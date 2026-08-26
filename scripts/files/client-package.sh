#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../dev/website-common.sh"

usage() { echo "Usage: client-package <project> [--output <zip>] [--dry-run] [--yes]"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
project="$(website_resolve_project "$1")"; shift
name="$(basename "$project")"
output="$PWD/${name// /-}-delivery-$(date +%Y%m%d).zip"
dry_run=false assume_yes=false
while (($#)); do
  case $1 in
    --output) output="${2:-}"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    --yes) assume_yes=true; shift ;;
    *) log_error "Unknown option: $1"; exit 2 ;;
  esac
done
output="$(realpath -m "$output")"

echo "Project: $project"
echo "Output: $output"
echo "Excluded: .git, node_modules, build caches, logs, .env files and local editor files"
if bash "$(dirname "${BASH_SOURCE[0]}")/../security/secret-check.sh" "$project" >/dev/null 2>&1; then
  echo "Secret scan: clear"
else
  log_warn "Secret scan found possible credentials. They are excluded only when stored in .env files."
  bash "$(dirname "${BASH_SOURCE[0]}")/../security/secret-check.sh" "$project" || true
  [[ $assume_yes == true ]] || ask_confirm "Continue packaging after reviewing secret-check output?" || exit 1
fi
[[ $dry_run == true ]] && exit 0
[[ $assume_yes == true ]] || ask_confirm "Create the client delivery ZIP?" || exit 0
require_tool zip zip || exit 1
mkdir -p "$(dirname "$output")"
(cd "$(dirname "$project")" && zip -qr "$output" "$name" \
  -x "$name/.git/*" "$name/node_modules/*" "$name/.next/*" "$name/dist/*" "$name/build/*" \
     "$name/.cache/*" "$name/.env" "$name/.env.local" "$name/.env.*.local" "$name/*.log" "$name/.DS_Store" \
     "$name/.vscode/*" "$name/.idea/*")
log_success "Client package created: $output"
