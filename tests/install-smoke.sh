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
[[ -x "$PREFIX/bin/pkg-toolkit" ]]
[[ -f "$HOME/.termux-toolkit/scripts/security/security-common.sh" ]]
[[ ! -e "$HOME/.bashrc" ]]

bash "$PREFIX/bin/ttk" help | grep -q 'ttk <install|man|status|scan|update>'
bash "$PREFIX/bin/mini-man" --help | grep -q 'Usage:'
bash "$PREFIX/bin/pkg-toolkit" --list | grep -q 'dev:'
bash "$PREFIX/bin/antivirus-scan" --help | grep -q 'Usage:'

# Reinstallation should remain idempotent and preserve user-owned data.
printf '%s\n' 'custom=true' > "$HOME/.termux-toolkit/config"
bash "$REPO_ROOT/install-toolkit.sh"
grep -qx 'custom=true' "$HOME/.termux-toolkit/config"

bash "$PREFIX/bin/uninstall-toolkit" --yes
[[ ! -e "$HOME/.termux-toolkit" ]]
[[ ! -e "$PREFIX/bin/ttk" ]]

echo "Install smoke test passed"
