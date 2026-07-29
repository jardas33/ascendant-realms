# v0.362 Barrosan Barn Contextual Placement Separation

READY FOR HUMAN V0362 BARROSAN BARN CONTEXTUAL PLACEMENT SEPARATION REVIEW.

This is a narrow opt-in fixture correction. The canonical Barn scene, source, roof, geometry, materials, textures, House02, workers, terrain, river, bridge, road, default runtime and gameplay semantics remain unchanged. The single authorized fixture mutation translates the Barn root from (-1.800, 0.180, -1.000) to (4.000, 0.180, -1.000), preserving rotation and scale.

World-space transformed mesh AABBs prove structural intersection false, XZ overlap 0, roof/eave intersection false, structural clearance 2.480 and required worker clearance 1.875. The evidence worker in Board 05 is capture-only and does not add collision, navigation or gameplay semantics.

Default Barn count: 0. Valid opt-in count: 1. Rollback: clean, with baseline/pixel evidence retained. Four fail-closed cases remain covered. All boards are genuine non-headless Godot renders; no video is included.

Validator: npm run godot:validate:salto-v0362-barrosan-barn-contextual-placement-separation
Capture: npm run godot:capture:salto-v0362-barrosan-barn-contextual-placement-separation
Pack: npm run godot:pack:salto-v0362-barrosan-barn-contextual-placement-separation