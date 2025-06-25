
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
  echo "network-check - check connectivity"
  echo "Usage: network-check"
  exit 0
fi

require_tool ping iputils
require_tool curl curl

LOG="$HOME/.termux-toolkit/logs/security-network.log"

p1=$(ping -c1 1.1.1.1 | tail -1 || true)
p2=$(ping -c1 8.8.8.8 | tail -1 || true)

http_code=$(curl -o /dev/null -w '%{http_code}' -s https://github.com || echo 000)
portal_code=$(curl -o /dev/null -w '%{http_code}' -s http://connectivitycheck.gstatic.com || echo 000)

echo "1.1.1.1 -> $p1" | tee "$LOG"
echo "8.8.8.8 -> $p2" | tee -a "$LOG"
echo "github.com HTTP -> $http_code" | tee -a "$LOG"

if [[ $portal_code == 204 ]]; then
  echo "No captive portal detected" | tee -a "$LOG"
else
  echo "⚠️ Possible captive portal" | tee -a "$LOG"
fi
