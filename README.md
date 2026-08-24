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
