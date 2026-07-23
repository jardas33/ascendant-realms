# v0.373 Internal Visual Audit

This is a private working audit based on the four rendered v0.372 captures. It
is not part of the human upload pack.

## Ten most damaging visible problems

1. The primary camera leaves a large uniform olive field around small clusters.
2. The river is a long, nearly parallel diagonal canal that dominates the frame.
3. Settlement content is effectively one house plus props, not a settlement.
4. The hostile camp is a few loose fence pieces and crates, not a territory.
5. The resource site is visually indistinguishable from decorative rocks.
6. Roads read as narrow brown ribbons laid on top of the ground.
7. Bridge scale is weak relative to the empty terrain and does not anchor the view.
8. Terrain has almost no zoning: no yard, work area, embankment, or camp ground.
9. The Quaternius objects are brightly saturated against an olive field and do not
   yet share a deliberate Barrosan value hierarchy.
10. The top-down audit exposes disconnected props, fence fragments, and weak
    settlement-to-crossing relationships instead of a coherent place.

## Discard / retain decisions

Discard the v0.372 world layout, camera framing, long river direction, isolated
house placement, loose fence arrangement, and narrow road endpoints. Retain the
Quaternius house, timber floor, fence, wagon, crate, barrel, rock, vegetation,
and human assets as a limited authored family. The assets are useful when grouped
into larger readable zones and given consistent scale, material, and lighting.

## Failed camera and spatial relationships

The three-quarter camera was too distant for the amount of content. The river
ran through the composition instead of structuring it. Settlement, resource
site, bridge, and camp were all separated by excessive negative space. The
replacement uses a compact diagonal river across the middle third, a larger
settlement upper-left, a readable resource yard beside it, a central crossing,
and a deliberately enclosed hostile camp lower-right.

## Failed palette relationships

The olive ground was too uniform, cyan water was too saturated, and orange roof
and fence elements became isolated attention magnets. The replacement uses a
warmer settlement yard, muted water, darker worked/resource ground, a restrained
hostile zone, and a shared warm daylight key with cool ambient fill.

## Intended correction

Build a compact four-zone battlefield around one curved diagonal crossing. Use
irregular contained terrain zones, wider travelled paths with soft shoulders,
three compatible settlement buildings, a visually explicit ore deposit with
worked ground and tools, a bridge with real approach geometry, and a closed camp
perimeter. Reframe with a closer fixed orthographic camera so meaningful world
content occupies most of the primary image without cropping key silhouettes.
