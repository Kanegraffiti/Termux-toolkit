#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev newproject
  exit 0
fi

usage() {
  echo "newproject - scaffold a new project"
  echo "Usage: newproject [name] [--node] [--python]"
}

project=""
node=false
python=false

for arg in "$@"; do
  case $arg in
    --node) node=true ;;
    --python) python=true ;;
    -h|--help) mini-man dev newproject; exit 0 ;;
    *) project="$arg" ;;
  esac
  shift || true
done

if [[ -z "$project" ]]; then
  read -rp "Enter project name: " project
fi

[[ -z "$project" ]] && { log_error "No project name provided."; exit 1; }

if [[ -e $project ]]; then
  log_error "Folder '$project' already exists."; exit 1
fi

mkdir -p "$project" && cd "$project"
log_info "🌱 Creating project in $(pwd)"

require_tool git git || { log_error "Git required"; exit 1; }

if [[ ! -f README.md ]]; then
  echo "# $(basename $(pwd))" > README.md
  log_success "README created"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git init -b main >/dev/null 2>&1; then
    log_success "Git repository initialized on main"
  else
    git init >/dev/null && git checkout -b main >/dev/null
    log_success "Git repository initialized"
  fi
fi

if $node; then
  if command -v npm >/dev/null 2>&1; then
    if [[ ! -f package.json ]]; then
      npm init -y >/dev/null && log_success "npm project initialized"
    fi
  else
    log_warn "npm not installed"
  fi
fi

if $python; then
  if command -v python >/dev/null 2>&1; then
    [[ -f requirements.txt ]] || touch requirements.txt
    log_success "Python requirements file ready"
  else
    log_warn "Python not installed"
  fi
fi

log_success "Project setup complete"
