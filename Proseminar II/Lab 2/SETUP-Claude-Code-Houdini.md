# Setting up Claude Code to drive Houdini — school PC

Prep for scripting the Part 2 node network. Windows paths throughout; macOS equivalents noted where they differ.

**There is no Claude Code extension for Houdini.** Houdini isn't a supported IDE. What you're setting up is
Claude Code running in a terminal, writing Python files, plus a one-click way to fire that Python into a live
Houdini session. That's the whole trick.

---

## 1. Get the files onto the machine

```
git clone https://github.com/nikkinaq-a11y/Current-Classes.git
```

Everything you need is in `Proseminar II/Lab 2/`.

If you already cloned before the lab folders existed, `git pull` instead.

---

## 2. Install Claude Code

Check [claude.com/claude-code](https://claude.com/claude-code) for the current installer. If Node is already
on the machine, `npm install -g @anthropic-ai/claude-code` is the usual route. You'll sign in once.

If the school PC has VS Code, install the VS Code extension too — it gives you a side-by-side view while
Houdini runs on the other monitor. Not required.

Lab machines often block global npm installs. If it fails, the native installer from the site above doesn't
need admin rights.

---

## 3. Find hython

Houdini ships it; it just isn't on PATH.

**Windows:** `C:\Program Files\Side Effects Software\Houdini 20.5.xxx\bin\hython.exe`
**macOS:** `/Applications/Houdini/Houdini20.5.xxx/Frameworks/Houdini.framework/Versions/Current/Resources/bin/hython`

Substitute your actual build number. Verify it runs:

```
"C:\Program Files\Side Effects Software\Houdini 20.5.xxx\bin\hython.exe" -c "import hou; print(hou.applicationVersionString())"
```

A version number means everything downstream works. **Do this before you need it** — it's the one step that
can fail outright on a non-commercial license.

Optionally add the `bin` folder to PATH so you can just type `hython`.

---

## 4. Decide where Claude Code runs

Run it **from the Houdini project folder** — the one containing `geo/`, `tex/`, `render/`, `hda/`. That's
what `$JOB` points at, and it's where the scripts and the scene file live.

The git repo is transport only. Copy what you need out of it:

1. Copy `CLAUDE.md.houdini-template` into the Houdini project root and **rename it `CLAUDE.md`**. Claude Code
   reads that automatically at session start, so you don't re-explain the project every time.
2. Copy `TribbleA1.fbx` into `$JOB/geo/`.

---

## 5. Make the shelf button — this is the step that matters

Without this you're doing headless runs and reopening files to see results, which is slow enough that
scripting stops being worth the trouble. With it, the loop is: Claude edits the script, you click once, the
network rebuilds in front of you.

In Houdini: right-click a shelf tab → **New Tool**. Name it something like "Rebuild Hybrid." In its
**Script** tab, put:

```python
exec(open(r'C:\path\to\your\project\build_hybrid.py').read())
```

Keep the `r` before the quote — it stops Windows backslashes being read as escape characters. This is the
single most common way this step fails.

Click Accept. The button now re-runs whatever that file currently contains.

Two reasons this beats `hython`: you see results immediately in the viewport, and you avoid a second license
checkout. Under a non-commercial license, running `hython` while the GUI is open can contend for the same
license — the shelf button sidesteps that entirely.

---

## 6. Generate a node-name reference

Houdini's internal node names don't match the Tab menu labels, and guessing them is the main source of
wasted back-and-forth. Dump the real ones once, early, so Claude works from fact instead of memory. In
Houdini's Python Shell (`Windows > Python Shell`):

```python
import hou
for t in sorted(hou.sopNodeTypeCategory().nodeTypes()):
    if any(k in t.lower() for k in ('vdb', 'poly', 'fuse', 'clip', 'blast', 'attrib')):
        print(t)
```

Save the output next to your script as `node-types.txt`.

---

## 7. Still to gather

- **`Simplified Tribbles Project.hipnc`** from Canvas — not in the repo, you have to download it.
- **An HDRI** from [polyhaven.com/hdris](https://polyhaven.com/hdris) into `$JOB/tex/`. 2K EXR is fine.

---

## First session checklist

1. `hython -c "import hou; print(hou.applicationVersionString())"` prints a version
2. `CLAUDE.md` sits in the Houdini project root
3. `TribbleA1.fbx` is in `$JOB/geo/`
4. Shelf button exists and runs without error (point it at an empty file first to test)
5. `node-types.txt` generated
6. Start Claude Code from the project folder

Then ask it for the Part 2 scaffolding script. It'll build the chain up through Convert VDB and stop — the
paint and positioning steps need you at the viewport, and `CLAUDE.md` tells it not to try faking them.

---

## What this does and doesn't buy you

Scriptable, and genuinely quick: the whole node chain — two File nodes, VDB from Polygons, Transforms,
VDB Combine on SDF Union, the dilate/erode Reshape pair, Convert VDB, Fuse, PolyFill, Clip, the output Null.
Wired and laid out. Roughly 70 lines.

Not scriptable, and it's most of the creative work: Attribute Paint is brush strokes with no text
representation; positioning one scan on another is done by dragging a handle and looking; and every
"stop when it looks right" value needs eyes on the viewport.

For one hybrid this is probably slower than just doing it by hand. It pays off if you want many variants
for the optional second hybrid, or if you'd rather skip the tedious wiring and keep the judgment calls.
