#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"

LOG_DIR="$HOME/.termux-toolkit/logs"
LOG_FILE="$LOG_DIR/move-files.log"
mkdir -p "$LOG_DIR"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man files move-files
  exit 0
fi

dry_run=false
if [[ ${1:-} == "--dry-run" ]]; then
  dry_run=true
  shift
fi

usage() {
  echo "move-files - move files with preview";
  echo "Usage: move-files [--dry-run] <source> <destination> | move-files --undo";
}

if [[ ${1:-} == "--undo" ]]; then
  if [[ ! -f $LOG_FILE ]]; then
    echo "❌ Nothing to undo" >&2
    exit 1
  fi
  while IFS='|' read -r src dst; do
    mv -n "$dst" "$src" && echo "↩️ $(basename "$dst")" || true
  done < "$LOG_FILE"
  rm -f "$LOG_FILE"
  echo "🎉 Undo complete"
  exit 0
fi

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

> "$LOG_FILE"
RECOVERY_FILE="$HOME/.termux-toolkit/logs/recovery.log"
trap 'echo "Move interrupted. Run: move-files --undo" >> "$RECOVERY_FILE"' ERR

echo "🔍 Preview:" 
for f in "$src"/*; do
  [[ -f $f ]] || continue
  echo " $(basename "$f") -> $dest" 
  echo "$src/$(basename "$f")|$dest/$(basename "$f")" >> "$LOG_FILE"
done

read -rp "Proceed with move? (y/N) " confirm
if [[ $confirm != [yY] ]]; then
  rm -f "$LOG_FILE"
  echo "Aborted." && exit 0
fi

if $dry_run; then
  log_info "Dry run enabled. No files moved."
else
  while IFS='|' read -r s d; do
    mv -n "$s" "$d" && log_info "$(basename "$s") moved"
  done < "$LOG_FILE"
  log_info "Move complete. Use 'move-files --undo' to reverse."
fi

