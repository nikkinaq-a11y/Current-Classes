#!/bin/sh
# Unzip a Marble export into scenes/<name> and swap in the spatial-audio index.html.
# Usage: ./new-scene.sh ~/Downloads/project-whatever.zip personal-archive
set -e
ZIP="$1"; NAME="$2"
[ -f "$ZIP" ] && [ -n "$NAME" ] || { echo "usage: $0 <export.zip> <scene-name>"; exit 1; }
LAB="$(cd "$(dirname "$0")" && pwd)"
DEST="$LAB/scenes/$NAME"
mkdir -p "$DEST"
unzip -oq "$ZIP" -d "$DEST"
[ -f "$DEST/index.marble-original.html" ] || mv "$DEST/index.html" "$DEST/index.marble-original.html"
cp "$LAB/marble-audio-template/index.html" "$DEST/index.html"
echo "Ready: $DEST"
echo "Edit audio:  cd \"$DEST\" && python3 -m http.server 8000 --bind 127.0.0.1"
echo "             then open http://127.0.0.1:8000/?edit=1 in Chrome"
