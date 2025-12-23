# Makefile rules for 'postgres' database server
APP_NAME = postgres
NAMESPACE = default

COPY_FILES += statefulset.yaml service.yaml
BUILD_ASSETS += postgres
VERSION_PREFIX=15.
VERSION_SUFFIX=-alpine
URL_ARGS=prefix=$(VERSION_PREFIX);suffix=$(VERSION_SUFFIX)

postgres-type = fetch-version
postgres-image = library/postgres
postgres-url = https://hub.docker.com/r/$(postgres-image)\#$(URL_ARGS)

# generate standard kustomize resource transformers (see kustomize-snippets.mk)
postgres-image-transf = $(gen_dir)/transform-postgres-image-tags.yaml
postgres-image-transf-type = kust-snippet@image-transformer
postgres-label-transf = $(gen_dir)/transform-postgres-labels.yaml
postgres-label-transf-type = kust-snippet@label-transformer
BUILD_ASSETS += postgres-image-transf postgres-label-transf

# Rule for creating database secrets
define postgres_secrets_rules=
.PHONY: secrets
secrets:
	"$(scripts_dir)/prompt-secret.sh" postgres-env $(A) \
		--namespace "$(NAMESPACE)" \
		-f POSTGRES_USER=postgres -p POSTGRES_PASSWORD \
		-f POSTGRES_DB=postgres
endef

# Rules for running PostgreSQL administration scripts (using kubectl run)
A = --help || echo "Please enter arguments using A=\"...\""
define postgres_admin_rules=
.PHONY: run_client create_db_user
run_client: A=
run_client: scripts/client.sh
	"$$<" $(A)
create_db_user: scripts/create-db-user.sh
	"$$<" $(A)
endef

define ALL_RULES+=
$(nl)$(postgres_secrets_rules)
$(nl)$(postgres_admin_rules)
endef
