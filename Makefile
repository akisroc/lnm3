# ----- /!\ -----
# --- DEV ONLY ---
# ----- /!\ -----

EXEC_PHX=docker compose exec lnm3_platform
EXEC_SF=docker compose exec lnm3_archive
EXEC_NUXT=docker compose exec lnm3_frontend

.PHONY: help setup up down restart logs ps shell-phx shell-nuxt db-migrate test

help: ## Display this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Init project (env, build, up)
	cp .env.example .env
	docker compose build
	$(MAKE) up
	sleep 5
	$(MAKE) db-setup
	@printf "\033[32mProject initialized and running\033[0m\n"

up: ## Start all services as daemons
	docker compose up -d

down:  ## Stop all services
	docker compose down

restart: ## Restart all services
	$(MAKE) down
	$(MAKE) up

logs: ## Display real-time logs
	docker compose logs -f

ps: ## Display all containers and their states
	docker compose ps

db-setup: ## Create, migrate and seed database
	docker compose run --rm -e PHX_SERVER=false lnm3_platform mix ecto.setup

db-seed: ## Seed database
	$(EXEC_PHX) mix run priv/repo/seeds.exs

db-reset: ## Reset database (drop, create, migrate, seed)
	$(EXEC_PHX) mix ecto.reset

db-migrate: ## Launch Phoenix/Ecto migrations
	$(EXEC_PHX) iex mix ecto.migrate

shell-phx: ## Enter in IEx shell
	$(EXEC_PHX) iex -S mix

shell-nuxt: ## Enter in Nuxt container
	$(EXEC_NUXT) sh

test: ## Launch tests on all services
	$(EXEC_PHX) mix test
	#$(EXEC_SF) bin/phpunit
