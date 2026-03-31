#!/bin/bash
# Install the Belgian AZERTY key remaps for X11
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$SCRIPT_DIR/.Xmodmap" ~/.Xmodmap
xmodmap ~/.Xmodmap

echo "Installed ~/.Xmodmap and loaded remaps."
echo "It will auto-load on future X11 logins."
