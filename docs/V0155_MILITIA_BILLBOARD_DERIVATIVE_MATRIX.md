# v0.155 Militia Billboard Derivative Matrix

Status: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY`.

Zero new AI images were generated for v0.155. Every derivative comes from the existing v0.154 Militia cutout and is ignored under the private artifact root.

| Variant | SHA-256 | Dimensions | Notes |
| --- | --- | --- | --- |
| Full-res | `eb007174023e2a4339d45e62ef7bb28769126bd7635ca4ca00115daaafa78996` | `1024 x 1536` | Direct transparent copy of the v0.154 cutout for control comparison. |
| 512 | `ce8ca60d20201874d679e9a00b6bf0f7c4b7f0a83c27cd83ae99e8e40fb6703e` | `512 x 512` | Alpha-bounds trim, transparent square padding, alpha-aware resize, transparent RGB edge bleed. |
| 768 | `ee1bfea83dec0e9f2ef00e5eb92de29a003266205e1cf5b46424cdefb7c92f7c` | `768 x 768` | Same deterministic operations at 768 square. |
| 1024 | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` | `1024 x 1024` | Selected by the private gate for human review. |

Reproduce with:

```text
npm run godot:militia-billboard-repair:derivatives:reproduce
```

Matrix JSON:

```text
artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_derivative-matrix.json
```
