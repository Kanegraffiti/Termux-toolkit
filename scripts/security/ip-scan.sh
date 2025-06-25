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
  echo "ip-scan - scan LAN with nmap"
  echo "Usage: ip-scan [subnet]"
  exit 0
fi

subnet="${1:-}"
require_tool nmap nmap || require_tool nmap busybox

if [[ -z $subnet ]]; then
  subnet=$(ip route | awk '/src/ {print $1; exit}')
fi

LOG="$HOME/.termux-toolkit/logs/security-ipscan.log"

nmap -p 22,80,443 "$subnet" -oG - | awk '/Up$/{ip=$2} /Ports:/{print ip, $2}' | tee "$LOG"
