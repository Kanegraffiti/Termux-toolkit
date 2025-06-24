#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../security/security-common.sh"

usage() {
  echo "scan-by-name - search by name and scan"
  echo "Usage: scan-by-name <name> [--hash] [--extra DIR]"
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

name="${1:-}"
[[ -z $name ]] && { usage; exit 1; }
shift

hash_only=false
extra_paths=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --hash) hash_only=true ;;
    --extra) extra_paths+=("$2"); shift ;;
  esac
  shift
done

check_storage_access

search_paths=("$HOME" "$HOME/storage/shared" "${extra_paths[@]}")
mapfile -t results < <(find "${search_paths[@]}" -name "$name" 2>/dev/null)

if [[ ${#results[@]} -eq 0 ]]; then
  echo "❌ No matches found" >&2
  exit 1
fi

if [[ ${#results[@]} -gt 1 ]]; then
  echo "Multiple matches:"; i=1
  for r in "${results[@]}"; do
    echo " $i) $r"; ((i++))
  done
  read -rp "Choose number(s) to process (e.g. 1 2): " choices
  set -- $choices
  selected=()
  for idx; do
    selected+=("${results[idx-1]}")
  done
else
  selected=("${results[0]}")
fi

for item in "${selected[@]}"; do
  if $hash_only; then
    sha256sum "$item" | awk '{print $1}'
    stat -c "%s bytes" "$item"
  else
    "$SCRIPT_DIR/antivirus-scan.sh" "$item"
  fi
done
