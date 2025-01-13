# Makefile rules for 'ingress-nginx'
APP_NAME = ingress-nginx
# E.g.: override asset version
#VERSION = v1.8.0

COPY_FILES += patch-jobs.json patch-configmap.yaml

# configure the asset fetcher
BUILD_ASSETS += ingress-nginx

ingress-nginx = $(gen_dir)/ingress-nginx.yaml
ingress-nginx-type = download
ingress-nginx-url = https://raw.githubusercontent.com/kubernetes/ingress-nginx/{VERSION}/deploy/static/provider/cloud/deploy.yaml\#prefix=controller-
#ingress-nginx-ver = v1.8.0

