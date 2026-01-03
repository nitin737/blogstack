# Blogging Platform Monorepo (Blogstack)

Open Source platform for posting blogs.

## Structure

- `api-gateway`: Entry point for all requests.
- `auth-service`: Authentication and Authorization.
- `user-service`: User management.
- `post-service`: Blog posts management.
- `comment-service`: Comments on posts.
- `engagement-service`: Likes, shares, etc.
- `subscription-service`: User subscriptions.
- `notification-service`: Email and push notifications.
- `search-service`: Search functionality.
- `analytics-service`: User analytics.
- `common`: Shared libraries.

## Build

Run `./gradlew build` to build the project.
