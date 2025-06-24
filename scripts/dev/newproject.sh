#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev newproject
  exit 0
fi

usage() {
  echo "newproject - scaffold a new project"
  echo "Usage: newproject [name] [--node] [--python]"
}

project="."
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

if [[ $project != "." ]]; then
  mkdir -p "$project"
  cd "$project"
fi

echo "🌱 Creating project in $(pwd)"

if [[ ! -f README.md ]]; then
  echo "# $(basename $(pwd))" > README.md
  echo "✅ README created"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init >/dev/null
  echo "✅ Git repository initialized"
fi

if $node; then
  if command -v npm >/dev/null 2>&1; then
    if [[ ! -f package.json ]]; then
      npm init -y >/dev/null && echo "✅ npm project initialized"
    fi
  else
    echo "❌ npm not installed" >&2
  fi
fi

if $python; then
  if command -v python >/dev/null 2>&1; then
    [[ -f requirements.txt ]] || touch requirements.txt
    echo "✅ Python requirements file ready"
  else
    echo "❌ Python not installed" >&2
  fi
fi

echo "🎉 Project setup complete"
