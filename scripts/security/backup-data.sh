#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../security/security-common.sh"

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
read -rp "Destination directory: " dest
mkdir -p "$dest"

ts=$(date +%Y%m%d_%H%M%S)
archive="$dest/backup_$ts.tar.gz"

if $dry_run; then
  echo "Would archive $srcs to $archive"
  exit 0
fi

tar czf "$archive" $srcs

tar tzf "$archive" >/dev/null

echo "✅ Backup stored at $archive"
