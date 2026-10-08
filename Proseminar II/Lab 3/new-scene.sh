#!/bin/sh
# Turn a Marble export into scenes/<name> with the spatial-audio index.html swapped in.
# Accepts either a full Marble zip export or a bare .spz download.
# Usage: ./new-scene.sh ~/Downloads/project-whatever.zip personal-archive
#        ./new-scene.sh ~/Downloads/lab3-b.spz personal-archive
set -e
SRC="$1"; NAME="$2"
[ -f "$SRC" ] && [ -n "$NAME" ] || { echo "usage: $0 <export.zip|splat.spz> <scene-name>"; exit 1; }
LAB="$(cd "$(dirname "$0")" && pwd)"
DEST="$LAB/scenes/$NAME"
mkdir -p "$DEST"
case "$SRC" in
  *.zip)
    unzip -oq "$SRC" -d "$DEST"
    [ -f "$DEST/index.marble-original.html" ] || mv "$DEST/index.html" "$DEST/index.marble-original.html"
    # Studio exports offset the scene by Studio's own camera spot (~5 up, ~10 forward), so the
    # viewer starts outside it. Shift everything so the first splat sits at the origin; other
    # splats and meshes keep their placement relative to it. Rotation and scale stay as exported.
    python3 - "$DEST/scene.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
items = d.get("splats", []) + d.get("meshes", [])
if items:
    base = items[0].get("transform", {}).get("translation", [0, 0, 0])
    for it in items:
        t = it.setdefault("transform", {}).get("translation", [0, 0, 0])
        it["transform"]["translation"] = [round(a - b, 6) for a, b in zip(t, base)]
json.dump(d, open(p, "w"), indent=2)
PY
    ;;
  *.spz)
    SPZ="$(basename "$SRC")"
    cp "$SRC" "$DEST/$SPZ"
    # Renderer comes from any earlier full export; Marble zips all ship the same file.
    cp "$(ls "$LAB"/scenes/*/spark.module.min.js | head -1)" "$DEST/"
    # Bare .spz downloads need a 180° turn about Y (upright, still facing the camera); zip exports use 180° about X.
    [ -f "$DEST/scene.json" ] || cat > "$DEST/scene.json" <<JSON
{
  "splats": [
    {
      "filename": "$SPZ",
      "transform": {
        "translation": [0, 0, 0],
        "quaternion": [0, 1, 0, 0],
        "scale": 1
      }
    }
  ]
}
JSON
    ;;
  *) echo "expected a .zip or .spz"; exit 1 ;;
esac
cp "$LAB/marble-audio-template/index.html" "$DEST/index.html"
echo "Ready: $DEST"
echo "Edit audio:  ./serve.sh $NAME   then open http://127.0.0.1:8000/?edit=1 in Chrome"
