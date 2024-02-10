#!/bin/bash
# Nextcloud maintenance CLI
set -e

args="-i"
cli_args=
#args="--dry-run -o yaml"

if [ -t 1 ] && [ -t 0 ]; then
    args+=' --tty'
fi

shell_cmd="su www-data -s /usr/bin/bash $cli_args"

# find the name of the pod
POD=$(kubectl get pod -l app.kubernetes.io/name=nextcloud -o jsonpath="{.items[0].metadata.name}")
if [[ -z "$POD" ]]; then
    echo "Could not find a pod for 'nextcloud' app!" >&2; exit 1
fi
kubectl exec $args "$POD" -- sh -c "$shell_cmd"

