## =================================================
## == Default kustomize makefile rules & helpers  ==
## =================================================

## Global: service name
APP_NAME ?= $(if $(SERVICE_NAME),$(SERVICE_NAME),unknown)

## scripts / binaries
kubectl ?= kubectl $(kubectl_args)
kustomize ?= kubectl kustomize $(kustomize_args)
kube_apply ?= kubectl $(kubectl_args) apply -f -
kustomize_args ?=
# kustomize_args += --load-restrictor=none
kubectl_args ?=

# Kustomize target options
kustomize-src ?= kustomization.yaml
kustomize-deps-all = $(LIB_COPY_FILES_DEPS_ALL) $(LIB_ASSET_ALL_DEPS)
kustomize-deps ?= $(kustomize-deps-all)

# copy kustomize descriptor to gen_dir
COPY_FILES += $(kustomize-src)

# Main kustomization rules
define LIB_KUSTOMIZE_RULES=
.PHONY: apply show update delete
show: $(kustomize-deps)
	$(kustomize) $(gen_dir)/
apply: $(kustomize-deps)
	$(kustomize) $(gen_dir)/ | $(kube_apply)
update:
	$$(MAKE) $(resource_dir) UPDATE=1 apply
delete:
	@read -p "Are you sure you want to delete $(APP_NAME)? [yN] " -n 1 -r; \
		echo; [ $$$$REPLY = "y" ]
	$(kubectl) delete -k $(gen_dir)/ | $(kube_apply)
clean:
	rm -rf "$(gen_dir)"

endef

ALL_RULES += $(nl)$(LIB_KUSTOMIZE_RULES)
