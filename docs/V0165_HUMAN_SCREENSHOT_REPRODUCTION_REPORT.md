# v0.165 Human Screenshot Reproduction Report

Status: `REPRODUCED_BEFORE_REPAIR`

## Windows App Review

Computer Use was used against the packaged Windows Godot app. The default procedural app launched cleanly, then the Worker + Barracks + Militia launcher was used for the M3 posture.

The concern reproduced in two places before repair:

- Title/briefing backdrop: imported humanoid billboards appeared very narrow behind the overlay.
- Playable battle view: Worker and Militia imported billboards were visible, but horizontally compressed against the procedural scene.

## Diagnosis

The source images and metadata were technically valid. The real defect was runtime quad aspect:

- Worker source: 1024 x 1024, alpha bounds 482 x 942, pivot bottom-center.
- Militia source: 1024 x 1024, alpha bounds 386 x 942, pivot bottom-center.
- Worker runtime quad before repair: `0.55 x 0.74`.
- Militia runtime quad before repair: `0.50 x 0.68`.

That means square sources were displayed on non-square quads, causing visible horizontal compression.

## Non-Defects

The following screenshot concerns were investigated and treated as intentional or unproven:

- Procedural terrain, structures, health bars, selection rings, objective markers, and HUD/minimap elements remain visible by design.
- Barracks material is intentionally restrained and still sits on procedural structure geometry.
- No evidence showed accidental procedural child silhouette parts under loaded Worker or Militia billboard roots after instrumentation.
- The view remains an early diagnostic Godot player slice, not a finished art direction pass.

## Repair Result

The runtime now preserves the square source aspect for Worker and Militia billboard quads. Final validation captures and Computer Use review are recorded under `artifacts/desktop-spikes/godot-salto/v0165/`.
