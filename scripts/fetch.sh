#!/bin/bash
# Retrieves the requested version of an application release (via URL)
# Supports latest version retrieval and caching. 
#
# Syntax: fetch.sh [OPTIONS] URL DEST_NAME
# The URL may contain a special '{VERSION}' placeholder in some of its
# components; each service has a specific set of supported version types.
#
# You can use it for the following services:
#  - github.com: released assets (tagged versions);
#  - raw.githubusercontent.com resources (version placeholders in tags);
#  - hub.docker.com: for docker tags (TODO);
#

set -e
BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &>/dev/null && pwd -P )

_fatal() { echo "$@" >&2; exit 2; }

VERSION=
VERSION_FILE=
GET_URL=
DOWNLOAD=
while [[ $# -gt 0 ]]; do
	case "$1" in
		--latest) VERSION=__latest ;;
		--version=*) VERSION="${1#*=}" ;;
		--version-file=*) VERSION_FILE="${1#*=}" ;;
		--get-url) GET_URL=1 ;;
		--download) DOWNLOAD=1 ;;
		-*) _fatal "Invalid argument: $1" ;;
		*) break ;;
	esac
	shift
done

declare -A SERVICES=(
	["github.com"]="github"
	["raw.githubusercontent.com"]="github_raw"
)

# Github routines
function service:github:parse_url() {
	local regexp="^https?://[^/]+/([^/]+/[^/]+)(/?.+)"
	if [[ "$1" =~ $regexp ]]; then
		_REPONAME="${BASH_REMATCH[1]}"
		_URL_REST="${BASH_REMATCH[2]#/}"
		if [[ "$_URL_REST" =~ /releases/download/([^/]+)/? ]]; then
			_VER_PREFIX=${BASH_REMATCH[1]/{VERSION\}/}
		fi
	else
		_fatal "Unable to parse URL: $1"
	fi
}
function service:github:get_version() {
	local JQ_MAP="select(.prerelease==false)"
	local JQ_FILTER=""
	if [[ -n "$_VER_PREFIX" ]]; then
		JQ_MAP+=" | select(.tag_name|startswith(\"$_VER_PREFIX\"))"
		JQ_FILTER+=" | sub(\"^$_VER_PREFIX\"; \"\")"
	fi
	curl --fail --show-error --silent "https://api.github.com/repos/$_REPONAME/releases" \
		| jq -r 'map('"$JQ_MAP"') | first | .tag_name'"$JQ_FILTER"
}
function service:github:get_download_url() {
	echo -n "${1/{VERSION\}/$_VERSION}"
}

function service:github_raw:parse_url() {
	service:github:parse_url "$@"
	if [[ -n "$_URL_REST" ]]; then
		local COMMIT=${_URL_REST%%/*}
		if [[ "$COMMIT" == *"{VERSION}"* ]]; then
			_VER_PREFIX=${COMMIT/{VERSION\}/}
		fi
	fi
}
function service:github_raw:get_version() { service:github:get_version "$@"; }
function service:github_raw:get_download_url() { service:github:get_download_url "$@"; }

URL="$1"
FILENAME="$2"
SERVICE=$(echo "$URL" | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/')
if [[ ! -v SERVICES["$SERVICE"] ]]; then
	_fatal "Service $SERVICE not supported!" >&2
fi
SERVICE=${SERVICES["$SERVICE"]}

service:$SERVICE:parse_url "$URL"

# check if we need to retrieve the latest version
_VERSION="$VERSION"
if [[ -z "$_VERSION" && -n "$VERSION_FILE" && -f "$VERSION_FILE" ]]; then
	_VERSION="$(cat "$VERSION_FILE" | head -1)"
fi
if [[ -z "$_VERSION" || "$_VERSION" == "__latest" ]]; then
	_VERSION=$(service:$SERVICE:get_version "$URL")
	[[ -n "$_VERSION" ]] || _fatal "Could not determine a version for '$_NAME'" >&2
fi
DOWNLOAD_URL="$(service:$SERVICE:get_download_url "$URL")"
if [[ "$GET_URL" == "1" ]]; then
	echo "$DOWNLOAD_URL"
else
	echo "$_VERSION"
fi

if [[ "$DOWNLOAD" == "1" ]]; then
	mkdir -p "$(dirname "$FILENAME")"
	curl --fail --show-error --silent -L -o "$FILENAME" "$DOWNLOAD_URL"
	if [[ -n "$VERSION_FILE" ]]; then
		echo "$_VERSION" > "$VERSION_FILE"
	fi
	echo "$FILENAME"
else
	if [[ -n "$VERSION_FILE" ]]; then
		mkdir -p "$(dirname "$VERSION_FILE")"
		echo "$_VERSION" > "$VERSION_FILE"
	fi
fi

