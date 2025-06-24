#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "ttk-feedback - submit toolkit feedback"
  echo "Usage: ttk-feedback [message]"
  exit 0
fi

msg="$*"
if [[ -z $msg ]]; then
  read -rp "Feedback: " msg
fi

mkdir -p "$HOME/.termux-toolkit/logs"
echo "$(date '+%F %T') $msg" >> "$HOME/.termux-toolkit/logs/feedback.log"
log "user-feedback: $msg"

# try sending to API endpoint if reachable
if check_network; then
  curl -fs -X POST "$AI_API_ENDPOINT" -d "feedback=$msg" >/dev/null 2>&1 || true
fi

echo "Thanks for your feedback!"
