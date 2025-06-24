#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# install-toolkit - install Termux CLI Toolkit
TARGET="$HOME/.termux-toolkit"
BIN="$TARGET/bin"
MAN="$TARGET/man"

mkdir -p "$BIN" "$MAN"

# install core library and default config
cp toolkit-core.sh "$TARGET/"
if [[ ! -f "$TARGET/config" ]]; then
  cat <<'EOF' > "$TARGET/config"
USE_EMOJIS=true
AI_API_ENDPOINT="http://192.168.1.100:8000"
DEFAULT_BACKUP_DIR="$HOME/backups"
EOF
fi
mkdir -p "$TARGET/plugins"

cp scripts/*/*.sh "$BIN" 2>/dev/null || true
cp tools/*.sh "$BIN" 2>/dev/null || true
cp scripts/system/mini-man "$BIN"

cp -r man/* "$MAN" 2>/dev/null || true

chmod +x "$BIN"/*

SHELL_RC="$HOME/.bashrc"
[[ -f $HOME/.zshrc ]] && SHELL_RC="$HOME/.zshrc"

# Backup
if [[ -f $SHELL_RC ]]; then
  cp "$SHELL_RC" "$SHELL_RC.bak.$(date +%s)"
fi

# PATH
if ! grep -q "termux-toolkit/bin" "$SHELL_RC" 2>/dev/null; then
  echo "export PATH=\"$BIN:\$PATH\"" >> "$SHELL_RC"
fi

# aliases
for script in "$BIN"/*; do
  name=$(basename "$script")
  [[ $name == "toolkit-core.sh" ]] && continue
  name=${name%.sh}
  if ! grep -q "alias $name=" "$SHELL_RC" 2>/dev/null; then
    echo "alias $name=\"$script\"" >> "$SHELL_RC"
  fi
done

# plugin aliases
for plugin in "$TARGET/plugins"/*.sh; do
  [[ -f $plugin ]] || continue
  tool=$(grep -m1 '^# @tool' "$plugin" | awk '{print $3}')
  [[ -n $tool ]] || continue
  if ! grep -q "alias $tool=" "$SHELL_RC" 2>/dev/null; then
    echo "alias $tool=\"$plugin\"" >> "$SHELL_RC"
  fi
done

echo "✅ Installation complete. Restart your shell or run 'source $SHELL_RC'"
