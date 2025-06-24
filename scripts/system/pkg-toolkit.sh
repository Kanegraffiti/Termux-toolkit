#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

usage() {
  echo "pkg-toolkit - install toolkit package batches"
  echo "Usage: pkg-toolkit <category> <install|uninstall>"
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

category="${1:-}"
action="${2:-install}"
[[ -z $category ]] && { usage; exit 1; }

security_pkgs=(clamav nmap rsync zip unzip busybox p7zip)

case $category in
  security)
    pkgs=("${security_pkgs[@]}")
    ;;
  *)
    echo "Unknown category $category" >&2
    exit 1
    ;;
esac

case $action in
  install)
    pkg install -y "${pkgs[@]}"
    ;;
  uninstall)
    pkg uninstall -y "${pkgs[@]}" || true
    ;;
  *)
    usage; exit 1 ;;
esac
