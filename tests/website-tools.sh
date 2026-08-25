#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export PREFIX="$TEST_ROOT/prefix"
export PATH="$PREFIX/bin:/usr/bin:/bin:$PATH"
mkdir -p "$HOME" "$PREFIX/bin" "$TEST_ROOT/projects/My Portfolio"
printf '<!doctype html><title>Test</title>\n' > "$TEST_ROOT/projects/My Portfolio/index.html"

cat > "$PREFIX/bin/pkg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$PREFIX/bin/pkg"

bash "$REPO_ROOT/install-toolkit.sh" >/dev/null

matches=$(bash "$PREFIX/bin/project-find" Portfolio --root "$TEST_ROOT/projects")
grep -q 'My Portfolio' <<< "$matches"

info=$(bash "$PREFIX/bin/project-info" "$TEST_ROOT/projects/My Portfolio")
grep -q 'Stack: Static HTML' <<< "$info"

preview=$(bash "$PREFIX/bin/site-open" "$TEST_ROOT/projects/My Portfolio" --dry-run --port 8080)
grep -q 'Detected stack: Static HTML' <<< "$preview"
grep -q 'http.server 8080' <<< "$preview"


python - "$TEST_ROOT/projects/unsafe.zip" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1], "w") as archive:
    archive.writestr("../escape.txt", "unsafe")
PY

if bash "$PREFIX/bin/project-info" "$TEST_ROOT/projects/unsafe.zip" >/dev/null 2>&1; then
  echo "Unsafe ZIP was unexpectedly accepted" >&2
  exit 1
fi
[[ ! -e "$TEST_ROOT/projects/escape.txt" ]]

echo "Website tool tests passed"
