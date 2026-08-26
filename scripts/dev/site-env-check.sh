#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() { echo "Usage: site-env-check <project> [--example <file>] [--env <file>]"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -ge 1 ]] || { usage >&2; exit 2; }
project="$(website_resolve_project "$1")"; shift
example="$project/.env.example" env_file="$project/.env"
while (($#)); do
  case $1 in
    --example) example="${2:-}"; shift 2 ;;
    --env) env_file="${2:-}"; shift 2 ;;
    *) log_error "Unknown option: $1"; exit 2 ;;
  esac
done
[[ -f $example ]] || { log_error "Environment example not found: $example"; exit 1; }

env_keys() {
  sed -nE 's/^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=.*/\2/p' "$1" | sort -u
}

expected="$(mktemp)" actual="$(mktemp)"
trap 'rm -f "$expected" "$actual"' EXIT
env_keys "$example" > "$expected"
[[ -f $env_file ]] && env_keys "$env_file" > "$actual" || : > "$actual"

missing="$(comm -23 "$expected" "$actual")"
extra="$(comm -13 "$expected" "$actual")"
echo "Example: $example"
echo "Environment: $env_file"
echo "Expected keys: $(wc -l < "$expected" | tr -d ' ')"
if [[ -n $missing ]]; then
  echo "Missing keys:"
  sed 's/^/ - /' <<< "$missing"
else
  echo "Missing keys: none"
fi
if [[ -n $extra ]]; then
  echo "Additional keys (values hidden):"
  sed 's/^/ - /' <<< "$extra"
fi
[[ -z $missing ]]
