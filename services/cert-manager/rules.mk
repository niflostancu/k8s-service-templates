# Makefile rules for 'cert-manager'

APP_NAME = cert-manager
# E.g.: override asset version
#VERSION = v1.11.0

KUSTOMIZE_ARGS ?=
APPLY_ARGS ?=

# assets used
ASSETS = cert-manager

cert-manager = $(tmp_dir)/cert-manager.yaml
cert-manager-url = https://github.com/cert-manager/cert-manager/releases/download/{VERSION}/cert-manager.yaml
#cert-manager-ver = v1.11.0

# include default rules
$(eval $(default_kustomize_rules))
$(eval $(default_asset_rules))

