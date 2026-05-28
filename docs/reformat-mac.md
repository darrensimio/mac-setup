# Reformat an existing Mac

Use this flow when you want a clean macOS install, then apply the [mac-setup](../README.md) scripts on top.

## 1. Back up and sign out

- Back up important data (Time Machine, cloud sync, or manual copy to an external drive).
- Sign out of iCloud, Messages, and any licensed apps that bind to the machine.
- Export or note passwords, SSH keys, API tokens, and license keys you will need again.
- If you use this repo on another machine, push any local dotfile or `configs/` changes to git before erasing.

## 2. Erase the Mac

### Option A — Erase All Content and Settings (simplest on supported Macs)

Supported on macOS Monterey or later on Apple Silicon, and on Intel Macs with Apple T2 Security Chip.

1. **System Settings** → **General** → **Transfer or Reset** → **Erase All Content and Settings**
2. Follow the prompts (admin password, Apple ID sign-out if asked).
3. The Mac restarts into a fresh Setup Assistant.

### Option B — Full erase via Recovery (all Macs)

1. Shut down the Mac.
2. Boot into Recovery:
   - **Apple Silicon:** Hold the power button until “Loading startup options” appears → **Options** → **Continue**
   - **Intel:** Restart and hold **⌘R** (or **⌥⌘R** for internet Recovery)
3. **Disk Utility** → select the internal drive (e.g. “Macintosh HD”) → **Erase** (APFS, GUID partition map) → **Erase Volume Group** if offered
4. Quit Disk Utility → **Reinstall macOS** → follow prompts
5. When installation finishes, the Mac boots into Setup Assistant

## 3. Initial macOS setup

1. Complete Setup Assistant (language, user account, Wi‑Fi, optional Apple ID).
2. Apply system updates: **System Settings** → **General** → **Software Update**
3. Install **Xcode Command Line Tools** when prompted, or run `xcode-select --install`

## 4. Run mac-setup

1. Clone the [mac-setup](../README.md) repository and install [prerequisites](../README.md#prerequisites) (**Homebrew**, **`mas`**, App Store sign-in).
2. From the repository root:

   ```bash
   bash scripts/setup.sh --check
   bash scripts/setup.sh --include-dock
   bash scripts/setup.sh --dock-check
   ```

---

Erasing the disk removes all local data on that volume. Confirm backups before Option A or B.
