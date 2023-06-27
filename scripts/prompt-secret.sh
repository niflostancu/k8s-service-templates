#!/bin/bash
# Creates a k8s secret with user prompt

# Name of the secret resource
NAME="$1"
# The secret field name
FIELDNAME="$2"
# Namespace to create secret in
NAMESPACE=${3:-default}

kubectl create secret generic "$NAME" --namespace "$NAMESPACE" \
	--from-file="$FIELDNAME"=<(read -s -p "Enter secret for '$NAME.$FIELDNAME': " p; echo -n "$p")

