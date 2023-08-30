## =================================================
## == Default kustomize makefile rules & helpers  ==
## =================================================

## Global: service name
APP_NAME ?= $(if $(SERVICE_NAME),$(SERVICE_NAME),unknown)

# kustomize properties
kustomize-src ?= kustomization.yaml
kustomize-dir ?= $(gen_dir)
kustomize-target ?= $(kustomize-dir)/kustomization.yaml
kustomize-deps ?= $(ALL_ASSET_DEPS)
kustomize-args ?=
# e.g., kustomize-args = --load-restrictor=none

## scripts / binaries
kubectl ?= kubectl
kustomize ?= kubectl kustomize
kube_apply ?= kubectl $(kubectl_args) apply -f -
kubectl_args ?=

# Main kustomization rules
define LIB_KUSTOMIZE_RULES=
# Kustomize rules
$(kustomize-target): $(kustomize-src)
	@mkdir -p "$$(dir $$(abspath $$@))"
	cp -f "$$<" "$$@"

.PHONY: show apply update delete clean
show: $(kustomize-target) $(kustomize-deps)
	$(kustomize) $(kustomize-args) $(kustomize-dir)/
apply: $(kustomize-target) $(kustomize-deps)
	$(kustomize) $(kustomize-args) $(kustomize-dir)/ | $(kube_apply)
update:
	$$(MAKE) $(resource_dir) UPDATE=1 apply
# removal rules:
delete:
	@read -p "Are you sure you want to delete $(APP_NAME)? [yN] " -n 1 -r; \
		echo; [ $$$$REPLY = "y" ]
	$(kubectl) $(kubectl_args) delete -k $(kustomize-dir)/ | $(kube_apply)
clean:
	rm -rf "$(gen_dir)"
endef

ALL_RULES += $(nl)$(LIB_KUSTOMIZE_RULES)
