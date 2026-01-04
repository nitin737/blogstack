package com.blogging.auth.controller;

import com.blogging.auth.service.JwtService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/oauth")
public class OAuthController {

    private final JwtService jwtService;

    public OAuthController(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @GetMapping("/success")
    public Map<String, String> success(@AuthenticationPrincipal OAuth2User user) {
        String email = user.getAttribute("email");
        String token = jwtService.generateToken(email);

        return Map.of("token", token);
    }
}
