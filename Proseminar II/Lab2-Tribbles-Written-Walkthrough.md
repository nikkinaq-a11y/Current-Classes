# Lab 2 — "The Trouble with Tribbles": Written Walkthrough

Condensed from the two tutorial video transcripts (`Prosem - Lab2 - Tutorial pt1.txt`, `Prosem - Lab 2 - Tutorial pt.2.txt`). Node names are exactly what you type after hitting **Tab** in the network editor.

---

## Before you start (both videos)

- **Set your project.** `File > Set Project` → point at your shared Houdini folder (the one with `geo/`, `tex/`, `render/`, `hda/` subfolders). Do this *first*, every session.
- **Save into the project.** `File > Save As` → type `$JOB` in the path bar to jump straight to the project root. Name it something like `tribbles_video.hipnc`.
- **Why it matters:** `$JOB` and `$HIP` are relative paths. If every file reference uses them, you can copy/paste whole node networks between scenes in the same project and nothing breaks. (Part 2 depends on this.)
- **If the UI is too small:** `Edit > Preferences > General UI` → Global UI Scale (instructor bumped 1.5 → 2.0). Requires a Houdini restart.
- **If point markers are too small to see:** hover over the viewport and press **D** → display options → increase point marker size.

---

# PART 1 — Procedural horns on a single object

Goal: scatter points on a surface, give each point random attributes, then copy a procedurally-built horn onto each point so every horn is different.

## 1.1 Base object

1. **Tab → Geometry**, double-click into it.
2. Inside, **Tab → File**. In the file picker, type `$JOB` → `geo/` → pick an OBJ from the provided collection (he used a "gel mask" from the National Museum touch collection / African art collection). **Make sure you pick the `.obj`, not the texture file.**
   - A plain sphere works fine too if you just want to learn the mechanics.
3. **Tab → UV Quickshade** below it → point it at the matching texture map so you can see the object textured.

## 1.2 Match Size (optional but useful)

4. **Tab → Match Size**. This centers the object at origin by default.
   - Set **Justify Y = Min** to sit the object on top of the grid.
   - "Scale to fit" lets you match another object's bounding box. Non-uniform scale + a single axis lets you stretch on Y only.
5. Procedural trick shown: to always keep an object sitting on top of a box, right-click the box's size parameter → **Copy Parameter**, then right-click the transform's Y → **Paste Relative Reference**, and append `/2`. Now changing the box size auto-moves the object by half its height.

## 1.3 Paint where the horns go

6. From Match Size, **Tab → Attribute Paint**. Turn on its render flag.
7. Hover in the viewport and press **Enter** to enter the paint tool.
   - **Ctrl + Shift + LMB-drag** resizes the brush.
   - Paint the two regions where you want horns. The brush has falloff — softer areas = fewer scattered points.
8. In the node's parameters, **rename the attribute** from `mask` to `where_horns_go` (float).
9. Check the **Geometry Spreadsheet** → you should see a point attribute `where_horns_go` with values from 0 → 1. This is the whole lesson: everything downstream is driven by attributes you invented.

## 1.4 Scatter

10. **Tab → Scatter**. Rename it `scatter_horns`.
11. Set scatter **by density**, and set the **density attribute = `where_horns_go`**.
12. Dial the point count down to something manageable (default is way too many).

## 1.5 Random per-horn attributes

Put these in a network box (hover in empty space → **Tab → Network Box**) named `horn_variation_attributes`.

Each one is an **Attribute Adjust Float** node wired in series after the scatter. For each: set **Pattern = Random**, set min/max, and **rename the attribute** (the node name *and* the attribute name — when in doubt use underscores).

| Node name | Attribute name | Pattern | Min | Max |
|---|---|---|---|---|
| horn_length | `horn_length` | Random | 0.05 | 0.25 |
| horn_bend | `horn_bend` | Random | 0 | 120 |
| horn_squish | `horn_squish` | Random | 0.5 | 4 |
| horn_squish_pos | `horn_squish_pos` | Random | 0.05 | 0.7 |
| horn_twist | `horn_twist` | Random | −180 | 180 |
| horn_variant | `horn_variant` | Random | 0 | 1 |

**The last one is an Attribute Adjust *Integer*, not Float** — it's the switch between horn type A and B.

> Gotcha from the video: he initially left `horn_variant` on **Constant = 0**, so every horn came out identical. If your variants aren't swapping, check the Geometry Spreadsheet — if `horn_variant` is all zeros, that's the bug. Set it to Random 0→1.

> Don't name an attribute `scale` — that's a reserved/special attribute in Houdini and it will behave unexpectedly.

