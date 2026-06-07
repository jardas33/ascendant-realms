# v0.152 Aster Billboard Derivative Matrix

Status: deterministic same-source derivatives generated from the existing ignored v0.151 Aster cutout. These are private comparator-only artifacts and are not tracked production art.

Source-quality comparator:

| Field | Value |
| --- | --- |
| Path | `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_fullres.png` |
| SHA-256 | `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72` |
| Dimensions | `1024 x 1536` |
| Pivot | `0.5166, 0.9349` |
| Posture | same-source full-resolution comparator copy |

Deterministic derivatives:

| Derivative | Dimensions | SHA-256 | Pivot | Alpha-edge green fringe |
| --- | ---: | --- | --- | ---: |
| `aster_billboard_static_v0151_trimmed_512.png` | `512 x 512` | `7098eb7f011bf2b0aea713dcc191d8b147af105ff893af152cb82d5364958147` | `0.5010, 0.9629` | `0` |
| `aster_billboard_static_v0151_trimmed_768.png` | `768 x 768` | `1c1a677986fe03267809ed97f2d2146e82be80a2eb8dcdf4a3ae777e9ed94057` | `0.5007, 0.9635` | `0` |
| `aster_billboard_static_v0151_trimmed_1024.png` | `1024 x 1024` | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` | `0.5005, 0.9639` | `0` |

Deterministic operations:

- Same v0.151 Aster cutout only.
- Alpha-bounds trim.
- Transparent square padding.
- Premultiplied-alpha-equivalent bilinear resize.
- Transparent RGB edge bleed.
- Metadata and hash regeneration.

Validation command:

```text
npm run godot:aster-billboard-repair:derivatives:reproduce
```

Boundary:

- Generate zero new AI images.
- No existing reference candidate import.
- No production approval.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
