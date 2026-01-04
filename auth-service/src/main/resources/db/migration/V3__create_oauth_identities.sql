CREATE TABLE oauth_identities (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_oauth_user
        FOREIGN KEY (user_id)
        REFERENCES user_credentials(id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX ux_provider_identity
ON oauth_identities (provider, provider_user_id);

CREATE INDEX ix_oauth_user_id
ON oauth_identities (user_id);
