#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

usage() { echo "Usage: site-doctor <project-or-name>"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $# -eq 1 ]] || { usage >&2; exit 2; }
project="$(website_resolve_project "$1")"
stack="$(website_stack "$project")"
manager="$(website_package_manager "$project")"
warnings=0 errors=0

pass() { echo "PASS  $*"; }
warn() { echo "WARN  $*"; warnings=$((warnings + 1)); }
fail() { echo "FAIL  $*"; errors=$((errors + 1)); }

echo "Project: $project"
echo "Stack: $stack"
echo "Package manager: $manager"
[[ $stack != Unknown ]] && pass "Technology stack detected" || fail "Technology stack was not recognized"
if [[ $manager != none ]]; then
  command -v "$manager" >/dev/null 2>&1 && pass "$manager is installed" || fail "$manager is not installed"
  [[ -d "$project/node_modules" ]] && pass "Dependencies are installed" || warn "node_modules is missing"
  website_has_script "$project" dev && pass "Development script exists" || warn "No dev script in package.json"
  website_has_script "$project" build && pass "Production build script exists" || fail "No build script in package.json"
  [[ -f "$project/package-lock.json" || -f "$project/pnpm-lock.yaml" || -f "$project/yarn.lock" || -f "$project/bun.lockb" ]] \
    && pass "Dependency lockfile exists" || warn "No dependency lockfile found"
fi
[[ -f "$project/.env.example" ]] && {
  [[ -f "$project/.env" ]] && pass ".env exists" || warn ".env.example exists but .env is missing"
}
[[ -d "$project/.git" ]] && pass "Git repository detected" || warn "Project is not a Git repository"
[[ -f "$project/README.md" ]] && pass "README exists" || warn "README is missing"

echo "Summary: $errors failure(s), $warnings warning(s)"
((errors == 0))
