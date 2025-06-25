#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man files copy-files
  exit 0
fi

dry_run=false
if [[ ${1:-} == "--dry-run" ]]; then
  dry_run=true
  shift
fi

usage() {
  echo "copy-files - copy files safely";
  echo "Usage: copy-files [--dry-run] <source> <destination>";
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

src=$1
dest=$2

if [[ ! -d $src ]]; then
  echo "❌ Source directory not found" >&2
  exit 1
fi

mkdir -p "$dest"

echo "🔍 Files to copy:" 
find "$src" -maxdepth 1 -type f -printf '%f\n' | while read -r f; do
  echo " $f"
done

read -rp "Proceed with copy? (y/N) " confirm
if [[ $confirm != [yY] ]]; then
  echo "Aborted." && exit 0
fi

if $dry_run; then
  log_info "Dry run enabled. No files copied."
else
  for f in "$src"/*; do
    [[ -f $f ]] || continue
    cp -i "$f" "$dest/" && log_info "$(basename "$f") copied"
  done
  log_info "Copy complete"
fi

