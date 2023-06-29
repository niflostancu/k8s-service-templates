# Asset fetcher target + variables
#

# space separated list of assets to manage
FETCH_ASSETS ?=

# Note: everything below may use the special $(asset) variable
asset-version=$(if $($(asset)-ver),$($(asset)-ver),$(VERSION))
asset-url = $(if $($(asset)-url),$($(asset)-url),$(URL))
asset-file = $($(asset))
asset-target = $(if $(asset-manual),$(asset),$(asset-file))
asset-targets = $($(asset)-targets)
asset-version-file = $(gen_dir)/$(asset).version
asset-download = $(if $($(asset)-download),$($(asset)-download),$(asset_fetch_download))
asset-manual = $($(asset)-manual)

# prerequisites to put for including the fetched assets
asset_fetch_reqs = $(foreach asset,$(FETCH_ASSETS),$(asset-target))
# asset fetcher rules to evaluate
asset_fetch_rules = $(foreach asset,$(FETCH_ASSETS),$(_asset_rule_ver))

# asset fetch script invocation macros
asset_fetch_args ?=
_asset_ver_file ?= $(if $(asset-version-file),--version-file="$(asset-version-file)")
_asset_ver_arg ?= $(if $(UPDATE),--latest,$(if $(version),--version="$(version)",))
_asset_fetch_args ?= $(strip $(_asset_ver_arg) $(_asset_ver_file)) $(asset_fetch_args)
asset_fetch_version = $(asset_fetch_script) $(_asset_fetch_args) "$(asset-url)"
asset_fetch_hash = $(asset_fetch_script) $(_asset_ver_arg) --get-hash "$(asset-url)"
asset_fetch_download = $(asset_fetch_script) $(_asset_fetch_args) --download "$(asset-url)"

# internal values
_asset_read_version=$(if $(asset-version),$(asset-version),$(shell $(asset_fetch_version)))
# insert the fetched version into the $(asset-file) path
_asset_versioned=$(basename $(asset-file))-$(version)$(suffix $(asset-file))

# cache $(version) within the rule expansion
define _asset_rule_manual=
.PHONY: $(asset-target)
$(asset-target): $(asset-targets)

endef
define _asset_rule_download=
$(asset-target): $(_asset_versioned) $(asset-version-file)
	ln -sf "$$$$(basename "$$<")" "$$@"
$(_asset_versioned): asset=$(asset)
$(_asset_versioned): version=$(version)
$(_asset_versioned): $(asset-version-file)
	$(asset-download) "$$@"

endef
define _asset_rule=
asset:=$(asset)
version:=$(version)

$(if $(asset-manual),$(_asset_rule_manual),$(_asset_rule_download))
$(asset-version-file):
	@mkdir -p "$$(@D)"
	@echo "$(version)" > "$$@"

$(if $($(asset)-extra-rules),$($(asset)-extra-rules))
asset:=
version:=

endef
_asset_rule_ver=$(let version,$(_asset_read_version),$(_asset_rule))

# macro for rules to generate asset file from make var template (using
# expansion)
define asset_generate_from_template=
$($(1)): $(asset-version-file)
	echo "$$$$$(2)" > $$@
# export variables using simple expansion (to be expanded inside the asset's rule)
$(2):=$$($(2))
export $(2)

endef

ALL_RULES += $(asset_fetch_rules)
