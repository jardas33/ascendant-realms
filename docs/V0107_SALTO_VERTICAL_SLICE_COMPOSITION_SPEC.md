# v0.107 Salto Vertical Slice Composition Spec

Status: planning and review contract only. No images are generated, imported, approved, or wired into runtime by this checkpoint.

## Purpose

v0.107 defines the first polished Salto visual slice before any new art is created. The goal is to make future AI-assisted art generation happen one planned asset at a time with known dimensions, camera rules, runtime slots, fallbacks, and review gates.

## Representative Slice

Use one representative battle slice only:

- Region: Salto-inspired highland foothold.
- Player faction: Barrosan Freeholds.
- Enemy contrast: Ashen Covenant.
- Battle posture: existing First Claim-style readable map composition; no new map or rules.
- Campaign posture: existing campaign shell framing for a single Salto mission launch and return-from-Results context.

## On-Screen Coverage

The first slice covers:

- One Barrosan hero.
- One Worker.
- Militia.
- Ranger.
- Command Hall.
- Barracks.
- Mine.
- Shrine.
- Road.
- Ford or readable water-crossing treatment.
- Quarry.
- Ruin.
- One Lume link.
- One HUD frame.
- One Results frame.
- One campaign-map frame.

## Why Each Asset Matters

| Asset | Why it matters |
| --- | --- |
| Salto environment style frame | Establishes wet highland mood, granite, road, water/ford, quarry, shrine, ruin, and UI-safe negative space. |
| Battlefield style frame | Proves terrain readability for playable, blocked, resource, capture, fog, objective, and minimap surfaces. |
| HUD frame | Sets compact desktop RTS/RPG interface language without mobile UI drift. |
| Results frame | Extends the HUD language into victory/defeat debriefs and reward/progression framing. |
| Lume style frame | Defines one restrained teal land-power link without generic magic clutter. |
| Campaign map style frame | Shows Salto mission launch context without adding nodes or campaign rules. |
| Worker concept | First Barrosan unit readability proof; tool/lantern/utility posture must read at RTS scale. |
| Militia concept | Frontline village defender contrast against Worker and Ranger. |
| Ranger concept | Ranged scout silhouette and ridge-path identity. |
| Hero concept | Grounded commander-champion that supports multiple hero builds without royal-paladin drift. |
| Command Hall | Core Barrosan building massing and broad stable silhouette. |
| Barracks | Practical mustering building distinct from Command Hall. |
| Mine | Resource infrastructure and quarry material language. |
| Shrine | Local ancient landmark with restrained hearth/Lume accent. |
| Ashen enemy contrast sheet | Ensures enemies contrast Barrosan units without demon/orc/undead shorthand. |

## Placeholder Boundary

The following remain placeholder and authoritative:

- `BattleSceneMapRenderer`, `CaptureSite`, fog, minimap, selection/capture rings, and Lume vector rendering.
- `PlaceholderBattlefieldPresentation` unit and building silhouettes.
- Existing HUD, Results, campaign shell, and CSS/DOM frames.
- Existing runtime art slot fallback behavior from v0.106.

## Reference-Only Boundary

All v0.107 planned assets are reference-only. They can become runtime candidates only after:

- source/tool/model/license metadata is recorded;
- protected-IP risk is reviewed;
- Emmanuel approves the candidate as a reference;
- a future explicit runtime integration milestone chooses, crops, validates, and wires an asset.

`runtime-candidate-approved` remains non-loadable. Only a later `runtime-integrated` asset can load.

## Must Not Be Generated Yet

Do not generate or request:

- a whole roster;
- a complete UI kit;
- final terrain tiles;
- runtime sprites or runtime buildings;
- icons;
- new maps, factions, races, units, or buildings;
- desktop-port assets;
- engine-choice mockups.

## Optional Mock Preview Decision

The private mock composition preview is deferred. A wireframe would add a new UI surface and visual QA burden, so v0.107 keeps the composition in deterministic docs and packet metadata only.

## Source Of Truth

Use `docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json` as the machine-readable contract. Generate the metadata packet with:

```text
npm run art:packet:salto-slice
```
