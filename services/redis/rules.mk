# Makefile rules for 'redis' store
APP_NAME = redis
NAMESPACE = default

COPY_FILES += deployment.yaml service.yaml configmap.yaml
BUILD_ASSETS += redis

redis-ver ?= 
_redis_pfx = $(if $(redis-ver),prefix=$(redis-ver).;)

redis-type = fetch-version
redis-image = library/redis
redis-url = https://hub.docker.com/r/$(redis-image)\#$(_redis_pfx);suffix=alpine

# generate standard kustomize resource transformers (see kustomize-snippets.mk)
redis-image-transf = $(gen_dir)/transform-redis-image-tags.yaml
redis-image-transf-type = kust-snippet@image-transformer
redis-label-transf = $(gen_dir)/transform-redis-labels.yaml
redis-label-transf-type = kust-snippet@label-transformer
BUILD_ASSETS += redis-image-transf redis-label-transf

# Rule for creating secrets (unused, for now)
define redis_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" redis-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f REDIS_USER=redis -p REDIS_PASSWORD
endef

# Rules for running Redis administration scripts (using kubectl run)
A = --help || echo "Please enter arguments using A=\"...\""
define redis_admin_rules=
.PHONY: run_client
run_client: scripts/client.sh
	"$$<"
endef

define ALL_RULES+=
$(nl)$(redis_secrets_rules)
$(nl)$(redis_admin_rules)
endef

