# Makefile rules for 'nextcloud'
APP_NAME = nextcloud

COPY_FILES += deployment.yaml ingress.yaml service.yaml
FETCH_ASSETS += nextcloud

nextcloud-manual = 1
nextcloud-targets = $(nextcloud_image_transform_file) $(nextcloud_label_transform_file)
nextcloud_image_transform_file = $(gen_dir)/transform-nextcloud-image-tags.yaml
nextcloud_label_transform_file = $(gen_dir)/transform-nextcloud-labels.yaml
nextcloud-image = library/nextcloud
nextcloud-url = https://hub.docker.com/r/$(nextcloud-image)\#prefix=27.;suffix=-apache

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
define nextcloud-extra-rules=
$(call asset_generate_from_template,nextcloud_label_transform_file,kust_label_transformer_tpl)
$(call asset_generate_from_template,nextcloud_image_transform_file,kust_image_transformer_tpl)

endef

# Rule for creating database secrets
define nextcloud_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" nextcloud-db-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f POSTGRES_USER=nextcloud -p POSTGRES_PASSWORD

endef

ALL_RULES += $(nextcloud_secrets_rules)

