# P1 BUILDINGS-01C — Clanhold / Watchtower Source Separation

## Classification

`PASS_VISUAL_SOURCE_SEPARATION_CANDIDATE`

This is a local specialist candidate only. It is not integrated, pushed, or promoted.

## Lane

- Worktree: `D:\CodexData\worktrees\ascendant-realms-p1-buildings-01c`
- Branch: `codex/p1-buildings-01c`
- Base: `dfa9c9359d1a5080b5beffd655cb9b7cb721f309`
- Godot: 4.6.3 stable (`7d41c59c4`)

## Scope

The Clanhold definition now selects a new project-authored `barrosan_clanhold_authority.glb`. The existing Watchtower definition and source remain unchanged. The capture fixture instantiates the legacy Clanhold, the authority Clanhold, and the retained Watchtower side by side in a live Hollowspan GameWorld.

The new source is authored from simple granite, timber, slate, iron, and banner primitives. The GLB embeds provenance stating that it is project-authored and contains no external asset reference. No gameplay data, building footprint, collision, navigation, HP, cost, build time, production, selection contract, stable ID, or save behavior was changed.

## Rendered evidence

Fresh headed 1920x1080 captures are under:

`artifacts/manual-review/p1-buildings-01c-clanhold-watchtower-source-separation/`

The proof contains:

- a live overview with legacy Clanhold, authority Clanhold, and Watchtower;
- selected authority Clanhold;
- selected legacy Clanhold;
- selected retained Watchtower;
- a second authority-selected frame;
- a live structure audit with exact positions and footprints.

The rendered comparison shows a strong silhouette separation: the legacy Clanhold reads as the same narrow tower family as Watchtower, while the authority source reads as a broad horizontal hall with a roof, wings, entrance, iron reinforcement, and a lower grounded mass. The proof is materially stronger than the parked 01B identity-dressing-only candidate. The authority roof is intentionally stylized low-poly and should receive a later material/roof refinement if this candidate is selected for integration.

## Validation

Passed locally:

- `node --check tools/godot/buildings01c/generate-clanhold-authority-glb.mjs`
- generator execution and GLB creation
- certified Godot 4.6.3 headless editor/import startup
- certified Godot 4.6.3 final headed capture at 1920x1080
- `node tools/godot/buildings01c/validate.mjs`
- `git diff --check`

Generated Godot `.import`/`.godot` state and capture logs remain quarantined and are not part of the specialist commit.

## Safety and disposition

- No canonical checkout mutation.
- No protected checkout mutation.
- No push, PR, merge, rebase, or integration.
- No gameplay or state-semantics changes.
- 01B remains parked as `PARKED_P1_BUILDINGS01B_ASSET_QUALITY_CEILING_DUPLICATE_CLANHOLD_WATCHTOWER_SOURCE`.

Recommended director decision: review this candidate for integration proposal. If accepted, perform integration separately from the canonical baseline and retain the 01C capture fixture as opt-in evidence tooling only.
