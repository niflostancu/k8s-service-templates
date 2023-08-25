## ==============================================
## == Generic asset build rules                ==
## ==============================================

## === Global variables ===
# Specifies the assets to fetch / build
FETCH_ASSETS?=# old name
BUILD_ASSETS?=$(FETCH_ASSETS)
# Global variable to force upgrading of assets
UPDATE ?=

# Default URL (use for single assets)
URL ?=
# Default asset type
ASSET_TYPE ?= download
# Path to the asset fetcher script
ASSET_FETCH_SCRIPT ?= "$(scripts_dir)/fetch.sh"

## === Generic asset variables ===
## (most are user-overridable and inherit global defaults)

# generic target name for an asset; if `$(<asset name>)` is defined it will be used,
# otherwise it will just be `<asset name>`
asset-target = $(if $($(asset)),$($(asset)),$(asset))
# Asset type, specify using <asset name>-type or ASSET_TYPE global
asset-type = $(if $($(asset)-type),$($(asset)-type),$(if \
		$($(asset)-manual),fetch-version,$(ASSET_TYPE)))
# Asset URL to fetch (see fetch.sh documentation for features + syntax)
asset-url = $(if $($(asset)-url),$($(asset)-url),$(URL))
# Asset dependencies to also build with the current asset
asset-deps = $(if $($(asset)-deps),$($(asset)-deps),$($(asset)-targets))
# Extra asset Makefile rules to append to the script
asset-extra-rules = $(if $($(asset)-extra-rules),$($(asset)-extra-rules))

## Utility macros to use in rules
# Sanity checks!
_lib_asset_checks = $(call check-var,asset) $(call check-var,asset-type) \
					$(call check-var,asset-target)
# list of common asset vars to provide to all inner rules + macros
lib_asset_common_vars = asset
# common header: set asset-specific vars as immediates for rule expansion:
define lib_asset_common_head =
# header $(_lib_asset_checks) \
$(foreach _var_,$(lib_asset_common_vars),$(nl)$(_var_):=$($(_var_))#)
endef
asset-assign-vars = $(foreach _var_,$(lib_asset_common_vars), \
		$(nl)$(1): $(_var_)=$$($(_var_)))

define lib_asset_common_tail=
# append any extra rules $(check-var asset)
$(asset-extra-rules)$(nl)
# footer: reset common asset vars \
$(foreach _var_,$(lib_asset_common_vars),$(nl)$(_var_):=#)
endef

# global dependencies (prereqs) for all declared assets
LIB_ASSET_ALL_DEPS = $(foreach asset,$(BUILD_ASSETS),$(_lib_asset_deps_))
_lib_asset__deps = LIB_ASSET[$(asset-type)]_DEPS
_lib_asset_deps_ = $(call check-var,$(_lib_asset__deps))$($(_lib_asset__deps))

# global rules for all declared assets
LIB_ASSET_ALL_RULES = $(foreach asset,$(BUILD_ASSETS),$(nl)$(_lib_asset_rules_))
_lib_asset__rules = LIB_ASSET[$(asset-type)]_RULES
_lib_asset_rules_ = $(call check-var,$(_lib_asset__rules))$($(_lib_asset__rules))

ALL_RULES += $(nl)\# BUILD_ASSETS: $(BUILD_ASSETS)
ALL_RULES += $(nl)$(LIB_ASSET_ALL_RULES)

