#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

require_tool pkg pkg || { log_error "pkg tool required"; exit 1; }

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

choose_batch() {
  local opts=("${!batches[@]}") sel
  if command -v fzf >/dev/null 2>&1; then
    sel=$(printf '%s\n' "${opts[@]}" | fzf)
  else
    PS3="Select batch: "
    select sel in "${opts[@]}"; do break; done
  fi
  echo "$sel"
}

case ${1:-} in
  --list) list_batches ;;
  --status) status_batches ;;
  --install)
    batch=${2:-$(choose_batch)}
    [[ -z $batch ]] && exit 1
    ask_confirm "Install batch '$batch'?" && install_batch "$batch"
    ;;
  --uninstall)
    batch=${2:-$(choose_batch)}
    [[ -z $batch ]] && exit 1
    ask_confirm "Uninstall batch '$batch'?" && uninstall_batch "$batch"
    ;;
  *)
    echo "Usage: pkg-toolkit --list | --status | --install [batch] | --uninstall [batch]" >&2
    exit 1
    ;;
esac
