# Makefile rules for 'ingress-nginx'

APP_NAME = ingress-nginx
# E.g.: override asset version
#VERSION = v1.8.0

KUSTOMIZE_ARGS ?=
APPLY_ARGS ?=

# configure the asset fetcher
FETCH_ASSETS = ingress-nginx

ingress-nginx = $(tmp_dir)/ingress-nginx.yaml
ingress-nginx-url = https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-{VERSION}/deploy/static/provider/cloud/deploy.yaml
#ingress-nginx-ver = v1.8.0

