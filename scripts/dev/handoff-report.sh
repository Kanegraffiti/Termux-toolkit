#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() { echo "Usage: handoff-report <project> [--output <markdown-file>]"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
project="$(website_resolve_project "$1")"; shift
output="$project/HANDOFF.md"
while (($#)); do
  case $1 in --output) output="${2:-}"; shift 2 ;; *) log_error "Unknown option: $1"; exit 2 ;; esac
done
stack="$(website_stack "$project")" manager="$(website_package_manager "$project")"
remote="Not configured" branch="Not a Git repository"
if [[ -d "$project/.git" ]]; then
  remote="$(git -C "$project" remote get-url origin 2>/dev/null || echo 'Not configured')"
  remote="$(sed -E 's#(https?://)[^/@]+@#\1[credentials-hidden]@#' <<< "$remote")"
  branch="$(git -C "$project" branch --show-current 2>/dev/null || echo unknown)"
fi
mkdir -p "$(dirname "$output")"
{
  echo "# Project Handoff: $(basename "$project")"
  echo
  echo "Generated: $(date '+%Y-%m-%d %H:%M')"
  echo
  echo "## Technical overview"
  echo
  echo "- Stack: $stack"
  echo "- Package manager: $manager"
  echo "- Repository: $remote"
  echo "- Branch: $branch"
  echo
  echo "## Setup"
  echo
  if [[ $manager != none ]]; then
    echo '```bash'
    echo "$manager install"
    website_has_script "$project" dev && echo "$manager run dev"
    echo '```'
  else
    echo "Open or serve the project directory according to the detected $stack stack."
  fi
  echo
  echo "## Production"
  echo
  if website_has_script "$project" build; then
    echo '```bash'
    echo "$manager run build"
    echo '```'
  else
    echo "No production build script was detected."
  fi
  echo
  echo "## Environment"
  echo
  [[ -f "$project/.env.example" ]] && echo "Copy .env.example to .env and supply the required values." \
    || echo "No .env.example file was detected."
  echo
  echo "## Handoff checklist"
  echo
  echo "- [ ] Production build passes"
  echo "- [ ] Environment variables are configured"
  echo "- [ ] Domain and deployment access transferred"
  echo "- [ ] Analytics and forms verified"
  echo "- [ ] Client credentials shared through a secure channel"
} > "$output"
log_success "Handoff report created: $output"
