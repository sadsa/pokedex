# 🏗️ Pokedex

<div align="center">

![Pokedex](https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/16.png)

*Building the foundation for your Pokedex adventure*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Angular](https://img.shields.io/badge/Angular-DD0031?style=flat&logo=angular&logoColor=white)](https://angular.io/)
[![Keycloak](https://img.shields.io/badge/Keycloak-blue?style=flat&logo=data:image/png;base64,ABC123)](https://www.keycloak.org/)

</div>

## 📖 Overview

Pokedex orchestrates the core services needed for your Pokedex application. Just as Professor Oak's lab provides the foundation for a trainer's journey, this repository manages the essential components of your Pokedex ecosystem.

### 🌟 Features

- 🖥️ Frontend Angular application
- 🔐 Keycloak authentication service
- 🐳 Docker-based deployment
- 🛠️ Comprehensive Makefile for easy management

## 🚀 Quick Start

### Prerequisites

- Docker (20.10.x or higher)
- Docker Compose (2.x or higher)
- Make (required for automation scripts)

### Installation and Local Development

1. **Run setup**:
   ```bash
   make setup
   ```

2. **Set up environment variables**:
   ```bash
   cp .env.example .env
   ```
   Update the values in `.env` as needed.

3. **Start the services**:
   ```bash
   make up
   ```
   This command will automatically:
   - Clone the required repositories
   - Check environment variables
   - Start all services

4. **Access the services**:
   - Frontend: http://localhost:4200
   - Keycloak: https://localhost:8443

## 📋 Makefile Commands

Our Makefile provides comprehensive commands for managing the Pokedex infrastructure. View all available commands with:
```bash
make help
```

### Core Commands

```bash
make up              # Start all services
make down            # Stop all services
make restart         # Restart all services
make status          # Check the status of all services
make logs            # View logs from all services
make clean           # Remove all containers, volumes, and temporary files
make build           # Build the Docker images
make generate-certs  # Generate self-signed certificates
```

### Additional Commands

```bash
make check-env       # Verify all required environment variables are set
make export          # Export realm from Keycloak
make import          # Import realm to Keycloak
```

## 🏗️ Architecture

- The frontend service is built from the Angular repository
- Keycloak service is extended from its own compose file
- Services communicate through the `orchestration-network`
- Keycloak maintains its own internal network for database communication

## 💻 Development

To rebuild specific services:
```bash
docker-compose up -d --build frontend
```

## 🔒 Security

- Keycloak provides robust authentication and authorization
- HTTPS is enabled for secure communication
- Environment variables are used for sensitive information

## 📞 Support

- Run `make help` for command assistance
- Create an issue in this repository for bug reports or feature requests

---
*Gotta deploy 'em all!* 🚀🔧