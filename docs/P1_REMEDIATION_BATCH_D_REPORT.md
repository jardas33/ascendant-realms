# Ascendant Realms — Continuous Human-Review Remediation Batch D

## Scope

Batch D is a bounded player-facing readability pass on the accepted local Batch C base. It contains four focused slices: tactical ground readability (R19), imported-model silhouette separation (R20), presentation-only motion grounding (R21), compact command-card readability (R22), and selected-group panel modernization (R23). It does not add gameplay systems or alter the protected checkout.

## Base and branch

- Worktree: `D:\CodexData\worktrees\ascendant-realms-p1-remediation-d`
- Branch: `codex/local-p1-remediation-d`
- Required base: `185d22ffe66fb11e8bd4db4d500252cda4ea2900`
- Final evidence source SHA is recorded authoritatively in `D:\CodexData\evidence\ascendant-realms-p1-remediation-d\FINAL\final-manifest.json`.

## Godot provenance

The official Godot 4.6.3 provenance discrepancy was resolved before source execution. The certified runtime is `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`, version `4.6.3.stable.official.7d41c59c4`, Authenticode-valid, SHA-256 `EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00`. The official release archive was downloaded from the Godot GitHub 4.6.3-stable release asset into `D:\CodexData\tools\godot-4.6.3-official-audit-20260809\`; its extracted executable produced the same hash. The earlier `63B3...` value was not found in the searched D-backed audit roots and is classified as an incorrect or different-file historical report, not a replacement runtime.

Full packet: `D:\CodexData\audit-packets\godot-4.6.3-provenance-audit-20260809\`.

## Implemented slices

### P1-R19 — tactical ground presentation

Calmed the wide terrain presentation through the existing ground shader and theme grades. Grass/route value separation is clearer while map geometry, resource/building positions, navigation, and map definitions remain unchanged. Highland, volcanic, and Ashen Vale grades remain distinct. A concrete Godot 4.6.3 parse defect in camera-bound type inference was repaired without behavior change.

### P1-R20 — character silhouette separation

Applied small role-aware value lifts and a roughness floor to duplicated per-instance imported materials. Worker, military, and hero models remain authored assets; TeamPip remains secondary; shared source materials are not mutated.

### P1-R21 — motion presentation

Walk animation playback scale follows the unit's already-authoritative planar velocity and resets for idle/work/attack. The proof harness records travel, animation scale, settle velocity, endpoint, and simulation speed. No navigation, position, speed, or simulation rule was changed.

### P1-R22 — command card

Worker build, building train, and research entries use a compact two-column card with readable title/detail lines, concise costs, tier context, disabled state, and explicit tooltip reasons. Existing command, queue, research, affordability, and hotkey semantics are preserved. An opt-in placement-only proof capture was added for final evidence.

### P1-R23 — selected group panel

Multiselect cells now reuse the existing authored entity portrait preview, show health, preserve selected membership, add a selected-group count, and distinguish heroes with a restrained star cue. The selection limit, control-group semantics, hitboxes, rings, and command behavior are unchanged.

## Evidence

Dedicated lane manifests and real headed PNGs are under:

`D:\CodexData\evidence\ascendant-realms-p1-remediation-d\p1r19\`

`D:\CodexData\evidence\ascendant-realms-p1-remediation-d\p1r20\`

`D:\CodexData\evidence\ascendant-realms-p1-remediation-d\p1r21\`

`D:\CodexData\evidence\ascendant-realms-p1-remediation-d\p1r22\`

`D:\CodexData\evidence\ascendant-realms-p1-remediation-d\p1r23\`

The final current-head pack is:

`D:\CodexData\evidence\ascendant-realms-p1-remediation-d\FINAL\`

It contains 20 gameplay-scale PNGs, `contact-sheet.svg`, `final-manifest.json`, and `black-frame-rejection-report.md`. The pack generator rejects missing, undersized, stale-source, or blank evidence.

## Validation commands

- `npm run godot:test:p1r19-tactical-ground`
- `npm run godot:test:p1r20-character-separation`
- `npm run godot:test:p1r21-motion-grounding`
- `npm run godot:test:p1r22-command-card`
- `npm run godot:test:p1r23-selected-group`
- `npm run godot:test:p1d-batch`
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

The final handoff must report the exit code of each command and the exact current-head SHA from the final manifest. No push, PR mutation, merge, promotion, protected-checkout change, R1K, v0.437, or destructive Git operation is authorized.

## Critic posture and remaining risks

The bounded visual changes are genuine and auditable. R19 materially calms the ground, R20 separates imported silhouettes, R21 makes motion timing read as motion without simulation changes, R22 makes command affordances scan faster, and R23 makes group membership legible. Remaining top problems are broader content/art quality, full combat/conquest proof, and the need for independent human review of the final gameplay-scale pack; those are not silently claimed solved by Batch D.

## Protected state

Protected checkout remains `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery`, branch `codex/v0436-first-complete-conquest-victory`, SHA `ad4ef9f895a60748af3ac0be8def9028adaa9f6c`. It is not modified by this batch. The batch branch is local-only and must not be pushed or promoted.
