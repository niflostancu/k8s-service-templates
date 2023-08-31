## ===============================================
## == Kustomize snippets (macros & asset rules) ==
## ===============================================

# common snippet asset options:
asset-kust-snippet-inherit ?= $(if $(kustomize-inherit),$(kustomize-inherit),$(firstword \
	$(filter-out $(DEFAULT_ASSETS),$(BUILD_ASSETS))))
asset-kust-snippet-resource ?= $(if $($(asset)-resource),$($(asset)-resource),$(kustomize-name))
asset-kust-snippet-version ?= $(if $(asset-version),$(asset-version),$(strip \
	$(call get-asset-version,$(asset-kust-snippet-inherit))))
# must replace all hyphens with underscore
asset-kust-snippet-varname ?= $(subst -,_,$(asset))__DATA

asset-kust-snippet-type ?= $(patsubst kust-snippet@%,%,$(asset-type))
asset-kust-snippet-tpl ?= $(if $($(asset)-tpl),$($(asset)-tpl),$(kust-snippet-tpl@$(asset-kust-snippet-type)))

define _lib_asset_kust_snippet_rules=
# kustomize snippet asset rules:
$(lib_asset_common_head) \
	$(strip $(call check-asset-var,asset-target) \
	$(call check-asset-var,asset-kust-snippet-version) \
	$(call check-asset-var,asset-kust-snippet-tpl))
# rule to generate the target file from template variable: \
$(call asset-assign-vars,$(asset-target))
$(asset-target): $(call get-asset-target,$(asset-kust-snippet-inherit)) $(asset-deps)
	echo "$$$${$(asset-kust-snippet-varname)}" > $$@
# export variables using simple expansion (to be expanded inside the asset's rule)
$(asset-kust-snippet-varname):=$$(asset-kust-snippet-tpl)
export $(asset-kust-snippet-varname) \
$(lib_asset_common_tail)
endef

## Useful Makefile snippets for Kustomize resource generation

# Template for generating Kustomize ImageTagTransformer file to override
# a resource's image and version tag (from $(asset)-image and $(version))
define kust-snippet-tpl@image-transformer=
apiVersion: builtin
kind: ImageTagTransformer
metadata:
  name: "$(asset)"
imageTag:
  name: "$(asset-kust-snippet-resource)"
  newName: "$(call get-asset-docker-image,$(asset-kust-snippet-inherit))"
  newTag: "$(call get-asset-version,$(asset-kust-snippet-inherit))"
endef
# backwards compatibility alias
kust_image_transformer_tpl = $(kust-snippet-tpl@image-transformer)

# Template for generating Kustomize LabelTransformer file to set
# a resource's version + hash to the asset's commit / image digest.
define kust-snippet-tpl@label-transformer=
apiVersion: builtin
kind: LabelTransformer
metadata:
  name: $(asset)
labels:
  app.kubernetes.io/version: "$(call get-asset-version,$(asset-kust-snippet-inherit))"
  app.kubernetes.io/digest: "$(call get-asset-digest,$(asset-kust-snippet-inherit))"
fieldSpecs:
  - path: metadata/labels
    create: true
endef
# backwards compatibility alias
kust_label_transformer_tpl = $(kust-snippet-tpl@label-transformer)

# utility macro for rules to generate asset file from make var template
# (using expansion)
define asset_generate_from_template=
$($(1)): $(asset-version-file)
	echo "$$$${$(1)__DATA}" > $$@
# export variables using simple expansion (to be expanded inside the asset's rule)
$(1)__DATA:=$$($(2))
export $(1)__DATA
endef

# register the asset types + quick snippets
LIB_ASSET[kust-snippet]_DEPS=$(asset-target)
LIB_ASSET[kust-snippet]_RULES=$(_lib_asset_kust_snippet_rules)

LIB_ASSET[kust-snippet@label-transformer]_DEPS=$(asset-target)
LIB_ASSET[kust-snippet@label-transformer]_RULES=$(_lib_asset_kust_snippet_rules)
LIB_ASSET[kust-snippet@image-transformer]_DEPS=$(asset-target)
LIB_ASSET[kust-snippet@image-transformer]_RULES=$(_lib_asset_kust_snippet_rules)

