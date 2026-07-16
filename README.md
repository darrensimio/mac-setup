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
```

**Sign in to the Mac App Store in the GUI** — there is no working `mas signin` on current macOS. Apple removed the API years ago; recent `mas` releases also dropped the `signin` and `account` commands.

1. Open the **App Store** app (or **System Settings → Apple ID → Media & Purchases**).
2. Sign in with the Apple ID you use for Mac App Store downloads.
3. Confirm `mas` works:

```bash
mas version
mas search slack   # should return results, not an auth error
```

If `mas install` fails with a sign-in or account error, sign out and back in via the App Store app, then retry.

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
```

Update Dock only (applies the Dock layout + related settings):

```bash
bash scripts/setup.sh --os-only --skip display --skip widget --include-dock
```

Check current Dock vs desired (no changes):

```bash
bash scripts/setup.sh --dock-check
```

See what is installed and which configs match the repo (Terraform-style plan):

```bash
bash scripts/setup.sh --plan
```

Check prerequisites:

```bash
bash scripts/setup.sh --check
```

Fresh Mac (full run including Dock reset):

```bash
bash scripts/setup.sh --include-dock
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
  plan.bash             # read-only install + config drift report
  validate-env.bash     # prerequisite checks
  lib/
    common.bash         # shared install helpers
  applications/
    setup-office-productivity.bash
    setup-devtools.bash
    setup-terminal.bash
    setup-utils.bash
    setup-genai.bash
    configs/            # local preference files (gitignored)
  os/
    setup-dock.bash
    setup-display.bash
    setup-mail.bash
    setup-menubar.bash
    setup-widget.bash
```

## Scripts

Application scripts check for existing installs and skip when already present.

### `scripts/setup.sh`

Runs application then OS scripts in order. **Dock reset is off by default** — pass `--include-dock` or set `MAC_SETUP_APPLY_DOCK=1` on a fresh Mac.

**Administrator password:** `setup.sh` asks for your Mac login password **once** at the start (when installing apps or OS settings), then keeps `sudo` credentials refreshed for the whole run. Some Homebrew casks (e.g. Microsoft Teams) use `.pkg` installers that need admin access; without this, macOS would prompt repeatedly.

**Errors:** By default, a failed app install or failed script is logged and the run **continues** with the next package/script. The process exits with code `1` if anything failed. Use `--fail-fast` to stop on the first failure (previous behavior).

**Summary table:** At the end of a run, `setup.sh` prints a table of each app/tool and OS step with status (Installed, Already installed, Failed, Skipped, etc.). Failed items are followed by a **Failure details** section with the full command output. Results are saved to `.mac-setup-last-run.tsv` and `.mac-setup-last-run-errors.log` in the repo root.

See `bash scripts/setup.sh --help`.

**Plan (read-only):** `bash scripts/setup.sh --plan` (or `bash scripts/plan.bash`) prints two tables:

- **Applications** — each package in the repo vs installed on this Mac
- **Configuration** — each optional plist in `scripts/applications/configs/` vs `~/Library/Preferences/` (e.g. Moom installed but plist not applied yet shows `not applied`)
- **OS settings** — scripted `defaults` targets (e.g. Mail **New message sound** = `None`, battery **show percentage**)
- **Dock** — same check as `--dock-check`

Exit code `0` when everything matches; `1` when anything would change on a full setup run.

When stdout is a terminal, status labels are colorized (green = OK, yellow = would change, dim = N/A). Set `NO_COLOR=1` or pipe output to disable colors.

### `scripts/applications/setup-office-productivity.bash`

Work and productivity apps.

| Source | Packages |
|--------|----------|
| Mac App Store (`mas`) | Microsoft Word, Excel, PowerPoint; Windows App; Pages, Numbers, Keynote; Slack; WhatsApp; Telegram |
| Homebrew cask | Microsoft Teams, Microsoft Edge, Proton Mail, Proton Pass, Proton VPN, 1Password, Notion, Google Chrome, Zoom |

Microsoft Teams is installed via Homebrew

