#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() { echo "Usage: repo-status-all [directory]"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
root="$(realpath "${1:-$HOME}")"
[[ -d $root ]] || { log_error "Directory not found: $root"; exit 2; }

printf '%-32s %-18s %-8s %-7s %-7s\n' "REPOSITORY" "BRANCH" "STATE" "AHEAD" "BEHIND"
printf '%-32s %-18s %-8s %-7s %-7s\n' "----------" "------" "-----" "-----" "------"
while IFS= read -r git_dir; do
  repo="${git_dir%/.git}"
  branch="$(git -C "$repo" branch --show-current 2>/dev/null || true)"
  [[ -n $branch ]] || branch="detached"
  [[ -n $(git -C "$repo" status --porcelain 2>/dev/null) ]] && state="modified" || state="clean"
  counts="$(git -C "$repo" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null || echo '0 0')"
  behind="${counts%%[[:space:]]*}"; ahead="${counts##*[[:space:]]}"
  printf '%-32s %-18s %-8s %-7s %-7s\n' "${repo#$root/}" "$branch" "$state" "$ahead" "$behind"
done < <(find "$root" -type d \( -name node_modules -o -name .termux-toolkit \) -prune -o -type d -name .git -print 2>/dev/null | sort)
