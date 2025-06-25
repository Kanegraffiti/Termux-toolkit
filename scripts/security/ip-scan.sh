#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"
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
