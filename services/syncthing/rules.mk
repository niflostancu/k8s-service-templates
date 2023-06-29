# Makefile rules for 'syncthing' (file synchronization tool)
APP_NAME = syncthing

COPY_FILES += statefulset.yaml service.yaml
FETCH_ASSETS += syncthing

syncthing-manual = 1
syncthing-targets = $(syncthing_image_file) $(syncthing_label_file)
syncthing_image_file = $(gen_dir)/transform-syncthing-image-tags.yaml
syncthing_label_file = $(gen_dir)/transform-syncthing-labels.yaml
syncthing-image = syncthing/syncthing
syncthing-url = https://hub.docker.com/r/$(syncthing-image)\#prefix=1.

define syncthing_image_transformer_tpl=
apiVersion: builtin
kind: ImageTagTransformer
metadata:
  name: syncthing-set-image-version
imageTag:
  name: syncthing
  newName: $(syncthing-image)
  newTag: $(version)

endef

define syncthing_label_transformer_tpl=
apiVersion: builtin
kind: LabelTransformer
metadata:
  name: syncthing-set-hash-label
labels:
  app.kubernetes.io/version: $(version)
  app.kubernetes.io/digest: $(shell $(asset_fetch_hash))
fieldSpecs:
  - path: metadata/labels
    create: true

endef

define syncthing-extra-rules=
$(call asset_generate_from_template,syncthing_label_file,syncthing_label_transformer_tpl)
$(call asset_generate_from_template,syncthing_image_file,syncthing_image_transformer_tpl)

endef

