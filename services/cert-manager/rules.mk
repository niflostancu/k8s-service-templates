# cert-manager helper makefile

APP_NAME = cert-manager
ASSETS = main

KUSTOMIZE_ARGS ?=
APPLY_ARGS ?=

# used assets
URL_main = https://github.com/cert-manager/cert-manager/releases/download/{VERSION}/cert-manager.yaml
ASSET_main = cert-manager.yaml
VERSION_main ?=

