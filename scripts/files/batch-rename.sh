#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man files batch-rename
  exit 0
fi

dry_run=false
if [[ ${1:-} == "--dry-run" ]]; then
  dry_run=true
  shift
fi

usage() {
  echo "batch-rename - rename files in bulk";
  echo "Usage: batch-rename [--dry-run] [directory]";
}

dir="${1:-.}"

if [[ ! -d $dir ]]; then
  echo "❌ Directory not found" >&2
  exit 1
fi

if ! command -v rename >/dev/null 2>&1; then
  echo "❌ 'rename' not installed" >&2
  read -rp "Install via pkg-toolkit.sh? (y/N) " ans
  if [[ $ans == [yY] ]]; then
    "$HOME/.termux-toolkit/tools/pkg-toolkit.sh" require rename || true
  fi
  exit 1
fi

read -rp "Prefix to add (empty for none): " prefix
read -rp "Suffix to add (empty for none): " suffix
read -rp "Lowercase names? (y/N) " lower

echo "🔍 Preview:" 
for f in "$dir"/*; do
  [[ -f $f ]] || continue
  base=$(basename "$f")
  new="$prefix${base}$suffix"
  if [[ $lower == [yY] ]]; then
    new=$(echo "$new" | tr '[:upper:]' '[:lower:]')
  fi
  [[ $base != $new ]] && echo " $base -> $new"
done

read -rp "Proceed with rename? (y/N) " confirm
if [[ $confirm != [yY] ]]; then
  echo "Aborted." && exit 0
fi

if $dry_run; then
  log_info "Dry run enabled. No files renamed."
else
  for f in "$dir"/*; do
    [[ -f $f ]] || continue
    base=$(basename "$f")
    new="$prefix${base}$suffix"
    if [[ $lower == [yY] ]]; then
      new=$(echo "$new" | tr '[:upper:]' '[:lower:]')
    fi
    [[ $base == $new ]] && continue
    mv -n "$f" "$dir/$new"
    log_info "$base -> $new"
  done
  log_info "Rename complete"
fi

