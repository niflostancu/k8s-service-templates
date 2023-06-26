# Utility Makefile macros library

# Populate utility variables
_last_mkfile = $(lastword $(MAKEFILE_LIST))
scripts_dir := $(patsubst %/,%,$(dir $(_last_mkfile)))
base_dir := $(patsubst %/,%,$(dir $(scripts_dir)))
parent_dir := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
resource_name = $(resource_dir)
gen_dir = $(abspath $(resource_dir))/generated
src_dir = $(parent_dir)

# scripts / binaries
kubectl ?= kubectl $(kubectl_args)
kustomize ?= kubectl kustomize $(kustomize_args)
kube_apply ?= kubectl $(kubectl_args) apply -f -
asset_fetch_script ?= "$(scripts_dir)/fetch.sh"

kustomize_args ?=
# kustomize_args += --load-restrictor=none
kubectl_args ?=

base_resource_dir=$(base_dir)/$(resource_name)
base_rules=$(base_resource_dir)/rules.mk

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

