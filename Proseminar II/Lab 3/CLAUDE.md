# Lab 3 — Worldbuilding with Gaussian Splats (Proseminar II, Duke)

Full instructions: `ASSIGNMENT-BRIEF.md`. This file tracks progress and how the folder works.

## The four scenes

| # | Scene | Tool | Extra | Deliverable | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Fish out of Water | LichtFeld Studio (self-scan, photos in `Lab3C/`) | Lab 2 "fish" model placed inside | Screenshots → Canvas | Splat done; model placement and screenshots still to do |
| 2 | Personal Archive | Marble, from a family photo | Spatial audio from BBC SFX / Freesound | Deployed link | ? |
| 3 | Fantasy | Marble, from a text prompt | **Foley you recorded yourself** | Deployed link | ? |
| 4 | Hand-Drawn | Marble, from a scan of a drawing | (audio optional) | Deployed link | ? |

`scenes/autumn-mountain-valley/` is a Marble export, not yet assigned to scene 2, 3 or 4.

## Folder layout

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

Audio limits: 10 sources per scene, 5 MB per file. Editing only works in desktop Chrome/Edge on 127.0.0.1.
Reconnect the folder after every reload.

## Deploy (once)

Duke VCM VM (Ubuntu) → `curl -sSL https://dokploy.com/install.sh | sh` → Dokploy settings: domain + Let's Encrypt.
Then for each scene, create one Application, upload the zip, deploy, add a domain on port 80 with HTTPS.
Store Dokploy credentials outside this repo.
