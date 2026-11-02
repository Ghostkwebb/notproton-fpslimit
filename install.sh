#!/usr/bin/env bash
set -euo pipefail

SUPPORT_DIR="$HOME/Library/Application Support/notproton"
PLUGIN_DIR="$SUPPORT_DIR/plugins"

mkdir -p "$SUPPORT_DIR" "$PLUGIN_DIR"

# If run from inside the repo directory:
if [ -f "bin/libfpslimit.dylib" ] && [ -f "fpslimit.conf" ]; then
  cp -f "bin/libfpslimit.dylib" "$SUPPORT_DIR/libfpslimit.dylib"
  cp -f "fpslimit.conf" "$PLUGIN_DIR/fpslimit.conf"
  echo "==> Installed notproton-fpslimit successfully!"
  echo "==> Restart Steam to see the FPS Limiter slider in your game's Compatibility tab."
  exit 0
fi

# If bin/ doesn't exist but fpslimit.m does, compile it:
if [ -f "fpslimit.m" ] && [ -f "fpslimit.conf" ]; then
  make
  cp -f "bin/libfpslimit.dylib" "$SUPPORT_DIR/libfpslimit.dylib"
  cp -f "fpslimit.conf" "$PLUGIN_DIR/fpslimit.conf"
  echo "==> Built and installed notproton-fpslimit successfully!"
  echo "==> Restart Steam to see the FPS Limiter slider in your game's Compatibility tab."
  exit 0
fi

# Otherwise, download latest release from GitHub:
echo "==> Fetching latest release of notproton-fpslimit..."
LATEST_URL="https://github.com/Ghostkwebb/notproton-fpslimit/releases/latest/download/notproton-fpslimit.zip"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "$LATEST_URL" -o "$TMP_DIR/notproton-fpslimit.zip"
unzip -q "$TMP_DIR/notproton-fpslimit.zip" -d "$TMP_DIR"

cp -f "$TMP_DIR/libfpslimit.dylib" "$SUPPORT_DIR/libfpslimit.dylib"
cp -f "$TMP_DIR/fpslimit.conf" "$PLUGIN_DIR/fpslimit.conf"

echo "==> Installed notproton-fpslimit successfully!"
echo "==> Restart Steam to see the FPS Limiter slider in your game's Compatibility tab."
