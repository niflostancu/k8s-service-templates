## ==============================================
## == Generic asset build rules                ==
## ==============================================

## === Global variables ===
# Specifies the assets to fetch / build
FETCH_ASSETS ?= # old name
BUILD_ASSETS ?= $(FETCH_ASSETS)
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

# The name of the asset's main target (to use for deps)
asset-target = $(if $($(asset)),$($(asset)),$(asset-$(asset-type)-target))
# Asset type, specify using <asset name>-type or ASSET_TYPE global
asset-type = $(if $($(asset)-type),$($(asset)-type),$(if \
		$($(asset)-manual),fetch-version,$(ASSET_TYPE)))
# Asset URL to fetch (see fetch.sh documentation for features + syntax)
asset-url = $(if $($(asset)-url),$($(asset)-url),$(URL))
# Asset dependencies to also build with the current asset
asset-deps = $(if $($(asset)-deps),$($(asset)-deps),$($(asset)-targets))
# Extra asset Makefile rules to append to the script
asset-extra-rules = $(if $($(asset)-extra-rules),$($(asset)-extra-rules))

## Property getters:
get-asset-target = $(let asset,$1,$(asset-target))
get-asset-url = $(let asset,$1,$(asset-url))
get-asset-deps = $(let asset,$1,$(asset-deps))

## Utility macros to use in rules
# check asset-specific variable if defined & not empty
check-asset-var = $(if $(strip $($1)),,$(error $(asset): "$1" is not defined))
# Sanity checks!
_lib_asset_checks = $(call check-var,asset) $(call check-asset-var,asset-type) \
					$(call check-asset-var,asset-target)
# list of common asset vars to provide to all inner rules + macros
lib_asset_common_vars = asset
# common header: set asset-specific vars as immediates for rule expansion:
define lib_asset_common_head =
# header $(strip $(_lib_asset_checks)) \
$(foreach _var_,$(strip $(lib_asset_common_vars)),$(nl)$(_var_):=$($(_var_))#)
endef
asset-assign-vars = $(foreach _var_,$(strip $(lib_asset_common_vars)),\
		$(nl)$(1): $(_var_):=$$($(_var_))#)

define lib_asset_common_tail=
$(if $(asset-extra-rules),# append any extra rules \
	$(nl)$(asset-extra-rules)$(nl))
# footer: reset common asset vars \
$(foreach _var_,$(strip $(lib_asset_common_vars)),$(nl)$(_var_):=#)

endef

# global rules for all declared assets
LIB_ASSET_ALL_RULES = $(foreach asset,$(BUILD_ASSETS),$(nl)$(_lib_asset_rules_))
_lib_asset__rules = LIB_ASSET[$(asset-type)]_RULES
_lib_asset__rules_check = $(call check-var,LIB_ASSET[$(asset-type)]_RULES) \
						  $(call check-var,LIB_ASSET[$(asset-type)]_DEPS)
_lib_asset_rules_ = $($(_lib_asset__rules))$(strip $(_lib_asset__rules_check))

# global dependencies (prereqs) for all declared assets
ALL_ASSET_DEPS = $(foreach asset,$(BUILD_ASSETS),$(_lib_asset_deps_))
_lib_asset_deps_ = $(LIB_ASSET[$(asset-type)]_DEPS)

ALL_RULES += $(nl)\# BUILD_ASSETS: $(BUILD_ASSETS)
ALL_RULES += $(nl)$(LIB_ASSET_ALL_RULES)

