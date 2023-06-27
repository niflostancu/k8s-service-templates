# Makefile entry point for all k8s resources
_base_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(_base_dir)scripts/common.mk

# parse the MAKECMDGOALS
resource_dir := $(patsubst %/,%,$(word 1,$(MAKECMDGOALS)))
MAKECMDGOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

ifeq ($(strip $(resource_dir)),)
$(error Invalid resource: '$(resource_dir)' (please specify it as first argument))
endif

# default target
.PHONY: $(resource_dir) $(resource_dir)/
ifeq ($(MAKECMDGOALS),)
$(resource_dir): _
else
$(resource_dir):
	@true
endif

include $(resource_dir)/rules.mk

# finally, evaluate the rules
$(eval $(ALL_RULES))

