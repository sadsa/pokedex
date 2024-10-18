include .env
export

# Makefile for pokedex infrastructure
SHELL := /bin/bash

# Configuration
DOCKER_COMPOSE := docker compose
BACKUP_DIR := backups
CURRENT_DATE := $(shell date '+%Y%m%d_%H%M%S')
PROJECT_NAME := pokedex

# Colors for pretty printing
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# Define repositories to clone
REPOS := snorlax-auth pokedex-frontend

# Check if .env file exists, if not copy from example
ifneq ($(wildcard .env),)
    include .env
else
    $(shell cp .env.example .env)
    include .env
endif

.PHONY: help up down status logs restart clean build export import generate-certs

help: ## Display this help
	@echo -e "$(BLUE)pokedex Makefile Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-30s$(NC) %s\n", $$1, $$2}'

generate-certs: ## Generate self-signed certificates
	@echo -e "$(BLUE)Generating self-signed certificates...$(NC)"
	@cd ../snorlax-auth && make generate-certs

check-env: ## Verify all required environment variables are set
	@echo -e "$(BLUE)Checking environment variables...$(NC)"
	@test -n "$(POSTGRES_PASSWORD)" || (echo -e "$(RED)POSTGRES_PASSWORD is not set$(NC)" && exit 1)
	@test -n "$(KC_BOOTSTRAP_ADMIN_PASSWORD)" || (echo -e "$(RED)KC_BOOTSTRAP_ADMIN_PASSWORD is not set$(NC)" && exit 1)
	@echo -e "$(GREEN)Environment variables check passed$(NC)"

clone-repos: ## Clone required repositories
	@echo -e "$(BLUE)Cloning required repositories...$(NC)"
	@for repo in $(REPOS); do \
		if [ ! -d "../$$repo" ]; then \
			git clone https://github.com/your-organization/$$repo.git ../$$repo; \
		else \
			echo -e "$(YELLOW)$$repo repository already exists$(NC)"; \
		fi; \
	done
	@echo -e "$(GREEN)Repositories cloned successfully$(NC)"

up: check-env clone-repos ## Start all services
	@echo -e "$(BLUE)Starting services...$(NC)"
	@mkdir -p $(BACKUP_DIR)
	$(DOCKER_COMPOSE) up -d
	@echo -e "$(GREEN)Services started successfully$(NC)"
	@echo -e "Frontend available at: http://localhost:4200"
	@echo -e "Keycloak available at: https://localhost:8443"

down: ## Stop all services
	@echo -e "$(BLUE)Stopping services...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo -e "$(GREEN)Services stopped successfully$(NC)"

status: ## Check the status of all services
	@echo -e "$(BLUE)Service status:$(NC)"
	$(DOCKER_COMPOSE) ps

logs: ## View logs from all services
	$(DOCKER_COMPOSE) logs -f

restart: down up ## Restart all services

clean: down ## Remove all containers, volumes, and temporary files
	@echo -e "$(BLUE)Cleaning up...$(NC)"
	$(DOCKER_COMPOSE) down -v
	rm -rf data/*
	@echo -e "$(GREEN)Cleanup complete$(NC)"

build: ## Build the Docker images
	@echo -e "$(BLUE)Building Docker images...$(NC)"
	$(DOCKER_COMPOSE) build

export: ## Export realm from Keycloak
	@echo -e "$(BLUE)Exporting realm...$(NC)"
	@mkdir -p $(BACKUP_DIR)
	@echo "Stopping Keycloak service..."
	@$(DOCKER_COMPOSE) stop keycloak
	@echo "Backing up realm configuration..."
	@$(DOCKER_COMPOSE) run --rm keycloak export --dir /tmp/export --users realm_file
	@$(DOCKER_COMPOSE) cp keycloak:/tmp/export $(BACKUP_DIR)/export
	@echo "Restarting Keycloak service..."
	@$(DOCKER_COMPOSE) start keycloak

import: ## Import realm from the backups/export directory
	@echo -e "$(BLUE)Importing realm from $(BACKUP_DIR)/export/$(NC)"
	@if [ ! -d "$(BACKUP_DIR)/export" ]; then \
		echo -e "$(RED)Error: $(BACKUP_DIR)/export directory not found$(NC)"; \
		exit 1; \
	fi
	@echo "Stopping Keycloak service..."
	@$(DOCKER_COMPOSE) stop keycloak
	@echo "Importing realm configuration..."
	@$(DOCKER_COMPOSE) run --rm -v $(PWD)/$(BACKUP_DIR)/export:/tmp/import keycloak import --dir /tmp/import
	@echo "Restarting Keycloak service..."
	@$(DOCKER_COMPOSE) start keycloak
	@echo -e "$(GREEN)Realm import completed$(NC)"