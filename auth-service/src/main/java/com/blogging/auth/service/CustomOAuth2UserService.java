package com.blogging.auth.service;

import com.blogging.auth.entity.OAuthIdentity;
import com.blogging.auth.entity.UserCredential;
import com.blogging.auth.repository.OAuthIdentityRepository;
import com.blogging.auth.repository.UserCredentialRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.UUID;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

        private final UserCredentialRepository userCredentialRepository;
        private final OAuthIdentityRepository oauthIdentityRepository;

        public CustomOAuth2UserService(UserCredentialRepository userCredentialRepository,
                        OAuthIdentityRepository oauthIdentityRepository) {
                this.userCredentialRepository = userCredentialRepository;
                this.oauthIdentityRepository = oauthIdentityRepository;
        }

        @Override
        @Transactional
        public OAuth2User loadUser(OAuth2UserRequest request) throws OAuth2AuthenticationException {
                OAuth2User oauth2User = super.loadUser(request);

                String provider = request.getClientRegistration().getRegistrationId();
                String providerUserId = oauth2User.getAttribute("sub");
                String email = oauth2User.getAttribute("email");

                oauthIdentityRepository
                                .findByProviderAndProviderUserId(provider, providerUserId)
                                .orElseGet(() -> registerNewOAuthUser(provider, providerUserId, email));

                // Default role is USER for now, as roles are managed in user-service according
                // to sync flow
                return new DefaultOAuth2User(
                                Collections.singleton(new SimpleGrantedAuthority("ROLE_USER")),
                                oauth2User.getAttributes(),
                                "sub");
        }

        private OAuthIdentity registerNewOAuthUser(String provider, String providerUserId, String email) {
                UserCredential user = UserCredential.builder()
                                .id(UUID.randomUUID())
                                .email(email)
                                .status(UserCredential.UserStatus.ACTIVE)
                                .build();

                user = userCredentialRepository.save(user);

                OAuthIdentity oauthIdentity = OAuthIdentity.builder()
                                .id(UUID.randomUUID())
                                .user(user)
                                .provider(provider)
                                .providerUserId(providerUserId)
                                .email(email)
                                .build();

                return oauthIdentityRepository.save(oauthIdentity);
        }
}
