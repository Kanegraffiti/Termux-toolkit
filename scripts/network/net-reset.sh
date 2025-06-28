#!/data/data/com.termux/files/usr/bin/bash
# Description: toggle Wi-Fi off and on to refresh network
# Dependencies: termux-api

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() {
  echo "net-reset - restart Wi-Fi interface";
  echo "Usage: net-reset [--offline]";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

offline=false
for arg in "$@"; do
  case $arg in
    --offline) offline=true ;;
  esac
  shift || true
done

if $offline; then
  log_warn "Offline mode - skipping network reset"
  exit 0
fi

require_tool termux-wifi-enable termux-api || exit 1

log_info "Disabling Wi-Fi..."
termux-wifi-enable false >/dev/null 2>&1 || log_warn "Failed to disable"
sleep 2
log_info "Enabling Wi-Fi..."
termux-wifi-enable true >/dev/null 2>&1 || log_warn "Failed to enable"
log_info "Wi-Fi toggled"