> Useful shortcuts: hold **Y** and drag across a wire for scissors (disconnect). **Ctrl+C / Ctrl+V** to duplicate a configured node instead of rebuilding it.

## 1.6 Horn appendage #1 (simple)

Network box: `horn_appendage_1`.

13. **Tab → Line**. Increase the **number of points** a lot (more points = smoother bend later). Set length ≈ 0.2.
14. **Tab → Sweep** below it. Radius ≈ 0.01. Turn on **single polygon end caps**.
    - If a parameter field turns green, you accidentally typed an expression — right-click → **Delete Channels**.
15. **Critical:** set the sweep's **direction to (0, 0, 1)** — positive Z. Houdini copies objects along surface normals in the Z direction, so anything you want to stick *out* of a body must be built pointing down +Z.
16. **Tab → Bend** below the sweep.
    - Set a **bend angle** so you can see what it's doing. Up vector stays default.
    - Turn on **taper** so it comes to a point.
    - **Capture length must match the line length.** Copy the Line node's Length parameter → right-click Bend's Capture Length → **Paste Relative Reference** → Enter. Now the bend always spans the whole horn no matter how long it gets.
    - Set **capture direction to Z**.

## 1.7 Horn appendage #2 (lumpy/twisted)

Network box: `horn_appendage_2`.

17. **Tab → Circle**, oriented on the **XY plane**. Divisions ≈ 100 (smooth). Radius ≈ 0.02 × 0.02.
18. **Tab → Attribute Expression**, operating on **N** (normals), **points**. In its presets menu choose **Spherify Normals** — it writes the VEX for you. This makes every point's normal face outward from center.
19. **Tab → Attribute Adjust Float**, attribute name `radial_offset`, class = points.
    - Pattern = **Noise**, noise type = **Simplex**.
    - Use **Minimum + Range Length**: minimum ≈ −0.05, range length ≈ 0.2.
    - Set the noise **element size small** (~0.1) so the wobble is tight and jagged.
