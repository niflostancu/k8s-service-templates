## ==============================================
## == Asset version fetcher                    ==
## ==============================================

## May also be used by other asset builders requiring version info.

## === Common version fetcher options ===
# user version overrides
VERSION ?=
asset-version = $(if $($(asset)-ver),$($(asset)-ver),$(VERSION))
asset-version-meta-file ?= $(gen_dir)/$(asset).version
# asset digest property (type-specific, see below)
asset-digest = $(if $($(asset)-digest),$($(asset)-digest),$(asset-$(asset-type)-digest))
# custom fetch args
asset-version-def-args ?= $(asset-fetch-def-args) 
asset-version-args = $(if $($(asset)-ver-args),$($(asset)-ver-args),$(asset-version-def-args))
# default fetch-version asset target is also the version meta file
asset-fetch-version-target ?= $(asset-version-meta-file)

## === Asset version fetch implementation ===
# Generic asset fetcher invocation macros
# use with $(call macro-name,script args...)
asset_fetch_version = $(ASSET_FETCH_SCRIPT) $(1) "$(asset-url)"
asset_fetch_digest = $(ASSET_FETCH_SCRIPT) $(strip $(asset-fetch-cache-arg)) \
		--get-hash "$(asset-url)"
# default fetch script arguments
asset-fetch-def-args = $(strip $(asset-fetch-version-arg) $(asset-fetch-cache-arg))
asset-fetch-cache-arg = $(if $(asset-version-meta-file),--version-file="$(asset-version-meta-file)")
asset-fetch-version-arg = $(if $(UPDATE),--latest,$(if $(version),--version="$(version)",))
# asset version & digest properties
asset-version-invoke-script=$(if $(asset-version),$(asset-version),\
	$(shell $(call asset_fetch_version,$(asset-version-args))))
get-asset-version = $(strip $(if $(_$1-ver-cached),,$(eval _$1-ver-cached := 1)\
	$(eval _$1-version := $(let asset,$1,$(asset-version-invoke-script))))$(_$1-version))
# asset digest (hash) special trait (available for some URL services only)
get-asset-digest = $(let asset,$(1),$(asset-digest))
asset-fetch-version-digest = $(strip $(if $(_$(asset)-digest-cached),,$(eval _$(asset)-digest-cached := 1)\
	$(eval _$(asset)-digest := $(shell $(asset_fetch_digest))))$(_$(asset)-digest))

lib_asset_version_checks = $(call check-asset-var,asset-url) \
		$(call check-asset-var,asset-fetch-version-arg) \
		$(call check-asset-var,asset-version-meta-file)

define _lib_asset_version_target_alias=
$(call asset-assign-vars,$(asset-target))
$(asset-target): $(asset-version-meta-file)
	touch "$$@"
endef

# rules template for version fetching
define _lib_asset_version_rules=
# fetch-version asset rules:
$(lib_asset_common_head) $(strip \
	$(lib_asset_version_checks))
$(if $(filter-out $(asset-target),$(asset-version-meta-file)),\
	$(nl)$(_lib_asset_version_target_alias)) \
$(lib_asset_version_target)
$(lib_asset_common_tail)
endef

# special rule with the $(version) expanded only once
_lib_asset_ver_rules_cached=$(let version,$(call get-asset-version,$(asset)),$(_lib_asset_version_rules))

# register the asset type
LIB_ASSET[fetch-version]_DEPS=$(asset-target)
LIB_ASSET[fetch-version]_RULES=$(_lib_asset_ver_rules_cached)

# append the version parameter to the common rules
# (only when version is available)
lib_asset_common_vars+=$(if $(version),version)

# utility target to write the version to a file
define lib_asset_version_target=
# target for asset version meta file: \
$(call asset-assign-vars,$(asset-version-meta-file))
$(asset-version-meta-file): $(asset-deps)
	@mkdir -p "$$(@D)"
	@$(call asset_fetch_version,$(asset-version-args))
endef

