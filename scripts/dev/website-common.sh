#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

WEBSITE_STATE_DIR="$HOME/.termux-toolkit/state/website"
WEBSITE_WORK_DIR="$HOME/.termux-toolkit/workspaces/websites"

website_search_roots() {
  [[ -d "$HOME/storage/shared" ]] && printf '%s\n' "$HOME/storage/shared"
  printf '%s\n' "$HOME"
}

website_find() {
  local query="$1" root="${2:-}" search_root
  if [[ -n $root ]]; then
    [[ -d $root ]] || { log_error "Search root does not exist: $root"; return 1; }
    find "$root" \
      \( -path '*/.git' -o -path '*/node_modules' -o -path '*/.termux-toolkit' \) -prune -o \
      \( -type d -o -type f -iname '*.zip' \) -iname "*$query*" -print
    return
  fi
  while IFS= read -r search_root; do
    find "$search_root" \
      \( -path '*/.git' -o -path '*/node_modules' -o -path '*/.termux-toolkit' \) -prune -o \
      \( -type d -o -type f -iname '*.zip' \) -iname "*$query*" -print 2>/dev/null
  done < <(website_search_roots)
}

website_choose_match() {
  local query="$1" root="${2:-}" choice
  local -a matches=()
  while IFS= read -r match; do
    [[ -n $match ]] && matches+=("$match")
  done < <(website_find "$query" "$root" | awk '!seen[$0]++')

  ((${#matches[@]})) || { log_error "No folder or ZIP matching '$query' was found."; return 1; }
  if ((${#matches[@]} == 1)); then
    printf '%s\n' "${matches[0]}"
    return
  fi
  if [[ ! -t 0 ]]; then
    log_error "Multiple matches found. Pass an exact path instead."
    printf ' - %s\n' "${matches[@]}" >&2
    return 1
  fi
  echo "Matches:" >&2
  select choice in "${matches[@]}"; do
    [[ -n $choice ]] && { printf '%s\n' "$choice"; return; }
    echo "Choose a listed number." >&2
  done
}

website_safe_extract() {
  local archive="$1" destination base
  require_tool unzip unzip >&2 || return 1
  if unzip -Z1 "$archive" | grep -Eq '(^/|(^|/)\.\.(/|$))'; then
    log_error "Archive contains unsafe paths and was not extracted."
    return 1
  fi
  base="$(basename "${archive%.zip}")"
  destination="$WEBSITE_WORK_DIR/${base}-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$destination"
  unzip -q "$archive" -d "$destination"

  local -a children=("$destination"/*)
  if ((${#children[@]} == 1)) && [[ -d ${children[0]} ]]; then
    printf '%s\n' "${children[0]}"
  else
    printf '%s\n' "$destination"
  fi
}

website_pid_matches() {
  local pid="$1" recorded_start current_start
  [[ $pid =~ ^[0-9]+$ && -r "/proc/$pid/stat" && -f "$WEBSITE_STATE_DIR/server.start" ]] || return 1
  recorded_start="$(cat "$WEBSITE_STATE_DIR/server.start")"
  current_start="$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null || true)"
  [[ -n $recorded_start && $current_start == "$recorded_start" ]]
}

website_resolve_project() {
  local value="$1" root="${2:-}" selected
  if [[ -e $value ]]; then
    selected="$(realpath "$value")"
  else
    selected="$(website_choose_match "$value" "$root")" || return 1
  fi
  if [[ -f $selected && ${selected,,} == *.zip ]]; then
    website_safe_extract "$selected"
  elif [[ -d $selected ]]; then
    printf '%s\n' "$selected"
  else
    log_error "Not a website folder or ZIP archive: $selected"
    return 1
  fi
}

website_stack() {
  local dir="$1" package="${1%/}/package.json"
  if [[ -f "$dir/next.config.js" || -f "$dir/next.config.mjs" || -f "$dir/next.config.ts" ]]; then
    echo "Next.js"
  elif [[ -f "$dir/vite.config.js" || -f "$dir/vite.config.ts" || -f "$dir/vite.config.mjs" ]]; then
    echo "Vite"
  elif [[ -f $package ]] && grep -q 'react-scripts' "$package"; then
    echo "Create React App"
  elif [[ -f "$dir/angular.json" ]]; then
    echo "Angular"
  elif [[ -f "$dir/astro.config.mjs" || -f "$dir/astro.config.ts" ]]; then
    echo "Astro"
  elif [[ -f "$dir/nuxt.config.js" || -f "$dir/nuxt.config.ts" ]]; then
    echo "Nuxt"
  elif [[ -f $package ]]; then
    echo "Node.js"
  elif [[ -f "$dir/index.php" ]]; then
    echo "PHP"
  elif [[ -f "$dir/index.html" ]]; then
    echo "Static HTML"
  else
    echo "Unknown"
  fi
}

website_package_manager() {
  local dir="$1"
  [[ -f "$dir/pnpm-lock.yaml" ]] && { echo pnpm; return; }
  [[ -f "$dir/yarn.lock" ]] && { echo yarn; return; }
  [[ -f "$dir/bun.lockb" || -f "$dir/bun.lock" ]] && { echo bun; return; }
  [[ -f "$dir/package.json" ]] && { echo npm; return; }
  echo none
}
