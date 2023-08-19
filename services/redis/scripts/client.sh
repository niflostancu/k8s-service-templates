#!/bin/bash
# Simple redis client utility using kubectl exec
set -e

args="-i"
redis_args=
#args="--dry-run -o yaml"

if [ -t 1 ] && [ -t 0 ]; then
    args+=' --tty'
else
    redis_args+=''
fi

shell_cmd="redis-cli $redis_args"

# find the name of the pod
POD=$(kubectl get pod -l app.kubernetes.io/name=redis -o jsonpath="{.items[0].metadata.name}")
if [[ -z "$POD" ]]; then
    echo "Could not find a pod for 'redis' app!" >&2; exit 1
fi
kubectl exec $args "$POD" -- sh -c "$shell_cmd"

