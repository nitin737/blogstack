#!/bin/bash
set -e

# This script creates multiple databases in a single PostgreSQL instance
# It's executed during container initialization

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create databases for each service
    SELECT 'CREATE DATABASE auth_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'auth_db')\gexec
    SELECT 'CREATE DATABASE user_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'user_db')\gexec
    SELECT 'CREATE DATABASE posts_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'posts_db')\gexec
    SELECT 'CREATE DATABASE comment_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'comment_db')\gexec
    SELECT 'CREATE DATABASE engagement_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'engagement_db')\gexec
    SELECT 'CREATE DATABASE subscription_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'subscription_db')\gexec
    SELECT 'CREATE DATABASE notification_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'notification_db')\gexec
    SELECT 'CREATE DATABASE analytics_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'analytics_db')\gexec
    
    -- Grant privileges (optional, but recommended)
    GRANT ALL PRIVILEGES ON DATABASE auth_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE user_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE posts_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE comment_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE engagement_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE subscription_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE notification_db TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE analytics_db TO postgres;
EOSQL

echo "✅ All databases created successfully!"
