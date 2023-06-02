# Makefile entry point for all k8s resources

include scripts/common.mk

# parse the MAKECMDGOALS
resource_dir := $(patsubst %/,%,$(word 1,$(MAKECMDGOALS)))
MAKECMDGOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

include $(resource_dir)/rules.mk

# eval the rules!
$(eval $(all_rules))

