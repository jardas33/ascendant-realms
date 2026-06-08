# v0.168 Player Slice Four-Slot Boundary

Status: `PASS_V0168_PLAYER_SLICE_FOUR_SLOT_BOUNDARY`

Allowed changed surface:

- Godot Salto runtime art loading/reporting for one new Aster opt-in flag path.
- v0.168 Windows launcher, capture, validation, review alias, and report tooling.
- v0.168 docs, tests, handoff, and artifact index updates.

Preserved:

- Default stabilized launcher remains procedural.
- Default player-slice launcher remains procedural.
- Worker-only launcher remains Worker-only.
- Worker + Barracks launcher remains two-slot.
- Worker + Barracks + Militia launcher remains three-slot.
- No Ashen integration.
- No fifth slot.
- Browser runtime remains untouched.
- Normal save, stable-ID, manifest, gameplay, AI, objective, balance, package, and campaign systems remain untouched.
- Selected Worker, Barracks, Militia, Aster, and Ashen local art, derivatives, metadata, tracked fallbacks, and current evidence are preserved.

Forbidden:

- New AI images.
- Ashen integration.
- Fifth opt-in art slot.
- Broad manifest/registry migration.
- Broad artifact deletion or archive moves.
- Default art enablement.
- Browser runtime wiring.

Boundary scan:

```text
node tools/godot/saltoWorkerBarracksMilitiaAsterArtOptInTool.mjs boundary --artifact-root=artifacts/desktop-spikes/godot-salto/v0168 - PASS_V0168_PLAYER_SLICE_FOUR_SLOT_BOUNDARY
```

Boundary evidence: `artifacts/desktop-spikes/godot-salto/v0168/boundary/worker-barracks-militia-aster-art-opt-in-boundary-scan.json`.
