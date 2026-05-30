# v0.80 Safe Copy Batches

Status: planning only. These batches are proposed order, not runtime approval.

## Batch 0 - Docs And Package Status

Scope:

- README/current status.
- Roadmap/current checkpoint.
- Changelog/checkpoint closeout.
- Package build metadata.
- Package verification required-file list.

Risk:

- Low.
- Already part of v0.80 closeout.
- No runtime title, gameplay, save, or data ID changes.

Rollback:

- Revert docs/package metadata commit.

## Batch 1 - Title And Main Menu Public Identity

Scope:

- Browser title.
- Main menu h1.
- Main menu subtitle/eyebrow.
- Tester README title references if needed.

Candidate copy:

- `JARDAS`.
- `JARDAS: Oath of the Barrosan Marches`.

Required before starting:

- Explicit Emmanuel approval that runtime title copy should change.
- Legal/trademark/storefront status acknowledged as not final unless separately cleared.
- Tests updated for title/menu text.

Not allowed:

- Repository rename.
- package.json `name` rename.
- localStorage key rename.
- save field rename.

Rollback:

- Revert title/menu copy batch.

## Batch 2 - Barrosan / Salto Act 1 Campaign Copy

Scope:

- `The Free Marches` display aliases only.
- Chapter 1 display title.
- Border Village/Act 1 briefing copy.
- Chapel/road/home-region lines.

Candidate copy:

- `Barrosan Freeholds`.
- `Act 1 - Ashes over Salto`.
- `Salto Outskirts` if the first battle is intended to become the Salto-adjacent opening.

Required before starting:

- Human approval of first playable runtime use of Salto.
- Node-card and Results copy review.
- Tests for campaign map labels and old-save compatibility.

Not allowed:

- `free_marches` ID rename.
- `border_marches` ID rename.
- `border_village` ID rename.

Rollback:

- Revert display copy batch. Saves should remain compatible because IDs do not change.

## Batch 3 - Lume / Aether Site Terminology

Scope:

- Aether Well Ruins display text.
- Aether Well/North Aether Spring site display text.
- Aether Surge modifier/event display labels.
- Item and skill descriptions that use Aether in a world-power sense.

Candidate copy:

- `Lume Well Ruins`.
- `Old Spring Ruins`.
- `North Lume Spring`.
- `Lume Surge`.
- `Lume Lens`.

Required before starting:

- Taxonomy approval: whether Aether remains a refined magic resource, becomes only a legacy internal ID, or is replaced in player-facing copy by Lume.
- Paired update of campaign modifier and battlefield event labels so the player does not see both names for the same concept.
- Tests for resources, campaign modifiers, events, Results, item/relic display, and package verification.

Not allowed:

- `aether` resource id rename.
- `maxMana` stat rename.
- `mission_aether_surge` id rename.
- `aether_surge` id rename.
- save migration.

Rollback:

- Revert display copy batch. No save rollback needed if IDs remain unchanged.

## Batch 4 - Future Class Display Copy

Scope:

- Warlord display name.
- Arcanist display name.
- Class descriptions.
- Hero creation/progression copy.

Candidate copy:

- Warlord to Marshal or Warden.
- Arcanist to Seer or Binder.
- Shepherd remains Shepherd.

Required before starting:

- Separate hero architecture gate.
- Class-save compatibility tests.
- Ability/hotkey/readability review.

Not allowed:

- class ID rename.
- save migration bundled with a display-only pass.

Rollback:

- Revert class display copy batch.

## Batch 5 - Deferred Lume Network Runtime

Scope:

- None in v0.80.

Reason:

- The Lume Network needs a dedicated v0.81-style smallest-fun-slice design gate before runtime work.
- Copy migration should not smuggle in new gameplay or new persistent state.
