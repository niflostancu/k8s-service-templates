## ==============================================
## == Docker image buildx rules & utils         ==
## ==============================================

# Global Configuration variables + shortands
DOCKER_BIN ?= docker
DOCKER_BUILDX_ARGS ?=
DOCKER_BUILDX_PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v7

# asset-specific options
asset-docker-buildx-src ?= $(if $($(asset)-src),$($(asset)-src),.)
asset-docker-buildx-file ?= $(if $($(asset)-file),$($(asset)-file),Dockerfile)
asset-docker-buildx-image ?= $(if $($(asset)-image),$($(asset)-image),$(asset))
asset-docker-buildx-tags ?= $(if $($(asset)-tags),$($(asset)-tags),latest)
asset-docker-buildx-args = $(if $($(asset)-args),$($(asset)-args),$(DOCKER_BUILDX_ARGS))
asset-docker-buildx-digest-file = $(gen_dir)/$(asset).docker-digest
# deploy type: `push` (default) or `load`
asset-docker-buildx-deploy = $(if $($(asset)-deploy),$($(asset)-deploy),push)
# default docker buildx target: the build digest file
asset-docker-buildx-target ?= $(asset-docker-buildx-digest-file)

# asset digest trait
# note: strip colon prefix + limit string to 32 characters (for k8s usage)
asset-docker-buildx-digest = $(strip $(if $(_$(asset)-digest-cached),,$(eval _$(asset)-digest-cached := 1)\
	$(eval _$(asset)-digest := $(shell head -1 $(asset-docker-buildx-digest-file) |\
		cut -d: -f2 | cut -c 1-60)))$(_$(asset)-digest))

## compute docker targets / CLI args
_asset_docker_buildx_src = $(asset-docker-buildx-src)/$(asset-docker-buildx-file)
_asset_docker_buildx_digest_fetch = $(DOCKER_BIN) inspect --format='{{index .RepoDigests 0}}'
_asset_docker_buildx_platf = $(if $(DOCKER_BUILDX_PLATFORMS),--platform $(DOCKER_BUILDX_PLATFORMS))
_asset_docker_buildx_tags = $(foreach tag,$(asset-docker-buildx-tags),\
							-t "$(asset-docker-buildx-image):$(tag)")
_asset_docker_buildx_file = -f $(asset-docker-buildx-file)
_asset_docker_buildx_deploy = $(if $(asset-docker-buildx-deploy),--$(asset-docker-buildx-deploy))
_asset_docker_buildx_args =  $(info A-$(asset)-A)$(asset-docker-buildx-args) $(_asset_docker_buildx_platf) \
		$(_asset_docker_buildx_file) $(_asset_docker_buildx_tags) \
		$(if $(UPDATE),--pull --no-cache) $(_asset_docker_buildx_deploy)

define _lib_asset_docker_buildx_alias=
$(call asset-assign-vars,$(asset-target))
$(asset-target): $(asset-docker-buildx-digest-file))
	touch "$$@"
endef

define _lib_asset_docker_buildx_rules=
# docker buildx asset rules:
$(lib_asset_common_head) \
	$(strip $(call check-asset-var,asset-docker-buildx-src) \
	$(call check-asset-var,asset-docker-buildx-file) \
	$(call check-asset-var,asset-docker-buildx-image) \
	$(call check-asset-var,asset-docker-buildx-tags))
# use a special image hash file as main target \
$(if $(filter-out $(asset-target),$(asset-docker-buildx-digest-file)),\
	$(nl)$(_lib_asset_docker_buildx_alias)) \
$(call asset-assign-vars,$(asset-docker-buildx-digest-file))
$(asset-docker-buildx-digest-file): $(_asset_docker_buildx_src) $(asset-deps)
	cd "$$(dir $$<)" && $$(DOCKER_BIN) buildx build \
		--iidfile "$$(abspath $$@.tmp)" $$(_asset_docker_buildx_args) .
	if ! cmp -s "$$@.tmp" "$$@"; then \
		mv "$$@.tmp" "$$@"; fi; rm -f "$$@.tmp"

$(lib_asset_common_tail)
endef

# register the asset type
LIB_ASSET[docker-buildx]_DEPS=$(asset-target)
LIB_ASSET[docker-buildx]_RULES=$(if $(asset-version),\
	$(let version,$(asset-version),$(_lib_asset_docker_buildx_rules)),\
	$(_lib_asset_docker_buildx_rules))

