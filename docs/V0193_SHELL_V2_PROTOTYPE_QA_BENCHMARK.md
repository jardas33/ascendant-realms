# v0.193 Presentation-Shell V2 Prototype QA And Benchmark

Status: `PASS_V0193_PRESENTATION_SHELL_V2_QA_BENCHMARK`

This checkpoint implements one isolated opt-in Godot Salto presentation-shell v2 prototype after the v0.192 human-review override. It preserves the legacy shell as comparator/fallback, keeps all prior launchers intact, generates zero images, adds zero imported art slots, does not integrate the wet-granite bridge-riverbank material, and changes no gameplay, pathing, collisions, objectives, AI, saves, stable IDs, production manifests, or browser runtime.

## Implemented Path

The new explicit review path is:

- `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`
- `tools/godot/launchGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/reviewGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/validateGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/captureGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/saltoPresentationShellV2Tool.mjs`

The launcher label is exactly:

```text
Experimental opt-in: Salto presentation shell v2
```

The runtime flag is:

```text
--salto-presentation-shell-v2
```

## Visual QA

The v2 prototype replaces the previous stacked shell posture with a visual-only compositor made from a small number of scoped surfaces:

- 8 local terrain ground patches instead of one full battlefield texture sheet.
- 6 route-following road surfaces using the selected road material only where road geometry exists.
- 3 continuous river channel surfaces.
- 4 bank/edge surfaces that frame the river instead of floating above it.
- 7 bridge deck, abutment, and rail surfaces.
- Simplified site markers and structure masses that reduce duplicate block-like overlays.

During Windows-side review the first broad terrain sheet read too much like a single dark rectangular overlay. That defect was repaired before closeout by replacing it with scoped terrain patches around the friendly staging area, command pocket, mine yard, bridge approaches, ruins pocket, Barracks pocket, and hostile approach.

The prototype is visually stronger than the legacy comparator, but it is still a procedural blockout. It should be reviewed by a human before any v0.194 material integration decision.

## Evidence

Validation and capture evidence is retained under:

- `artifacts/desktop-spikes/godot-salto/v0193/validation/`
- `artifacts/desktop-spikes/godot-salto/v0193/capture/`
- `artifacts/desktop-spikes/godot-salto/v0193/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0193/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0193/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0193/artifact-retention/`

Key review captures:

- `artifacts/desktop-spikes/godot-salto/v0193/capture/shell-v2/screenshots/03_shell_v2_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0193/capture/shell-v2/screenshots/11_bridge_crossing.png`
- `artifacts/desktop-spikes/godot-salto/v0193/capture/legacy-l1-shell/screenshots/03_shell_v2_overview.png`

## Benchmark

The v2 benchmark is compared against the legacy L1 shell comparator.

| Mode | Average FPS | p95 frame ms |
| --- | ---: | ---: |
| Legacy L1 shell | 75.15 | 14.29 |
| Presentation shell v2 | 75.16 | 13.32 |

Benchmark gates:

- FPS ratio: `1.0001` against the required `>= 0.85`.
- p95 worsening: `-6.79%` against the allowed `<= 20%`.

## Boundaries

Confirmed boundaries:

- Zero images generated.
- Zero imported art slots added.
- Existing five character slots preserved.
- Existing ground and road material opt-in paths reused only in the v2 shell.
- Wet-granite bridge-riverbank material remains private-comparator-only.
- Default launcher remains procedural.
- Legacy shell remains available as comparator and fallback.
- Browser runtime remains untouched.
- No gameplay, pathing, collisions, objectives, AI, saves, or stable IDs changed.

