#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export PREFIX="$TEST_ROOT/prefix"
mkdir -p "$HOME" "$PREFIX/bin"
export PATH="$PREFIX/bin:$PATH"

# Minimal stand-in for Termux's package command during the Linux smoke test.
cat > "$PREFIX/bin/pkg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$PREFIX/bin/pkg"

bash "$REPO_ROOT/install-toolkit.sh"

[[ -x "$PREFIX/bin/ttk" ]]
[[ -x "$PREFIX/bin/mini-man" ]]
[[ -x "$PREFIX/bin/mini" ]]
[[ -x "$PREFIX/bin/pkg-toolkit" ]]
[[ -x "$PREFIX/bin/site-open" ]]
[[ ! -e "$PREFIX/bin/website-common" ]]
[[ -f "$HOME/.termux-toolkit/scripts/security/security-common.sh" ]]
[[ ! -e "$HOME/.bashrc" ]]

help_output=$(bash "$PREFIX/bin/ttk" help)
grep -q 'ttk man \[category\] \[tool\]' <<< "$help_output"
mini_help=$(bash "$PREFIX/bin/mini-man" --help)
grep -q 'Usage:' <<< "$mini_help"
manuals=$(bash "$PREFIX/bin/mini" man)
grep -q 'Available manuals:' <<< "$manuals"
package_list=$(bash "$PREFIX/bin/pkg-toolkit" --list)
grep -q 'dev:' <<< "$package_list"
scan_help=$(bash "$PREFIX/bin/antivirus-scan" --help)
grep -q 'Usage:' <<< "$scan_help"
tool_list=$(bash "$PREFIX/bin/ttk" list)
grep -qx 'move-files' <<< "$tool_list"
bash "$PREFIX/bin/ttk" has move-files
! bash "$PREFIX/bin/ttk" has missing-tool
[[ $(bash "$PREFIX/bin/ttk" root) == "$HOME/.termux-toolkit" ]]
[[ $(bash "$PREFIX/bin/ttk" version) == "v1.0-alpha" ]]
run_help=$(bash "$PREFIX/bin/ttk" run antivirus-scan --help)
grep -q 'Usage:' <<< "$run_help"

# Reinstallation should remain idempotent and preserve user-owned data.
printf '%s\n' 'custom=true' > "$HOME/.termux-toolkit/config"
bash "$REPO_ROOT/install-toolkit.sh"
grep -qx 'custom=true' "$HOME/.termux-toolkit/config"

bash "$PREFIX/bin/uninstall-toolkit" --yes
[[ ! -e "$HOME/.termux-toolkit" ]]
[[ ! -e "$PREFIX/bin/ttk" ]]

echo "Install smoke test passed"
