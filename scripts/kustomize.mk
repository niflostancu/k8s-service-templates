# Default rules & helpers for kustomize

UPDATE ?=

kustomize-src ?= kustomization.yaml

# Files to copy to the generated/ dir
COPY_FILES ?= $(kustomize-src)

_kustomize_copied ?= $(COPY_FILES:%=$(gen_dir)/%)
_kustomize_reqs ?= $(asset_fetch_reqs) $(_kustomize_copied)

define kustomize_rules=
.PHONY: apply show update
show: $(_kustomize_reqs)
	$(kustomize) $(gen_dir)/
apply: $(_kustomize_reqs)
	$(kustomize) $(gen_dir)/ | $(kube_apply)
update:
	$$(MAKE) $(resource_dir) UPDATE=1 apply
clean:
	rm -rf "$(gen_dir)"
# copy everything inside the generated directory
$(foreach _file,$(COPY_FILES),$(kustomize_copy_rule))

endef

define kustomize_copy_rule=
$(_file:%=$(gen_dir)/%): $(_file)
	@mkdir -p "$$(dir $$(abspath $$@))"
	cp -f "$$<" "$$@"

endef

ALL_RULES += $(kustomize_rules)
