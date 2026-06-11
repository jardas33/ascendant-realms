# v0.221 Selection Indicator Report

Status: PASS

v0.221 reduces selection and focus indicator dominance in the isolated Godot Salto presentation-reboot path while preserving friendly, squad, hostile, objective and minimap readability.

## Adjustments

- Reduced selected-unit disc scale and alpha for the v0.221 path.
- Reduced hero, Worker, squad and hostile target marker scale/alpha without changing selection logic or stable IDs.
- Reduced five-slot review anchor rings for Worker, Aster, Militia and Ashen so character silhouettes remain primary.
- Reduced tutorial/focus ring and arrow prominence during v0.221-focused captures.
- Kept minimap correlation markers visible and aligned with the review-path camera framing.

## Validation

The v0.221 capture pack includes:

- `04_hero_selected.png`
- `05_squad_selected.png`
- `06_hostile_pressure.png`
- `10_minimap_correlation.png`

Validation covered selected, comparator, missing-art, hash-mismatch and boundary scenarios. The v0.215 presentation reboot and v0.220 environment dressing launchers were also revalidated after adding the v0.221 compatibility guard.

## Boundaries

- Selection behavior changed: no.
- Stable IDs changed: no.
- Gameplay commands changed: no.
- Marker occlusion regression detected: no.
- Browser runtime changed: no.
- Default launcher changed: no.

Decision: selected. The rings now read as tactical affordances instead of oversized debug shapes at the tested review distances.
