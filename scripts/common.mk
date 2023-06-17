# Utility Makefile macros library

# Populate utility variables
_mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
scripts_dir := $(patsubst %/,%,$(dir $(_mkfile_path)))
base_dir := $(patsubst %/,%,$(dir $(scripts_dir)))
tmp_dir = $(resource_dir)/tmp

# scripts / binaries
kubectl ?= kubectl $(kubectl_args)
kustomize ?= kubectl kustomize $(kustomize_args)
kube_apply ?= kubectl $(kubectl_args) apply -f -
asset_fetch_script ?= "$(scripts_dir)/fetch.sh"

kustomize_args ?=
# kustomize_args += --load-restrictor=none
kubectl_args ?=

# load user config
-include $(base_dir)/config.local.mk

# Asset fetcher target + variables
asset_fetch_args ?=
_asset_ver_arg ?= $(if $(findstring latest,$(VERSION)),--latest,\
					$(if $(VERSION),--version=$(VERSION),))
_asset_fetch_args ?= $(strip $(_asset_ver_arg)) $(asset_fetch_args)
download_asset = $(asset_fetch_script) $(_asset_fetch_args) --download $(URL) $@
get_assets_reqs = $(foreach asset,$(ASSETS),$($(asset)))

# first rule => apply
_: apply
.FORCE:
.PHONY: _ .FORCE

# debug / print mk database rule
.PHONY: @debug
@debug:
	@echo "base_dir = $(base_dir)"
	@echo "tmp_dir = $(tmp_dir)"
	@$(MAKE) -r -p $(filter-out @debug,$(resource_dir))

include $(base_dir)/scripts/default-rules.mk

