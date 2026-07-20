# v0.355 Barrosan Barn Human-Gold Lock

## Scope

v0.355 is documentary and canonical-asset registration only. It records the human-approved v0.354 barn as visual gold and creates a passive opt-in canonical scene. It does not redesign, repair, polish, or reinterpret the barn.

## Authority and lineage

- Base HEAD: `3e557032976075b06a20f45213d6949c68add314`
- Branch: `codex/v0215-v0226-recovery`
- Human decision: `V0.354 HUMAN-APPROVED — BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`
- Geometry: v0.347; material: v0.350; shutters: v0.351; roof: v0.352; workers/natural contact: v0.353; final evidence: v0.354.
- Frozen roof-repair hash: `0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9`.

## Canonical registration

Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`.

No existing House02 `scenes/gold` or `docs/gold` convention was present, so the prompt-prescribed fallback locations were used. The scene is a passive visual registration of the frozen v0.350 barn GLB with asset metadata only; it contains no review camera, light, terrain, workers, labels, debug/evidence nodes, capture logic, or gameplay. The capture harness applies only the already-accepted v0.354 recipe at load time so canonical capture follows the exact historical render path.

## Exact source identity

The fresh v0.355 256x256 canonical source is rendered in the accepted v0.354 neutral world, lighting, terrain, orthographic square camera, and SubViewport. It hashes exactly to the accepted v0.354 raw source:

`13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3`.

This is an exact byte hash gate, not perceptual approval. The internal outcome is therefore ready for human record review, with automated visual approval remaining false.

## Gold manifest and ledger

- Manifest: `docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json`
- Acceptance ledger: `docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md`
- Asset status: `HUMAN_APPROVED_VISUAL_GOLD`
- Production/default/gameplay integrated: false / false / false.
- Collision/navigation, gameplay stable ID, workers/props/vegetation integration, animation, economy, and construction remain deferred.

## Review pack

`artifacts/manual-review/v0355-barrosan-barn-human-gold-lock/UPLOAD_TO_CHAT/`

The upload pack contains exactly eight files: one README ledger, six rendered PNG boards, and one compact JSON summary. It contains no video and no large diagnostic dump. The six PNGs cover v0.354 human approval/lineage, canonical visual scene, front/rear/roof identity, accepted-versus-canonical pixel identity, the exact 256 source, and the hash/status ledger.

## Validation

- Dedicated command: `npm run godot:validate:salto-v0355-barrosan-barn-human-gold-lock`
- Capture command: `npm run godot:capture:salto-v0355-barrosan-barn-human-gold-lock`
- Pack command: `npm run godot:pack:salto-v0355-barrosan-barn-human-gold-lock`
- The validator checks the frozen v0.354 chain, canonical scene isolation, exact raw hash identity, manifest fields/status, exact eight-file pack, six-PNG/no-video contract, and zero gameplay/default-runtime mutation claims.
- Full closeout also runs `npm test`, `npm run build`, content/art/runtime/artifact-retention validation, `npm run godot:all`, and `git diff --check`.

## Final state

Visual gold is human-approved at v0.354 and canonically registered at v0.355. Production integration and gameplay building registration are intentionally not started. Human record review remains required.
