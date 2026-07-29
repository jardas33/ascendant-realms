# v0.371 — First Cohesive Playable Quaternius RTS Sector

## Verdict

The compact opt-in sector connects the accepted bounded v0.367 gameplay loop to the accepted v0.370 Quaternius visual family. The loop is proven by the smoke manifest and seven clean PLAYER captures: opening, Worker gathering, Field Barracks construction, recruitment, bridge crossing, combat, and victory. Route C is now technically feasible as the next playable presentation foundation, while final Barrosan material/weathering remains a later art pass.

## Scope and isolation

The new route is `desktop-spikes/godot-salto/scenes/v0371_first_cohesive_quaternius_rts_sector.tscn`, launched with `npm run godot:play:quaternius-rts-sector`. It is reached only through the explicit `--v0371-playable`, `--v0371-smoke`, or `--v0371-capture` flags. The v0.370 proof scene was not modified. The true default runtime, saves, stable IDs, and unrelated systems remain untouched.

## Gameplay loop

The scene reuses the bounded v0.367 semantics: ordinary selection, Worker movement and gather/deposit, gold cost, authored Field Barracks placement and staged construction, Militia recruitment, ordinary movement/attack, health/death resolution, victory, defeat, and restart. Militia movement uses a deterministic three-point bridge corridor when crossing the river; it does not walk through the water. The hostile camp contains two imported Quaternius Adventurer characters and composed fence/cart/barrel/crate dressing.

## Visual composition

The PLAYER camera is a closer three-quarter perspective RTS view. The complete tabletop boundary is outside the active framing. Terrain is an authored continuous bed with separate grass regions, a recessed irregular stream, organic road ribbon, bridge deck/rails/stairs, Quaternius buildings, and clustered nature. Main Hall, resource site, Barracks, bridge, and hostile camp retain distinct silhouettes and tactical roles. Units use actual imported `Worker.gltf` and `Adventurer.gltf` models with restrained contact shadows and selection rings; no capsules, slabs, coloured spheres, debug labels, or proof HUD are used in the world presentation.

## Required evidence

Review pack: `artifacts/manual-review/v0371-first-cohesive-quaternius-rts-sector/`

The seven PNGs are real rendered PLAYER frames. `08_VALIDATION.json` is the compact capture mapping, and `08_SMOKE.json` is the runtime loop manifest when generated. The capture command is `npm run godot:capture:quaternius-rts-sector`; the smoke command is `npm run godot:smoke:quaternius-rts-sector`.

## Validation

Dedicated validator: `npm run godot:validate:quaternius-rts-sector`.

The validator checks the isolated scene, explicit route, inherited bounded gameplay contracts, real Quaternius character paths, bridge/stream composition, absence of primitive unit fallbacks, seven nontrivial PLAYER captures, compact review JSON, and no coupling to the accepted v0.368 scene. Local closeout also runs v0.370 validation, tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## Honest limitations and v0.372

The first pass deliberately keeps the existing simple combat and linear resource semantics rather than introducing production navigation or advanced AI. The imported family is cohesive but still brighter and less weathered than the final Barrosan target. Recommended v0.372: improve the playable sector's authored Barrosan material/weathering treatment and bounded route/bridge feedback without expanding the gameplay loop.
