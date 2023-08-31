## =================================================
## == Utility makefile macros                     ==
## =================================================

# check variable if defined & not empty
check-var = $(if $(strip $($1)),,$(error "$1" is not defined))
# blank + new line values
blank :=
define nl
$(blank)
$(blank)
endef

# removes duplicates from a variable (without sorting)
uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))

# normalizes directory paths (removes trailing slash)
normalize-dir-paths = $(patsubst %/,%,$(1))

# normalizes a list of paths $(2) relative to a list of prefixes $(1)
# note: due to recursion, prefixes are traversed in reverse order of priority! 
normalize-rel-paths = $(if $1,$(call normalize-rel-paths,$(filter-out $(firstword $1),$1),\
		$(patsubst $(firstword $1)/%,%,$2)),$2)

