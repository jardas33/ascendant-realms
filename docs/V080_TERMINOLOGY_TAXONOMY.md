# v0.80 Terminology Taxonomy

Status: docs-only planning. No runtime strings, IDs, save fields, art, gameplay, or Lume Network behavior are changed by this document.

## Purpose

v0.80 separates approved world language from current prototype implementation language so a future copy migration can be small, testable, and reversible.

## Locked Direction From v0.79

- `JARDAS: Oath of the Barrosan Marches` is the approved leading public-title direction, with `JARDAS` dominant.
- `Ascendant Realms` remains the internal repository codename until a later runtime rebrand gate.
- `Salto` is the opening village and emotional home.
- `The Barrosan Marches` are the wider frontier region.
- `Lume` is the ancient living power beneath the land.
- A Jardas is an oath-bound hero who can awaken, bind, defend, and guide Lume sites.
- The first future signature-system design priority is the Lume Network, but no runtime implementation is approved here.

## Term Classes

| Class | Examples | v0.80 decision |
| --- | --- | --- |
| Public identity candidates | JARDAS, Oath of the Barrosan Marches | Approved direction, not runtime title migration. |
| Internal codenames | Ascendant Realms, package name, repo path | Keep unchanged. |
| World/home terms | Salto, Barrosan Marches, Barrosan Freeholds | Approved direction, future display-copy candidates only. |
| Living land-power terms | Lume, Lume site, Lume Network | Approved concept, not runtime system. |
| Tactical resource terms | Mana, maxMana, manaCost | Keep for hero ability readability. |
| Prototype magic-resource terms | Aether, Aether Surge, Aether Well | Review case by case; do not blanket rename. |
| Stable IDs | `free_marches`, `aether`, `ashen_outpost`, `warlord` | Prohibited from v0.80 rename. |
| Tutorial safety copy | no-save/no-reward lines | Keep clear even after future lore pass. |

## Lume, Mana, And Aether Recommendation

Lume should become the world-facing living land-power term. It fits sites, springs, shrines, old roads, mines, territory, oaths, and the future Lume Network.

Mana should remain the tactical hero ability resource for now. It is already readable in ability cooldown/cost copy, hero stats, items, and skill descriptions. Replacing all Mana references with Lume would blur the difference between personal ability pacing and the living land-power.

Aether is the ambiguous placeholder. It currently appears as a resource, site label, item lore word, skill name, event/modifier name, and reward text. v0.80 recommends review, not immediate replacement:

- Keep the `aether` internal resource id until a dedicated save/data migration exists.
- Consider moving site/world copy toward Lume where it refers to springs, wells, shrines, and living territory.
- Consider preserving Aether as a refined or battle-channelled magic substance only if Emmanuel wants a two-layer magic vocabulary.
- Do not rename Aether in runtime during v0.80.

## Approved Future Display Directions

- `The Free Marches` can move toward `Barrosan Freeholds` in future player-facing display copy.
- `Border Marches` chapter copy can move toward `Act 1 - Ashes over Salto`.
- `Aether Well Ruins` and `Aether Well` are high-priority review candidates for Lume-related naming.
- `Aether Surge` should be reviewed as a paired campaign-modifier and battlefield-event label.

## Terms To Keep For Now

- `Ashen Covenant`.
- `Captain Malrec`.
- `Cinderfen` route names.
- `Crowns`, `Stone`, `Iron`.
- `Mana`.
- `Warrior`, `Seer`, `Commander` build identity.
- Tutorial / Proving Grounds no-reward copy.

## Prohibited Identifier Changes

Do not rename stable IDs during display-copy work:

- `free_marches`
- `ashen_covenant`
- `sylvan_concord`
- `border_marches`
- `aether`
- `maxMana`
- `mission_aether_surge`
- `aether_surge`
- `aether_lens`
- `cinderseer_focus`
- `ashen_outpost`
- `warlord`
- `arcanist`
- `proving_grounds_basics`

These can be displayed differently later only through a display alias/copy layer or through a separately approved migration gate with old-save tests.

## Deferred

- Runtime title rebrand.
- Runtime display-copy migration.
- Internal ID migration.
- Save migration.
- Lume Network implementation.
- Race/class implementation.
- Art generation/import.
- Desktop/engine/storefront work.
