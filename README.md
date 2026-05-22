# mac-setup

Personal macOS setup scripts for installing apps and applying system preferences on a new Mac (or when re-applying your configuration). Scripts are idempotent and safe to re-run. Enterprise MDM or device management tooling is not included.

**Wiping and reinstalling macOS?** See [docs/reformat-mac.md](docs/reformat-mac.md).

## Prerequisites

- macOS 13 (Ventura) or newer
- Admin access on the machine
- Internet connectivity
- **Xcode Command Line Tools** — required for Homebrew and compilers
- **Homebrew** — used by all application install scripts
- **`mas`** and an **App Store sign-in** — required for Mac App Store installs in `setup-office-productivity.bash` and `setup-utils.bash` (`setup-utils.bash` can install `mas` via Homebrew if it is missing)

Check macOS version:

```bash
sw_vers
```

### Install Xcode Command Line Tools

```bash
xcode-select --install
xcode-select -p   # expect /Library/Developer/CommandLineTools
```

### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add Homebrew to your shell profile:

**Apple Silicon:**

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Intel:**

```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Install mas (Mac App Store CLI)

Required before running scripts that install App Store apps:

```bash
brew install mas
mas signin your@appleid.com   # optional; verify with: mas account
```

### Optional

- **Rosetta** (Apple Silicon, for Intel-only tools): `softwareupdate --install-rosetta --agree-to-license`
- **Git identity** (if cloning this repo): `git config --global user.name` / `user.email`
- **Full Disk Access** for Terminal or iTerm — some `defaults` changes may need it

### Validate environment

```bash
command -v xcode-select >/dev/null && echo "✔ Xcode CLI Tools"
command -v brew >/dev/null && echo "✔ Homebrew"
command -v mas >/dev/null && echo "✔ mas"
```

## Quick start

Clone the repo, complete prerequisites above, then run scripts **from the repository root**. Install applications before configuring the Dock (the dock script expects apps under `/Applications`).

```bash
git clone <your-clone-url>
cd mac-setup

bash scripts/applications/setup-office-productivity.bash
bash scripts/applications/setup-devtools.bash
bash scripts/applications/setup-terminal.bash
bash scripts/applications/setup-utils.bash
bash scripts/os/setup-display.bash
bash scripts/os/setup-dock.bash
bash scripts/os/setup-widget.bash
```

You can run scripts individually or in a different order; skip any you do not need.

## Repository layout

```
scripts/
  applications/
    setup-office-productivity.bash
    setup-devtools.bash
    setup-terminal.bash
    setup-utils.bash
  os/
    setup-dock.bash
    setup-display.bash
    setup-widget.bash
```

## Scripts

Each script checks for existing installs and skips when already present.

### `scripts/applications/setup-office-productivity.bash`

Work and productivity apps.

| Source | Packages |
|--------|----------|
| Mac App Store (`mas`) | Microsoft Word, Excel, PowerPoint, Teams; Windows App; Pages, Numbers, Keynote; Slack; WhatsApp; Telegram |
| Homebrew cask | Microsoft Edge, Proton Mail, Proton Pass, Proton VPN, 1Password, Notion, Google Chrome, Zoom |

### `scripts/applications/setup-devtools.bash`

Developer tools.

| Source | Packages |
|--------|----------|
| Homebrew cask | Visual Studio Code (symlinks `code` to `/usr/local/bin/code`), Bruno |
| Homebrew formula | tig, gh, htop, curlie |

### `scripts/applications/setup-terminal.bash`

Terminal environment.

| Source | Packages |
|--------|----------|
| Homebrew cask | iTerm2 |
| curl install script | Oh My Zsh (unattended, only if `~/.oh-my-zsh` is missing) |

### `scripts/applications/setup-utils.bash`

Utilities and peripheral software.

| Source | Packages |
|--------|----------|
| Mac App Store (`mas`) | Moom Classic |
| Homebrew cask | Spotify, Caffeinated, Hidden Bar, DisplayLink Manager, Stats, Jabra Direct, Logi Options+ |

Also installs `mas` if not already on the system.

**Optional preference restore** (if the file exists under `scripts/applications/configs/`):

- `scripts/applications/configs/eu.exelban.Stats.plist` → `~/Library/Preferences/`

These paths are not committed by default; add them locally if you want restore behavior.

### `scripts/os/setup-dock.bash`

Dock and related security settings via `defaults write` (not `dockutil`).

- Clears the dock, then adds: Safari, Google Chrome, Microsoft Edge, Spotify, Mail, Proton Mail, Messages, WhatsApp, Telegram, Microsoft Word/Excel/PowerPoint, App Store, System Settings, Proton Pass, 1Password, Windows App, iTerm, Visual Studio Code
- Dock tile size 24, magnification on (large size 96), Recents hidden
- Bottom-left and bottom-right hot corners: lock screen
- Require password immediately after sleep or screen saver
- Restarts Dock to apply changes

### `scripts/os/setup-display.bash`

Display scaling via [displayplacer](https://github.com/jakehilbertson/displayplacer) (installed via Homebrew if missing). Resolution is chosen from `sysctl hw.model`:

| Hardware | Resolution |
|----------|------------|
| MacBook Air | 1710×1112 (scaled) |
| MacBook Pro | 1800×1169 (scaled) |
| Other | 1920×1200 (scaled) |

### `scripts/os/setup-widget.bash`

Disables desktop widgets (`com.apple.WindowManager`, `com.apple.widgets`) and restarts widget-related processes.

## Idempotency

All scripts are designed to be non-destructive when re-run: existing apps and tools are detected and skipped rather than reinstalled.
