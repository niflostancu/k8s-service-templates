# Default rules for kustomize & asset generation

define default_kustomize_rules=
.PHONY: apply show update
apply: $$(get_assets_reqs)
	$(kustomize) $(resource_dir)/ | $(kube_apply)
show: $$(get_assets_reqs)
	$(kustomize) $(resource_dir)/
update: VERSION = --latest
update: apply

endef

_cur_asset_target=$($(asset))
_cur_asset_url=$($(asset)-url)
_cur_asset_ver=$($(asset)-ver)

define default_asset_rule=
$(_cur_asset_target): URL=$(_cur_asset_url)
$(if $(_cur_asset_ver),$(_asset_rule_ver_override))
$(_cur_asset_target):
	$$(download_asset)

endef

define _asset_rule_ver_override=
$(_cur_asset_target): VERSION=$(_cur_asset_ver)

endef

default_asset_rules=$(foreach asset,$(ASSETS),$(default_asset_rule))

