# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of independent system utility tools, each in its own subdirectory:

- **`Linux-Scaling/`** — Per-app UI scaling system for Linux (Bash scripts)
- **`KeyboardRemap/`** — Belgian AZERTY keyboard remapping for Windows (AutoHotkey v2.0)

Each tool is self-contained with no shared code or build dependencies between them.

---

## Linux-Scaling

A Bash-based system that intercepts app launches and applies toolkit-specific scaling before exec'ing the real binary. Targets GNOME on Ubuntu with fractional scaling enabled.

### Commands

```bash
# Install
cd Linux-Scaling && ./install.sh

# After installation, manage via CLI:
app-scaling setup              # Generate PATH wrappers + patch .desktop files
app-scaling teardown           # Remove all scaling hooks
app-scaling status             # Show current config and state
app-scaling test <app>         # Preview scaling that would apply to an app
app-scaling set <app> <scale>  # Set app's scale factor
app-scaling set-default <tk> <scale>  # Set toolkit default
app-scaling global <pct>       # Change GNOME fractional scaling %
app-scaling global <pct> --relative  # Also adjust per-app factors proportionally
```

### Architecture

Two interception paths feed into a single core launcher (`scaled-launch`):

1. **Terminal launches**: wrapper scripts in `~/.local/bin/scaled/` shadow real binaries via PATH (prepended in `~/.bashrc`)
2. **GUI launches**: patched `.desktop` files in `~/.local/share/applications/` override system ones (freedesktop.org priority)

Both call `scaled-launch`, which reads `~/.config/app-scaling/scales.conf`, detects resolution via `xrandr`, and applies toolkit-specific scaling before `exec`-ing the real binary.

A udev rule (`/etc/udev/rules.d/99-app-scaling-monitor.rules`) triggers `app-scaling-monitor-handler` on monitor hotplug, which auto-adjusts GNOME scaling based on the `[monitors]` section.

### Toolkit Scaling Mechanisms

| Toolkit | Mechanism | Stacks with GNOME scaling? |
|---------|-----------|---------------------------|
| `electron` | `--force-device-scale-factor=X` CLI flag | Yes |
| `qt` | `QT_SCALE_FACTOR=X` env var | Yes |
| `gtk` | `GDK_DPI_SCALE=X` env var (fractional; `GDK_SCALE` is integer-only) | Yes |
| `wine` | `LogPixels` dword in Wine registry (`user.reg` + `system.reg`); base DPI 96 | No — absolute, excluded from `--relative` |

### Config Format (`scales.conf`)

```ini
[monitors]
2160 = 150      # resolution_height = gnome_scaling_%

[defaults]
wine = 3.0      # fallback scale when app entry has empty scale

[apps]
code          = 1.0 / 1.4 : electron   # scale_1080p / scale_4k : toolkit
google-chrome = 1.0 / 1.2 : electron
notepad-plus-plus = : wine             # uses [defaults] wine value
```

Resolution detection: `xrandr` checks active height; ≥2160px uses 4K column, otherwise 1080p column.

`~/.config/app-scaling/scales.override` — if present, `scaled-launch` uses this instead of `scales.conf` (created by `app-scaling global --no-save`).

### Scripts

| Script | Location (source → installed) |
|--------|-------------------------------|
| `scaled-launch` | `scripts/` → `~/.local/bin/` |
| `app-scaling` | `scripts/` → `~/.local/bin/` |
| `generate-wrappers` | `scripts/` → `~/.local/bin/` |
| `patch-desktop-scaling` | `scripts/` → `~/.local/bin/` |
| `app-scaling-monitor-handler` | `scripts/` → `~/.local/bin/` |

All scripts use `set -euo pipefail`. The detailed technical reference is in `Linux-Scaling/CLAUDE.md`.

---

## KeyboardRemap

An AutoHotkey v2.0 script that fixes missing key mappings on Belgian AZERTY keyboards in Windows. Uses `SendText` (direct Unicode injection) instead of clipboard to preserve AltGr state across consecutive combos.

### Running

Double-click `KeyboardRemap.ahk` (requires AutoHotkey v2.0), or add a shortcut to `shell:startup` for auto-start.

### Diagnosing key issues

```bash
pip install keyboard
python KeyboardRemap/key_test.py   # interactive — shows scan codes, VK codes, output chars
```

### What it remaps

```autohotkey
<^>!vkBE → "<"   (AltGr + ,)
<^>!vkBF → ">"   (AltGr + ;)
vkDE     → "~"   (² key)
```

Uses VK codes (`vkBE`, `vkBF`) for portability across keyboard layouts rather than character literals.
