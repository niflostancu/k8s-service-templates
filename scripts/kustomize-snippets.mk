# Useful Makefile snippets for Kustomize resource generation

# Template for generating Kustomize ImageTagTransformer file to override
# a resource's image and version tag (from $(asset)-image and $(version))
define kust_image_transformer_tpl=
apiVersion: builtin
kind: ImageTagTransformer
metadata:
  name: $(asset)-set-image-version
imageTag:
  name: $(asset)
  newName: $($(asset)-image)
  newTag: $(version)

endef

# Template for generating Kustomize LabelTransformer file to set
# a resource's version + hash to the asset's commit / image digest.
# Uses the $(asset_fetch_hash) script to fetch the hash of the current version.
define kust_label_transformer_tpl=
apiVersion: builtin
kind: LabelTransformer
metadata:
  name: $(asset)-set-hash-label
labels:
  app.kubernetes.io/version: $(version)
  app.kubernetes.io/digest: $(shell $(asset_fetch_hash))
fieldSpecs:
  - path: metadata/labels
    create: true

endef

# macro for rules to generate asset file from make var template (using
# expansion)
define asset_generate_from_template=
$($(1)): $(asset-version-file)
	echo "$$$$$(2)" > $$@
# export variables using simple expansion (to be expanded inside the asset's rule)
$(2):=$$($(2))
export $(2)

endef

