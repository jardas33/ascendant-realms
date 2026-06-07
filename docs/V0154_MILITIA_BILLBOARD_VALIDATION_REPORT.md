# v0.154 Militia Billboard Validation Report

Status: `PASS_V0154_MILITIA_BILLBOARD_VALIDATION`.

Recorded PASS markers:

- `PASS_V0154_MILITIA_BILLBOARD_METADATA`
- `PASS_V0154_MILITIA_BILLBOARD_FALLBACK_REPRODUCIBILITY`
- `PASS_V0154_MILITIA_BILLBOARD_VALIDATION`
- `PASS_V0154_MILITIA_BILLBOARD_RUNTIME_VALIDATION`

Validation confirmed:

- Exactly one v0.154 source image exists.
- Source SHA-256: `b53e94150bd3fb9b1fde36268655df251deca286f336e6faed72ba1d264d8de0`.
- Cutout SHA-256: `eb007174023e2a4339d45e62ef7bb28769126bd7635ca4ca00115daaafa78996`.
- Cutout dimensions: `1024 x 1536`.
- Trim bounds: left `282`, top `99`, right `797`, bottom `1358`, width `516`, height `1260`.
- Pivot: normalized `0.5273, 0.8848`.
- Alpha stats: `1,231,825` transparent pixels, `6,133` partial pixels, transparent corners true.
- Tracked fallback SHA-256: `8b262f722cc28b346109f0578a0ca151ef8ff01fd4e149075cf7e539a5ab767c`.
- The tracked geometric fallback reproduces byte-for-byte.
- The v0.153 prerequisite gates are present.
- Selected Aster, Worker, and Barracks context hashes match the previous checkpoints.
- Private v0.154 markers do not appear in normal player/browser runtime targets.
- `fourthPrivateComparatorRuntimeArtSlotOnly` and `noFifthRuntimeArtSlot` are recorded.
