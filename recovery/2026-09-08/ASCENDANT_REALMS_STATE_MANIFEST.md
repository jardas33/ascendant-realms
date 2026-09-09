# Ascendant Realms Disaster-Recovery State Manifest

Snapshot date: 2026-09-08
GitHub repository: https://github.com/jardas33/ascendant-realms
Godot version: 4.6.3.stable

## Protected and recoverable commits

- Authoritative baseline: `8bd0f417ae5d30174b67881c495d17fe3f3b2172`
- Protected canonical: `b9812797bba626a3b51e0b79739bc6e2cdf0bca4`
- Frozen animation candidate: `195b4b2a6443dabebfbd557ea64d4f8a29ed7a17`
- World physicality R3A candidate: `2092dac52ed24ed850db7ac628ad534be37ce5a0`

## Important branches

- `codex/current-godot-baseline-next` -> `8bd0f417...`
- `codex/visual-convergence-r1` -> `195b4b2...`
- `codex/world-physicality-r3a` -> `2092dac...`
- `codex/pause-menu-layout-r1` -> `8bd0f417...`
- `safety/2026-09-08/baseline-next` -> `8bd0f417...`
- `safety/2026-09-08/frozen-animation-candidate` -> `195b4b2...`
- `safety/2026-09-08/world-physicality-r3a` -> `2092dac...`
- `safety/2026-09-08/evidence-snapshot` -> this snapshot commit

The protected canonical is not moved. Candidates are unpromoted unless a
separate Director decision says otherwise. Generated/import drift remains
local and is not part of this recovery snapshot.

## Preserved candidate patches

- `reports/astra-declutter/CANDIDATE_01.patch`
- `reports/minimap-fog/CANDIDATE_A.patch`
- `reports/pale-perimeter/SELECTED_REMOVAL.patch`

The adjacent Markdown/JSON files in those report folders explain provenance,
scope, and reapplication. Raster captures and bulk logs are intentionally not
included.

## Latest physicality state

LATEST_PHYSICALITY_DEFECT=
units were proven able to pass through Clanhold, Gold, Stone, Astra wall,
guard tower, and supply wagon on the pre-fix baseline.

LATEST_PHYSICALITY_CANDIDATE=
`2092dac52ed24ed850db7ac628ad534be37ce5a0`

The physicality candidate is technically strong but not yet qualified:
War Hall construction/spawn/death lifecycle and clean Clanhold/tower arrival
fixtures remain Director-required validation work. No promotion is authorized
by this snapshot.

## Current Director state

The Director changed the next action to `ASCENDANT REALMS — GITHUB
DISASTER-RECOVERY BACKUP R1`. This branch is backup-only: no merge, rebase,
cherry-pick, promotion, canonical mutation, or production-source change.

## Recovery note

Clone the repository, fetch the safety refs, and inspect the exact commit SHAs
above before reapplying any preserved patch. The three candidate patches are
evidence/reapplication inputs, not automatically integrated changes.
