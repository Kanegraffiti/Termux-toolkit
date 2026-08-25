#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() { echo "Usage: site-build-check <project> [--dry-run] [--yes]"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
project="$(website_resolve_project "$1")"; shift
dry_run=false assume_yes=false
while (($#)); do
  case $1 in --dry-run) dry_run=true ;; --yes) assume_yes=true ;; *) log_error "Unknown option: $1"; exit 2 ;; esac
  shift
done
manager="$(website_package_manager "$project")"
[[ $manager != none ]] || { log_error "No JavaScript package manifest was detected."; exit 1; }
website_has_script "$project" build || { log_error "package.json has no build script."; exit 1; }
command=("$manager" run build)
printf 'Project: %s\nCommand:' "$project"; printf ' %q' "${command[@]}"; echo
[[ $dry_run == true ]] && exit 0
if [[ ! -d "$project/node_modules" ]]; then
  [[ $assume_yes == true ]] || ask_confirm "Dependencies are missing. Run '$manager install'?" || exit 1
  (cd "$project" && "$manager" install)
fi
[[ $assume_yes == true ]] || ask_confirm "Run the project's production build code now?" || exit 0
log="$HOME/.termux-toolkit/logs/site-build-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$(dirname "$log")"
if (cd "$project" && "${command[@]}") 2>&1 | tee "$log"; then
  log_success "Production build passed. Log: $log"
else
  log_error "Production build failed. Log: $log"
  exit 1
fi
