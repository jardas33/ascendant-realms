# v0.137 Lighting and VFX Spec

Classification: `BLOCKOUT_QUALITY_GREEN`

## Lighting and Atmosphere

- Overcast highland lighting remains the default readable direction.
- Warm hearth accents mark the Command Hall and shrine-adjacent safe areas.
- Cool water and bank cues separate the river and ford from terrain.
- Subtle terrain fog uses transparent procedural bands only.
- Restrained teal Lume cues avoid bloom overload and no particle spaghetti.
- Shadows remain readable; no full post-processing or final material claim is made.

## VFX Required in the Packaged Proof

The v0.137 headed proof verifies these feedback beats through the normal player-facing path:

- mine conversion pulse;
- Worker assignment pulse;
- Barracks construction progress;
- recruit spawn pulse;
- Ashen wave countdown entry cue;
- attack marker;
- damage flash;
- death fade;
- Lume restore pulse.

No VFX proof may rely on private-harness shortcuts, direct state injection, fixture-only helpers, debug triggers, or screenshot-only assertions.

