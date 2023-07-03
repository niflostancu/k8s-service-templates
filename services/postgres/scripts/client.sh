#!/bin/bash
# Simple psql client utility using kubectl exect
set -e

args="-i"
psql_args=
#args="--dry-run -o yaml"

if [ -t 1 ] && [ -t 0 ]; then
    args+=' --tty'
else
    psql_args+=' -f-'
fi

shell_cmd="export PGPASSWORD=\$POSTGRES_PASSWORD; psql $psql_args -h postgres -U\$POSTGRES_USER"

# find the name of the pod

POD=$(kubectl get pod -l app.kubernetes.io/name=postgres -o jsonpath="{.items[0].metadata.name}")
if [[ -z "$POD" ]]; then
    echo "Could not find a pod for 'postgres' app!" >&2; exit 1
fi
kubectl exec $args "$POD" -- sh -c "$shell_cmd"

