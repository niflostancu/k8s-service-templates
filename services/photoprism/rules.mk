# Makefile rules for PhotoPrism
APP_NAME = photoprism
NAMESPACE = default

COPY_FILES += deployment.yaml ingress.yaml service.yaml
BUILD_ASSETS += photoprism

VERSION_PREFIX=24

photoprism-type = fetch-version
photoprism-image = photoprism/photoprism
photoprism-url = https://hub.docker.com/r/$(photoprism-image)\#prefix=$(VERSION_PREFIX)

# generate standard kustomize resource transformers (see kustomize-snippets.mk)
photoprism-image-transf = $(gen_dir)/transform-photoprism-image-tags.yaml
photoprism-image-transf-type = kust-snippet@image-transformer
photoprism-label-transf = $(gen_dir)/transform-photoprism-labels.yaml
photoprism-label-transf-type = kust-snippet@label-transformer
BUILD_ASSETS += photoprism-image-transf photoprism-label-transf

# Rule for creating secrets
define photoprism_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" photoprism-secret-env $(A) \
		--namespace "$(NAMESPACE)" \
		-p PHOTOPRISM_ADMIN_PASSWORD -p PHOTOPRISM_DATABASE_PASSWORD
endef

# Rules for running PhotoPrism administration scripts (using kubectl run)
A = --help || echo "Please enter arguments using A=\"...\""
define photoprism_admin_rules=
.PHONY: cli
cli: scripts/cli.sh
	"$$<"
endef

define ALL_RULES+=
$(nl)$(photoprism_secrets_rules)
$(nl)$(photoprism_admin_rules)
endef
