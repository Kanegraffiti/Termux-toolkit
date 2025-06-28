#!/data/data/com.termux/files/usr/bin/bash
# Description: measure network download speed using curl
# Dependencies: curl

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() {
  echo "speed-test - quick bandwidth test";
  echo "Usage: speed-test [--offline] [url]";
  echo "Default URL: https://speed.hetzner.de/100MB.bin";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

offline=false
url="https://speed.hetzner.de/100MB.bin"
for arg in "$@"; do
  case $arg in
    --offline) offline=true ;;
    *) url="$arg" ;;
  esac
  shift || true
done

if $offline; then
  log_warn "Offline mode - skipping speed test"
  exit 0
fi

require_tool curl curl || exit 1
check_network || exit 1

TMP_FILE=$(mktemp)
log_info "Downloading test file..."
start=$(date +%s)
curl -L "$url" -o "$TMP_FILE" --progress-bar >/dev/null
end=$(date +%s)
rm -f "$TMP_FILE"

elapsed=$((end - start))
if [[ $elapsed -gt 0 ]]; then
  size_mb=100
  rate=$((size_mb / elapsed))
  log_info "Approx speed: ${rate} MB/s"
else
  log_warn "Test too quick to measure"
fi
