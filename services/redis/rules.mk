# Makefile rules for 'redis' store
APP_NAME = redis
NAMESPACE = default

COPY_FILES += deployment.yaml service.yaml configmap.yaml
BUILD_ASSETS += redis

redis-type = fetch-version
redis-image = library/redis
redis-url = https://hub.docker.com/r/$(redis-image)\#prefix=7.;suffix=alpine
redis-deps = $(redis_image_transf) $(redis_label_transf)

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
redis_image_transf = $(gen_dir)/transform-redis-image-tags.yaml
redis_label_transf = $(gen_dir)/transform-redis-labels.yaml
define redis-extra-rules=
$(call asset_generate_from_template,redis_label_transf,kust_label_transformer_tpl)
$(call asset_generate_from_template,redis_image_transf,kust_image_transformer_tpl)
endef

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

