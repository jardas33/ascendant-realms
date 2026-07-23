# v0.370 Quaternius Cohesive Art-Family Proof — Asset Coverage Blocker

Status: **BLOCKED — no visual sandbox was implemented**

Base HEAD: `0e488088ed7e683b8a6d6f2d4f6d44f53c795443`

Branch: `codex/v0215-v0226-recovery`

## Decision

The three requested Quaternius intake directories are present, populated, and
contain usable 3D files. The intake does not, however, contain enough of the
required cohesive environment family to make an honest v0.370 proof. The
checkpoint therefore stops at the asset gate. No Route C scene, production
asset import, launcher, capture script, review image, gameplay integration, or
fallback change was created.

## Intake verified

| Pack | Files | Bytes | License record |
| --- | ---: | ---: | --- |
| `external-art-intake/quaternius/medieval-village-megakit/` | 936 | 174,347,235 | `License_Standard.txt` |
| `external-art-intake/quaternius/fantasy-props-megakit/` | 517 | 162,871,281 | `License_Standard.txt` |
| `external-art-intake/quaternius/ultimate-modular-men/` | 111 | 277,070,570 | `License.txt` |

The character pack includes usable authored character scenes, including
`Adventurer.gltf`, `Farmer.gltf`, and `Worker.gltf`. The village pack includes
usable modular floors, walls, doors, windows, roofs, stairs, fences, and props.
The fantasy props pack includes usable settlement props such as barrels,
crates, carts, and whetstones.

## Exact coverage gap

The requested representative sector requires a bridge, trees/vegetation,
rocks or resource dressing, and a small hostile camp in the same family. A
recursive filename audit of the supplied model files found:

- no Quaternius bridge model;
- no tree, bush, shrub, plant, foliage, or grass model;
- no authored rock, ore, crystal, mine, camp, or tent model;
- no complete building asset, only modular architectural pieces.

The only resource-like filename match is `Whetstone.gltf`; the `RockTrim`
matches are shared material textures, not environmental rock geometry.

This is not sufficient to satisfy the brief's scene story and visual acceptance
bar. Composing a bridge from rectangular floor/fence pieces and fabricating
trees or rocks with primitive meshes would violate the explicit prohibition on
rectangular bridge substitutes, primitive substitutes for missing assets, and
generated placeholder geometry presented as finished art.

## Scope safety

The source intake was not modified. No files were copied under
`desktop-spikes/godot-salto/assets/third_party/quaternius/v0370/`. The default
launcher, v0.368 gameplay route, accepted fallback/proof routes, canonical
Barrosan assets, gameplay rules, saves, stable IDs, and UI systems remain
untouched. No v0.370 review pack is claimed because no raw rendered proof was
produced.

## Safest next action

Provide a compatible Quaternius environment supplement containing at least one
bridge, a small nature/rock/resource set, and a camp or equivalent hostile
settlement dressing, or explicitly authorize a different cohesive family that
already contains those categories. Then retry the isolated proof from this
checkpoint without changing the accepted runtime.

No v0.371 work should begin from this blocked state.
