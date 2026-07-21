# v0.360 Barrosan Barn Evidence-Pack Truth, Compact Summary and Legibility Closeout

## Scope

v0.360 is a documentary evidence-pack repair only. It does not recapture, remodel, re-import, re-authorize, or enable the accepted Barrosan Barn asset. The v0.359 runtime and raw captures remain the source of truth; this checkpoint makes the upload pack truthful, compact, and human-reviewable.

## Base, decision and retained contract

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `07763f92ea343997d3ddbd159e94b3fe894b8da7`
- v0.359 exact-SHA CI: `29840529534` — success
- Human decision retained: v0.354 Barrosan Barn visual gold accepted; lineage frozen.
- Canonical scene: `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn`
- Accepted raw source and roof hashes remain unchanged.

## Why v0.360 was necessary

The v0.359 runtime capture was technically accepted, but its upload summary was not a truthful compact summary: six per-frame arrays remained in the JSON, 21,600 entries in total, making the summary approximately 1.19 MB. The v0.359 builder also failed to retain the complete v0.358 top-level field set because it looked for the prior aggregate under the wrong runtime path. v0.360 corrects those documentary defects without touching the runtime or raw benchmark artifact.

## Summary truth repair

- Raw arrays removed from the upload pack: 6 keys / 21,600 entries.
- Raw arrays retained externally at `artifacts/performance/v0359-barrosan-barn/v0359-performance.json`.
- Compact summary is under 100 KB and contains aggregate values only.
- Retained v0.358 top-level keys: 82 before; 82 after; missing: 0.
- Validator recursively rejects raw/per-frame benchmark keys and includes an in-memory injected-array self-test.
- No raw benchmark JSON, CSV, or video is included in the upload pack.

## Fail-closed Board 06

Board 06 is rebuilt as a 1600x900 2x2 composition using the accepted v0.359 raw failure captures. Each card has a 30 px scenario heading and 18 px structured body text for: requested slot, load attempted, load succeeded, Barn instances, fallback asset, runtime continued, failure code, and mutation-safe continuation. The documentary `loadAttempted: true` means the scenario request entered the fail-closed load contract; canonical instantiation remains blocked (`canonicalInstantiationAttempted: false`) for invalid authority cases. Raw v0.359 manifests are preserved unchanged.

## Performance Board 08 and load-time evidence

Board 08 now separates frame-performance measurements from Barn scene-load time. The retained load-time value is **376.718 ms**, sourced from `artifacts/runtime/v0358/performance/v0358-performance.json`, measured by `Time.get_ticks_usec` around the authorized canonical `load()` + instantiate + `add_child` path in the retained non-headless harness. The v0.359 uncapped performance arrays and aggregate ratios remain external: median FPS ratio `0.992743105950653`; p95 frame-time ratio `1.06136900078678`; retained Barn nodes after rollback `0`.

## Exact review pack

`artifacts/manual-review/v0360-barrosan-barn-evidence-pack-truth-closeout/UPLOAD_TO_CHAT/` contains exactly 10 files: one README, eight 1600x900 PNG boards, and one compact JSON summary. Boards 01–05 and 07 are reused byte-for-byte from accepted v0.359 evidence. Boards 06 and 08 are the only recomposed boards. The README includes the black-frame rejection report; the validator rejects missing, tiny, invalid, or wrong-aspect PNGs.

## What did not change

No canonical scene, source image, roof, runtime script, default launcher, gameplay state, stable ID, save, collision, navigation, animation, props, production integration, or asset authority changed. Mutation counts remain zero. The pack remains opt-in evidence only; v0.359 remains the debug/proof and fallback layer.

## Validation and human stop

Dedicated command: `npm run godot:validate:salto-v0360-barrosan-barn-evidence-pack-truth-closeout`.

The closeout runs the dedicated v0.360 validator, retained v0.359 validator, v0.358–v0.354 validators, tests, production build, content/art/runtime-art-slot checks, artifact retention, `npm run godot:all`, and `git diff --check`. The final report will record exact local outputs and exact-SHA CI after commit/push. Automated visual approval remains false; this checkpoint stops for human review.

## Deferred work

Do not begin production integration, gameplay, collision/navigation, animation, props, default enablement, or another visual slot from this checkpoint. Those require a separate human decision and a new scoped goal.

READY FOR HUMAN V0360 BARROSAN BARN EVIDENCE-PACK TRUTH CLOSEOUT REVIEW.
