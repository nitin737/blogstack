#!/bin/bash
set -e

# This script creates multiple databases in a single PostgreSQL instance
# It's executed during container initialization

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create databases for each service
    SELECT 'CREATE DATABASE blogging_auth' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_auth')\gexec
    SELECT 'CREATE DATABASE blogging_user' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_user')\gexec
    SELECT 'CREATE DATABASE blogging_post' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_post')\gexec
    SELECT 'CREATE DATABASE blogging_comment' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_comment')\gexec
    SELECT 'CREATE DATABASE blogging_engagement' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_engagement')\gexec
    SELECT 'CREATE DATABASE blogging_subscription' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_subscription')\gexec
    SELECT 'CREATE DATABASE blogging_notification' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_notification')\gexec
    SELECT 'CREATE DATABASE blogging_analytics' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'blogging_analytics')\gexec
    
    -- Grant privileges (optional, but recommended)
    GRANT ALL PRIVILEGES ON DATABASE blogging_auth TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_user TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_post TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_comment TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_engagement TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_subscription TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_notification TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE blogging_analytics TO postgres;
EOSQL

echo "✅ All databases created successfully!"
