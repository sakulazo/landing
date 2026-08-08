# Makefile — despliegue de un sitio estático (Astro)
# Contrato estándar (ADR-0004): help / build / push / deploy MSG= / verify
# Plantilla canónica: infra-vps/templates/Makefile.static
# Uso: make deploy MSG="descripción del cambio"

# ── Variables por proyecto ────────────────────────────────────────────
# SITE_NAME: nombre corto · SITE_URL: URL pública · REMOTE_DIR: raíz servida por
# Caddy (¡debe empezar por /srv/!) · REMOTE_OWNER: propietario real en /srv ·
# BUILD_CMD: comando de build. SIN comentarios inline (los espacios rompen owner:group).
SITE_NAME    := landing
SITE_URL     := https://sakulazo.com/
REMOTE_DIR   := /srv/landing
REMOTE_OWNER := sakulito
BUILD_CMD    := npm run build

# ── Infraestructura SSH (común) ───────────────────────────────────────
SSH_HOST   := sakulito@185.214.134.40
SSH_PORT   := 42932
SSH_KEY    := $(HOME)/.ssh/id_ed25519
GIT_REMOTE := origin
GIT_BRANCH := main

.PHONY: help build push deploy verify

help: ## Muestra la ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Construye el sitio (genera dist/)
	$(BUILD_CMD)

push: ## Commit + push a GitHub (requiere MSG="descripción")
	@test -n "$(MSG)" || { echo "ERROR: falta MSG=... p.ej. make deploy MSG=\"fix: texto\""; exit 1; }
	git add -A
	git diff --cached --quiet || git commit -m "$(MSG)"
	git push $(GIT_REMOTE) $(GIT_BRANCH)

deploy: build push ## Build + push + subida al VPS (limpia el destino completo)
	@case "$(REMOTE_DIR)" in /srv/*) ;; *) echo "ERROR: REMOTE_DIR inseguro: $(REMOTE_DIR)"; exit 1;; esac
	@echo ">> $(SITE_NAME): subiendo build a $(SSH_HOST):$(REMOTE_DIR)"
	@tar -C dist -cf - . | ssh -i $(SSH_KEY) -p $(SSH_PORT) $(SSH_HOST) \
	  'sudo find $(REMOTE_DIR) -mindepth 1 -delete && sudo mkdir -p $(REMOTE_DIR) && sudo tar -C $(REMOTE_DIR) -xf - \
	   && sudo chown -R $(REMOTE_OWNER):$(REMOTE_OWNER) $(REMOTE_DIR) \
	   && sudo find $(REMOTE_DIR) -type f -exec chmod 644 {} + \
	   && sudo find $(REMOTE_DIR) -type d -exec chmod 755 {} +'
	@$(MAKE) verify

verify: ## Comprueba que el sitio responde 200
	@ssh -i $(SSH_KEY) -p $(SSH_PORT) $(SSH_HOST) 'curl -s -o /dev/null -w "$(SITE_NAME): HTTP %{http_code}\n" $(SITE_URL)'
