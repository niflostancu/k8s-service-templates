# Makefile rules for 'ttrss'
APP_NAME = ttrss
NAMESPACE = default

COPY_FILES += deployment.yaml ingress.yaml service.yaml
BUILD_ASSETS += ttrss

ttrss-type = fetch-version
ttrss-image = $(DOCKER_IMAGE_PREFIX)ttrss
ttrss-url = https://hub.docker.com/r/$(ttrss-image)

# generate standard kustomize resource transformers (see kustomize-snippets.mk)
ttrss-image-transf = $(gen_dir)/transform-ttrss-image-tags.yaml
ttrss-image-transf-type = kust-snippet@image-transformer
ttrss-label-transf = $(gen_dir)/transform-ttrss-labels.yaml
ttrss-label-transf-type = kust-snippet@label-transformer
BUILD_ASSETS += ttrss-image-transf ttrss-label-transf

# Rule for creating database secrets
define ttrss_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" ttrss-db-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f TTRSS_DB_USER=ttrss -p TTRSS_DB_PASS
endef

ALL_RULES += $(nl)$(ttrss_secrets_rules)

