#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man files find-dupes
  exit 0
fi

usage() {
  echo "find-dupes - locate duplicate files";
  echo "Usage: find-dupes [directory] [--name|--checksum]";
}

dir="${1:-.}"
method="checksum"
if [[ ${2:-} == "--name" ]]; then
  method="name"
fi

if [[ ! -d $dir ]]; then
  echo "❌ Directory not found" >&2
  exit 1
fi

case $method in
  name)
    echo "🔍 Searching by name..."
    find "$dir" -type f -printf '%f\n' | sort | uniq -d | while read -r name; do
      echo "Duplicate: $name"
      find "$dir" -type f -name "$name"
    done
    ;;
  *)
    if ! command -v sha1sum >/dev/null 2>&1; then
      echo "❌ sha1sum not installed" >&2
      read -rp "Install via pkg-toolkit.sh? (y/N) " ans
      if [[ $ans == [yY] ]]; then
        "$HOME/.termux-toolkit/tools/pkg-toolkit.sh" require coreutils || true
      fi
      exit 1
    fi
    echo "🔍 Searching by checksum..."
    find "$dir" -type f -exec sha1sum {} + | sort | awk 'BEGIN{lasthash=""} {if($1==lasthash){print prev"\n"$0} prev=$0; lasthash=$1}'
    ;;
esac

