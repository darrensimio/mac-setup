# mac-setup

This document installs the minimum required tooling to support a fully declarative macOS setup. Enterprise enrollment, MDM, or device management tooling is intentionally excluded.

---

# 1. System Requirements

- macOS 13 (Ventura) or newer recommended
- Admin access on the machine
- Internet connectivity
- Apple ID signed in (optional, required only for App Store installs via `mas`)

Check macOS version:

```bash
sw_vers
````

---

# 2. Install Xcode Command Line Tools

Required for:

* Git
* Compilers
* Homebrew dependencies

Install:

```bash
xcode-select --install
```

Verify:

```bash
xcode-select -p
```

Expected output:

```
/Library/Developer/CommandLineTools
```

---

# 3. Install Homebrew

Homebrew is the package manager that enables declarative installs via `Brewfile`.

Install:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, add Homebrew to your shell profile:

### Apple Silicon (M1/M2/M3):

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Intel:

```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

Verify:

```bash
brew --version
```

---

# 4. Install Core Bootstrap Dependencies

These tools are required before running your declarative bootstrap.

```bash
brew install git
brew install mas
brew install dockutil
brew install asdf
brew install chezmoi
```

Verify each:

```bash
git --version
mas version
dockutil --version
asdf --version
chezmoi --version
```

---

# 5. Enable Rosetta (Apple Silicon Only)

If running on Apple Silicon and you expect Intel-based tools:

```bash
softwareupdate --install-rosetta --agree-to-license
```

---

# 6. Configure Git (Required for Repo-Based Setup)

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Optional but recommended:

```bash
git config --global init.defaultBranch main
git config --global pull.rebase false
```

---

# 7. Ensure Full Disk Access (Recommended)

Some automation scripts may require it.

System Settings → Privacy & Security → Full Disk Access
Add:

* Terminal
* iTerm (if used)

---

# 8. (Optional) Sign into App Store

Required only if installing App Store apps via `mas`.

Login:

```bash
mas signin your@appleid.com
```

Verify:

```bash
mas account
```

---

# 9. Confirm Environment Readiness

Run this validation block:

```bash
echo "Validating environment..."

command -v xcode-select >/dev/null && echo "✔ Xcode CLI Tools"
command -v brew >/dev/null && echo "✔ Homebrew"
command -v git >/dev/null && echo "✔ Git"
command -v mas >/dev/null && echo "✔ mas"
command -v dockutil >/dev/null && echo "✔ dockutil"
command -v asdf >/dev/null && echo "✔ asdf"
command -v chezmoi >/dev/null && echo "✔ chezmoi"

echo "Environment ready."
```

---

# 10. What Happens Next?

After prerequisites are installed:

1. Clone your macOS IaC repository
2. Run `bootstrap.sh`
3. System config, apps, runtimes, and dotfiles install declaratively

Example:

```bash
git clone https://github.com/your-org/macos-iac.git
cd macos-iac
./bootstrap.sh
```

---

# Minimal Dependency Summary

| Tool            | Purpose                       |
| --------------- | ----------------------------- |
| Xcode CLI Tools | Compiler & build dependencies |
| Homebrew        | Package manager               |
| git             | Version control               |
| mas             | App Store CLI                 |
| dockutil        | Dock configuration            |
| asdf            | Runtime version management    |
| chezmoi         | Dotfile management            |

---

# Idempotency Principle

All tools installed above are:

* Safe to reinstall
* Non-destructive if re-run
* Compatible with declarative reconfiguration