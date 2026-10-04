#!/bin/sh
# Serve a scene for local audio editing. Usage: ./serve.sh autumn-mountain-valley
cd "$(dirname "$0")/scenes/$1" || exit 1
echo "Editor: http://127.0.0.1:8000/?edit=1   (Ctrl+C to stop)"
python3 -m http.server 8000 --bind 127.0.0.1
