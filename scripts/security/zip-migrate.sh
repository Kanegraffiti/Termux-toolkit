#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../security/security-common.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "zip-migrate - zip folder for migration"
  echo "Usage: zip-migrate <folder>"
  exit 0
fi

folder="${1:-}"
[[ -z $folder ]] && { echo "Folder required" >&2; exit 1; }

require_tool zip zip

check_storage_access

dest="$HOME/backups"
mkdir -p "$dest"
name="$(basename "$folder")-$(date +%Y%m%d).zip"
archive="$dest/$name"

size=$(du -s "$folder" | awk '{print $1}')
free=$(df "$dest" | awk 'NR==2{print $4}')
if (( free < size )); then
  echo "⚠️ Low space in $dest" >&2
fi

zip -r -s 1g "$archive" "$folder"

echo "✅ Archive at $archive"
