# v0.162 Barracks Material Opt-In Slot Contract

Status: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.

Slot identity:
- `slotId`: `barrosan_barracks_material_v0149`
- `approach`: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
- `expectedSha256`: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`
- `expectedDimensions`: `768 x 768`

Runtime contract:
- The Barracks material is loaded only when `--barracks-material-opt-in` is present.
- The loader validates source presence, metadata presence, slot ID, approach, metadata SHA-256, image SHA-256, and dimensions.
- The material is applied only to the friendly Barracks procedural shell pieces.
- The Barracks click target, stable fixture ID, construction state, HUD flow, and gameplay state remain unchanged.
- The selected Worker billboard can remain active in the same process.

Fallback contract:
- Missing source path or file produces a procedural Barracks fallback.
- Hash mismatch produces a procedural Barracks fallback.
- Worker art remains active during Barracks fallback scenarios.
- Fallback reports include `fallbackActive`, `fallbackReason`, requested slot count, and loaded slot count.

Validated fallback results:
- Combined mode requested `2` slots and loaded `2`; Barracks applied to `5` friendly Barracks surfaces.
- Missing-art fallback requested `2` slots and loaded `1`; Worker loaded, Barracks `fallbackMode` was `missing`.
- Hash-mismatch fallback requested `2` slots and loaded `1`; Worker loaded, Barracks `fallbackMode` was `hash-mismatch`.

Forbidden in v0.162:
- A third normal-slice art slot.
- Aster, Militia, or Ashen Raider player-facing art.
- Browser runtime wiring.
- Save or stable-ID mutation.
- Production runtime-art manifest mutation.
- Default launcher mutation.
- Worker-only launcher mutation.
