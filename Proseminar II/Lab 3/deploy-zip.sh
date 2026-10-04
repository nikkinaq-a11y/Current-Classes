#!/bin/sh
# Zip a finished scene for Dokploy's Drop upload (files at the zip root, no Marble original page).
# Usage: ./deploy-zip.sh autumn-mountain-valley
set -e
LAB="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$LAB/deploy"
cd "$LAB/scenes/$1"
rm -f "$LAB/deploy/$1.zip"
zip -qr "$LAB/deploy/$1.zip" . -x "index.marble-original.html" -x "README.md" -x ".DS_Store"
echo "Upload: $LAB/deploy/$1.zip"
