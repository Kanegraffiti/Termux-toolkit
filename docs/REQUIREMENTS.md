# Robust Requirements for Termux Toolkit Scripts

This document outlines the design goals and script conventions for future tools.
It summarizes the guidelines used when creating any script in the Toolkit.

## Script placement and naming

- Place new scripts inside `~/scripts` in a subfolder that matches the tool
  category. Symlink or alias them into `~/.termux-toolkit/bin` using `fixer.sh`.
- Use **kebab-case** for all filenames.

## Script header

Each file should start with the following block:

```bash
#!/data/data/com.termux/files/usr/bin/bash
# Description: short purpose here
# Dependencies: comma,separated,list
# Author: optional
```

## General requirements

- Write portable Bash for Android 10+.
- Include a `require()` check for needed commands.
- Provide `--help` output when no arguments or `-h/--help` is passed.
- Confirm destructive actions and create backups in `~/logs/toolkit.log`.
- Support an `--offline` flag where network use is optional.

## UX expectations

- Use consistent emoji or ASCII markers for info, warnings and errors.
- Colour output: info (blue), success (green), warnings (yellow), errors (red).
- Validate inputs and clearly explain interactive steps.
- Show a basic progress indicator for long running operations.

## Error handling

Use the following pattern for commands that might fail:

```bash
somecmd || { echo "❌ Command failed"; exit 1; }
```

If network access is required, wrap API calls with a simple connectivity check:

```bash
ping -c 1 google.com >/dev/null 2>&1 || echo "⚠️ No Internet"
```

## Logging and backups

Scripts that alter or remove files must create backups such as
`file.20250627_120000.bak` and log their actions to `~/logs/toolkit.log`.

## Offline behaviour

When a remote service is unavailable, a script should fail gracefully and
suggest local alternatives if possible. Passing `--offline` forces local mode.

## Optional debug helper

A future optional plugin, **Bugsy-Lite**, can wrap bashdb or pdb and allow users
to run `bugsy <file>` to debug with a friendly UX. It will be offered as an
extra install batch so the core toolkit stays lightweight.

