# Asset fetcher target + variables
#

# space separated list of assets to manage
FETCH_ASSETS ?=

# Note: everything below may use the special $(asset) variable
asset-version = $(if $($(asset)-ver),$($(asset)-ver),$(VERSION))
asset-url = $(if $($(asset)-url),$($(asset)-url),$(URL))
asset-file = $($(asset))
asset-version-file = $(gen_dir)/$(asset).version

# prerequisites to put for including the fetched assets
asset_fetch_reqs = $(foreach asset,$(FETCH_ASSETS),$(asset-file))
# asset fetcher rules to evaluate
asset_fetch_rules = $(foreach asset,$(FETCH_ASSETS),$(_asset_rule))

# asset fetch script invocation macros
asset_fetch_args ?=
_asset_ver_file ?= $(if $(asset-version-file),--version-file=$(asset-version-file))
_asset_ver_arg ?= $(if $(findstring latest,$(asset-version)),--latest,\
					$(if $(asset-version),--version=$(asset-version),))
_asset_fetch_args ?= $(strip $(_asset_ver_arg) $(_asset_ver_file)) $(asset_fetch_args)
download_asset = $(asset_fetch_script) $(_asset_fetch_args) --download $(asset-url)
fetch_cached_version = $(asset_fetch_script) $(_asset_fetch_args) $(asset-url)
fetch_latest_version = $(foreach asset-version,latest,$(fetch_cached_version))

# internal values
_asset_read_version=$(shell $(if $(UPDATE),$(fetch_latest_version),$(fetch_cached_version)))
# insert the fetched version into the $(asset-file) path
_asset_versioned_=$(basename $(asset-file))-$(_asset_read_version)$(suffix $(asset-file))

define _asset_rule =
$(asset-file): $(_asset_versioned_) $(asset-version-file)
	ln -sf "$$$$(basename "$$<")" "$$@"
$(_asset_versioned_): $(asset-version-file)
	$(download_asset) "$$@"
$(asset-version-file):
	$(fetch_cached_version)

endef

ALL_RULES += $(asset_fetch_rules)
