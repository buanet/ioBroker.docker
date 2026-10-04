#!/usr/bin/env bash
# Local build of buanet/ioBroker.docker using the upstream Debian context.
set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: ./build-local.sh [OPTIONS]

  --debian NAME       Debian release without '-slim' (default: trixie)
  --node MAJOR        Node.js major version (default: 24)
  --tag IMAGE:TAG     Image name (default: iobroker-local:DEBIAN-nodeMAJOR)
  --version TEXT      Image version metadata (default: local)
  --platform OS/ARCH  Optional target platform, e.g. linux/amd64
  --no-cache         Build without layer cache
  --pull             Pull a current base image before building
  --help             Show this help

Place this script in ioBroker.docker/localbuild/.
EOF
}

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
require_value() {
    [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail "Missing value for $1"
}

debian=trixie
node=24
tag=''
version=local
platform=''
build_options=()
while (( $# )); do
    case "$1" in
        --debian) require_value "$@"; debian=$2; shift 2 ;;
        --node) require_value "$@"; node=$2; shift 2 ;;
        --tag) require_value "$@"; tag=$2; shift 2 ;;
        --version) require_value "$@"; version=$2; shift 2 ;;
        --platform) require_value "$@"; platform=$2; shift 2 ;;
        --no-cache|--pull) build_options+=("$1"); shift ;;
        --help|-h) usage; exit 0 ;;
        *) fail "Unknown argument: $1 (see --help)" ;;
    esac
done

[[ "$debian" =~ ^[a-z0-9][a-z0-9.-]*$ && "$debian" != *-slim ]] || fail 'Invalid Debian release; use e.g. trixie or bookworm'
[[ "$node" =~ ^[1-9][0-9]*$ ]] || fail 'Node must be a major version, e.g. 22 or 24'
[[ "$version" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]] || fail 'Version may contain only letters, numbers, dots, underscores and hyphens'
if [[ -n "$platform" ]]; then
    [[ "$platform" =~ ^linux/[a-zA-Z0-9_-]+(/[a-zA-Z0-9_-]+)?$ ]] || fail 'Invalid platform; use e.g. linux/amd64 or linux/arm64'
    build_options+=(--platform "$platform")
fi
tag=${tag:-iobroker-local:${debian}-node${node}}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
repo_dir=$(cd -- "$script_dir/.." && pwd -P)
context="$repo_dir/debian"
source_dockerfile="$context/Dockerfile"
[[ -f "$source_dockerfile" ]] || fail "Missing $source_dockerfile. Place localbuild in the repository root."
command -v docker >/dev/null 2>&1 || fail 'Docker is not installed or not in PATH'
docker info >/dev/null 2>&1 || fail 'Docker daemon is unavailable or access is denied'

# Fail visibly if upstream has changed its template structure.
grep -Eq '^FROM[[:space:]]+debian:[^[:space:]]+' "$source_dockerfile" || fail 'Upstream Dockerfile has no supported Debian FROM line'
grep -Fq '${NODE}' "$source_dockerfile" || fail 'Upstream Dockerfile no longer contains the ${NODE} placeholder'

temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/iobroker-localbuild.XXXXXXXX")
cleanup() { rm -rf -- "$temp_dir"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
build=$(date -u +%Y%m%d%H%M%S)
dati=$(date -u +%Y-%m-%dT%H:%M:%SZ)

sed \
    -e "s|^FROM[[:space:]]\+debian:[^[:space:]]\+|FROM debian:${debian}-slim|" \
    -e "s|\${NODE}|${node}|g" \
    -e "s|\${VERSION}|${version}|g" \
    -e "s|\${BUILD}|${build}|g" \
    -e "s|\${DATI}|${dati}|g" \
    "$source_dockerfile" > "$temp_dir/Dockerfile"

printf 'Debian: %s-slim\nNode.js: %s\nImage: %s\nContext: %s\n' "$debian" "$node" "$tag" "$context"
docker build "${build_options[@]}" --file "$temp_dir/Dockerfile" --tag "$tag" "$context"
printf '\nBuild completed: %s\n' "$tag"
