# cert-manager helper makefile

APP_NAME = ingress-nginx
ASSETS = main

KUSTOMIZE_ARGS ?=
APPLY_ARGS ?=

# used assets
URL_main = https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-{VERSION}/deploy/static/provider/cloud/deploy.yaml
ASSET_main = ingress-nginx-deploy.yaml
VERSION_main ?=

