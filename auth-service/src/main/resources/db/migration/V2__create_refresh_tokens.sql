CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_refresh_user
        FOREIGN KEY (user_id)
        REFERENCES user_credentials(id)
        ON DELETE CASCADE
);

CREATE INDEX ix_refresh_user_id
ON refresh_tokens (user_id);

CREATE UNIQUE INDEX ux_refresh_token
ON refresh_tokens (token);
