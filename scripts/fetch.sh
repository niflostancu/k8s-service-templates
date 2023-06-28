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
#  - hub.docker.com: for docker tags (specify jq filtering using # in URL);
#

set -e
BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &>/dev/null && pwd -P )

# Use for debugging shell calls from make
# echo "CALL: $*" >&2
_fatal() { echo "$@" >&2; exit 2; }

VERSION=
VERSION_FILE=
GET_URL=
GET_HASH=
DOWNLOAD=
while [[ $# -gt 0 ]]; do
	case "$1" in
		--latest) VERSION=__latest ;;
		--version=*) VERSION="${1#*=}" ;;
		--version-file=*) VERSION_FILE="${1#*=}" ;;
		--get-hash) GET_HASH=1 ;;
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
	["hub.docker.com"]="docker_hub"
)

# Parses an URL fragment and returns each pair on a newline
# (easy to iterate using `read -r line`)
# Accepted format: #key1=value;key2=value...
function parse_url_fragment() {
	local pair= PAIRS=()
	if [[ "$1" =~ ^[^#]*#(.+)$ ]]; then
		IFS=';' read -ra PAIRS <<< "${BASH_REMATCH[1]}"
		for pair in "${PAIRS[@]}"; do
			echo "$pair"
		done
	fi || true
}

# Parses a github URL
# Accepted formats:
# - https://github.com/{namespace}/{repository}/releases/download/{VERSION}/...
function service:github:parse_url() {
	if [[ "$1" =~ ^https?://[^/]+/([^/]+/[^/]+)(/?.+) ]]; then
		_REPONAME="${BASH_REMATCH[1]}"
		_URL_REST="${BASH_REMATCH[2]#/}"
	else
		_fatal "Unable to parse URL: $1"
	fi
}
function service:github:get_version() {
	local API_URL="https://api.github.com/repos/$_REPONAME/releases" 
	local HASH= PREFIX= SUFFIX= line=
	if [[ "$1" == "--hash" ]]; then
		HASH=1; shift
	fi
	while IFS= read -r line; do
		case $line in
			prefix=*|pfx=*) PREFIX=${line#*=}; ;;
			suffix=*|sfx=*) SUFFIX=${line#*=}; ;;
		esac
	done < <( parse_url_fragment "$1" )
	local JQ_FILTERS="map(select(.prerelease==false)) | [.[].tag_name]"
	[[ -z "$PREFIX" ]] || \
		JQ_FILTERS+=" | map(select(tostring|startswith(\"$PREFIX\")))"
	[[ -z "$SUFFIX" ]] || \
		JQ_FILTERS+=" | map(select(tostring|endswith(\"$SUFFIX\")))"
	JQ_FILTERS+=" | first"
	# echo "JQ FILTERS: $JQ_FILTERS">&2
	local TAG=$(curl --fail --show-error --silent "$API_URL" | jq -r "$JQ_FILTERS")
	if [[ -n "$HASH" ]]; then
		# fetch commit SHA from the GH API
		API_URL="https://api.github.com/repos/$_REPONAME/git/ref/tags/$TAG" 
		curl --fail --show-error --silent "$API_URL" | jq -r ".object.sha"
	else
		echo -n "$TAG"
	fi
}
function service:github:get_download_url() {
	echo -n "${1/{VERSION\}/$_VERSION}"
}

# Github Raw download URL parser
# Accepted formats:
# - https://raw.githubusercontent.com/{namespace}/{repository}/{VERSION}/...
function service:github_raw:parse_url() { service:github:parse_url "$@"; }
function service:github_raw:get_version() { service:github:get_version "$@"; }
function service:github_raw:get_download_url() { service:github:get_download_url "$@"; }

# Docker Hub latest tag query (via API v2)
# Accepted formats:
# - https://hub.docker.com/_/{repository}/#filter={VERSION}
# - https://hub.docker.com/(r|repository/docker)/{namespace}/{repository}/#filter={VERSION}
function service:docker_hub:parse_url() {
	if [[ "$1" =~ ^https?://[^/]+/_/([^/#]+)(/[^#]*)? ]]; then
		# official library
		_NAMESPACE=library
		_REPONAME="${BASH_REMATCH[1]}"
		_URL_REST="${BASH_REMATCH[2]#/}"
	elif [[ "$1" =~ ^https?://[^/]+/(r|repository/docker)/([^/]+)/([^#/]+)(/[^#]*)? ]]; then
		# named project
		_NAMESPACE="${BASH_REMATCH[2]}"
		_REPONAME="${BASH_REMATCH[3]}"
		_URL_REST="${BASH_REMATCH[4]#/}"
	else
		_fatal "Unable to parse URL: $1"
	fi
}
function service:docker_hub:get_version() {
	local API_URL="https://hub.docker.com/v2/namespaces/$_NAMESPACE/repositories/$_REPONAME/tags"
	API_URL+="?page_size=100"
	local HASH= PREFIX= SUFFIX= LONGEST= line=
	if [[ "$1" == "--hash" ]]; then
		HASH=1; shift
	fi
	while IFS= read -r line; do
		case "$line" in
			prefix=*|pfx=*) PREFIX=${line#*=}; ;;
			suffix=*|sfx=*) SUFFIX=${line#*=}; ;;
			longest|long) LONGEST=1; ;;
		esac
	done < <( parse_url_fragment "$1" )
	local JQ_FILTERS=".results | map(select(.name != \"latest\"))"
	[[ -z "$PREFIX" ]] || \
		JQ_FILTERS+=" | map(select(.name|tostring|startswith(\"$PREFIX\")))"
	[[ -z "$SUFFIX" ]] || \
		JQ_FILTERS+=" | map(select(.name|tostring|endswith(\"$SUFFIX\")))"
	# sort by date, desc + name length, asc
	local JQ_SORTBY=".last_updated"
	[[ -z "$LONGEST" ]] || JQ_SORTBY+=", (100-(.name|length))"
	JQ_FILTERS+=" | sort_by($JQ_SORTBY) | reverse | first"
	if [[ -n "$HASH" ]]; then
		# remove hash prefix from the digest value (e.g., 'sha256:...')
		JQ_FILTERS+=" | .digest | sub(\".*:\"; \"\")"
	else
		JQ_FILTERS+=" | .name"
	fi
	# echo "JQ FILTERS: $JQ_FILTERS">&2
	curl --fail --show-error --silent "$API_URL" | jq -r "$JQ_FILTERS"
}
function service:docker_hub:get_download_url() {
	_fatal "Docker Hub download not supported!"
}


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
_GET_VERSION_ARGS=()
if [[ -z "$_VERSION" && -n "$VERSION_FILE" && -f "$VERSION_FILE" ]]; then
	_VERSION="$(cat "$VERSION_FILE" | head -1)"
fi
if [[ -z "$_VERSION" || "$_VERSION" == "__latest" ]]; then
	[[ -z "$GET_HASH" ]] || _GET_VERSION_ARGS=(--hash)
	_VERSION=$(service:$SERVICE:get_version "${_GET_VERSION_ARGS[@]}" "$URL")
	[[ -n "$_VERSION" ]] || _fatal "Could not determine a version for '$_NAME'" >&2
fi

if [[ "$GET_URL" == "1" ]]; then
	DOWNLOAD_URL="$(service:$SERVICE:get_download_url "$URL")"
	echo "$DOWNLOAD_URL"
else
	echo "$_VERSION"
fi

if [[ "$DOWNLOAD" == "1" ]]; then
	DOWNLOAD_URL="$(service:$SERVICE:get_download_url "$URL")"
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

