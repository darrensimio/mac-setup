# mac-setup

Personal macOS setup scripts for installing apps and applying system preferences on a new Mac (or when re-applying your configuration). Application install scripts are idempotent and safe to re-run. Enterprise MDM or device management tooling is not included.

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

Homebrew and Git depend on Apple’s **Command Line Tools** (CLT). Check whether they are already installed:

```bash
xcode-select -p
git --version
```

If `xcode-select -p` prints `/Library/Developer/CommandLineTools` (or a path under `/Applications/Xcode.app/...`) and `git --version` works, skip to [Install Homebrew](#install-homebrew).

Run in **Terminal.app** or **iTerm** (not only inside an IDE terminal — the system dialog may not appear otherwise):

```bash
xcode-select --install
```

1. Wait for the dialog **“The xcode-select command requires the command line developer tools”**.
2. Click **Install** (not **Get Xcode** unless you want the full Xcode app).
3. Accept the license and wait for the download to finish (can take several minutes).
4. Verify:

```bash
xcode-select -p
# Expected: /Library/Developer/CommandLineTools

git --version
clang --version
```

If you see **“Can't install the software because it is not currently available”** or no dialog appears, use **System Settings → General → Software Update** and install **Command Line Tools for Xcode**.

#### Troubleshooting

| Symptom | What to try |
|--------|-------------|
| Dialog never appears | Open **System Settings → General → Software Update** and install “Command Line Tools for Xcode”, or retry `xcode-select --install` from Terminal.app. |
| `xcode-select: error: unable to get active developer directory` | CLT not installed yet — complete the install steps above. |
| Tools installed but wrong path | `sudo xcode-select --switch /Library/Developer/CommandLineTools` |
| Stuck or corrupted install | Remove and reinstall: `sudo rm -rf /Library/Developer/CommandLineTools` then run `xcode-select --install` again. |
| `xcode-select --install` says already installed but `git` fails | Install CLT from Software Update; then run `xcode-select -p` again. |
| After a major macOS upgrade | Open Software Update — Apple often ships a new CLT package for the new OS. |

You do **not** need the full Xcode app from the App Store unless you develop with Xcode itself. CLT alone are enough for this repo.

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

### Git and GitHub

Required before you `git clone` this repository. Git is included with the Xcode Command Line Tools (verify with `git --version`).

**1. Set your commit identity**

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

**2. Authenticate with GitHub (SSH)**

```bash
# Generate a key (press Enter to accept defaults; add a passphrase if you want)
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519

# Start the agent and add the key (macOS)
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Copy the public key, then add it in GitHub → Settings → SSH and GPG keys → New SSH key
pbcopy < ~/.ssh/id_ed25519.pub

# Test the connection
ssh -T git@github.com
```

Clone this repository:

```bash
git clone git@github.com:<your-user>/mac-setup.git
```

### Optional

- **Rosetta** (Apple Silicon, for Intel-only tools): `softwareupdate --install-rosetta --agree-to-license`
- **Full Disk Access** for Terminal or iTerm — some `defaults` changes may need it

### Validate environment

```bash
bash scripts/setup.sh --check
# or
bash scripts/validate-env.bash
```

## Quick start

Clone the repo, complete prerequisites above, then run from the **repository root**. Install applications before configuring the Dock (the dock script expects apps under `/Applications`).

```bash
git clone <your-clone-url>
cd mac-setup

bash scripts/setup.sh --check
bash scripts/setup.sh --include-dock   # fresh Mac: full run including Dock reset
```

Re-run without resetting the Dock:

```bash
bash scripts/setup.sh --skip dock
```

Run individual steps:

```bash
bash scripts/setup.sh --apps-only
bash scripts/setup.sh --os-only --include-dock
bash scripts/setup.sh --dry-run
```

You can still run scripts under `scripts/applications/` and `scripts/os/` directly; skip any you do not need.

## Repository layout

```
scripts/
  setup.sh              # orchestrator (recommended entrypoint)
  validate-env.bash     # prerequisite checks
  lib/
    common.bash         # shared install helpers
  applications/
    setup-office-productivity.bash
    setup-devtools.bash
    setup-terminal.bash
    setup-utils.bash
    configs/            # local preference files (gitignored)
  os/
    setup-dock.bash
    setup-display.bash
    setup-widget.bash
```

## Scripts

Application scripts check for existing installs and skip when already present.

### `scripts/setup.sh`

Runs application then OS scripts in order. **Dock reset is off by default** — pass `--include-dock` or set `MAC_SETUP_APPLY_DOCK=1` on a fresh Mac. See `bash scripts/setup.sh --help`.

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

Installs `mas` via Homebrew when missing (before App Store installs).

**Optional preference restore** — place files under `scripts/applications/configs/` (see [configs/README.md](scripts/applications/configs/README.md)):

- `eu.exelban.Stats.plist` → `~/Library/Preferences/`

### `scripts/os/setup-dock.bash`

Dock and related security settings via `defaults write` (not `dockutil`). **Resets the Dock every time it runs** — use via `setup.sh --include-dock` on a new Mac, or run directly when intentional.

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

| Scripts | Re-run behavior |
|---------|-----------------|
| Application installs | Skip apps/tools already present |
| `setup-display.bash`, `setup-widget.bash` | Re-apply settings (generally safe) |
| `setup-dock.bash` | **Clears and rebuilds Dock** — use `--include-dock` only when you want that |

