# v0.347 rendered-geometry truth repair

Outcome: **READY FOR HUMAN V0347 BARN RENDERED-GEOMETRY REVIEW**

Automated visual approval is false and human review remains required. v0.346 remains the rejected human-review candidate and is not marked gold, accepted, or production-ready. This upload pack contains only the isolated v0.347 derivative and its rendered evidence.

Exactly six upload files are present: four actual rendered boards, this readme, and compact-evidence-summary.json. The five unlabelled source renders remain under artifacts/runtime/v0347/screenshots/ and are not extra upload files.

Capture command: npm run godot:capture:salto-v0347-barn-rendered-geometry-truth
Pack command: npm run godot:pack:salto-v0347-barn-rendered-geometry-truth
Validator command: npm run godot:validate:salto-v0347-barn-rendered-geometry-truth

The source set was exactly five real Godot renders before packaging: front three-quarter, direct front, direct side/gable, roof close-up, and the true 512x256 matched House02-left/barn-right comparison. No video, title card, embedded reference image, or fallback frame is used.

Geometry truth: final world-space roof pitch is 20 degrees on both measured slopes, with one straight ridge; final roof rise is approximately 34 percent of total building height. The gables are solid granite geometry and the roof uses the frozen House02 slate tile lineage with an explicit active UV contract.

No default runtime, gameplay, save, stable-ID, movement, pathfinding, combat, economy, or resource change is included. The scene is an opt-in review-only fixture.
