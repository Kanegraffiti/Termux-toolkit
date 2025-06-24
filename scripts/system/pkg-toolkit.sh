#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

CONF="$HOME/.termux-toolkit/pkg-batches.conf"
[[ -f $CONF ]] || cp "$(dirname "$0")/../../tools/pkg-batches.conf" "$CONF"

declare -A batches
while IFS='=' read -r name pkgs; do
  [[ $name ]] || continue
  name=${name//[/}
  name=${name//]/}
  batches[$name]=$pkgs
done < "$CONF"

list_batches() {
  for n in "${!batches[@]}"; do
    echo "$n: ${batches[$n]}"
  done
}

status_batches() {
  for n in "${!batches[@]}"; do
    for p in ${batches[$n]}; do
      if pkg list-installed 2>/dev/null | grep -q "^$p"; then
        echo "✅ $p"
      else
        echo "❌ $p"
      fi
    done
  done | sort -u
}

install_batch() { pkg install -y ${batches[$1]} ; }
uninstall_batch() { pkg uninstall -y ${batches[$1]} || true ; }

case ${1:-} in
  --list) list_batches ;;
  --status) status_batches ;;
  --install) install_batch "$2" ;;
  --uninstall) uninstall_batch "$2" ;;
  *) echo "Usage: pkg-toolkit --list | --status | --install <batch> | --uninstall <batch>" >&2; exit 1 ;;
esac
