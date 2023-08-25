## =================================================
## == File copying rules / helpers                ==
## =================================================

# Files to copy to the generated/ dir
COPY_FILES ?=

# Copies _file from a resource's src dir to gen_dir
define copy_file_rule=
$(_file:%=$(gen_dir)/%): $(_file)
	@mkdir -p "$$(dir $$(abspath $$@))"
	cp -f "$$<" "$$@"
endef

# Rule to copy ALL declared files
define LIB_COPY_FILES_RULES_ALL=
$(foreach _file,$(COPY_FILES),$(nl)$(copy_file_rule))
endef

# Dependencies all copied files
LIB_COPY_FILES_DEPS_ALL ?= $(COPY_FILES:%=$(gen_dir)/%)

ALL_RULES += $(nl)$(LIB_COPY_FILES_RULES_ALL)$(nl)

