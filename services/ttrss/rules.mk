# Makefile rules for 'ttrss'
APP_NAME = ttrss

COPY_FILES += deployment.yaml ingress.yaml service.yaml
FETCH_ASSETS += ttrss

ttrss-manual = 1
ttrss-targets = $(ttrss_image_transform_file) $(ttrss_label_transform_file)
ttrss_image_transform_file = $(gen_dir)/transform-ttrss-image-tags.yaml
ttrss_label_transform_file = $(gen_dir)/transform-ttrss-labels.yaml
ttrss-image = niflostancu/ttrss
ttrss-url = https://hub.docker.com/r/$(ttrss-image)

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
define ttrss-extra-rules=
$(call asset_generate_from_template,ttrss_label_transform_file,kust_label_transformer_tpl)
$(call asset_generate_from_template,ttrss_image_transform_file,kust_image_transformer_tpl)

endef

# Rule for creating database secrets
define ttrss_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" ttrss-db-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f TTRSS_DB_USER=ttrss -p TTRSS_DB_PASS

endef

ALL_RULES += $(ttrss_secrets_rules)

