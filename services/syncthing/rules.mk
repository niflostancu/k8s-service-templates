# Makefile rules for 'syncthing' (file synchronization tool)
APP_NAME = syncthing
NAMESPACE = default

COPY_FILES += statefulset.yaml service.yaml
BUILD_ASSETS += syncthing

syncthing-type = fetch-version
syncthing-image = syncthing/syncthing
syncthing-url = https://hub.docker.com/r/$(syncthing-image)\#prefix=1.

# generate standard kustomize resource transformers (see kustomize-snippets.mk)
syncthing-image-transf = $(gen_dir)/transform-syncthing-image-tags.yaml
syncthing-image-transf-type = kust-snippet@image-transformer
syncthing-label-transf = $(gen_dir)/transform-syncthing-labels.yaml
syncthing-label-transf-type = kust-snippet@label-transformer
BUILD_ASSETS += syncthing-image-transf syncthing-label-transf

