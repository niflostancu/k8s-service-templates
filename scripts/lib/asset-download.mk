## ================================================
## == Asset fetcher / downloader implementation  ==
## ================================================

# asset downloader specific options:
asset-download-def-args ?= $(asset-fetch-def-args)
asset-download-dest ?= $(if $($(asset)-dest),$($(asset)-dest),$($(asset)))
asset-download-args = $(if $($(asset)-args),$($(asset)-args),$(asset-download-def-args))

# fetch.sh --download script invocation
asset_fetch_download = $(ASSET_FETCH_SCRIPT) $(1) --download "$(asset-url)"
# asset-file with version info between base name and extension
_asset_download_versioned = $(basename $(asset-download-dest))-$(version)$(suffix $(asset-download-dest))

define _lib_asset_download_rules=
# download asset rules:
$(lib_asset_common_head) \
	$(strip $(lib_asset_version_checks) $(call check-asset-var,asset-download-dest) \
	$(call check-asset-var,asset-download-args))

# target is a symlink to the versioned file
# asset-target: $(asset-target) \
$(call asset-assign-vars,$(asset-target))
$(asset-target): $(asset-deps) $(_asset_download_versioned) $(asset-version-meta-file)
	ln -sf "$$$$(basename "$$<")" "$$@"
# download using versioned filename \
$(call asset-assign-vars,$(_asset_download_versioned))
$(_asset_download_versioned): $(asset-version-meta-file)
	$(call asset_fetch_download,$(asset-download-args)) "$$@"
	touch "$$@"

$(lib_asset_version_target)
$(nl)$(lib_asset_common_tail)
endef

# cache the fetched version value
_lib_asset_download_rules_cached=$(let version,$(asset-version-read-val),$(_lib_asset_download_rules))

# register the asset type
LIB_ASSET[download]_DEPS=$(asset-target)
LIB_ASSET[download]_RULES=$(_lib_asset_download_rules_cached)

