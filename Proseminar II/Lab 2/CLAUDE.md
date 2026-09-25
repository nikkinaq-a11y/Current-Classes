# Lab 2 — "The Trouble with Tribbles" (Proseminar II, Duke)

Read this before doing anything in this folder. It is written for a Claude session starting cold on a
machine that has Houdini installed.

## The assignment

Render 3–4 images of a scene populated with procedural creatures ("tribbles"). Two tutorial videos drive it:

- **Part 1** — procedural geometry: scatter points on a surface, give each point random attributes, copy a
  procedurally-built horn onto each one so no two are alike.
- **Part 2** — hybrid bodies: take two photogrammetry-style models, convert them to VDB volumes, cut and
  merge them, convert back to polygons. Then drop the result into an instructor-provided scene file,
  light it with an HDRI, and render.

The instructor's scene file, `Simplified Tribbles Project.hipnc`, comes from Canvas and is **not in this
repo**. It has three labeled placeholder slots where custom bodies get wired in.

## What's in this folder

| File | What it is |
| --- | --- |
| `SETUP-Claude-Code-Houdini.md` | How to set up this machine to script Houdini. **Start here on a new machine.** |
| `Lab2-Tribbles-Written-Walkthrough.md` | Both videos transcribed into step-by-step instructions. The manual path. |
| `Prosem - Lab2 - Tutorial pt1.txt` | Raw transcript, video 1 |
| `Prosem - Lab 2 - Tutorial pt.2.txt` | Raw transcript, video 2 |
| `TribbleA1.fbx` | **The body model.** Blender 5.1.0 export, 2026-09-23, 18.7 MB |
| `Spray Bottle_CleanedUpModel.fbx` | Earlier body attempt, 1.07 MB. Lighter — possible second half of the hybrid |
| `Spray Bottles.blend` / `.blend1` | Blender source for the spray bottle |

## Current state

Part 1 and Part 2 have not been built yet. The walkthrough exists; the Houdini work does not.

The plan is to script the Part 2 node scaffolding in Python and do the hand-work in the UI. See
`SETUP-Claude-Code-Houdini.md` for why that split, and for the shelf-button workflow that makes iteration
fast.

## Models

Primary body: **`TribbleA1.fbx`**. Copy it into `$JOB/geo/` and reference it as `$JOB/geo/TribbleA1.fbx`.

It is a dense mesh. The tutorial starts VDB voxel size at 0.001, which will be slow here — block out at
1–5 and only drop the voxel size for the final conversion. The dilate/erode melding trick degrades on fine
detail, so coarsen the volume before that step rather than after.

The tutorial loaded OBJ files; Houdini's File SOP reads FBX directly. Textures come in separately either way.

## Running Python against Houdini

Two routes. Prefer the second while iterating.

**Headless:** `hython script.py` — builds or edits a `.hipnc` on disk, no viewport.

**Live session (preferred):** a shelf tool button in the running GUI whose script is
`exec(open(r'<abs path>\build_hybrid.py').read())`. Claude edits the file, the user clicks the button, the
network rebuilds in front of them.

Under a non-commercial license (`.hipnc` files), running `hython` while the GUI is open may contend for the
license. If that happens, use the shelf button only.

## Conventions

- All file references use `$JOB/...`, never absolute paths. The lab depends on copy-pasting node networks
  between scenes, which only survives with relative paths.
- Scripts must be **idempotent**: delete and rebuild the subnet rather than appending, so clicking the shelf
  button twice doesn't produce two of everything.
- Attribute names use underscores (`horn_length`, `where_horns_go`).
- Never name an attribute `scale` — reserved in Houdini.
- Expose every tunable value (voxel size, reshape offset, clip position) as a constant at the top of the
  script so it's easy to adjust by hand.

## Node type names

Internal names differ from the Tab-menu labels. **Do not guess.** Introspect with
`hou.sopNodeTypeCategory().nodeTypes()`, or read `node-types.txt` if it has been generated.

Known correct: `file`, `xform` (Transform), `vdbfrompolygons`, `vdbcombine`, `convertvdb`, `vdbsmooth`,
`vdbreshapesdf`, `fuse`, `polyfill`, `clip`, `attribpaint`, `blast`, `null`.

## Part 2 node chain — the scriptable part

```
file (scan A) ──> xform ──> vdbfrompolygons ──┐
                                              ├──> vdbcombine (SDF Union) ──> vdbreshapesdf (dilate)
file (scan B) ──> xform ──> vdbfrompolygons ──┘                                      │
                                                                                     v
                                          null (OUT_*) <── convertvdb <── vdbreshapesdf (erode)
```

- `vdbcombine` operation must be **SDF Union**.
- Transforms go **upstream** of the VDB nodes. VDB transforms require uniform scale, so a non-uniform scale
  downstream errors out. This is the most common failure in this chain.
- Bind the erode offset to the dilate offset with a parameter expression, not a copied number.
- `convertvdb` output type: polygons.

## What NOT to script

These need a human at the viewport. Build the scaffolding and leave them:

- **Attribute Paint.** Brush strokes baked into the node — no text representation exists. If a procedural
  selection is genuinely wanted, **ask first**; it changes the technique the assignment teaches and breaks
  the downstream blast-by-attribute step.
- **Transform values positioning one scan on another.** Found by dragging a handle and looking.
- **Any "stop when it looks right" value** — voxel size, reshape offset, smooth radius, clip plane position.

## Repair after any cut

Cutting a mesh (blast or clip) leaves holes, and VDB conversion requires a watertight mesh. Always follow a
cut with `fuse` (small distance — these meshes have doubled points) then `polyfill`. If polyfill errors with
"odd number of edges," switch its fill mode from quads to triangles.

## A note on scope

The assignment brief explicitly asks the student to explore the provided network and "become as familiar with
how it works as you can." Scripting the graph routes around that. The intended split is: script the tedious
wiring, do the judgment calls by hand. Don't expand scripting into the hand-work without being asked.
