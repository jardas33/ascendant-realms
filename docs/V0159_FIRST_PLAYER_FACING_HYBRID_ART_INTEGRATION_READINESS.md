# V0159 First Player-Facing Hybrid-Art Integration Readiness

Status: readiness packet only. v0.159 prepares a decision packet and a future v0.160 implementation contract. It generates zero images, adds zero slots, integrates nothing into the normal Salto player slice, preserves the default launcher unchanged, and does not begin v0.160.

## Start State

v0.159 starts from the pushed v0.158 mixed friendly-versus-hostile private comparator stress gate at commit `1d5daeb61645d7fd2195c0fab8c9f13866d6e787`.

v0.158 recorded:

- `PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION`.
- `PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT`.
- `PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED`.
- `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`.
- Tier L selected-vs-fallback FPS / p95 ratios: `0.9392` / `1.1098`.
- 32-Ashen selected-vs-fallback FPS / p95 ratios: `1.1061` / `0.9154`.
- Private comparator only, with zero new images, zero new runtime-art slots, no normal Salto player-slice mutation, and no browser-runtime wiring.

## Preserved Five-Slot Private Comparator Context

| Private comparator slot | Selected derivative | SHA-256 |
| --- | --- | --- |
| Worker billboard | `HYBRID_WORKER_TRIMMED_1024` | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` |
| Barracks material | `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` | `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f` |
| Aster billboard | `HYBRID_ASTER_TRIMMED_1024` | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` |
| Militia billboard | `HYBRID_MILITIA_TRIMMED_1024` | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` |
| Ashen Raider billboard | `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024` | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |

Archived comparison evidence remains preserved for the technically valid but less restrained v0.156 Ashen Raider:

- v0.156 source SHA-256: `9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad`.
- v0.156 cutout SHA-256: `95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba`.

## Readiness Decision

The private comparator phase is technically promising enough to prepare one player-facing opt-in experiment, but not enough to approve production art or replace procedural presentation.

The first player-facing crossing should be:

- Godot-only.
- Worker-only.
- Opt-in experimental launcher only.
- Off by default.
- Fail-closed to the existing procedural Worker fallback.
- Review-evidence focused.

The recommended v0.160 first slot is `worker_billboard_static_v0147` using `HYBRID_WORKER_TRIMMED_1024`.

## Why Worker First

Worker is the lowest-risk first player-facing proof because it is familiar, non-heroic, non-hostile, repeated often enough to expose scale and overlap problems, and easy to compare against the existing procedural Worker fallback. It gives Emmanuel a concrete read on whether hybrid static billboard art improves the normal Salto review slice without putting the hero, hostile combat readability, or building surfaces in the first integration blast radius.

## What v0.159 Does Not Approve

- No image generation.
- No new runtime-art slot.
- No import of any selected image into a normal player-facing runtime path.
- No default launcher change.
- No browser runtime wiring.
- No package or manifest mutation for production art.
- No save, stable-ID, gameplay, balance, map, objective, or browser behavior change.
- No final Godot choice.
- No final runtime-art approval.
- No v0.160 execution.

## Required Human Review

Emmanuel should review this packet, the first-slot scorecard, the v0.160 Worker opt-in contract, the risk register, the rollback plan, and the future v0.160 prompt before authorizing any player-facing integration work.
