# v0.116 Recommended Engine Spike Order

## Boundary

This is a recommended order for later, explicitly approved spikes. It does not choose an engine and does not start v0.117.

## Recommended Order

1. Godot 4 fixed-camera 2D/2.5D spike.
2. Unity 2D/URP fixed-camera spike.
3. Electron or browser-wrapper packaging control.
4. Unreal only if earlier evidence fails or a future explicit 3D-heavy direction is approved.

## Why Godot First

Godot should be tested first because it has a plausible balance of top-down 2D/2.5D presentation, CLI export support, text-friendly project files, scriptable scenes, and open tooling. The future spike must prove this in practice rather than assuming it:

- Repository-driven setup.
- Generated or text-edited representative scene.
- Manifest-driven content import.
- Scripted asset registration.
- CLI validation, build, benchmark, and Windows export.
- Minimal Emmanuel editor operation.

If Godot requires frequent manual editor dragging, non-reproducible import state, or hidden setup, it should lose heavily on the scorecard.

## Why Unity Second

Unity has strong visual and tooling potential for a modern fixed-camera RTS/RPG, especially polished 2D, 2.5D lighting, particles, and UI. It should be tested second because it may carry more editor metadata, package restore, licensing, and CI complexity. The future Unity spike must prove:

- Project generation and package restore from repo state.
- Scene/prefab creation through scripts or deterministic serialized files.
- Manifest-driven import and validation.
- CLI build/export/benchmark on Windows.
- Clear debugging without routine manual editor work.

## Why Electron Is A Control

Electron or another browser wrapper can prove packaging continuity, but v0.115 shows the browser battle-loop gate is RED and battle-code dominant. A wrapper may package the same problem. Use it only as a later control if explicitly approved.

## Why Unreal Is Deferred

Unreal has a high rendering ceiling but is likely too editor-centric, heavyweight, and binary-heavy for the current AI-first fixed-camera 2D/2.5D representative slice. It should be deferred unless earlier candidates fail or a future approved direction requires its strengths.

## Spike Must Prove AI-First Operation

The future spike must prove Codex can:

- Create the project from repository files.
- Create or modify the Salto fixture scene from scripts or text.
- Import content from manifests.
- Validate stable IDs and save fixtures.
- Build, export, benchmark, and package through scripts.
- Produce scorecard evidence.
- Identify and minimize unavoidable manual editor steps.

Emmanuel's routine role should be practical and lightweight: install required software, launch packaged builds, run simple scripts, record short playtests, approve visual direction, and answer creative questions.

## Visual Ambition To Test

The benchmark should compare whether a candidate can support an original, super-cool 2026-style RTS/RPG mood: a top-down or fixed-camera 2.5D game with strong Barrosan and Ashen silhouettes, atmospheric Salto terrain, modern lighting/VFX, central persistent hero readability, crisp tactical command feedback, and a polished non-mobile UI language.
