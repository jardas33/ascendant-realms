# v0.117 Godot Fixture Import Report

## Source Fixture

Source root:

```text
artifacts/desktop-spike-fixture/latest/
```

Fixture hash:

```text
d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3
```

The fixture remains the v0.116 engine-neutral Salto fixture. v0.117 copies deterministic derived inputs into:

```text
desktop-spikes/godot-salto/data/generated/
```

## Generated Files

- `benchmark-contract.json`
- `content-subset.json`
- `expected-parity.json`
- `fixture-hashes.json`
- `input-contract.json`
- `results-contract.json`
- `save-fixture-index.json`
- `scene-fixture.json`
- `stable-id-subset.json`
- `visual-placeholder-contract.json`
- `fixture-manifest.json`
- `unknown-id-rejection-fixture.json`

## Validation

Static fixture validation status:

```text
PASS_STATIC_FIXTURE_VALIDATION
```

Stable-ID posture:

- Selected fixture IDs resolved: 18.
- Missing selected stable IDs: none.
- Unknown probe ID: `v0117_unknown_fixture_id_must_be_rejected`.
- Unknown probe result: rejected.

Lume posture:

- Fixture-local benefit ID: `linked_ward`.
- Fixture-local link ID: `west_stone_cut_to_ford_toll`.
- Damage-taken multiplier: exactly `0.92`.

Save posture:

- Save fixture manifest is consumed as read-only evidence.
- Raw saves are not copied into the Godot project.
- No browser `localStorage` mutation is allowed.
- No live save writes are allowed.

Art posture:

- Runtime art integrated: false.
- Generated or imported art included: false.
- Placeholder-only scenes are used.
