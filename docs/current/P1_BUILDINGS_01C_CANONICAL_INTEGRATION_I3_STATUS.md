# P1 BUILDINGS-01C — Canonical Integration I3

Status: `PASSED_CANONICAL_INTEGRATION_I3_CLANHOLD_SOURCE_SEPARATION`

## Scope

This local-only integration promotes the reviewed BUILDINGS-01C source-separation asset into the canonical Godot lane. It changes the Barrosan Clanhold model reference and adds the authored authority GLB while retaining the existing Watchtower source. No capture harness, validator contract, gameplay script, save, stable ID, or remote state was integrated.

## Identity

- Canonical worktree: `D:\CodexData\worktrees\ascendant-realms-current-godot-baseline`
- Branch: `codex/current-godot-baseline`
- Starting HEAD: `dfa9c9359d1a5080b5beffd655cb9b7cb721f309`
- Final integration commit: recorded in the final handoff because this report is itself part of the commit.
- Parent: `dfa9c9359d1a5080b5beffd655cb9b7cb721f309`
- Commit subject: `I3 integrate BUILDINGS-01C Clanhold source separation`

## Included paths

1. `production/ascendant-realms-godot/assets/environment/buildings/barrosan_clanhold_authority.glb`
2. `production/ascendant-realms-godot/scripts/game/building_defs.gd`
3. `tools/godot/buildings01c/generate-clanhold-authority-glb.mjs`
4. `docs/current/P1_BUILDINGS_01C_CLANHOLD_WATCHTOWER_SOURCE_SEPARATION_STATUS.md`

## Explicitly excluded

The specialist capture and validator wiring was intentionally not integrated:

- `production/ascendant-realms-godot/project.godot`
- `production/ascendant-realms-godot/scripts/main_menu.gd`
- `production/ascendant-realms-godot/scripts/world/game_root.gd`
- `production/ascendant-realms-godot/tests/p1_buildings_01c_capture.gd`
- `tools/godot/buildings01c/validate.mjs`

Temporary proof-only copies of the capture script and autoload dispatch were used against the committed canonical source, then removed. No temporary capture wiring is present in the commit or final authored integration paths.

## Source separation

- Authority Clanhold GLB SHA-256: `B9805E371AE5EC75D8C3AE3C12A07932CF9847DF0DEA48A2151F5317AE9D57A3`
- Preserved Watchtower GLB SHA-256: `9E2E74A5533F4133F8DFDEC50997925D031D817B2B499848DD663DB9836734E1`
- Hashes are unequal.
- `building_defs.gd` selects `barrosan_clanhold_authority.glb` for `barrosan_clanhold` and retains `_b("barrosan_watchtower")` for the Watchtower.
- Authority GLB is a valid GLB 2 asset with the reviewed project-authored provenance metadata.

## Fresh proof

All proof below was generated after the integration commit and is outside the Git commit unless explicitly listed above.

### Exact-HEAD source comparison

Fresh headed 1920×1080 proof root:

`D:\CodexData\evidence\canonical-i3-buildings\`

It contains five real PNGs and `p1-buildings-01c-structure-audit.json` from the live `GameWorld._create_building` path:

- old Clanhold / authority Clanhold / Watchtower overview;
- selected legacy Clanhold;
- selected authority Clanhold;
- selected preserved Watchtower;
- selected authority Clanhold final view.

The audit records the expected live IDs, model paths, positions, footprints, and `prebuilt=true`. The authority Clanhold is visibly a wider/horizontal mass while the Watchtower remains the preserved narrow tower family.

After the final report-only commit, the placement/ghost contract was rerun from the final HEAD at `D:\CodexData\evidence\canonical-i3-p1r10-final\`; its manifest records source SHA `2acefa488e046da9d21a17407fc0e17d9fc7bf00`, eight real frames across 1920×1080 and 1366×768, and `pass=true`. The source-comparison PNGs above remain valid because the commits after their capture changed documentation only; no production path changed.

### Construction and placement regression

Fresh current-source v0.432 proof root:

`D:\CodexData\worktrees\ascendant-realms-current-godot-baseline\artifacts\manual-review\v0432-war-hall-clan-levy-production-loop\`

Command:

```text
ASCENDANT_REALMS_GODOT=D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe node tools/godot/v0432WarHallProductionTool.mjs capture
node tools/godot/v0432WarHallProductionTool.mjs validate
```

The fresh pack includes valid/invalid placement preview, construction progress, completed structure selection, queue/production, and regression frames. This verifies that the integrated model-definition change did not break the existing placement/construction/completion pipeline.

The final exact-HEAD rerun records `captureSourceSha` and `finalCommitSha` both equal to `2acefa488e046da9d21a17407fc0e17d9fc7bf00`, with `passed=true` on `codex/current-godot-baseline`.

### Focused canonical checks

- `node --check tools/godot/buildings01c/generate-clanhold-authority-glb.mjs`: passed.
- Certified Godot 4.6.3 headless editor/import startup: passed, exit 0.
- Existing P1-R10 build-preview capture: passed at 1920×1080 and 1366×768 with real PNGs, valid and invalid ghost outcomes matching expectations.
- The initial authored integration commit contained exactly the four included paths above; the final amended commit adds only this report as the fifth path.
- No temporary capture/autoload paths remain in the committed integration.

## Preservation

Gameplay semantics, building IDs, save behavior, placement rules, construction behavior, resources, AI, combat, navigation, map topology, and the true default runtime were not changed. Existing generated/import drift in the canonical worktree was preserved and not staged. No push, PR mutation, merge, promotion, protected-checkout mutation, or destructive Git operation occurred.

## Follow-on disposition

BUILDINGS-01C is eligible for canonical visual review under the classification above. The next independent environment task may be opened from this new canonical HEAD; it must target a material visual payoff rather than a minor tint, prop, or noise pass and must preserve gameplay and topology.
