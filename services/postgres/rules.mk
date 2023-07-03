# Makefile rules for 'postgres' database server
APP_NAME = postgres
NAMESPACE = default

COPY_FILES += statefulset.yaml service.yaml
FETCH_ASSETS += postgres

postgres-manual = 1
postgres-targets = $(postgres_image_transform_file) $(postgres_label_transform_file)
postgres_image_transform_file = $(gen_dir)/transform-postgres-image-tags.yaml
postgres_label_transform_file = $(gen_dir)/transform-postgres-labels.yaml
postgres-image = library/postgres
postgres-url = https://hub.docker.com/r/$(postgres-image)\#prefix=15;suffix=alpine

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
define postgres-extra-rules=
$(call asset_generate_from_template,postgres_label_transform_file,kust_label_transformer_tpl)
$(call asset_generate_from_template,postgres_image_transform_file,kust_image_transformer_tpl)

endef

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
.PHONY: run_client create_user
run_client: scripts/client.sh
	"$$<"
create_db_user: scripts/create-db-user.sh
	"$$<" $(A)
endef

ALL_RULES += $(postgres_secrets_rules) $(postgres_admin_rules)

