# v0.164 Militia Opt-In Visual Review Guide

Status: `PASS_V0164_MILITIA_OPT_IN_CAPTURE`; human review still required.

Review packet:

- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0164/capture/worker-barracks-militia-art-opt-in-contact-sheet.svg`
- Capture guide: `artifacts/desktop-spikes/godot-salto/v0164/capture/worker-barracks-militia-art-opt-in-visual-review-guide.md`
- Capture report: `artifacts/desktop-spikes/godot-salto/v0164/capture/worker-barracks-militia-art-opt-in-capture-report.json`

Captured postures:

- `default-procedural`
- `worker-only`
- `worker-barracks`
- `worker-barracks-militia`
- `militia-missing-art-fallback`
- `militia-hash-mismatch-fallback`

Each posture includes 12 packaged player-slice screenshots:

- title
- briefing
- default battle view
- Worker selected
- mine converted
- Worker assigned
- build placement
- Barracks complete
- squad crowding
- camera minimum zoom
- camera maximum zoom
- results

Human review prompts:

- Is the Militia readable as a friendly defender below Aster in visual hierarchy?
- Does the Militia remain distinct from Worker at the normal camera?
- Are shield, spear, health bar, and selection ring readable during squad crowding?
- Does the Militia introduce any alpha halo, pivot drift, or odd ground contact?
- Does Worker + Barracks + Militia feel more coherent than the procedural fallback posture?
- Should v0.165 be a bounded visual repair, a fourth-slot readiness packet, or a pause?

Do not approve:

- Any fourth art slot.
- Any browser-runtime wiring.
- Any final runtime-art approval.
- Any normal-slice change outside the bounded opt-in launcher.
