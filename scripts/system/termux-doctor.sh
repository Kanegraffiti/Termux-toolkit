#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/toolkit-core.sh"

usage() { echo "Usage: termux-doctor"; }
[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }

warnings=0 failures=0
pass() { echo "PASS  $*"; }
warn() { echo "WARN  $*"; warnings=$((warnings + 1)); }
fail() { echo "FAIL  $*"; failures=$((failures + 1)); }

echo "Termux Toolkit health check"
[[ ${PREFIX:-} == */com.termux/* ]] && pass "Termux PREFIX detected" || fail "This does not appear to be Termux"
[[ -d "$HOME/storage/shared" ]] && pass "Shared storage is available" || warn "Run termux-setup-storage"
[[ ":$PATH:" == *":${PREFIX:-/missing}/bin:"* ]] && pass "Termux bin directory is on PATH" || fail "Termux bin is missing from PATH"
for command in bash git python ttk; do
  command -v "$command" >/dev/null 2>&1 && pass "$command is available" || warn "$command is not installed or not on PATH"
done
[[ -f "$HOME/.termux-toolkit/source-dir" ]] && pass "Toolkit update source is recorded" || warn "Toolkit update source is missing"
broken=0
if [[ -d "${PREFIX:-/missing}/bin" ]]; then
  while IFS= read -r link; do
    [[ -e $link ]] || { echo "WARN  Broken toolkit launcher: $link"; broken=$((broken + 1)); }
  done < <(find "${PREFIX:-/missing}/bin" -maxdepth 1 -type l -lname "$HOME/.termux-toolkit/bin/*" 2>/dev/null)
fi
warnings=$((warnings + broken))
available="$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')"
if [[ $available =~ ^[0-9]+$ && $available -lt 524288 ]]; then
  warn "Less than 512 MB of free storage remains"
else
  pass "Storage has at least 512 MB free"
fi
echo "Summary: $failures failure(s), $warnings warning(s)"
((failures == 0))
