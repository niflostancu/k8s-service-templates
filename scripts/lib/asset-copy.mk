## =================================================
## == File copying asset type / rules / helpers   ==
## =================================================

# Global var. for simple copy rule generation (see below)
COPY_FILES ?=

# asset copy type-specific options:
asset-copy-src ?= $(if $($(asset)-src),$($(asset)-src),$(asset-url))
asset-copy-dest ?= $(if $($(asset)-dest),$($(asset)-dest),$(asset-copy-src:%=$(gen_dir)/%))
asset-copy-rule-deps ?= $(if $(word 2,$(asset-copy-src)),$(gen_dir)/%: %,$(asset-copy-src))
asset-copy-def-args ?= $(asset-fetch-def-args)
asset-copy-args = $(if $($(asset)-args),$($(asset)-args),-f)
# default copy asset target: use destination path
asset-copy-target ?= $(asset-copy-dest)

## === Asset rule generation macros (using `<asset>-type = copy`) ===

define _lib_asset_copy_alias=
$(asset-target): $(asset-copy-dest)
	touch "$(asset-target)"
endef

define _lib_asset_copy_rules=
# copy asset rules:
$(lib_asset_common_head)
# main copy targets: \
$(if $(filter-out $(asset-target),$(asset-copy-dest)),$(nl)$(_lib_asset_copy_alias)) \
$(call asset-assign-vars,$(asset-copy-dest))
$(asset-copy-dest): $(asset-copy-rule-deps) $(asset-deps)
	@mkdir -p "$$(dir $$(abspath $$@))"
	cp $(asset-copy-args) "$$<" "$$@"
$(lib_asset_common_tail)
endef

# register the asset type
LIB_ASSET[copy]_DEPS=$(asset-target)
LIB_ASSET[copy]_RULES=$(_lib_asset_copy_rules)

## === Standard COPY_FILES asset ===
copy-files-src = $(COPY_FILES)
copy-files-type = copy

BUILD_ASSETS += $(if $(COPY_FILES),copy-files)

