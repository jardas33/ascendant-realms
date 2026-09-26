# Lioraen Groveheart — Ancient Bough R1

This is the editable source for the in-game Lioraen headquarters. The previous
round green mound is retained as `lioraen_groveheart.glb` for comparison. The
new version gives the headquarters a bark-covered trunk, four separated living
crowns, an occupied circular gallery, stone approach, blue faction banners
with gold tree marks, and a cool heartlight. It keeps the `lioraen_groveheart`
building ID, size, health, healing aura, economy, and production data.

`lioraen_groveheart_ancient_bough_r1.blend` has its images packed. Export it
with Blender 5.2.1 using
`production/ascendant-realms-godot/tools/blender/exportLioraenGroveheart.py`.
The game loads the exported
`production/ascendant-realms-godot/assets/environment/buildings/lioraen_groveheart_ancient_bough_r1.glb`.
The optimized model has 14 mesh objects and 18,700 faces; the earlier
prototype had 117 mesh objects with the same geometry.

The bark albedo was generated with the built-in image generator. The working
art brief was: "Seamless tileable dark ancient oak bark albedo for a fantasy living
tree building, deep furrows, aged warm brown and olive undertones, natural
fibrous ridges, diffuse material texture, even lighting, no branches, leaves,
text, frame, or cast shadows." The selected source is
`lioraen_groveheart_ancient_bark_r1.png`; it is also packed in the `.blend`
and embedded in the GLB. The oak crown geometry comes from the existing
`broadleaf_oak.glb`, with its trunk and low geometry removed from this copy.

This is a substantial in-game silhouette improvement, but the battlefield's
grass and lighting still make the faction scene flatter than the portrait and
menu art. Review the real Godot captures before promoting this branch.
