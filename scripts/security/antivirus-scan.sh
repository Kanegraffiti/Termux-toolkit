#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"
source "${SCRIPT_DIR}/../security/security-common.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "antivirus-scan - run clamscan on files or directories"
  echo "Usage: antivirus-scan [path ...]"
  exit 0
fi

require_tool clamscan clamav
require_tool freshclam clamav

check_storage_access

LOG="$HOME/.termux-toolkit/logs/security-antivirus.log"

freshclam || true

paths=("$@")
if [[ ${#paths[@]} -eq 0 ]]; then
  if ask_confirm "Scan entire storage? (y/N) "; then
    paths=("$HOME" "$HOME/storage/shared")
  else
    echo "Aborted." && exit 0
  fi
fi

infected_file_list="$(mktemp)"

clamscan -r "${paths[@]}" | tee "$LOG" | awk '/FOUND$/{print $1}' > "$infected_file_list"

infected_count=$(wc -l < "$infected_file_list" | tr -d ' ')

if [[ $infected_count -gt 0 ]]; then
  echo "❌ $infected_count infected file(s) found"
  if ask_confirm "Quarantine infected files to ~/quarantine? (y/N) "; then
    mkdir -p "$HOME/quarantine"
    while IFS= read -r f; do
      mv "$f" "$HOME/quarantine/" 2>>"$LOG" || true
    done < "$infected_file_list"
    echo "🗄️ Files moved to ~/quarantine"
  fi
else
  echo "✅ No infections"
fi

rm -f "$infected_file_list"
