# Makefile rules for 'nextcloud'
APP_NAME = nextcloud
NAMESPACE = default

# override it to fix the major version
#VERSION_PREFIX=32.
VERSION_SUFFIX=-apache
URL_ARGS=prefix=$(VERSION_PREFIX);suffix=$(VERSION_SUFFIX)

COPY_FILES += deployment.yaml ingress.yaml service.yaml
# multi-stage asset build process
BUILD_ASSETS += nc-base docker-files docker-image

# default nextcloud build arguments
NEXTCLOUD_UID = 1000
NEXTCLOUD_GID = 1000

# target to fetch the base image version data
nc-base-type = fetch-version
nc-base-image = library/nextcloud
nc-base-url = https://hub.docker.com/r/$(nc-base-image)\#$(URL_ARGS)

# copy the docker src files into the resource's generated dir
docker-files-type = copy
docker-files = $(gen_dir)/image-cust/.copied
docker-files-src = $(call get-resource-files,image-cust/**)
docker-files-args = -r

# build & push a customized docker image (derived from the one fetched above)
docker-image-type = docker-buildx
docker-image-ver = $(call get-asset-version,nc-base)
docker-image-image = $(DOCKER_IMAGE_PREFIX)nextcloud-custom
docker-image-deps = $(call get-asset-target,nc-base docker-files)
docker-image-src = $(gen_dir)/image-cust
# push to repo; DISABLED BY DEFAULT (enable in your customization)
#docker-image-push = 1
#docker-image-platforms = $(DOCKER_DEFAULT_PLATFORMS)
docker-image-tags = $(version) latest
docker-image-args = --build-arg="BASE_IMAGE=$(nc-base-image):$(version)" \
		--build-arg="NEXTCLOUD_UID=$(NEXTCLOUD_UID)" \
		--build-arg="NEXTCLOUD_GID=$(NEXTCLOUD_GID)"

kustomize-inherit = docker-image
kustomize-deps += $(call get-asset-target,nc-base copy-files docker-image nc-label-transf nc-image-transf)

# generate standard kustomize resource transformers (see kustomize-snippets.mk)
nc-image-transf = $(gen_dir)/transform-nextcloud-image-tags.yaml
nc-image-transf-type = kust-snippet@image-transformer
nc-label-transf = $(gen_dir)/transform-nextcloud-labels.yaml
nc-label-transf-type = kust-snippet@label-transformer
BUILD_ASSETS += nc-image-transf nc-label-transf

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
