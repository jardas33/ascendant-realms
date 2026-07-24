# v0.378 Provided Infrastructure Kit Visual Gate Report

## Result

**PASS — V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE MET**

The final bounded source repair clears the strict visual gate using the supplied-authored infrastructure kit in an isolated opt-in Godot scene. The accepted result is intentionally limited to terrain, road, recessed river/banks, and bridge infrastructure. No buildings, units, gameplay, HUD, or production-runtime mutation are present.

## Scope and provenance

- Branch: `codex/v0215-v0226-recovery`
- Checkpoint base: `9d9ef05a72068565683ac35296226a416a524904`
- Original supplied GLB preserved at `external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378_original_supplied.glb`
- Original supplied SHA-256: `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`
- Evaluated repaired GLB: `external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb`
- Evaluated repaired GLB SHA-256: `5d27feaabd61f4ab05063b860d19405b45a9ef2219ee27ee256972275ade40e9`
- Evaluated generator source SHA-256: `28f5de34e24700f9bff58e18510d5ee87f47d41c9b9b0d5031e21e2d77a755a1`
- Imported copy: `desktop-spikes/godot-salto/assets/v0378/provided-infrastructure/barrosan_infrastructure_v0378.glb`

The original artifact remains intact. The evaluated GLB is explicitly recorded as a bounded source repair in the intake README and SHA manifest; it is not a silent replacement.

## Isolated scene and capture path

- Godot script: `desktop-spikes/godot-salto/scripts/v0378_provided_infrastructure.gd`
- Launch/capture wrapper: `tools/godot/captureGodotV0378ProvidedInfrastructureWindows.ps1`
- Focused validator: `tools/godot/saltoV0378ProvidedInfrastructureTool.mjs`
- Launch mode: opt-in v0.378 capture only; the true default runtime remains unchanged.
- Best final evidence: `artifacts/work/v0378-final-iteration-04/`

## Final visual gate

All four final iterations were rendered as 1920x1080 scene PNGs and manually inspected. The final repair narrowed and lightened the bridge deck treatment, added a continuous shallow deck edge course, pulled rails inward, reduced rail mass, and retained the repaired continuous road/riverbank surfaces.

| Area | Score | Gate |
|---|---:|---:|
| Terrain continuity and readability | 72 | PASS (>=65) |
| Road continuity and worn-surface read | 75 | PASS (>=65) |
| Recessed river and shaped banks | 70 | PASS (>=65) |
| Bridge deck, rails, supports, landings | 72 | PASS (>=65) |
| Overall infrastructure-kit visual result | 72 | PASS (>=70) |

Evidence confirms:

- no checkerboard, torn road, floating strips, exposed map boundary, black frame, blank frame, or title card;
- continuous land and road surfaces;
- river visibly recessed below land with a readable bank transition;
- bridge deck, planks, edge course, rails, posts, abutments, and landings read as one crossing;
- grayscale separation remains legible;
- no buildings, units, HUD, gameplay, movement, or unrelated runtime content.

The kit remains sparse by design because v0.378 evaluates only the provided infrastructure stage, not a populated gameplay sector.

## Rejected evidence retained

Original and earlier rejected sets remain available for audit:

- `artifacts/work/v0378-iteration-01/` through `-04/`
- `artifacts/work/v0378-repaired-iteration-01/` through `-04/`
- `artifacts/work/v0378-repaired2-iteration-01/` through `-04/`
- `artifacts/work/v0378-iteration-log.md`
- `artifacts/work/v0378-black-frame-rejection-report.md`

## Review pack

The exact nine-file delivery pack is:

`artifacts/manual-review/v0378-provided-infrastructure-kit/`

It contains five real rendered PNGs, a read-me marker, source/import provenance, scorecard, and validation manifest. It includes the exact marker `READY FOR HUMAN V0378 PROVIDED INFRASTRUCTURE KIT REVIEW`.

## Validation

- `npm run godot:validate:v0378-provided-infrastructure` — passed, 80 rendered PNGs across original, repaired-1, repaired-2, and final evidence sets; all hashes verified.
- `npm run godot:smoke:v0378-provided-infrastructure` — passed.
- `npm test` — passed.
- `npm run build` — passed.
- `npm run validate:content` — passed.
- `npm run validate:art-intake` — passed.
- `npm run validate:runtime-art-slots` — passed.
- `npm run validate:artifact-retention` — passed.
- `npm run godot:all` — passed.
- `git diff --check` — passed.

The supplied GLB, imported copy, source repair, capture manifests, and evidence hashes are cross-checked by the focused validator. The accepted game runtime and v0.377 fallback/proof layer remain untouched.

## Decision

The v0.378 provided infrastructure kit visual gate is met. This checkpoint is ready for human review and normal commit/push/CI closeout. No v0.379 work is started by this checkpoint.
