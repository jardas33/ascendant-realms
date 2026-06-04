# v0.121 Godot Procedural Preset Spec

Status: private spike presets only.

v0.121 defines three 2.5D procedural visual presets and one 2D control label.

## Presets

`2D_CONTROL`

Used for the existing 2D placeholder readability lane.

`CLEAN_READABILITY`

The normal 2.5D review default. It prioritizes silhouette clarity, road/site/Lume readability, subdued palette, and restrained VFX.

`ATMOSPHERIC_BALANCED`

Adds warmer lighting posture, stronger fog posture, and slightly richer Lume glow while preserving tactical readability.

`VFX_STRESS_PRIVATE`

Private stress evidence only. It adds extra procedural Lume pulse markers and glow pressure. It is excluded from the normal Emmanuel review default and must not be treated as visual direction.

## Automation

Preset selection is scriptable through `--visual-preset=` and through private review-harness buttons. Routine preset switching does not require the Godot editor or manual drag-and-drop.