iWork (Pages, Numbers, Keynote) use Mac App Store IDs in the `361…` series. Older `409…` IDs are not installable via `mas` on Mac. Latest listings require **macOS 15.6+**; on older macOS, install iWork manually from the App Store (it may offer a compatible older version).
, not the Mac App Store: [App Store ID 1113153706](https://apps.apple.com/us/app/microsoft-teams/id1113153706) is the iOS/iPad app, so `mas install` cannot install the Mac desktop client.


### `scripts/applications/setup-devtools.bash`

Developer tools.

| Source | Packages |
|--------|----------|
| Homebrew cask | Visual Studio Code (symlinks `code` to `~/.local/bin/code`), Cursor, Bruno |
| Homebrew formula | tig, gh, htop, curlie |

### `scripts/applications/setup-genai.bash`

Generative AI desktop clients.

| Source | Packages |
|--------|----------|
| Homebrew cask | ChatGPT, Poe |

```bash
bash scripts/applications/setup-genai.bash
```

Skip with `bash scripts/setup.sh --skip genai`.

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
| Mac App Store (`mas`) | Moom Classic, Caffeinated (paid), Post-it, Hour - World Clock |
| Homebrew cask | Spotify, Hidden Bar, DisplayLink Manager, OneDrive, Google Drive, Jabra Direct, Logitech Options+, Stats |

Installs `mas` via Homebrew when missing (before App Store installs).

**Caffeinated** uses Mac App Store ID `1362171212` (the Homebrew cask `caffeinated` was removed). It is a paid app — sign in to the App Store and get it on your Apple ID once before `mas install` will work.

**Post-it** uses Mac App Store ID `1475777828` (free; requires macOS 13+).

**Hour - World Clock** uses Mac App Store ID `569089415` (free menu bar world clock; requires macOS 11+).

**Logitech Options+** installs via Homebrew cask `logi-options+` (app path: `/Applications/logioptionsplus.app`). A reboot is recommended after first install for drivers to take effect.

**Optional preference restore** — place files under `scripts/applications/configs/` (see [configs/README.md](scripts/applications/configs/README.md)):

- `eu.exelban.Stats.plist` → `~/Library/Preferences/`

### `scripts/os/setup-menubar.bash`

Menu bar / Control Center settings:

- **Battery** → show **percentage** in the menu bar (`BatteryShowPercentage`)
- Keeps the battery item visible in the menu bar (not Control Center only)

```bash
bash scripts/os/setup-menubar.bash
```

Skip with `bash scripts/setup.sh --skip menubar`.

### `scripts/os/setup-mail.bash`

Apple Mail (System Mail.app) preferences:

- **New message sound** → `None`
- **Play sounds for other mail actions** → off (`PlayMailSounds` = false)

Uses `defaults write -app Mail` plus AppleScript to drive **Mail → Settings → General** (needs **Accessibility** for UI automation; **Full Disk Access** helps read/write sandboxed Mail prefs).

Runs as part of `bash scripts/setup.sh --os-only` (skip with `--skip mail`). Mail is quit briefly before writing prefs. On a brand-new Mac, open Mail at least once so its preferences container exists; the script still writes the key for the next launch.

```bash
bash scripts/os/setup-mail.bash
```

### `scripts/os/setup-dock.bash`

Dock and related security settings via `defaults write` (not `dockutil`). **Resets the Dock every time it runs** — use via `setup.sh --include-dock` on a new Mac, or run directly when intentional.

- Clears the dock, then adds: Safari, Google Chrome, Microsoft Edge, ChatGPT, Poe, Spotify, Mail, Proton Mail, Messages, WhatsApp, Telegram, Post-it, Notion, Microsoft Word/Excel/PowerPoint, Jabra Direct, App Store, System Settings, Proton Pass, 1Password, Windows App, iTerm, Visual Studio Code, Cursor
- Dock tile size 24, magnification on (large size 96), Recents hidden
- Bottom-left and bottom-right hot corners: lock screen
- Require password immediately after sleep or screen saver
- Restarts Dock to apply changes

To check the current Dock state (apps + order) without applying changes:

```bash
bash scripts/setup.sh --dock-check
```

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
| Application installs | Skip apps/tools already present; failed installs are retried on the next run |
| `setup-display.bash`, `setup-widget.bash`, `setup-menubar.bash`, `setup-mail.bash` | Re-apply settings (generally safe) |
| `setup-dock.bash` | **Clears and rebuilds Dock** — use `--include-dock` only when you want that |

Failed `mas` or `brew` installs do not stop the rest of the run (unless you pass `--fail-fast` to `setup.sh`).

