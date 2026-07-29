# v0.322 Barrosan Bridge Hamlet Hero Slice

## Executive verdict

**READY FOR HUMAN ART REVIEW**. This is an isolated opt-in Route C hero slice, not a production integration and not an art-direction lock.

## Scope and preservation

The slice focuses only on the Salto east bridge hamlet: a curved recessed river, one timber-and-granite bridge, a principal Barrosan manor/farmhouse, a secondary workshop/storehouse, connected roads, restrained props and one true-3D Worker with two small visual proof units. It does not alter the default route, gameplay, movement, pathfinding, combat, economy, production, AI, resources, saves, stable IDs, minimap data or accepted state chain. v0.321, v0.320 and the v0.319 fallback remain separate.

Base HEAD: `5d02c1aa356caa3471d4afcf0bb925138b26befd`
Branch: `codex/v0215-v0226-recovery`

## Prototype scene and capture

Scene: `desktop-spikes/godot-salto/visual_vertical_slice/V0322BarrosanBridgeHamletHeroSlice.tscn`
Capture: `npm run godot:capture:salto-barrosan-bridge-hamlet-hero-slice`
Validator: `npm run godot:validate:salto-barrosan-bridge-hamlet-hero-slice`
Exact upload directory: `artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice/UPLOAD_TO_CHAT/`

## Visual result

The prototype uses a controlled orthographic oblique camera. Land is elevated above the river bed; the river bends several times with nonuniform width and a darker recessed center. The bridge has granite abutments, timber deck thickness, joints, rail posts and connected approach transitions. The manor uses granite foundation/corners, aged plaster, slate roof planes, deep eaves, recessed openings, steps and chimney smoke. The workshop has a different low silhouette, broad work entrance, lean-to and work-yard props. Roads are authored as connected irregular ribbons with separate wheel wear.

Lighting is a warm directional key with cool valley fill and real consistent shadows. Trees, shrubs, reeds, stone walls, timber, barrels, sacks and a workbench provide restrained inhabited detail. Units are repository-authored true-3D meshes with grounded feet and restrained selection treatment; no billboards are used.

## Evidence integrity

`08_CONTINUOUS_HERO_SLICE.mp4` is encoded from 264 real Godot-rendered source frames at 24 fps, then copied into `UPLOAD_TO_CHAT`. The exact uploaded file is H.264 in an ISO Base Media container, 1280x720, 11.0 seconds, 24 fps, with 264 independently decoded frames and 264 unique decoded frame hashes. Its SHA-256 is `8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84`; magic bytes begin `000000206674797069736f6d`. The pack builder reopens that exact upload path, checks ISO Base Media magic, probes the container with ffprobe, independently decodes and hashes frames with ffmpeg, records the SHA-256 in `compact-evidence-summary.json`, rereads the same path and confirms the hash remains unchanged. The validator repeats the exact-upload check and rejects PNG magic, insufficient duration, insufficient decoded frames, low unique-frame count or hash drift.

The local v0.321 upload was independently checked during this checkpoint and is a valid 48-frame GIF by its local bytes. v0.322 still treats the upload boundary as authoritative and uses a stricter MP4 exact-file audit because the reported external upload artifact was not trusted.

## Bake-off and recommendation

The compact comparison places the recovered historical target, the current v0.303 procedural PLAYER/fallback reference and the new Route C hero overview side by side. Route C is technically feasible and visually more credible for the bridge-hamlet problem because it supplies real terrain elevation, bridge mass, architectural side faces and grounded units without changing production runtime semantics. Human review should judge whether the authored material specificity is strong enough for a later controlled production slice.

Recommended next checkpoint, only after human review: **v0.323 Route C hero-slice human-review decision and production-integration gate**, limited to deciding whether this isolated slice is accepted, revised once, or rejected. No automatic art lock is claimed here.

## Review pack and validation

The compact upload contains exactly 10 files: `00_READ_ME_FIRST.md`, one readable three-way comparison, six real rendered PNG views, `08_CONTINUOUS_HERO_SLICE.mp4`, and `compact-evidence-summary.json`. The full evidence directory contains the numbered 01–43 capture ledger, real rendered source views, the visual-quality contact sheet, technical comparison sheet, runtime manifest and black-frame rejection report.

Dedicated commands are `npm run godot:validate:salto-barrosan-bridge-hamlet-hero-slice` and `npm run godot:validate:salto-v0322-final-media`. The retained v0.321-v0.303 validators and v0.259 invariant validator passed in clean validation isolation. `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run godot:validate:salto-experimental-artifact-retention`, `npm run godot:all` and `git diff --check` passed locally.

## Validation and final state

The dedicated v0.322 validator, corrected exact-upload media validator, retained v0.321-v0.303 validators, v0.259 invariant, tests, build, content/art/runtime checks, artifact retention, `npm run godot:all` and `git diff --check` passed before closeout. The implementation commit `132f56d4668682b6892fa2752e1f999c42a44631` completed GitHub Actions run `29456133952` successfully for that exact SHA. Final state is clean and synced with origin at 0 ahead / 0 behind.
