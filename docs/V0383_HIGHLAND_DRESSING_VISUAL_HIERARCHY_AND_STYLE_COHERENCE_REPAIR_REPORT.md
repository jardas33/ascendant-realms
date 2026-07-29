# v0.383 Highland Dressing Visual Hierarchy and Style-Coherence Repair

## Verdict

v0.382 was rejected by human visual review. v0.383 is a new isolated opt-in repair that addresses the rejection reasons while leaving accepted infrastructure and runtime semantics intact. The final capture is prepared for human review; it is not a claim that the visual direction is permanently accepted.

## Base and protected state

- Branch: `codex/v0215-v0226-recovery`
- Starting HEAD: `6d6a3e21a4b651ba7f9b7825d95fe1d4ce08f9cd`
- Accepted infrastructure commit: `06f45ce1428af5baeac77d542fa1e0811b52c88a`
- Accepted v0.380 GLB SHA-256: `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`
- Accepted source-generator SHA-256: `4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19`

The accepted GLB remains an ancestor dependency and is loaded unchanged. v0.383 only creates a separate scene instance, dressing nodes, scene-level visibility cleanup for non-structural scatter, lighting, and camera settings.

## Human-review rejection carried forward

The v0.382 review identified bridge occlusion, oversized foreground vegetation, cropped upper vegetation, repeated bank formulas, overly saturated red accents, oversized shadows, isolated pale rocks, and weak grayscale focal hierarchy. These are the explicit v0.383 repair targets.

## Implementation

Scene: `desktop-spikes/godot-salto/scenes/v0383_highland_style_coherence.tscn`

Launch:

```text
npm run godot:play:v0383-style-coherence
```

Capture:

```text
$env:V0383_ITERATION='3'; $env:V0383_OUTPUT_ROOT='artifacts/runtime/v0383'; npm run godot:capture:v0383-style-coherence
```

The new scene keeps the accepted river, bridge, roads, and terrain. It adds two reduced asymmetrical landscape masses, six non-repeating bank clusters, four grouped outer rock clusters, and minimal approach dressing. No building, unit, HUD, economy, AI, movement, combat, or default-runtime behavior is present.

## Visual repairs

### Bridge clearance and composition

The crossing is the primary silhouette. Authored vegetation is held outside the deck, landings, immediate road approaches, and the one-bridge-width bank clearance area. The upper mass is moved fully inside frame. The lower mass is smaller and farther from the landing. The orthographic camera retains a stable RTS view and centers the crossing without cinematic distortion.

### Bank variation and material restraint

The six clusters use three patterns: reeds/low grass/one small rock; two or three rocks with sparse reeds; and low grass with one understated buried rock. The authored layer contains no flowered bush variant and no strong red accent. Base non-structural rocks, shrubs, and reeds are subdued only in this opt-in scene instance; the source GLB remains byte-for-byte unchanged.

### Lighting and shadows

The scene uses a restrained warm key, neutral ambient fill, lower key energy, higher shadow bias, and a cool non-shadowing fill. The result preserves contact shadows while avoiding a near-black quadrant. The final grayscale capture retains the intended hierarchy: bridge, crossing, secondary masses, then small dressing.

## Iteration evidence

Three real 1920x1080 iterations were rendered and opened:

- `artifacts/work/v0383-iteration-01/`
- `artifacts/work/v0383-iteration-02/`
- `artifacts/work/v0383-iteration-03/` (final visual geometry before final runtime recapture)

The final review pack uses only the final runtime captures and excludes rejected iterations.

## Preservation and boundaries

- v0.380 bridge, river, road, terrain, and infrastructure materials are not edited.
- v0.382 scene and evidence remain preserved.
- True default runtime remains unchanged.
- No gameplay state, stable ID, save, economy, resource, movement, pathfinding, combat, damage, AI, or wave logic is added.
- No external asset is imported; existing in-repository Quaternius assets are reused under the retained notice.

## Validation

Dedicated command: `npm run godot:validate:v0383-style-coherence`

The validator checks the accepted hashes, v0.382 preservation, opt-in routing, scene-only dressing boundaries, six-cluster/three-pattern structure, three real iteration captures, final six-image capture set, review-pack exact file contract, and forbidden gameplay tokens.

Additional required checks are run before closeout: v0.382 validator, v0.380 validator, accepted GLB hash verification, smoke, tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## Review pack

`artifacts/manual-review/v0383-highland-style-coherence/`

The pack contains the final primary view, bridge-clearance audit, bank-variation detail, mass-spacing view, distribution audit, grayscale primary, iteration summary, and validation manifest. The primary and grayscale frames are real renderer output, not title cards.

## Closeout status

The final status string is `READY FOR HUMAN V0383 HIGHLAND STYLE-COHERENCE REVIEW`. Commit, push, exact-SHA CI confirmation, and the second ChatGPT visual review are the final handoff steps.
