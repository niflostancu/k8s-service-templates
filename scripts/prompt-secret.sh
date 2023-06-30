#!/bin/bash
# Creates a k8s secret with customizable user prompt & multiple fields

NAME=
NAMESPACE=default
KUBECTL_ARGS=()
KUBECTL_FELDS=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
		--namespace|-n)
			NAMESPACE="$2"; shift;
			;;
		--dry-run)
			KUBECTL_ARGS+=(--dry-run=client -o yaml)
			;;
		--ask-field|-f)
			_FIELD="$2"
			_DEFAULT=
			_PROMPT_STR=
			if [[ "$_FIELD" =~ ^(.+)=(.+) ]]; then
				_FIELD="${BASH_REMATCH[1]}"
				_DEFAULT="${BASH_REMATCH[2]}"
				_PROMPT_STR+=" [$_DEFAULT]"
			fi
			_SECRET=$(read -i "$_DEFAULT" -p "Enter value for '$_FIELD'$_PROMPT_STR: " p; echo -n "$p")
			[[ -n "$_SECRET" ]] || _SECRET=$_DEFAULT
			KUBECTL_FELDS+="$_FIELD=$_SECRET"$'\n'
			shift ;;
		--ask-password|-p)
			_FIELD="$2"
			_SECRET=$(read -s -p "Enter secret for '$_FIELD': " p; echo -n "$p")
			KUBECTL_FELDS+="$_FIELD=$_SECRET"$'\n'
			shift ;;
		-*)
			echo "Invalid argument: $1" >&2; exit 1
			;;
		*)
			[[ -z "$NAME" ]] || { echo "Invalid argument: $1" >&2; exit 1; }
			NAME="$1"
			;;
	esac; shift
done

if [[ -z "$NAME" ]]; then
	echo "Fatal: no name given as argument!" >&2
	exit 1
fi

kubectl create secret generic "${KUBECTL_ARGS[@]}" "$NAME" --namespace="$NAMESPACE" \
	--from-env-file=<(echo "$KUBECTL_FELDS")

