# Makefile rules for 'nextcloud'
APP_NAME = nextcloud
NAMESPACE = default

COPY_FILES += deployment.yaml ingress.yaml service.yaml
BUILD_ASSETS += nextcloud

nextcloud-type = fetch-version
nextcloud-deps = $(nextcloud_image_transf) $(nextcloud_label_transf)
nextcloud-image = library/nextcloud
nextcloud-url = https://hub.docker.com/r/$(nextcloud-image)\#prefix=27.;suffix=-apache

nextcloud_image_transf = $(gen_dir)/transform-nextcloud-image-tags.yaml
nextcloud_label_transf = $(gen_dir)/transform-nextcloud-labels.yaml

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
define nextcloud-extra-rules=
$(call asset_generate_from_template,nextcloud_label_transf,kust_label_transformer_tpl)
$(call asset_generate_from_template,nextcloud_image_transf,kust_image_transformer_tpl)
endef

# Rule for creating database secrets
define nextcloud_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" nextcloud-db-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f POSTGRES_USER=nextcloud -p POSTGRES_PASSWORD
endef

# Rules for running Nextcloud administration scripts (using kubectl run)
A = --help || echo "Please enter arguments using A=\"...\""
define nextcloud_admin_rules=
.PHONY: cli
cli: scripts/cli.sh
	"$$<"
endef

define ALL_RULES+=
$(nl)$(nextcloud_secrets_rules)
$(nl)$(nextcloud_admin_rules)
endef
