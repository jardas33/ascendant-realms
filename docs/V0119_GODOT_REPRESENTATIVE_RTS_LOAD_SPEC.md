# v0.119 Godot Representative RTS Load Spec

v0.119 replaces the tiny Godot placeholder loop with a deterministic, representative RTS/RPG workload for the existing Salto desktop spike. It remains a bounded benchmark spike only.

## Purpose

- Exercise both Godot placeholder modes with the same repository-driven fixture.
- Measure small, medium, and large RTS-like loads before any full port decision.
- Preserve AI-first, editor-optional workflow through text scripts and command-line validation.
- Keep the browser runtime, saves, stable IDs, runtime art posture, and final engine choice unchanged.

## Workload Tiers

| Tier | Units | Structures | Sites | Lume | Pressure |
| --- | ---: | ---: | ---: | --- | --- |
| S | 14 | 4 | 1 | 2 endpoints, 1 active link | none beyond representative combat commands |
| M | 43 | 4 | 3 | 2 endpoints, 1 active link | one bounded enemy-pressure beat |
| L | 105 | 6 | 5 | 3 endpoints, 2 links | sustained bounded enemy pressure |

Tier S contains the hero, one Worker, six friendly military units, six Ashen units, Command Hall, Barracks, mine, shrine, one capture site, and one Lume link.

Tier M contains the hero, two Workers, twenty friendly military units, twenty Ashen units, the same core structures, three capture sites, two Lume endpoints, one active link, and one enemy-pressure beat.

Tier L contains the hero, four Workers, fifty friendly military units, fifty Ashen units, two player structures, two enemy structures, five capture sites, three Lume endpoints, two links, and sustained movement/combat posture.

## Runtime Contract

- Deterministic seed: `1190119`.
- `linked_ward` damage-taken multiplier remains exactly `0.92`.
- Save fixtures remain read-only evidence.
- No `localStorage` writes are allowed.
- No runtime art is imported.
- No manual Godot editor scene assembly is required.
- Both `2D_PLACEHOLDER` and `2_5D_ORTHOGRAPHIC_PLACEHOLDER` load the same generated gameplay fixture.

## Explicit Non-Goals

- No full Godot port.
- No final Godot selection.
- No campaign system expansion.
- No full hero progression, AI strategy, tech tree, multiplayer, save migration, or runtime art integration.
- No Unity, Unreal, Electron, or v0.120 work.
