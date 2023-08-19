# Makefile rules for 'redis' store
APP_NAME = redis
NAMESPACE = default

COPY_FILES += deployment.yaml service.yaml configmap.yaml
FETCH_ASSETS += redis

redis-manual = 1
redis-targets = $(redis_image_transform_file) $(redis_label_transform_file)
redis_image_transform_file = $(gen_dir)/transform-redis-image-tags.yaml
redis_label_transform_file = $(gen_dir)/transform-redis-labels.yaml
redis-image = library/redis
redis-url = https://hub.docker.com/r/$(redis-image)\#prefix=7.;suffix=alpine

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
define redis-extra-rules=
$(call asset_generate_from_template,redis_label_transform_file,kust_label_transformer_tpl)
$(call asset_generate_from_template,redis_image_transform_file,kust_image_transformer_tpl)

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

ALL_RULES += $(redis_secrets_rules) $(redis_admin_rules)

