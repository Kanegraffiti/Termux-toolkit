#!/data/data/com.termux/files/usr/bin/bash
# Description: scan ports on a host using nmap
# Dependencies: nmap

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() {
  echo "port-scan - simple port scanner";
  echo "Usage: port-scan [--offline] <host> [ports]";
  echo "Example: port-scan 192.168.1.1 22,80";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

offline=false
host=""
ports="1-1024"
for arg in "$@"; do
  case $arg in
    --offline) offline=true ;;
    *) if [[ -z $host ]]; then host="$arg"; else ports="$arg"; fi ;;
  esac
  shift || true
done

[[ -n $host ]] || { usage; exit 1; }

if $offline; then
  log_warn "Offline mode - skipping port scan"
  exit 0
fi

require_tool nmap nmap || exit 1

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/port-scan.log"

log_info "Scanning $host ports $ports..."
nmap -p "$ports" "$host" | tee "$LOG_FILE"
