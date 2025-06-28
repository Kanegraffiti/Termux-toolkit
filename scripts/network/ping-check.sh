#!/data/data/com.termux/files/usr/bin/bash
# Description: ping one or more hosts and report latency
# Dependencies: iputils-ping

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() {
  echo "ping-check - ping hosts";
  echo "Usage: ping-check [--offline] <host1> [host2 ...]";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

offline=false
hosts=()
for arg in "$@"; do
  case $arg in
    --offline) offline=true ;;
    *) hosts+=("$arg") ;;
  esac
  shift || true
done

[[ ${#hosts[@]} -gt 0 ]] || hosts=("1.1.1.1" "google.com")

if $offline; then
  log_warn "Offline mode - skipping network pings"
  exit 0
fi

require_tool ping iputils-ping || exit 1

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/ping-check.log"

for h in "${hosts[@]}"; do
  log_info "Pinging $h..."
  if ping -c1 "$h" >/dev/null 2>&1; then
    latency=$(ping -c1 "$h" | awk -F'/' 'END{print $5" ms"}')
    log_info "$h responded in $latency" | tee -a "$LOG_FILE"
  else
    log_warn "$h unreachable" | tee -a "$LOG_FILE"
  fi
  sleep 1
done
