## ==============================================
## == Initial / common Makefile macros         ==
## ==============================================

## Several important internal vars (mostly paths)
_last_mkfile = $(lastword $(MAKEFILE_LIST))
scripts_dir := $(patsubst %/,%,$(dir $(_last_mkfile)))
base_dir := $(patsubst %/,%,$(dir $(scripts_dir)))
parent_dir := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
resource_name = $(resource_dir)
gen_dir = $(resource_dir)/generated
base_resource_dir=$(base_dir)/$(resource_name)
base_rules=$(base_resource_dir)/rules.mk
# use VPATH for finding source files in inheritance order
VPATH = $(abspath $(resource_dir)) $(base_resource_dir)
# dynamically compose + evaluate makefile rules:
ALL_RULES?=\# BEGIN ALL_RULES
# disable built-in rules + suffixes
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

## === Utility Makefile macros ===
# check variable if defined & not empty
check-var = $(if $(strip $($1)),,$(error "$1" is not defined))
# blank + new line values
blank :=
define nl
$(blank)
$(blank)
endef

## === Load user config overrides ===
-include $(parent_dir)/config.local.mk

## === Default rules ===
# first rule => show
_: show
.FORCE:
.PHONY: _ .FORCE

# debug helpers
.PHONY: @debug @debug-make @debug-rules
@debug: @debug-rules
@debug-rules:
	$(info base_dir = $(base_dir))
	$(info gen_dir = $(gen_dir))
	$(info $(ALL_RULES))
	@echo 
@debug-make: @debug-rules
	@$(MAKE) -r -p $(filter-out @debug,$(resource_dir))

## === Include the whole build scripts library ===
include $(scripts_dir)/lib/asset.mk
include $(scripts_dir)/lib/copy.mk
include $(scripts_dir)/lib/asset-version.mk
include $(scripts_dir)/lib/asset-download.mk
# include $(scripts_dir)/lib/docker-build.mk
include $(scripts_dir)/lib/kustomize.mk
include $(scripts_dir)/lib/kustomize-snippets.mk

