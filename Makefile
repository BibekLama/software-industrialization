-include .env
export

NETWORK_NAME ?= sw_infra_net
COMPOSE      := docker compose --env-file .env
PROXY        := $(COMPOSE) -f proxy/compose.yml
POSTGRES     := $(COMPOSE) -f postgres/compose.yml
PGADMIN      := $(COMPOSE) -f pgadmin/compose.yml
GITEA        := $(COMPOSE) -f gitea/compose.yml
SONAR     := $(COMPOSE) -f sonarqube/compose.yml
NEXUS     := $(COMPOSE) -f nexus/compose.yml
JENKINS   := $(COMPOSE) -f jenkins/compose.yml

.DEFAULT_GOAL := help
.NOTPARALLEL:

.PHONY: help up down status \
        network-create network-remove network-recreate network-status \
        proxy-up proxy-down proxy-restart proxy-logs proxy-ps proxy-config \
        postgres-up postgres-down postgres-logs postgres-ps postgres-config \
        postgres-check postgres-reset \
        pgadmin-up pgadmin-down pgadmin-restart pgadmin-logs pgadmin-ps pgadmin-config \
        gitea-up gitea-down gitea-restart gitea-logs gitea-ps gitea-config \
        gitea-admin-create
		sonar-up sonar-down sonar-restart sonar-logs sonar-ps sonar-config \
        nexus-up nexus-down nexus-restart nexus-logs nexus-ps nexus-config \
        jenkins-up jenkins-down jenkins-restart jenkins-logs jenkins-ps jenkins-config


help:
	@echo "Stack"
	@echo "  make up                  Network, proxy, postgres, pgadmin, gitea (in order)"
	@echo "  make down                Reverse order, then remove network"
	@echo "  make status              Containers attached to $(NETWORK_NAME)"
	@echo ""
	@echo "Network ($(NETWORK_NAME))"
	@echo "  make network-create      Create network (idempotent)"
	@echo "  make network-remove      Remove network (fails if containers attached)"
	@echo "  make network-recreate    Remove, then create"
	@echo "  make network-status      Show network and attached containers"
	@echo ""
	@echo "Proxy (Traefik)"
	@echo "  make proxy-up|down|restart|logs|ps|config"
	@echo ""
	@echo "Postgres"
	@echo "  make postgres-up|down|logs|ps|config"
	@echo "  make postgres-check      Verify app DB logins (SELECT 1)"
	@echo "  make postgres-reset      DELETE data volume (asks for confirmation)"
	@echo ""
	@echo "pgAdmin"
	@echo "  make pgadmin-up|down|restart|logs|ps|config"
	@echo ""
	@echo "Gitea"
	@echo "  make gitea-up|down|restart|logs|ps|config"
	@echo "  make gitea-admin-create  Create admin user from .env"
	@echo ""
	@echo "SonarQube"
	@echo "  make sonar-up | sonar-down | sonar-restart | sonar-logs | sonar-ps | sonar-config"
	@echo ""
	@echo "Nexus"
	@echo "  make nexus-up | nexus-down | nexus-restart | nexus-logs | nexus-ps | nexus-config"
	@echo ""
	@echo "Jenkins"
	@echo "  make jenkins-up | jenkins-down | jenkins-restart | jenkins-logs | jenkins-ps | jenkins-config"


# ---------- Stack ----------
up: proxy-up postgres-up pgadmin-up gitea-up sonar-up nexus-up jenkins-up

down: jenkins-down nexus-down sonar-down gitea-down pgadmin-down postgres-down proxy-down network-remove

status:
	@docker ps --filter network=$(NETWORK_NAME) --format 'table {{.Names}}\t{{.Status}}'

# ---------- Network ----------
network-create:
	@./network/create-network.sh

network-remove:
	@./network/remove-network.sh

network-recreate: network-remove network-create

network-status:
	@docker network ls --filter name=^$(NETWORK_NAME)$$
	@docker network inspect $(NETWORK_NAME) \
		--format '{{range .Containers}}{{.Name}}{{"\n"}}{{end}}' 2>/dev/null || true

# ---------- Proxy ----------
proxy-up: network-create
	@$(PROXY) up -d

proxy-down:
	@$(PROXY) down

proxy-restart: network-create
	@$(PROXY) up -d --force-recreate

proxy-logs:
	@$(PROXY) logs -f --tail=100

proxy-ps:
	@$(PROXY) ps

proxy-config:
	@$(PROXY) config

# ---------- Postgres ----------
postgres-up: network-create
	@$(POSTGRES) up -d --wait

postgres-down:
	@$(POSTGRES) down

postgres-logs:
	@$(POSTGRES) logs -f --tail=100

postgres-ps:
	@$(POSTGRES) ps

postgres-config:
	@$(POSTGRES) config

postgres-check:
	@docker exec postgres psql -U $(GITEA_DB_USER) -d $(GITEA_DB_NAME) -c "SELECT 1;"
	@docker exec postgres psql -U $(SONAR_DB_USER) -d $(SONAR_DB_NAME) -c "SELECT 1;"

postgres-reset:
	@read -p "This DELETES all Postgres data (Gitea + SonarQube DBs). Type 'yes': " a; \
		[ "$$a" = "yes" ] || { echo "Aborted."; exit 1; }
	@$(POSTGRES) down -v

# ---------- pgAdmin ----------
pgadmin-up: network-create
	@$(PGADMIN) up -d

pgadmin-down:
	@$(PGADMIN) down

pgadmin-restart:
	@$(PGADMIN) restart

pgadmin-logs:
	@$(PGADMIN) logs -f --tail=100

pgadmin-ps:
	@$(PGADMIN) ps

pgadmin-config:
	@$(PGADMIN) config

# ---------- Gitea ----------
gitea-up: network-create
	@$(GITEA) up -d

gitea-down:
	@$(GITEA) down

gitea-restart:
	@$(GITEA) restart

gitea-logs:
	@$(GITEA) logs -f --tail=100

gitea-ps:
	@$(GITEA) ps

gitea-config:
	@$(GITEA) config

gitea-admin-create:
	@$(GITEA) exec -T --user git gitea gitea admin user create \
		--admin --username "$(GITEA_ADMIN_USER)" --password "$(GITEA_ADMIN_PASSWORD)" \
		--email "$(GITEA_ADMIN_EMAIL)" --must-change-password=false

# ---------- SonarQube ----------
sonar-up: network-create
	@$(SONAR) up -d --wait
sonar-down:
	@$(SONAR) down
sonar-restart:
	@$(SONAR) restart
sonar-logs:
	@$(SONAR) logs -f --tail=100
sonar-ps:
	@$(SONAR) ps
sonar-config:
	@$(SONAR) config

# ---------- Nexus ----------
nexus-up: network-create
	@$(NEXUS) up -d --wait
nexus-down:
	@$(NEXUS) down
nexus-restart:
	@$(NEXUS) restart
nexus-logs:
	@$(NEXUS) logs -f --tail=100
nexus-ps:
	@$(NEXUS) ps
nexus-config:
	@$(NEXUS) config

# ---------- Jenkins ----------
jenkins-up: network-create
	@$(JENKINS) up -d --wait
jenkins-down:
	@$(JENKINS) down
jenkins-restart:
	@$(JENKINS) restart
jenkins-logs:
	@$(JENKINS) logs -f --tail=100
jenkins-ps:
	@$(JENKINS) ps
jenkins-config:
	@$(JENKINS) config
