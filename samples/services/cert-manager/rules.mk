# Local cert-manager service customizations
include $(base_rules)

# used by the secrets target
NAMESPACE = cert-manager
# example cloudflare issuer + certificate
COPY_FILES += example-issuer.yaml example-cert.yaml

# Rule for creating secrets (e.g., API keys)
define cert_secrets_rules=
secrets:
	"$(scripts_dir)/prompt-secret.sh" example-cloudflare-api \
		--namespace "$(NAMESPACE)" -p key
endef

ALL_RULES += $(cert_secrets_rules)

