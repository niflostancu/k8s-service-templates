# Makefile rules for 'ttrss'
APP_NAME = ttrss
NAMESPACE = default

COPY_FILES += deployment.yaml ingress.yaml service.yaml
BUILD_ASSETS += ttrss

ttrss-type = fetch-version
ttrss-image = niflostancu/ttrss
ttrss-url = https://hub.docker.com/r/$(ttrss-image)
ttrss-deps = $(ttrss_image_transf) $(ttrss_label_transf)

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
ttrss_image_transf = $(gen_dir)/transform-ttrss-image-tags.yaml
ttrss_label_transf = $(gen_dir)/transform-ttrss-labels.yaml
define ttrss-extra-rules=
$(call asset_generate_from_template,ttrss_label_transf,kust_label_transformer_tpl)
$(call asset_generate_from_template,ttrss_image_transf,kust_image_transformer_tpl)
endef

# Rule for creating database secrets
define ttrss_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" ttrss-db-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f TTRSS_DB_USER=ttrss -p TTRSS_DB_PASS
endef

ALL_RULES += $(nl)$(ttrss_secrets_rules)

