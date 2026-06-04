# v0.122 Godot Parity Report

Status: implemented; final command evidence is captured by the v0.122 artifact reports.

## Expected Passing Statuses

```text
Adapter validation - PASS_GODOT_CONTENT_ADAPTER_VALIDATION
Rules parity - PASS_GODOT_RULES_PARITY_HARNESS
linked_ward - 0.92
Read-only saves - true
localStorage mutation allowed - false
Routine editor use required - false
Full simulation parity claimed - false
```

## Matched Evidence

- The selected content subset loads from generated JSON.
- Stable IDs resolve through generated fixture data.
- Unknown, duplicate, and missing ID checks are represented in adapter validation.
- Both placeholder modes exercise the same representative Tier M fixture.
- Both placeholder modes preserve the same initial placement signature.
- The fixed fixture reaches the required movement, target acquisition, capture-site, Lume, Results, read-only save, and unknown-ID rejection outcomes.

## Artifact Evidence

Generated local evidence is written under:

```text
artifacts/desktop-spikes/godot-salto/v0122/
```

Required files:

- `content-subset.json`
- `stable-id-report.json`
- `adapter-validation.json`
- `parity-report.json`
- `migration-readiness.json`
- `README.md`

## Boundary

This is bounded rules-posture parity only. It does not prove full browser simulation parity, complete pathing equivalence, full AI equivalence, production UI parity, save migration, reward migration, runtime art readiness, or final engine choice.
