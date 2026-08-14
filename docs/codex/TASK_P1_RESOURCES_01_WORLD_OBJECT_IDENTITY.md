# P1 RESOURCES-01 — Resource Node Art, World-Object Identity & Readability

## Lane

- Branch: `codex/p1-resources-01`
- Base: `5822bcd5e677b88ee9f017c119fb5848c7981ae3`
- Worktree: `D:\CodexData\worktrees\ascendant-realms-p1-resources-01`
- Runtime: Godot 4.6.3 stable at `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`

## Defect

The current resource presentation uses the authored resource meshes, but a
single global value lift and the pale P1-R14 stone accent make the stone
quarry read like a pale construction/building object at normal RTS scale.
Timber, gold, food, and stone also lack a clearly separated material/value
hierarchy when workers or nearby tactical objects share the frame.

## Bounded repair

Repair presentation only. Preserve resource kinds, amounts, costs, gathering
rates, coordinates, collision/gameplay footprints, worker interaction,
navigation, economy, AI, combat, victory, fog, saves, and stable IDs.

## Evidence plan

Use the real Godot runtime and current-source headed capture to show stone,
timber, gold, food, a mixed resource area, and the normal tactical context.
Capture before and after from the same camera/focus contract, with exact
source SHA recorded in manifests. Reject blank, stale, title-card-only, or
low-variance frames.

## Acceptance

- Resource objects visibly read as quarry, timber, gold, and food rather than
  buildings or debug geometry.
- Existing authored meshes remain in use.
- No gameplay semantics or resource values change.
- Fresh post-commit evidence is current-source and validator-passing.
- Generated import/UID/evidence drift stays quarantined and unstaged.
