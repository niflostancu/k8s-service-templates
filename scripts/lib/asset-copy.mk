## =================================================
## == File copying asset type / rules / helpers   ==
## =================================================

# Global var. for simple copy rule generation
COPY_FILES ?=

# asset copy type-specific options:
asset-copy-src ?= $(if $($(asset)-src),$($(asset)-src),$(asset-url))
asset-copy-dest ?= $(if $($(asset)-dest),$(gen_dir)/$($(asset)-dest),$(asset-target))
asset-copy-def-args ?= $(asset-fetch-def-args)
asset-copy-args = $(if $($(asset)-args),$($(asset)-args),)

## === Global rule generation macros (using COPY_FILES) ===

# Copies _file from a resource's src dir to gen_dir
define _lib_copy_file_rule=
$(_file:%=$(gen_dir)/%): $(_file)
	@mkdir -p "$$(dir $$(abspath $$@))"
	cp -f "$$<" "$$@"
endef

# Rule to copy ALL declared files
define LIB_COPY_FILES_RULES_ALL=
# global copy rules: \
$(foreach _file,$(COPY_FILES),$(nl)$(_lib_copy_file_rule))
endef

# Dependencies all globally copied files
LIB_COPY_FILES_DEPS_ALL ?= $(COPY_FILES:%=$(gen_dir)/%)

ALL_RULES += $(nl)$(nl)$(LIB_COPY_FILES_RULES_ALL)$(nl)

## === Asset rule generation macros (using `<asset>-type = copy`) ===

define _lib_asset_copy_alias=
$(asset-target): $(asset-deps) $(asset-copy-dest)
endef

define _lib_asset_copy_rules=
# copy asset rules:
$(lib_asset_common_head)
# main copy targets: \
$(if $(filter-out $(asset-target),$(asset-copy-dest)),$(nl)$(_lib_asset_copy_alias)) \
$(call asset-assign-vars,$(asset-copy-dest))
$(asset-copy-dest): $(asset-copy-src) $(asset-deps)
	@mkdir -p "$$(dir $$(abspath $$@))"
	cp -f "$$<" "$$@"
$(lib_asset_common_tail)
endef

# register the asset type
LIB_ASSET[copy]_DEPS=$(asset-target)
LIB_ASSET[copy]_RULES=$(_lib_asset_copy_rules)

