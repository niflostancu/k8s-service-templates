#!/bin/bash
# Simple psql client utility using kubectl exec
set -e

RUN_SHELL=
if [[ "$1" == "--shell" ]]; then
    RUN_SHELL=1
fi

args="-i"
psql_args=
#args="--dry-run -o yaml"

if [ -t 1 ] && [ -t 0 ]; then
    args+=' --tty'
else
    psql_args+=' -f-'
fi

if [[ -n "$RUN_SHELL" ]]; then
    shell_cmd="/bin/bash"
else
    shell_cmd="export PGPASSWORD=\$POSTGRES_PASSWORD; psql $psql_args -h postgres -U\$POSTGRES_USER"
fi

# find the name of the pod

POD=$(kubectl get pod -l app.kubernetes.io/name=postgres -o jsonpath="{.items[0].metadata.name}")
if [[ -z "$POD" ]]; then
    echo "Could not find a pod for 'postgres' app!" >&2; exit 1
fi
kubectl exec $args "$POD" -- sh -c "$shell_cmd"

