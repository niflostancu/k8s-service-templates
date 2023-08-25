# Makefile rules for 'syncthing' (file synchronization tool)
APP_NAME = syncthing
NAMESPACE = default

COPY_FILES += statefulset.yaml service.yaml
BUILD_ASSETS += syncthing

syncthing-type = fetch-version
syncthing-image = syncthing/syncthing
syncthing-url = https://hub.docker.com/r/$(syncthing-image)\#prefix=1.
syncthing-deps = $(syncthing_image_transf) $(syncthing_label_transf)

# generate standard kustomize res. transformers (see kustomize-snippets.mk)
syncthing_image_transf = $(gen_dir)/transform-syncthing-image-tags.yaml
syncthing_label_transf = $(gen_dir)/transform-syncthing-labels.yaml
define syncthing-extra-rules=
$(call asset_generate_from_template,syncthing_label_transf,kust_label_transformer_tpl)
$(call asset_generate_from_template,syncthing_image_transf,kust_image_transformer_tpl)
endef

