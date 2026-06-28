# v0.259 Barrosan UI State Invariant Hardening

Verdict: `PARTIAL`

## Exact facts

- Base commit: `d28ccebc34eb0b72d6e6e6809c687598a11cc8ae`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in Barrosan runtime single-source resolver, capture dispatch, v0.259 evidence tooling, package scripts, and this report.
- UI resolver owns: top objective, center instruction, selected panel title/status/action, work button, target status, and Field Barracks overlay state.
- Mechanics remain unchanged from v0.258: costs, HP, pressure timing, rebuild ticks, training, one Militia, no passive collapse, default runtime unchanged.

## Invariant proof

- Single-source status: PASS.
- Impossible combination status: PASS.
- Forbidden text status: PASS.
- Visual overlay sync status: PASS.
- Retained mechanics status: PASS.
- Default runtime changed: false.
- Proof snapshots captured: 27.
- Required lifecycle states covered: initial Aster, select Worker, place, valid placement, full, damaged, critical, destroyed, Worker rebuild, rebuild ordered, rebuilding 25/50/75, rebuilt 100, train available, Militia defend.

## Mechanical proof retained

- Full resources: 420/160/90/38 -> 240/40/90/38 -> 150/0/90/38 -> 90/0/70/38.
- HP: 200 -> 175 -> 150 -> 125 -> 100 -> 75 -> 50 -> 25 -> 0; rebuild 0 -> 25 -> 50 -> 75 -> 100.
- Production remains available above HP 0, unavailable at HP 0 and during rebuild, and returns at rebuilt 100/200.
- Rebuild remains explicit at HP 0 only and costs exactly 90 Crowns / 40 Stone.
- Train after rebuild remains 60 Crowns / 20 Iron and produces exactly one Militia.
- Repair remains HP 1-199 only; Rebuild remains HP 0 only. No passive collapse, rebuild, repair, or refund.
- Minimap and structures preserved: true.

## Validation and honest assessment

- Dedicated v0.259 capture and validator: pass.
- Full local validation: pass. Exact-SHA GitHub Actions: pending publication.
- Honest assessment: this is a bounded opt-in UI invariant hardening pass for the Barrosan lifecycle slice. It is not global reconstruction, new economy, or production art expansion. Verdict is PARTIAL.
- Recommendation for v0.260: only if separately authorized, move from UI-state correctness to one further bounded gameplay or visual contract without broadening scope.

Stop after v0.259. Do not begin v0.260.
