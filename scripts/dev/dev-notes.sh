#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev dev-notes
  exit 0
fi

usage() {
  echo "dev-notes - open scratch notes"
  echo "Usage: dev-notes [file]"
}

FILE="${1:-DEV_NOTES.md}"

${EDITOR:-nano} "$FILE"
