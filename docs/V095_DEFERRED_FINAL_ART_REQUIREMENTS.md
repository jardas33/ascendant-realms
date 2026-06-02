# v0.95 Deferred Final Art Requirements

v0.95 deliberately improves placeholder readability without final art.

## Final Terrain Needs

- Salto/Barrosan ground palette and authored terrain textures.
- Road, ford, bridge, water, quarry, shrine, and ruin treatments.
- Fog style frames and shader/post-process decisions.

## Final Entity Needs

- Barrosan Hero, Worker, Militia, Ranger, and Acolyte unit sprites or models.
- Ashen Raider, Brute, Hexer, Commander, elite squad, and building sprites or models.
- Command Hall, Barracks, Mystic/Shrine, Watchtower, resource site, and construction-state art.

## UI/Readability Needs

- Authored selection rings and command target affordances.
- Final capture-site icon set.
- Final minimap frame and marker language.
- Final Burn/status iconography.
- Final Lume link and node visual language.

## Review Gate

Future art must pass the v0.88 intake and review gate before runtime integration. As of v0.106, future runtime art must also pass `npm run validate:runtime-art-slots` with a `runtime-integrated` slot assignment under `public/assets/runtime-art/`. `runtime-candidate-approved` is still not enough to load.

This checkpoint does not approve, generate, import, or integrate art.
