#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

LOG_DIR="$HOME/.termux-toolkit/logs"
LOG_FILE="$LOG_DIR/pkg-install.log"
mkdir -p "$LOG_DIR"

batches=(
  "Core Dev Tools|git curl nodejs python jq"
  "File Utils|rename findutils coreutils"
  "Doc Conversion|pandoc libreoffice poppler-utils"
  "Android Helpers|termux-api x11-repo unstable-repo"
)

list_batches() {
  i=1
  for b in "${batches[@]}"; do
    name=${b%%|*}
    pkgs=${b#*|}
    echo "[$i] $name: $pkgs"
    i=$((i+1))
  done
}

status() {
  for b in "${batches[@]}"; do
    pkgs=${b#*|}
    for p in $pkgs; do
      if pkg list-installed 2>/dev/null | grep -q "^$p"; then
        echo "✅ $p"
      else
        echo "❌ $p"
      fi
    done
  done | sort -u
}

require() {
  pkg=$1
  if command -v "$pkg" >/dev/null 2>&1; then
    return 0
  fi
  echo "⚠️ $pkg not installed" >&2
  read -rp "Install $pkg now? (y/N) " ans
  if [[ $ans == [yY] ]]; then
    pkg install -y "$pkg" && return 0
  fi
  return 1
}

if [[ ${1:-} == "--list" ]]; then
  list_batches
  exit 0
elif [[ ${1:-} == "--status" ]]; then
  status
  exit 0
elif [[ ${1:-} == "require" ]]; then
  shift
  require "$1"
  exit $?
fi

declare -A actions
idx=1
for b in "${batches[@]}"; do
  name=${b%%|*}
  pkgs=${b#*|}
  echo "[$idx] $name: $pkgs"
  read -rp "(i)nstall/(u)ninstall/(s)kip: " ans
  case $ans in
    i|I) actions[$idx]="install" ;;
    u|U) actions[$idx]="uninstall" ;;
    *) actions[$idx]="skip" ;;
  esac
  idx=$((idx+1))
  echo
done

echo "Summary:" 
idx=1
for b in "${batches[@]}"; do
  act=${actions[$idx]}
  name=${b%%|*}
  [[ $act == "skip" ]] && { idx=$((idx+1)); continue; }
  echo " - $act $name"
  idx=$((idx+1))
fi

read -rp "Proceed? (y/N) " confirm
[[ $confirm == [yY] ]] || exit 0

idx=1
for b in "${batches[@]}"; do
  act=${actions[$idx]}
  pkgs=${b#*|}
  case $act in
    install)
      until pkg install -y $pkgs >>"$LOG_FILE" 2>&1; do
        echo "❌ Install failed for $pkgs" >&2
        read -rp "Retry? (y/N) " r
        [[ $r == [yY] ]] || break
      done
      ;;
    uninstall)
      until pkg uninstall -y $pkgs >>"$LOG_FILE" 2>&1; do
        echo "❌ Uninstall failed for $pkgs" >&2
        read -rp "Retry? (y/N) " r
        [[ $r == [yY] ]] || break
      done
      ;;
  esac
  idx=$((idx+1))
  echo
done

echo "📦 Done. Log at $LOG_FILE"

