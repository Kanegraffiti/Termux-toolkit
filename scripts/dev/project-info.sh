#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() {
  echo "Usage: project-info <folder-or-zip-or-name> [--root <directory>]"
}

[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
value=$1
shift
root=""
while (($#)); do
  case $1 in
    --root) root="${2:-}"; shift 2 ;;
    *) log_error "Unknown option: $1"; exit 2 ;;
  esac
done

project="$(website_resolve_project "$value" "$root")"
stack="$(website_stack "$project")"
manager="$(website_package_manager "$project")"

printf 'Project: %s\nStack: %s\nPackage manager: %s\n' "$project" "$stack" "$manager"
[[ -f "$project/package.json" ]] && echo "Manifest: package.json"
[[ -f "$project/index.html" ]] && echo "Entry point: index.html"
[[ -d "$project/node_modules" ]] && echo "Dependencies: installed" || {
  [[ $manager == none ]] || echo "Dependencies: not installed"
}
