#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev setupdev
  exit 0
fi

usage() {
  echo "setupdev - install common dev packages"
  echo "Usage: setupdev"
}

read -rp "Install common dev packages (git, curl, nodejs, python, sqlite)? (y/N) " ans
if [[ $ans != "y" && $ans != "Y" ]]; then
  echo "Aborted." && exit 0
fi

# network check
if ! ping -c1 -W1 8.8.8.8 >/dev/null 2>&1; then
  echo "❌ Network unreachable. Try again later or install packages manually." >&2
  exit 1
fi

pkg update -y
pkg install -y git curl nodejs python sqlite nano inotify-tools

echo "✅ Development packages installed"
