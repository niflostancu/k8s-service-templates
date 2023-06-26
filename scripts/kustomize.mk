# Default rules & helpers for kustomize

UPDATE ?=

kustomization-src=kustomization.yaml
kustomization-file=$(gen_dir)/kustomization.yaml

kustomization_reqs?=
kustomization_reqs+=$(kustomization-file) $(asset_fetch_reqs)

define kustomize_rules=
.PHONY: apply show update
show: $(kustomization_reqs)
	$(kustomize) $(gen_dir)/
apply: $(kustomization_reqs)
	$(kustomize) $(gen_dir)/ | $(kube_apply)
update:
	$$(MAKE) $(resource_dir) UPDATE=1 apply
clean:
	rm -rf "$(gen_dir)"

# Copy everything inside the generated directory
$(kustomization-file): $(kustomization-src)
	cp -f "$$<" "$$@"

endef

