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

See the [blog post](https://example.com) for details.

## Installation
```bash
pkg install git -y
git clone <this repo>
cd Termux-toolkit
./install-toolkit.sh
```
Restart your shell or `source ~/.bashrc`.

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
