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
  mini-man files convert-docs
  exit 0
fi

usage() {
  echo "convert-docs - convert documents";
  echo "Usage: convert-docs <source> <target>";
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

src=$1
dst=$2

ext_from="${src##*.}"
ext_to="${dst##*.}"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ $1 not installed" >&2
    read -rp "Install via pkg-toolkit.sh? (y/N) " ans
    if [[ $ans == [yY] ]]; then
      "$HOME/.termux-toolkit/tools/pkg-toolkit.sh" require "$1" || true
    fi
    exit 1
  fi
}

case "$ext_from:$ext_to" in
  md:txt)
    require pandoc
    pandoc "$src" -t plain -o "$dst"
    ;;
  md:pdf)
    require pandoc
    pandoc "$src" -o "$dst"
    ;;
  txt:md)
    require pandoc
    pandoc "$src" -f plain -t markdown -o "$dst"
    ;;
  docx:pdf)
    require lowriter
    lowriter --convert-to pdf "$src" --outdir "$(dirname "$dst")"
    mv "$(dirname "$dst")/$(basename "${src%.docx}").pdf" "$dst"
    ;;
  *)
    echo "❌ Conversion not supported" >&2
    exit 1
    ;;
esac

echo "🎉 Converted $src -> $dst"

