#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev scaffold-maker
  exit 0
fi

usage() {
  echo "scaffold-maker - create project scaffold";
  echo "Usage: scaffold-maker <name> [--lang node|python|bash]";
}

name="${1:-}"
lang="${2:-}"

if [[ -z $name ]]; then
  read -rp "Project name: " name
fi

case $lang in
  --lang)
    lang=$3
    ;;
  node|python|bash)
    ;;
  *)
    read -rp "Language (node/python/bash)? " lang
    ;;
esac

mkdir -p "$name"/{src,tests,docs}
cd "$name"

echo "# $name" > README.md

gitignore_content=""
case $lang in
  node)
    gitignore_content="node_modules/";
    command -v npm >/dev/null 2>&1 && npm init -y >/dev/null && echo "✅ npm init" || echo "❌ npm not installed" >&2
    ;;
  python)
    gitignore_content="__pycache__/";
    command -v python >/dev/null 2>&1 && touch requirements.txt && echo "✅ requirements.txt" || echo "❌ Python not installed" >&2
    ;;
  bash)
    gitignore_content="";
    ;;
esac

echo "$gitignore_content" > .gitignore

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  read -rp "Initialize git repo? (y/N) " ans
  if [[ $ans == [yY] ]]; then
    git init >/dev/null && echo "✅ Git initialized"
  fi
fi

echo "🎉 Project scaffold created in $(pwd)"

