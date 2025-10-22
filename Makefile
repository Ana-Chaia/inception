DOCKER_COMPOSE=docker compose -f $(DOCKER_COMPOSE_FILE)
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml
PROJECT_ENV_URL = https://raw.githubusercontent.com/Ana-Chaia/inception/refs/heads/main/srcs/
DOMAIN_NAME = anacaro5.42.fr

all: config build

verify_os:
	@echo "Verificando sistema operacional (Ubuntu/Debian)..."
	@if [ -r /etc/os-release ]; then \
		. /etc/os-release; \
		if [ "$$ID" = "debian" ] || [ "$$ID" = "ubuntu" ] || echo "$$ID_LIKE" | grep -qi debian; then \
			echo "OK: $$PRETTY_NAME detectado."; \
		else \
			echo "Erro: Sistema não suportado: $$PRETTY_NAME"; exit 1; \
		fi; \
	else \
		echo "Erro: /etc/os-release não encontrado. Abortando."; exit 1; \
	fi;

install:
	@$(MAKE) verify_os

# Uninstall old versions
	sudo apt remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --purge
	sudo apt autoremove -y
# Install Docker Engine, containerd, and Docker Compose.
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh ./get-docker.sh && rm ./get-docker.sh
# Docker permissions
	sudo usermod -aG docker $$(whoami)
	echo "%docker ALL=(ALL) NOPASSWD: /home/$$(whoami)/data/*" | sudo tee /etc/sudoers.d/docker
	@echo ""
	@echo "Docker installed successfully!"
	@docker --version
	@echo ""
	@docker compose version
	@echo ""
	
config:
	@$(MAKE) verify_os
	@echo "Getting the .env file..."
	@if [ ! -f ./srcs/.env ]; then \
		curl -fsSL "$(PROJECT_ENV_URL)/.env" -o ./srcs/.env; \
		else echo ".env file already exists!"; \
	fi
	@echo ""
	@echo ""

	@echo "Add $(DOMAIN_NAME) in /etc/hosts..."
		@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts > /dev/null; \
		else echo "$$(whoami).42.fr already exists in /etc/hosts!"; \
	fi
	
# Create mariadb and wordpress directories if they don't exist

	@if [ ! -d "/home/$$(whoami)/data/mysql" ]; then \
		mkdir -p "/home/$$(whoami)/data/mysql"; \
	else \
		echo "Mysql data directory already exists!"; \
	fi
	@echo ""
	@echo ""

	@if [ ! -d "/home/$$(whoami)/data/wordpress" ]; then \
		mkdir -p "/home/$$(whoami)/data/wordpress"; \
	else \
		echo "Wordpress data directory already exists!"; \
	fi
	@echo ""
	@echo ""

build:
	@$(DOCKER_COMPOSE) up --build -d
kill:
	@$(DOCKER_COMPOSE) kill
down:
	@$(DOCKER_COMPOSE) down
clean:
	@containers_before=$$(docker ps -aq | wc -l); \
	echo "Quantidade de conteiners em execucao: $$containers_before";
	@$(DOCKER_COMPOSE) down -v > /dev/null

fclean: clean
	@sudo sed -i "/$(DOMAIN_NAME)/d" /etc/hosts;
	@images_before=$$(docker images -q | wc -l); \
	echo "Quantidade de imagens existentes: $$images_before";
	@if [ -d "$(HOME)/data" ]; then \
		echo "Removendo $(HOME)/data..."; \
		sudo rm -rf "$(HOME)/data"; \
	else \
		echo "$(HOME)/data não existe. Pulando remoção."; \
	fi
	@if [ -f srcs/.env ]; then \
		echo "Removendo arquivo .env"; \
		sudo rm -rf srcs/.env; \
	else \
		echo "Arquivo srcs/.env nao existe"; \
	fi
	@echo "Pruning Docker system..."
	@docker system prune -a -f >/dev/null
	@containers_after=$$(docker ps -aq | wc -l); \
	images_after=$$(docker images -q | wc -l); \
	echo "Quantidade de conteiners que ficaram: $$containers_after"; \
	echo "Quantidade de imagens que ficaram:    $$images_after"

uninstall:
	sudo apt remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --purge
	sudo apt autoremove -y
	sudo rm -r /etc/sudoers.d/docker || true

restart: clean build

.PHONY: build clean fclean down install kill restart uninstall verify_os config all
