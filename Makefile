include .env
export

CYAN_COLOR=\033[36;01m
NO_COLOR=\033[0m
RED_COLOR=\033[31;01m
YELLOW_COLOR=\033[33;01m

TAG=$$(git log -1 --pretty=%h)

help:
	@echo ""
	@echo "$(YELLOW_COLOR)Usage: make [TARGET] [EXTRA_ARGUMENTS]"
	@echo "$(YELLOW_COLOR)* Targets:"
	@echo "$(CYAN_COLOR)  * build         - Initiates everything (building images, installing gems)"
	@echo "$(CYAN_COLOR)  * rebuild       - Re-initiates everything (building images, installing gems) without cache"
	@echo "$(CYAN_COLOR)  * run-debug     - Run project without background service"
	@echo "$(CYAN_COLOR)  * run-server    - Run project as a background service"
	@echo "$(RED_COLOR)  * destroy       - Remove all containers"
	@echo "$(CYAN_COLOR)  * migrate       - Run migration service container for migrations"
	@echo "$(CYAN_COLOR)  * console       - Run Rails console"
	@echo "$(CYAN_COLOR)  * restart       - Restart specific service (make restart service=service_name)"
	@echo ""


build:
	@echo "$(CYAN_COLOR)==> Building Image...$(NO_COLOR)"
	sudo docker build . -t ${WEB_IMAGE}

rebuild:
	@echo "$(CYAN_COLOR)==> Re-Building Image...$(NO_COLOR)"
	sudo docker build . --no-cache -t $(WEB_IMAGE)

run-debug:
	@echo "$(CYAN_COLOR)==> Starting rails server as a background service...$(NO_COLOR)"
	sudo docker-compose up

run-server:
	@echo "$(CYAN_COLOR)==> Starting rails server...$(NO_COLOR)"
	sudo docker-compose up -d

destroy:
	@echo "$(RED_COLOR)==> Destroying all containers...$(NO_COLOR)"
	@docker rm -f `docker ps -aq`

dbconsole:
	@echo "$(CYAN_COLOR)==> Starting rails database console...$(NO_COLOR)"
	docker-compose exec postgres psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}

db-migrate:
	@echo "$(CYAN_COLOR)==> Runing database migrations...$(NO_COLOR)"
	docker-compose up app-migration

console:
	@echo "$(CYAN_COLOR)==> Starting rails console...$(NO_COLOR)"
	docker-compose exec web rails console

restart:
	@echo "$(CYAN_COLOR)==> Re-Starting ${service}...$(NO_COLOR)"
	docker-compose restart ${service}
