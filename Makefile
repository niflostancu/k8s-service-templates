## ==============================================
## == Main Makefile script                     ==
## ==============================================
## Entry point for all build targets / scripts.
## Must be included by all deriving projects (a simple include will suffice ;).
##

# auto-detect base path
_base_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# include the init script which sets up the scripts / macros library
include $(_base_dir)scripts/init.mk

# Parse the MAKECMDGOALS: we need to extract the path to the target
# service (resource) to be built:
resource_dir := $(patsubst %/,%,$(word 1,$(MAKECMDGOALS)))
MAKECMDGOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ifeq ($(strip $(resource_dir)),)
$(error Invalid resource: '$(resource_dir)' (please specify it as first argument))
endif

# generate a default target with the resource name
.PHONY: $(resource_dir) $(resource_dir)/
ifeq ($(MAKECMDGOALS),)
$(resource_dir): _
else
$(resource_dir):
	@true
endif

# include the service-specific rules
include $(resource_dir)/rules.mk

# finally, evaluate all rules and let make do its job!
$(eval $(ALL_RULES))

