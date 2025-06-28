#!/data/data/com.termux/files/usr/bin/bash
# Description: diagnose DNS resolution for domains
# Dependencies: bind-utils

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() {
  echo "dns-debug - resolve domains and output records";
  echo "Usage: dns-debug [--offline] <domain1> [domain2 ...]";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

offline=false
domains=()
for arg in "$@"; do
  case $arg in
    --offline) offline=true ;;
    *) domains+=("$arg") ;;
  esac
  shift || true
done

[[ ${#domains[@]} -gt 0 ]] || domains=("google.com")

if $offline; then
  log_warn "Offline mode - checking /etc/hosts only"
  for d in "${domains[@]}"; do
    grep -w "$d" /etc/hosts || log_warn "$d not found in hosts"
  done
  exit 0
fi

require_tool nslookup bind-utils || require_tool dig dnsutils || exit 1

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/dns-debug.log"

for d in "${domains[@]}"; do
  log_info "Querying $d..."
  nslookup "$d" | tee -a "$LOG_FILE" || log_warn "Failed to resolve $d" | tee -a "$LOG_FILE"
  sleep 1
done
