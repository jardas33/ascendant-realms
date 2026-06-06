# v0.147 Worker Billboard Single-Slot Intake Spec

Status: private comparator-only runtime-art intake experiment and human review stop.

## Start State

- Expected start commit: `d82fe5efba6ee8af70bba94d2517023c76e6b558`.
- Branch: `main`.
- v0.146 push run `27075353536` completed successfully.
- v0.146 recommended `HYBRID_3D_WORLD_BILLBOARD_UNITS` as the only approach authorized for this single-slot experiment.
- `ORTHO_3D_MESH` remains fallback comparator only.
- `BILLBOARD_2D_ATLAS` remains deferred comparator only.
- Godot remains provisional and is not finally selected.
- Browser prototype remains preserved.

## Authorized Slot

Slot ID: `worker_billboard_static_v0147`.

Role:

- `free_marches` Worker.
- Builder, camp hand, utility and site-support unit.
- Builds, repairs, and boosts sites.
- Command Hall trains Workers only.

This slot uses the v0.144 decision only as written guidance: T1 is the primary silhouette direction and T2 is the Worker-role companion. No v0.144 reference image is imported, traced, cropped, runtime-loaded, or registered.

## Generated Local Cutout

Exactly one built-in image generation call was used for:

```text
artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/worker_billboard_static_v0147_source_chromakey.png
```

The deterministic matte-to-alpha output is:

```text
artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/worker_billboard_static_v0147.png
```

Both files are ignored local experiment artifacts. They are not reference candidates, production assets, browser assets, package assets, or player-facing Godot assets.

## Tracked Fallback

Clean-checkout reproducibility uses a tracked diagnostic fallback generated from simple original geometric shapes:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json
```

The fallback is not art. It exists only so CI, fresh checkout validation, and comparator smoke can run without the ignored local Worker cutout.

## Comparator Scope

The private comparator tests:

- Hybrid diagnostic fallback baseline.
- Hybrid local external Worker slot, falling back to the tracked diagnostic image if the ignored local cutout is absent.
- Orthographic 3D mesh fallback comparator.
- Tier S, M, and L representative loads.
- Close, normal, zoomed-out, overlap, selection-ring, fallback-comparison, and scale posture captures.
- Scale multipliers `0.90x`, `1.00x`, and `1.10x` using the same single image.

## Commands

```text
npm run godot:worker-billboard:validate
npm run godot:worker-billboard:fallback:reproduce
npm run godot:worker-billboard:benchmark:headed
npm run godot:worker-billboard:capture
```

One-click wrapper:

```text
GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat
```

## Non-Goals

- No existing generated reference candidate import.
- No additional image generation.
- No animation frames, spritesheet, atlas production, texture sheet, model, HUD art, environment art, Aster art, or icon generation.
- No normal Salto player-facing slice mutation.
- No default launcher replacement.
- No browser runtime mutation.
- No runtime manifest, production art-slot registry, production package, save, or stable-ID mutation.
- No final Worker design approval, runtime-art approval, final engine choice, full port, or v0.148 work.
