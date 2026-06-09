# v0.193 Presentation-Shell V2 Boundary And Rollback

Status: `PASS_V0193_PRESENTATION_SHELL_V2_BOUNDARY`

v0.193 adds one isolated opt-in Godot Salto presentation-shell v2 review path. It does not replace the legacy shell, does not enable art by default, does not wire anything into the browser runtime, and does not add any imported art slot.

## Preserved Comparator And Fallback

The legacy shell remains the comparator and fallback. The v2 flag is isolated behind:

```text
--salto-presentation-shell-v2
```

If the v2 compositor cannot initialize, the runtime records a fallback reason and the legacy shell remains available for review. The v2 path also records status fields for validation:

- `environmentPresentationShellV2Enabled`
- `environmentPresentationShellV2.initialized`
- `environmentPresentationShellV2.legacyShellFallbackAvailable`
- `environmentPresentationShellV2.legacyShellStacked`
- `environmentPresentationShellV2.wetGraniteMaterialIntegrated`
- `environmentPresentationShellV2ArtSlotCount`

## Rollback Plan

To roll back v0.193, remove only the isolated v2 entrypoints and flag handling:

- Remove the three v0.193 root batch files.
- Remove the four v0.193 PowerShell wrappers.
- Remove `tools/godot/saltoPresentationShellV2Tool.mjs`.
- Remove the `--salto-presentation-shell-v2` dispatch and v2 compositor branch from the Godot Salto spike scripts.
- Remove the v0.193 npm scripts from `package.json`.

Do not touch the default procedural launcher, Worker-only launcher, Worker + Barracks launcher, Worker + Barracks + Militia launcher, Worker + Barracks + Militia + Aster launcher, Worker + Barracks + Militia + Aster + Ashen launcher, ground-material launcher, ground+road material launcher, legacy environment-shell launchers, selected local art, selected derivatives, metadata, tracked fallbacks, or retained evidence.

## Non-Goals

v0.193 explicitly does not:

- Generate images.
- Import or integrate the wet-granite bridge-riverbank material.
- Add a new character slot.
- Add a new environment material slot.
- Enable art by default.
- Modify the browser runtime.
- Modify gameplay, pathing, collisions, objectives, AI, saves, stable IDs, or production manifests.
- Start v0.194.

## Evidence

Boundary evidence is retained at:

- `artifacts/desktop-spikes/godot-salto/v0193/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0193/validation/`
- `artifacts/desktop-spikes/godot-salto/v0193/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0193/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0193/artifact-retention/`

