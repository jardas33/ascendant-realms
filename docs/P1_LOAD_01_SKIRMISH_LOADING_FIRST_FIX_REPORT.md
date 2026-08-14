# P1 LOAD-01 — Skirmish Loading Time Diagnosis and First-Fix Pass

## Scope

This specialist pass measures the real Barrosan-versus-Lioraen Easy Hollowspan skirmish path from the ordinary player menu/setup flow to a genuinely playable battlefield, then applies one narrow loading fix. It does not alter gameplay semantics, map content, economy, combat, navigation, saves, stable IDs, or the true default runtime.

## Measurement contract

The capture observer is opt-in through `ASCENDANT_P1_LOAD01=1` and is disabled in ordinary runtime. `T0` records player-initiated skirmish, `T1` records the loading transition, and `T9` is the first frame where the real battlefield is running, navigation is ready, the camera is active, HUD/minimap are ready, and the loading screen is settled. Baseline and after runs use the same Hollowspan / Barrosan / Lioraen Easy / rich-resources / conquest configuration.

## Diagnosis and first fix

Baseline instrumentation recorded 166 preload entries and approximately 6.887 seconds of synchronous resource-load time. The largest individual entry was the packed battlefield scene at approximately 417.8 ms, followed by several model/material entries in the 80–146 ms range. The first fix is desktop-only threaded preloading of the same full `PRELOAD_PATHS` set via `ResourceLoader.load_threaded_request`; the established synchronous one-resource-per-frame path remains for web. No asset is skipped and no world/entity initialization is moved.

## Results

The measured baseline runs reached T1-to-T9 in 8.529 s, 7.887 s, and 8.572 s (median 8.529 s). Exploratory after runs reached T1-to-T9 in 3.133 s, 3.555 s, and 3.176 s, but were recorded before the source commit and are not final acceptance evidence. The final exact-head capture at source `9787a009a64015401f70a48cbc71ac838cd98d01` reached T1-to-T9 in 2.927 s, 2.863 s, and 2.685 s (median 2.863 s), a 66.4% reduction from the measured baseline median. The final capture manifest is `D:\CodexData\evidence\ascendant-realms-p1-load-01\final-after-runs\p1-load-01-capture-manifest.json`; all three runs exit cleanly, reach T9, and preserve exact branch/source provenance.

## Evidence

The required final evidence includes three baseline manifests under `D:\CodexData\evidence\ascendant-realms-p1-load-01\ordinary-run-1..3`, three exact-head after manifests under the `final-after-runs` directory, per-run resource timing ledgers, logs, and a real 1920×1080 gameplay screenshot named `01_LOAD01_PLAYABLE.png`. Title-card, blank, and undersized screenshots fail validation. The after capture must be visually inspected before handoff.

## Validation and isolation

The dedicated commands are `npm run godot:test:p1-load-01`, `npm run godot:capture:p1-load-01`, and `npm run godot:validate:p1-load-01`. Godot is the certified D: installation `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe` (4.6.3 stable official). The intended specialist change set is the loader first fix, opt-in observer, package commands, validator contract, this report, and the generated review pack only. Import files, UID files, and pre-existing review/log drift remain quarantined and unstaged.

## Specialist status

The specialist branch is `codex/p1-load-01`, based on canonical HEAD `8ff195c2c1e9027d49bf371023d919ec6468b256`, with final evidence source `9787a009a64015401f70a48cbc71ac838cd98d01`. The lane is not canonically integrated, pushed, merged, or promoted. The protected checkout and canonical branch remain untouched.
