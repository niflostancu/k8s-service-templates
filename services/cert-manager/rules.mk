# Makefile rules for 'cert-manager'

APP_NAME = cert-manager
# E.g.: override asset version
#VERSION = v1.11.0

KUSTOMIZE_ARGS ?=
APPLY_ARGS ?=

# assets used
FETCH_ASSETS = cert-manager
# Example to include extra files to the kustomization build
#COPY_FILES += issuer-cloudflare.yaml tls-mydomains.yaml

cert-manager = $(gen_dir)/cert-manager.yaml
cert-manager-url = https://github.com/cert-manager/cert-manager/releases/download/{VERSION}/cert-manager.yaml
#cert-manager-ver = v1.11.0

