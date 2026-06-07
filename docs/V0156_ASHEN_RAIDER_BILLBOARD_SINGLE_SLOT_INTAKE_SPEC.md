# v0.156 Ashen Raider Billboard Single-Slot Intake Spec

## Scope

v0.156 tests one isolated private-comparator hostile slot:

- Slot: `ashen_raider_billboard_static_v0156`
- Source/cutout root: `artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/`
- Evidence root: `artifacts/desktop-spikes/godot-salto/v0156/evidence/`
- Comparator: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd`

Exactly one local AI-generated source image is authorized for this checkpoint. The transparent cutout, metadata, and fallback are deterministic local derivatives. No existing reference candidate is imported.

## Preserved Context

The private comparator keeps the selected context fixed:

- Worker: `HYBRID_WORKER_TRIMMED_1024`, `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`
- Barracks: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`, `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`
- Aster: `HYBRID_ASTER_TRIMMED_1024`, `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`
- Militia: `HYBRID_MILITIA_TRIMMED_1024`, `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`

v0.155 prerequisite evidence remains the baseline context: Tier L FPS / p95 ratio `1.0702 / 0.9688`; 32-Militia stress FPS / p95 ratio `1.0018 / 0.9946`.

## Gate

The v0.156 automated acceptance gate is private-comparator-only:

- Tier L local-vs-fallback FPS ratio must be at least `0.90`.
- Tier L p95 frame-time worsening ratio must be at most `1.15`.
- Ashen Raider must read hostile and remain distinct from Worker and selected Militia context.
- Hostile and friendly markers must remain visible.
- Alpha edge and bottom-center pivot must be reviewable.
- No player-facing launcher, browser runtime, manifest, save, stable ID, or production art registry may be modified.

Human review remains required before any future production consideration.
