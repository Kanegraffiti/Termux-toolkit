#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT
export HOME="$TEST_ROOT/home" PREFIX="$TEST_ROOT/prefix"
export PATH="$PREFIX/bin:/usr/bin:/bin:$PATH"
project="$TEST_ROOT/project"
mkdir -p "$HOME" "$PREFIX/bin" "$project/.git"
cat > "$PREFIX/bin/pkg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$PREFIX/bin/pkg"

cat > "$project/package.json" <<'EOF'
{
  "scripts": {"dev": "vite", "build": "vite build"},
  "dependencies": {"vite": "latest"}
}
EOF
touch "$project/package-lock.json"
cat > "$project/.env.example" <<'EOF'
API_URL=
PUBLIC_NAME=
EOF
cat > "$project/.env" <<'EOF'
API_URL=https://example.test
EOF
printf '# Test project\n' > "$project/README.md"

bash "$REPO_ROOT/install-toolkit.sh" >/dev/null

doctor=$(bash "$PREFIX/bin/site-doctor" "$project" || true)
grep -q 'Stack: Node.js' <<< "$doctor"
grep -q 'Production build script exists' <<< "$doctor"

if bash "$PREFIX/bin/site-env-check" "$project" >/dev/null; then
  echo "Missing environment key was not detected" >&2
  exit 1
fi
printf 'PUBLIC_NAME=test\n' >> "$project/.env"
bash "$PREFIX/bin/site-env-check" "$project" >/dev/null

printf 'API_TOKEN=abcdefghijklmnopqrstuvwxyz123456\n' > "$project/config.txt"
if bash "$PREFIX/bin/secret-check" "$project" >/dev/null 2>&1; then
  echo "Probable secret was not detected" >&2
  exit 1
fi
rm -f "$project/config.txt"
bash "$PREFIX/bin/secret-check" "$project" >/dev/null

build_preview=$(bash "$PREFIX/bin/site-build-check" "$project" --dry-run)
grep -q 'npm run build' <<< "$build_preview"

package_preview=$(bash "$PREFIX/bin/client-package" "$project" --dry-run)
grep -q 'Excluded:' <<< "$package_preview"

report="$TEST_ROOT/HANDOFF.md"
bash "$PREFIX/bin/handoff-report" "$project" --output "$report" >/dev/null
grep -q 'Project Handoff' "$report"
grep -q 'npm run build' "$report"

echo "Project rescue tool tests passed"
