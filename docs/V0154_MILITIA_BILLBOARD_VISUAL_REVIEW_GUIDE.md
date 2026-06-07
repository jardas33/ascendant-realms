# v0.154 Militia Billboard Visual Review Guide

Status: ready for human review after `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_GATE`.

Review the ignored captures under:

```text
artifacts/desktop-spikes/godot-salto/v0154/evidence/screenshots/
```

Review questions:

- Does Militia read as a basic recruited Barrosan defender, not as Aster or Worker?
- Does the shield/spear silhouette stay readable in group formations?
- Does Militia sit lower in hierarchy than Aster?
- Are rings visible in overlap and zoomed views?
- Are alpha edges and foot pivot reviewable without obvious halo?
- Does static formation readability hold at Tier L crowding?

No final runtime-art approval is implied.

Useful evidence:

- Source/cutout review: `09_one_militia_source.png`, `10_checkerboard_alpha.png`, `11_dark_alpha_edge.png`, `12_light_alpha_edge.png`.
- Hierarchy/context review: `13_aster_militia_hierarchy.png`, `14_worker_militia_distinction.png`.
- Group review: `15_group_formation_readability.png`, `16_zoomed_group_readability.png`, `17_overlap_sorting.png`, `18_rings_visible.png`, `19_static_formation.png`.
- Comparator review: `20_fallback_comparison.png`, `21_ortho_comparison.png`.
