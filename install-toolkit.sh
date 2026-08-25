#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# install-toolkit - install Termux CLI Toolkit
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.termux-toolkit"
BIN="$TARGET/bin"
MAN="$TARGET/man"
: "${PREFIX:?This installer must be run inside Termux (PREFIX is not set)}"
PREFIX_BIN="$PREFIX/bin"

mkdir -p "$TARGET" "$TARGET/plugins" "$TARGET/logs" "$PREFIX_BIN"

# Remove launchers created by an older toolkit installation.
if [[ -d "$BIN" ]]; then
  for old_launcher in "$BIN"/*; do
    [[ -e $old_launcher ]] || continue
    old_link="$PREFIX_BIN/$(basename "$old_launcher")"
    [[ -L $old_link && $(readlink "$old_link") == "$old_launcher" ]] && rm -f "$old_link"
  done
fi

# Replace only toolkit-managed runtime files. User config, plugins and logs stay.
rm -rf "$BIN" "$TARGET/scripts" "$TARGET/man" "$TARGET/tools"
mkdir -p "$BIN"
cp -R "$SOURCE_DIR/scripts" "$TARGET/scripts"
cp -R "$SOURCE_DIR/man" "$TARGET/man"
cp -R "$SOURCE_DIR/tools" "$TARGET/tools"
cp "$SOURCE_DIR/VERSION" "$TARGET/VERSION"
printf '%s\n' "$SOURCE_DIR" > "$TARGET/source-dir"

if [[ ! -f "$TARGET/config" ]]; then
  cat <<'EOF' > "$TARGET/config"
USE_EMOJIS=true
AI_API_ENDPOINT="http://localhost:11434"
DEFAULT_BACKUP_DIR="$HOME/backups"
EOF
fi

create_launcher() {
  local name="$1"
  local command_path="$2"
  local launcher="$BIN/$name"
  cat > "$launcher" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
exec bash "$command_path" "\$@"
EOF
  chmod +x "$launcher"
  ln -sf "$launcher" "$PREFIX_BIN/$name"
}

while IFS= read -r script; do
  name="$(basename "$script")"
  name="${name%.sh}"
  [[ $name == "toolkit-core" || $name == *-common ]] && continue
  create_launcher "$name" "$script"
done < <(find "$TARGET/scripts" -mindepth 2 -maxdepth 2 -type f \
  \( -name '*.sh' -o -name 'mini-man' \) ! -path '*/test/*' | sort)

create_launcher "uninstall-toolkit" "$TARGET/uninstall-toolkit.sh"
cp "$SOURCE_DIR/uninstall-toolkit.sh" "$TARGET/uninstall-toolkit.sh"
chmod +x "$TARGET/uninstall-toolkit.sh"

echo "✅ Installation complete. Run 'ttk help' or 'mini-man' to begin."
