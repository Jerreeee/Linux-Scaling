# KeyboardRemap

Fixes missing key mappings on Belgian AZERTY keyboards. Platform-specific implementations in `Windows/` and `X11/` subfolders.

## What it remaps

| Combo | Output | Notes |
|-------|--------|-------|
| AltGr + `,` | `<` | Missing by default on Belgian AZERTY |
| AltGr + `;` | `>` | Missing by default on Belgian AZERTY |
| `²` key | `~` | Replaces rarely-used ² (left of 1) |

## Windows (`Windows/KeyboardRemap.ahk`)

AutoHotkey v2.0 script. Uses `SendText` (direct Unicode injection) instead of clipboard to preserve AltGr state across consecutive combos. Uses VK codes (`vkBE`, `vkBF`) for portability across keyboard layouts.

**Running:** Double-click `KeyboardRemap.ahk` (requires AutoHotkey v2.0), or add a shortcut to `shell:startup` for auto-start.

### Diagnosing key issues (Windows)

```bash
pip install keyboard
python key_test.py   # interactive — shows scan codes, VK codes, output chars
```

## X11 (`X11/.Xmodmap`)

xmodmap config that remaps keycodes 58, 59, and 49 at the appropriate modifier levels.

**Install:** `cd X11 && ./install.sh` — copies `.Xmodmap` to `~/.Xmodmap` and loads it. Auto-loads on future X11 logins.

### Diagnosing key issues (X11)

```bash
xmodmap -pke   # dump current keymap
xev            # interactive key event viewer
```
