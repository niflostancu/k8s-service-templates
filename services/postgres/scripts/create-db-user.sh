#!/bin/bash
# Usage: create-db-user.sh [OPTIONS] USERNAME [DATABASE]
set -e
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

USERNAME=
NAMESPACE=default
DRY_RUN=
ALTER_USER=
FROM_SECRET=
FROM_SECRET_FIELD=password
PASSWORD=
GRANT_DATABASES=()

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
		--namespace|-n)
			NAMESPACE="$2"
			shift ;;
		--dry-run)
			DRY_RUN=1
			;;
		--alter|-e)
			ALTER_USER=1
			;;
		--password|-p)
			PASSWORD="$2"
			shift ;;
		--from-secret|-s)
			FROM_SECRET="$2"
			shift ;;
		--secret-field|-f)
			FROM_SECRET_FIELD="$2"
			shift ;;
		--grant-db|-d)
			GRANT_DATABASES+=("$2")
			shift ;;
		-*)
			echo "Invalid argument: $1" >&2
			exit 1 ;;
		*)
			[[ -z "$USERNAME" ]] || { echo "Invalid argument: $1" >&2; exit 1; }
			USERNAME="$1"
			;;
	esac; shift
done

if [[ -z "$USERNAME" ]]; then
	echo "Fatal: no username given as argument!" >&2
	exit 1
fi

if [[ -n "$FROM_SECRET" ]]; then
	PASSWORD=$(kubectl get secret -n "$NAMESPACE" "$FROM_SECRET" \
		--template="{{ index .data \"$FROM_SECRET_FIELD\" }}" | base64 --decode)
fi
if [[ -z "$PASSWORD" ]]; then
	PASSWORD=$(read -s -p "Enter password for '$USERNAME': " p; echo -n "$p")
fi

if [[ -z "$ALTER_USER" ]]; then
	QUERY="CREATE USER \"$USERNAME\" WITH PASSWORD '$PASSWORD';"$'\n'
else
	QUERY="ALTER USER \"$USERNAME\" WITH PASSWORD '$PASSWORD';"$'\n'
fi
QUERY+="\du+"$'\n'
for db in "${GRANT_DATABASES[@]}"; do
	QUERY+="GRANT ALL PRIVILEGES ON DATABASE \"$db\" TO \"$USERNAME\";"$'\n'
	QUERY+="\c $db"$'\n'
	QUERY+="CREATE SCHEMA IF NOT EXISTS public;"$'\n'
	QUERY+="GRANT ALL ON SCHEMA public TO \"$USERNAME\";"$'\n'
	QUERY+="\dn+"$'\n'
done

if [[ -n "$DRY_RUN" ]]; then
	echo "$QUERY"
else
	echo "$QUERY" | "$SDIR"/client.sh
fi