20. **Tab → Peak**. Set **Scale by Attribute = `radial_offset`** (instead of `mask`), don't recompute normals. Crank the distance — you'll get a jagged star shape. Pick one you like.
21. **Tab → Attribute Delete** → delete the **point attribute N**. (Cleans up the shading.)
22. If the shape self-intersects: **Tab → Spline Fit** (converts to NURBS, smooths out the crossings). Lower the **tolerance** until it keeps the character but stops crossing itself.
23. **Tab → Resample** to get back to polygons. Use **Maximum Segments** (not max segment length) and dial the count until the outline looks good.
24. **Tab → Line** (this is `line2` — a separate line so horn #2 can be a different length). Lots of points, length ≈ 0.2.
25. **Tab → Sweep**:
    - First input = the resampled cross-section, second input = `line2`. (Hover over the input connectors to confirm which is which.)
    - Set **Cross Section = Second Input** (not "round tube").
    - Direction (0, 0, 1) again. Single polygon end caps on.
26. **Copy/paste the Bend node from horn #1** and wire it here. Change its capture-length reference from `line1` to **`line2`**. Turn on **Twist** this time (try 300 to see the effect).

## 1.8 Switch between the two horns

27. **Tab → Switch**. Input 0 = horn #1 bend, input 1 = horn #2 bend.

## 1.9 The for-each loop (the payoff)

28. **Tab → For-Each Point** (spell it right — "for each point"). This drops a `foreach_begin` / `foreach_end` pair.
29. **Tab → Copy to Points** and place it inside the loop.
    - **Input 0 = the geometry you're copying** (the Switch node).
    - **Input 1 = the points** (from `foreach_begin`).
    - If it looks wrong, you probably wired the two inputs backwards.
30. Feed the scattered points (with all their random attributes) into `foreach_begin`.

## 1.10 Wiring the point attributes into the horn parameters

This is the one bit of expression syntax. In a parameter field on the **Bend** node, type:

```
point("../foreach_begin1", 0, "horn_bend", 0)
```

Breakdown:
- `../` — go up out of this node's context
- `foreach_begin1` — the node to read from (match your actual node name)
- `0` — point number / input index
- `"horn_bend"` — the attribute name
- `0` — the component (0 for a float)

**Watch the closing quote and paren** — in the video the first attempt errored because the string wasn't closed.

Apply it to these fields:

**Bend #1:**
- Bend Angle → `point("../foreach_begin1", 0, "horn_bend", 0)`
- Squish/Taper amount → `...,"horn_squish", 0)`
- Squish pivot/position → `...,"horn_squish_pos", 0)`
- Capture Length → leave as the relative reference to `line1`

**Bend #2:** same three, plus
- Twist → `...,"horn_twist", 0)`

**Switch node:**
- Select Input → `point("../foreach_begin1", 0, "horn_variant", 0)`

You can copy the text of one expression and paste it into the others, just changing the attribute name.

## 1.11 See it on the body

31. **Tab → Merge** at the end. Wire in the loop output and the body (after the UV Quickshade). Only position needs to match.
32. Rename the whole Geometry object something like `mask_with_horns` so you can reference it later from the tribbles template.

**Deliverable for Part 1:** your object with randomized procedural horns. It can stand alone, or you can paste the network into the tribbles template (see 3.2 below).

---

# PART 2 — VDB hybrids, the template scene, and rendering

Goal: cut and fuse two photogrammetry scans into one hybrid body, drop it into the provided tribbles network, set up lighting and camera, and render.

## 2.1 Load two scans

1. New scene, **set project**, save as e.g. `tribbles_VDB.hipnc` in `$JOB`.
2. **Tab → Geometry** → inside → **Tab → File** → `$JOB/geo/` → pick scan A (he used an antelope). Rename the node `antelope`.
3. Second **Tab → File** → scan B (he used a pulley figure). Rename `pulley`.
   - Again: pick the `.obj`, not the texture.
   - Viewport display: "smooth wire shaded" lets you see topology density.

## 2.2 Convert to volumes

4. On each: **Tab → VDB from Polygons**.
   - Default voxel size gives garbage resolution. These are small objects — start at **0.001** (roughly millimeter scale). Smaller = more detail but much heavier.
   - Ctrl+C / Ctrl+V the first one to get identical settings on the second.
5. Add a **Transform** node to each — *before* the VDB conversion, not after.
   > Gotcha: he put transforms downstream of the VDBs and got an error — **VDB transforms must be uniform scale.** Move the transform upstream so you're transforming polygons, and the voxel size stays valid.

## 2.3 Combine

6. **Tab → VDB Combine**, wire both in. Set operation to **SDF Union**.
7. Select a Transform node and press **Enter** in the viewport to get the handle. Move/rotate/scale one scan into position on the other (he made the antelope head into a headdress on the pulley figure).
8. **Tab → Convert VDB** at the end → output type **Polygons**. The union comes out as one clean watertight mesh.
9. Optional: **Tab → VDB Smooth** before the convert. Raise the radius to blend the seam — but it muddies detail fast. "Any smoothing technique, be skeptical of that."

## 2.4 Cutting away parts — method A: paint + blast

10. **Tab → Attribute Paint** on the scan. Ctrl+Shift+LMB to shrink brush. Paint over the region you want gone (he painted the rope on the pulley).
11. Rename the attribute from `mask` to `rope` (or whatever). Confirm in the Geometry Spreadsheet.
12. **Tab → Blast by Attribute** → attribute = `rope`. It deletes any point with a value above zero.
    - **Invert** it to keep *only* the painted region instead — that's how you'd grab just the antelope's head.
    - White = kept, purple = deleted. Go back to the paint node and clean up strays (hold **Ctrl** while painting to erase).

## 2.5 Repairing the hole (required)

**VDBs need a watertight mesh.** Holes → the VDB becomes a total mess.

13. **Tab → Fuse** — small distance, just welds nearby duplicate points. (Photogrammetry scans often have doubled geometry.)
14. **Tab → PolyFill** (older name: PolyCap).
    - If it errors with "odd number of edges," switch **fill mode from Quads to Triangles**.
    - It will look blunt and ugly. That's fine if something covers it.

## 2.6 Cutting away parts — method B: clip

15. **Tab → Clip**, placed *before* the Convert VDB.
16. The direction parameter is the **plane's normal**, not an axis you're keeping. Set it to cut where you want (he zeroed out X and used Z), then use the handle's square to slide the plane into place.
17. "Fill polygons along the clipping plane" often does nothing — uncheck it and instead: **Fuse** (small distance) → **PolyFill**.

## 2.7 Melding two parts that don't touch — the dilate/erode trick

Useful when you want two pieces to look grown together rather than just intersecting.

18. **Tab → VDB Reshape** (mode: **Dilate**). Raise the offset until the two volumes *just touch* — watch the visualizer go blue where they meet.
19. Copy that offset value. **Ctrl+C/V a second VDB Reshape**, set it to **Erode**, and paste the same number in. It shrinks back down, but the two pieces stay fused.
20. If it gets too goopy, raise the voxel size (he went to ~2, then ~5 for a faster/simpler result) or lower the reshape offset. Very fine-detail small objects don't survive this well.

## 2.8 Label the output

21. **Tab → Null** at the end, rename it something like `OUT_pulley_with_antelope`. Nulls do nothing but give you a labeled, stable endpoint.

---

# PART 3 — The "Simplified Tribbles Project.hipnc" template

## 3.1 Getting your body in

1. Open the template. It may open in the **Stage** context — switch to **OBJ** (object level).
2. Read the **sticky notes**. There are three labeled **placeholder** slots for optional scan body parts.
3. Go back to your VDB scene, **select the whole network, Ctrl+C**, then **Ctrl+V** into the template. No importing, no re-linking — because you used `$JOB` relative paths, it just works.
4. Click empty space to deselect, then wire your network into one of the placeholder slots.
5. If your body comes in at the wrong scale, add a **Transform** at the end of your chain and scale it up. The randomization still applies — you've only changed the base scale.

## 3.2 What to go hunting for in the network

The assignment is explicitly a "follow the wires" exercise. Things he points out:

- **Top of the network:** `body_sphere` / body placeholders — swap these out.
- **Appendage slots:** where your Part 1 horn networks plug in. You can wire in a second, different appendage.
- **Material palette:** copper, concrete, desert materials already set up to randomize. You can add more, but you don't have to.
- **Ground grid:** originally something like 1000×1000. He changed it to **250×250**.
- **Mountain node** (noise on the ground): set peak height ≈ **25** with element size ≈ **75** for rolling dunes. Turn the flat grid off.
- **Scatter node for the tribbles:** this is where you control location and density. You can *paint* where they go.
- Turn on render flags as you go and press **Ctrl+Z** freely — breaking things and undoing is the point.

## 3.3 HDRI environment

6. Switch to the **Stage** context. Find the dome/environment light — the default is a `.exr` he supplied.
7. Get a new one from **polyhaven.com → HDRIs** (all free). 2K EXR is fine; 4K gives a sharper background.
8. **Put the file in your project's `tex/` folder, not Downloads.** Then reference it as `$JOB/tex/yourfile.exr`. He is emphatic about this.
9. **To make the HDRI show up in the render (Karma quirk):** on the dome light, change the background setting from **"do nothing" to "set or create"**, and **check "light geometry."** Otherwise you get the lighting but no sky in the image.

## 3.4 Camera

10. At the object level there's a `cam1`.
11. In the **Stage** context: **Tab → Scene Import Camera**, wire it in. Set **Root Object = /obj**, **Objects = cam1**.
12. Back in the object/geo viewport: pick **cam1** from the viewport camera dropdown (top right), then click the **lock/link camera to view** button (it turns red). Now flying the viewport moves the actual camera — much faster than dialing parameters.
13. Frame your shot. Look for where the sun is in the HDRI to get interesting shadows.

## 3.5 Render

14. Camera settings: set **resolution** (1080p).
15. Set the **output picture path**: `$JOB/render/tribbles_04.png` (use the `$JOB` shortcut in the picker).
16. Confirm the render camera is **cam1**.
17. **Tab → USD Render ROP**. Select it → **Render to Disk**.
18. **Save your scene before rendering.** This is the step most likely to crash on a GPU/CPU hiccup.
19. To preview first: in the Stage viewport, switch the viewport from Perspective to the **Karma CPU** renderer. CPU is slower but more stable. Close other Houdini scenes — memory contention makes this crawl.
20. For an animated camera, the frame range is set on the render ROP and it writes one image per frame.

---

## What you turn in

- **3–4 rendered views** of your tribble population. Four is the max — commit to four compositions rather than churning out thirty.
- Part 1's horned object can be turned in standalone or integrated into the template.
- **Optional:** a second photogrammetry model built into a new hybrid.

## Quick gotcha list

| Symptom | Cause |
|---|---|
| All horns identical | `horn_variant` left on Constant 0 — set to Random 0→1 |
| Expression error in Bend | Unclosed quote in the `point()` call |
| Parameter field turns green | Typed an expression by accident — right-click → Delete Channels |
| Horns point the wrong way | Sweep direction isn't (0, 0, 1) |
| Taper doesn't reach a point | Bend capture length isn't referenced to the Line's length |
| VDB comes out a mess | Mesh isn't watertight — Fuse + PolyFill the holes first |
| "Transform must have uniform scale" | Transform node is downstream of the VDB — move it upstream |
| HDRI lights the scene but sky is missing | Dome light background is on "do nothing" — set to "set or create" + check light geometry |
| File links break when pasting between scenes | You used absolute paths instead of `$JOB` / `$HIP` |
