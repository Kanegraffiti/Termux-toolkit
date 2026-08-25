#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() {
  cat <<'EOF'
Usage: site-open <folder-or-zip-or-name> [options]

Options:
  --root <directory>  Limit name searching to one directory
  --port <number>     Local port (default: 4173)
  --no-open           Start the server without opening a browser
  --dry-run           Show what would happen without running anything
EOF
}

[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
value=$1
shift
root="" port=4173 open_browser=true dry_run=false
while (($#)); do
  case $1 in
    --root) root="${2:-}"; shift 2 ;;
    --port) port="${2:-}"; shift 2 ;;
    --no-open) open_browser=false; shift ;;
    --dry-run) dry_run=true; shift ;;
    *) log_error "Unknown option: $1"; exit 2 ;;
  esac
done
[[ $port =~ ^[0-9]+$ && $port -ge 1024 && $port -le 65535 ]] || {
  log_error "Port must be between 1024 and 65535."
  exit 2
}
if command -v ss >/dev/null 2>&1 && ss -ltn 2>/dev/null | awk '{print $4}' | grep -Eq "(^|:)$port$"; then
  log_error "Port $port is already in use. Choose another with --port."
  exit 1
fi

project="$(website_resolve_project "$value" "$root")"
stack="$(website_stack "$project")"
manager="$(website_package_manager "$project")"
url="http://127.0.0.1:$port"
declare -a command

case $stack in
  "Next.js") command=("$manager" run dev -- --hostname 127.0.0.1 --port "$port") ;;
  Vite|Astro|Nuxt|Angular|Node.js) command=("$manager" run dev -- --host 127.0.0.1 --port "$port") ;;
  "Create React App") command=(env HOST=127.0.0.1 PORT="$port" "$manager" start) ;;
  PHP) command=(php -S "127.0.0.1:$port" -t "$project") ;;
  "Static HTML") command=(python -m http.server "$port" --bind 127.0.0.1 --directory "$project") ;;
  *) log_error "Could not determine how to serve this project. Run project-info first."; exit 1 ;;
esac

log_info "Project: $project"
log_info "Detected stack: $stack"
log_info "URL: $url"
printf 'Command:'; printf ' %q' "${command[@]}"; echo
[[ $dry_run == true ]] && exit 0

if [[ $manager != none && ! -d "$project/node_modules" ]]; then
  ask_confirm "Dependencies are missing. Run '$manager install' in this project?" || {
    log_warn "Cancelled before executing project code."
    exit 1
  }
  (cd "$project" && "$manager" install)
fi

case $stack in
  PHP) require_tool php php || exit 1 ;;
  "Static HTML") require_tool python python || exit 1 ;;
  *) require_tool "$manager" "$manager" || exit 1 ;;
esac

mkdir -p "$WEBSITE_STATE_DIR"
old_pid="$(cat "$WEBSITE_STATE_DIR/server.pid" 2>/dev/null || true)"
if website_pid_matches "$old_pid"; then
  log_error "A toolkit website server is already running (PID $old_pid). Run site-stop first."
  exit 1
fi
log_file="$WEBSITE_STATE_DIR/server.log"
starting_dir="$PWD"
cd "$project"
nohup "${command[@]}" >"$log_file" 2>&1 &
pid=$!
cd "$starting_dir"
printf '%s\n' "$pid" > "$WEBSITE_STATE_DIR/server.pid"
printf '%s\n' "$project" > "$WEBSITE_STATE_DIR/project"
printf '%s\n' "$url" > "$WEBSITE_STATE_DIR/url"

sleep 1
kill -0 "$pid" 2>/dev/null || {
  log_error "Server stopped during startup. Last log lines:"
  tail -20 "$log_file" >&2
  exit 1
}
start_time="$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null || true)"
if [[ -z $start_time ]]; then
  log_error "Server stopped during startup. Last log lines:"
  tail -20 "$log_file" >&2
  exit 1
fi
printf '%s\n' "$start_time" > "$WEBSITE_STATE_DIR/server.start"

if command -v curl >/dev/null 2>&1; then
  ready=false
  for _ in {1..15}; do
    if curl -fsS --max-time 1 "$url" >/dev/null 2>&1; then
      ready=true
      break
    fi
    kill -0 "$pid" 2>/dev/null || break
    sleep 1
  done
  [[ $ready == true ]] || log_warn "Server is running but did not respond yet. Check site-status and the log."
fi

log_success "Website server started (PID $pid)."
if [[ $open_browser == true ]]; then
  if command -v termux-open-url >/dev/null 2>&1; then
    termux-open-url "$url"
  else
    log_warn "termux-open-url is unavailable. Open $url manually."
  fi
fi
echo "Run 'site-status' for details or 'site-stop' when finished."
