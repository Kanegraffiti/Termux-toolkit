# Termux CLI Toolkit

Termux CLI Toolkit is a collection of handy command line tools for Android developers using [Termux](https://termux.dev). It bundles common git helpers and system utilities so you can work faster on the go.
The project is currently in **v1.0-alpha**.

## Features
- Safe git push and pull helpers
- Quick alias setup for your own scripts
- Simple manual pages accessible with `mini-man`
- New developer utilities in `mini-man dev`
- Security tools for backups and malware scans in `mini-man security`

![demo](docs/screenshot.png)

### Categories
- 🛠 **files**: `move-files`, `batch-rename`
- 🔒 **security**: `backup-data`, `antivirus-scan`
- 🧑‍💻 **dev**: `newproject`
- 🌐 **network**: `ping-check`, `dns-debug`
- 🌍 **website projects**: `project-find`, `project-info`, `site-open`, `site-status`, `site-stop`

## Installation
```bash
pkg install git -y
git clone https://github.com/Kanegraffiti/Termux-toolkit.git
cd Termux-toolkit
./install-toolkit.sh
```

Termux already includes `$PREFIX/bin` in `PATH`, so the commands are available
immediately. Run `ttk help` or `mini-man` to get started.

Keep the cloned repository if you want `ttk update` to pull and reinstall future
versions. If it is moved or deleted, clone the repository again before updating.

To remove the toolkit, run `uninstall-toolkit`. This deletes toolkit config,
plugins and logs after confirmation.

## Usage
Run `mini-man` to list all tools. Each command has `-h` or `--help`.

The manual browser can be opened in any of these equivalent ways:

```bash
mini-man
mini man
ttk man
```

Use `ttk help` for examples, `ttk man <category> <tool>` to read a manual,
or `ttk list` to print every installed command.

### Integration with other assistants

Other local programs such as Solace should integrate through the stable `ttk`
interface rather than reading toolkit internals directly:

```bash
command -v ttk                 # detect the installation
ttk root                       # locate the installed toolkit
ttk version                    # read its version
ttk list                       # discover available commands
ttk has move-files             # test a capability using the exit status
ttk run move-files --help      # safely invoke a toolkit command
```

This keeps integrations working if the toolkit's internal folders change.

### Open a website project from device storage

`site-open` can find a project folder or ZIP by name, safely extract ZIP files,
identify common web stacks, start the appropriate local development server and
open it in the Android browser:

```bash
project-find "client website"
project-info "client website"
site-open "client website"
site-status
site-stop
```

Supported detection includes static HTML, PHP, Vite, Next.js, Create React App,
Angular, Astro, Nuxt and generic Node.js projects. Unknown project code is not
executed silently: missing JavaScript dependencies require confirmation before
the package manager is run. Use `site-open <name> --dry-run` to inspect the
detected project and launch command without starting anything.

### Security Module
Run `mini-man security` to view commands such as malware scans, backups and network checks.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. Pull requests are welcome!

## Script requirements
Detailed conventions for writing new scripts can be found in
[docs/REQUIREMENTS.md](docs/REQUIREMENTS.md).

## Local testing
Basic test scripts live in `scripts/test`. After installation you can run:
```bash
./scripts/test/test-network.sh
./scripts/test/test-storage-access.sh
```
to verify network and storage permissions. Use `test-script.sh <tool>` to run a
quick sanity check on any toolkit command.
