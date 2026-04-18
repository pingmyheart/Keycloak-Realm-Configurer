# Keycloak-Realm-Configurer

*Util to configure keycloak realm with roles and client for oauth authentication*

![Last Commit](https://img.shields.io/github/last-commit/pingmyheart/Keycloak-Realm-Configurer)
![Repo Size](https://img.shields.io/github/repo-size/pingmyheart/Keycloak-Realm-Configurer)
![Issues](https://img.shields.io/github/issues/pingmyheart/Keycloak-Realm-Configurer)
![Pull Requests](https://img.shields.io/github/issues-pr/pingmyheart/Keycloak-Realm-Configurer)
![License](https://img.shields.io/github/license/pingmyheart/Keycloak-Realm-Configurer)
![Top Language](https://img.shields.io/github/languages/top/pingmyheart/Keycloak-Realm-Configurer)
![Language Count](https://img.shields.io/github/languages/count/pingmyheart/Keycloak-Realm-Configurer)

## Features

- **Environment Variable Configuration**: Reads configuration from environment variables, allowing for flexible and
  dynamic setup.
- **Dockerized**: Can be easily run in a Docker container, making it suitable for deployment in various environments,
  including Kubernetes.
- **Easy To Use**: Provides a straightforward interface for configuring Keycloak realms, roles, and clients without the
  need for complex scripting or manual configuration.

## Required Configuration

In order to use the Keycloak-Realm-Configurer, you need to set the following environment variables:

```bash
CLI_REALM: "realm-name"
CLI_ROLES: "comma,separated,roles,to,be,created"
CLI_CLIENT: "realm-name-client"
CLI_ADMIN_CLIENT: "realm-name-admin-client"
CLI_ACCESS_TOKEN_LIFESPAN: "900" # Access token lifespan in seconds (default: 900 seconds or 15 minutes)
KEYCLOAK_SERVER: "http://localhost:8080" # Keycloak server URL
KEYCLOAK_ADMIN: "admin-username"
KEYCLOAK_ADMIN_PASSWORD: "admin-password"
```

## Usage

### Docker

Pull the Docker image and run a container. The container will execute the configuration process based on the provided
environment variables. The configuration will be applied to the Keycloak server specified in the `KEYCLOAK_SERVER`
environment variable. Then the container will exit after the configuration is complete.