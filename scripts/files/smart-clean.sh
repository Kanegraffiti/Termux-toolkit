#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man files smart-clean
  exit 0
fi

usage() {
  echo "smart-clean - remove temp/clutter files";
  echo "Usage: smart-clean [directory]";
}

dir="${1:-.}"

if [[ ! -d $dir ]]; then
  echo "❌ Directory not found" >&2
  exit 1
fi

patterns=("*.DS_Store" "Thumbs.db" "*.bak" "*.tmp")

echo "🔍 Searching for clutter..."
files=$(find "$dir" -type f \( -name "${patterns[0]}" -o -name "${patterns[1]}" -o -name "${patterns[2]}" -o -name "${patterns[3]}" \))

if [[ -z $files ]]; then
  echo "✨ No clutter files found"
  exit 0
fi

echo "$files"
read -rp "Delete these files? (y/N) " confirm
if [[ $confirm != [yY] ]]; then
  echo "Aborted." && exit 0
fi

echo "$files" | xargs rm -f

echo "🧹 Cleaned up"

