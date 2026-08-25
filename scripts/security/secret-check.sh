#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

usage() { echo "Usage: secret-check [project]"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
project="$(realpath "${1:-.}")"
[[ -d $project ]] || { log_error "Directory not found: $project"; exit 2; }

findings=0
report_match() {
  local file="$1" rule="$2" pattern="$3" lines
  lines="$(grep -nEi "$pattern" "$file" 2>/dev/null | cut -d: -f1 | sort -nu || true)"
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    printf '%s:%s [%s]\n' "${file#$project/}" "$line" "$rule"
    findings=$((findings + 1))
  done <<< "$lines"
}

while IFS= read -r -d '' file; do
  grep -Iq . "$file" 2>/dev/null || continue
  report_match "$file" "private-key" 'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
  report_match "$file" "github-token" 'gh[pousr]_[A-Za-z0-9]{20,}'
  report_match "$file" "openai-key" 'sk-[A-Za-z0-9_-]{20,}'
  report_match "$file" "aws-access-key" 'AKIA[0-9A-Z]{16}'
  report_match "$file" "probable-secret" '(api[_-]?(key|token)|secret|token|password)[[:space:]]*[=:][[:space:]]*[-A-Za-z0-9_./+=]{12,}'
done < <(find "$project" \
  \( -path '*/.git' -o -path '*/node_modules' -o -path '*/.next' -o -path '*/dist' \
     -o -path '*/build' \) -prune -o \
  \( -name '*.lock' -o -name 'package-lock.json' \) -prune -o \
  -type f -size -2M -print0)

if ((findings)); then
  log_warn "$findings possible secret location(s) found. Values were not printed."
  exit 1
fi
log_success "No probable secrets found by the local rules."
