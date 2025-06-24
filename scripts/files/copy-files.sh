#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man files copy-files
  exit 0
fi

usage() {
  echo "copy-files - copy files safely";
  echo "Usage: copy-files <source> <destination>";
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

src=$1
dest=$2

if [[ ! -d $src ]]; then
  echo "❌ Source directory not found" >&2
  exit 1
fi

mkdir -p "$dest"

echo "🔍 Files to copy:" 
find "$src" -maxdepth 1 -type f -printf '%f\n' | while read -r f; do
  echo " $f"
done

read -rp "Proceed with copy? (y/N) " confirm
if [[ $confirm != [yY] ]]; then
  echo "Aborted." && exit 0
fi

for f in "$src"/*; do
  [[ -f $f ]] || continue
  cp -i "$f" "$dest/" && echo "✅ $(basename "$f") copied"
done

echo "🎉 Copy complete"

