# Utility Makefile macros library

# Populate utility variables
_mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
scripts_dir := $(patsubst %/,%,$(dir $(_mkfile_path)))
base_dir := $(patsubst %/,%,$(dir $(scripts_dir)))
gen_dir = $(resource_dir)/generated

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

# first rule => apply
_: apply
.FORCE:
.PHONY: _ .FORCE

# debug / print mk database rule
.PHONY: @debug
@debug:
	@echo "base_dir = $(base_dir)"
	@echo "gen_dir = $(gen_dir)"
	@$(MAKE) -r -p $(filter-out @debug,$(resource_dir))

include $(base_dir)/scripts/asset-fetch.mk
include $(base_dir)/scripts/kustomize.mk

