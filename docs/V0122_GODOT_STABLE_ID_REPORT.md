# v0.122 Godot Stable-ID Report

Status: implemented for the selected generated subset.

v0.122 consumes selected stable IDs from generated portable JSON and validates them through text-based Godot adapters. No stable IDs are renamed, added, or remapped.

## Required Behavior

- Resolve all selected subset IDs.
- Reject unknown IDs.
- Reject duplicate IDs.
- Reject missing IDs.
- Preserve deterministic adapter ordering.
- Record the imported fixture hash.

## Unknown Probe

The unknown probe ID is:

```text
v0122_unknown_fixture_id_must_be_rejected
```

The probe must fail lookup in Godot and in the generated validation evidence.

## Evidence Location

Generated local evidence is written to:

```text
artifacts/desktop-spikes/godot-salto/v0122/stable-id-report.json
```

## Boundary

This report proves adapter-level stable-ID acceptance for the bounded subset only. It does not migrate the full content graph or authorize stable-ID changes in the browser prototype.
