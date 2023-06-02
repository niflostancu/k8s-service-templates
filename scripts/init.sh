#!/bin/bash
# use as 'source scripts/init.sh'

export KUBECONFIG="$(make -s get_kube_config)"

