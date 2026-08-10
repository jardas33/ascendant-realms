# v0.436 H4 Minimap Readability Audit

## Scope

H4 audits the existing minimap presentation across the representative maps
without changing minimap geometry, camera transforms, world state, or map
semantics.

## Result

The existing minimap presentation remains deterministic and readable enough
for this bounded lane: terrain/road hierarchy, capture points, building
presence, unit markers, and the camera marker are visible at both required
resolutions. No safe isolated source repair was justified in this audit.

## Evidence

Fresh certified headed captures were produced by
`node tools/godot/p1r3MinimapTerrainTool.mjs capture` with the evidence root:

`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/H4-minimap/`

The capture returned exit 0 for Hollowspan, Emberfall Rift, and Frostmere
Basin at 1920x1080 and 1366x768. The captured frames show the live world and
the minimap together; the 1366 Hollowspan frame was visually inspected.

## Preserved

No map geometry, marker identity, unit position, resource state, command
state, or gameplay behavior changed. The minimap remains compatible with the
accepted debug/review evidence path.
