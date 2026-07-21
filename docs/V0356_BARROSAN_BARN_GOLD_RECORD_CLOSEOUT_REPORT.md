# v0.356 Barrosan Barn Gold-Lock Record Repair and Final Documentary Closeout

## Scope

v0.356 repairs the v0.355 human-review record only. The accepted Barrosan Barn visual gold, canonical scene, source bindings, materials, textures, transforms, render recipe, and runtime remain frozen. No artistic work was performed.

## Authority and defects found

- Base HEAD: `2cb0897486c2c9c877c0f0031c1bf5afed1eec13`
- Branch: `codex/v0215-v0226-recovery`
- Human decision: `V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`
- v0.355 visual/canonical identity passed: the accepted and canonical 256x256 sources both hash to `13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3`.
- The defects were documentary: the compact summary lacked the required exact fields, the upload README contained UTF-8 mojibake, board 01 did not directly show the accepted v0.354 authority, and board 06 did not expose the complete canonical/status/mutation ledger.

## Repairs

- Repaired `00_READ_ME_FIRST.md` with explicit UTF-8 output and the exact human decision.
- Replaced `compact-evidence-summary.json` with the required v0.356 top-level field contract.
- Regenerated only board 01 and board 06; boards 02–05 retain their underlying rendered evidence.
- Added a documentary repair command and dedicated v0.356 validator.
- Audited the existing manifest and ledger without changing source paths or bindings. The ledger now makes the silent-gold-source-edit protection explicit.

## Frozen identity and lineage

- Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`
- Gold manifest: `docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json`
- Acceptance ledger: `docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md`
- Geometry: v0.347; materials: v0.350; shutters: v0.351; roof: v0.352; workers/contact: v0.353; final evidence: v0.354.
- Frozen roof hash: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`.

## Mutation and integration record

`geometryMutationCount = 0`, `materialMutationCount = 0`, `textureMutationCount = 0`, `transformMutationCount = 0`, `gameplayMutationCount = 0`, and `defaultRuntimeMutationCount = 0`.

Visual gold is approved, but production integration, gameplay building registration, collision/navigation, animation, workers/props/vegetation integration, and default-runtime integration remain not started. v0.356 grants no production or gameplay integration. The artistic barn-repair loop remains closed.

## Review pack

The repaired pack remains at `artifacts/manual-review/v0355-barrosan-barn-human-gold-lock/UPLOAD_TO_CHAT/` and contains exactly eight files: the README, six PNG boards, and `compact-evidence-summary.json`; no video is present. Board 01 directly presents the actual accepted v0.354 256 source, decision, approval commit, accepted hash, and frozen lineage. Board 06 presents the canonical paths, hashes, status, lineages, mutation zeros, and integration distinctions in readable text.

## Validation

- Dedicated command: `npm run godot:validate:salto-v0356-barrosan-barn-gold-record-closeout`
- Retained commands: v0.355 and v0.354 dedicated validators.
- Full local validation: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`.
- Human review remains required; `automatedVisualApproval` is false.

## Final state

The v0.355 gold lock is now documentary-complete. No accepted asset, canonical binding, rendering, gameplay, or default runtime behavior was changed.
