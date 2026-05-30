# v0.81 Future Implementation Sequence

Status: docs-only sequence. Do not start these future milestones without a separate explicit goal.

## Milestone A: Smallest-Fun-Slice Runtime Prototype

Purpose: prove whether a tiny Lume Site Network is fun in the browser prototype.

Scope:

- one mission: `aether_well_ruins`;
- one map: `broken_ford`;
- battle-local state only;
- predefined eligible sites;
- maximum three eligible sites;
- maximum two active links;
- one benefit: Linked Ward;
- capture-only activation;
- one HUD row;
- one selected-site summary;
- one Results summary;
- content validation and tests;
- Tutorial/no-reward excluded;
- no save-version bump.

Do not include:

- hero binding unless Emmanuel explicitly chooses it;
- Living Mines;
- race-specific variants;
- new maps;
- new art;
- runtime copy flood;
- package/title rebrand.

## Milestone B: Controlled Display-Copy Migration

Purpose: make selected Lume/Salto/Barrosan copy visible after the prototype direction is approved.

Possible scoped changes:

- `Aether Well Ruins` visible label to `Lume Well Ruins`;
- selected `Aether Surge` visible label to `Lume Surge` if taxonomy approves;
- `The Free Marches` visible label to `Barrosan Freeholds`;
- `Border Marches` chapter display to `Act 1 - Ashes over Salto`;
- selected campaign briefing updates.

Do not rename:

- internal IDs;
- save fields;
- `aether`;
- `maxMana`;
- package/repo/runtime title.

## Future Visual Milestone

Purpose: review visual style frames and silhouettes without flooding runtime art.

Scope:

- Barrosan visual style frame;
- Ashen visual style frame;
- Wolfveil silhouette study;
- source/license governance;
- no runtime art import until approval.

Do not combine with Lume runtime work unless explicitly approved.

## Later Expansion Gates

Possible later systems:

- Living Mines;
- Retinue identity around linked territory;
- rival adaptation to Lume links;
- Dynamic Battlefield Oaths;
- Salto Stronghold;
- race-specific Lume variations;
- public title runtime gate;
- desktop vertical-slice decision gate.

Each should be its own checkpoint with narrow verification.

## Recommended Order

1. Emmanuel reviews v0.81 packet.
2. If approved, implement Milestone A runtime prototype.
3. Let playtests decide whether capture-only is enough or Jardas binding is needed.
4. Only then consider display-copy migration.
5. Only then consider visual style-frame runtime art planning.

## Stop Rule

Do not begin v0.82 or any runtime prototype from v0.81. v0.81 ends with review material and a package.
