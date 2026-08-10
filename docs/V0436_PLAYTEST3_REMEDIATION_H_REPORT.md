# v0.436 Playtest 3 Remediation H — H1–H5 Local Report

## Scope and provenance

This bounded H batch started from G0 commit
`c09d2803673b002cb600429fd3828a26534fc475` in worktree
`D:/CodexData/worktrees/ascendant-realms-playtest3-remediation-h` on branch
`codex/local-playtest3-remediation-h`. All work is local only. No push, pull
request mutation, merge, promotion, v0.437, R1K, or protected-checkout change
was performed.

Certified Godot was used for headed captures and checks:

`D:/CodexData/tools/godot-4.6.3-stable/Godot_v4.6.3-stable_win64.exe`

Version: `4.6.3.stable.official.7d41c59c4`  
SHA-256: `EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00`

Evidence root:
`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/`  
Logs root:
`D:/CodexData/logs/ascendant-realms-playtest3-remediation-h/`

## H1 — combat positioning and building occupancy

Local commit: `6f491339` (`H1 stabilize combat engagement and building avoidance`).

The bounded repair adds deterministic route waypoints around blocking building
footprints, attack-position anchors, settle hysteresis, route progress, and a
settled-attack avoidance guard. Unit-versus-unit engagement semantics and the
existing combat range contract were retained. The R1H capture harness received
only the minimum explicit `int`/`Dictionary` annotations needed to parse under
the certified Godot runtime.

Focused navigation/combat tests passed. Fresh headed session-B frames are real
gameplay captures, but the lane is truthfully classified
`BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED`: the prepared force can still be
eliminated in the first Easy wave before stable assault resolution. No success
label was substituted for that result.

## H2 — selected entity portraits

Local commit: `105576e5` (`H2 improve selected entity portraits`).

Portrait framing was enlarged and rebalanced with a warmer neutral surround,
stronger ambient fill, a readable three-quarter camera, and slightly improved
unit/building framing. Entity state, selection, assets, and gameplay are
unchanged. The P1-R2 capture returned exit 0 with lit-pixel probes passing for
worker, military, hero, small building, and HQ at 1920x1080 and 1366x768.

Evidence:
`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/H2-portraits/`

## H3 — command panel readability

The command-button implementation was already present in the accepted local
source lineage (`_mk_command_button`): 150x58 action surfaces, explicit normal,
hover, pressed, and disabled style boxes, and disabled tooltips with the
existing `Unavailable: ...` reason. H3 therefore added documentation only in
local commit `2eb5f741` (`H3 clarify command panel actions`); no redundant code
change was made.

Evidence:
`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/H3-command-panel/`

The command capture returned exit 0 and includes worker, HQ, production,
research, disabled, 1366, and build-placement frames. The frames are actual
headed gameplay renders.

## H4 — minimap readability

H4 was an audit-only lane. Existing minimap geometry and presentation remained
the safest compatible result, so no source change was introduced. Fresh
certified captures for Hollowspan, Emberfall Rift, and Frostmere Basin at both
1920x1080 and 1366x768 returned exit 0 and were visually inspected.

Evidence:
`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/H4-minimap/`

## H5 — Easy normal-play audit

The existing Easy contract remains `_think_interval = 2.0`, `_worker_target = 7`,
and `_army_attack_size = 6`, with the accepted v0.435 focused validator and
runtime expectations tied to that six-unit wave. The focused Easy test passed.
The broader retained validator reports historical capture metadata mismatch on
this local branch, so it is not reported as green. Changing the wave size to
four would be an unapproved balance/contract change. H5 therefore made no code
change and records the first-Easy-wave survivability issue as the next
player-impact blocker.

## Final evidence

The required final local pack is:

`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/FINAL/`

It contains actual combat-sequence frames, portrait frames, command-panel
frames, minimap frames, 1366 frames, a real rendered 2x2 visual contact sheet,
a technical contact sheet, and `black-frame-rejection-report.json`. A
trustworthy headed video was not available without fabricating evidence; the
pack provides `PLAYTEST3_REMEDIATION_H_COMBAT_FRAME_SEQUENCE.json` instead.

## Validation status

Passed focused commands:

- `npm run godot:test:v0436-r1-navigation-repair`
- `npm run godot:test:v0436-r1-navigation-behavioral-proof`
- `npm run godot:test:v0436-r1i-combat-causality`
- `npm run godot:test:v0436-r1j-complete-combat-attribution`
- `npm run godot:test:v0436-r1k-controlled-combat-matrix`
- `npm run godot:test:v0435-easy-ai-wave`
- P1-R2 selected-portrait capture, exit 0
- P1-R22 command-card capture, exit 0
- P1-R3 minimap capture, exit 0

The combined production build/content/art/runtime/artifact-retention/Godot-all
closeout remains pending final execution in this worktree. The H1 capture
blocker and the historical v0.435 capture metadata mismatch remain explicit;
neither is hidden by this report.

## Protected state

Protected checkout:
`D:/Code for projects/WB game like/ascendant-realms-v0223-recovery`

Protected HEAD remains `ad4ef9f895a60748af3ac0be8def9028adaa9f6c`. Its
pre-existing dirty state was not touched. The historical
`FAIL_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` diagnostic remains
unchanged.

The H worktree still contains generated Godot 4.6 `.import` churn and
pre-existing artifact-start-file edits from the capture environment. Those
paths were deliberately not staged or discarded. This report therefore does
not claim a clean tree until that state can be reconciled safely without
destroying unrelated work.

## Recommended next player-impact queue

1. Repair the first Easy-wave survivability/assault-resolution blocker under an
   explicitly updated contract.
2. Reconcile generated import-cache churn in a fresh clean validation worktree.
3. Only then consider the next bounded command/minimap polish slice.
