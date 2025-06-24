#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# install-toolkit - install Termux CLI Toolkit
TARGET="$HOME/.termux-toolkit"
BIN="$TARGET/bin"
MAN="$TARGET/man"

mkdir -p "$BIN" "$MAN"

cp scripts/*/*.sh "$BIN" 2>/dev/null || true
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
  name=${name%.sh}
  if ! grep -q "alias $name=" "$SHELL_RC" 2>/dev/null; then
    echo "alias $name=\"$script\"" >> "$SHELL_RC"
  fi
done

echo "✅ Installation complete. Restart your shell or run 'source $SHELL_RC'"
