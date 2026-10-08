# Lab 3 — Worldbuilding with Gaussian Splats (Proseminar II, Duke)

Full instructions: `ASSIGNMENT-BRIEF.md`. This file tracks progress and how the folder works.

## The four scenes

| # | Scene | Tool | Extra | Deliverable | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Fish out of Water | LichtFeld Studio (self-scan, photos in `Lab3C/`) | Lab 2 "fish" model placed inside | Screenshots → Canvas | Splat done; model placement and screenshots still to do |
| 2 | Personal Archive | Marble, from a family photo | Spatial audio from BBC SFX / Freesound | Deployed link | ? |
| 3 | Fantasy | Marble, from a text prompt | **Foley you recorded yourself** | Deployed link | ? |
| 4 | Hand-Drawn | Marble, from a scan of a drawing | (audio optional) | Deployed link | ? |

Marble zips live in `marble-exports/` (originally named lab3 A–D = scenes 1–4):

| Zip | Splat(s) | Scene folder |
| --- | --- | --- |
| `Lab 3 - Fish out of Water.zip` | droid + rain-kissed Main Street | `scenes/fish-out-of-water/` — brief wants screenshots; also deploying with audio (extra) |
| `Lab 3 - Personal Archive (first version).zip` | lab3-b (52 MB) | unused |
| `Lab 3 - Personal Archive.zip` | edited autumn mountain valley | `scenes/personal-archive/` — audio added, deployed to Dokploy app Lab3B |
| `Lab 3 - Fantasy.zip` | lab3-c | `scenes/fantasy/` — 2 Freesound medieval tracks added; brief wants self-recorded foley |
| `Lab 3 - Hand-Drawn Scene.zip` | rustic garden path painting | `scenes/hand-drawn/` — no audio; `deploy/hand-drawn.zip` built |

Marble Studio exports place the splat ~5 up / ~10 forward of the viewer camera (Studio's own camera spot), so
the viewer starts far outside the scene. Fix: set each splat's `transform.translation` to `[0, 0, 0]` in
`scene.json` before adding audio. `new-scene.sh` now does this on zip import (shifting all splats together).
Scenes take several seconds to load and show black until then; that is not a wrong camera start.

## Folder layout

- `marble-exports/` — the original Marble `.zip` exports (sources for `new-scene.sh`)
- `marble-audio-template/` — git clone of github.com/dahvcduke/marble-audio-template (`git pull` inside it for updates)
- `scenes/<name>/` — one unzipped Marble export per scene, with the template's `index.html` swapped in.
  Marble's own page is kept as `index.marble-original.html` and left out of deploys.
- `deploy/<name>.zip` — upload these to Dokploy (General → Drop, Build Type: Static)

## Workflow per Marble scene

```sh
./new-scene.sh ~/Downloads/project-<x>.zip personal-archive   # unzip + swap index.html
./serve.sh personal-archive                                   # then Chrome: http://127.0.0.1:8000/?edit=1
#   Connect project folder → drop audio → position orbs → wait for "Saved"
./deploy-zip.sh personal-archive                              # → deploy/personal-archive.zip
```

Each scene's `index.html` is patched (2026-10-07) so the published site hides the audio panel and orbs and starts
all audio on the first click or key press; `?edit=1` on 127.0.0.1 is unchanged. The template clone is not patched,
so a scene made with `new-scene.sh` needs the same change.

Audio limits: 10 sources per scene, 5 MB per file. Editing only works in desktop Chrome/Edge on 127.0.0.1.
Reconnect the folder after every reload.

## Deploy (once)

VM: `nikki-splats.colab.duke.edu` (vcm-55325, 67.159.76.228, Ubuntu 26.04), SSH as `vcm`.
Dokploy v0.30.8 installed 2026-10-04; dashboard at http://67.159.76.228:3000.
Install gotcha: Dokploy's script pins Docker 28.5.0, which doesn't exist for Ubuntu 26.04. Fix was
`apt-mark unhold docker-ce docker-ce-cli docker-ce-rootless-extras`, install current docker-ce (29.x)
from Docker's apt repo, then rerun the installer (it skips Docker when present).
Next: Dokploy settings → domain + Let's Encrypt.
Then for each scene, create one Application, upload the zip, deploy, add a domain on port 80 with HTTPS.
Store Dokploy credentials outside this repo.

## Live links (verified 2026-10-05, every file matches the local deploy zip)

- 2 Personal Archive (Lab3B): https://lab-3-lab3b-personal-archive-62bcyn-5a01f5-67-159-76-228.sslip.io
- 3 Fantasy (Lab3C): https://lab-3-lab3c-fantasy-obtceu-b6bd51-67-159-76-228.sslip.io
- 4 Hand-Drawn (Lab3D): https://lab-3-lab3d-handdrawn-gblsjs-fa1c2d-67-159-76-228.sslip.io

Each scene needs its own Dokploy Application — uploading to an existing app replaces its contents.
