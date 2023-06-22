# Default rules & helpers for kustomize

UPDATE ?=

define kustomize_rules=
.PHONY: apply show update
show: $(asset_fetch_reqs)
	$(kustomize) $(resource_dir)/

apply: $(asset_fetch_reqs)
	$(kustomize) $(resource_dir)/ | $(kube_apply)

update:
	$$(MAKE) $(resource_dir) UPDATE=1 apply

clean:
	rm -rf "$(gen_dir)"

endef

