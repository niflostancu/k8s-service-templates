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
fetch_script ?= "$(scripts_dir)/fetch.sh"

kustomize_args ?=
# kustomize_args += --load-restrictor=none
kubectl_args ?=

# asset-specific fetcher macros;
asset_url = $(or $(URL_$(A)),$(URL))
asset_ver = $(or $(VERSION_$(A)),$(VERSION))
asset_file = $(ASSET_$(A))
asset_fetch_version ?= $(shell $(fetch_script) --latest --print-version $(asset_url) $(asset_file))
asset_version_file ?= $(tmp_dir)/$(asset_file)-ver.txt
asset_dest ?= $(tmp_dir)/$(asset_file)
asset_fetch_args ?= $(strip $(asset_fetch_ver_arg))
asset_fetch_ver_arg ?= $(if $(findstring latest,$(asset_ver)),--latest,\
					   $(if $(asset_ver),--version=$(asset_ver),))
asset_fetch_cmd ?= $(fetch_script) $(asset_fetch_args) --download $(asset_url) $(asset_file)

# default assets
ASSETS ?= main

# first rule => apply
_: apply
.FORCE:
.PHONY: _ .FORCE

# per-asset rules
define asset_rules =
$(A)_fetch: $(asset_fetch_dest)
$(asset_fetch_dest):
	$(asset_fetch_cmd)
$(A)_fetch_latest: asset_fetch_ver_arg = --latest
$(A)_fetch_latest:
	$(asset_fetch_cmd)

$(A)_debug:
	@echo "asset_fetch_args = $(asset_fetch_args)"
	@echo "asset_fetch_dest = $(asset_fetch_dest)"
.PHONY: $(A)_fetch $(A)_fetch_latest $(A)_debug

endef

# global rules
define all_rules +=
fetch_all: $(foreach A,$(ASSETS),$(A)_fetch)
apply: $(foreach A,$(ASSETS),$(A)_fetch)
	$(kustomize) $(resource_dir)/ | $(kube_apply)
show: $(foreach A,$(ASSETS),$(A)_fetch)
	$(kustomize) $(KUSTOMIZE_ARGS) $(resource_dir)/
update: $(foreach A,$(ASSETS),$(A)_fetch_latest)
	$(kustomize) $(resource_dir)/ | $(kube_apply)

.PHONY: apply update show fetch_all

# expand enabled assets
$(foreach A,$(ASSETS),$(asset_rules))

endef

debug_mk:
	$(info $(DEBUG_MACRO))
	@echo "base_dir = $(base_dir)"
	@echo "tmp_dir = $(tmp_dir)"
define DEBUG_MACRO
cat <<-'EOF'
All Rules:
$(all_rules)
'EOF'

endef

# load user config
-include $(base_dir)/config.local.mk

