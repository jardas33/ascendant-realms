# Baseline structural audit

- Exact authorized baseline: `8bd0f417ae5d30174b67881c495d17fe3f3b2172` (`codex/current-godot-baseline-next`).
- Production file: `production/ascendant-realms-godot/scripts/world/hollowspan_environment_composition.gd`.
- Authored Astra settlement placements: 14.
- Starting HQ: Hollowspan start `(-100, 0, -100)`; baseline settlement anchor `(-92, 0, -92)`.
- Existing composition is presentation-only; the source explicitly routes each instance through `_set_presentation_only(instance, true)`.
- Baseline non-assembly nearest pair: `wall_a` / `guard_tower`, 3.162 m. The gate and open-door meshes intentionally share a transform at 0 m.
- Mean Astra-to-HQ distance from authored placement coordinates: 13.805 m; minimum: 6.708 m.

The prior headed frame and the fresh baseline frame both show the same issue: secondary scenery crowds the HQ-facing settlement edge and competes with the clear dirt approach.
