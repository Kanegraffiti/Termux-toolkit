#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TARGET="$HOME/.termux-toolkit"
: "${PREFIX:?This uninstaller must be run inside Termux (PREFIX is not set)}"

if [[ ${1:-} != "--yes" ]]; then
  read -rp "Remove Termux Toolkit? Your config, logs and plugins will be deleted. (y/N) " answer
  [[ $answer == [yY] ]] || { echo "Aborted."; exit 0; }
fi

if [[ -d "$TARGET/bin" ]]; then
  for launcher in "$TARGET/bin"/*; do
    [[ -e $launcher ]] || continue
    link="$PREFIX/bin/$(basename "$launcher")"
    [[ -L $link && $(readlink "$link") == "$launcher" ]] && rm -f "$link"
  done
fi

rm -rf "$TARGET"
echo "✅ Termux Toolkit removed."
