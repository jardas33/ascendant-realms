# Editable Granitborn review sources

These are byte-exact, packed Blender sources from the three surviving Codex
world candidates. They are kept outside the Godot project: Blender is not
required to launch or import the game.

| Source | Original packet | Runtime asset |
| --- | --- | --- |
| castro_hold.blend | R56 Castro Hold | assets/environment/buildings/codex_r56/castro_hold.glb |
| roundhouse.blend | R57 Roundhouse | assets/environment/buildings/codex_r57/roundhouse.glb |
| forge.blend | R58 Castro Forge, final art R5 | assets/environment/buildings/codex_r58/forge.glb |

Provenance: local Codex packet tip
`cbb2b6325cb814a4fb6d18201c1ed5f2b35f15de`, branch
`codex/astra-character-foundation-r12`. R59 carries only these latest surviving
building sources, not the rejected character history or older Hold variants.
The packet source hashes are recorded in `SOURCE_PROVENANCE.json` here.

These assets remain human-review candidates. Materials, silhouette detail,
terrain cohesion, characters and runtime performance are not AAA-qualified.
