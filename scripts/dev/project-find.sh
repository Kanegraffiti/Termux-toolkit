#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() {
  echo "Usage: project-find <name> [--root <directory>]"
}

[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
query=$1
shift
root=""
while (($#)); do
  case $1 in
    --root) root="${2:-}"; shift 2 ;;
    *) log_error "Unknown option: $1"; exit 2 ;;
  esac
done

website_find "$query" "$root" | awk '!seen[$0]++'
