# Local application configs

Place optional preference files here to restore during setup. These files are **not committed** (see repo `.gitignore`).

| File | Restored by |
|------|-------------|
| `eu.exelban.Stats.plist` | `setup-utils.bash` → `~/Library/Preferences/` |
| `moom-classic/com.manytricks.Moom.plist` | `setup-office-productivity.bash` → `~/Library/Preferences/` |

Notes:
- `moom-classic/com.manytricks.moom` is a local Many Tricks receipt / license artifact. It is copied for backup convenience but is **not** restored by scripts.

Copy from an existing Mac, for example:

```bash
cp ~/Library/Preferences/eu.exelban.Stats.plist scripts/applications/configs/
```
