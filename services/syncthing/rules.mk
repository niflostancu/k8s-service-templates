# Makefile rules for 'syncthing' (file synchronization tool)
APP_NAME = syncthing

COPY_FILES += statefulset.yaml service.yaml
FETCH_ASSETS += syncthing

syncthing-manual = 1
syncthing-targets = $(syncthing_image_transform_file) $(syncthing_label_transform_file)
syncthing_image_transform_file = $(gen_dir)/transform-syncthing-image-tags.yaml
syncthing_label_transform_file = $(gen_dir)/transform-syncthing-labels.yaml
syncthing-image = syncthing/syncthing
syncthing-url = https://hub.docker.com/r/$(syncthing-image)\#prefix=1.

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
define syncthing-extra-rules=
$(call asset_generate_from_template,syncthing_label_transform_file,kust_label_transformer_tpl)
$(call asset_generate_from_template,syncthing_image_transform_file,kust_image_transformer_tpl)

endef

