# Local application configs

Place optional preference files here to restore during setup. These files are **not committed** (see repo `.gitignore`).

| File | Restored by |
|------|-------------|
| `eu.exelban.Stats.plist` | `setup-utils.bash` → `~/Library/Preferences/` |
| `moom-classic/com.manytricks.Moom.plist` | `setup-utils.bash` → `~/Library/Preferences/` |
| `hidden-bar/com.dwarvesv.minimalbar.plist` | `setup-utils.bash` → `~/Library/Containers/com.dwarvesv.minimalbar/Data/Library/Preferences/` (sandboxed app) |

Notes:
- `moom-classic/com.manytricks.moom` is a local Many Tricks receipt / license artifact. It is copied for backup convenience but is **not** restored by scripts.
- Hidden Bar is sandboxed. Copy prefs from the container path, not `~/Library/Preferences/`:

```bash
cp ~/Library/Containers/com.dwarvesv.minimalbar/Data/Library/Preferences/com.dwarvesv.minimalbar.plist \
  scripts/applications/configs/hidden-bar/
```

Copy from an existing Mac, for example:

```bash
cp ~/Library/Preferences/eu.exelban.Stats.plist scripts/applications/configs/
```
