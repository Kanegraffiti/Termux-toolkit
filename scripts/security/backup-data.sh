#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"
source "$TOOLKIT_ROOT/scripts/security/security-common.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "backup-data - interactive backup"
  echo "Usage: backup-data [--dry-run]"
  exit 0
fi

dry_run=false
[[ ${1:-} == "--dry-run" ]] && dry_run=true

require_tool tar tar
require_tool gzip gzip

check_storage_access

read -rp "Source paths (space separated): " srcs
read -rp "Destination directory [$DEFAULT_BACKUP_DIR]: " dest
dest=${dest:-$DEFAULT_BACKUP_DIR}
mkdir -p "$dest"

ts=$(date +%Y%m%d_%H%M%S)
archive="$dest/backup_$ts.tar.gz"
RECOVERY_FILE="$HOME/.termux-toolkit/logs/recovery.log"
trap 'echo "Backup interrupted. Partial file at $archive" >> "$RECOVERY_FILE"' ERR

if $dry_run; then
  echo "Would archive $srcs to $archive"
  exit 0
fi

tar czf "$archive" $srcs

tar tzf "$archive" >/dev/null

echo "✅ Backup stored at $archive"
