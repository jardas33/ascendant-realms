# v0.80 Display-Copy Migration Map

Status: planning map only. v0.80 does not perform the migration.

## Source Inventory

The source inventory is `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`.

Inventory summary:

- Total rows: 72.
- Surfaces inventoried: 8.
- `keep_runtime_copy_now`: 32.
- `copy_candidate_low_risk`: 5.
- `copy_candidate_needs_approval`: 8.
- `lume_or_aether_review`: 12.
- `prohibited_identifier_change`: 15.

## Migration Classes

| Class | Meaning | v0.80 action |
| --- | --- | --- |
| Keep now | Runtime copy is readable and not in conflict with the approved direction. | Do not change. |
| Low-risk display candidate | Docs/package/status or plain display copy can change later with tests. | Plan only. |
| Approval-required copy | Public title, Salto, Barrosan, class, or faction copy needs explicit human approval before runtime. | Plan and ask Emmanuel. |
| Lume/Aether review | Copy touches the boundary between living land-power, battle resource, and hero Mana. | Do not change until taxonomy is approved. |
| Prohibited identifier | Stable ID, save field, package name, stat field, event id, node id, or item id. | Do not rename. |

## Proposed Future Copy Map

| Current player-facing copy | Candidate future copy | Category | Notes |
| --- | --- | --- | --- |
| Ascendant Realms | JARDAS: Oath of the Barrosan Marches | Approval-required title gate | Public title direction is approved, runtime rebrand is not. |
| Prototype v0.3 / Cinderfen Route Baseline | JARDAS prototype / Act 1 - Ashes over Salto | Approval-required title/campaign gate | Bundle with main-menu title and README/package status. |
| The Free Marches | Barrosan Freeholds | Approval-required faction display gate | Keep `free_marches` id. |
| Chapter 1: Border Marches | Act 1 - Ashes over Salto | Approval-required campaign gate | Keep `border_marches` id. |
| Border Village | Salto Outskirts | Approval-required campaign gate | Needs map/objective continuity review. |
| Chapel of the Marches | Chapel of the Barrosan Marches | Low-risk copy candidate | Good later companion to Barrosan direction. |
| Aether Well Ruins | Lume Well Ruins or Old Spring Ruins | Lume/Aether review | High-priority human decision. |
| Aether Well | Lume Well or Old Well | Lume/Aether review | Site copy only; keep site id. |
| North Aether Spring | North Lume Spring or North Aether Spring | Lume/Aether review | Spring is a strong Lume candidate. |
| Aether Surge | Lume Surge or Aether Surge | Lume/Aether review | Must change campaign modifier and battlefield event together if approved. |
| Aether Lens | Lume Lens, Aether Lens, or Well Lens | Lume/Aether review | Item lore depends on final taxonomy. |
| Aether Flow | Lume Flow, Aether Flow, or Flow | Lume/Aether review | Skill text touches ability-resource vocabulary. |
| Warlord | Marshal or Warden | Approval-required class architecture gate | Keep `warlord` id. |
| Arcanist | Seer or Binder | Approval-required class architecture gate | Keep `arcanist` id. |
| Aster | TBD tutorial/Jardas name | Approval-required onboarding gate | Not needed for v0.80. |

## Do Not Rename

The following strings are tracked as identifiers or serialized/data contract terms, not display copy:

- `ascendant-realms` package name.
- `free_marches`.
- `ashen_covenant`.
- `sylvan_concord`.
- `border_marches`.
- `ashen_outpost`.
- `aether`.
- `maxMana`.
- `mission_aether_surge`.
- `aether_surge`.
- `warlord`.
- `arcanist`.
- `aether_lens`.
- `cinderseer_focus`.
- `proving_grounds_basics`.

## Minimum Future Migration Gate

Before a future runtime copy migration:

1. select exactly one batch from `docs/V080_SAFE_COPY_BATCHES.md`;
2. update display strings only;
3. keep all internal IDs and save fields unchanged;
4. run old-save and package validation tests;
5. run at least `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, package generation, and package verification;
6. add a screenshot/manual proxy only if visible runtime UI changes are in scope;
7. document rollback as one revertible batch.
