# v0.186 Structure Shell Hierarchy QA And Benchmark

Status: `PASS`

## Scope

v0.186 hardens only the visual-only procedural structure shells in the explicit Godot Salto opt-in environment review path. It uses zero generated images, adds zero art slots, preserves the five-slot character freeze, keeps the selected ground and road materials opt-in only, keeps the default launcher procedural, and leaves browser runtime, gameplay, pathing, collisions, objectives, AI, saves, and stable IDs unchanged.

The v0.186 S1 review path builds on the v0.185 E4 shell-live-QA baseline and adds clearer practical Barrosan structure language: wet granite foundations, timber frames, restrained metal, practical scaffolding, readable roof/foundation trim, contact shadows, and restrained warm-hearth accents.

## Visual QA Findings

Structure hierarchy materially improved in the scoped S1 path:

- Command Hall: no longer reads as a single block stack. It now has a grounded stone base, stepped keep core, timber side posts, low gabled roof forms, a ridge line, door threshold shadow, and a restrained hearth slot.
- West Stone Cut Mine: now has a darker mine mouth, retaining-wall reads, cut-stone tiers, tailings shadow, and a compact crane silhouette.
- Barracks restoration shell: now separates the grounded yard, split wing masses, low roof forms, scaffold posts, brace lines, and an unfinished restoration gap.
- Site structures and defensive props: retain restrained procedural silhouettes without becoming tactical obstructions.
- Characters, rings, minimap, road, river, bridge, and combat posture remain readable in the opt-in S1 captures.

## Repaired During QA

Windows-side capture review found that the first green v0.186 run did not give true close inspections for the Command Hall and mine because the local capture focus was being overwritten by global S1 framing. The repair added v0.186-specific capture actions and a dedicated structure-shell focus helper, then reran the full validation. The final normal and close captures are distinct and reviewable.

## Evidence

- Validation report: `artifacts/desktop-spikes/godot-salto/v0186/validation/structure-shell-hardening-validation-report.json`
- Capture report: `artifacts/desktop-spikes/godot-salto/v0186/capture/structure-shell-hardening-capture-report.json`
- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0186/capture/v0186-structure-shell-hardening-contact-sheet.svg`
- Benchmark scorecard: `artifacts/desktop-spikes/godot-salto/v0186/benchmark/structure-shell-hardening-benchmark-scorecard.md`
- Boundary report: `artifacts/desktop-spikes/godot-salto/v0186/boundary/structure-shell-hardening-boundary-report.json`

Representative S1 captures:

- `artifacts/desktop-spikes/godot-salto/v0186/capture/s1-structure-shell-hardening/screenshots/04_command_hall_normal.png`
- `artifacts/desktop-spikes/godot-salto/v0186/capture/s1-structure-shell-hardening/screenshots/05_command_hall_close.png`
- `artifacts/desktop-spikes/godot-salto/v0186/capture/s1-structure-shell-hardening/screenshots/07_mine_close.png`
- `artifacts/desktop-spikes/godot-salto/v0186/capture/s1-structure-shell-hardening/screenshots/09_barracks_restoration_close.png`
- `artifacts/desktop-spikes/godot-salto/v0186/capture/s1-structure-shell-hardening/screenshots/12_road_bridge_relation.png`
- `artifacts/desktop-spikes/godot-salto/v0186/capture/s1-structure-shell-hardening/screenshots/14_combat_posture.png`

## Computer Use Review

Windows-side packaged app review covered:

- Title screen with the v0.186 opt-in label visible.
- Briefing screen readability.
- Battle start with S1 structure-shell posture visible.
- Aster selection by real input and objective advancement toward the West Stone Cut Mine.
- Camera movement and zoom smoke.

Result: live review matched the automated captures; no tactical obstruction, duplicate rendering, fallback visibility defect, or gameplay-path mutation was observed.

## Benchmark

E4 refined shell live QA baseline versus S1 structure-shell hardening:

- E4 average FPS: `75.25`
- S1 average FPS: `75.54`
- FPS ratio: `1.0039`
- E4 p95: `14.08`
- S1 p95: `13.51`
- p95 worsening: `-4.05%`

Result: `PASS_V0186_STRUCTURE_SHELL_HARDENING_BENCHMARK`.

## Limitations

The S1 structures are intentionally still procedural primitive shells. They are more grounded and readable, but this checkpoint does not authorize generated structure textures, model production, bridge/riverbank material integration, new materials, new slots, or default-art enablement.
