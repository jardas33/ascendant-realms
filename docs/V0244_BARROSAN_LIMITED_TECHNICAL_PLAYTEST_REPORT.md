# v0.244 Barrosan Limited Opt-In Technical Gameplay Playtest

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `832175edc9acd71648b0d986061e45f98f6464dd`.
- The v0.243 report's `af4b52914cec260b6517f16021cf502774ea2ddd` is the implementation parent; `832175ed...` is its documentation closeout child and the true v0.244 base.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27884622555.
- Final commit: `PENDING_PUBLICATION`.
- Final exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no.
- New GLB exported: no.
- v0.239 GLB reused unchanged: yes.
- GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.

## Player-slice sequence

- Loaded the opt-in Barrosan runtime, selected Aster, and ran road-adjacent and bridge/river movement probes.
- Selected Command Keep, Restored Barracks and Lume Mine as live entities.
- Exercised the existing mine capture, Worker assignment, Barracks restoration, Militia queue and spawn flow.
- Selected March Forge, Frontier Market and Watchtower as sim-safe shells; all remain non-producing.
- Evaluated one valid and one blocked placement preview through the generated-authority adapter.
- Confirmed preview did not mutate resources and retained all nine minimap/registry roles.

## Construction and validation honesty

- Real construction through the v0.243 placement bridge was intentionally not attempted.
- The bridge is read-only and is not connected to the existing Godot Barracks placeholder construction system; joining those paths would require a separate rules-integration checkpoint.
- Existing Barracks restoration is real within the bounded Godot microloop and remains preserved.
- Valid preview: `true`.
- Blocked preview: `blocked-terrain` / `Blocked terrain.`.
- Preview resources unchanged: `true`.

## Live and shell coverage

- Live entities tested: `main_base`, `barracks`, `mine`.
- Shell entities tested directly: `blacksmith`, `market`, `watchtower`; all six shell contracts remain registered and non-producing.
- Shell health remains 500/500 with no economy, AI, combat or save mutation.

## Movement and pathing

- Probes covered road-adjacent movement, bridge/river movement, live mine proximity and Barracks/main-base proximity.
- The result is review-grade only. Godot still uses rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.
- Visual road, river and bridge alignment remains partially decorative.

## Runtime boundaries

- Touched only the opt-in Barrosan runtime subclass and v0.244 capture/report tooling.
- Untouched: default browser runtime, default Godot runtime, gameplay rules, economy rules, production rules, combat, AI, saves, objectives, commands and source content.

## Validation results

- `npm run godot:test`: pass.
- v0.244 capture and dedicated validator: pass.
- `npm test`: pass, 122 files / 887 tests.
- `npm run build`: pass.
- `npm run validate:content`: pass.
- `npm run validate:art-intake`: pass.
- `npm run validate:runtime-art-slots`: pass, 52 slots.
- `npm run godot:validate:salto-experimental-artifact-retention`: pass.
- `npm run godot:all`: pass.
- `git diff --check`: pass.
- Exact-SHA CI: recorded after publication.

## Exact source files changed

- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0244BarrosanLimitedTechnicalPlaytestReviewPack.py`
- `tools/godot/captureGodotV0244BarrosanLimitedTechnicalPlaytestWindows.ps1`
- `tools/godot/saltoV0244BarrosanLimitedTechnicalPlaytestTool.mjs`
- `tools/godot/validateGodotV0244BarrosanLimitedTechnicalPlaytestWindows.ps1`
- `package.json`
- `docs/V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_REPORT.md`

## Assessment

The constrained opt-in slice survives selection, movement, live Barracks restoration/recruitment, live mine access, shell selection and real validation previews without changing the default runtime. The verdict remains PARTIAL because construction through the generated-rule bridge is preview-only and pathing remains review-grade.

Recommendation: another technical hardening pass is required before v0.245 first limited playable opt-in vertical slice. The next gate should connect one existing construction action to shared authoritative placement/resource semantics without promoting shells or changing defaults.

Stop after v0.244. Do not begin v0.245.
