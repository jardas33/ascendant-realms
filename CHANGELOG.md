# Changelog

# v0.164 Godot Salto Militia Third Opt-In Player-Slice Integration And Human Review Stop - 2026-06-07

This checkpoint adds only the validated Militia billboard as the third normal-slice opt-in art slot behind a new Worker + Barracks + Militia launcher. It preserves the default procedural launcher, preserves the Worker-only launcher, preserves the Worker + Barracks launcher, proves Militia missing-art and hash-mismatch fallback, runs squad-selection and combat-onset checks, benchmarks equivalent modes, and stops for Emmanuel review. It does not begin v0.165.

Added:

- New three-slot launcher `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`.
- New v0.164 validate and capture launchers.
- Package scripts for v0.164 launch, validation, and capture.
- Militia opt-in runtime gates for source path, metadata, slot ID, derivative, SHA-256, dimensions, image load, texture creation, material creation, and mesh creation.
- Fail-closed procedural fallback diagnostics for Militia missing-art and hash-mismatch cases while Worker and Barracks remain active.
- v0.164 validation, capture, benchmark, real-input, Computer Use, boundary, and summary tooling.
- v0.164 spec, slot contract, functional report, visual review guide, benchmark report, rollback report, three-slot boundary, and implementation docs.
- Scaffold guardrail coverage for the three-slot opt-in contract.

Decision:

- Preserved Worker slot: `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024`.
- Worker SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preserved Barracks slot: `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- Barracks SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Added Militia slot: `militia_billboard_static_v0154` / `HYBRID_MILITIA_TRIMMED_1024`.
- Militia SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.

Evidence:

- Final v0.164 scorecard: `PASS_V0164_MILITIA_OPT_IN_HUMAN_REVIEW_READY`.
- Validation: `PASS_V0164_MILITIA_OPT_IN_VALIDATION`.
- Functional: `PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL`.
- Capture: `PASS_V0164_MILITIA_OPT_IN_CAPTURE`.
- Benchmark: `PASS_V0164_MILITIA_OPT_IN_BENCHMARK`, with M3 FPS ratio versus M0 `1.0003`, M3 P95 frame-time ratio versus M0 `0.9442`, M3 FPS ratio versus M2 `1.0001`, and M3 P95 frame-time ratio versus M2 `0.9478`.
- Real-input smoke: `PASS_V0164_MILITIA_OPT_IN_REAL_INPUT`, with normal packaged Godot input, `debugShortcutUsed=false`, and `stateInjectionUsed=false`.
- Computer Use review: `PASS_V0164_MILITIA_OPT_IN_COMPUTER_USE_GATE`.
- Boundary: `PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY`, package leakage `false`, default launcher hash unchanged, Worker-only launcher hash unchanged, Worker + Barracks launcher hash unchanged, no fourth slot, and zero image generation.

Boundaries:

- Zero images generated.
- No fourth player-facing art slot.
- Existing Worker-only launcher preserved.
- Existing Worker + Barracks launcher preserved.
- Default stabilized launcher preserved as procedural.
- No Aster, Ashen Raider, HUD, terrain, environment, or reference-art import.
- No browser-runtime wiring or production manifest mutation.
- No save, stable-ID, gameplay, AI, objective, map, input, balance, campaign, or browser behavior mutation.
- No final runtime-art approval, final Militia art approval, final Godot choice, full port, or v0.165 work.

# v0.163 Godot Salto Barracks-Material Opt-In Visual QA Hardening And Human Review Stop - 2026-06-07

This checkpoint inspects and hardens only the existing combined Worker + Barracks-material opt-in player-slice path. It adds v0.163 Windows-side review, real-input, capture, benchmark, fallback, boundary, and scorecard evidence while preserving the default stabilized launcher as procedural, preserving the Worker-only launcher, generating zero images, adding zero slots, and stopping for Emmanuel review. It does not begin the next milestone.

Added:

- One-click combined review helper `GODOT_REVIEW_SALTO_WORKER_BARRACKS_ART_OPT_IN_WINDOWS.bat`.
- One-click v0.163 hardening validator `GODOT_VALIDATE_SALTO_WORKER_BARRACKS_ART_OPT_IN_HARDENING_WINDOWS.bat`.
- v0.163 hardening wrapper for default, Worker-only, combined, Barracks missing-art fallback, Barracks hash-mismatch fallback, benchmark, and real-input scenarios.
- v0.163 report aggregator `tools/godot/saltoWorkerBarracksArtOptInHardeningTool.mjs`.
- Package scripts for v0.163 review and hardening validation.
- v0.163 visual QA, Computer Use review, real-input, hardening, visual guide, rollback, two-slot boundary, and implementation docs.
- Scaffold guardrail coverage for the v0.163 hardening gate.

Evidence:

- Final v0.163 scorecard: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.
- Validation: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_QA_VALIDATION`.
- Capture: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_CAPTURE`.
- Benchmark: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_BENCHMARK`, with Worker-only FPS ratio `0.9940`, combined FPS ratio `0.9939`, combined-vs-Worker FPS ratio `0.9999`, Worker-only P95 frame-time ratio `0.9837`, combined P95 frame-time ratio `1.0186`, and combined-vs-Worker P95 frame-time ratio `1.0354`.
- Real-input smoke: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`.
- Computer Use review: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_GATE`.
- Boundary: `PASS_V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY`, package leakage `false`, default launcher hash unchanged, Worker-only launcher hash unchanged, and combined launcher hash unchanged.
- Broader local gates passed: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, reference-art init/validate/contact-sheet/review-pack, default Godot player-slice validation, Worker-only Godot validation, combined Worker + Barracks Godot validation, focused scaffold Vitest, Node syntax check, and `git diff --check`.

Boundaries:

- Zero images generated.
- No third player-facing art slot.
- Existing Worker-only launcher preserved.
- Default stabilized launcher preserved as procedural.
- Combined Worker + Barracks launcher preserved.
- No Aster, Militia, Ashen Raider, HUD, terrain, environment, or reference-art import.
- No browser-runtime wiring or production manifest mutation.
- No save, stable-ID, gameplay, AI, objective, map, input, balance, campaign, or browser behavior mutation.
- No final runtime-art approval, final Barracks art approval, final Godot choice, full port, or next-milestone work.

# v0.162 Godot Salto Worker + Barracks Art Opt-In Human Review Stop - 2026-06-07

This checkpoint adds only the v0.150 seam-repaired Barracks material as the second normal-slice opt-in art slot behind a new combined Worker + Barracks launcher. It preserves the default stabilized launcher as procedural, preserves the existing Worker-only launcher, proves Barracks missing-art and hash-mismatch fallback while Worker art remains active, benchmarks equivalent modes, generates zero images, adds no third slot, and stops for Emmanuel review. It does not begin v0.163.

Added:

- Combined opt-in launcher `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.
- Combined validation and capture launchers.
- Package scripts for combined launch, validation, capture, and benchmark.
- Barracks material opt-in runtime gates for source path, metadata, slot ID, approach, SHA-256, dimensions, image load, texture creation, and material creation.
- Fail-closed procedural fallback diagnostics for Barracks missing-art and hash-mismatch cases while Worker art remains active.
- v0.162 validation, capture, benchmark, real-input, boundary, and summary tooling.
- v0.162 spec, slot contract, functional report, visual review guide, benchmark report, rollback report, two-slot boundary, and implementation docs.
- Scaffold guardrail coverage for the two-slot opt-in contract.

Decision:

- Preserved Worker slot: `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024`.
- Worker SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Added Barracks slot: `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- Barracks SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.

Evidence:

- Final v0.162 scorecard: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.
- Validation: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_VALIDATION` and `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL`.
- Capture: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_CAPTURE`.
- Benchmark: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK`, with Worker-only FPS ratio `0.9975`, combined FPS ratio `1.0028`, Worker-only P95 frame-time ratio `1.0106`, and combined P95 frame-time ratio `1.0334`.
- Real-input smoke: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`, with normal packaged Godot input, `debugShortcutUsed=false`, and `stateInjectionUsed=false`.
- Boundary: `PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY`, package leakage `false`, default launcher hash unchanged, and Worker-only launcher hash unchanged.
- Broader local gates passed: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, reference-art init/validate/contact-sheet/review-pack, default Godot player-slice validation, Worker-only Godot validation, focused scaffold Vitest, Node syntax check, and `git diff --check`.

Boundaries:

- Zero images generated.
- No third player-facing art slot.
- Existing Worker-only launcher preserved.
- Default stabilized launcher preserved as procedural.
- No Aster, Militia, Ashen Raider, HUD, terrain, environment, or reference-art import.
- No browser-runtime wiring or production manifest mutation.
- No save, stable-ID, gameplay, AI, objective, map, input, balance, campaign, or browser behavior mutation.
- No final runtime-art approval, final Barracks art approval, final Godot choice, full port, or v0.163 work.

# v0.161 Godot Salto Worker-Art Opt-In Visual QA Hardening And Human Review Stop - 2026-06-07

This checkpoint inspects and hardens only the existing v0.160 Worker-art opt-in player-slice path. It adds Windows-side review, real-input, capture, benchmark, fallback, and boundary evidence for the single Worker slot, preserves the default stabilized launcher as procedural, generates zero images, adds zero slots, and stops for Emmanuel review. It does not begin v0.162.

Added:

- One-click opt-in review helper `GODOT_REVIEW_SALTO_WORKER_ART_OPT_IN_WINDOWS.bat`.
- One-click hardening validator `GODOT_VALIDATE_SALTO_WORKER_ART_OPT_IN_HARDENING_WINDOWS.bat`.
- v0.161 hardening wrapper for procedural, opt-in, missing-art, hash-mismatch, scale, benchmark, and real-input scenarios.
- v0.161 report aggregator `tools/godot/saltoWorkerArtOptInHardeningTool.mjs`.
- Package scripts for v0.161 review and hardening validation.
- v0.161 visual QA, Computer Use review, real-input, hardening, visual guide, rollback, single-slot boundary, and implementation docs.
- Scaffold guardrail coverage for the v0.161 hardening gate.

Decision:

- Preserved player-facing opt-in slot: `worker_billboard_static_v0147`.
- Preserved selected derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preferred scale remains `1.00x` unless human review requests a separate bounded repair.

Evidence:

- Final v0.161 scorecard: `PASS_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY`, FPS ratio `1.0023`, P95 frame-time ratio `0.8784`, package leakage `false`, default stabilized launcher hash unchanged.

Boundaries:

- Zero images generated.
- No second player-facing art slot.
- No Aster, Barracks, Militia, Ashen Raider, HUD, terrain, environment, or reference-art import.
- No browser-runtime wiring or production manifest mutation.
- No save, stable-ID, gameplay, AI, objective, map, input, balance, campaign, or browser behavior mutation.
- No final runtime-art approval, final Worker art approval, final Godot choice, full port, or v0.162 work.

# v0.160 Godot Salto Worker Billboard Opt-In Player-Slice Integration Experiment - 2026-06-07

This checkpoint integrates exactly one validated Worker billboard candidate into the packaged Godot Salto player-facing review slice behind a new explicit opt-in launcher. It preserves the default stabilized launcher and default player-slice launcher as procedural, proves missing-art and hash-mismatch fallback to the procedural Worker, benchmarks the opt-in path against the procedural baseline, and stops for Emmanuel review. It does not begin v0.161.

Added:

- Explicit opt-in launcher `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- Validation and capture launchers for the opt-in experiment.
- Package scripts for opt-in launch, validation, capture, and benchmark.
- Worker-art opt-in runtime gates for source path, metadata, slot id, SHA-256, dimensions, image load, and texture creation.
- Fail-closed procedural fallback diagnostics for missing-art and hash-mismatch cases.
- Runtime benchmark evidence for procedural, opt-in, missing-art fallback, and hash-mismatch fallback scenarios.
- v0.160 spec, slot contract, functional report, visual review guide, benchmark report, rollback report, boundary, and implementation report.
- Scaffold guardrail coverage proving the one-slot contract and default-launcher exclusion.

Decision:

- Player-facing opt-in slot: `worker_billboard_static_v0147`.
- Selected derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Fallback: existing procedural Worker silhouette.

Boundaries:

- Zero images generated.
- No second player-facing art slot.
- No Aster, Barracks, Militia, Ashen Raider, or archived Ashen import.
- No browser-runtime wiring or production manifest mutation.
- No save, stable-ID, gameplay, AI, objective, map, input, balance, campaign, or browser behavior mutation.
- No final runtime-art approval, final Worker art approval, final Godot choice, full port, or v0.161 work.

# v0.159 First Player-Facing Hybrid-Art Integration Readiness Packet And V0.160 Worker Contract - 2026-06-07

This checkpoint prepares only the first player-facing hybrid-art integration readiness packet and the future v0.160 Worker opt-in implementation contract. It generates zero images, adds zero runtime-art slots, integrates nothing into the normal Salto player slice, preserves the default launcher unchanged, and stops for Emmanuel review. It does not begin v0.160.

Added:

- v0.159 first player-facing hybrid-art integration readiness packet.
- v0.159 first-slot decision scorecard selecting Worker as the safest future opt-in proof.
- v0.159 v0.160 Worker opt-in integration contract.
- v0.159 player-slice integration risk register, rollback plan, Emmanuel review guide, private-comparator-to-player-slice boundary, and implementation report.
- Future prompt `docs/art-prompts/V0160_01_GODOT_PLAYER_SLICE_WORKER_BILLBOARD_OPT_IN_INTEGRATION.md`.
- Scaffold guardrail coverage proving the v0.159 packet exists while the future Worker opt-in launcher is not created and the default player-facing launchers do not contain Worker experiment tokens.

Decision:

- Future v0.160 first slot prepared: `worker_billboard_static_v0147`.
- Future v0.160 selected derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Future posture: Godot-only opt-in launcher, default launcher unchanged, fail-closed procedural fallback.

Boundaries:

- Zero images generated.
- Zero new runtime-art slots.
- No selected candidate imported into the normal Salto player slice.
- No opt-in launcher created in v0.159.
- No browser-runtime wiring or production package mutation.
- No manifest, production art-slot, save, stable-ID, gameplay, balance, input, map, objective, campaign, or browser behavior mutation.
- No final runtime-art approval, final Worker art approval, final Godot choice, full port, or v0.160 execution.

# v0.158 Hybrid Mixed Friendly-Versus-Hostile Combat-Readability Stress Gate And Human Review Stop - 2026-06-07

This checkpoint stress-tests only the already-selected five-slot private hybrid comparator posture. It generates zero new images, adds zero runtime-art slots, preserves the selected Worker/Barracks/Aster/Militia/v0.157 Ashen Raider context, preserves archived v0.156 Ashen source/cutout evidence, and stops for Emmanuel review. It does not modify the normal Salto player slice and does not wire anything into the browser runtime.

Added:

- Private v0.158 dispatch flag `--hybrid-mixed-combat-readability-stress`.
- One-click wrapper `GODOT_HYBRID_MIXED_COMBAT_READABILITY_STRESS_WINDOWS.bat`.
- v0.158 validation, fair-path audit, headed benchmark, and capture wrappers.
- New private comparator `hybrid_mixed_combat_readability_stress_comparator.gd`.
- New reporting tool `tools/godot/hybridMixedCombatReadabilityStressTool.mjs`.
- v0.158 mixed-combat stress spec, fair-path audit, benchmark report, visual review guide, private boundary, and implementation report.
- Scaffold guardrail coverage proving the private comparator path stays out of the player-facing launcher.

Evidence:

- Validation: `PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION`.
- Fair-path audit: `PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT`.
- Runtime evidence: `PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED`.
- Stress gate: `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`.
- Tier L selected-vs-fallback FPS / p95 ratios: `0.9392` / `1.1098`.
- 32-Ashen selected-vs-fallback FPS / p95 ratios: `1.1061` / `0.9154`.
- Screenshot count: `47`.

Boundaries:

- Zero new AI images.
- Zero new runtime-art slots.
- Selected five-slot private comparator only.
- No animation assets or directional variants.
- No existing reference candidate import.
- No normal Salto player-slice mutation.
- No browser-runtime wiring or player-facing Godot wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final combat-art approval, final engine selection, full port, or v0.159 work inside this checkpoint.

# v0.157 Ashen Raider Visual-Restraint Replacement Private Comparator And Human Review Stop - 2026-06-07

This checkpoint preserves the technically valid v0.156 Ashen Raider source/cutout as archived comparison evidence, generates exactly one restrained replacement source image, derives deterministic fullres/512/768/1024 candidates for the same hostile slot, selects `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`, and stops for Emmanuel review. It does not add a sixth runtime-art slot, does not modify the normal Salto player slice, and does not wire anything into the browser runtime.

Added:

- Private v0.157 dispatch flag `--ashen-raider-visual-restraint-replacement`.
- One-click wrapper `GODOT_ASHEN_RAIDER_VISUAL_RESTRAINT_REPLACEMENT_WINDOWS.bat`.
- v0.157 derivative reproducibility, validation, audit, headed benchmark, and capture wrappers.
- New private comparator `ashen_raider_visual_restraint_replacement_comparator.gd`.
- v0.157 Ashen Raider replacement spec, slot contract, derivative matrix, fair-path audit, paired benchmark report, visual review guide, private boundary, and implementation report.
- Scaffold guardrail coverage proving the private comparator path stays out of the stabilized/player-facing launchers.

Evidence:

- Derivative reproducibility: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_DERIVATIVES_REPRODUCIBILITY`.
- Validation: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_VALIDATION`.
- Runtime validation: `PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_VALIDATION`.
- Runtime evidence: `PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_EVIDENCE`.
- Gate: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE`.
- Evidence: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_EVIDENCE_RECORDED`, with `37` screenshots, `42` benchmark rows, and `18` aggregate rows.
- Fair-path audit: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_FAIR_PATH_AUDIT`.
- Source SHA-256: `f2c96f230534c86f060b04d0580b8b0f797b859dc348ba1a450a97c90eca6954`.
- Archived v0.156 source SHA-256: `9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad`.
- Archived v0.156 cutout SHA-256: `95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba`.
- Selected SHA-256: `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8`.
- Tier L selected-vs-fallback FPS ratio: `0.9853`.
- Tier L selected-vs-fallback p95 frame-time ratio: `1.0159`.
- Fallback Tier L mean FPS / p95: `1025.21` / `1.26 ms`.
- Archived v0.156 Tier L mean FPS / p95: `988.19` / `1.42 ms`.
- Selected Tier L mean FPS / p95: `1010.16` / `1.28 ms`.
- Preserved context hashes: Worker `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`, Barracks `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`, Aster `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`, Militia `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Fair-path audit confirms `10` texture cache entries, `10` material cache entries, `10` source load entries, one create/load per key, and no repeated texture/material creation or metadata parsing during steady-state frames.

Boundaries:

- Exactly one AI image.
- Same Ashen Raider hostile private comparator slot only.
- Preserves v0.156 source/cutout as archived comparison evidence.
- No animations.
- No sixth runtime-art slot.
- No second hostile slot.
- No existing reference candidate import.
- No normal Salto player-slice mutation.
- No browser-runtime wiring or player-facing Godot wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Ashen Raider art approval, final engine selection, full port, or v0.158 work inside this checkpoint.

# v0.156 Hybrid Ashen Raider Static Billboard Single Hostile-Slot Intake Experiment And Human Review Stop - 2026-06-07

This checkpoint generates exactly one original ignored Ashen Raider source image, derives one deterministic alpha cutout, validates one hostile private-comparator-only runtime-art slot against a tracked fallback, preserves the selected Worker/Barracks/Aster/Militia context, and stops for Emmanuel review. It does not modify the normal Salto player slice or browser runtime.

Added:

- Private v0.156 dispatch flag `--ashen-raider-billboard-single-slot`.
- One-click wrapper `GODOT_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- v0.156 metadata, fallback reproducibility, validation, audit, headed benchmark, and capture wrappers.
- New private comparator `ashen_raider_billboard_single_slot_comparator.gd`.
- Tracked deterministic fallback PNG and contract for `ashen_raider_billboard_static_v0156`.
- v0.156 Ashen Raider intake spec, slot contract, validation report, benchmark report, scorecard, visual review guide, private boundary, and implementation report.

Evidence:

- Gate: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE`.
- Evidence: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`, with `24` screenshots and `21` benchmark rows.
- Source SHA-256: `9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad`.
- Cutout SHA-256: `95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba`.
- Fallback SHA-256: `501dd67cff89a7cd09aa6a1674b24717f183a7a6d71eddbd33a26f6962bb9faa`.
- Tier L local-vs-fallback FPS ratio: `1.0051`.
- Tier L local-vs-fallback p95 frame-time ratio: `1.0074`.
- Fallback Tier L mean FPS / p95: `1001.64` / `1.35 ms`.
- Local Ashen Raider Tier L mean FPS / p95: `1006.75` / `1.36 ms`.
- Preserved context hashes: Worker `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`, Barracks `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`, Aster `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`, Militia `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Fair-path audit: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT`, with `6` texture cache entries, `6` material cache entries, one load/create per source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.
- Human review note: the Raider reads hostile and distinct, but the large weapon silhouette needs human art review before any future approval decision.

Boundaries:

- Exactly one AI image.
- Ashen Raider only.
- Single hostile private comparator runtime-art slot only.
- No animations.
- No sixth runtime-art slot.
- No existing reference candidate import.
- No normal Salto player-slice mutation.
- No browser-runtime wiring or player-facing Godot wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Ashen Raider art approval, final engine selection, full port, or v0.157 work inside this checkpoint.

# v0.155 Hybrid Militia Billboard Repair Mass-Overlap Combat-Readability Benchmark And Human Review Stop - 2026-06-07

This checkpoint repairs and fairly benchmarks only the existing private Militia billboard path. It generates zero new AI images, derives full-res/512/768/1024 same-source variants from the v0.154 Militia cutout, adds no new runtime-art slot and no fifth runtime-art slot, validates 32-unit combat overlap readability, selects `HYBRID_MILITIA_TRIMMED_1024`, and stops for Emmanuel review. It does not modify the normal Salto player slice or browser runtime.

Added:

- Private v0.155 dispatch flag `--militia-billboard-mass-overlap-repair`.
- One-click wrapper `GODOT_MILITIA_BILLBOARD_MASS_OVERLAP_REPAIR_WINDOWS.bat`.
- v0.155 derivative, validation, audit, headed benchmark, and capture wrappers.
- v0.155 repair mode in the existing private Militia comparator.
- v0.155 Militia repair spec, derivative matrix, scorecard, fair-path audit, visual review guide, private boundary, and implementation report.

Evidence:

- Gate: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`.
- Evidence: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_EVIDENCE_RECORDED`, with `36` screenshots and `60` benchmark rows.
- Selected derivative: `HYBRID_MILITIA_TRIMMED_1024`.
- Selected SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Tier L selected-vs-fallback FPS ratio: `1.0702`.
- Tier L selected-vs-fallback p95 frame-time ratio: `0.9688`.
- 32-Militia stress selected-vs-fallback FPS ratio: `1.0018`.
- 32-Militia stress selected-vs-fallback p95 frame-time ratio: `0.9946`.
- Fallback Tier L mean FPS / p95: `650.79` / `1.92 ms`.
- Selected Tier L mean FPS / p95: `696.5` / `1.86 ms`.
- Fallback stress mean FPS / p95: `690.55` / `1.85 ms`.
- Selected stress mean FPS / p95: `691.77` / `1.84 ms`.
- Fair-path audit: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT`, with `8` texture cache entries, `8` material cache entries, one load/create per source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.

Boundaries:

- Zero new AI images.
- Same v0.154 Militia source only.
- No animations.
- No new runtime-art slot.
- No fifth runtime-art slot.
- No existing reference candidate import.
- No normal Salto player-slice mutation.
- No browser-runtime wiring or player-facing Godot wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Militia art approval, final engine selection, full port, or v0.156 work inside this checkpoint.

# v0.154 Hybrid Militia Static Billboard Single-Slot Intake Experiment And Human Review Stop - 2026-06-07

This checkpoint generates exactly one original ignored Militia source image, derives one deterministic alpha cutout, validates a fourth private comparator-only runtime-art intake check against a tracked procedural fallback, records Tier S/M/L evidence with selected Aster/Worker/Barracks context, and stops for Emmanuel review. It does not add a fifth runtime-art slot or modify the normal Salto player slice.

Added:

- Private v0.154 dispatch flag `--militia-billboard-single-slot`.
- One-click wrapper `GODOT_MILITIA_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- v0.154 metadata, fallback reproducibility, validation, audit, headed benchmark, and capture wrappers.
- New private comparator `militia_billboard_single_slot_comparator.gd`.
- Tracked deterministic fallback PNG and contract for `militia_billboard_static_v0154`.
- v0.154 Militia intake spec, slot contract, validation report, scorecard, visual review guide, private boundary, and implementation report.

Evidence:

- Gate: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_GATE`.
- Evidence: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`, with `22` screenshots and `21` benchmark rows.
- Source SHA-256: `b53e94150bd3fb9b1fde36268655df251deca286f336e6faed72ba1d264d8de0`.
- Cutout SHA-256: `eb007174023e2a4339d45e62ef7bb28769126bd7635ca4ca00115daaafa78996`.
- Fallback SHA-256: `8b262f722cc28b346109f0578a0ca151ef8ff01fd4e149075cf7e539a5ab767c`.
- Tier L local-vs-fallback FPS ratio: `1.0055`.
- Tier L local-vs-fallback p95 frame-time ratio: `1.0199`.
- Fallback Tier L mean FPS / p95: `962.15` / `1.51 ms`.
- Local Militia Tier L mean FPS / p95: `967.42` / `1.54 ms`.
- Ortho fallback Tier L mean FPS / p95: `853.8` / `2.11 ms`.
- Fair-path audit: `PASS_V0154_MILITIA_BILLBOARD_FAIR_PATH_AUDIT`, with `5` texture cache entries, `5` material cache entries, one load/create per source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.

Boundaries:

- Exactly one AI image.
- Militia only.
- No animations.
- Fourth private comparator runtime-art intake check only.
- No fifth runtime-art slot.
- No existing reference candidate import.
- No normal Salto player-slice mutation.
- No browser-runtime wiring or player-facing Godot wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Militia art approval, final engine selection, full port, or v0.155 work inside this checkpoint.

# v0.153 Hybrid Three-Slot Private Composition Stress Gate And Human Review Stop - 2026-06-07

This checkpoint stress-tests only the private hybrid composition posture for the already-selected Worker billboard, Barracks material shell, and Aster billboard paths. It generates zero new AI images, adds zero new runtime-art slots, benchmarks fallback-only hybrid, selected-local three-slot hybrid, and ortho fallback comparison paths, records Tier S/M/L evidence, and stops for Emmanuel review.

Added:

- Private v0.153 dispatch flag `--hybrid-three-slot-composition-stress`.
- One-click wrapper `GODOT_HYBRID_THREE_SLOT_COMPOSITION_STRESS_WINDOWS.bat`.
- v0.153 validation, audit, headed benchmark, and capture wrappers.
- Tool-side v0.153 validation, threshold, scorecard, visual-review, contact-sheet, and fair-path audit reports.
- v0.153 docs for composition spec, scorecard, fair-path audit, visual review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd` now supports a private v0.153 composition mode using selected v0.148 Worker, v0.150 Barracks, and v0.152 Aster sources plus tracked fallback/ortho comparison paths.
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private v0.153 dispatch path only.
- `tools/godot/asterBillboardSingleSlotTool.mjs` now records v0.153 validation, evidence, threshold, scorecard, visual-review, contact-sheet, and fair-path audit reports.
- Desktop-spike scaffold tests now assert the v0.153 composition path remains isolated from the normal Salto player slice and default launchers.

Evidence:

- Gate: `PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE`.
- Evidence: `PASS_V0153_HYBRID_THREE_SLOT_EVIDENCE_RECORDED`, with `24` screenshots and `21` benchmark rows.
- Selected-local Tier L FPS ratio versus fallback-only: `1.0071`.
- Selected-local Tier L p95 frame-time ratio versus fallback-only: `1.0379`.
- Fallback-only Tier L mean FPS / p95: `1111.09` / `1.32 ms`.
- Selected-local Tier L mean FPS / p95: `1118.98` / `1.37 ms`.
- Ortho fallback Tier L mean FPS / p95: `999.84` / `1.67 ms`.
- Fair-path audit: `PASS_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT`, with `6` texture cache entries, `6` material cache entries, one texture/material create per selected/fallback source key, and no repeated texture/material creation or metadata parsing during steady-state frames.

Boundaries:

- Zero new AI images.
- Zero new runtime-art slots.
- No existing reference candidate import.
- No normal Salto player-slice mutation.
- No browser-runtime wiring or player-facing Godot wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final art approval, final engine selection, full port, or v0.154 work.

# v0.152 Hybrid Aster Billboard Fair-Path Repair Derivative Selection And Human Review Stop - 2026-06-07

This checkpoint repairs and fairly benchmarks only the existing private v0.151 Aster billboard path. It generates zero new AI images, uses the same v0.151 Aster cutout only, creates deterministic ignored full-res/512/768/1024 comparator derivatives, selects the trimmed 1024 derivative after the preserved gate passes, and stops for Emmanuel review.

Added:

- Deterministic ignored v0.152 Aster billboard repair derivatives under `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/`.
- Repair derivative reproduction, validation, fair-path audit, headed benchmark, and capture wrappers.
- One-click wrapper `GODOT_ASTER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat`.
- v0.152 docs for repair spec, derivative matrix, fair-path audit, paired benchmark report, visual review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--aster-billboard-single-slot-repair` dispatch path only.
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd` now supports a repair mode with shared Aster billboard rendering and repaired review-capture framing.
- `tools/godot/asterBillboardSingleSlotTool.mjs` now records v0.152 derivative reproducibility, validation, threshold, evidence, visual-review, and fair-path audit reports.
- Desktop-spike scaffold tests now assert the v0.152 Aster repair path remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.152 as the current private comparator human-review stop.

Evidence:

- Same v0.151 source SHA-256: `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72`.
- Selected repair: `HYBRID_ASTER_TRIMMED_1024`.
- Selected SHA-256: `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`, dimensions `1024 x 1024`.
- Gate: `PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE`.
- Tier L selected average-FPS ratio: `0.9708`; selected p95 ratio: `1.0088`.
- Evidence: `PASS_V0152_ASTER_BILLBOARD_REPAIR_EVIDENCE_RECORDED`, with `31` screenshots and `35` benchmark rows.
- Fair-path audit: `PASS_V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT`, with one texture load/create per source, one material create per source/material key, and no repeated texture/material creation during steady-state frames.

Boundaries:

- Zero new AI images.
- Same v0.151 Aster source only.
- No existing reference candidate import.
- No new runtime-art slot.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Aster art approval, final engine selection, full port, or v0.153 work.

Verification:

- Required v0.152 verification is listed in `docs/V0152_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.151 Hybrid Aster Static Billboard Single-Slot Intake Experiment And Human Review Stop - 2026-06-07

This checkpoint tests only one isolated private hybrid Aster static billboard slot. It generates exactly one original ignored Aster source image, creates a deterministic matte-to-alpha local cutout, validates a tracked diagnostic fallback, fairly benchmarks Tier S/M/L private comparator evidence with the v0.148 Worker and v0.150 Barracks repair as context only, selects the local Aster billboard after the preserved gate passes, and stops for Emmanuel review.

Added:

- One ignored local Aster source and cutout under `artifacts/desktop-spikes/godot-salto/v0151/local-aster-slot/`.
- Tracked deterministic Aster fallback PNG and contract for clean-checkout validation.
- Private comparator `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd`.
- Metadata, fallback reproducibility, validation, fair-path audit, headed benchmark, capture wrappers, and `GODOT_ASTER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- v0.151 docs for intake spec, slot contract, validation report, scorecard, visual review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--aster-billboard-single-slot` dispatch path only.
- Desktop-spike scaffold tests now assert the v0.151 Aster billboard path remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.151 as the current private comparator human-review stop.

Evidence:

- Local Aster cutout SHA-256: `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72`, dimensions `1024 x 1536`.
- Fallback SHA-256: `b327fae1de7dde0047eb62af8cebe6eb2fecde43856b8dcd60ef3830d6bae46d`, dimensions `1024 x 1536`.
- Selected approach: `HYBRID_ASTER_LOCAL_STATIC_BILLBOARD`.
- Gate: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE`.
- Tier L local-vs-fallback average-FPS ratio: `0.9273`; p95 ratio: `1.1081`.
- Evidence: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`, with `32` screenshots and `35` benchmark rows.
- Fair-path audit: `PASS_V0151_ASTER_BILLBOARD_FAIR_PATH_AUDIT`, with one texture load/create per source, one material create per source/material key, and no repeated texture/material creation during steady-state frames.

Boundaries:

- Exactly one new AI image.
- No existing reference candidate import.
- No generated reference image import.
- No downloaded asset use.
- No fourth runtime-art slot.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Aster art approval, final engine selection, full port, or v0.152 work.

Verification:

- Required v0.151 verification is listed in `docs/V0151_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.150 Hybrid Barracks Material UV Seam Repair Lighting Review And Human Review Stop - 2026-06-07

This checkpoint repairs and fairly benchmarks only the existing private v0.149 Barrosan Barracks material path. It generates zero new AI images, uses the same v0.149 material source only, creates deterministic ignored seam-repair variants, selects the wrapsafe offset-blend derivative after the preserved gate passes, and stops for Emmanuel review.

Added:

- Deterministic ignored v0.150 Barracks material seam-repair derivatives under `artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/`.
- Private comparator `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd`.
- Seam-repair validation, derivative reproducibility, fair-path audit, headed benchmark, and capture wrappers.
- One-click wrapper `GODOT_BARROSAN_BARRACKS_MATERIAL_SEAM_REPAIR_WINDOWS.bat`.
- v0.150 docs for seam-repair spec, derivative matrix, fair-path audit, paired benchmark report, visual review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--barrosan-barracks-material-seam-repair` dispatch path only.
- `tools/godot/barracksMaterialSingleSlotTool.mjs` now records v0.150 derivative reproducibility, validation, threshold, evidence, and fair-path audit reports.
- Desktop-spike scaffold tests now assert the v0.150 seam-repair path remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.150 as the current private comparator human-review stop.

Evidence:

- Same v0.149 source SHA-256: `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c`.
- Original v0.149 selected 768 SHA-256: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`.
- Selected repair: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- Selected SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`, dimensions `768 x 768`.
- Gate: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE`.
- Tier L selected average-FPS ratio: `1.0048`; selected p95 ratio: `0.9681`.
- Evidence: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_EVIDENCE_RECORDED`, with `62` screenshots and `49` benchmark rows.
- Fair-path audit: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_FAIR_PATH_AUDIT`, with one texture load/create per source, one material create per source/material key, and no repeated texture/material creation during steady-state frames.

Boundaries:

- Zero new AI images.
- Same v0.149 source only.
- No new runtime-art slot.
- No reference candidate import.
- No downloaded asset use.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Barracks material approval, final engine selection, full port, or v0.151 work.

Verification:

- Required v0.150 verification is listed in `docs/V0150_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.149 Hybrid Barrosan Barracks Material Single-Slot Intake Experiment And Human Review Stop - 2026-06-06

This checkpoint tests only one isolated private hybrid Barrosan Barracks material slot. It generates exactly one original ignored material-source image, creates deterministic local derivatives, validates a tracked diagnostic fallback, fairly benchmarks Tier S/M/L private comparator evidence with v0.148 Worker context, selects the 768 derivative after the preserved gate passes, and stops for Emmanuel review.

Added:

- One ignored local material source under `artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/`.
- Deterministic ignored 512, 768, and 1024 Barracks material derivatives plus metadata.
- Tracked deterministic fallback PNG and contract for clean-checkout validation.
- Private comparator `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd`.
- Validation, fallback reproducibility, derivative reproducibility, fair-path audit, headed benchmark, capture wrappers, and `GODOT_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- v0.149 docs for intake spec, slot contract, derivative matrix, fair-path audit, paired benchmark report, visual review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--barrosan-barracks-material-single-slot` dispatch path only.
- Desktop-spike scaffold tests now assert the v0.149 Barracks material path remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.149 as the current private comparator human review stop.

Evidence:

- Generated source SHA-256: `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c`, dimensions `1254 x 1254`.
- Fallback SHA-256: `473ea8fd00a42716d2130109d2d3eb30f0a5eb3751fe0445af773a5bf0731767`, dimensions `512 x 512`.
- Selected derivative: `HYBRID_BARRACKS_LOCAL_768`.
- Selected SHA-256: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`, dimensions `768 x 768`.
- Original gate: `PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE`.
- Tier L baseline mean FPS: `1784.09`; selected Tier L mean FPS: `1873.11`; average FPS ratio `1.0499`.
- Tier L baseline mean p95 frame time: `0.94 ms`; selected p95 `0.85 ms`; p95 ratio `0.9043`.
- Fair-path audit: `PASS_V0149_BARRACKS_MATERIAL_FAIR_PATH_AUDIT`, with one texture load/create per source, one material create per source/material key, and no repeated texture/material creation during steady-state frames.

Boundaries:

- Exactly one new AI image.
- No existing reference candidate import.
- No generated reference image import.
- No downloaded asset use.
- No third runtime-art slot.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Barracks material approval, final engine selection, full port, or v0.150 work.

Verification:

- Required v0.149 verification is listed in `docs/V0149_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.148 Hybrid Worker Billboard Single-Slot Repair Fair Benchmark And Human Review Stop - 2026-06-06

This checkpoint repairs and fairly benchmarks only the existing private hybrid Worker billboard single-slot path. It uses the existing ignored v0.147 Worker source/cutout, generates zero new AI images, adds no second runtime-art slot, preserves the original gate, captures fair-path Tier S/M/L evidence, and stops for Emmanuel review.

Added:

- Deterministic ignored repair derivatives under `artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/`: trimmed 512, 768, and 1024 Worker PNGs plus metadata.
- Repair validation, fair-path audit, derivative reproducibility, headed benchmark, and capture wrappers.
- One-click wrapper `GODOT_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat`.
- Private comparator repair sequencing with five Tier L trials, rotated order, cached texture/material reuse counters, and alpha/pivot review captures.
- v0.148 docs for repair spec, fair-path audit, derivative matrix, paired benchmark report, alpha/pivot review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--worker-billboard-single-slot-repair` dispatch path only.
- `tools/godot/workerBillboardSingleSlotTool.mjs` now records v0.148 derivative reproducibility, threshold, evidence, and fair-path audit reports.
- Desktop-spike scaffold tests now assert the v0.148 repair path remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.148 as the current repair benchmark and human review stop.

Evidence:

- Selected derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Selected SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`, dimensions `1024 x 1024`.
- Original gate: `PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE`.
- Tier L baseline mean FPS: `858.41`; selected Tier L mean FPS: `851.14`; average FPS ratio `0.9915`.
- Tier L baseline mean p95 frame time: `1.87 ms`; selected p95 `1.88 ms`; p95 ratio `1.0053`; p95 absolute delta `0.01 ms` context only.
- Fair-path audit: `PASS_V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT`, with one texture load/create per source, one material create per source/tint, and no repeated texture/material creation during steady-state frames.

Boundaries:

- Zero new AI images.
- No second runtime-art slot.
- No existing reference candidate import.
- No generated reference image import.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Worker design approval, final engine selection, full port, or v0.149 work.

Verification:

- Required v0.148 verification is listed in `docs/V0148_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.147 Hybrid Worker Billboard Single-Slot Runtime-Art Intake Experiment And Human Review Stop - 2026-06-06

This checkpoint adds one isolated private Worker billboard single-slot intake experiment for human review. It uses the v0.146 hybrid recommendation, generates exactly one original local Worker cutout, validates it against a deterministic tracked fallback, captures Tier S/M/L private comparator evidence, records the threshold scorecard, and stops for Emmanuel review.

Added:

- One ignored local Worker cutout source/alpha slot under `artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/`.
- Deterministic tracked diagnostic fallback under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/`.
- Private comparator script `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd`.
- One-click wrapper `GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- npm scripts `godot:worker-billboard:validate`, `godot:worker-billboard:fallback:reproduce`, `godot:worker-billboard:benchmark:headed`, and `godot:worker-billboard:capture`.
- Evidence/metadata tool `tools/godot/workerBillboardSingleSlotTool.mjs`.
- v0.147 docs for intake spec, slot contract, validation report, benchmark report, visual review guide, private boundary, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--worker-billboard-single-slot` dispatch path only.
- Desktop-spike scaffold tests now assert the Worker billboard experiment remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.147 as a one-image, private-comparator human review stop.

Evidence:

- Local Worker cutout: SHA-256 `e294115817821eb84a459f6c86110d7b6951ad34182802bf6b0c07f560cab88a`, dimensions `1254 x 1254`, matte-to-alpha transparent PNG.
- Tracked fallback: SHA-256 `fa60b6e6a86b41cb449c3a16a0401cf44fbab8b5faefd7f19147b3a8c6161419`, dimensions `512 x 512`, transparent diagnostic fallback.
- Tier L threshold: `FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD`, local average FPS ratio `0.8464`, local p95 frame-time ratio `1.3697`, local p95 absolute delta `0.44 ms`; the p95 delta stayed within the recorded `0.50 ms` local headed jitter allowance, but the average-FPS gate missed the `0.90` target.

Boundaries:

- Exactly one AI-generated image.
- No existing reference candidate import.
- No downloaded asset use.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final Worker design approval, final engine selection, full port, or v0.148 work.

Verification:

- Required v0.147 verification is listed in `docs/V0147_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.146 Godot Runtime-Art Pipeline Comparator Spike And Human Decision Stop - 2026-06-06

This checkpoint adds an isolated private Godot runtime-art pipeline comparator and evidence packet for human review. It validates the v0.145 reference-art workspace, encodes the HUD reference decision, runs procedural-only Tier S/M/L comparisons for three possible runtime-art approaches, records the scorecard, recommends a single next experiment, and stops for Emmanuel review.

Added:

- Private comparator scene/script under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/`.
- One-click wrapper `GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat`.
- npm scripts `godot:runtime-art-comparator:validate`, `godot:runtime-art-comparator:benchmark:headed`, and `godot:runtime-art-comparator:capture`.
- Evidence post-processor `tools/godot/runtimeArtComparatorTool.mjs`.
- v0.146 docs for comparator spec, benchmark report, scorecard, recommendation, Emmanuel review guide, boundary report, and implementation report.

Changed:

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd` now has a private `--runtime-art-comparator` dispatch path only.
- Desktop-spike scaffold tests now assert the comparator remains isolated from the normal Salto player slice and default launchers.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.146 as a comparator evidence and human decision stop.

Recommendation:

- Recommended next single-slot runtime-art experiment: `HYBRID_3D_WORLD_BILLBOARD_UNITS`.
- Fallback comparator: `ORTHO_3D_MESH`.
- Deferred for the next slot: `BILLBOARD_2D_ATLAS`.

Boundaries:

- Zero image generation.
- No generated reference image import.
- No downloaded asset use.
- No normal Salto player-slice mutation.
- No player-facing Godot wiring or browser-runtime wiring.
- No manifest mutation, art-slot mutation, production package mutation, save change, stable-ID change, final runtime-art approval, final engine selection, full port, or v0.147 work.

Verification:

- Required v0.146 verification is listed in `docs/V0146_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.145 Salto HUD Reference-Style Exploration And Human Review Stop - 2026-06-06

This checkpoint generates exactly three Salto HUD reference-style frames for human review. It encodes the v0.144 silhouette review decision inside the generation milestone, keeps all images ignored local reference candidates only, preserves `runtimeIntegrationStatus = forbidden`, regenerates the contact sheet and review pack for fifteen total candidates, and records tracked review docs.

Added:

- Three ignored local Salto HUD reference-style candidates under `artifacts/art-review/v0138/candidates/`.
- Three ignored matching metadata files under `artifacts/art-review/v0138/metadata/`.
- Ignored v0.145 local human review note under `artifacts/art-review/v0138/review-notes/`.
- v0.145 docs for the HUD generation report, HUD review guide, reference-only boundary, and implementation report.

Changed:

- Regenerated ignored v0.138 reference-art validation, contact-sheet, and review-pack outputs for fifteen total candidates.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.145 as a reference-only Salto HUD human-review stop.

Boundaries:

- Exactly three frames only.
- No production UI asset lock.
- No runtime-art integration.
- No character portrait, character generation, environment generation, sprite, texture, model, icon-as-asset, UI kit, atlas, animation sheet, or additional frame generation.
- No Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.146 work.

Verification:

- Required v0.145 verification is listed in `docs/V0145_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.144 Aster / Worker Silhouette-Scale Convergence Revisions And Human Review Stop - 2026-06-06

This checkpoint generates exactly three Aster / Worker silhouette-scale convergence boards for human review. It encodes the v0.143 review direction inside the generation milestone, keeps all images ignored local reference candidates only, preserves `runtimeIntegrationStatus = forbidden`, regenerates the contact sheet and review pack for twelve total candidates, and records tracked review docs.

Added:

- Three ignored local Aster / Worker silhouette-scale convergence candidates under `artifacts/art-review/v0138/candidates/`.
- Three ignored matching metadata files under `artifacts/art-review/v0138/metadata/`.
- Ignored v0.144 local human review note under `artifacts/art-review/v0138/review-notes/`.
- v0.144 docs for the convergence report, silhouette convergence review guide, reference-only boundary, and implementation report.

Changed:

- Regenerated ignored v0.138 reference-art validation, contact-sheet, and review-pack outputs for twelve total candidates.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.144 as a reference-only Aster / Worker silhouette convergence human-review stop.

Boundaries:

- Exactly three boards only.
- No final character design lock.
- No HUD, portrait, environment, broad unit-roster, sprite, texture, model, UI kit, turnaround, animation-pose, animation-sheet, or additional board generation.
- No Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.145 work.

Verification:

- Required v0.144 verification is listed in `docs/V0144_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.143 Aster / Worker Silhouette-Scale Reference Boards And Human Review Stop - 2026-06-06

This checkpoint generates exactly three Aster / Worker silhouette-scale comparison boards for human review. The images remain ignored local reference candidates only. Matching metadata keeps `runtimeIntegrationStatus = forbidden`, the contact sheet and review pack are regenerated for nine total candidates, and tracked docs record the review guide and hard runtime boundary.

Added:

- Three ignored local Aster / Worker silhouette-scale candidates under `artifacts/art-review/v0138/candidates/`.
- Three ignored matching metadata files under `artifacts/art-review/v0138/metadata/`.
- Ignored v0.143 local human review note under `artifacts/art-review/v0138/review-notes/`.
- v0.143 docs for the generation report, silhouette-scale review guide, reference-only boundary, and implementation report.

Changed:

- Regenerated ignored v0.138 reference-art validation, contact-sheet, and review-pack outputs for nine total candidates.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.143 as a reference-only Aster / Worker silhouette-scale human-review stop.

Boundaries:

- Exactly three boards only.
- No final character design lock.
- No HUD, portrait, environment, broad unit-roster, sprite, texture, model, UI kit, turnaround, animation-pose, animation-sheet, or additional board generation.
- No Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.144 work.

Verification:

- Required v0.143 verification is listed in `docs/V0143_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.142 Salto Environment Reference-Only Style Lock Ratification And Silhouette Brief Preparation - 2026-06-06

This checkpoint ratifies Emmanuel's completed v0.141 style-lock review without generating images or integrating art. It records R1 as the primary Salto environment reference-only style lock, R2 as the companion material/atmosphere reference, R3 as a limited lane/Ashen-readability reference, and prepares the next Aster/Worker silhouette-scale brief for a future explicit v0.143 prompt.

Added:

- Ignored local v0.142 style-lock decision note under `artifacts/art-review/v0138/review-notes/`.
- `docs/art-prompts/V0143_01_ASTER_WORKER_SILHOUETTE_SCALE_BOARD.md`.
- v0.142 docs for the environment reference style lock, silhouette brief preparation, reference-only boundary, and implementation report.

Changed:

- Regenerated ignored v0.138 reference-art validation, contact-sheet, and review-pack outputs for the existing six environment candidates.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.142 as a reference-only ratification and brief-preparation stop.

Boundaries:

- Zero image generation.
- No HUD, Aster, Worker, unit, sprite, texture, model, portrait, UI kit, animation, or extra candidate generation.
- No Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.143 execution.

Verification:

- Required v0.142 verification is listed in `docs/V0142_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.141 Salto Environment Style-Lock Revision Round And Human Approval Stop - 2026-06-06

This checkpoint uses the v0.140 canary review direction to generate exactly three revised Salto environment reference-only candidates. Candidate A is the primary visual base, Candidate C is the tactical-layout reference, and Candidate B is only a restrained atmosphere reference. It validates six total candidate metadata files, rebuilds the local contact sheet and review pack, updates tracked review docs, and stops for Emmanuel's style-lock review.

Added:

- Three ignored local revised environment candidates under `artifacts/art-review/v0138/candidates/`.
- Three ignored matching metadata files under `artifacts/art-review/v0138/metadata/`.
- Ignored v0.141 local style-lock review note under `artifacts/art-review/v0138/review-notes/`.
- v0.141 docs for the revision report, style-lock review guide, reference-only boundary, and implementation report.

Changed:

- Regenerated ignored v0.138 reference-art validation, contact-sheet, and review-pack outputs for six total environment candidates.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.141 as a reference-only style-lock revision stop.

Boundaries:

- No HUD, Aster, Worker, unit, sprite, texture, model, UI kit, animation, or extra candidate generation.
- No Godot wiring, browser wiring, runtime import, art-slot mutation, save change, stable-ID change, final art choice, protected-IP approval, or v0.142 work.

Verification:

- Required v0.141 verification is listed in `docs/V0141_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.140 Salto Environment Reference-Art Canary Generation And Human Style-Lock Stop - 2026-06-06

This checkpoint tests the enabled Codex image-generation capability in a controlled reference-only canary session. It generates exactly three Salto environment candidates for human review, validates matching metadata, builds the local contact sheet and review pack, and stops for Emmanuel's art review.

Added:

- Three ignored local environment candidates under `artifacts/art-review/v0138/candidates/`.
- Three ignored matching metadata files under `artifacts/art-review/v0138/metadata/`.
- Regenerated ignored v0.138 reference-art validation, contact-sheet, and review-pack outputs.
- v0.140 docs for the canary generation report, reference-only boundary, Emmanuel art review guide, and implementation report.

Changed:

- Handoff, roadmap, development checkpoint, and release checklist now describe v0.140 as a reference-only art canary stop.

Boundaries:

- No HUD, Aster, Worker, unit, sprite, texture, model, animation, or extra variant generation.
- No Godot wiring, browser wiring, runtime import, art-slot mutation, save change, stable-ID change, final art choice, protected-IP approval, or v0.141 work.

Verification:

- Required v0.140 verification is listed in `docs/V0140_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.139 Godot Salto Slice Stabilization Gate, Human Review Package, And Next-Phase Roadmap - 2026-06-06

This checkpoint consolidates the current packaged Godot Salto player-facing slice into one stabilized human-review package. It remains a bounded review and roadmap checkpoint: no gameplay systems, generated images, asset downloads, runtime art imports, final Godot choice, full port, browser-runtime change, save change, stable-ID change, multiplayer, or v0.140 work.

Added:

- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- `GODOT_VALIDATE_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- `GODOT_CAPTURE_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- v0.139 PowerShell wrappers under `tools/godot/`.
- `tools/godot/generateGodotStabilizationReviewPack.mjs`.
- Ignored v0.139 artifacts under `artifacts/desktop-spikes/godot-salto/v0139/`: gate, triple-playthrough, usability, performance, screenshot manifest/hash wrappers, package report, scorecard update, and README.
- v0.139 docs for stabilization gate, final review build, Emmanuel review guide, next-phase options, and implementation report.

Changed:

- Handoff, roadmap, development checkpoint, and release checklist now describe v0.139.
- The recommended next phase is Option A only after explicit approval: generate four reference-only style frames and stop for human art review.

Verification:

- Required v0.139 verification is listed in `docs/V0139_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.133.1 Godot Test11 Combat Readability And Wave Playability Repair - 2026-06-05

This repair responds to Emmanuel's `test11` packaged-build recording. Objective 8 reached the Ashen wave, but stale Worker/Barracks context, a heavy top battle banner, visible reserve clutter, and weak target marking made the fight hard to read and hard to finish.

Changed:

- Objective 8 now stages a readable four-attacker Ashen lane and a visible defender line.
- The wave launch hands off to the defender squad and records `combat_defender_handoff`.
- Empty combat box-select attempts preserve the defender squad and record `box_select_empty_preserved_defenders`.
- All active Ashen attackers are target-marked while the wave objective is active.
- The visible `Attack` button now issues a wave-defense order that carries the fight across all four active attackers.
- The redundant top player-shell battle banner was removed so battle guidance does not cover the playfield.
- Objective 8 HUD copy now reports the remaining Ashen count and points to `Attack` or right-click targeting.

Scope unchanged: no Godot editor work, no runtime art import, no save change, no stable-ID change, no browser runtime change, no full port, no final engine choice, and no v0.134 work.

# v0.133 Godot Post-Mine Sequence Repair, Barracks-Recruit Guidance, Ashen-Wave Trigger, And Real Combat-Onset Proof - 2026-06-05

This checkpoint repairs the player-facing Godot Salto flow after Worker assignment. It replaces loose post-mine objective jumps with guarded prerequisites, removes the box-select skip into Ashen pressure, guides Barracks restoration and Militia recruitment through ordinary RTS input, starts a visible Ashen countdown, launches the bounded wave automatically, proves enemy movement and combat onset, defeats the wave through simulation/input, restores the Lume link, and reaches Results. It remains a bounded Godot spike repair: no generated images, imported runtime art, final Godot choice, full port, Unity project, browser-runtime change, save change, stable-ID change, broad economy, broad building tree, broad recruitment, campaign expansion, multiplayer, or v0.134 work.

Added:

- `GODOT_POST_MINE_FLOW_SMOKE_WINDOWS.bat`.
- `GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat`.
- `tools/godot/runGodotPostMineFlowSmokeWindows.ps1`.
- `npm run godot:validate:post-mine-flow`.
- `npm run godot:headed:post-mine-flow-smoke`.
- v0.133 ignored artifact generation for post-mine trace, prerequisite report, Barracks restoration proof, Militia recruit proof, pressure countdown proof, wave launch proof, combat onset proof, wave defeat proof, Lume restore proof, screenshot manifest, screenshots, and README.
- v0.133 docs for the objective-state audit, prerequisite ledger, Barracks guidance, Militia guidance, Ashen countdown, combat onset, Lume restore, headed proof, gate, implementation report, and Emmanuel retest guide.

Changed:

- The player-facing Godot sequence now advances from Worker assignment to Barracks restoration, Militia training, Ashen countdown, wave defense, Lume restoration, and Results through normal packaged-window input and simulation.
- Box selection changes selection only and cannot skip to Ashen pressure before required prerequisites are satisfied.
- The v0.133 artifact root is `artifacts/desktop-spikes/godot-salto/v0133/`.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.133.

Verification:

- Required v0.133 verification is listed in `docs/V0133_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.130 Godot Salto Vertical-Slice Acceptance Pack, Human Review Build, And First Reference-Art Generation Session - 2026-06-05

This checkpoint packages the existing Godot Salto player-facing slice for Emmanuel review and prepares the first four reference-only art generation prompts. It remains a bounded review-preparation checkpoint: no generated images, imported runtime art, final Godot choice, full port, Unity project, browser-runtime change, save change, stable-ID change, broad campaign, multiplayer, or v0.131 work.

Added:

- `GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat`.
- `GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat`.
- `GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat`.
- v0.130-specific validation and capture scripts under `tools/godot/`.
- v0.130 ignored artifact generation for validation, acceptance gate, performance smoke, objective flow, screenshot manifest, screenshot hashes, package report, scorecard update, contact sheet, and README.
- v0.130 docs for the acceptance gate, final human review build, first reference-art session, reference-art workflow, Emmanuel decision packet, and implementation report.

Changed:

- The v0.130 artifact root is `artifacts/desktop-spikes/godot-salto/v0130/`.
- The default human-review path is named explicitly as the Salto vertical slice while the private engineering harness stays separate.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.130.

Verification:

- Required v0.130 verification is listed in `docs/V0130_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.124 Godot Player-Facing Salto Review Slice, Private Harness Separation, And Art-Ready Presentation Shell - 2026-06-04

This checkpoint separates the private engineering harness from a new player-facing Salto review slice. It makes `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat` the default human-review path, keeps `GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat` for engineering review, and adds v0.124 validation/capture artifacts for the player-facing flow. It remains a bounded placeholder-only Godot workflow spike: no final engine choice, full port, generated image, imported art, runtime art integration, browser replacement, gameplay change, save change, stable-ID rename, multiplayer, or v0.125 work.

Added:

- Player-facing launch, validate, and capture wrappers plus npm scripts.
- Title, briefing, battle, and Results player-slice flow.
- Procedural Salto composition, differentiated silhouettes, compact HUD/minimap, and Lume presentation improvements.
- v0.124 artifact reports for player-slice validation, objective flow, performance smoke, screenshot hashes, and art slots.
- v0.124 docs and Emmanuel player-slice review guide.

Changed:

- Packaged Godot ZIP evidence now uses the v0.124 package name.
- The old review launcher defaults to the private harness instead of being the human-review default.
- Handoff, roadmap, development checkpoint, release checklist, package scripts, and focused scaffold tests now describe v0.124.

Verification:

- Required v0.124 verification is listed in `docs/V0124_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.123 Godot Continuation Decision Packet, Unity Comparator Boundary, And First Reference-Art Prompt Library - 2026-06-04

This checkpoint consolidates the Godot Salto workflow evidence into Emmanuel's continuation decision packet. It classifies the current Godot spike as `GODOT_SPIKE_GREEN` for careful next-spike planning, defines the Unity comparator boundary, creates a simple Emmanuel review guide, and adds the first copy-ready reference-art prompt library. It keeps the work inside docs, scorecard interpretation, validation-boundary maintenance, and reference-only prompt preparation: no final engine choice, full port, Unity project, Unreal project, Electron wrapper, image generation, runtime art import, browser replacement, gameplay change, save change, stable-ID rename, multiplayer, content expansion, or v0.124 work.

Added:

- `docs/V0123_GODOT_CONTINUATION_GATE.md`.
- `docs/V0123_GODOT_SCORECARD_UPDATE.md`.
- `docs/V0123_UNITY_COMPARATOR_BOUNDARY.md`.
- `docs/V0123_EMMANUEL_GODOT_REVIEW_GUIDE.md`.
- `docs/V0123_REFERENCE_ART_REVIEW_BOUNDARY.md`.
- `docs/V0123_IMPLEMENTATION_REPORT.md`.
- `docs/art-prompts/V0123_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md`.
- `docs/art-prompts/V0123_02_BARROSAN_HERO_SILHOUETTE_SHEET.md`.
- `docs/art-prompts/V0123_03_BARROSAN_WORKER_SILHOUETTE_SHEET.md`.
- `docs/art-prompts/V0123_04_BARROSAN_MILITIA_RANGER_SILHOUETTE_SHEET.md`.
- `docs/art-prompts/V0123_05_COMMAND_HALL_BARRACKS_STYLE_SHEET.md`.
- `docs/art-prompts/V0123_06_LUME_VFX_STYLE_FRAME.md`.
- `docs/art-prompts/V0123_07_CAMPAIGN_MAP_STYLE_FRAME.md`.
- `docs/art-prompts/V0123_08_HUD_STYLE_FRAME.md`.

Changed:

- Handoff, roadmap, development checkpoint, and release checklist now describe v0.123.
- The desktop-spike fixture boundary validation now allows authorized v0.123 Godot docs and blocks v0.124 Godot follow-up docs instead.

Current evidence:

- v0.122 baseline pushed and remote CI green before v0.123 edits.
- Latest Godot scorecard remains `workflow-spike-content-adapter-parity-not-final-engine-choice`, total `78 / 100`, AI-operability `24 / 25`.
- v0.118 packaged headed smoke PASS.
- v0.120 fresh-checkout validation PASS with routine editor use false.
- v0.121 visual capture PASS with 32 captures and procedural 2.5D review presets.
- v0.122 adapter validation PASS, rules parity PASS, migration-readiness matrix PASS, Windows package PASS.

Verification:

- Required v0.123 verification is listed in `docs/V0123_IMPLEMENTATION_REPORT.md` and must be run before closeout.

# v0.118 Godot Packaged-Build Headed Smoke Automated Visual Capture And Human-Review Harness - 2026-06-04

This checkpoint extends the Godot Salto workflow spike with packaged-build headed smoke, deterministic screenshot capture, headed benchmarks, package validation, and Emmanuel's one-click review harness. It keeps the work inside the existing Godot spike and fixture boundary: no final engine choice, full port, browser replacement, gameplay change, save change, stable-ID rename, runtime art import, or v0.119 work.

Added:

- `GODOT_LAUNCH_REVIEW_WINDOWS.bat`.
- `GODOT_HEADED_SMOKE_WINDOWS.bat`.
- `GODOT_CAPTURE_REVIEW_WINDOWS.bat`.
- `tools/godot/launchGodotReviewWindows.ps1`.
- `tools/godot/runGodotHeadedSmoke.ps1`.
- `tools/godot/captureGodotReviewWindows.ps1`.
- `npm run godot:launch:review`.
- `npm run godot:headed:smoke`.
- `npm run godot:capture:review`.
- v0.118 docs: Emmanuel review guide, headed smoke spec, screenshot capture spec, package validation report, headed benchmark report, visual contact sheet report, and implementation report.

Changed:

- The Godot Salto root harness now supports packaged executable flags for review smoke, screenshot capture, and headed benchmark modes.
- The packaged review harness covers home, 2D launch, 2.5D launch, hero selection, Worker selection, squad selection, move, attack, pan, zoom, pause, site capture, Lume link, Results, return home, and exit.
- The 2D and 2.5D placeholder scenes now expose visible review-state changes for automated capture.
- The Godot spike viewport is fixed at 1600x900 for headed review captures.
- Godot export/package tooling refreshes stale Windows build outputs before packaging v0.118 artifacts.
- The desktop-spike fixture boundary validation now allows authorized v0.118 docs and blocks v0.119 docs instead.
- Handoff, roadmap, development checkpoint, and release checklist now describe v0.118.

Current evidence:

- Godot detected: `4.6.3.stable.official.7d41c59c4`.
- Export templates detected for `4.6.3.stable`.
- Fixture import PASS, fixture hash `d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3`.
- Packaged headed smoke PASS.
- Screenshot capture PASS, 15 deterministic 1600x900 screenshots plus manifest and SVG contact sheet.
- 2D headed benchmark PASS.
- 2.5D orthographic headed benchmark PASS.
- Package validation PASS.
- Ignored v0.118 artifact root: `artifacts/desktop-spikes/godot-salto/v0118/`.

Verification:

- `npm test` PASS.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS.
- `npm run export:desktop-spike-fixture` PASS.
- `npm run validate:desktop-spike-fixture` PASS.
- `npm run godot:all` PASS.
- `npm run godot:headed:smoke` PASS.
- `npm run godot:capture:review` PASS.
- `git diff --check` PASS.

# v0.117 Godot-First Automated Desktop Benchmark Spike And One-Click Windows Workflow - 2026-06-03

This checkpoint creates the first small Godot desktop benchmark spike and one-click Windows workflow. It uses the v0.116 engine-neutral Salto fixture, standard non-.NET Godot 4.6.3 x86_64, GDScript, text scenes, deterministic fixture import, headless validation/tests, 2D and 2.5D placeholder benchmarks, Windows export, Windows package assembly, scorecard output, and Emmanuel's one-click guide. It does not choose Godot finally, start a full port, replace the browser prototype, import art, change gameplay, change saves, rename stable IDs, or start v0.118.

Added:

- `desktop-spikes/godot-salto/`.
- `tools/godot/doctorGodotWindows.ps1`.
- `tools/godot/bootstrapGodotWindows.ps1`.
- `tools/godot/generateGodotSaltoScene.ps1`.
- `tools/godot/runGodotValidation.ps1`.
- `tools/godot/runGodotTests.ps1`.
- `tools/godot/runGodotBenchmark.ps1`.
- `tools/godot/exportGodotWindows.ps1`.
- `tools/godot/packageGodotWindows.ps1`.
- `tools/godot/runGodotAll.ps1`.
- Root `GODOT_*_WINDOWS.bat` wrappers.
- `npm run godot:*` scripts.
- `src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts`.
- v0.117 docs: scope, setup/bootstrap, fixture import, AI-first workflow, visual comparison, benchmark, Windows export, Emmanuel one-click guide, implementation report, and deferred findings.

Changed:

- `.gitignore` now ignores repository-local Godot tools, Godot cache, generated builds/reports, and ignored desktop-spike artifacts while preserving `.gitkeep` placeholders.
- The desktop-spike fixture boundary validation now allows authorized v0.117 docs and blocks v0.118 docs instead.
- Handoff, README, roadmap, development checkpoint, and release checklist now describe v0.117.

Current evidence:

- Godot detected: `4.6.3.stable.official.7d41c59c4`.
- Export templates detected for `4.6.3.stable`.
- Fixture import PASS, fixture hash `d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3`.
- Stable-ID validation PASS, selected IDs resolved, unknown probe rejected.
- `linked_ward` remains exactly `0.92`.
- Read-only save fixture posture preserved.
- Godot headless tests PASS.
- 2D placeholder benchmark PASS.
- 2.5D orthographic placeholder benchmark PASS.
- Windows export PASS, executable hash `6e1e999244d991ecc41374ad20066028bf37bc6f02982b46de5441401bf718d1`.
- Windows package PASS, ZIP hash `d65c85570350faead5d4cb0590d5f3a64670a125eb3177bc1b0ab1841f3e7f46`.
- Scorecard status: `workflow-spike-complete-not-final-engine-choice`, score `74 / 100`, AI-operability `24 / 25`.

Verification:

- `npm run godot:all` PASS.
- `npm test` PASS.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS.
- `npm run export:portable-content` PASS.
- `npm run validate:portable-content` PASS.
- `npm run test:save-translation-contract` PASS.
- `npm run export:desktop-spike-fixture` PASS.
- `npm run validate:desktop-spike-fixture` PASS.
- `git diff --check` PASS with Git's line-ending warning for `.gitignore`.

# v0.116 Reviewed Architecture Direction, Desktop-Engine Spike Preparation Pack, And Engine-Neutral Salto Fixture - 2026-06-03

This checkpoint creates the reviewed architecture direction, engine-candidate matrix, AI-first/editor-optional desktop spike acceptance contract, Emmanuel review packet, reference-art continuation boundary, scorecard template, and deterministic engine-neutral Salto fixture export/validation tooling. It does not choose an engine, add an engine dependency, create an engine project, create a desktop wrapper, start a port, change runtime gameplay, change saves, rename stable IDs, import art, or start v0.117.

Added:

- `docs/V0116_ARCHITECTURE_DECISION_RECORD.md`.
- `docs/V0116_ENGINE_CANDIDATE_MATRIX.md`.
- `docs/V0116_RECOMMENDED_ENGINE_SPIKE_ORDER.md`.
- `docs/V0116_DESKTOP_SPIKE_ACCEPTANCE_CONTRACT.md`.
- `docs/V0116_DESKTOP_SPIKE_FIXTURE_EXPORT_SPEC.md`.
- `docs/V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json`.
- `docs/V0116_EMMANUEL_ARCHITECTURE_REVIEW_PACKET.md`.
- `docs/V0116_REFERENCE_ART_CONTINUATION_BOUNDARY.md`.
- `docs/V0116_IMPLEMENTATION_REPORT.md`.
- `src/game/desktop-spike/DesktopSpikeFixture.ts`.
- `src/game/desktop-spike/DesktopSpikeFixture.test.ts`.
- `tools/exportDesktopSpikeFixture.ts`.
- `tools/validateDesktopSpikeFixture.ts`.
- `npm run export:desktop-spike-fixture`.
- `npm run validate:desktop-spike-fixture`.

Changed:

- The roadmap and handoff now frame future engine spikes around Codex-led automation, reproducible setup, manifest-driven import, one-command validation, CLI build/export/benchmark/package work, and editor-optional routine development for Emmanuel.
- The fixture artifact root `artifacts/desktop-spike-fixture/` is ignored because it is regenerated from repository sources.

Current evidence:

- v0.115 browser gate remains RED.
- `linked_ward` remains exactly `0.92`.
- The fixture is engine-neutral and derives from existing portable content, stable IDs, save fixtures, benchmark definitions, Lume data, and reference-only art docs.
- Future visual review should assess a modern original RTS/RPG direction inspired by the spirit of a 2026 Warlords Battlecry evolution, without copying its IP, assets, lore, UI, or mechanics.

Verification:

- `npm test` PASS, 120 files / 830 tests.
- `npm run build`, `npm run validate:content`, and `npm run validate:art-intake` PASS.
- `npm run export:portable-content` PASS, 229 stable manifest entries.
- `npm run validate:portable-content` PASS with byte-for-byte determinism.
- `npm run test:save-translation-contract` PASS, 16 fixtures, 11 translated, 2 quarantined, 3 rejected.
- `npm run export:desktop-spike-fixture` and `npm run validate:desktop-spike-fixture` PASS, fixture hash `d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3`, 12 files matched byte-for-byte.
- `git diff --check` PASS with Git's line-ending warning for `.gitignore`.

# v0.115 Trusted Performance Consolidation, Clean-Restart Retest Packet, And Browser Gate - 2026-06-03

This checkpoint consolidates v0.109-v0.114 trusted browser performance evidence, creates Emmanuel's clean-restart retest packet and performance decision packet, and sets the browser performance gate to RED. It changes docs, package metadata/docs, and validation tests only: no runtime gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, art, runtime asset paths, public benchmark controls, engine posture, desktop implementation, multiplayer, PvP, co-op, content, or v0.116 work changed.

Added:

- `docs/V0115_BROWSER_PERFORMANCE_GATE.md`.
- `docs/V0115_CONSOLIDATED_PERFORMANCE_REPORT.md`.
- `docs/V0115_EMMANUEL_CLEAN_RESTART_RETEST.md`.
- `docs/V0115_EMMANUEL_PERFORMANCE_DECISION_PACKET.md`.
- `docs/V0115_IMPLEMENTATION_REPORT.md`.
- `src/game/playtest/TrustedPerformanceConsolidationGate.ts`.
- `src/game/playtest/TrustedPerformanceConsolidationGate.test.ts`.

Changed:

- Private package generation and validation now expect `v0.115 Trusted Performance Consolidation, Clean-Restart Retest Packet, and Browser Gate` and include v0.115 docs.
- Handoff, roadmap, development checkpoint, release checklist, and package build notes now frame the browser gate as RED.

Current evidence:

- v0.111 blank/simple DOM/simple canvas/true Phaser-empty controls remain about 60 FPS with 16.7 ms p95.
- v0.114 Tier M combat remains 2.4 FPS / 566.6 ms p95; Tier M moving remains 2.4 FPS / 633.3 ms p95 after the v0.115 verification refresh.
- v0.115 gate result is RED. Runtime art integration and broad browser visual expansion remain blocked.

Verification:

- `npm test` PASS, 119 files / 820 tests.
- `npm run build`, `npm run validate:content`, and `npm run validate:art-intake` PASS.
- Required trusted performance commands PASS: host snapshot, preview controls, clean profile, trusted preview, phase profile, allocation audit, spatial-query profile, render-lifecycle audit, and trusted report.
- Required benchmark commands PASS: smoke, representative, stress, and report.
- `npm run package:playtest` and `npm run verify:playtest-package` PASS pre-commit, 459 package checks.
- Browser plugin smoke PASS at `http://127.0.0.1:5260/` with a visible canvas and only the Phaser banner in dev logs.

# v0.111 Host Environment Calibration, Clean-Browser Reproducibility, And Machine-Pressure Gate - 2026-06-03

This checkpoint adds private host-environment calibration, browser control baselines, temporary clean-profile reproducibility, machine-pressure classification, private Performance Lab instruction buttons, and post-restart retest guidance. It extends v0.109/v0.110 benchmark evidence without changing gameplay, saves, stable IDs, rewards, balance, maps, factions, art, user browser profiles, OS settings, public runtime posture, engine choice, desktop implementation, desktop saves, multiplayer, PvP, co-op, or v0.112 scope.

Added:

- `src/game/playtest/HostEnvironmentCalibration.ts`.
- `src/game/playtest/HostEnvironmentCalibration.test.ts`.
- `tools/runHostEnvironmentCalibration.ts`.
- `npm run perf:host-snapshot`, `npm run perf:controls:preview`, `npm run perf:controls:headed`, `npm run perf:trusted:clean-profile`, and `npm run perf:controls:report`.
- Private Playtest Hub controls for host snapshot, browser control baselines, clean-profile benchmark, environment comparison export, and post-restart instructions.
- Ignored artifact roots `artifacts/performance/host-snapshots/` and `artifacts/performance/v0111/`.
- v0.111 docs: host snapshot spec, browser control baselines, clean-profile benchmark spec, machine-pressure classification, Emmanuel post-restart retest, and implementation report.

Changed:

- Private package generation and validation now expect `v0.111 Host Environment Calibration, Clean-Browser Reproducibility, and Machine-Pressure Gate` and include v0.111 docs.

Not changed:

- No unrelated process killing, reboot, OS setting change, user browser profile mutation, browser history collection, open-tab collection, private process command-line collection, save-version bump, save field, localStorage key, stable ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, race, unit, building, generated/imported art, runtime asset path, desktop path, engine choice, multiplayer, PvP, co-op, runtime title, or v0.112 work changed.
- `linked_ward` remains exactly `0.92`.

Current evidence:

- `npm run perf:host-snapshot` PASS.
- `npm run perf:controls:preview` PASS, 6 rows.
- `npm run perf:trusted:clean-profile` PASS.
- `npm run perf:controls:report` PASS, 10 rows.
- Classification: `HOST_PRESSURE_UNLIKELY` and `BATTLE_CODE_DOMINANT`.
- Preview controls: blank rAF 60.1 FPS / p95 16.7 ms; simple DOM 60.1 FPS / p95 16.7 ms; simple canvas 60.1 FPS / p95 16.7 ms; Phaser empty scene 60 FPS / p95 16.7 ms; campaign map 9.9 FPS / p95 183.4 ms; Tier M battle 2.5 FPS / p95 516.6 ms.
- Clean-profile controls: blank rAF 60.1 FPS / p95 16.7 ms; Phaser empty scene 60 FPS / p95 16.7 ms; campaign map 9.8 FPS / p95 300 ms; Tier M battle 2.5 FPS / p95 483.3 ms.
- Browser plugin private hub check PASS at `http://127.0.0.1:5230/`: five v0.111 private controls visible, environment export template included commands and safety fields, and post-restart instructions opened.
- `npm run test:e2e:smoke:fast` PASS, 10 tests.
- `npm run package:playtest` PASS before commit, producing the expected dirty package for pre-commit validation.
- `npm run verify:playtest-package` PASS, 433 checks, after fixing the package validator's stale v0.110 checkpoint expectation.

# v0.110 Battle-Loop Phase Profiler, Runtime Bottleneck Isolation, And Controlled Performance Rescue - 2026-06-03

This checkpoint adds a private BattleScene phase profiler, a 22-row Performance Lab ladder, subsystem isolation toggles, density-scaling reports, and a trusted browser gate. It extends v0.109 benchmark integrity without changing gameplay, saves, stable IDs, rewards, balance, maps, factions, art, public runtime posture, engine choice, desktop implementation, desktop saves, multiplayer, PvP, co-op, or v0.111 scope.

Added:

- `src/game/playtest/BattleLoopPhaseProfiler.ts`.
- `src/game/playtest/BattleLoopPhaseProfiler.test.ts`.
- `tools/runBattleLoopPhaseProfile.ts`.
- `npm run perf:phase-profile:preview`, `npm run perf:subsystem-matrix`, `npm run perf:density-ladder`, `npm run perf:browser-gate`, and `npm run perf:v0110:report`.
- Private battle-session phase timing for scene/update, input-facing state, simulation clock, camera, abilities, movement/pathing, combat/projectiles, status effects, economy/production, Lume simulation/presentation, AI/strategy, cleanup, fog simulation/presentation, HUD DOM, and end-condition phases.
- Private/session-only subsystem switches for simulation, AI, path, movement, combat, projectiles, fog simulation, fog presentation, entity graphics, labels, capture rings, Lume, minimap, HUD DOM patches, notifications, camera, and profiler overlay.
- Ignored artifact root `artifacts/performance/v0110/`.
- v0.110 docs: phase profiler spec, subsystem isolation spec, density report, root-cause classification, controlled optimization report, browser performance gate, visual QA report, implementation report, Emmanuel retest, and deferred architecture findings.

Changed:

- Performance Lab now includes v0.110 phase-profiler and subsystem-isolation scenarios using existing private launch fixtures.
- Private package generation and validation now expect `v0.110 Battle-Loop Phase Profiler, Runtime Bottleneck Isolation, and Controlled Performance Rescue` and include v0.110 docs.
- Visual QA adds four private v0.110 phase-profiler/trusted-diagnostic captures and the review pack classifies them under Trusted Benchmark.

Not changed:

- No save-version bump, save field, localStorage key, stable ID, serialized ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, race, unit, building, Living Mine, generated/imported art, unapproved runtime image, runtime asset path, public benchmark control, desktop path, engine choice, multiplayer, PvP, co-op, runtime title, or v0.111 work changed.
- `linked_ward` remains exactly `0.92`.

Verification:

- Focused implementation tests PASS: BattleLoopPhaseProfiler, TrustedBrowserBenchmark, and PrivatePerformanceProfiler.
- `npx tsc -p tsconfig.json --noEmit` PASS.
- `npm test` PASS, 113 files / 788 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- Content, art-intake, runtime art slots, save translation, portable-content export, and portable-content validation gates PASS.
- Representative battle benchmarks PASS: smoke 1 scenario, representative 8 scenarios, stress 1 local-only scenario, report refreshed for 10 scenarios.
- Trusted v0.109 performance lanes PASS: preview, dev, root-cause matrix 19 cases, report refreshed for 21 rows.
- v0.110 performance lanes PASS as commands: phase profile 3 rows, subsystem matrix 17 rows, density ladder 5 rows, browser gate, and report refresh for 22 rows.
- v0.110 gate status is RED for v0110_tier_m_density: 2.5 FPS average, 516.6 ms p95, 533.3 ms max frame, and 52 long tasks. v0.111 and art-ready follow-up remain blocked until a separately approved architecture/performance rescue goal clears it.
- Browser smoke/playtest lanes PASS: fast smoke 10, full smoke 17, controls 18/18, extended controls 90/90, verifier 1,658 checks, Act 1 180 summarized runs from 255 deterministic simulator runs.
- Hosted release lanes PASS: smoke 17, deep-battle exact rerun 31 after the first 20-minute outer timeout, deep-campaign-pressure 8, layout-core 27, layout-cinderfen 12.
- `npm run visual:qa` exact rerun PASS after the first one-hour outer timeout, 21 tests / 244 screenshots / 0 console errors / 0 screenshot retries.
- `npm run visual:review-pack` PASS, 244 screenshots and 10 contact sheets. Browser plugin local review PASS for the localhost review pack with 244 screenshots and 4 v0.110 screenshot entries.

# v0.109 Browser Benchmark Integrity Audit And Performance Root-Cause Isolation - 2026-06-02

This checkpoint audits the suspicious v0.108 browser benchmark methodology, adds a trusted production-preview-first benchmark protocol, adds private manual benchmark flow and diagnostic toggles, generates a root-cause matrix, and updates visual QA/review-pack/package coverage. The trusted evidence still shows serious browser lag in the Tier M baseline, so the earlier 2-3 FPS evidence is mixed: old methodology was weak, but runtime cost remains real. It does not change gameplay, saves, stable IDs, rewards, balance, maps, factions, art, public runtime posture, engine choice, desktop implementation, or desktop saves.

Added:

- `src/game/playtest/TrustedBrowserBenchmark.ts`.
- `src/game/playtest/TrustedBrowserBenchmark.test.ts`.
- `tools/runTrustedBrowserBenchmark.ts`.
- `npm run perf:trusted:preview`, `npm run perf:trusted:dev`, `npm run perf:trusted:manual-template`, `npm run perf:root-cause-matrix`, and `npm run perf:trusted:report`.
- Private Playtest Hub `RUN TRUSTED MANUAL BENCHMARK` flow.
- Private battle-session diagnostic toggles for labels, rings, Lume, minimap refresh, fog visual redraw, HUD density, notifications, and profiler overlay.
- Ignored artifact root `artifacts/performance/v0109/`.
- `docs/V0109_PROFILER_METHOD_AUDIT.md`.
- `docs/V0109_TRUSTED_BROWSER_BENCHMARK_PROTOCOL.md`.
- `docs/V0109_EXECUTION_MODE_COMPARISON.md`.
- `docs/V0109_ROOT_CAUSE_MATRIX_REPORT.md`.
- `docs/V0109_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`.
- `docs/V0109_MANUAL_BENCHMARK_GUIDE.md`.
- `docs/V0109_VISUAL_QA_REPORT.md`.
- `docs/V0109_IMPLEMENTATION_REPORT.md`.
- `docs/V0109_EMMANUEL_RETEST_CHECKLIST.md`.
- `docs/V0109_DEFERRED_ENGINE_SPIKE_PREPARATION.md`.

Changed:

- Trusted benchmark reports separate launch, warm-up, steady-state, interaction, reset, return-to-hub, and Results transition timing.
- Private performance counters now include total labels, DOM nodes, memory trend when available, and additional frame-threshold counts above 100/250/500 ms.
- Visual QA now targets 240 screenshots, and the visual review pack emits a Trusted Benchmark contact sheet.
- Private package generation and validation now expect `v0.109 Browser Benchmark Integrity Audit and Performance Root-Cause Isolation` and include v0.109 docs.

Not changed:

- No save-version bump, save field, localStorage key, stable ID, serialized ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, generated/imported art, unapproved runtime image, runtime asset path, public benchmark control, desktop path, engine choice, multiplayer, PvP, co-op, or runtime title changed.
- `linked_ward` remains exactly `0.92`.
- v0.110, engine-spike preparation, and desktop port work were not started.

Verification:

- `npm test` PASS, 112 files / 783 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- Content, art-intake, portable-content export/validation, and save-translation contract gates PASS.
- Representative battle benchmarks PASS: smoke 1 scenario, representative 8 scenarios, stress 1 local-only scenario, report refreshed for 10 scenarios.
- Trusted benchmark commands PASS: manual template, preview 2 rows, dev 1 row, root-cause matrix 19 cases, report refreshed for 21 result rows.
- Browser smoke/playtest lanes PASS: fast smoke 10 tests, full smoke 17 tests, controls 18/18 rows, extended controls 90/90 rows, controls verifier 1,658 checks, Act 1 telemetry 180 summarized runs from 255 deterministic simulator runs.
- Hosted release lanes PASS: smoke 17 tests, deep-battle 31 tests, deep-campaign-pressure 8 tests, layout-core 27 tests, layout-cinderfen 12 tests.
- `npm run visual:qa` PASS after resolving the v0.109 visual-harness cleanup failure, 21 tests / 240 screenshots / 0 console errors / 0 screenshot retries.
- `npm run visual:review-pack` PASS, 240 screenshots and 10 contact sheets. Browser plugin manual review PASS for the Trusted Benchmark contact sheet, 27/27 images loaded.
- Pre-commit `npm run package:playtest`, `npm run verify:playtest-package`, and `git diff --check` are run before commit; final clean package generation and package verification are repeated after the checkpoint commit so the package does not carry a dirty suffix.

# v0.108 Representative Battle Benchmark Harness And Desktop Acceptance Profile - 2026-06-02

This checkpoint adds a private no-save representative battle benchmark harness, local browser benchmark scripts, provisional desktop acceptance profile, visual QA coverage, and package metadata/docs. It does not change gameplay, saves, stable IDs, rewards, balance, maps, factions, art, public runtime posture, engine choice, desktop implementation, or desktop saves.

Added:

- `src/game/playtest/RepresentativeBattleBenchmark.ts`.
- `src/game/playtest/RepresentativeBattleBenchmark.test.ts`.
- `tools/runRepresentativeBattleBenchmark.ts`.
- `tools/reportRepresentativeBattleBenchmark.ts`.
- `src/game/battle/BattleSceneResults.test.ts`.
- Private Playtest Hub group `REPRESENTATIVE BATTLE BENCHMARK` with ten benchmark entries.
- `npm run benchmark:battle:smoke`, `npm run benchmark:battle:representative`, `npm run benchmark:battle:stress`, and `npm run benchmark:battle:report`.
- Ignored benchmark artifact root `artifacts/benchmarks/v0108/`.
- `docs/V0108_REPRESENTATIVE_BATTLE_PROFILE.md`.
- `docs/V0108_BENCHMARK_SCENARIO_MANIFEST.json`.
- `docs/V0108_BROWSER_BATTLE_BENCHMARK_REPORT.md`.
- `docs/V0108_DESKTOP_ACCEPTANCE_PROFILE.md`.
- `docs/V0108_PERFORMANCE_DELTA_REPORT.md`.
- `docs/V0108_VISUAL_QA_REPORT.md`.
- `docs/V0108_IMPLEMENTATION_REPORT.md`.
- `docs/V0108_EMMANUEL_BENCHMARK_GUIDE.md`.

Changed:

- Private benchmark battle staging now creates representative Tier S/M/L no-save scenarios using existing runtime content only.
- Private Results handoff preserves Playtest Hub context for forced-victory benchmark transitions.
- Private package generation and validation now expect `v0.108 Representative Battle Benchmark Harness and Desktop Acceptance Profile` and include v0.107/v0.108 docs.
- Visual QA now targets 213 screenshots, and the visual review pack emits 9 contact sheets including Representative Benchmark.
- Private performance counter rates clamp scene-transition counter resets to zero instead of reporting negative rates.

Not changed:

- No save-version bump, save field, localStorage key, stable ID, serialized ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, generated/imported art, unapproved runtime image, runtime asset path, public benchmark control, desktop path, engine choice, multiplayer, PvP, co-op, or runtime title changed.
- Mine/shrine benchmark coverage uses existing capture-site infrastructure (`west_stone_cut` and `ford_toll`) and adds no mine or shrine building IDs.
- Tier L stress remains private/local-only evidence and is not a CI acceptance lane.

Verification:

- `npm test` PASS, 111 files / 777 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS, 1 candidate metadata JSON file checked and 0 review manifests.
- `npm run export:portable-content` PASS, 229 stable-ID manifest entries.
- `npm run validate:portable-content` PASS, deterministic two-pass export.
- `npm run test:save-translation-contract` PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
- `npm run benchmark:battle:smoke` PASS, 1 scenario.
- `npm run benchmark:battle:representative` PASS, 8 scenarios.
- `npm run benchmark:battle:stress` PASS, 1 local-only stress scenario.
- `npm run benchmark:battle:report` PASS, refreshed 10-scenario report.
- `npm run test:e2e:smoke:fast` PASS, 10 tests.
- `npm run visual:qa` PASS, 213 screenshots, 0 console errors, 0 retries.
- `npm run visual:review-pack` PASS, 213 screenshots and 9 contact sheets.
- Browser plugin check PASS, in-app Browser verified the new group and key benchmark entries.

Final clean package generation and package verification are repeated after the checkpoint commit so the package does not carry a dirty suffix.

# v0.107 Salto Vertical Slice Composition Plan And Asset-Dimension Contracts - 2026-06-02

This checkpoint defines the first polished Salto visual slice as docs, manifest validation, and metadata-only packet tooling. It does not generate images, import candidate art, load unapproved art, alter gameplay, change saves, rename stable IDs, change maps/factions/balance/rewards, choose an engine, start desktop work, change package metadata, or change the runtime title.

Added:

- `docs/V0107_SALTO_VERTICAL_SLICE_COMPOSITION_SPEC.md`.
- `docs/V0107_ASSET_DIMENSION_CONTRACTS.md`.
- `docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json`.
- `docs/V0107_GENERATION_DEPENDENCY_ORDER.md`.
- `docs/V0107_FIRST_SLICE_REVIEW_GATE.md`.
- `docs/V0107_IMPLEMENTATION_REPORT.md`.
- `docs/V0107_EMMANUEL_ART_GENERATION_CHECKLIST.md`.
- `tools/salto-slice/saltoSliceManifest.ts`.
- `tools/salto-slice/generateSaltoSlicePacket.ts`.
- `tools/salto-slice/saltoSlicePacket.test.ts`.
- `npm run art:packet:salto-slice`.
- Ignored `artifacts/art-review/salto-slice-packet/` metadata output.

Changed:

- The visual-intake gate now references the v0.107 Salto slice packet before any future first-slice candidate generation.
- The v0.105 first-generation packet now points to the v0.107 dependency order for the broader first Salto slice.
- Roadmap, handoff, checkpoint, and release docs now identify v0.107 as the current art-planning checkpoint.

Not changed:

- No save-version bump, save field, localStorage key, stable ID, serialized ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, generated image, imported image, unapproved runtime image, runtime asset path, package metadata, desktop path, engine choice, public diagnostic control, or runtime title changed.
- `runtime-candidate-approved` remains non-loadable. Runtime image loading still requires a future `runtime-integrated` asset under a separate runtime integration milestone.

Verification:

- `npx vitest run tools/salto-slice/saltoSlicePacket.test.ts --reporter=dot` PASS, 1 file / 9 tests.
- `npm run art:packet:salto-slice` PASS, metadata packet generated under ignored artifacts.
- `npm test` PASS, 109 files / 768 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS, 1 candidate metadata JSON file checked and 0 review manifests.
- `npm run art:review:validate` PASS, committed registry/schema checked and 0 candidate metadata files.
- `npm run validate:runtime-art-slots` PASS, 52 runtime art slots.
- `git diff --check` PASS with the existing `.gitignore` LF-to-CRLF warning.

# v0.106 Runtime Art Slot Adapter And Placeholder Fallback Harness - 2026-06-02

This checkpoint adds a typed runtime art slot contract and placeholder fallback harness for future approved runtime assets. It does not generate images, import candidate art, load unapproved art, alter gameplay, change saves, rename stable IDs, change maps/factions/balance/rewards, choose an engine, start desktop work, or change the runtime title.

Added:

- `src/game/art/RuntimeArtSlotTypes.ts`.
- `src/game/art/RuntimeArtSlots.ts`.
- `src/game/art/RuntimeArtSlotAdapter.ts`.
- `src/game/art/RuntimeArtSlotAdapter.test.ts`.
- `tools/runtime-art-slots/validateRuntimeArtSlots.ts`.
- `npm run validate:runtime-art-slots`.
- Private-only `Art Slots` diagnostics overlay.
- Private-only mock routing mode for slot review.
- `src/game/styles/runtime-art-slots.css`.
- `art_slot_fallbacks` private Playtest Hub scenario family.
- 14 v0.106 visual QA screenshots, bringing the visual QA matrix to 203 screenshots.
- `Art Slot Fallbacks` visual review-pack screen family and focused contact sheet.
- `docs/V0106_RUNTIME_ART_SLOT_CONTRACT.md`.
- `docs/V0106_PLACEHOLDER_FALLBACK_MATRIX.md`.
- `docs/V0106_ART_SLOT_VALIDATION_REPORT.md`.
- `docs/V0106_VISUAL_QA_REPORT.md`.
- `docs/V0106_IMPLEMENTATION_REPORT.md`.
- `docs/V0106_EMMANUEL_RUNTIME_ART_SLOT_GUIDE.md`.

Changed:

- Private package generation and package validation now expect `v0.106 Runtime Art Slot Adapter and Placeholder Fallback Harness`.
- Package docs now include v0.105 art registry/workspace docs plus v0.106 slot/fallback docs.
- Visual review pack now emits 8 contact sheets after visual QA.

Not changed:

- No save-version bump, save field, localStorage key, stable ID, serialized ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, generated image, imported image, unapproved runtime image, desktop path, engine choice, public diagnostic control, or runtime title changed.
- `runtime-candidate-approved` remains non-loadable. Runtime image loading requires a future `runtime-integrated` asset under `public/assets/runtime-art/`.

Verification:

- `npm run validate:runtime-art-slots` PASS, 52 runtime art slots.
- `npm test -- RuntimeArtSlotAdapter PlaytestScenarioGallery VisualReviewPack PlaytestPackageValidation` PASS, 4 files / 20 tests.
- `npm test` PASS, 108 files / 759 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS, 1 candidate metadata JSON file checked and 0 review manifests.
- `npm run art:review:validate` PASS.
- `npm run visual:qa` PASS, 203 screenshots, 0 console errors, 0 retries.
- `npm run visual:review-pack` PASS, 203 screenshots and 8 contact sheets.
- `npm run package:playtest` PASS for the pre-commit package.
- `npm run verify:playtest-package` PASS, 392 checks on the pre-commit package.
- `git diff --check` PASS.

Final clean package generation and package verification are repeated after the checkpoint commit so the package does not carry a dirty suffix.

# v0.105 Visual Asset Registry, Candidate Review Workspace, And Art-Intake Tooling - 2026-06-02

This checkpoint adds reference-only tooling for future art review. It does not generate images, import art, alter runtime asset paths, change gameplay, change saves, rename IDs, change package metadata, choose an engine, start desktop work, or start v0.106.

Added:

- `src/game/art/visual-asset-registry.schema.json`.
- `src/game/art/visual-asset-registry.json`.
- `src/game/art/VisualAssetReviewRegistry.ts`.
- `src/game/art/VisualAssetReviewRegistry.test.ts`.
- `tools/art-review/shared.ts`.
- `tools/art-review/initArtReviewWorkspace.ts`.
- `tools/art-review/validateArtReview.ts`.
- `tools/art-review/generateArtReviewContactSheet.ts`.
- `tools/art-review/generateArtReviewReport.ts`.
- `tools/art-review/artReviewTools.test.ts`.
- `npm run art:review:init`.
- `npm run art:review:validate`.
- `npm run art:review:contact-sheet`.
- `npm run art:review:report`.
- Ignored `artifacts/art-review/candidates/`, `artifacts/art-review/contact-sheets/`, and `artifacts/art-review/reports/` roots.
- `docs/V0105_VISUAL_ASSET_REGISTRY_SPEC.md`.
- `docs/V0105_CANDIDATE_REVIEW_WORKSPACE_SPEC.md`.
- `docs/V0105_ART_REVIEW_STATE_MACHINE.md`.
- `docs/V0105_FIRST_ART_GENERATION_PACKET.md`.
- `docs/V0105_IMPLEMENTATION_REPORT.md`.
- `docs/V0105_EMMANUEL_ART_REVIEW_GUIDE.md`.

Changed:

- README, roadmap, release checklist, checkpoint, handoff, v0.88 art-intake gate, and validation docs now describe v0.105's reference-only art-review tooling.
- The v0.88 vertical-slice asset plan is now mirrored into a deterministic registry sorted by stable `assetId`.

Not changed:

- No generated/imported art, runtime asset path, save-version bump, save field, localStorage key, stable ID, serialized ID, gameplay rule, reward, XP, balance value, campaign progression, map, faction, desktop implementation, engine choice, runtime title, or package metadata changed.
- Package generation and package verification are not required for v0.105 because package metadata and private package contents are unchanged.

Verification:

- `npm test -- VisualAssetReviewRegistry artReviewTools` PASS, 2 files / 16 tests.
- `npm run art:review:validate` PASS, committed registry and schema checked.
- `npm test` PASS, 107 files / 752 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS, 1 candidate metadata JSON file checked and 0 review manifests.
- `git diff --check` PASS.

# v0.104 Profiler-Guided Rendering Optimization And Public Battle HUD Minimal Mode - 2026-06-02

This checkpoint uses the committed v0.103 profiler evidence to reduce redundant rendering work and add public Minimal battle HUD density. It does not alter gameplay systems, balance, rewards, saves, stable IDs, campaign progression, Lume mechanics, maps, factions, art/assets, desktop implementation, runtime title, or production private-control posture.

Added:

- `src/game/ui/hudPanels/HudDensity.ts`.
- `src/game/ui/hudPanels/HudDensity.test.ts`.
- `src/game/ui/hudPanels/HudVolatileRegions.test.ts`.
- Public Minimal battle HUD density for normal public battles.
- Private-only Standard and Debug HUD density controls for private playtest review.
- Private Debug density counters for HUD/minimap/fog/Lume/display-object review.
- Private profiler scenarios `perf_hud_minimal`, `perf_hud_standard`, and `perf_hud_debug`.
- 17 v0.104 visual QA screenshots, bringing the visual QA matrix to 189 screenshots.
- `docs/V0104_PROFILER_TRIAGE_REPORT.md`.
- `docs/V0104_PUBLIC_BATTLE_HUD_MINIMAL_MODE_SPEC.md`.
- `docs/V0104_PRIVATE_HUD_DENSITY_TOGGLE_SPEC.md`.
- `docs/V0104_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`.
- `docs/V0104_PERFORMANCE_DELTA_REPORT.md`.
- `docs/V0104_VISUAL_QA_REPORT.md`.
- `docs/V0104_IMPLEMENTATION_REPORT.md`.
- `docs/V0104_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Ordinary battle HUD snapshot construction now waits for the existing 0.1s cadence unless a forced refresh is requested.
- Volatile HUD regions patch status, minimap, and hint updates without replacing stable panel markup.
- Minimap SVG markup is cached by deterministic render signature.
- Fog and Lume graphics skip redundant redraws when rendered signatures are unchanged.
- Private Performance Lab and profiler outputs now target v0.104 and compare against v0.103 artifacts.
- Visual QA launch waits were hardened for long visual capture groups without reducing visual assertions.
- Private package generation and package validation now expect the v0.104 checkpoint and v0.104 docs.

Not changed:

- No save-version bump, save fields, localStorage writes, stable IDs, serialized IDs, rewards, XP, Retinue, relics, reputation, campaign progression, combat balance, AI/pathing, maps, factions, generated/imported art, desktop work, runtime title, or Lume mechanics changed.
- No public Debug/Standard density controls are exposed.

Verification:

- `npm test` PASS, 105 files / 736 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS.
- `npm run export:portable-content` PASS, 229 stable-ID manifest entries.
- `npm run validate:portable-content` PASS, deterministic two-pass export.
- `npm run test:save-translation-contract` PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
- `npm run perf:profile:private` PASS, 20 private scenarios.
- `npm run perf:report:private` PASS.
- `npm run test:e2e:smoke:fast` PASS, 10 tests.
- `npm run test:e2e:smoke` PASS, 17 tests.
- Hosted release lanes PASS: smoke 17 tests, deep-meta 12 tests, deep-battle 31 tests, deep-campaign-pressure 8 tests, layout-core 27 tests, layout-cinderfen 12 tests.
- `npm run visual:qa` PASS, 189 screenshots, 0 console errors, 0 retries.
- `npm run visual:review-pack` PASS, 189 screenshots and 7 contact sheets.
- `npm run playtest:controls` PASS, 18 rows.
- `npm run playtest:controls:extended` PASS, 90 rows.
- `npm run playtest:controls:verify` PASS, 1,658 checks.
- `npm run playtest:act1` PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
- Final clean package generation and package verification are run after the checkpoint commit so the package does not carry a `-dirty` suffix.

# v0.103 Battlefield Clutter Reduction And Private Performance Profiler - 2026-06-01

This checkpoint reduces battlefield visual clutter and adds private/dev-only performance profiling evidence. It does not alter gameplay systems, balance, rewards, saves, stable IDs, campaign progression, Lume mechanics, maps, factions, art/assets, desktop implementation, or production posture.

Added:

- `src/game/playtest/PrivatePerformanceProfiler.ts`.
- `src/game/playtest/PrivatePerformanceProfiler.test.ts`.
- `tools/profilePrivatePerformance.ts`.
- `tools/reportPrivatePerformance.ts`.
- `npm run perf:profile:private`.
- `npm run perf:report:private`.
- Private Playtest Hub `Performance Lab` entries.
- 27 v0.103 visual QA screenshots, bringing the visual QA matrix to 172 screenshots.
- `docs/V0103_BATTLEFIELD_CLUTTER_REDUCTION_SPEC.md`.
- `docs/V0103_PRIVATE_PERFORMANCE_PROFILER_SPEC.md`.
- `docs/V0103_PERFORMANCE_LAB_SCENARIO_MANIFEST.json`.
- `docs/V0103_PERFORMANCE_BASELINE_REPORT.md`.
- `docs/V0103_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`.
- `docs/V0103_VISUAL_QA_REPORT.md`.
- `docs/V0103_IMPLEMENTATION_REPORT.md`.
- `docs/V0103_EMMANUEL_RETEST_CHECKLIST.md`.
- `docs/V0103_DEFERRED_ART_AND_RENDERING_FINDINGS.md`.

Changed:

- Capture-site labels now default to important states: selected, contested, objective-relevant, or hostile.
- Capture-site steady rings are slightly quieter.
- Lume Auto hides stable active links after transition pulses unless linked endpoints are selected.
- Lume optional-link copy moved behind Details.
- Private demo Lume buttons use shorter preview copy.
- Private package generation and package validation now expect the v0.103 checkpoint and v0.103 docs.

Not changed:

- No save-version bump, save fields, localStorage writes, stable IDs, serialized IDs, rewards, XP, Retinue, relics, reputation, campaign progression, combat balance, AI/pathing, maps, factions, generated/imported art, desktop work, runtime title, or `linked_ward` 0.92 damage multiplier changed.

Verification:

- `npm test` PASS, 103 files / 730 tests.
- `npm run build` PASS with the known Phaser/vendor chunk-size warning.
- `npm run validate:content` PASS.
- `npm run validate:art-intake` PASS.
- `npm run export:portable-content` PASS, 229 stable-ID manifest entries.
- `npm run validate:portable-content` PASS, deterministic two-pass export.
- `npm run test:save-translation-contract` PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
- `npm run perf:profile:private` PASS, 17 private scenarios.
- `npm run perf:report:private` PASS.
- `npm run test:e2e:smoke:fast` PASS, 10 tests.
- `npm run test:e2e:smoke` PASS, 17 tests.
- `npm run playtest:controls` PASS, 18 rows.
- `npm run playtest:controls:extended` PASS, 90 rows.
- `npm run playtest:controls:verify` PASS, 1,658 checks.
- `npm run playtest:act1` PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
- Hosted release lanes PASS: smoke 17 tests, deep-battle 31 tests on rerun, deep-campaign-pressure 8 tests on rerun, layout-core 27 tests, layout-cinderfen 12 tests.
- `npm run visual:qa` PASS, 172 screenshots, 0 console errors, 0 retries.
- `npm run visual:review-pack` PASS, 172 screenshots and 7 contact sheets.
- `git diff --check` PASS with only the existing `.gitignore` Windows line-ending notice.
- Final clean package generation and package verification are run after the checkpoint commit so the package does not carry a `-dirty` suffix.

# v0.102 Browser Save Fixture Library And Desktop Translation Contract Proof - 2026-06-01

This checkpoint adds deterministic fictional browser save fixtures and a pure translation-contract proof for future desktop experiments. It does not alter runtime save behavior, gameplay, balance, rewards, stable IDs, `CURRENT_SAVE_VERSION`, localStorage behavior, package posture, engine posture, art/assets, desktop implementation, or start v0.103.

Added:

- `src/game/save/SaveTranslationContract.ts`.
- `src/game/save/SaveTranslationContract.test.ts`.
- `tools/testSaveTranslationContract.ts`.
- `npm run test:save-translation-contract`.
- `tests/fixtures/saves/v0102/manifest.json`.
- 16 deterministic v0.102 save fixture files.
- `docs/V0102_SAVE_FIXTURE_LIBRARY_SPEC.md`.
- `docs/V0102_DESKTOP_SAVE_ENVELOPE_CONTRACT.md`.
- `docs/V0102_SAVE_TRANSLATION_PROOF_REPORT.md`.
- `docs/V0102_UNKNOWN_ID_AND_CORRUPTION_POLICY.md`.
- `docs/V0102_IMPLEMENTATION_REPORT.md`.

Changed:

- Added `/artifacts/save-translation-contract/` to ignored generated artifacts.
- Extended the save fixture README with the v0.102 fixture-library and proof-command rules.

Not changed:

- No save-version bump, runtime save fields, localStorage keys, real-save writes, stable IDs, serialized IDs, content definitions, gameplay rules, rewards, campaign progression, Retinue rules, settings behavior, desktop save path, profile UI, desktop port, engine choice, package metadata, generated images, imported assets, runtime title, or public title changed.

Verification:

- Passed: `npx vitest run src/game/save/SaveTranslationContract.test.ts --reporter=dot` with 7 tests, `npm test` with 102 files / 724 tests, `npm run build` with the known Phaser/vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run export:portable-content` with 229 manifest entries, `npm run validate:portable-content`, `npm run test:save-translation-contract` with 16 fixtures / 11 translated / 2 quarantined / 3 rejected, and `git diff --check`.
- Note: `git diff --check` emitted only the Windows line-ending warning for `.gitignore`; it exited successfully.

# v0.101 Portable Content Export Contract And Stable-ID Snapshot - 2026-06-01

This checkpoint adds deterministic downstream-only portable content export tooling and a compact stable-ID snapshot for later engine experiments. TypeScript remains authoritative. It does not alter runtime behavior, gameplay, balance, saves, stable IDs, package posture, engine posture, art/assets, desktop implementation, or start v0.102.

Added:

- `src/game/portable/PortableContentExport.ts`.
- `src/game/portable/PortableContentExport.test.ts`.
- `src/game/portable/stable-id-snapshot.json`.
- `tools/exportPortableContent.ts`.
- `tools/validatePortableContent.ts`.
- `npm run export:portable-content`.
- `npm run validate:portable-content`.
- `docs/V0101_PORTABLE_CONTENT_EXPORT_CONTRACT.md`.
- `docs/V0101_STABLE_ID_FREEZE_POLICY.md`.
- `docs/V0101_EXPORT_SCHEMA_REFERENCE.md`.
- `docs/V0101_CONTENT_REUSE_ROUNDTRIP_PLAN.md`.
- `docs/V0101_IMPLEMENTATION_REPORT.md`.

Changed:

- Added `/artifacts/portable-content/` to ignored generated artifacts.
- Portable export writes `content-export.json`, `stable-id-manifest.json`, `content-export-summary.md`, and `content-export-hashes.json` under `artifacts/portable-content/latest/`.
- Portable validation runs existing content validation, stable category/reference checks, snapshot drift checks, hash checks, and two-pass byte-for-byte determinism checks.

Not changed:

- No save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, rewards, replay rules, Retinue rules, Tutorial safety, difficulty, AI, balance values, maps, factions, generated images, imported assets, package metadata, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npx vitest run src/game/portable/PortableContentExport.test.ts` with 6 tests, `npm test` with 101 files / 717 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run export:portable-content` with 229 manifest entries, `npm run validate:portable-content` with byte-for-byte two-pass determinism, and `git diff --check`.
- Note: `git diff --check` emitted only the Windows line-ending warning for `.gitignore`; it exited successfully.

# v0.100 Private Playtest Hub And Scenario Gallery - 2026-06-01

This checkpoint adds a private-package-only Playtest Hub and Scenario Gallery for faster manual QA. It exposes representative campaign, first-session, battle, Lume, meta-progression, and Results previews only in private/dev posture. It does not expose shortcuts in production posture, alter normal progression, saves, persistent rewards, gameplay rules, balance, stable IDs, maps, factions, art/assets, imported assets, desktop work, or start v0.101.

Added:

- `src/game/scenes/PlaytestHubScene.ts`.
- `src/game/playtest/PlaytestScenarioGallery.ts`.
- `src/game/playtest/PlaytestHubFixtures.ts`.
- `src/game/styles/playtest-hub.css`.
- Private hub entry, return, reset, and 8-minute visual-tour UI.
- Private no-save scenario fixtures for campaign shell, first session, battle shell, Lume flow, meta screens, ordinary Results, defeat Results, and private-demo Results.
- `docs/V0100_PRIVATE_PLAYTEST_HUB_SPEC.md`.
- `docs/V0100_SCENARIO_GALLERY_MANIFEST.json`.
- `docs/V0100_SAVE_ISOLATION_REPORT.md`.
- `docs/V0100_EMMANUEL_FAST_REVIEW_GUIDE.md`.
- `docs/V0100_VISUAL_QA_REPORT.md`.
- `docs/V0100_IMPLEMENTATION_REPORT.md`.

Changed:

- Main Menu can show `PLAYTEST HUB` only when private playtest tools are enabled.
- Campaign Map, Hero Creation, Hero Progression, Battle HUD, and Results preview flows can return to the hub without mutating the prior save.
- Private Lume demo and private-demo Results remain intact and can now be reached from the gallery.
- Visual QA now includes 145 screenshots after adding nine v0.100 hub/gallery captures.
- Visual review pack generation records 145 screenshots and 7 contact sheets from the full matrix.
- Package generation and validation now require/copy the v0.100 docs and report the v0.100 checkpoint in playtest build info.
- Hosted deep-battle coverage now splits one oversized behaviour/marquee gauntlet into two assertion-preserving tests so the full hosted shard completes within its test budgets.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, unlock rules, rewards, replay rules, Retinue rules, reputation rules, Tutorial safety, difficulty, AI, balance values, maps, factions, generated images, imported assets, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 100 files / 711 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 10 tests, `npm run test:e2e:smoke` with 17 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-meta with 12 tests, hosted deep-battle with 31 tests, hosted smoke with 17 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 27 tests, hosted layout-cinderfen with 12 tests, `npm run visual:qa` with 16 tests / 145 screenshots / 0 console errors / 0 retries, and `npm run visual:review-pack` with 145 screenshots / 7 contact sheets.
- Non-pass evidence resolved before closeout: an initial filtered v0.100 visual-QA run failed only the global expected screenshot count because it intentionally captured 9 of 145 screenshots; the final full visual-QA run passed. Hosted deep-battle initially timed out in one oversized behaviour/marquee gauntlet; the same assertion coverage was split into two tests and the full hosted shard reran green.

# v0.99 Act 1 Mission Presentation Objective Clarity And Narrative Polish - 2026-06-01

This checkpoint improves campaign presentation and copy only. It makes Act 1 read as a coherent route beginning near Salto, clarifies mission-card objectives and next steps, improves Captain Malrec framing, and tightens ordinary Results guidance. It does not add nodes, change unlock rules, rewards, difficulty, AI, saves, stable IDs, broad branding, art/assets, imported assets, desktop work, or start v0.100.

Added:

- `docs/V099_ACT1_PRESENTATION_AUDIT.md`.
- `docs/V099_MISSION_CARD_AND_OBJECTIVE_SPEC.md`.
- `docs/V099_WORLD_COPY_APPLIED_LEDGER.md`.
- `docs/V099_ACT1_RESULTS_AND_NEXT_STEP_REPORT.md`.
- `docs/V099_VISUAL_QA_REPORT.md`.
- `docs/V099_IMPLEMENTATION_REPORT.md`.
- `docs/V099_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Act 1 node descriptions now read as concise one-line premises.
- Salto Outskirts, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost briefing/after-action copy now lead with clearer objectives and next-step language.
- Campaign selected-mission panels show compact lock-reason or recommended-next-step copy without changing action logic.
- Results overview now uses campaign primary-objective copy and existing Act 1 guidance when campaign completion data exists.
- Captain Malrec copy now frames him as disciplined, dangerous, and convinced controlled Lume prevents collapse.
- Visual QA now includes 136 screenshots after adding ten v0.99 Act 1 presentation/Results captures.
- Package generation and validation now require/copy the v0.99 docs and report the v0.99 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, skill rules, XP values, relic stats, equipment rules, Retinue rules, Stronghold rules, campaign progression, unlock rules, rewards, replay rules, optional objective logic, Tutorial safety, difficulty, AI, balance values, maps, factions, generated images, imported assets, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 98 files / 704 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-battle with 30 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 27 tests, hosted layout-cinderfen with 12 tests, `npm run visual:qa` with 15 tests / 136 screenshots / 0 console errors / 0 retries, `npm run visual:review-pack` with 136 screenshots / 7 contact sheets, and pre-commit `npm run verify:playtest-package` with 357 checks.
- Non-pass evidence resolved before closeout: initial unit suite found one stale Old Stone Road assertion; initial hosted smoke had a transient Tutorial overlay bounding-box failure that passed exact and full reruns; initial hosted deep-campaign-pressure found two stale copy assertions that passed exact and full reruns after update; initial visual QA exceeded the 30-minute tool timeout and passed with a longer timeout after cleaning generated screenshots.

# v0.98 Hero Retinue Inventory And Stronghold UX Rescue - 2026-06-01

This checkpoint improves meta-progression presentation only. It rescues Hero Overview, Skills, Equipment, Inventory, Relic, Retinue, Stronghold, and Results-to-meta readability. It does not change progression rules, XP, relic stats, equipment rules, Retinue rules, Stronghold upgrade rules, saves, stable IDs, rewards, campaign progression, gameplay balance, art/assets, imported assets, desktop work, or start v0.99.

Added:

- `src/game/results/ResultsMetaProgressionPanel.ts`.
- `src/game/progression/MetaProgressionUx.test.ts`.
- `docs/V098_HERO_OVERVIEW_UX_SPEC.md`.
- `docs/V098_SKILLS_AND_EQUIPMENT_UX_SPEC.md`.
- `docs/V098_RETINUE_UX_RESCUE_SPEC.md`.
- `docs/V098_STRONGHOLD_UX_RESCUE_SPEC.md`.
- `docs/V098_RESULTS_TO_META_FLOW_REPORT.md`.
- `docs/V098_VISUAL_QA_REPORT.md`.
- `docs/V098_IMPLEMENTATION_REPORT.md`.
- `docs/V098_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Hero Progression now opens with a concise Hero Overview card covering identity, level/XP, class/origin, primary stats, equipment, relic, skill points, Retinue, and inventory.
- Skills now present purchased / available / locked state, cost, requirement, concise effect, and details disclosure without changing unlock logic.
- Equipment now reads as a loadout; Inventory now groups equipped gear, stored gear, and relics with compact comparison/effect chips.
- Relic rows now distinguish equipped, stored, duplicate/owned posture, active-only effect copy, and build synergy details without changing stats.
- Retinue Camp now surfaces Ready, Deployed, Recovering, reserve, cap, reinforcement eligibility, recovery status, and veteran identity with member details behind disclosure.
- Stronghold now surfaces current tier, available/locked/purchased upgrades, cost, prerequisite, benefit, and action state with extra rules behind disclosure.
- Ordinary Results now include a compact Progression Summary for XP, rewards, relics, Retinue, and Stronghold/campaign resources.
- Visual QA now includes 126 screenshots after adding eight v0.98 meta-progression rescue states.
- Package generation and validation now require/copy the v0.98 docs and report the v0.98 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero progression rules, skill unlock rules, XP values, relic stats, equipment rules, Retinue rules, Stronghold upgrade rules, campaign progression, rewards, replay rules, Tutorial safety, balance values, maps, factions, generated images, imported assets, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 98 files / 700 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-battle with 30 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 27 tests, hosted layout-cinderfen with 12 tests, `npm run visual:qa` with 14 tests / 126 screenshots / 0 console errors / 0 retries, `npm run visual:review-pack` with 126 screenshots / 7 contact sheets, and pre-commit `npm run verify:playtest-package` with 350 checks.
- Non-pass evidence resolved before closeout: initial fast smoke exposed the stale inventory assertion for `hero-stats` now hidden behind More Details, then an unrelated settings click flake passed exact rerun and full-lane rerun. Initial visual QA caught a broad Results `summary` locator after nested accordions were present; the locator was tightened and the full visual-QA rerun passed. Initial hosted deep-battle hit one behaviour-gauntlet timeout; exact rerun and full-lane rerun both passed.

# v0.97 Camera Selection Orders And Tactical Feedback Polish - 2026-06-01

This checkpoint improves controls readability and tactical feedback only. It adds clearer selection focus, read-only enemy inspection, short-lived command markers, camera focus/minimap confirmations, compact command-panel details, package metadata, and visual-QA coverage. It does not add gameplay systems, change unit stats, alter combat balance, change pathing rules, change saves, rename stable IDs, add maps/factions/art/assets, start desktop work, or start v0.98.

Added:

- `src/game/ui/CommandFeedbackMarker.ts`.
- `src/game/ui/CommandFeedbackMarker.test.ts`.
- `src/game/systems/CameraBounds.ts`.
- `src/game/systems/CameraSystem.test.ts`.
- `docs/V097_SELECTION_FEEDBACK_SPEC.md`.
- `docs/V097_COMMAND_MARKER_SPEC.md`.
- `docs/V097_CAMERA_USABILITY_REPORT.md`.
- `docs/V097_COMMAND_PANEL_FOLLOWUP_REPORT.md`.
- `docs/V097_VISUAL_QA_REPORT.md`.
- `docs/V097_IMPLEMENTATION_REPORT.md`.
- `docs/V097_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Existing move, attack-move, attack target, Patrol, rally, build, ability, invalid, and focus flows can emit brief procedural command markers.
- Reduced-motion users get readable command feedback without animated flourish.
- Selected hero, Worker, squad, combat unit, building, resource site, and enemy inspection states now show a concise selection focus card.
- Enemy inspection is read-only and does not expose friendly behavior controls.
- Space focuses the selected entity before falling back to Aster.
- Minimap and focus actions now show concise confirmation copy and a brief focus marker.
- Camera center/scroll clamping now uses a shared pure helper.
- Command-panel secondary explanations sit behind `More Details`.
- Visual QA now includes 118 screenshots after adding the v0.97 selection/command/camera states.
- Package generation and validation now require/copy the v0.97 docs and report the v0.97 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, replay rules, Tutorial safety, rewards, XP, combat stats, balance values, pathing rules, maps, factions, art assets, imported assets, generated images, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 97 files / 696 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-battle with 30 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, `npm run visual:qa` with 13 tests / 118 screenshots / 0 console errors / 0 retries, and `npm run visual:review-pack` with 118 screenshots / 7 contact sheets.
- Non-pass evidence documented before closeout: full local release exceeded the 60-minute local tool timeout with no pass/fail output; a later shard1 attempt reported three older deep-flow startup/timeout failures, and exact reruns of those three tests passed.

# v0.96 First-Time Player Onboarding And Tutorial UX Rescue - 2026-06-01

This checkpoint improves first-session presentation only. It rescues the playable Tutorial sequence, one-action guidance copy, compact More Help, Focus Objective, Dismiss/Reopen, shared help surfaces, Salto first-step guidance, package metadata, and visual-QA coverage. It does not add gameplay, change rewards, alter saves, rename stable IDs, change campaign progression, broaden Lume rules, add maps/factions/races/art/assets, change balance, or start v0.97.

Added:

- `src/game/ui/OnboardingHelp.ts`.
- `src/game/ui/OnboardingHelp.test.ts`.
- `docs/V096_FIRST_SESSION_AUDIT.md`.
- `docs/V096_CONTEXTUAL_ONBOARDING_SPEC.md`.
- `docs/V096_TUTORIAL_UX_RESCUE_REPORT.md`.
- `docs/V096_HELP_SURFACE_SPEC.md`.
- `docs/V096_VISUAL_QA_REPORT.md`.
- `docs/V096_IMPLEMENTATION_REPORT.md`.
- `docs/V096_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Proving Grounds now opens with selecting Aster and breaks the first-session flow into clearer Tutorial objectives.
- Tutorial steps can include short reason copy, collapsed More Help, and safe player-triggered Focus Objective targets.
- Tutorial completion now covers selecting starting troops and assigning a Worker to a resource site.
- Tutorial panel now supports More Help, Focus Objective, Dismiss, and Reopen.
- Battle HUD, pause menu, and campaign shell now expose a shared collapsed help surface.
- Fresh Salto selection now shows a compact next-action card without moving the primary action below the fold.
- Visual QA now includes 110 screenshots after adding the v0.96 first-session states.
- Package generation and validation now require/copy the v0.96 docs and report the v0.96 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, reward IDs, gameplay systems, hero rules, rewards, XP, campaign progression, replay rules, Tutorial no-reward safety, balance values, pathing, collision, fog simulation, Lume mechanics, maps, factions, races, units, buildings, art assets, imported assets, generated images, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 95 files / 689 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-battle with 29 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 27 tests, hosted layout-cinderfen with 12 tests, `npm run visual:qa` with 12 tests / 110 screenshots / 0 console errors / 0 retries, and `npm run visual:review-pack` with 110 screenshots / 7 contact sheets.
- Non-pass evidence resolved before closeout: initial fast smoke caught Tutorial preselection auto-completion, campaign action crowding, and Tutorial More Help drag conflict; initial visual QA timed out at 20 minutes; hosted layout-core caught stale build output and small CSS overflow issues. Each was fixed or rerun successfully.

# v0.95 Procedural Battlefield Readability And Placeholder-World Rescue - 2026-05-31

This checkpoint improves battle presentation only. It rescues procedural placeholder terrain, fog readability, entity silhouettes, capture-site emphasis, label density, minimap clarity, package metadata, and visual-QA coverage. It does not add gameplay, change balance, alter saves, rename stable IDs, change fog logic, change Lume mechanics, add maps/factions/assets, import/generate art, start desktop work, or start v0.96.

Added:

- `src/game/ui/PlaceholderBattlefieldPresentation.ts`.
- `src/game/ui/PlaceholderBattlefieldPresentation.test.ts`.
- `docs/V095_PROCEDURAL_BATTLEFIELD_READABILITY_SPEC.md`.
- `docs/V095_FOG_AND_TERRAIN_PLACEHOLDER_RESCUE_REPORT.md`.
- `docs/V095_ENTITY_SILHOUETTE_PLACEHOLDER_SPEC.md`.
- `docs/V095_CAPTURE_SITE_AND_LABEL_DENSITY_REPORT.md`.
- `docs/V095_VISUAL_QA_REPORT.md`.
- `docs/V095_IMPLEMENTATION_REPORT.md`.
- `docs/V095_EMMANUEL_RETEST_CHECKLIST.md`.
- `docs/V095_DEFERRED_FINAL_ART_REQUIREMENTS.md`.

Changed:

- Battle terrain rendering now uses deterministic Phaser primitive detail for roads, water edges, terrain scuffs, blocked-ground shadows, and site-ground context.
- Fog-of-war presentation is softer and less checkerboard-like without changing fog visibility logic.
- Unit and building placeholders use role-aware silhouettes and label priority.
- Routine unit labels are quieter; important labels remain visible when selected, statused, objective-relevant, commander/elite, hero, building, or capture site.
- Capture-site rings better distinguish neutral, friendly, enemy, selected, contested, and objective states.
- Minimap markers and panel sizing are slightly clearer for desktop battle review.
- Visual QA now includes 102 screenshots after adding the v0.95 battlefield-readability states.
- Package generation and validation now require/copy the v0.95 docs and report the v0.95 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, mission IDs, map IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, gameplay systems, balance values, rewards, XP, campaign progression, replay rules, Tutorial safety, pathing, collision, fog simulation, Lume mechanics, maps, factions, units, buildings, art assets, imported assets, generated images, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 94 files / 686 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-battle with 29 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 27 tests, hosted layout-cinderfen with 12 tests, `npm run visual:qa` with 11 tests / 102 screenshots / 0 console errors / 0 retries, and `npm run visual:review-pack` with 102 screenshots / 7 contact sheets.
- Non-pass evidence resolved before closeout: initial unit tests caught unsupported triangle placeholders in Phaser test doubles; a filtered v0.95 visual-QA run failed only the expected global screenshot count. The final unfiltered visual-QA run passed.

# v0.94 Main Menu Ascendant Creation And Campaign-Shell Density Rescue - 2026-05-31

This checkpoint improves out-of-battle presentation only. It rescues the main menu composition, makes Ascendant creation scannable, compacts campaign mission information, improves campaign tab hierarchy, and groups ordinary Results expanded details. It does not add gameplay, alter hero rules, change rewards, change saves, rename stable IDs, add maps/factions/races/art, rebrand the runtime title, or start desktop work.

Added:

- `docs/V094_MAIN_MENU_RESCUE_SPEC.md`.
- `docs/V094_ASCENDANT_CREATION_UX_SPEC.md`.
- `docs/V094_CAMPAIGN_DENSITY_RESCUE_SPEC.md`.
- `docs/V094_RESULTS_DETAILS_COMPACTION_REPORT.md`.
- `docs/V094_VISUAL_QA_REPORT.md`.
- `docs/V094_IMPLEMENTATION_REPORT.md`.
- `docs/V094_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Main menu now uses a wider desktop title/action layout with grouped Play, Practice, and Manage actions.
- Hero creation now renders Step 1 Choose Class, Step 2 Choose Origin, and Step 3 Review Hero using existing hero class/origin data.
- Campaign map presentation has larger node labels, clearer selected route styling, dimmer future locked nodes/routes, and a compact mission panel.
- Stronghold, Hero, Inventory, Intel, and Reputation tabs now use primary-summary and action/detail card hierarchy.
- Ordinary Results full details now use grouped accordions and compact metrics; private-demo Results remain on the existing private-demo path.
- Visual QA now includes 84 screenshots after adding the v0.94 presentation rescue states.
- Package generation and validation now require/copy the v0.94 docs and report the v0.94 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, hero rules, rewards, XP, campaign progression, replay rules, Tutorial safety, gameplay values, maps, factions, races, units, buildings, art assets, imported assets, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 93 files / 683 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted deep-battle with 29 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 27 tests, hosted layout-cinderfen with 12 tests, `npm run visual:qa` with 10 tests / 84 screenshots / 0 console errors / 0 retries, and `npm run visual:review-pack` with 84 screenshots / 7 contact sheets.
- Non-pass evidence resolved before closeout: initial fast smoke caught node overlap, initial full smoke exposed a Results detail assertion after compaction, hosted layout-core caught mobile-short menu overflow, and visual QA caught the locked-mission primary action below the 1366x768 fold. Each was fixed and rerun successfully.

# v0.93 Runtime UI Foundation Tokens And Mission-Panel State Reset - 2026-05-31

This checkpoint promotes the approved visual-token direction into a runtime CSS-token layer and fixes selected-mission panel reset/readability issues. It does not add gameplay, alter rewards, change saves, rename stable IDs, add art/assets, change campaign progression logic, rebrand the runtime, or start desktop work.

Added:

- `src/game/styles/tokens.css`.
- `docs/V093_RUNTIME_UI_TOKEN_IMPLEMENTATION_SPEC.md`.
- `docs/V093_SALTO_MISSION_PANEL_STATE_RESET_REPORT.md`.
- `docs/V093_DESKTOP_TYPOGRAPHY_READABILITY_REPORT.md`.
- `docs/V093_VISUAL_QA_REPORT.md`.
- `docs/V093_IMPLEMENTATION_REPORT.md`.
- `docs/V093_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Base, menu, form, inventory, campaign, Results, and battle-HUD styles now consume shared runtime UI tokens for typography, spacing, panels, borders, and state colors.
- Campaign node targets are larger while retaining map visibility and non-overlap checks.
- Switching selected campaign nodes now resets the selected mission panel to the top, collapses ordinary `More Details`, and keeps the primary action framed.
- Layout and visual-QA coverage now includes the Salto return-after-locked-preview reset path.
- Package generation and validation now require/copy the v0.93 docs and report the v0.93 checkpoint in playtest build info.

Not changed:

- No save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, gameplay systems, rewards, XP, campaign progression, replay rules, Tutorial state, balance values, maps, factions, units, buildings, art assets, imported assets, desktop port, engine choice, runtime title, or public title changed.

Verification:

- Passed: `npm test` with 93 files / 683 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast` with 9 tests, `npm run test:e2e:smoke` with 16 tests, controls normal/extended/verify with 18 scenarios, 90 extended pass rows, and 1658 checks, `npm run playtest:act1` with 180 Act 1 runs from 255 deterministic simulator runs, hosted smoke with 16 tests, hosted layout-core with 26 tests, hosted layout-cinderfen with 12 tests, hosted deep-battle with 29 tests, hosted deep-campaign-pressure with 8 tests, `npm run visual:qa` with 9 tests / 65 screenshots / 0 console errors / 0 retries, and `npm run visual:review-pack` with 65 screenshots / 7 contact sheets.
- Final `git diff --check`, package generation, and package verification run during commit/package closeout.

# v0.92 Visual Review Pack Generator And Unified Emmanuel Retest Packet - 2026-05-31

This checkpoint adds QA tooling and documentation for reviewing existing deterministic visual-QA screenshots quickly. It does not alter gameplay, runtime behavior, saves, stable IDs, balance, art assets, desktop implementation, engine choice, or dependencies.

Added:

- `src/game/playtest/VisualReviewPack.ts`.
- `src/game/playtest/VisualReviewPack.test.ts`.
- `tools/generateVisualReviewPack.ts`.
- `docs/V092_VISUAL_REVIEW_PACK_SPEC.md`.
- `docs/V092_CONTACT_SHEET_INDEX.md`.
- `docs/V092_EMMANUEL_UNIFIED_RETEST_PACKET.md`.
- `docs/V092_IMPLEMENTATION_REPORT.md`.

Changed:

- Added `npm run visual:review-pack`.
- Added `/artifacts/visual-review/` to `.gitignore`.
- Roadmap, handoff, checkpoint, changelog, and release checklist now document the v0.92 QA tooling boundary.

Generated:

- `artifacts/visual-review/latest/index.html`.
- `artifacts/visual-review/latest/review-manifest.json`.
- `artifacts/visual-review/latest/README.md`.
- 64 copied screenshots and 7 contact sheets.

Not changed:

- No runtime code path, gameplay system, save-version bump, save fields, stable IDs, serialized IDs, reward logic, balance value, campaign progression, map, faction, unit, building, art asset, imported asset, desktop port, engine choice, or package metadata changed.

Verification:

- Passed: `npm test` with 93 files / 683 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run visual:qa` with 9 tests / 64 screenshots / 0 console errors / 0 retries, final `npm run visual:review-pack` with 64 screenshots / 7 contact sheets, and `git diff --check`.
- Focused generator evidence passed: `npx vitest run src/game/playtest/VisualReviewPack.test.ts`, 1 file / 5 tests.
- Non-pass evidence: an initial build caught a TypeScript narrowing issue in the new contact-sheet screen-family filter; the type was tightened before final verification.
- Package validation is not required because package metadata did not change.

# v0.91 Desktop Full-Game Transition Technical Audit And Vertical-Slice Roadmap - 2026-05-31

This checkpoint documents future desktop-transition strategy without porting the game, creating a wrapper, choosing an engine, adding dependencies, generating/importing art, implementing multiplayer, changing saves, or altering runtime behavior.

Added:

- `docs/V091_CURRENT_ARCHITECTURE_REUSE_MATRIX.md`.
- `docs/V091_DESKTOP_ENGINE_DECISION_CRITERIA.md`.
- `docs/V091_DESKTOP_VERTICAL_SLICE_SCOPE.md`.
- `docs/V091_STAGED_TRANSITION_EXPERIMENTS.md`.
- `docs/V091_SAVE_CONTENT_AND_TEST_REUSE_PLAN.md`.
- `docs/V091_MULTIPLAYER_AND_COOP_DEFERRED_REQUIREMENTS.md`.
- `docs/V091_EMMANUEL_DESKTOP_TRANSITION_REVIEW_PACKET.md`.
- `docs/V091_IMPLEMENTATION_REPORT.md`.

Changed:

- Roadmap, handoff, checkpoint, changelog, and release checklist now record v0.91 as a docs-only desktop-transition audit and make clear that the browser prototype remains the active development and testing environment.
- The architecture audit classifies content data, hero progression, Race + Class architecture, campaign data, saves, combat, pathing, AI, resource sites, Lume Network, Retinue, HUD, campaign shell, Results, visual pipeline, audio, input, resolution handling, accessibility, tests, deterministic simulator, packaging, and multiplayer future scope.
- The engine-decision criteria compare Phaser/browser prototype continuation, a later desktop packaging experiment, Godot, Unity, Unreal, and justified alternatives without selecting a final engine.

Not changed:

- No runtime code, save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, gameplay systems, rewards, XP, campaign progression, balance values, maps, factions, races, units, buildings, art/assets, dependencies, package scripts, desktop wrapper, engine choice, multiplayer/PvP/co-op, or runtime title changed.

Verification:

- Passed: required v0.91 docs existence check, `npm test` with 92 files / 678 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake` with 1 candidate metadata JSON file checked and 0 review manifests, and `git diff --check`.
- JSON validation is not applicable because v0.91 adds no JSON files.
- Package validation is not required because package metadata and package contents did not change.

# v0.90 UX Visual-Regression Harness And Desktop-Viewport Acceptance Hardening - 2026-05-31

This checkpoint hardens QA coverage for visual/layout regressions without adding gameplay, changing balance, altering saves, renaming stable IDs, generating/importing art, or starting desktop implementation.

Added:

- `docs/V090_VISUAL_REGRESSION_MATRIX.json`.
- `docs/V090_DESKTOP_VIEWPORT_ACCEPTANCE_SPEC.md`.
- `docs/V090_LAYOUT_ASSERTION_COVERAGE.md`.
- `docs/V090_LIGHTWEIGHT_PERFORMANCE_BASELINE.md`.
- `docs/V090_VISUAL_QA_REVIEW_RULES.md`.
- `docs/V090_IMPLEMENTATION_REPORT.md`.
- `src/game/playtest/VisualRegressionMatrix.test.ts`.

Changed:

- Visual QA now captures 64 deterministic screenshots across main menu, campaign map, selected unlocked/locked missions, all campaign tabs, battle HUD states, Lume inactive/active/selected/hidden/always-visible states, private-demo Results compact/expanded, ordinary Victory/Defeat/Replay Results, and Tutorial.
- Desktop visual acceptance now covers 1920x1080, 1600x900, and 1366x768.
- Visual QA now records screenshot count, harness duration, average screenshot duration, console-error count, and retry usage, and fails on screenshot retries.
- Layout coverage now asserts campaign node non-overlap, above-fold primary actions, Results action visibility, key-card text overflow, HUD/objective/minimap posture, Lume control isolation, and private-demo posture.
- Hosted `deep-meta` expectations now navigate the current campaign tab architecture before asserting tab-specific panels and use current Retinue `Ready` status copy.
- Package generation and package verification now include the v0.90 QA docs.

Not changed:

- No save-version bump, save fields, localStorage keys, stable IDs, serialized IDs, gameplay systems, campaign progression, reward logic, XP, balance values, Tutorial safety, maps, factions, units, buildings, relic IDs, art/assets, runtime title, public title, desktop implementation, or package folder naming changed.

Verification:

- Passed: `npm test` with 92 files / 678 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, fast smoke with 9 tests, full smoke with 16 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-meta with 12 tests, hosted deep-battle with 29 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, hosted layout-core with 25 tests, hosted layout-cinderfen with 12 tests, and visual QA with 9 tests / 64 screenshots / 0 console errors / 0 retries.
- Resolved non-pass evidence: initial hosted `deep-meta` exposed stale campaign-tab/Retinue expectations and initial full local layout exposed one private posture assertion; exact reruns and hosted layout-core passed after test cleanup.

# v0.89 Controlled Display-Copy Migration Batch A - 2026-05-31

This checkpoint applies the first approved low-risk player-facing display-copy migration batch without changing gameplay, saves, stable IDs, serialized values, rewards, balance, maps, factions, art/assets, runtime title, public title, class display names, or repository/package folder names.

Added:

- `docs/V089_APPLIED_COPY_MIGRATION_LEDGER.md`.
- `docs/V089_DEFERRED_AMBIGUOUS_TERMS.md`.
- `docs/V089_COPY_ONLY_TEST_AND_ROLLBACK_REPORT.md`.
- `docs/V089_VISUAL_QA_REPORT.md`.
- `docs/V089_IMPLEMENTATION_REPORT.md`.
- `docs/V089_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Approved player-facing copy now uses Barrosan Freeholds, The Barrosan Marches, Salto Outskirts/Salto-adjacent opening copy, Rootbound Concord, and Lume Surge where v0.79/v0.80 approved the migration.
- Content validation now guards the copy-only migration and protected IDs: `free_marches`, `sylvan_concord`, `border_marches`, `border_village`, `mission_aether_surge`, `aether_surge`, `aether_lens`, `maxMana`, `Aether`, `Mana`, and `CURRENT_SAVE_VERSION`.
- Package generation and package verification metadata now include the v0.89 copy migration docs.
- Active building-placement instructions now remain visible in the HUD status line while battlefield event status remains available in event/objective UI.

Not changed:

- No save-version bump, save fields, localStorage keys, serialized IDs, gameplay systems, campaign progression, reward logic, XP, replay logic, Tutorial safety, maps, factions, units, buildings, relic IDs, art/assets, runtime title, public title, class display names, or repository/package folder names changed.
- `Aether`, `Aether Well Ruins`, `Aether Lens`, `Aether Flow`, `Mana`, and ambiguous Aether/Marcher/class/title terms remain deferred.

Verification:

- Passed: `npm test` with 91 files / 676 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, fast smoke with 9 tests, full smoke with 16 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, and visual QA with 6 tests / 36 screenshots / 0 console errors / 0 retries.
- Resolved non-pass evidence: the first hosted deep-battle rerun failed 2 of 29 tests; exact reruns isolated one transient behaviour gauntlet timeout and one placement-status readability regression. After the presentation fix and rebuild, the exact failing test and full hosted deep-battle lane passed.

# v0.88 Visual Foundation, Style-Frame Preparation, And AI-Art Intake Gate - 2026-05-31

This checkpoint prepares a controlled professional visual pipeline before any AI-assisted art generation begins. It is docs-first and does not generate images, import assets, add runtime art, redesign gameplay, alter saves, rename stable IDs, choose a desktop engine, or start v0.89.

Added:

- `docs/V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md`.
- `docs/V088_UI_DESIGN_TOKEN_PROPOSAL.md`.
- `docs/V088_BARROSAN_STYLE_FRAME_BRIEF.md`.
- `docs/V088_ASHEN_STYLE_FRAME_BRIEF.md`.
- `docs/V088_WOLFVEIL_SILHOUETTE_BRIEF.md`.
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md`.
- `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`.
- `docs/V088_ART_INTAKE_AND_REVIEW_GATE.md`.
- `docs/V088_EMMANUEL_VISUAL_REVIEW_PACKET.md`.
- `docs/V088_IMPLEMENTATION_REPORT.md`.

Changed:

- Package generation now includes the v0.88 visual foundation docs, prompt templates, planning manifest, intake gate, and Emmanuel review packet.
- Package verification now requires the v0.88 package docs and build-info checkpoint.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, rewards, XP, campaign progression, mission IDs, stable IDs, maps, factions, races, units, buildings, classes, runtime CSS, gameplay systems, balance values, broad AI/pathing behavior, desktop work, multiplayer, PvP, co-op, runtime rebrand/display-copy migration, image generation, asset import, or runtime art changed.

Verification:

- Passed: JSON validation for `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`, `npm test` with 91 files / 675 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, and `npm run validate:art-intake`.

# v0.87 Campaign-Shell Second Polish And General Results Information Architecture - 2026-05-31

This checkpoint polishes campaign and ordinary Results presentation without adding gameplay systems, changing campaign progression, altering rewards, altering saves, renaming stable IDs, adding art/assets, maps, factions, desktop work, multiplayer, PvP, co-op, or broad creative changes.

Added:

- `src/game/results/ResultsOverviewPanel.ts`.
- `docs/V087_CAMPAIGN_SHELL_SECOND_POLISH_SPEC.md`.
- `docs/V087_RESULTS_INFORMATION_ARCHITECTURE_SPEC.md`.
- `docs/V087_VISUAL_QA_REPORT.md`.
- `docs/V087_IMPLEMENTATION_REPORT.md`.
- `docs/V087_EMMANUEL_RETEST_CHECKLIST.md`.
- `docs/V087_DEFERRED_CAMPAIGN_AND_RESULTS_FINDINGS.md`.

Changed:

- Campaign nodes now expose presentation-only map coordinates and chapter metadata for a wider map-first shell.
- The Campaign Map tab now uses larger chapter lanes, clearer routes, stronger node-state styling, and wider spacing while preserving fresh Border Village selection and locked Aether Well preview.
- The selected mission panel is compact by default, with build hints, doctrine details, modifiers, rival information, replay notes, extended rewards, and telemetry-style copy behind `More Details`.
- Stronghold, Hero, Inventory, Intel, and Reputation tabs now use card hierarchy and details disclosures for long explanatory copy.
- Ordinary Results screens now place victory/defeat, mission name, time, primary objective, key rewards, hero XP, important veterans, and return/replay actions above collapsed full battle details.
- Replay Results now keep the replay action visible with the primary action row.
- A stale hero ability button refresh path now updates immediately after successful casts so the presentation surface reflects cooldown/mana state without changing ability logic.
- Visual QA now captures v0.87 campaign and Results screenshots, including 1920x1080 and 1366x768 campaign shells.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, rewards, XP, campaign progression, mission IDs, stable IDs, maps, factions, races, units, buildings, classes, art/assets, Lume rules, balance values, broad AI/pathing behavior, desktop work, multiplayer, PvP, co-op, runtime rebrand/display-copy migration, canvas/world force-click behavior, or DOM fallback behavior changed.
- The v0.85 private-demo Results branch remains separate and preserved.

Verification:

- Passed: `npm test` with 91 files / 675 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, controls normal/extended/verify, Act 1 telemetry, fast smoke with 9 tests, full smoke with 16 tests, layout with 32 tests, hosted deep-battle with 29 tests, hosted smoke with 16 tests, hosted deep-campaign-pressure with 8 tests, and visual QA with 6 tests / 36 screenshots / 0 console errors / 0 retries.
- Non-pass evidence: broad local `npm run test:e2e:release` exceeded a 40-minute command timeout without a usable summary; the layout shard and required hosted release lanes passed after focused cleanup.

# v0.86 General Battlefield-Shell UX Rescue - 2026-05-31

This checkpoint rescues the general battlefield shell presentation without changing gameplay, save data, Lume rules, balance, campaign progression, runtime identity, or stable IDs.

Added:

- `src/game/battle/BattleStatusPriority.ts`.
- `src/game/battle/BattleStatusPriority.test.ts`.
- `src/game/ui/CaptureSitePresentation.ts`.
- `src/game/ui/CaptureSitePresentation.test.ts`.
- `src/game/ui/FogPresentation.ts`.
- `src/game/ui/FogPresentation.test.ts`.
- `src/game/ui/SelectionPresentation.ts`.
- `src/game/ui/SelectionPresentation.test.ts`.
- `docs/V086_BATTLEFIELD_SHELL_UX_RESCUE_SPEC.md`.
- `docs/V086_NOTIFICATION_PRIORITY_SPEC.md`.
- `docs/V086_OBJECTIVE_TRACKER_PRESENTATION_SPEC.md`.
- `docs/V086_VISUAL_QA_REPORT.md`.
- `docs/V086_IMPLEMENTATION_REPORT.md`.
- `docs/V086_DEFERRED_UX_FINDINGS.md`.
- `docs/V086_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Command panel entries now show compact action/cost/lock copy first, with long descriptions and effect text preserved in details disclosures and accessible labels.
- Battlefield status lines now use critical, important, routine, and debug categories; routine command confirmations are shorter and deduped.
- Objective tracker rows avoid misleading empty `Objectives 0/0` text when only event/doctrine/Lume context exists.
- Battlefield event and doctrine rows use compact details for longer counterplay copy.
- Capture-site labels now use clearer contrast chips and state prefixes.
- Selection rings use restrained team-specific presentation.
- Fog presentation uses softer rounded cells for unexplored and explored-muted states while preserving visibility logic.
- Minimap capture-site markers distinguish neutral, owned, and objective sites more clearly.
- Visual QA now captures two v0.86 battlefield-shell review screenshots at 1920x1080 and 1366x768.
- Package generation and package verification now include v0.86 docs and tester guidance.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, rewards, campaign progression, maps, factions, races, units, buildings, classes, art/assets, internal ID renames, Lume rule expansion, linked-site rule changes, resource-production changes, global balance changes, broad AI/pathing changes, desktop work, multiplayer, PvP, co-op, or runtime rebrand/display-copy migration was added.
- No canvas/world force-click or DOM fallback behavior was added.

Verification:

- Passed: focused battlefield-shell Vitest coverage with 7 files / 37 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm test` with 91 files / 672 tests, `npm run validate:content`, `npm run validate:art-intake`, fast smoke with 9 tests, full smoke with 15 tests after an exact Broken Ford scene-transition rerun, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests after compact-command/minimap/details expectation updates and exact reruns, hosted smoke with 15 tests, hosted deep-campaign-pressure with 8 tests after an exact compact-upgrade-details rerun, and visual QA with 6 tests / 31 screenshots / 0 console errors / 0 retries.

# v0.85 Contextual Lume Overlay And Results-Screen UX Rescue - 2026-05-31

This checkpoint makes the Aether Well Lume overlay contextual and rescues the private-demo Results screen, without changing Lume balance, save data, campaign progression, runtime identity, or stable Lume IDs.

Added:

- `src/game/battle/LumeNetworkRendering.ts`.
- `src/game/battle/LumeNetworkRendering.test.ts`.
- `src/game/results/ResultsPrivateDemoPanel.ts`.
- `docs/V085_CONTEXTUAL_LUME_OVERLAY_SPEC.md`.
- `docs/V085_LUME_VISIBILITY_CONTROL_SPEC.md`.
- `docs/V085_PRIVATE_DEMO_RESULTS_UX_SPEC.md`.
- `docs/V085_IMPLEMENTATION_REPORT.md`.
- `docs/V085_VISUAL_QA_REPORT.md`.
- `docs/V085_DEFERRED_RESULTS_AND_BATTLEFIELD_UX_FINDINGS.md`.
- `docs/V085_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Auto Lume rendering now hides inactive clutter in normal play and shows only the relevant private-demo guide link before it matters.
- Stable active Lume links now fade to a subtler line while activation, restore, contested, severed, selected-endpoint, and Always-mode states stay readable.
- Added battle-session-only `Links: Auto`, `Links: Always`, and `Links: Hidden` controls to the existing Lume HUD row.
- Expanded Lume render snapshots so hosted tests can assert visibility mode, visible state, emphasis, pulse kind, alpha, width, and layer depth.
- Private-demo Results now use `PRIVATE DEMO COMPLETE`, show the Lume/no-save summary above the fold, expose primary actions immediately, and collapse full battle telemetry behind `Show Full Battle Details`.
- Updated package generation and package verification to include v0.85 docs and tester guidance.
- Extended smoke, hosted, unit, and visual QA coverage around the contextual overlay and Results rescue.

Not changed:

- No save-version bump, save fields, localStorage keys, persistent settings, persistent rewards, campaign progression, maps, factions, races, units, buildings, classes, art/assets, internal ID renames, Lume balance changes, `linked_ward` stacking changes, resource-production bonuses, global balance changes, desktop work, multiplayer, PvP, co-op, or runtime rebrand/display-copy migration was added.

Verification:

- Passed: focused Lume rendering/director/objective/Results/package Vitest coverage with 5 files / 42 tests, `npm test` with 88 files / 664 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, fast smoke with 9 tests after an initial short shell timeout, full smoke with 15 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests after an initial 10-minute shell timeout, hosted smoke with 15 tests, hosted deep-campaign-pressure with 8 tests, and visual QA with 6 tests / 29 screenshots / 0 console errors / 0 retries.

# v0.84 Guided Lume Demo Readability And Fast-Retest Polish - 2026-05-30

This checkpoint polishes the package/dev-only Aether Well Lume demo so Emmanuel can understand and retest the existing Lume slice faster, without changing Lume balance, save data, campaign progression, or runtime identity.

Added:

- `docs/V084_GUIDED_LUME_DEMO_READABILITY_SPEC.md`.
- `docs/V084_LUME_LINK_RENDERING_SPEC.md`.
- `docs/V084_PRIVATE_DEMO_FAST_RETEST_SPEC.md`.
- `docs/V084_VISUAL_QA_REPORT.md`.
- `docs/V084_EMMANUEL_RETEST_CHECKLIST.md`.
- `docs/V084_IMPLEMENTATION_REPORT.md`.
- `docs/V084_DEFERRED_BATTLEFIELD_UX_FINDINGS.md`.

Changed:

- Replaced the dense private Lume HUD paragraph with a progressive `LUME WARD` and `LUME LINKS x/2` tracker.
- Added compact private-demo copy with a Details disclosure so the no-save/no-reward warning stays visible but less bulky.
- Added private-demo focus controls for West Stone Cut, Ford Toll, and the optional North Aether Spring reveal.
- Added private-demo `Exit Demo` and post-activation `Finish Demo & View Results` actions.
- Added procedural Lume link/endpoint rendering for inactive, active, contested, severed, and restored battlefield states.
- Shortened and deduped Lume notifications for awakened, severed, restored, and full-network states.
- Updated package generation and package verification to include the v0.84 docs and tester guidance.
- Hardened the hosted Lume proxy against a test race where a nearby player unit could instantly recapture Ford Toll after the test forced enemy ownership.
- Hardened an existing Cinderfen visual-QA helper with a test-only fallback when the neutral brute has already been cleared.

Not changed:

- No save-version bump, save fields, persistent rewards, maps, factions, races, units, buildings, classes, art/assets, internal ID renames, public campaign prerequisite changes, Lume balance changes, `linked_ward` stacking changes, resource-production bonuses, global balance changes, desktop work, multiplayer, PvP, co-op, or runtime rebrand/display-copy migration was added.

Verification:

- Passed: focused Lume director/objective-panel Vitest coverage with 2 files / 10 tests, package validation tests with 3 tests, targeted private Lume smoke with 1 test, targeted Lume deep-flow with 1 test, hosted Lume proxy with 1 test, `npm test` with 87 files / 659 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, fast smoke with 9 tests, full smoke with 15 tests after an infrastructure-only timeout/server-kill rerun, controls normal/extended/verify, Act 1 telemetry, hosted smoke with 15 tests, hosted deep-battle with 29 tests, hosted deep-campaign-pressure with 8 tests after the Lume race fix, visual QA with 6 tests / 26 screenshots / 0 console errors / 0 retries after the Cinderfen helper fallback, dirty pre-commit package generation, and dirty package verification with 265 checks.

# v0.83 Campaign Map UX Rescue And Private Playtest Quick Launch - 2026-05-30

This checkpoint rescues the campaign screen by making the node map the first visible surface again, while adding a private playtest shortcut for the existing Aether Well Lume runtime slice.

Added:

- `src/game/playtest/PrivatePlaytestTools.ts`.
- `docs/V083_CAMPAIGN_MAP_UX_RESCUE_SPEC.md`.
- `docs/V083_PRIVATE_PLAYTEST_QUICK_LAUNCH_SPEC.md`.
- `docs/V083_IMPLEMENTATION_REPORT.md`.
- `docs/V083_VISUAL_QA_REPORT.md`.
- `docs/V083_PRIVATE_PLAYTEST_LAUNCH_NOTES.md`.
- `docs/V083_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Reworked Campaign Map into a map-first tabbed layout with a visible selected-node summary and primary action.
- Moved Stronghold, Hero, Inventory, Intel, and Reputation support surfaces behind campaign tabs.
- Added an explicit private-tool flag path for private playtest packages and development builds.
- Added a private Aether Well Lume demo launch that reaches the existing Aether Well Ruins Lume slice from a fresh campaign while disabling rewards/progress.
- Added private demo HUD and Results no-save/no-reward copy.
- Updated package generation and package verification to require v0.83 docs plus the private tool marker.
- Added smoke coverage for campaign map node overlap and private Lume demo no-save isolation.
- Added visual QA coverage for campaign map rescue and the private Lume launch at 1920x1080 and 1366x768.

Not changed:

- No save-version bump, save fields, persistent rewards, maps, factions, races, units, buildings, classes, art/assets, internal ID renames, public campaign prerequisite changes, broad Lume expansion, global balance change, desktop work, multiplayer, PvP, co-op, or runtime rebrand/display-copy migration was added.

Verification:

- Passed: focused Lume/package Vitest coverage with 4 files / 45 tests, `npm test` with 87 files / 656 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, targeted map/private smoke with 2 tests, fast smoke with 9 tests, full smoke with 15 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests, hosted smoke with 15 tests, hosted deep-campaign-pressure with 8 tests, visual QA with 6 tests / 26 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, and dirty package verification with 258 checks.

# v0.82 Mission-Local Lume Network Runtime Prototype - 2026-05-30

This checkpoint implements the smallest runtime Lume Network slice approved by v0.81. Aether Well Ruins on Broken Ford now supports a battle-local linked-site objective: capture West Stone Cut plus Ford Toll, or Ford Toll plus North Aether Spring, to activate Linked Ward.

Added:

- `src/game/types/LumeNetworkTypes.ts`.
- `src/game/data/lumeNetworks.ts`.
- `src/game/data/validation/validateLumeNetworks.ts`.
- `src/game/battle/LumeNetworkDirector.ts`.
- `src/game/battle/LumeNetworkDirector.test.ts`.
- `docs/V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md`.
- `docs/V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md`.
- `docs/V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md`.
- `docs/V082_EMMANUEL_RETEST_CHECKLIST.md`.
- `docs/V082_IMPLEMENTATION_REPORT.md`.

Changed:

- Added content validation for Lume Network definitions and package validation for the v0.82 docs.
- Added Lume Network briefing copy to the Aether Well Ruins campaign node.
- Added battle-local Lume telemetry fields to Results stats without adding save fields.
- Added HUD, selected-site, and Results summaries for active, contested, and severed Lume links.
- Added Linked Ward as a non-stacking mission-local defensive benefit: friendly units and buildings near active linked sites take 8% less incoming damage from enemy attacks.
- Added a hosted proxy covering activation, enemy recapture/severing, and Results summary for Aether Well Ruins.

Not changed:

- No save-version bump, save fields, internal ID migration, maps, factions, races, units, buildings, classes, art/assets, desktop wrapper, engine choice, runtime rebrand, runtime display-copy migration, Jardas binding, Worker binding, hero binding, resource-production bonus, global balance change, enemy AI bump, multiplayer, PvP, or co-op was added.

Verification:

- Passed: `npm test` with 87 files / 654 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, focused package validation with 3 tests, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests, hosted deep-campaign-pressure with 8 tests including the Aether Well Lume proxy, hosted smoke with 14 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, dirty package verification with 251 checks, and `git diff --check`.

# v0.81 Lume Site Network Prototype Specification And Smallest-Fun-Slice Gate - 2026-05-30

This checkpoint is docs-only. It audits the existing resource-site and campaign architecture, compares small Lume Network prototype candidates, and recommends a mission-local Linked Control slice for Emmanuel review before any runtime implementation.

Added:

- `docs/V081_EXISTING_SITE_SYSTEM_AUDIT.md`.
- `docs/V081_LUME_NETWORK_DESIGN_PRINCIPLES.md`.
- `docs/V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md`.
- `docs/V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md`.
- `docs/V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md`.
- `docs/V081_DATA_MODEL_AND_INTEGRATION_PLAN.md`.
- `docs/V081_UI_READABILITY_AND_TEACHING_SPEC.md`.
- `docs/V081_RACE_EXTENSIBILITY_MATRIX.md`.
- `docs/V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md`.
- `docs/V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md`.
- `docs/V081_FUTURE_IMPLEMENTATION_SEQUENCE.md`.
- `docs/V081_EMMANUEL_REVIEW_PACKET.md`.
- `docs/V081_IMPLEMENTATION_REPORT.md`.

Changed:

- Updated README, roadmap, handoff, checkpoint, release checklist, package metadata, and package validation lists so the v0.81 Lume Site Network planning packet is discoverable and package-verifiable.

Recommendation:

- Use `aether_well_ruins` on `broken_ford` as the first future testbed.
- Start with battle-local Linked Control, maximum three eligible sites, maximum two active links, and `Linked Ward` as the first non-stacking defensive benefit.
- Keep hero/Jardas binding deferred unless Emmanuel chooses a stronger identity-first prototype.

Not changed:

- No runtime behavior, save format, internal IDs, gameplay balance, enemy AI, pathing, controls, runtime UI, maps, factions, races, units, buildings, classes, assets, art generation/import, desktop wrapper, engine choice, runtime rebrand, runtime copy migration, Lume Network implementation, multiplayer, PvP, or co-op code changed.

Verification:

- Passed: `npm test` with 86 files / 644 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, focused package validation test with 3 tests, dirty pre-commit package generation, dirty package verification with 246 checks, and final `git diff --check`.

# v0.80 Salto Lume And Display-Copy Migration Plan - 2026-05-30

This checkpoint is docs-only. It inventories current runtime-facing terminology and creates a safe migration plan for future Salto, Barrosan, Lume, title, and display-copy work without starting runtime copy migration.

Added:

- `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`.
- `docs/V080_TERMINOLOGY_TAXONOMY.md`.
- `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`.
- `docs/V080_SAFE_COPY_BATCHES.md`.
- `docs/V080_TEST_AND_ROLLBACK_PLAN.md`.
- `docs/V080_EMMANUEL_REVIEW_PACKET.md`.
- `docs/V080_IMPLEMENTATION_REPORT.md`.

Changed:

- Updated README, roadmap, handoff, checkpoint, release checklist, package metadata, and package validation lists so the v0.80 display-copy planning packet is discoverable and package-verifiable.

Inventory:

- 72 rows across title/brand/package, faction/world terms, campaign nodes/briefings, resources/economy/sites, hero/abilities/builds, items/relics/rewards, battle events/AI/Results, and Tutorial/onboarding surfaces.
- Recommended keeping Mana as the tactical hero ability resource for now, treating Lume as the future living land-power term, and reviewing Aether case by case instead of blanket-renaming it.

Not changed:

- No runtime behavior, save format, internal IDs, gameplay balance, enemy AI, pathing, controls, runtime UI, maps, factions, races, units, buildings, classes, assets, art generation/import, desktop wrapper, engine choice, runtime rebrand, runtime copy migration, Lume Network implementation, multiplayer, PvP, or co-op code changed.

Verification:

- Passed: `npm test` with 86 files / 644 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, focused package validation test with 3 tests, explicit JSON parse of the v0.80 inventory, dirty pre-commit package generation, dirty package verification with 233 checks, and final `git diff --check`.

# v0.79 Emmanuel Creative Review Incorporation And Direction Lock - 2026-05-30

This checkpoint is docs-only. It records Emmanuel's human-approved decisions after the v0.78 review packet, converts the approved proposals into an explicit direction lock, lists provisional/deferred decisions, and defines the safe next milestone sequence without starting v0.80.

Added:

- `docs/V079_EMMANUEL_APPROVAL_LEDGER.md`.
- `docs/V079_DIRECTION_LOCK_SUMMARY.md`.
- `docs/V079_VERTICAL_SLICE_PRIORITY_LOCK.md`.
- `docs/V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md`.
- `docs/V079_DEFERRED_DECISIONS_REGISTER.md`.
- `docs/V079_SAFE_NEXT_MILESTONE_SEQUENCE.md`.
- `docs/V079_IMPLEMENTATION_REPORT.md`.

Changed:

- Updated README, roadmap, handoff, checkpoint, release checklist, package metadata, and package validation lists so the v0.79 direction-lock docs are discoverable and package-verifiable.

Locked direction:

- Approved `JARDAS: Oath of the Barrosan Marches` as the leading public-title direction, with `JARDAS` as the dominant logo word and `Ascendant Realms` retained as the internal repository codename.
- Approved Salto, the Barrosan Marches, Lume, the Jardas meaning, Captain Malrec's rival direction, the one-human/one-mixed/six-non-human race-roster structure, Barrosan/Ashen/Wolfveil vertical-slice priority, future Race + Class + Origin + Oath hero architecture, Lume Network as the first future signature-system design gate, five-act campaign direction, visual direction, and browser-prototype-to-desktop roadmap principles.

Not changed:

- No runtime behavior, save format, internal IDs, gameplay balance, enemy AI, pathing, controls, runtime UI, maps, factions, races, units, buildings, hero classes, assets, art generation/import, desktop wrapper, engine choice, runtime rebrand, runtime copy migration, Lume Network implementation, multiplayer, PvP, or co-op code changed.

Verification:

- Passed: `npm test` with 86 files / 644 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, focused package validation test with 3 tests, dirty pre-commit package generation, dirty package verification with 226 checks, and `git diff --check`.

# v0.78 Creative Identity Lock And Original-IP Separation Pass - 2026-05-30

This checkpoint is docs-only. It defines the proposed public identity and long-term product direction before further runtime expansion: `JARDAS: Oath of the Barrosan Marches` as the leading title proposal, Jardas/Lume/Salto/Barrosan Marches lore, an eight-race master roster draft, future Race + Class + Origin + Oath hero architecture, signature gameplay pillars, a five-act campaign outline, browser-to-desktop transition gates, visual direction and AI-art governance, display-name migration safety, original-IP separation, future implementation sequence, and an Emmanuel review packet.

Added:

- `docs/V078_CREATIVE_IDENTITY_LOCK_PLAN.md`.
- `docs/V078_PUBLIC_TITLE_AND_BRAND_OPTIONS.md`.
- `docs/V078_WORLD_AND_LORE_BIBLE_DRAFT.md`.
- `docs/V078_RACE_AND_FACTION_MASTER_MATRIX.md`.
- `docs/V078_HERO_RACE_CLASS_ORIGIN_OATH_ARCHITECTURE.md`.
- `docs/V078_SIGNATURE_GAMEPLAY_PILLARS.md`.
- `docs/V078_LONG_CAMPAIGN_MASTER_OUTLINE.md`.
- `docs/V078_BROWSER_TO_DESKTOP_TRANSITION_GATE.md`.
- `docs/V078_VISUAL_DIRECTION_AND_AI_ART_GOVERNANCE.md`.
- `docs/V078_VISUAL_VERTICAL_SLICE_BRIEF.md`.
- `docs/V078_DISPLAY_NAME_MIGRATION_MAP.md`.
- `docs/V078_ORIGINAL_IP_SEPARATION_LEDGER.md`.
- `docs/V078_FUTURE_IMPLEMENTATION_SEQUENCE.md`.
- `docs/V078_EMMANUEL_REVIEW_PACKET.md`.
- `docs/V078_IMPLEMENTATION_REPORT.md`.

Changed:

- Updated README, roadmap, handoff, checkpoint, release checklist, package metadata, and package validation lists so the docs-only v0.78 review packet is discoverable and package-verifiable.

Not changed:

- No runtime behavior, save format, internal IDs, gameplay balance, enemy AI, pathing, controls, runtime UI, maps, factions, races, units, buildings, assets, art generation/import, desktop wrapper, engine choice, multiplayer, PvP, or co-op code changed.

Verification:

- Passed: `npm test` with 86 files / 644 tests, `npm run build` with the known Vite Phaser vendor chunk-size warning, `npm run validate:content`, `npm run validate:art-intake`, focused package validation test with 3 tests, dirty pre-commit package generation, dirty package verification with 219 checks, and `git diff --check`.

# v0.75-v0.77 Act 1 Finale And Rival Commander Milestone - 2026-05-30

This checkpoint turns Ashen Outpost into a readable Act 1 climax around Captain Malrec, existing doctrines/elites, tactical plans, battlefield events, Retinue, hero skills, relics, and Results debriefs. No maps, factions, runtime art/assets, save migration, giant boss system, broad AI/pathing rewrite, global rebalance, shop/crafting, or canvas/world force-click behavior were added.

Added:

- Added `docs/V075_ACT1_FINALE_ENCOUNTER_SPEC.md`.
- Added `docs/V076_RIVAL_COMMANDER_PHASES_SPEC.md`.
- Added `docs/V077_MILESTONE_REWARD_AND_DEBRIEF_SPEC.md`.
- Added `docs/V075_IMPLEMENTATION_REPORT.md`.
- Added `docs/V076_IMPLEMENTATION_REPORT.md`.
- Added `docs/V077_IMPLEMENTATION_REPORT.md`.
- Added `docs/V077_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Added deterministic Ashen Outpost finale data and `Act1FinaleDirector` with three phases: secure foothold, break fortified line, defeat Captain Malrec.
- Added battle-only finale stats and Results debrief rows for phase completion, commander release/defeat, tactical-plan support, and Act 1 completion next steps.
- Gated Captain Malrec out of coordinated attack waves until the final phase.
- Reused existing objective HUD and battlefield-event surfaces for phase titles, short objectives, commander alerts, and event hooks.
- Updated Ashen Outpost briefing, reward/debrief copy, and Act 1 spine label to `Ashen Outpost Finale`.
- Updated hosted Ashen Outpost proxy coverage for phase progression, commander behavior, Act 1 complete Results, and replay-safe milestone rewards.
- Updated package metadata and validation to name `v0.75-v0.77 Act 1 finale and rival commander milestone`.
- Adjusted first-capture reward status priority so one-time capture bonuses remain readable when pressure warnings fire from the same trigger.

Verification:

- Passed: focused finale/content tests with 70 tests, focused hosted Ashen Outpost proxy, `npm test` with 86 files / 644 tests, production build with the known Vite Phaser vendor chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA rerun with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package verification with 204 checks, and `git diff --check`.
- Non-pass evidence: initial unit run had one stale Act 1 label assertion; full smoke found Cinder Shrine reward status hidden by a same-trigger pressure warning; hosted smoke first rerun served stale `dist`; visual QA first attempt missed the first screenshot group after an app-boot flake. Each issue was either fixed or rerun clean with the original checks intact.

# v0.72-v0.74 Dynamic Battlefield Events And Tactical Objectives - 2026-05-30

This checkpoint adds a small battle-session-only event layer that reacts to mission type, enemy doctrine, elite squads, player tactical plan, Retinue readiness, and resource-site state. It uses existing maps, units, AI hooks, HUD, and Results surfaces only. No maps, factions, runtime art/assets, save migration, persistent event state, broad AI/pathing rewrite, global rebalance, giant event system, shop/crafting, formation editor, or canvas/world force-click behavior were added.

Added:

- Added `docs/V072_BATTLEFIELD_EVENT_DIRECTOR_SPEC.md`.
- Added `docs/V073_DYNAMIC_TACTICAL_OBJECTIVES_SPEC.md`.
- Added `docs/V074_ADAPTIVE_PRESSURE_AND_READABILITY_SPEC.md`.
- Added `docs/V072_IMPLEMENTATION_REPORT.md`.
- Added `docs/V073_IMPLEMENTATION_REPORT.md`.
- Added `docs/V074_IMPLEMENTATION_REPORT.md`.
- Added `docs/V074_EMMANUEL_RETEST_CHECKLIST.md`.

Changed:

- Added validated Battlefield Event definitions for Site Under Threat, Hold the Line, Elite Strike, Reinforcement Window, and Aether Surge.
- Added a battle-local `BattlefieldEventDirector` with Tutorial/no-reward protection, one-active-major-event cap, cooldowns, max-per-battle cap, and deterministic mission/doctrine/modifier/plan weighting.
- Added event HUD copy with event title, short objective, timer/progress, counterplay hint, and plan-support note.
- Added dynamic objective outcomes and small battle-local bonuses for completed event objectives only.
- Added Results battlefield-event summaries for events encountered, completed/failed objectives, and plan-supported outcomes.
- Added hosted deep-campaign proxy coverage for Tutorial protection, Site Under Threat, Elite Strike, tactical-plan interaction, and Results summaries.
- Updated package metadata and validation to name `v0.72-v0.74 dynamic battlefield events and tactical objectives`.

Verification:

- Full checkpoint verification passed locally: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run test:e2e:smoke`, control playtests, Act 1 telemetry, hosted deep-battle, hosted smoke, hosted deep-campaign-pressure, visual QA, package generation, package verification, and `git diff --check`.
- Non-pass evidence: first hosted deep-campaign-pressure run found event objective status could outrank an existing pressure warning. Status priority was fixed so active pressure warnings stay readable, then the exact failed test and full hosted lane reran green.

## v0.69-v0.71 Pre-Battle Tactical Preparation Foundation - 2026-05-30

This checkpoint turns enemy doctrine readability into actionable pre-battle preparation through concise campaign intelligence, launch-local tactical plan selection, and counter-doctrine recommendations. No maps, factions, runtime art/assets, save migration, new persistent save fields, broad AI/pathing rewrite, global rebalance, shop/crafting, formation editor, or canvas/world force-click behavior were added.

### Included

- Added `docs/V069_PRE_BATTLE_INTELLIGENCE_SPEC.md`.
- Added `docs/V070_TACTICAL_PLAN_SELECTION_SPEC.md`.
- Added `docs/V071_COUNTER_DOCTRINE_PREPARATION_SPEC.md`.
- Added `docs/V069_IMPLEMENTATION_REPORT.md`.
- Added `docs/V070_IMPLEMENTATION_REPORT.md`.
- Added `docs/V071_IMPLEMENTATION_REPORT.md`.
- Added `docs/V071_EMMANUEL_RETEST_CHECKLIST.md`.
- Added Guarded Advance, Resource Push, and Champion Hunt tactical plan definitions.
- Added doctrine-to-plan recommendations for Raider, Fortress, Hunter, and Warband.
- Added pre-battle intelligence to campaign node details: expected doctrine, elite risk, mission modifiers, counterplay, Retinue/reinforcement reminder, and hero/relic build hint.
- Added session-only tactical plan selection and one non-stacking tactical launch modifier for eligible campaign battles.
- Added modest plan effects: cheaper Call Retinue, small starting resources, and small hero max-Mana support.
- Added battle HUD active-plan copy and Results tactical-plan after-action summary.
- Updated hosted deep-campaign coverage for tactical intel, plan selection, battle HUD propagation, and Results summary.
- Updated package metadata and validation to name `v0.69-v0.71 pre-battle tactical preparation foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly through eligible campaign battle launch-local tactical modifiers.
- Gameplay numbers changed: only small launch-local plan effects; no global balance changes.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward with no tactical-plan complexity.
- Retinue/reinforcement changed: Guarded Advance can reduce Call Retinue cost to 60 Crowns in eligible campaign battles.

### Verification

- Passed: focused tactical-plan/launch/runtime/Retinue tests with 33 tests, focused campaign/Results/content tests with 70 tests, package validation focused test, `npm test` with 83 files / 627 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle rerun with 29 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, and visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries.
- Non-pass evidence: first hosted deep-battle attempt failed because an existing Retinue reinforcement proxy still expected the old 75-Crowns cost. The checkpoint intentionally gives default Guarded Advance a 60-Crowns Call Retinue cost; the proxy was updated to assert the new button copy and resource delta, then the exact failed test and full hosted deep-battle lane passed.

## v0.66-v0.68 Enemy Tactical Doctrines And Elite Squad Foundation - 2026-05-30

This checkpoint adds readable enemy tactical variety through small data-driven doctrines, occasional capped elite squads, and concise counterplay copy. No maps, factions, runtime art/assets, save-version bump, new save fields, global rebalance, broad pathing rewrite, enemy formation rewrite, giant roster, shop/crafting, or canvas/world force-click behavior were added.

### Included

- Added `docs/V066_ENEMY_TACTICAL_DOCTRINES_SPEC.md`.
- Added `docs/V067_ELITE_SQUAD_FOUNDATION_SPEC.md`.
- Added `docs/V068_COUNTERPLAY_READABILITY_SPEC.md`.
- Added `docs/V066_IMPLEMENTATION_REPORT.md`.
- Added `docs/V067_IMPLEMENTATION_REPORT.md`.
- Added `docs/V068_IMPLEMENTATION_REPORT.md`.
- Added `docs/V068_EMMANUEL_RETEST_CHECKLIST.md`.
- Added Raider, Fortress, Hunter, and Warband doctrine definitions.
- Added mission/modifier/enemy-hero doctrine selection with Tutorial/no-reward protection.
- Added conservative doctrine hooks for resource raids, defensive reserves, guarded hero/Retinue pressure, and late mixed pushes.
- Added Ash Raider Vanguard and Cinder Iron Guard elite squad definitions with modest capped stat bonuses.
- Added campaign briefing, battle HUD, selected-unit renderer, and Results copy for doctrine, elite squad, and counterplay readability.
- Updated hosted deep-campaign coverage for Raider/Fortress doctrine and Cinder Iron Guard elite after-action summary.
- Updated package metadata and validation to name `v0.66-v0.68 enemy tactical doctrines and elite squad foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for enemy tactical AI hooks and battle-only elite squad tags.
- Gameplay numbers changed: only mission-local doctrine timing/size/reserve hooks and capped elite unit bonuses; no global balance changes.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward with no doctrine or elite complexity.
- Retinue/reinforcement changed: no, but Hunter doctrine can target exposed hero/Retinue only when escorted and cooldown-gated.

### Verification

- Passed: focused doctrine/AI/HUD/Results/campaign tests, focused hosted Raider/Fortress/elite proxy with 2 tests, `npm test` with 82 files / 620 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke rerun with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, dirty package verification with 183 checks, and `git diff --check`.
- Non-pass evidence: initial `npm test` failed because the new elite damage multiplier lacked a fallback for lightweight Unit/Hero test doubles; fixed with a `?? 1` fallback and reran green. First full-smoke attempt timed out at the command wrapper after 364 seconds with no Playwright summary; a longer clean rerun passed all 14 tests.

## v0.63-v0.65 Retinue Recovery And Reinforcement Foundation - 2026-05-30

This checkpoint adds save-safe Retinue recovery, clearer reserve management, and one controlled Call Retinue battle command. No maps, factions, runtime art/assets, save-version bump, giant roster UI, permanent control groups, shop/crafting, broad AI/pathing rewrite, global rebalance, formation editor, or canvas/world force-click behavior were added.

### Included

- Added `docs/V063_RETINUE_RECOVERY_SPEC.md`.
- Added `docs/V064_RESERVE_MANAGEMENT_SPEC.md`.
- Added `docs/V065_BATTLEFIELD_REINFORCEMENT_SPEC.md`.
- Added `docs/V063_IMPLEMENTATION_REPORT.md`.
- Added `docs/V064_IMPLEMENTATION_REPORT.md`.
- Added `docs/V065_IMPLEMENTATION_REPORT.md`.
- Added `docs/V065_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `recovering` Retinue status with optional one-step recovery timer.
- Added legacy `wounded` normalization, lost-entry filtering, and Ready-only deployment selection.
- Added Retinue Camp Ready reserve and Recovering count/readability copy.
- Added campaign-only Call Retinue with 75 Crowns battle cost, Ready reserve requirement, Command Hall gating, one-use cap, safe Command Hall spawn, minimap ping, and Results recording.
- Added Results summaries for reinforcement, participating Retinue, survivors, losses, entering recovery, and returned Ready.
- Updated hosted deep-battle coverage for Retinue reinforcement/recovery.
- Updated package metadata and validation to name `v0.63-v0.65 Retinue recovery and reinforcement foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for Retinue recovery and one controlled reinforcement call.
- Gameplay numbers changed: 35% recovery threshold and 75 Crowns battle reinforcement cost only; no global balance changes.
- Save format changed: no save-version bump; added optional `recoveryMissionsRemaining` on Retinue entries.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward with no Retinue mutation or reinforcement option.
- Inventory/loot changed: no.

### Verification

- Passed: focused Retinue/save/results/HUD/package tests, focused hosted Retinue reinforcement/recovery proxy, `npm test` with 81 files / 610 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, fast smoke rerun with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 29 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification with 176 checks, and `git diff --check`.
- Non-pass evidence: the first fast-smoke attempt timed out after 184 seconds with no summary before the clean rerun passed.

## v0.60-v0.62 Persistent Retinue And Deployment Foundation - 2026-05-29

This checkpoint turns the existing opt-in Retinue Camp into a small persistent survivor roster with explicit pre-battle deployment selection. No maps, factions, runtime art/assets, save-version bump, giant roster UI, permanent control groups, shop/crafting, broad AI/pathing rewrite, global rebalance, or canvas/world force-click behavior were added.

### Included

- Added `docs/V060_RETINUE_PERSISTENCE_FOUNDATION_SPEC.md`.
- Added `docs/V061_PRE_BATTLE_DEPLOYMENT_SPEC.md`.
- Added `docs/V062_SURVIVOR_CONTINUITY_AND_RESULTS_SPEC.md`.
- Added `docs/V060_IMPLEMENTATION_REPORT.md`.
- Added `docs/V061_IMPLEMENTATION_REPORT.md`.
- Added `docs/V062_IMPLEMENTATION_REPORT.md`.
- Added `docs/V062_EMMANUEL_RETEST_CHECKLIST.md`.
- Added eligible Retinue validation for Militia, Ranger, and Acolyte only.
- Added explicit Retinue roster capacity and separate deployment selection.
- Added `retinueDeploymentIds` save normalization and Campaign Map deploy/reserve toggles.
- Added Retinue survival/deployment counters and Results survived/lost continuity copy.
- Updated Results Retinue recruitment copy to distinguish roster capacity, deployment selected count, eligibility, and full-roster state.
- Updated hosted Retinue proxy coverage for recruitment, full roster, deployment toggles, and battle spawn.
- Updated package metadata and validation to name `v0.60-v0.62 persistent Retinue and deployment foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for persistent Retinue roster/deployment choice.
- Gameplay numbers changed: Retinue roster/deployment caps only; no global balance changes.
- Save format changed: no save-version bump; added backward-compatible `retinueDeploymentIds` plus optional Retinue counters.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward with no Retinue recruitment/deployment complexity.
- Inventory/loot changed: no.

### Verification

- Passed: focused Retinue/save/results/package tests, `npm test` with 80 files / 603 tests, content validation, art-intake validation, production build with the known Vite Phaser chunk-size warning, focused hosted Retinue proxy with 2 tests, fast smoke with 8 tests, full smoke rerun with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 28 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, local release shards 2/3 and 3/3 with 34 and 14 tests, dirty pre-commit package generation, package verification with 169 checks, and `git diff --check`.
- Non-pass evidence: first full-smoke attempt timed out after 5 minutes with no summary before the clean rerun passed; local release shard 1/3 timed out after 20 minutes with no summary. Required hosted lanes passed.

## v0.57-v0.59 Army Veterancy And Tactical Feedback Foundation - 2026-05-29

This checkpoint adds small battle-only army veterancy, unit-role identity copy, and tactical feedback polish. No maps, factions, runtime art/assets, save migration, permanent army roster, broad pathing rewrite, global rebalance, huge unit stat overhaul, formation editor, Patrol rewrite, or canvas/world force-click behavior were added.

### Included

- Added `docs/V057_ARMY_VETERANCY_FOUNDATION_SPEC.md`.
- Added `docs/V058_UNIT_ROLE_IDENTITY_SPEC.md`.
- Added `docs/V059_TACTICAL_COMBAT_FEEDBACK_SPEC.md`.
- Added `docs/V057_IMPLEMENTATION_REPORT.md`.
- Added `docs/V058_IMPLEMENTATION_REPORT.md`.
- Added `docs/V059_IMPLEMENTATION_REPORT.md`.
- Added `docs/V059_EMMANUEL_RETEST_CHECKLIST.md`.
- Added validated role metadata for player combat units, Hero, Worker utility, buildings where relevant, enemy readability, and neutral targets.
- Added selected-unit role tags, rank, XP, kills, modest veteran-bonus copy, and battle-only scope.
- Added selected-group role mix and ranked-member summaries so recalled groups stay readable.
- Added role-aware training command copy.
- Added clearer Worker construction order summaries.
- Added Results copy for veteran units survived and battle-only normal-unit veterancy scope.
- Extended hosted deep-battle coverage for role copy, veteran display, control-group recall, movement spacing, Patrol start/cancel, and Worker command regression.
- Updated package metadata and validation to name `v0.57-v0.59 army veterancy and tactical feedback foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for battle-only unit veterancy/readability.
- Gameplay numbers changed: only modest battle-local veteran bonuses for units that earn Veteran status.
- Save format changed: no save-version bump and no new save fields.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward with no veterancy requirement.
- Inventory/loot changed: no.

### Verification

- Passed: focused role/veterancy/tactical tests with 99 tests, package validation tests, `npm test` with 80 files / 602 tests, content validation, art-intake validation, production build with the known Vite Phaser chunk-size warning, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 28 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, and package verification with 162 checks.
- Non-pass evidence: early local smoke attempts included timeout/no-summary and dev-server-not-running setup failures before green reruns; one intermediate full-smoke settings failure passed exact rerun and later clean full-smoke rerun; local release shard 1 timed out after 20 minutes without a summary. Hosted release lanes and local smoke evidence passed after cleanup.

## v0.54-v0.56 Control Groups And Patrol Foundation - 2026-05-29

This checkpoint adds controlled RTS command depth through session-only control groups, lightweight group move spacing, and a minimal Patrol command. No maps, factions, save migration, runtime art/assets, broad pathing rewrite, global rebalance, formation editor, enemy formation AI, giant command rewrite, or canvas/world force-click behavior were added.

### Included

- Added `docs/V054_CONTROL_GROUPS_FOUNDATION_SPEC.md`.
- Added `docs/V055_FORMATION_AWARE_MOVEMENT_SPEC.md`.
- Added `docs/V056_PATROL_FOUNDATION_SPEC.md`.
- Added `docs/V054_IMPLEMENTATION_REPORT.md`.
- Added `docs/V055_IMPLEMENTATION_REPORT.md`.
- Added `docs/V056_IMPLEMENTATION_REPORT.md`.
- Added `docs/V056_EMMANUEL_RETEST_CHECKLIST.md`.
- Added session-only Ctrl+1 through Ctrl+5 assignment and 1 through 5 recall for living player units/heroes.
- Added dead-member cleanup and filtering so enemies, buildings, resource sites, and invalid ids do not enter control groups.
- Added compact selected-panel group summary and HUD feedback for group assignment/recall.
- Added conservative per-unit destination offsets for multi-unit move and attack-move commands.
- Added minimal Patrol for combat units/heroes with `P` hotkey, HUD command, Stop command, order summary, existing combat acquisition, and explicit cancellation.
- Extended hosted deep-battle coverage for control groups, group move spacing, Patrol start/cancel, Worker command regression, and hero ability hotkey regression.
- Updated package metadata and validation to name `v0.54-v0.56 control groups and Patrol foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for player command depth.
- Gameplay numbers changed: no.
- Save format changed: no save-version bump and no new save fields.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward with no Patrol requirement.
- Inventory/loot changed: no.

### Verification

- Passed: TypeScript no-emit, focused control-depth/package tests with 46 tests, `npm test` with 78 files / 591 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, focused hosted control-depth proxy with 1 test, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 28 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, local release shards 1/3, 2/3, and 3/3 with 45, 34, and 14 tests, dirty pre-commit package generation, package verification with 155 checks, and `git diff --check`.
- Interaction note: existing verified DOM fallbacks were used for UI buttons, and existing verified pointer down/up handled stalled canvas right-click actionability. No force-click or DOM fallback was added for canvas/world clicks.

## v0.51-v0.53 Player-Facing UX And Command Readability Polish - 2026-05-29

This checkpoint improves the feel and readability of existing battle/campaign surfaces through cursor affordances, command disabled reasons, Worker intent clarity, hero ability state copy, combat status readability, and package/retest docs. No maps, factions, new gameplay systems, save migration, runtime art/assets, shop, crafting, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V051_PLAYER_UX_AUDIT_PLAN.md`.
- Added `docs/V051_PLAYER_UX_AUDIT_REPORT.md`.
- Added `docs/V051_IMPLEMENTATION_REPORT.md`.
- Added `docs/V052_COMMAND_AND_CURSOR_READABILITY_REPORT.md`.
- Added `docs/V053_COMBAT_AND_RESULTS_READABILITY_REPORT.md`.
- Added `docs/V053_EMMANUEL_RETEST_CHECKLIST.md`.
- Added pure cursor-intent rules and native cursor labels for attack, build/continue construction, repair, resource-site assignment, invalid target, and default movement states.
- Added command state / disabled-reason metadata to existing command buttons.
- Clarified Worker repair and resource-site assignment disabled reasons.
- Added hero ability reason metadata and standardized Mana copy.
- Improved Burn status chip size, contrast, and separation from health bars.
- Increased unit hover tolerance slightly for target confidence without changing combat or command semantics.
- Extended hosted deep-battle coverage for attack cursor labels, Worker build/repair/site hover intent, and hero ability cooldown reasons.
- Updated package metadata and validation to name `v0.51-v0.53 player-facing UX and command readability polish`.

### Verdict

- Runtime gameplay changed: no new mechanics; derived cursor/HUD/readability behavior changed.
- Gameplay numbers changed: no.
- Save format changed: no save-version bump and no new save fields.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward.
- Inventory/loot changed: no.

### Verification

- Passed: focused cursor/HUD/package tests with 20 tests, `npm test` with 76 files / 579 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, focused hosted UX proxy with 5 tests, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, Act 1 telemetry, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, and package verification with 148 checks.
- Optional local release shard evidence: shard 2 passed with 34 tests and shard 3 passed with 14 tests. Shard 1 had non-pass local-dev evidence with 43 passed / 1 failed on Results inventory-button retry/fallback timing; the exact failed case at `tests/e2e/deep-flow.spec.ts:6064` passed on rerun.

## v0.48-v0.50 Act 1 Playability And Release-Candidate Stabilization - 2026-05-29

This checkpoint stabilizes the existing Act 1 route as a release-candidate loop through deterministic telemetry, copy/readability polish, replay/reward clarity, hosted proxy coverage, and package hardening. No maps, factions, runtime art/assets, shop, crafting, giant quest system, save-breaking migration, broad campaign rewrite, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V048_ACT1_PLAYABILITY_AUDIT_PLAN.md`.
- Added `docs/V048_ACT1_PLAYTEST_TELEMETRY_REPORT.md`.
- Added `docs/V048_IMPLEMENTATION_REPORT.md`.
- Added `docs/V049_ACT1_BALANCE_AND_TELEMETRY_REPORT.md`.
- Added `docs/V050_ACT1_RELEASE_CANDIDATE_NOTES.md`.
- Added `docs/V050_IMPLEMENTATION_REPORT.md`.
- Added `docs/V050_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `Act1PlayabilityTelemetry`, `npm run playtest:act1`, and committed Act 1 telemetry Markdown/JSON outputs.
- Used deterministic telemetry to confirm Safe Beginner clears every Act 1 campaign battle and to classify harder-node failures as strategy-spread watchpoints.
- Applied copy-only Act 1 polish for Worker training, production, site assignment, site upgrades, army staging, skill spending, relic equip, champion relic choice, replay safety, and already-claimed objective credit.
- Extended hosted proxy coverage for Act 1 route unlock, resource-control guidance, champion relic guidance, and replay-safe copy.
- Updated package metadata and validation to require v0.48-v0.50 docs plus Act 1 telemetry artifacts.

### Verdict

- Runtime gameplay changed: no new mechanics; guidance/readability changed.
- Gameplay numbers changed: no.
- Save format changed: no save-version bump and no new save fields.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward.
- Inventory/loot changed: no new relics or inventory systems.

### Verification

- Passed: focused v0.48-v0.50 tests with 46 tests, `npm run playtest:act1`, content validation, art-intake validation, `npm test` with 75 files / 575 tests, production build with the known Vite Phaser chunk-size warning, focused hosted Act 1 proxy with 3 tests, fast smoke with 8 tests, full smoke on rerun with 14 tests, controls normal/extended/verify, hosted deep-battle on rerun with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, and local release shards 1/3, 2/3, and 3/3 after manually verifying the local dev server.
- Non-pass evidence: full local release timed out after 40 minutes without a summary; an earlier full smoke attempt timed out without a summary; the first hosted deep-battle attempt timed out without a summary; local shard 1 initially timed out once and then failed 44/44 with `ERR_CONNECTION_REFUSED` before a manual dev server was started.

## v0.45-v0.47 Act 1 Campaign Spine And Onboarding Polish - 2026-05-29

This checkpoint turns the existing campaign systems into a clearer Act 1 path: Tutorial / Proving Grounds, first persistent battle, base development, resource control, rival pressure, champion relic reward, and replayable objective cleanup. It uses existing campaign nodes, maps, scenario metadata, rewards, relic/skill systems, campaign UI, and Results UI. No factions, runtime art/assets, shop, crafting, cinematic system, giant quest system, save-breaking migration, broad campaign rewrite, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V045_ACT1_CAMPAIGN_SPINE_SPEC.md`.
- Added `docs/V046_DIFFICULTY_PACING_FOUNDATION_SPEC.md`.
- Added `docs/V047_ONBOARDING_AND_PLAYER_GUIDANCE_SPEC.md`.
- Added `docs/V045_IMPLEMENTATION_REPORT.md`.
- Added `docs/V046_IMPLEMENTATION_REPORT.md`.
- Added `docs/V047_IMPLEMENTATION_REPORT.md`.
- Added `docs/V047_EMMANUEL_RETEST_CHECKLIST.md`.
- Added content-driven Act 1 step metadata for Training, First Campaign Battle, Base Development, Resource Control, Rival Pressure, Champion Relic Milestone, and Replay Cleanup.
- Added `CampaignActSpineRules` helpers for recommended next steps, node-to-step lookup, locked reason copy, Results guidance, and replay guidance.
- Added campaign node details for Act 1 role, pacing tier, mechanic focus, unlock summary, locked reason, onboarding hint, and next action.
- Added Results guidance for next mission unlocks, replay availability, skill spending, relic equip, optional objective cleanup, and first-clear/replay context.
- Updated Act 1 node copy to make Workers, buildings, upgrades, resource sites, rival champion defeat, relic choice, skill spending, and replay objectives easier to follow.
- Updated package metadata and validation to name `v0.45-v0.47 Act 1 campaign spine and onboarding polish`.

### Verdict

- Runtime gameplay changed: yes, narrowly for campaign progression readability and Act 1 guidance.
- Gameplay numbers changed: no global rebalance and no new scenario modifiers.
- Save format changed: no save-version bump and no new save fields.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial / Proving Grounds remains no-save/no-reward.
- Inventory/loot changed: no new relics or inventory systems; the existing relic choice/equip flow receives clearer guidance.

### Verification

- Passed: focused Act 1 campaign/results tests with 31 tests, content validation, production build with the known Vite Phaser chunk-size warning, `npm test` with 74 files / 570 tests, focused package validation tests with 3 tests, focused hosted Act 1 proxy with 3 tests, art-intake validation, fast smoke with 8 tests after manual dev-server start, full smoke with 14 tests, controls normal/extended/verify, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, local release shard 1/3 with 44 tests, local release shard 2/3 with 34 tests, local release shard 3/3 with 14 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, dirty package verification with 133 checks, and `git diff --check`.
- Full local release note: `npm run test:e2e:release` exceeded a 40-minute tool timeout without returning a summary. The timed-out Playwright/Vite processes were stopped, and the 3-way release shard fallback passed completely.
- Smoke note: an initial fast-smoke timeout and a dev-server-not-running `ERR_CONNECTION_REFUSED` rerun were non-pass setup evidence; fast smoke passed after starting the dev server, and full smoke passed afterward.

## v0.42-v0.44 Mission Variety And Scenario Modifier Foundation - 2026-05-28

This checkpoint makes campaign battles read more like authored missions by adding mission types, small mission-local scenario modifiers, campaign briefing copy, Results after-action copy, and clearer pacing language. It uses existing maps, objectives, units, rewards, AI config, campaign UI, and Results UI. No new maps, factions, runtime art/assets, shop, crafting, giant quest system, save-breaking migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V042_MISSION_VARIETY_FOUNDATION_SPEC.md`.
- Added `docs/V043_SCENARIO_MODIFIERS_SPEC.md`.
- Added `docs/V044_CAMPAIGN_PACING_AND_BRIEFING_SPEC.md`.
- Added `docs/V042_IMPLEMENTATION_REPORT.md`.
- Added `docs/V043_IMPLEMENTATION_REPORT.md`.
- Added `docs/V044_IMPLEMENTATION_REPORT.md`.
- Added `docs/V044_EMMANUEL_RETEST_CHECKLIST.md`.
- Added Assault, Control, Defense, and Skirmish / Training mission type metadata.
- Added compact briefing, primary objective, reward preview, after-action, modifier, and build-hint metadata to existing campaign battle nodes.
- Added Rich Veins, Enemy Patrols, Fortified Enemy, and Aether Surge as conservative scenario modifiers.
- Routed scenario modifiers through existing battle launch modifiers, capture-site income, enemy AI config, and hero Mana modifier hooks.
- Added mission type/modifier/reward preview copy to Campaign Map node details and Results campaign reward blocks.
- Preserved replay reward safety, optional objective credit, rival relic choice, hero XP/skill reminders, and Tutorial no-save/no-reward protection.
- Updated package metadata and validation to name `v0.42-v0.44 mission variety and scenario modifier foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for mission-local modifier effects and campaign/Results readability.
- Gameplay numbers changed: narrowly, only through conservative battle-local modifier effects on selected campaign missions.
- Save format changed: no save-version bump and no new save fields.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial remains no-save/no-reward with no scenario modifier complexity.
- Inventory/loot changed: no.

### Verification

- Passed: TypeScript no-emit, focused mission/modifier/campaign/results tests with 71 tests, `npm test` with 73 files / 563 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, targeted hosted campaign briefing/modifier/replay proxy with 2 tests after a fresh build, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, hosted deep-meta with 12 tests, hosted layout-core with 20 tests, hosted layout-cinderfen with 12 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 screenshot retries, local deep-meta focused rerun with 12 tests, local layout boot group rerun with 4 viewport tests, dirty package generation, dirty package verification with 126 checks, and `git diff --check`.
- Full local release note: `npm run test:e2e:release` exceeded a 40-minute tool timeout without returning a summary, and `npm run test:e2e:release:shard1of3` exceeded a 20-minute timeout. Focused local reruns narrowed the surfaced failures to dev-server cold-boot/socket timing; hosted production-preview release groups are green and remain the final release-matrix evidence for this checkpoint.

## v0.39-v0.41 Campaign Progression And Mission Reward Foundation - 2026-05-28

This checkpoint makes the campaign feel more like a connected RTS/RPG route: campaign node first-clear state, replay-safe rewards, optional objective credit, rival champion reward context, XP, relic choice, and skill-point reminders now meet on the campaign map and Results screen. No maps, factions, runtime art/assets, shop, crafting, giant quest system, save-breaking migration, broad campaign rewrite, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V039_CAMPAIGN_PROGRESSION_FOUNDATION_SPEC.md`.
- Added `docs/V040_MISSION_REWARD_STRUCTURE_SPEC.md`.
- Added `docs/V041_REPLAY_AND_OBJECTIVE_STATE_SPEC.md`.
- Added `docs/V039_IMPLEMENTATION_REPORT.md`.
- Added `docs/V040_IMPLEMENTATION_REPORT.md`.
- Added `docs/V041_IMPLEMENTATION_REPORT.md`.
- Added `docs/V041_EMMANUEL_RETEST_CHECKLIST.md`.
- Made completed battle nodes replayable through the existing campaign map.
- Added campaign map reward preview/status copy for first-clear, replay, claimed, optional objectives, and rival build hints.
- Added backward-compatible optional objective completion credit in campaign saves.
- Added Results copy for campaign first-clear/replay state, node reward claimed/already-claimed state, optional objective state, relic choice, XP, and skill-point reminders.
- Preserved Tutorial no-save/no-reward protection and existing unique relic duplicate protection.
- Updated package metadata and validation to name `v0.39-v0.41 campaign progression and mission reward foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for campaign node replay, campaign reward labeling, and optional objective completion credit.
- Gameplay numbers changed: no global rebalance; replay rewards use the existing reduced repeat-clear reward path.
- Save format changed: backward-compatible campaign save field added; no save-version bump.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial remains no-save/no-reward with no campaign progress/relic reward noise.
- Inventory/loot changed: no new relics; rival champion relic choice remains the special source and unique rewards still do not farm infinitely.

### Verification

- Passed: TypeScript no-emit, focused save/campaign/view-model/results tests with 110 tests, focused package validation tests with 3 tests, `npm test` with 73 files / 558 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, targeted hosted campaign objective/replay proxy with 2 tests, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification with 119 checks, and `git diff --check`.
- `npm run test:e2e:release` was attempted as an extra optional local full-suite gate and hit the 30-minute command timeout before returning a summary. The required hosted release groups and visual QA above are the final release evidence.

## v0.36-v0.38 Hero Skill Tree And Relic-Build Synergy - 2026-05-28

This checkpoint adds the next small RPG foundation: Warrior / Seer / Commander skill branches, modest ability upgrades, and light equipped-relic synergy. It uses existing hero XP, existing skill points, existing abilities, and the existing one-slot relic loadout. No maps, factions, runtime art/assets, shop, crafting, giant skill tree, enemy hero skill tree, save-breaking migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V036_HERO_SKILL_TREE_FOUNDATION_SPEC.md`.
- Added `docs/V037_ABILITY_UPGRADE_FOUNDATION_SPEC.md`.
- Added `docs/V038_RELIC_BUILD_SYNERGY_SPEC.md`.
- Added `docs/V036_IMPLEMENTATION_REPORT.md`.
- Added `docs/V037_IMPLEMENTATION_REPORT.md`.
- Added `docs/V038_IMPLEMENTATION_REPORT.md`.
- Added `docs/V038_EMMANUEL_RETEST_CHECKLIST.md`.
- Reframed the visible skill tree around Warrior, Seer, and Commander branch identities.
- Kept each branch tiny at 2-3 visible nodes and hid legacy compatibility nodes from new spending.
- Added data-driven ability-upgrade metadata and effective ability derivation for casting and HUD copy.
- Added modest Cleave, learned-ability Mana/cooldown, Rally Banner, and War Cry support hooks.
- Added equipped-relic synergy for matching Emberbrand Shard, Cinder-Seer Focus, and Outpost Command Signet branch identity.
- Added build/synergy copy to Hero Progression, Hero Inventory, Equipment rows, battle HUD, ability tooltips, and Results progression reminders.
- Updated package metadata and validation to name `v0.36-v0.38 hero skill tree and relic-build synergy foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for hero skill spending, effective ability values, and equipped matching relic synergy.
- Gameplay numbers changed: narrowly, only through modest skill and synergy bonuses when the player unlocks/equips the relevant build pieces.
- Save format changed: no save-version bump; existing `allocatedSkills`, inventory, and equipment fields are used.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial remains no-save/no-reward with no skill-tree requirement.
- Inventory/loot changed: no new relics and no broad inventory flow; synergy derives from the existing three relics and one relic slot.

### Verification

- Passed: focused skill/save/ability/HUD/results/content/package tests with 109 tests, `npm test` with 73 files / 554 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, targeted hosted skill-tree/relic-synergy proxy with 2 tests, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification with 112 checks, and `git diff --check`.
- `npm run test:e2e:release` was not run for this closeout. The required hosted release groups and visual QA above are the final release evidence.

## v0.34-v0.35 Relic Reward Choice And Hero Build Identity - 2026-05-27

This checkpoint makes persistent relic rewards feel more intentional by adding a tiny inline Results choice flow and clearer Warrior/Seer/Commander build identity copy. It keeps the existing three relics and one relic slot. No maps, factions, runtime art/assets, shop, crafting, full inventory overhaul, large loot table, save-breaking migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or canvas/world force-click behavior were added.

### Included

- Added `docs/V034_RELIC_REWARD_CHOICE_SPEC.md`.
- Added `docs/V035_HERO_BUILD_IDENTITY_SPEC.md`.
- Added `docs/V034_IMPLEMENTATION_REPORT.md`.
- Added `docs/V035_IMPLEMENTATION_REPORT.md`.
- Added `docs/V035_EMMANUEL_RETEST_CHECKLIST.md`.
- Replaced eligible rival champion relic auto-grants with an inline Results relic choice.
- Kept the source champion relic first and offered one unowned alternate when available.
- Preserved one-choice confirmation when only one unowned relic remains.
- Preserved unique duplicate conversion when every relic is already owned.
- Added required relic build archetype, build summary, and choice copy metadata.
- Added Warrior/Seer/Commander build identity copy to Results, Hero Inventory, Equipment, and battle HUD summaries.
- Updated package metadata and validation to name `v0.34-v0.35 relic reward choice and hero build identity`.

### Verdict

- Runtime gameplay changed: yes, narrowly for relic reward choice timing and selected relic acquisition.
- Gameplay numbers changed: no new relic effects and no global rebalance.
- Save format changed: no save-version bump; existing inventory/equipment fields are still used.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial remains no-save/no-reward with no relic choice or grant.
- Inventory/loot changed: yes, only in the small Results choice flow over the existing three unique relics.

### Verification

- Passed: focused relic/rival/results/HUD/content/package tests with 70 tests, `npm test` with 73 files / 549 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, targeted hosted Ashen Outpost relic-choice/equip proxy, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification with 105 checks, `git diff --check`, and targeted optional full-release follow-up reruns.
- `npm run test:e2e:release` was attempted as an extra optional local full-suite gate. The first attempt exposed an existing mobile-short layout itinerary budget issue; a scoped timeout matching the other hosted layout tests was added and the exact case passed. The second attempt exposed the new relic-choice click helper treating a successful disappearing choice button as failure; that helper call was fixed and the focused hosted Ashen Outpost plus hosted deep-campaign group passed. The optional full release lane was not used as final release evidence.

## v0.32-v0.33 Persistent Relic Inventory And Hero Loadout Foundation - 2026-05-27

This checkpoint turns the v0.31 relic reward preview into a tiny persistent RPG reward loop. It uses existing hero inventory/equipment save structures and adds one equipped relic slot without creating a broad inventory system. No maps, factions, runtime art/assets, shop, crafting, broad inventory UI, reward-choice modal, save-version bump, broad AI/pathing rewrite, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world clicks were added.

### Included

- Added `docs/V032_PERSISTENT_RELIC_INVENTORY_SPEC.md`.
- Added `docs/V033_HERO_RELIC_LOADOUT_SPEC.md`.
- Added `docs/V032_IMPLEMENTATION_REPORT.md`.
- Added `docs/V033_IMPLEMENTATION_REPORT.md`.
- Added `docs/V033_EMMANUEL_RETEST_CHECKLIST.md`.
- Promoted the three v0.31 relic candidates into unique `slot: "relic"` item definitions.
- Added persistent relic reward metadata with source champion, acquisition source, effect summary, tags, rarity/tier/category, and duplicate policy.
- Added save-safe relic inventory helpers over existing `HeroSaveData.inventory` and `HeroSaveData.equipment.relic`.
- Added eligible rival champion defeat relic grants and unique duplicate conversion without repeat-farming.
- Added Results relic reward copy, inventory/duplicate status, effect/stat summaries, and an `Equip Relic` action.
- Added Hero Inventory relic equip/unequip support through the existing equipment panel.
- Added battle HUD equipped relic summary.
- Updated package metadata and validation to name `v0.32-v0.33 persistent relic inventory and hero loadout foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly for persistent rival relic rewards and equipped-only relic stat effects.
- Gameplay numbers changed: narrowly, through three modest equipped relic stat packages.
- Save format changed: no save-version bump; existing inventory/equipment fields are used.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and Tutorial remains no-save/no-reward with no relic grants or Relic Reward block.
- Inventory/loot changed: yes, only the three source relics and one relic slot.

### Verification

- Passed: focused relic/rival/save/progression/results/HUD/content tests with 107 tests, `npm test` with 73 files / 546 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls normal/extended/verify, targeted hosted Ashen Outpost relic reward/equip proxy, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, dirty pre-commit package generation, package verification with 100 checks, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, and `git diff --check`.
- `npm run test:e2e:release` was attempted as an extra local full-suite gate and reported transient local dev-server boot/layout/smoke timing failures; the exact affected file:line rerun passed with 7 tests. The required hosted release lanes above are green.

## v0.30-v0.31 Rival Champion And Relic Reward Foundation - 2026-05-27

This checkpoint adds a safe rival champion/enemy commander foundation and a tiny preview-only relic reward foundation. It uses existing assets and systems only. No maps, factions, runtime art/assets, save migration, inventory overhaul, broad AI/pathing rewrite, global rebalance, Patrol, formations, or complex loot were added.

### Included

- Added `docs/V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md`.
- Added `docs/V031_RELIC_REWARD_FOUNDATION_SPEC.md`.
- Added `docs/V030_IMPLEMENTATION_REPORT.md`.
- Added `docs/V031_IMPLEMENTATION_REPORT.md`.
- Added `docs/V031_EMMANUEL_RETEST_CHECKLIST.md`.
- Added preview-only relic reward definitions and validation.
- Added relic preview selection rules and a results-screen `Relic Reward Preview` block.
- Tightened rival champion AI so commanders defend base/sites, avoid economy raids, and join only late coordinated attacks with escorts.
- Extended results/unit/content/package and hosted Ashen Outpost coverage.
- Updated package metadata and validation to name `v0.30-v0.31 rival champion and relic reward foundation`.

### Verdict

- Runtime gameplay changed: yes, narrowly in enemy commander AI selection and victory results display.
- Gameplay numbers changed: no global rebalance; relic effects are preview-only and not applied.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, and relic previews are blocked in Tutorial/rewards-disabled runs.
- Inventory/loot changed: no persistent inventory or equipment changes.

### Verification

- Passed: focused v0.30-v0.31 unit/content/package tests with 77 tests, targeted hosted Ashen Outpost commander/relic proxy, `npm test` with 73 files / 540 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, controls normal/extended/verify, fast smoke with 8 tests, full smoke with 14 tests, hosted deep-meta with 12 tests, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, and `git diff --check`.
- `npm run test:e2e:release` was attempted and exposed one deep-meta transition-helper issue after a New Campaign click had already reached hero creation. The narrow test helper call was fixed with the existing scene-transition click option, then the targeted test and hosted deep-meta group passed.
- Remote closeout: push runs `26510324409`, `26512926475`, and `26518961193` passed Fast confidence. Manual matrix runs `26510633476` and `26513207423` isolated hosted deep-battle harness failures around minimap/canvas actionability and a stale rally-order assertion. Follow-up commit `62e35ae` passed manual release-matrix run `26519266738`, including Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`.

## v0.29.2 Hosted Deep-Battle Recovery And Release-Matrix Closeout - 2026-05-27

This checkpoint fixes the remaining hosted `deep-battle` release-matrix failure after v0.29.1 remote-CI recovery. It is a test-harness and release-closeout pass only. It does not change runtime gameplay, balance, save data, maps, factions, runtime art/assets, AI, pathing, or content.

### Included

- Added `docs/V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md`.
- Added `docs/V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md`.
- Added `docs/V0292_RELEASE_MATRIX_CLOSEOUT.md`.
- Added `docs/V0292_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `docs/V0292_LONG_SOAK_REPORT.md`.
- Updated package metadata and validation to name `v0.29.2 hosted deep-battle recovery and release-matrix closeout`.
- Added the v0.29.2 recovery docs and Emmanuel retest checklist to private playtest packages.
- Stabilized hosted `deep-battle` only in `tests/e2e/deep-flow.spec.ts`.

### Deep-Battle Failure

- Manual release-matrix run `26484817685` failed hosted `deep-battle` after checkout, build, and tests ran.
- Failing or flaky coverage involved movement summary timing, hover-stability DOM identity, behaviour gauntlet retreat/marquee timing, and Worker/resource-site deterministic setup.
- Classification: hosted Playwright actionability/input-delivery and stale assertion issues, plus unrelated enemy-site pressure in one Worker/site proxy.
- First v0.29.2 fix commit `45c7eb1` passed Fast confidence in push run `26490257582`.
- Manual release-matrix run `26490433401` on `45c7eb1` passed checkout, Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`, but hosted `deep-battle` still failed one stale duplicate movement-summary assertion.
- Follow-up fix commit `b7604e5` passed Fast confidence in push run `26493632871`.
- Manual release-matrix run `26493804376` on `b7604e5` passed Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`.
- No hero progression, ability, enemy strategy, Worker-slot, or runtime gameplay regression was found.

### Fix

- Right-click world commands now use a normal Playwright canvas-position click after the helper verifies the target is uncovered canvas; no `force` and no DOM fallback for canvas/world clicks.
- Movement command assertions now require durable scene state before any optional transient movement-summary check.
- The minimap/fog/move hosted test no longer repeats a second assertion against the short-lived movement summary after the shared helper succeeds.
- Hosted Worker/site setup parks unrelated hostile units away before testing player Worker assignment/upgrades.
- Hover-stability coverage now asserts the visible, enabled, correctly labeled button under the pointer rather than same-node identity across HUD refresh.
- Marquee cleanup uses one additional real mouse release only if the scene still reports an active drag.

### Verification

- Passed: targeted behaviour gauntlet soak with 5 repeats and no retries, targeted four-test hosted audit set with no retries, exact stale-summary follow-up test with 5 repeats and no retries, `npm test` with 72 files / 533 tests, production build with the known Vite Phaser chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, extended controls with 90 pass rows, controls verifier with 1658 checks, hosted deep-battle with 27 tests before and after the stale-summary follow-up fix, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, and `git diff --check`.
- Remote Fast confidence passed on `b7604e5`, and manual release matrix run `26493804376` passed hosted `deep-battle` plus the other enabled release groups. The clean v0.29.2 private playtest package was regenerated from a clean final closeout commit and package verification passed with 90 checks.

## v0.29.1 Hero Progression Closeout And Blocked CI Documentation - 2026-05-26

This checkpoint closes out v0.28-v0.29 by documenting the blocked GitHub Actions state, making local fallback verification/package guidance explicit, and recording the follow-up remote CI recovery state. It does not change gameplay, balance, save data, maps, factions, runtime art/assets, AI, pathing, or runtime systems. Follow-up commits include test-only hosted e2e stabilization.

### Included

- Added `docs/V0291_BLOCKED_REMOTE_CI_STATUS.md`.
- Added `docs/V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md`.
- Updated package metadata and validation to name `v0.29.1 hero progression closeout and blocked CI documentation`.
- Kept the v0.28/v0.29 hero progression specs, implementation reports, and Emmanuel retest checklist required in private playtest packages.
- Added the v0.29.1 blocked-CI and local-verification closeout docs to private playtest packages.
- Added test-only hosted deep-battle closeout stabilization in `tests/e2e/deep-flow.spec.ts`; no runtime gameplay files changed.

### Remote CI

- GitHub Actions run `26447947052` failed twice at `actions/checkout@v4`.
- The runner received GitHub HTTP 403 with `remote: Your account is suspended. Please visit https://support.github.com for more information.`
- No repo tests or package commands ran remotely.
- Treat the original run as remote CI unavailable, not a code/test failure.
- Checkout later recovered. Push run `26484639124` on `6124d71` passed Fast confidence with checkout success.
- Manual release-matrix run `26484817685` on `6124d71` passed Fast confidence, Release simulator, and hosted `deep-meta`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.
- Manual release-matrix run `26484817685` failed hosted `deep-battle` after checkout, build, and tests ran. Do not claim remote CI green yet.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Tests weakened: no.

### Verification

- Passed: `npm test` with 72 files / 533 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, extended controls with 90 pass rows, controls verifier with 1658 checks, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty playtest package generation, and dirty package verification with 85 checks.
- Follow-up local verification after `6124d71` passed `npm test`, `npm run build`, content validation, art-intake validation, fast smoke, and hosted deep-battle.
- Remote CI is recovered from the original checkout blocker, but manual release-matrix run `26484817685` remains red in hosted `deep-battle`.

## v0.28-v0.29 Hero Progression And Ability Foundation - 2026-05-26

This checkpoint adds the first safe RPG progression layer for the player hero. The hero can gain live battle XP, level during battle, receive modest stat gains, use readable ability cooldown states, and carry battle XP into the existing victory results flow without adding new content rosters, inventory complexity, enemy hero systems, save migration, or runtime art.

### Included

- Added `docs/V028_HERO_PROGRESSION_SPEC.md`.
- Added `docs/V029_HERO_ABILITIES_AND_REWARDS_SPEC.md`.
- Added `docs/V028_IMPLEMENTATION_REPORT.md`.
- Added `docs/V029_IMPLEMENTATION_REPORT.md`.
- Added `docs/V029_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and package validation to name `v0.28-v0.29 hero progression and ability foundation`.
- Added shared hero level stat-gain helpers and applied live battle damage/armor growth on level-up.
- Added one-time player resource-site capture XP while preserving existing kill XP, level curve, reward XP, and victory persistence.
- Updated the hero HUD with XP, skill points, damage, armor, and ability unlock count.
- Added tested ability button states for ready, cooldown, and insufficient mana.
- Preserved Rally Banner and Cleave as the safe active ability examples and prevented cooldown spam from spending extra mana.
- Added victory results coverage for battle XP, level-ups, and reward XP.
- Updated Tutorial hint copy while preserving no-reward training and the existing tutorial route.
- Expanded unit, UI, runtime, package, and hosted coverage for hero XP, level-up, ability cooldowns, targeting, HUD state, and rewards.

### Verdict

- Runtime gameplay changed: yes, the player hero now has live battle XP, live level-up stat gains, clearer ability states, and battle XP on victory results.
- Gameplay numbers changed: narrowly, site capture awards 10 hero XP and live level-ups now apply existing conservative level stat gains during battle.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no, only hint copy changed.
- Inventory/loot changed: no.
- Enemy hero system added: no.

### Verification

- Passed: GitHub Actions v0.26-v0.27 push run `26431511137` Fast confidence, focused hero progression/ability/HUD tests with 6 files / 10 tests, focused BattleRuntime victory XP test with 12 tests, package validation unit tests with 3 tests, `npm test` with 72 files / 533 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, extended controls with 90 pass rows, controls verifier with 1658 checks, focused hosted hero progression/ability/reward proxy with 3 tests, hosted deep-battle with 27 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, 3-way release shards with 44/34/14 tests, visual QA with 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty playtest package generation, dirty package verification with 83 checks, and production preview smoke with 0 browser console errors.
- The unsharded `npm run test:e2e:release` command was attempted but exceeded a 30-minute tool window before producing usable output; the three release shards passed afterward and preserve the full release suite coverage.
- Browser plugin note: tool discovery in the compacted closeout turn did not expose an in-app Browser page-control tool, so `npm run smoke:preview` plus visual QA are the local browser sanity fallback.

### Next

- Commit the checkpoint, regenerate/verify the clean v0.28-v0.29 package from the final commit, push, and use that package for Emmanuel's hero progression/ability/reward retest.

## v0.26-v0.27 Enemy Base Development And Tech Escalation AI - 2026-05-26

This checkpoint turns the enemy's v0.24-v0.25 site pressure into staged base development and tech escalation. Enemy AI can use site control and economy health to fortify, research existing upgrades, defend important positions, and escalate pressure without adding harvesting, visible enemy Workers, new content, or global army buffs.

### Included

- Added `docs/V026_ENEMY_BASE_DEVELOPMENT_SPEC.md`.
- Added `docs/V027_ENEMY_TECH_ESCALATION_SPEC.md`.
- Added `docs/V026_IMPLEMENTATION_REPORT.md`.
- Added `docs/V027_IMPLEMENTATION_REPORT.md`.
- Added `docs/V027_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and package validation to name `v0.26-v0.27 enemy base development and tech escalation AI`.
- Added a pure enemy base-development planner that chooses early, mid, and late stages from time, site control, improved sites, stockpile health, researched tech, and player threat.
- Added enemy tech planning through existing `UpgradeSystem` rules with delay, cooldown, affordability, prerequisite, researched-state, active-queue, and building-support gates.
- Mapped existing enemy structures into abstract roles: Enemy Stronghold as base hub, Enemy Barracks as military/hexfire tech role, and existing enemy Watchtowers as defense roles.
- Extended existing shared upgrades to relevant Ashen units/buildings only when enemy research completes.
- Added staged escalation: early neutral-site capture/light raids, mid site upgrades/defense/tech, and late stronger coordinated pressure when economy and site control are healthy.
- Added defensive reserve logic so base/site defense can interrupt raids and late attacks.
- Added short battle status copy for fortifying, tech, raid forming, escalation, base defense, and site defense.
- Expanded unit and hosted coverage for tech selection, prerequisites, impossible upgrade rejection, stage shifts, base/site defense, raid spam prevention, and economy-backed escalation.
- Narrowly hardened an existing smoke scene-transition click path exposed by the full release lane; follow-up BattleScene assertions remain intact.

### Verdict

- Runtime gameplay changed: yes, enemy AI now develops abstract base stages, researches existing tech, and escalates pressure from economy/site control.
- Gameplay numbers changed: narrowly, through research-gated Ashen eligibility for existing upgrades and local AI thresholds/cooldowns; no global army rebalance.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.
- Harvesting added: no classic carry/drop-off harvesting, visible enemy Workers, cargo, drop-off loop, or full enemy Worker economy.

### Verification

- Passed: GitHub Actions v0.24-v0.25 push run `26426765221` Fast confidence, focused AI/system tests with 40 tests, `npm test` with 66 files / 522 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, extended controls with 90 pass rows, controls verifier with 1658 checks, focused hosted enemy base tech proxy, hosted deep-battle with 24 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, focused Border Village smoke repro, full release e2e with 89 tests, visual QA with 5 tests / 18 screenshots / 0 console errors, dirty playtest package generation, dirty package verification with 78 checks, and production preview smoke with 0 browser console errors.
- Browser plugin note: in-app Browser was attempted but its runtime failed before page control with a kernel asset path error, so `npm run smoke:preview` is the local browser sanity fallback.

### Next

- Commit the checkpoint, regenerate/verify the clean v0.26-v0.27 package from the final commit, push, and use that package for Emmanuel's enemy base-development/tech-escalation retest.

## v0.24-v0.25 Enemy Resource-Site Strategy And Economy Pressure AI - 2026-05-25

This checkpoint makes enemy AI interact strategically with the v0.22/v0.23 resource-site economy. Enemies can capture, retake, defend, upgrade, and raid around sites without adding classic carry/drop-off harvesting or globally overbuffing army pressure.

### Included

- Added `docs/V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md`.
- Added `docs/V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md`.
- Added `docs/V024_IMPLEMENTATION_REPORT.md`.
- Added `docs/V025_IMPLEMENTATION_REPORT.md`.
- Added `docs/V025_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and package validation to name `v0.24-v0.25 enemy resource-site strategy and economy pressure AI`.
- Added a pure enemy resource-site strategy/scoring helper that values site type, level, distance, local threat/support, owner, player Worker/boost value, and known lost enemy sites.
- Added controlled enemy neutral-site capture, lost-site retake, valuable-site defense, conservative Level 2 site upgrades, and periodic economy-pressure raids.
- Added abstract enemy logistics slots on enemy-owned Level 2 sites without simulating visible enemy Workers, harvesting, cargo, or drop-off loops.
- Added UI/status copy for site contesting, enemy improved sites, and abstract enemy logistics.
- Expanded unit/system/hosted coverage for scoring, capture, retake, defense, upgrades, invalid upgrade rejection, raids, raid cooldowns, weak-raid regrouping, abstract logistics, and existing Worker slot/site-loss behavior.
- Narrowly hardened existing e2e harness paths for full-release confidence: serial training queue completion, completed-Barracks layout setup, Continue Campaign success recognition, and first deep-meta menu actionability.

### Verdict

- Runtime gameplay changed: yes, enemy AI now uses and pressures resource sites.
- Gameplay numbers changed: narrowly, through local AI cooldowns/budgets/scoring and enemy-owned site income; no global army rebalance.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.
- Harvesting added: no classic carry/drop-off harvesting, cargo, drop-off loop, or full enemy Worker economy.

### Verification

- Passed: GitHub Actions v0.23 push run `26385642398` Fast confidence, `npm test` with 66 files / 516 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, extended controls with 90 pass rows, controls verifier with 1658 checks, focused hosted enemy resource-site AI proxy, focused hosted v0.23 Worker/site upgrade regression, hosted deep-battle with 23 tests, hosted smoke with 14 tests, hosted deep-campaign-pressure with 7 tests, visual QA with 5 tests / 18 screenshots / 0 console errors, full release e2e with 88 tests, dirty playtest package generation, dirty package verification with 73 checks, and production preview smoke with 0 browser console errors.
- Browser plugin note: in-app Browser was attempted but its runtime failed before page control with a kernel asset path error, so `npm run smoke:preview` is the local browser sanity fallback.

### Next

- Commit the checkpoint, regenerate/verify the clean v0.24-v0.25 package from the final commit, push, and use that package for Emmanuel's enemy resource-site strategy/economy-pressure retest.

## v0.23 Resource Site Upgrades And Worker Slots - 2026-05-25

This checkpoint expands the v0.22 resource-site Worker assignment foundation with a small upgrade and slot-depth layer. Ascendant Realms still uses capturable site-control income; it does not add classic carry/drop-off harvesting.

### Included

- Added `docs/V023_RESOURCE_SITE_UPGRADES_SPEC.md`.
- Added `docs/V023_IMPLEMENTATION_REPORT.md`.
- Added `docs/V023_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and package validation to name `v0.23 resource site upgrades and worker slots`.
- Added resource-site levels: Level 1 captured sites keep base passive income and one Worker slot; Level 2 improved sites add a 15% rounded upgrade bonus and a second Worker slot.
- Added a selected-site Upgrade command for friendly captured sites with a 120 Crowns / 80 Stone cost.
- Preserved each site's existing resource identity and baseline income.
- Expanded Worker assignment to explicit slot state, prevented duplicate Worker fills, rejected overfilled sites, and cleared slots on move/attack/build/repair/reassignment/death/site loss.
- Reset site upgrades and slots when site control is lost.
- Updated selected-site and Worker command UI to show level, base income, upgrade bonus, Worker slots, assigned Workers, Worker bonus, total income, and invalid reasons.
- Expanded unit/UI/package coverage and hosted deep-battle coverage for site upgrade, second Worker slot, income calculation, overfill rejection, site loss clearing, and existing Worker assignment behavior.
- Narrowly hardened two existing hosted/browser tests without changing assertions: Border Village extended smoke now has a 60s budget, and first-campaign build placement retries the real world-click up to 5 times.

### Verdict

- Runtime gameplay changed: yes, captured friendly resource sites can now be upgraded and upgraded sites support a second assigned Worker.
- Gameplay numbers changed: narrowly, Level 2 sites add a modest site-local upgrade bonus; baseline site income and Worker bonus formula remain conservative.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.
- Harvesting added: no classic carry/drop-off harvesting, cargo, or drop-off loop.

### Verification

- Passed: in-app Browser preview at `http://127.0.0.1:4179/`, focused ResourceSystem/UI/package tests, focused hosted v0.23 regression, `npm test` with 66 files / 506 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, controls verifier with 1658 checks, hosted deep-battle with 22 tests, hosted smoke with 14 tests, dirty playtest package generation, and dirty package verification with 68 checks.

### Next

- Commit the checkpoint, regenerate/verify the clean v0.23 package from the final commit, push, and use that package for Emmanuel's resource-site upgrade/slot retest.

## v0.22 Resource Site Worker Assignment Foundation - 2026-05-24

This checkpoint adds the first resource-economy expansion after the v0.21.x Worker intent work. Ascendant Realms keeps its capturable resource-site economy; Workers now explicitly support friendly captured sites for bonus income instead of doing classic carry/drop-off harvesting.

### Included

- Added `docs/V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md`.
- Added `docs/V022_IMPLEMENTATION_REPORT.md`.
- Added `docs/V022_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and package validation to name `v0.22 resource site worker assignment foundation`.
- Added one Worker assignment slot to each resource site.
- Added explicit Worker assignment via Worker command buttons and selected-Worker right-click on friendly captured sites.
- Kept proximity alone from assigning Workers or starting bonus income.
- Preserved baseline passive site income and added a small 20% rounded Worker bonus, minimum +1, to the site's existing resource tick while the assigned Worker is alive and in range.
- Cleared assignment on move, attack, build, repair, reassignment, Worker death, and lost/invalid site control.
- Added Worker order text for `Returning to Site` and `Working Site`.
- Added selected-site UI for control, resource type, base income, Worker slot, Worker bonus, boosted income, and invalid assignment reasons.
- Added focused unit/UI/package and hosted deep-battle coverage for assignment, invalid targets, no proximity assignment, boost income, recall/reassign/death/site-loss clearing, and command override behavior.

### Verdict

- Runtime gameplay changed: yes, Workers can now explicitly boost friendly captured resource sites.
- Gameplay numbers changed: narrowly, assigned Workers add a conservative site-local income bonus; baseline site income remains unchanged.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.
- Harvesting added: no classic carry/drop-off harvesting, cargo, or drop-off loop.

### Verification

- Passed: TypeScript no-emit, focused Worker assignment/unit/UI/package tests, focused hosted Worker assignment regression, `npm test` with 66 files / 500 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, controls playtest with 18 scenarios / 18 pass rows, controls verifier with 1658 checks, hosted deep-battle with 22 tests, and hosted smoke with 14 tests.

### Next

- Generate and verify the final clean v0.22 package after the checkpoint commit, then use it for Emmanuel's Worker assignment retest before starting broader economy work.

## v0.21.3 Worker Explicit Attack Damage And Status Clarity - 2026-05-24

This checkpoint follows Emmanuel's FAIL / MIXED retest of the latest v0.21.x Worker package. It fixes Worker explicit attack damage visibility/proof and clarifies Burn/status marker readability without starting harvesting or v0.22.

### Included

- Updated `docs/V0213_WORKER_INTENT_CLOSEOUT.md`.
- Added `docs/V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md`.
- Added `docs/V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md`.
- Updated package metadata and package validation to name `v0.21.3 worker explicit attack damage and status clarity`.
- Added the v0.21.3 closeout, attack retest intake, and cursor note docs to private playtest packages.
- Added a narrow explicit Worker building-attack damage floor only when a Worker has an explicit building attack target.
- Let explicit Worker building hits show floating damage by carrying the damage source through combat callbacks.
- Kept idle Workers from auto-attacking enemy buildings by default.
- Changed Burn/status markers into a labeled `BURN` chip above the health bar so Burn reads as status feedback rather than a broken health-fill dot.

### Verdict

- Runtime gameplay changed: yes, explicit Worker building attacks now visibly/measurably damage valid enemy buildings.
- Gameplay numbers changed: narrowly, Worker building damage has a small explicit-order-only floor; there is no global combat rebalance.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.
- Harvesting added: no.

### Verification

- Passed: `npm test` with 65 files / 487 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, focused Worker attack browser regression, controls playtest with 18 scenarios / 18 pass rows, controls verifier with 1658 checks, dirty playtest package generation, dirty package verification with 62 checks, and `git diff --check`.
- Skipped remotely by push workflow rules: Optional visual QA, Release simulator, hosted release groups, and Full release e2e.
- Manual release-matrix note: exact final v0.21.3 workflow_dispatch release matrix should be run after push if exact remote hosted/simulator evidence is needed.

### Next

- Commit the runtime/docs/package metadata, regenerate/verify a clean v0.21.3 package from the final commit, and use it for Emmanuel's Worker explicit attack/status marker retest before v0.22.

## v0.21.2 Worker Intent Clarity And Healthbar Polish - 2026-05-24

This checkpoint follows Emmanuel's `ascendant-realms-private-playtest-f6a121b` Worker repair retest. Worker repair mostly passed; v0.21.2 fixes explicit Worker intent rules, Worker attack clarity, and healthbar marker feedback without starting harvesting or v0.22.

### Included

- Added `docs/V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md`.
- Added `docs/V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md`.
- Updated package metadata and package validation to name `v0.21.2 worker intent clarity and healthbar polish`.
- Required explicit Worker construction intent before incomplete friendly buildings progress; proximity alone no longer starts or resumes construction.
- Required explicit Worker Repair intent before damaged friendly completed buildings repair; proximity alone no longer starts or resumes repair.
- Added selected-Worker right-click resume construction for incomplete friendly sites.
- Made explicit Worker attack orders work against valid enemy buildings through the existing weak Worker combat capability.
- Kept idle Workers from auto-attacking nearby enemy buildings by default.
- Made building target detection use visible rectangular footprints so visible enemy-building corners do not fall through to terrain orders.
- Moved status/burn badges beside the healthbar to remove the red-dot artifact at the start of a damaged Worker's healthbar.
- Kept future crossed-swords attack and hammer repair/build cursor work as docs-only; no runtime cursor art/assets were added.
- Added targeted construction, repair, combat, collision, healthbar, package-validation, UI, and smoke harness coverage.

### Verdict

- Runtime gameplay changed: yes, Worker construction/repair now require explicit active Worker commands, and explicit Worker attack against valid enemy buildings now resolves through existing combat.
- Gameplay numbers changed: no global balance change; existing weak Worker combat stats are reused.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.
- Harvesting added: no.

### Verification

- Passed: focused Worker construction/repair/attack/collision/healthbar/package/UI tests, Browser local smoke, isolated main-menu smoke repro, `npm test` with 65 files / 485 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke, full smoke, control lab normal plus 1658-check verifier, dirty playtest package generation, dirty package verification with 59 checks, and `git diff --check`.

### Next

- Commit the checkpoint, regenerate/verify a clean v0.21.2 package from the final commit, and use it for Emmanuel's Worker intent clarity and healthbar polish retest.

## v0.21.1 Worker Repair Closeout And CI Verification - 2026-05-24

This checkpoint closes out v0.21 by pushing the Worker repair foundation, recording remote CI status, and refreshing package metadata. It does not start v0.22 and does not add new gameplay.

### Included

- Pushed `79d038b`, `Checkpoint v0.21 worker repair foundation`, to `origin/main`.
- Added `docs/V0211_WORKER_REPAIR_CLOSEOUT.md`.
- Updated package metadata and package validation to name `v0.21.1 worker repair closeout and CI verification`.
- Added the v0.21.1 closeout doc to private playtest packages.
- Recorded that push workflow rules skip the release matrix/simulator unless CI Release Matrix Dry Run is manually dispatched with `run_release_matrix=true`.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed: GitHub Actions push Fast confidence for `79d038b`, focused package-validation test, `npm test` with 64 files / 478 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke, dirty playtest package generation, and dirty package verification with 57 checks.
- Remote release-matrix note: push workflow rules skipped simulator, hosted release groups, optional visual QA, and full release. Manual workflow_dispatch with `run_release_matrix=true` remains the exact remote hosted/simulator follow-up if needed.

### Next

- Commit the closeout metadata, regenerate/verify a clean v0.21.1 package from the final commit, and use it for Emmanuel's Worker repair retest.

## v0.21 Worker Repair Foundation - 2026-05-24

This checkpoint adds the first narrow Worker repair foundation without opening harvesting, resource-dropoff economy, enemy repair AI, or a broader Worker system.

### Included

- Added `docs/V021_WORKER_REPAIR_FOUNDATION_SPEC.md` and `docs/V021_IMPLEMENTATION_REPORT.md`.
- Added Worker repair intent state separate from construction, move, and attack orders.
- Added `RepairSystem` for repair validation, approach movement, pause/resume, and slow HP restoration.
- Worker can repair damaged friendly completed Command Hall, Barracks, Mystic Lodge, and Watchtower buildings.
- Repair is blocked for enemy buildings, incomplete buildings, and full-health buildings.
- Explicit move and attack orders pause repair intent and do not magnet the Worker back.
- Worker command UI now shows repair targets, HP, no-cost status, and full-health disabled state.
- Selected Worker/building UI now reports active repair, paused repair, damaged repair status, and full-health status.
- Added unit/UI/package tests and a hosted deep-battle repair proxy.

### Verdict

- Runtime gameplay changed: yes, Worker repair was added.
- Gameplay numbers changed: yes, a small no-cost Worker repair rate was added; combat, production, construction, tech, maps, waves, and global balance are otherwise unchanged.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed: TypeScript no-emit, focused repair/construction/UI/package tests, production build with the known Vite chunk-size warning, hosted repair proxy, `npm test` with 64 files / 478 tests, content validation, art-intake validation, fast smoke, full smoke, control lab normal plus 1658-check verifier, hosted deep-battle with 20 tests, hosted smoke with 14 tests, dirty playtest package generation, dirty package verification with 56 checks, and `git diff --check`.

### Next

- Commit the checkpoint, generate a clean final package from the final commit, and use it for Emmanuel's Worker repair retest.

## v0.20.1 Tech Tree Closeout And Polish - 2026-05-24

This checkpoint closes out v0.20 by pushing the foundation commit, verifying Fast confidence, refreshing package metadata, and recording a small tech-tree audit. It does not start v0.21.

### Included

- Pushed `ae3d80d`, `Checkpoint v0.20 upgrade and tech tree foundation`, to `origin/main`.
- Added `docs/V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md`.
- Updated package metadata and package validation to name `v0.20.1 tech tree closeout and polish`.
- Added the v0.20.1 closeout doc to private playtest packages.
- Audited Command Hall, Barracks, Mystic Lodge, Watchtower, upgrade ownership, prerequisites, and effect summaries.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed: GitHub Actions push Fast confidence for `ae3d80d`, `npm test` with 63 files / 465 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke, full smoke, control lab normal plus 1658-check verifier.
- Remote release-matrix note: push workflow rules skipped simulator, hosted release groups, optional visual QA, and full release. Manual workflow_dispatch with `run_release_matrix=true` remains the exact remote hosted/simulator follow-up if needed.

### Next

- Send the clean v0.20.1 package for Emmanuel's tech-tree role retest after the final closeout commit/package verification.

## v0.20 Upgrade And Tech Tree Foundation - 2026-05-24

This checkpoint adds the first small, building-owned upgrade/tech-tree foundation without opening a large content or economy pass.

### Included

- Added `docs/V020_TECH_TREE_FOUNDATION_SPEC.md` and `docs/V020_IMPLEMENTATION_REPORT.md`.
- Added upgrade owner building, category, tier, and effect-summary metadata.
- Added Command Hall core upgrade `Camp Foundations I`; Command Hall still trains Workers only.
- Kept Barracks on Militia/Ranger production and clarified ownership for Infantry Weapons I, Reinforced Armor I, and Ranger Training I.
- Kept Mystic Lodge on Acolyte and Aether Study I.
- Added Watchtower defensive upgrade `Sentry Bracing I`, locked behind completed Watchtower plus `Camp Foundations I`.
- Added building armor upgrade application and validation.
- Updated upgrade buttons to show owner, requirements, category, effect, cost, researching, and researched state.
- Added focused unit/system/UI/package tests and a hosted Tutorial proxy for Barracks upgrade research.

### Verdict

- Runtime gameplay changed: yes, two small upgrades and building armor upgrade application were added.
- Gameplay numbers changed: only the new Command Hall and Watchtower armor upgrades; existing unit upgrades, production costs, waves, maps, and global balance are unchanged.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: copy only; no new steps or rewards.
- Economy/production architecture rewritten: no; this is a small tech-tree foundation over the v0.19 roles.

### Verification

- Passed: focused tech-tree/unit coverage, `npm test` with 63 files / 465 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, hosted Tutorial proxy, fast smoke, full smoke, control lab normal plus 1658-check verifier, hosted deep-battle with 19 tests, hosted smoke with 14 tests, dirty playtest package generation, and dirty package verification with 53 checks.

### Next

- Package and verify the final v0.20 build for Emmanuel's upgrade/role retest.

## v0.19.1 Production Role Verification And Polish - 2026-05-24

This checkpoint verifies and lightly polishes the v0.19 production architecture before v0.20. It does not add new production systems or content.

### Included

- Added `docs/V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md`, `docs/V0191_REMOTE_CI_STATUS.md`, and `docs/V0191_PRODUCTION_ROLE_POLISH_REPORT.md`.
- Added production-role data coverage for Command Hall, Worker build ownership, Barracks, Mystic Lodge, Watchtower, and upgrade prerequisites.
- Expanded command-panel coverage for Command Hall Worker-only UI, inactive incomplete buildings, completed Barracks research ownership, and completed Mystic Lodge actions.
- Added a focused hosted Tutorial proxy for Command Hall -> Worker -> Barracks -> army plus Watchtower role readability.
- Updated hosted layout expectations so Command Hall reachability checks expect Train Worker instead of removed build/upgrade buttons.
- Polished existing copy for Command Hall Worker-only role, incomplete-building action locks, Mystic Lodge Aether Study I ownership, Watchtower defensive status, and the defeat-tip production route.

### Verdict

- Runtime gameplay changed: no new systems; only role/readability copy changed.
- Gameplay numbers changed: no unit stats, costs, build times, waves, resources, or global balance values changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no new steps or rewards; the hosted proxy verifies the existing route.
- Economy/production architecture rewritten: no, this is a verification and polish pass over v0.19.

### Verification

- Passed: focused production-role/unit coverage, production build with the known Vite chunk-size warning, content validation, art-intake validation, hosted Tutorial proxy, hosted behaviour gauntlet plus Tutorial proxy, hosted layout-core, hosted layout-cinderfen, `npm test` with 62 files / 458 tests, fast smoke, full smoke, control lab normal plus 1658-check verifier, hosted deep-battle with 19 tests, hosted smoke with 14 tests, dirty playtest package generation, dirty package verification with 51 checks, and `git diff --check`.
- Remote CI note: v0.19 workflow-dispatch run #113 passed Fast confidence, Release simulator, hosted deep-meta, hosted deep-battle, hosted deep-campaign-pressure, and hosted smoke. It failed only hosted layout-core/layout-cinderfen because those tests still expected removed Command Hall build/upgrade actions; v0.19.1 fixes that stale expectation and both local hosted layout lanes pass.

### Next

- Generate and verify the clean v0.19.1 package from the final commit for Emmanuel's focused production-role retest.

## v0.19 Production Architecture And Building Roles - 2026-05-24

This checkpoint starts v0.19 as a narrow production role/readability migration on top of the accepted v0.18.3 Worker construction baseline.

### Included

- Added `docs/V019_PRODUCTION_ARCHITECTURE_SPEC.md` and `docs/V019_IMPLEMENTATION_REPORT.md`.
- Command Hall now exposes Worker training only in normal player-facing UI.
- Existing basic troop research moved from Command Hall to Barracks.
- Barracks now owns Militia/Ranger training plus Infantry Weapons I, Reinforced Armor I, and Ranger Training I.
- Mystic Lodge remains the existing Acolyte and Aether Study I building.
- Watchtower remains a completed-only defensive building.
- Incomplete buildings show role/unlock/status copy and expose no completed train/research/attack behavior.
- Selected-building and command-button copy now clarify building roles, costs, lock status, and completion unlocks using existing HUD surfaces.
- Tutorial / Proving Grounds keeps 12 steps while explaining Command Hall -> Worker, Worker -> building, Barracks -> army, and Watchtower -> defense.
- Hosted browser coverage was extended for Command Hall Worker-only UI, incomplete-building role/status copy, Worker construction pause/pathing retention, and Barracks-owned research.

### Verdict

- Runtime gameplay changed: yes, existing basic troop research ownership moved from Command Hall to Barracks, and building role/status UI changed.
- Gameplay numbers changed: no unit stats, costs, build times, waves, resources, or global balance values changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: copy only; no new Tutorial objectives or rewards.
- Economy/production architecture rewritten: no broad rewrite; this is a role/readability migration over existing content.

### Verification

- Passed: focused TypeScript/unit checks, `npm test` with 61 files / 454 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke, full smoke after exact rerun, control lab normal plus 1658-check verifier, hosted deep-battle with 18 tests, extra hosted deep-campaign-pressure with 7 tests, hosted smoke with 14 tests, dirty playtest package generation, and dirty package verification with 48 checks.
- Browser smoke note: first `npm run test:e2e:smoke` attempt hit the known cold dev-server main-menu boot timeout on test 1 while the remaining 13 tests passed; exact rerun passed all 14 tests.
- Hosted deep-battle note: two full-lane attempts exposed an intermittent single-click miss in the existing behaviour-mode gauntlet after the Worker/building-role tests had passed. The fix keeps the same assertion and uses the existing real-canvas world-click retry helper, with no force click and no DOM fallback for canvas/world clicks.

### Next

- Commit the checkpoint, generate a clean package from the final commit, and use it for Emmanuel's v0.19 role retest.

## v0.18.3 Worker Assignment And Construction Pathing Fix - 2026-05-24

This checkpoint fixes Emmanuel's mixed retest of `ascendant-realms-private-playtest-039fe64`. It is a narrow construction/pathing bugfix pass, not a worker-economy expansion.

### Included

- Added `docs/V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md` and `docs/V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md`.
- Worker construction intent is now separate from ordinary player move/attack commands.
- Explicit player move and attack orders pause the current construction assignment instead of being overwritten by construction auto-return.
- Construction progress now requires the assigned Worker to be alive and within valid work range.
- Moving the Worker back into range resumes construction.
- Construction-site status uses existing UI copy: `Building` and `Paused - Worker away`.
- Pathing around Command Hall, Barracks, Mystic Lodge, Watchtower, and blocked terrain uses a finer grid plus exact blocker checks so open edge points do not behave like invisible rocks.
- Hosted deep-battle coverage now includes Worker move-away pause/resume and compact base-cluster attack movement.

### Verdict

- Runtime gameplay changed: yes, Worker construction assignment/pause behavior and path routing around blockers changed.
- Gameplay numbers changed: no costs, stats, build times, waves, resources, or global balance values changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no new objectives or content.
- Economy/production architecture rewritten: no, bugfix only.

### Verification

- Passed: TypeScript no-emit, focused construction/movement/pathing/combat tests, `npm test` with 61 files / 450 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, control lab normal plus 1658-check verifier, hosted deep-battle with 18 tests, and hosted smoke with 14 tests.
- Browser smoke note: `npm run test:e2e:smoke:fast` and `npm run test:e2e:smoke` both passed after exact rerun/prewarm. The initial failures were cold Vite dev-server app-boot timeouts before Phaser reached the main menu, not assertion failures in the v0.18.3 behavior.
- Dirty package generated and verified: `artifacts/playtest/ascendant-realms-private-playtest-039fe64-dirty`, 46 checks.
- `git diff --check` passed.
- Clean package generated and verified: `artifacts/playtest/ascendant-realms-private-playtest-ce43d0e`, 46 checks.
- GitHub Actions CI Release Matrix Dry Run #26365296115 passed on `main` / `ce43d0e`: Fast confidence, Release simulator, and all six hosted release-matrix groups succeeded. Optional visual QA and Full release e2e were skipped by input.

### Next

- Treat `ce43d0e` / `ascendant-realms-private-playtest-ce43d0e` as the v0.18.3 baseline. Worker construction foundation is stable enough for the next phase.

## v0.18.2 Worker Construction Expansion - 2026-05-23

This checkpoint expands the v0.18 Worker construction foundation to the existing player building set only. It remains a bounded construction pass, not a worker economy rewrite.

### Included

- Added `docs/V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md` and `docs/V0182_IMPLEMENTATION_REPORT.md`.
- Worker selection can now build Barracks, Mystic Lodge, and Watchtower.
- Command Hall remains Worker-training only and still exposes no direct building placement commands.
- Existing costs, construction times, footprints, art conventions, and completed building behaviors are preserved.
- Incomplete Watchtower behavior is covered so it cannot fire before construction completes.
- Selected construction-site UI now says `Assigned Worker` instead of duplicating `Worker Worker`.
- Package metadata and validation now include the v0.18.2 retest docs.

### Verdict

- Runtime gameplay changed: yes, Worker build options now cover existing player buildings.
- Gameplay numbers changed: no existing cost, stat, wave, resource, or build-time values changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Tutorial requirement changed: no new objectives; Tutorial still uses the Worker Barracks route.
- Economy/production architecture rewritten: no, Worker construction expansion only.

### Verification

- Passed: TypeScript no-emit, focused Worker/package/UI/runtime tests, production build with the known Vite chunk-size warning, targeted hosted Worker regressions, `npm test` with 61 files / 442 tests, content validation, art-intake validation, simulator with 255 runs, control lab normal/extended plus 1658-check verifier, fast smoke, full smoke, all six hosted release-matrix groups, local full release with 82 tests, and production-preview smoke with 0 browser console errors.
- Completed after commit: clean package `ascendant-realms-private-playtest-a20da05` verified with 44 checks, package server boot sanity passed at `http://127.0.0.1:4174/`, and GitHub Actions push run #107 passed Fast confidence. Release matrix, simulator, optional visual QA, and full release e2e jobs were skipped on push by workflow rules; release-matrix evidence is the local production-preview matrix above.

### Next

- Send the clean package for focused retesting of Worker-built Barracks, Mystic Lodge, and Watchtower.

## v0.18 Worker Construction Foundation - 2026-05-23

This checkpoint implements the first safe Worker construction vertical slice after the clean v0.17.5 baseline. It keeps the scope narrow: one Worker, one Worker-built military building, no harvesting, no repair loop, no enemy construction AI, no save migration, no art replacement, and no broad Tutorial rewrite.

### Included

- Added `docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md` and `docs/V018_IMPLEMENTATION_REPORT.md`.
- Added a Free Marches Worker unit using existing asset conventions only.
- Command Hall can train Workers.
- Removed player-facing Command Hall building placement commands; Barracks construction now starts from Worker selection.
- Worker selection can build Barracks.
- Worker-built Barracks begins as an incomplete construction site with assigned Worker id/name, status, and progress.
- Assigned construction progresses only while the Worker is alive and near the building footprint.
- Incomplete buildings remain blockers but do not expose train or upgrade commands.
- Selected-building UI now shows construction lock copy, status, progress, and assigned Worker.
- Package metadata and validation now require the v0.18 docs.
- Added focused unit/UI/package tests and hosted deep-battle coverage for Command Hall Worker training, Worker-only construction commands, Worker -> Barracks -> completed production unlock, and Tutorial Worker construction smoke coverage.
- Stabilized the existing hosted behaviour-mode gauntlet click helper after hosted evidence showed a timing race unrelated to Worker construction.

### Verdict

- Runtime gameplay changed: yes, Worker training and Worker-assigned Barracks construction.
- Gameplay numbers changed: yes, one new Worker unit and Command Hall Worker training; no broad army, wave, resource, or global balance rewrite.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: no runtime combat-control behavior changed.
- Tutorial requirement changed: yes, the existing Barracks objective now routes through Worker training and Worker placement without adding new steps.
- Economy/production architecture rewritten: no, foundation slice only.

### Verification

- Passed: TypeScript no-emit, focused package/Worker/UI tests, targeted hosted Worker regression, `npm test` with 61 files / 440 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, control lab normal, control-lab verification with 1658 checks, targeted hosted behaviour-mode gauntlet rerun, hosted deep-battle with 16 tests, hosted smoke with 14 tests, local full release with 81 tests in 40.8m, dirty package verification with 42 checks, and packaged local-server browser boot sanity.
- Pending after commit: clean package verification and GitHub Actions release matrix rerun after push.

### Next

- Finish the closeout gates and package v0.18 for Emmanuel to retest the Worker path specifically: select Command Hall, train Worker, confirm Command Hall has no Barracks/Mystic Lodge/Watchtower build buttons, select Worker, build Barracks, confirm incomplete Barracks cannot train, wait for completion, then train army units from the completed Barracks.

## v0.17.5 Ranger Near-Base Invisible Blocker Fix - 2026-05-23

This checkpoint follows Emmanuel's mixed retest of `ascendant-realms-private-playtest-7baa99a`. v0.17.4 made trained Rangers no longer hard-stuck after production, but several ranged units could still feel blocked by invisible geometry near the Tutorial Barracks / Command Hall cluster until redirected.

### Included

- Added `docs/V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md` with Emmanuel's 7baa99a Tutorial feedback.
- Kept static building cells for route search, but made exact world-point walkability use the padded building rectangle so visible open ground beside a building is no longer treated as fully blocked just because its coarse cell center is blocked.
- Allowed exact walkable goals inside coarse static-blocked cells to be used as path endpoints.
- Anchored path smoothing from the requested start point instead of the start cell center.
- Added PathfindingGrid, MovementSystem, and trained-Ranger cluster regressions for visible open near-base points around the Command Hall / Barracks cluster.
- Updated private playtest package metadata and validation to include the v0.17.5 intake doc.

### Verdict

- Runtime gameplay changed: yes, static building point-walkability and exact path endpoints near coarse building cells.
- Gameplay numbers changed: no unit/building/resource/wave/pacing/balance values changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: no.
- Worker construction implemented: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed: TypeScript no-emit, focused PathfindingGrid/MovementSystem/TrainingSystem/package tests, targeted Tutorial Ranger production browser regression, `npm test` with 60 files / 433 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, in-app browser Tutorial HUD boot check, user manual retest that the Ranger near-base issue seems solved, dirty-tree package generation, dirty-tree package verification with 40 checks, and `git diff --check`.

### Next

- Commit/push if `git diff --check` remains green, regenerate a clean private package from the final commit, and have Emmanuel retest several Rangers around the Tutorial Barracks / Command Hall cluster with repeated move orders near the base.

## v0.17.4 Trained Ranger Spawn And Movement Recovery - 2026-05-23

This checkpoint follows Emmanuel's mixed retest of `ascendant-realms-private-playtest-532007d`. It keeps the v0.17 line narrow: preserve the passed cost display, side-panel Hide/Show, neutral-contact, and enemy-base text fixes while addressing newly produced Rangers that could become immobile near the Tutorial Barracks / Command Hall cluster.

### Included

- Added `docs/V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md` with Emmanuel's 532007d Tutorial feedback.
- Trained units now resolve their spawn point against the live map pathfinding grid and nearby building footprints before appearing.
- Move-ordered units that somehow start inside a blocked building cell now get a small nearest-walkable correction before pathing.
- Added focused TrainingSystem and MovementSystem regressions for the Tutorial Barracks / Command Hall geometry.
- Added a browser/manual-proxy deep regression that launches Tutorial, places the Barracks in the reported cluster, trains eight Rangers, orders them to move, and proves each newly trained Ranger moves.
- Updated private playtest package metadata and validation to include the v0.17.4 intake doc.

### Verdict

- Runtime gameplay changed: yes, trained-unit spawn placement and blocked-start movement recovery.
- Gameplay numbers changed: no unit/building/resource/wave/pacing/balance values changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: no.
- Worker construction implemented: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed: TypeScript no-emit, focused TrainingSystem/MovementSystem/package tests, targeted Tutorial Ranger production browser regression, `npm test` with 60 files / 431 tests, production build with the known Vite chunk-size warning, content validation, art-intake validation, fast smoke with 8 tests, targeted rerun of the one transient full-smoke timeout path, full smoke rerun with 14 tests, control lab normal, control lab extended, and control-lab verification with 1658 checks.
- Note: the first full smoke run timed out in the existing long Cinderfen Watch/Aftermath extended-smoke path; that exact test passed on targeted rerun, and the full smoke command passed on rerun.

### Next

- Generate and verify the v0.17.4 private playtest package, then have Emmanuel retest Tutorial Ranger production around the Barracks / Command Hall cluster.

## v0.17.3 Contact Polish And Command Panel Readability - 2026-05-23

This checkpoint follows Emmanuel's mixed retest of `ascendant-realms-private-playtest-e448d18`. It keeps the v0.17 line narrow: preserve the fixed incoming damage and easier Tutorial pressure, address one brief neutral-contact idle report, reduce attack-order path-warning clutter, and make the selected side panel less obstructive.

### Included

- Added `docs/V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md` with Emmanuel's e448d18 Tutorial feedback.
- Added a small melee visible-contact floor so player troops, Stone Imps, and Wild Hounds can engage when their sprites read as adjacent without requiring a first step.
- Kept Hold Ground/Guard Area/Press Attack semantics intact and preserved move-away suppression coverage.
- Suppressed `No clear path. Moving as close as possible.` for explicit attack-target path failures so enemy-base attacks do not stack warning text over combat.
- Added a Hide/Show control to the selected unit/building side panel. This is HUD-session-only and does not touch save data.
- Made build, train, and upgrade command buttons show explicit `Cost: ...` text, including locked/insufficient-resource commands.
- Updated package metadata and validation to include the v0.17.3 intake doc.

### Verdict

- Runtime gameplay changed: yes, melee visible-contact floor and explicit-attack path-warning display.
- Gameplay numbers changed: no map/unit/wave/resource/pacing values changed; v0.17.2 Tutorial-only pacing is preserved.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: narrowly, only visible-contact engagement tolerance.
- Worker construction implemented: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed: TypeScript no-emit, focused CombatSystem/CommandPanel/package tests, targeted Tutorial smoke, targeted deep combat contact regression, `npm test` with 59 files / 428 tests, production build, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, control lab normal, control lab extended, control-lab verification with 1658 checks, dirty-tree package generation, dirty-tree package verification with 38 checks, and `git diff --check`.

### Next

- Commit/push if `git diff --check` remains green, regenerate a clean private package from the final commit, and have Emmanuel retest Tutorial neutral troop contact, enemy-base attack visual feedback, side-panel Hide/Show, and visible build/train/upgrade costs.

## v0.17.2 Imp Damage Feedback And Tutorial Easing - 2026-05-23

This checkpoint follows Emmanuel's mixed retest of `ascendant-realms-private-playtest-a990f11`. It keeps the v0.17 line in narrow Tutorial polish: Stone Imp hero damage readability, simpler incoming damage text, and another Tutorial-only pacing ease.

### Included

- Added `docs/V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md` with Emmanuel's a990f11 Tutorial feedback.
- Fixed the Stone Imp versus Tutorial hero feedback gap by showing player-owned incoming direct damage down to 1 actual damage. Stone Imp hits against Aster now show the existing floating damage text even after hero armor reduces the hit to `4`.
- Removed the `HIT` prefix from incoming direct damage. Player-side direct damage now shows compact `-N` text in the existing red incoming color, while existing effect labels such as `Burn` remain separate.
- Eased Tutorial-only enemy escalation again: enemy income per tick is now scaled to 40%, training is at least 24s, expansion is at least 90s with a 120s initial delay, first attack is at least 540s, and follow-up attacks are at least 220s.
- Updated package metadata and validation to include the v0.17.2 intake doc.

### Verdict

- Runtime gameplay changed: yes, damage feedback readability and Tutorial-only enemy pacing.
- Gameplay numbers changed: Tutorial-only enemy AI helper values changed; campaign/skirmish map data and global difficulty presets did not.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: no.
- Worker construction implemented: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed so far: focused DamageFeedback/battlePacing/package tests, TypeScript no-emit, targeted Tutorial browser smoke covering Stone Imp damage against Aster, `npm test` with 58 files / 425 tests, build, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, control lab normal, control lab extended, control-lab verification with 1658 checks, dirty-tree package generation, and dirty-tree package verification with 37 checks.

### Next

- Run the full verification/package closeout, then have Emmanuel retest Tutorial Stone Imp damage against the hero, incoming damage text without `HIT`, and beginner pressure feel.

## v0.17.1 Tutorial Drag Polish And Beginner Pacing - 2026-05-23

This checkpoint follows Emmanuel's mixed retest of `ascendant-realms-private-playtest-171ba86`. It keeps v0.17.1 to Tutorial polish only: broader panel dragging, clearer incoming damage text, and slower Tutorial-only enemy pressure.

### Included

- Added `docs/V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md` with Emmanuel's 171ba86 Tutorial feedback.
- Made the Tutorial objective panel draggable from any non-button part of the panel instead of only the `Proving Grounds` title.
- Preserved Hide/Show and Reset, and kept Tutorial panel movement session-only with no save data or migration.
- Added distinct incoming player-side damage text through the existing floating-text system: direct hits on player-controlled entities now show `HIT -N` in a brighter red, while outgoing enemy damage remains compact `-N`.
- Kept floating text settings authoritative; disabling combat floating text still suppresses the new incoming text.
- Slowed only Tutorial enemy escalation by applying a Tutorial helper that scales enemy income per tick to 60%, raises training to at least 12s, expansion to at least 48s with a 60s initial delay, first attack to at least 420s, follow-up attacks to at least 140s, and keeps attack/expansion groups capped small.
- Updated package metadata and validation to include the v0.17.1 intake doc.

### Verdict

- Runtime gameplay changed: yes, Tutorial panel drag targeting, combat floating text readability, and Tutorial-only enemy pacing.
- Gameplay numbers changed: Tutorial-only enemy AI pacing/income helper values changed; campaign/skirmish map data and global difficulty presets did not.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: no.
- Worker construction implemented: no.
- Economy/production architecture rewritten: no.

### Verification

- Passed so far: focused TutorialPanel/DamageFeedback/battlePacing/package tests, TypeScript no-emit, targeted Tutorial browser smoke, `npm test` with 58 files / 425 tests, build, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, control lab normal, control lab extended, and control-lab verification with 1658 checks.

### Next

- Regenerate and verify the clean private playtest package from the final v0.17.1 commit. Emmanuel should retest Tutorial panel body dragging, button clicks, incoming hero/unit damage readability, and beginner pressure feel.

## v0.17 Tutorial QoL And Worker Economy Design Spec - 2026-05-23

This checkpoint starts v0.17 after Emmanuel confirmed the v0.16.13 adjacent melee/contact bug is fixed. It focuses on Tutorial objective-box QoL, Tutorial-specific pressure readability, and a design-only worker-economy spec.

### Included

- Added Emmanuel's solo playtest intake for the green v0.16.13 combat-control baseline.
- Marked the v0.16 critical adjacent melee bug as manually fixed against `ascendant-realms-private-playtest-461c563`.
- Made the Tutorial objective panel movable by dragging its Proving Grounds handle, with session-only offset state.
- Added Tutorial panel Hide/Show and Reset controls; these do not write save data and preserve HUD/minimap interaction.
- Added browser smoke coverage for drag, reset, minimize, restore, hover-stable Tutorial Next, completion, and no-save/no-reward behavior.
- Clarified Tutorial copy around early income capture, side mines, building a Barracks, training Militia, rallying, and grouped defense.
- Applied the existing Story pacing values to enemy escalation only for Tutorial launches, leaving campaign/skirmish map AI data unchanged.
- Added `docs/V017_WORKER_ECONOMY_DESIGN_SPEC.md` for Command Hall workers, worker-built buildings, production buildings, upgrades, risks, UI, AI, save/migration concerns, and phased v0.18+ implementation.
- Updated private playtest package metadata and validation to include the v0.17 intake/spec docs.

### Verdict

- Runtime gameplay changed: yes, Tutorial UI movement/minimize/reset and Tutorial-only enemy escalation pacing.
- Gameplay numbers changed: no global map, unit, wave, resource, or campaign balance data changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Combat-control baseline changed: no; v0.16.13 contact behavior was preserved.
- Worker construction implemented: no, design spec only.
- Economy/production architecture rewritten: no.

### Verification

- Passed: focused TutorialPanel and battle-pacing tests, TypeScript no-emit, targeted Tutorial browser smoke, in-app browser panel drag/hide/reset check, `npm test` with 57 files / 422 tests, build, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests, control lab normal, control lab extended, and control-lab verification with 1658 checks.

### Next

- Commit/push the checkpoint, regenerate a clean private playtest package from the final v0.17 commit, verify it, and have Emmanuel retest the Tutorial objective panel movement plus overall Tutorial pressure feel.

## v0.16.13 Stone Imp Visible-Contact Reacquisition Fix - 2026-05-23

This checkpoint fixes the failed bd26de3 manual retest where the Tutorial Hold Ground hero could still idle beside two Stone Imps before combat started or after the first imp died.

### Included

- Added bd26de3 retest intake and a v0.16.13 fix note.
- Reproduced bd26de3 in a browser/manual proxy: Warlord versus Stone Imp contact started at 54px and 57px but idled at 58px+.
- Increased melee visible-contact tolerance from 24px to 32px so the real Stone Imp visible-contact boundary reacquires without movement.
- Strengthened unit, deterministic control-lab, and hosted browser/manual regressions to use the 64px Stone Imp setup instead of the previous 54px near miss.
- Updated private package metadata and validation to require the v0.16.13 retest/fix notes.

### Verdict

- Runtime gameplay changed: yes, local melee visible-contact reacquisition only.
- Gameplay numbers changed: no unit stats, waves, resources, or balance data changed.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no mode definitions changed; Hold Ground still refuses distant idle enemies.
- Enemy aggro changed: no broad AI/pathing rewrite; only local melee contact reach changed.
- Retreat logic changed: no.
- Worker construction implemented: no.

### Verification

- Passed: focused package/combat/control tests with 3 files / 36 tests, `npm test` with 57 files / 421 tests, build, content validation, art-intake validation, fast smoke with 8 tests, control lab normal/extended/verify, hosted browser/manual Stone Imp regression, dirty-tree package generation, and package verification with 33 checks.

### Next

- Regenerate and verify a clean private playtest package from the final v0.16.13 commit. Emmanuel should retest the Tutorial Hold Ground hero beside two Stone Imps against that new package, not bd26de3.

## v0.16.12 Stationary Adjacent Melee Reacquisition Fix - 2026-05-23

This checkpoint fixes Emmanuel's `ec0608a` Tutorial retest failure where a Hold Ground hero and adjacent Stone Imps could remain idle in visible contact. It is a narrow v0.16.x combat bugfix, not v0.17.

### Included

- Added Emmanuel's `PT-20260521-EMMANUEL-EC0608A-SOLO-01` retest intake.
- Added a v0.16.12 fix report covering the audit, root cause, runtime change, test coverage, building-feedback debt, hover tolerance, and Tutorial-box deferral.
- Increased melee visible-contact tolerance narrowly for stationary adjacent melee.
- Let melee units accept immediate hostile contact when their explicit target is not already in effective range.
- Cleared explicit attack-move state after dead/invalid explicit targets so Hold Ground resumes local-contact rules after a target dies.
- Added top/head hover hit tolerance for units and buildings while preserving nearby empty terrain refusal.
- Updated control-lab scenarios and private package metadata for v0.16.12.

### Verdict

- Runtime gameplay changed: yes, melee contact/reacquisition semantics only.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: yes, Hold Ground contact/post-target-death semantics only.
- Enemy aggro changed: yes, immediate melee contact can interrupt a distant explicit target; no global chase was added.
- Retreat logic changed: no.
- Test/CI harness changed: yes, stronger combat/collision/control-lab/hosted regression coverage and package metadata.
- Worker construction implemented: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused combat/collision/movement/behaviour/control-lab tests with 5 files / 45 tests, `npm test` with 57 files / 421 tests, build, content validation, art-intake validation, fast smoke with 8 tests, control lab normal/extended/verify, hosted manual combat contact regression, in-app browser production-preview sanity, dirty-tree package generation, and package verification with 31 checks.

### Next

- Commit, push, regenerate the clean private playtest package, verify it does not end in `-dirty`, and have Emmanuel retest the Tutorial adjacent-two-imp Hold Ground case before v0.17.

## v0.16.11 Release-Candidate Issue Backlog And Tester Launch Prep - 2026-05-22

This checkpoint prepares project-management artifacts for Emmanuel's manual retest or a 2-5 tester launch. It is not v0.17 and does not change runtime gameplay.

### Included

- Added exact-final CI and release note documenting that `7cc6eff` has push Fast confidence green and no exact-final workflow-dispatch release matrix.
- Added ready-to-copy GitHub issue templates for manual retest, possible v0.16.x combat/control bugfixes, attack cursor polish, worker construction design, external tester intake, tutorial/onboarding polish, and visual overhaul.
- Added tester launch packet index with package file list and 2-5 tester route assignments.
- Added no-code freeze note: the next evidence should be human/manual testing, not more autonomous code.
- Updated package metadata to the v0.16.11 checkpoint title.
- Added `TESTER_LAUNCH_PACKET_INDEX.md` to the generated playtest package and validator.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Enemy aggro changed: no.
- Retreat logic changed: no.
- Test/CI harness changed: yes, package metadata and package validation only.
- Package changed: yes, tester launch index added.
- Worker construction implemented: no.
- Invented human feedback: no.

### Verification

- Passed: `npm test` with 57 files / 415 tests, build, content validation, art-intake validation, dirty-tree package generation, and package verification with 30 checks.

### Next

- Commit, push, regenerate the clean package, and have Emmanuel manually retest before v0.17.

## v0.16.10 Release-Candidate Freeze And Backlog Triage - 2026-05-22

This checkpoint freezes the post-v0.16.7 combat/control candidate for Emmanuel retest or a small external tester batch. It is not v0.17 and not a runtime feature/content/balance pass.

### Included

- Added v0.16.10 release-candidate baseline, final-hash CI status, release-candidate decision, backlog triage, public-safety check, tester message, feedback form, route assignment, and Emmanuel retest docs.
- Inspected GitHub Actions run #83 for `83f146e`: Fast confidence passed; release simulator, hosted release matrix, optional visual QA, and full release e2e were skipped by the push trigger.
- Documented that no exact-final workflow-dispatch release matrix was found for `83f146e`; run #80 remains the latest enabled workflow-dispatch matrix evidence for the post-v0.16.7 runtime stack.
- Declared `83f146e` ready for Emmanuel manual retest and a small 2-5 external tester batch, with remaining human-risk and watchpoints separated from automated confidence.
- Triaged backlog into manual-before-v0.17 checks, v0.16.x bugfix-only triggers, v0.17 intake, worker construction design, combat readability/VFX, tutorial/onboarding, visual overhaul, and explicit deferrals.
- Updated the playtest package metadata to the v0.16.10 checkpoint title.
- Added release-candidate notes, Emmanuel retest checklist, short tester message, short feedback form, and route assignments to the generated playtest package and validator.
- Completed a public-release safety check without finding secrets, private tester data, raw feedback, package artifacts, large unwanted binaries, or protected-IP copies.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Enemy aggro changed: no.
- Retreat logic changed: no.
- Test/CI harness changed: yes, package metadata and package validation only.
- Package changed: yes, tester kit contents expanded.
- Worker construction implemented: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.
- Secrets found: no.

### Verification

- Passed: `npm test` with 57 files / 415 tests, build, content validation, art-intake validation, fast smoke with 8 tests, control lab normal, control lab extended, control verifier with 1658 checks, dirty-tree package generation, and package verification with 29 checks.

### Next

- Commit, push, regenerate the clean private playtest package, verify it does not end in `-dirty`, and have Emmanuel run `EMMANUEL_MANUAL_RETEST_CHECKLIST.md`.

## v0.16.9 Autonomous Manual-Retest Proxy And Tester Readiness - 2026-05-22

This checkpoint strengthens automated evidence for the v0.16.7 manual combat/control fixes and prepares a small external tester packet. It is not v0.17 and not a runtime feature/content/balance pass.

### Included

- Added v0.16.9 baseline, remote CI, autonomous manual-proxy, combat edge matrix, first-tester, worker-design-only, visual/readability, and long-soak docs.
- Inspected GitHub Actions run #79 for `ad4eee0`: Fast confidence passed; workflow-dispatch release matrix jobs were skipped.
- Inspected GitHub Actions run #80 for `ad4eee0`: workflow-dispatch Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke all passed; optional visual QA and full release e2e were skipped.
- Extended the deterministic control behaviour lab from 12 to 18 scenarios.
- Added manual-proxy scenarios for Hold Ground adjacent follow-up and group retreat/resume.
- Added combat edge scenarios for 1 hero vs 3 melee enemies, 2 friendlies vs 3 enemies, local building aggro, and Hold/Guard/Press mode differences.
- Added a focused ranged-enemy building aggro unit test.
- Updated private package build-info metadata and verifier expectation to name the v0.16.9 checkpoint.
- Prepared short first external tester docs for 2-5 testers without committing private tester names.
- Documented worker construction as deferred design-only work.
- Audited attack cursor, hover readability, dense clusters, behaviour buttons, and retreat/order feedback without adding runtime art/assets.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Enemy aggro changed: no.
- Retreat logic changed: no.
- Test/CI harness changed: yes, deterministic control-lab and unit-test coverage only.
- Worker construction implemented: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused proxy/edge tests, 5-repeat focused proxy soak, control lab normal/extended/verify, 3-repeat hosted proxy soak, `npm test` with 57 files / 415 tests, build, content validation, art-intake validation, fast smoke, full smoke, hosted deep-battle, hosted smoke, full release e2e with 79 tests, and visual QA with 18 screenshots / 0 console errors / 0 retries.

### Next

- Push the final v0.16.9 docs/test checkpoint, regenerate the clean private playtest package, verify it does not end in `-dirty`, and inspect the automatic final push Fast confidence run. A fresh workflow-dispatch release matrix on the final v0.16.9 commit is optional because v0.16.9 does not change runtime gameplay.

## v0.16.8 Post-Combat-Fix CI Verification And Soak Audit - 2026-05-22

This checkpoint verifies v0.16.7's runtime combat/control fix with remote CI inspection, automated soak, control-lab coverage, public-repo safety audit, and tester handoff. It is not v0.17 and not a feature/content/balance pass.

### Included

- Added v0.16.8 baseline, remote CI, soak, control-lab, public-repo safety, long-soak, CI-triage, and Emmanuel retest docs.
- Inspected GitHub Actions CI Release Matrix Dry Run #78 for the v0.16.7 commit: Fast confidence passed; workflow-dispatch release matrix jobs were skipped.
- Added deterministic control-lab scenarios for local enemy melee building aggro and attack-hover tolerance versus nearby empty terrain.
- Regenerated control-lab normal, extended, and dashboard outputs.
- Stabilized one hosted smoke assertion by using deterministic scene state instead of transient Cinderfen Crossing launch text in `battle-status`.
- Audited public-repo safety for secrets, private tester data, generated artifacts, tracked binaries, and obvious protected-IP terms.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Enemy aggro changed: no.
- Retreat logic changed: no.
- Test/CI harness changed: yes, control-lab scenarios and one smoke assertion.
- Worker construction implemented: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.
- Secrets found: no.
- Public asset watchpoint: current tracked image assets remain prototype assets and still need source/license proof before production approval.

### Verification

- Passed: focused combat/movement/collision/behaviour/control-lab tests, 10-repeat focused unit soak, 5-repeat hosted manual combat regression, 3 control-lab normal/extended/verify cycles, `npm test` with 57 files / 414 tests, build, content validation, art-intake validation, fast smoke, full smoke after the smoke assertion fix, hosted deep-battle, hosted smoke after targeted fix and rerun, full release e2e with 79 tests, and visual QA with 18 screenshots / 0 console errors / 0 retries.

### Next

- Later v0.16.9 CI inspection found GitHub Actions run #80, a workflow-dispatch release matrix on `ad4eee0`, passed the enabled release lanes for the post-v0.16.7 combat-control stack. Optional visual QA and full release e2e were skipped remotely.

## v0.16.7 Manual Combat Contact And Aggro Fix - 2026-05-21

This checkpoint fixes Emmanuel's real v0.16.6 manual retest combat/control findings. It is a narrow runtime bugfix, not v0.17 and not a feature/content/balance pass.

### Included

- Added v0.16.7 manual intake, reproduction plan, audit, fix report, and deferred worker-construction note.
- Increased melee contact tolerance enough for adjacent visible-contact enemies without making Hold Ground chase distant idle enemies.
- Made melee unit-vs-building contact use the building footprint so enemies near a Command Hall/building can attack it locally.
- Preserved explicit move-away combat suppression when pathing clears the move target early.
- Added conservative attack hover/click hit tolerance for visible enemy body footprint while keeping nearby empty terrain non-targetable.
- Added focused CombatSystem, MovementSystem, CollisionSystem, and hosted deep-battle regression coverage.

### Verdict

- Root cause: raw contact/hit-test circles were stricter than visible melee/building/hover footprints, and retreat suppression depended too tightly on a live move target.
- Runtime gameplay changed: yes.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: yes, contact/reacquisition semantics only; no new mode or persistence.
- Enemy aggro changed: yes, local melee building contact only.
- Retreat logic changed: yes, move-away suppression preservation only.
- Worker construction implemented: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused Combat/Collision/Movement tests with 30 tests, focused hosted manual regression, `npm test` with 57 files / 414 tests, build, content validation, art-intake validation, fast smoke with 8 tests, full smoke with 14 tests after a longer rerun, controls lab, controls verifier, hosted deep-battle with 14 tests, hosted smoke with 14 tests, full release with 79 tests after a longer local wrapper rerun, visual QA with 18 screenshots / 0 console errors / 0 retries, and `git diff --check`.

### Next

- Commit, push, regenerate the clean private playtest package, verify it does not end in `-dirty`, and rerun GitHub Actions CI Release Matrix Dry Run because runtime combat/control behaviour changed.

## v0.16.6 Hosted Deep-Battle First Campaign Training Stabilization - 2026-05-21

This checkpoint fixes the remaining GitHub Actions CI Release Matrix Dry Run #75 hosted deep-battle failure after v0.16.5. It is a test-only follow-up, not v0.17 and not a gameplay/content/balance change.

### Included

- Added `docs/V0166_HOSTED_DEEP_BATTLE_FIRST_CAMPAIGN_TRAINING_FIX.md`.
- Kept visible Militia train command clicks first in the first-campaign hosted deep-battle test.
- Added a narrow fallback to the existing scene-backed training command helper only when visible command clicks do not expose a training queue.
- Allowed the trained Militia lookup to accept a newly trained unit already at the rally point, matching the later rally assertion.

### Verdict

- Root cause: hosted deep-battle #75 passed the v0.16.5 split tests and failed later in the broad first-campaign path because training command observation and trained-unit lookup were too brittle under hosted timing.
- First-campaign capture/build/train/rally/victory assertions weakened: no.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Package changed: no.
- CI workflow/release matrix changed: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused hosted first-campaign path, hosted deep-battle lane with 13 tests, `npm run test:e2e:smoke:fast` with 8 tests, `npm test` with 56 files / 406 tests, build, content validation, art-intake validation, and `git diff --check`.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run for v0.16.6 and confirm `Release matrix (deep-battle)` is green before starting v0.17.

## v0.16.5 Hosted Deep-Battle Command Hall Split Stabilization - 2026-05-20

This checkpoint fixes the remaining GitHub Actions CI Release Matrix Dry Run #72 hosted deep-battle timeout after v0.16.4. It is a test-only follow-up, not v0.17 and not a gameplay/content/balance change.

### Included

- Added `docs/V0165_HOSTED_DEEP_BATTLE_COMMAND_HALL_SPLIT_AUDIT.md`.
- Added `docs/V0165_HOSTED_DEEP_BATTLE_COMMAND_HALL_SPLIT_FIX.md`.
- Split the older broad hosted deep-battle HUD/minimap/fog/build/cancel test into two focused tests.
- Kept minimap, fog, attack cursor, marquee, and right-click move assertions in the original test.
- Moved Command Hall building placement/cancel assertions into a fresh hosted deep-battle context.
- Kept the dedicated behaviour mode gauntlet intact.

### Verdict

- Root cause: the older hosted deep-battle HUD test still reached the late Command Hall build command too close to the 120s hosted CI timeout after v0.16.4 fixed the earlier movement-order issue.
- Minimap/fog/building/cancel/command hall assertions weakened: no.
- Behaviour mode assertions weakened: no.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Package changed: no.
- CI workflow/release matrix changed: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused hosted movement/fog/move deep-battle test, focused hosted Command Hall build/cancel test, hosted deep-battle lane with 13 tests, hosted smoke lane with 14 tests, `npm run test:e2e:smoke:fast` with 8 tests, full smoke with 14 tests, `npm test` with 56 files / 406 tests, build, content validation, art-intake validation, controls lab, controls verifier, full release with 78 tests, and 3-repeat hosted soaks for both split tests.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run for v0.16.5 and confirm `Release matrix (deep-battle)` is green before starting v0.17.

## v0.16.4 Hosted Deep-Battle Movement Command Stabilization - 2026-05-20

This checkpoint fixes the remaining GitHub Actions CI Release Matrix Dry Run #70 hosted deep-battle timeout after v0.16.3. It is a test-only follow-up, not v0.17 and not a gameplay/content/balance change.

### Included

- Added `docs/V0164_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md`.
- Added `docs/V0164_HOSTED_DEEP_BATTLE_FIX.md`.
- Added a shared `Moving` / `Repositioning` movement-order summary pattern for valid right-click move commands.
- Swapped transient hosted status-line assertions in the older deep-battle HUD test for deterministic fog state, movement order, and placement cancel state checks.
- Kept the dedicated behaviour mode gauntlet intact.

### Verdict

- Root cause: the older hosted HUD/minimap/building deep-battle test still required exact `Moving` copy and transient status-line text in a pressure-heavy battle, while the runtime can validly show `Repositioning` and pressure status can outrank normal command/fog messages.
- Minimap/fog/building/cancel/command hall assertions weakened: no.
- Behaviour mode assertions weakened: no.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Package changed: no.
- CI workflow/release matrix changed: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused hosted deep-battle HUD test, hosted deep-battle lane with 12 tests, hosted smoke lane with 14 tests, `npm run test:e2e:smoke:fast` with 8 tests, full smoke with 14 tests, `npm test` with 56 files / 406 tests, build, content validation, art-intake validation, controls lab, controls verifier, full release with 77 tests, and 3-repeat focused deep-battle soak.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run for v0.16.4 and confirm `Release matrix (deep-battle)` is green before starting v0.17.

## v0.16.3 Hosted Smoke Pause/Resume Stabilization - 2026-05-20

This checkpoint fixes the remaining GitHub Actions CI Release Matrix Dry Run #68 hosted smoke timeout after v0.16.2. It is a test-only follow-up, not v0.17 and not a gameplay/content/balance change.

### Included

- Added `docs/V0163_HOSTED_SMOKE_PAUSE_RESUME_FIX.md`.
- Added scoped click options for only the settings runtime smoke battle menu and resume buttons.
- Kept the verified DOM-control fallback, but stopped spending hosted CI budget on repeated normal actionability waits before using it.
- Preserved the pause/resume scene-state assertions.

### Verdict

- Root cause: hosted smoke still spent too much time in normal Playwright click actionability before the verified DOM fallback on real `Menu` and `Resume` DOM buttons.
- Settings/accessibility assertions weakened: no.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Package changed: no.
- CI workflow/release matrix changed: no.
- Force clicks used: no.
- Canvas/world DOM fallback used: no.

### Verification

- Passed: focused hosted settings runtime test, hosted smoke lane with 14 tests, `npm run test:e2e:smoke:fast` with 8 tests, full smoke with 14 tests, `npm test` with 56 files / 406 tests, build, content validation, art-intake validation, and full release with 77 tests.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run for v0.16.3 and confirm `Release matrix (smoke)` is green before starting v0.17.

## v0.16.2 Release-Matrix Smoke And Deep-Battle Stabilization - 2026-05-20

This checkpoint fixes the GitHub Actions CI Release Matrix Dry Run #66 hosted release-matrix smoke and deep-battle timeout regressions after v0.16.1. It is a test-only stabilization pass, not v0.17 and not a gameplay/content/balance change.

### Included

- Added `docs/V0162_RELEASE_MATRIX_TIMEOUT_FAILURE_AUDIT.md`.
- Added `docs/V0162_RELEASE_MATRIX_TIMEOUT_FIX.md`.
- Removed duplicated behaviour-mode switching from the older deep-battle HUD/minimap/building test.
- Kept the dedicated hosted behaviour mode gauntlet intact as the owner of behaviour-mode switching assertions.
- Increased only the settings runtime accessibility smoke timeout from 60s to 90s.
- Added semantic pause/resume success checks for the settings runtime battle menu and resume clicks.
- Added an explicit post-resume battle-state assertion.

### Verdict

- Root cause: two hosted tests exceeded their scoped Playwright budgets under release-matrix production-preview timing. The deep-battle HUD test was overloaded by duplicated behaviour-mode transitions, and the settings runtime smoke needed the same kind of scoped hosted budget previously used for settings-smoke timeouts.
- `Target page/context/browser closed` was a timeout cleanup consequence, not the cause.
- Settings/accessibility assertions weakened: no.
- Minimap/fog/building/cancel/command hall assertions weakened: no.
- Behaviour mode assertions weakened: no.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Package changed: no.
- CI workflow/release matrix changed: no.

### Verification

- Passed: focused hosted deep-battle test, focused hosted smoke settings runtime test, hosted deep-battle lane with 12 tests, hosted smoke lane with 14 tests, `npm run test:e2e:smoke:fast` with 8 tests, full smoke with 14 tests, `npm test` with 56 files / 406 tests, build, content validation, art-intake validation, controls lab, controls verifier, full release with 77 tests, 3-repeat focused deep-battle soak, 3-repeat focused settings runtime soak, and `git diff --check`.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run for v0.16.2 and confirm `Release matrix (deep-battle)` and `Release matrix (smoke)` are green before starting v0.17.

## v0.16.1 Fast-Confidence CI Smoke Stabilization - 2026-05-20

This checkpoint fixes the GitHub Actions CI Release Matrix Dry Run #64 `Fast confidence` regression after v0.16. It is a test-only smoke stabilization pass, not v0.17 and not a gameplay/content/balance change.

### Included

- Added `docs/V0161_FAST_CONFIDENCE_CI_FAILURE_AUDIT.md`.
- Added `docs/V0161_FAST_CONFIDENCE_CI_FIX.md`.
- Split the settings accessibility smoke path into two focused `@ci-fast` tests: persistence and in-battle runtime application.
- Added a Settings-screen success check for the Settings menu click/reopen path.
- Preserved the inventory smoke test unchanged.

### Verdict

- Root cause: the original settings accessibility smoke test was an oversized multi-scene `@ci-fast` path that could exceed hosted runner budget and destabilize later browser context setup.
- Settings/accessibility assertions weakened: no.
- Inventory assertions weakened: no.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: no.
- Package changed: no.
- CI workflow/release matrix changed: no.

### Verification

- Passed: targeted settings persistence, targeted inventory, `npm run test:e2e:smoke:fast` with 8 tests, full `npm run test:e2e:smoke` with 14 tests, `npm test` with 56 files / 406 tests, build, content validation, art-intake validation, controls lab, controls verifier, hosted smoke rerun with 14 tests, full release with 77 tests, a 3-repeat settings persistence soak, and `git diff --check`.
- Noted: the first hosted smoke run failed in an unrelated extended-smoke Cinderfen transient status-copy assertion. The targeted hosted case then passed, and the full hosted smoke rerun passed without code changes.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run for v0.16.1 and confirm `Fast confidence` is green before starting v0.17.

## v0.16 Behaviour Mode Gauntlet And Playtest Diagnostics - 2026-05-19

This checkpoint builds an automated confidence and packaging layer around the v0.15 RTS behaviour modes and control fixes. It is a hardening, diagnostics, regression, and private-playtest evidence pass, not a broad feature or balance pass.

### Included

- Added `docs/V016_BASELINE_AND_CI_AUDIT.md`.
- Added `docs/V016_BEHAVIOUR_MODE_AUDIT.md`.
- Added `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`.
- Added Emmanuel/tester retest docs: control retest script, route card, behaviour-mode checklist, feedback intake template, and triage guide.
- Added deterministic control behaviour lab scripts: `npm run playtest:controls`, `npm run playtest:controls:extended`, and `npm run playtest:controls:verify`.
- Added generated control lab JSON/Markdown and dashboard outputs.
- Expanded unit/system coverage for Hold Ground, Guard Area, Press Attack, explicit orders, move-away suppression, mixed group mode reporting, order summary copy, selected panel behaviour controls, and package validation.
- Added a hosted browser gauntlet covering behaviour mode controls, attack hover, left-click attack, retreat feedback, marquee/HUD cleanup, minimap movement, and `H` hero-select refresh.
- Narrowly fixed Hold Ground direct-attacker response so a nearby enemy directly attacking the unit can be pursued, while idle distant enemies are still refused.
- Hardened private playtest package validation so v0.16 control retest materials are required.

### Verdict

- Runtime gameplay changed: yes, narrowly in Hold Ground direct-attacker response.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: yes, only to align Hold Ground direct-attacker handling with the existing v0.15 spec.
- Patrol implemented: no.
- Human feedback invented or claimed: no.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md`, `LLM_GAME_HANDOFF.md`, and `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`.
- GitHub Actions should be rerun because runtime combat/control behaviour and release/package diagnostics changed.

### Next

- Send the clean v0.16 private package to Emmanuel and use `docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md` for the next manual retest.

## v0.15 RTS Control Behaviour Foundation - 2026-05-18

This checkpoint builds the first original RTS behaviour-mode foundation on top of the v0.14.x Emmanuel control fixes, while preserving the no-new-content, no-save-migration, no-runtime-art, no-balance-tuning guardrails.

### Included

- Added `docs/V015_CONTROL_COMBAT_BASELINE_AUDIT.md`.
- Added `docs/V015_BEHAVIOUR_MODES_SPEC.md`.
- Added `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`.
- Added session-only unit behaviour mode state: Hold Ground, Guard Area, and Press Attack.
- Added selected-unit and selected-group behaviour controls using existing HUD button styling.
- Updated selected order copy for behaviour modes, repositioning, and explicit attack targets.
- Hardened retreat intent so normal move-order suppression cannot be consumed and overridden on the same update frame.
- Kept attack-hover and left-click attack intent intact while adding coverage for HUD refresh survival, cursor clearing, and empty-click non-attack behavior.
- Preserved v0.14.4/v0.14.5 marquee, HUD, and minimap regression coverage.
- Updated tester-facing quick-start/package copy and playtest package metadata for v0.15.

### Verdict

- Runtime gameplay changed: yes, narrowly in player unit behaviour modes, command feedback, explicit attack target labels, and move-away suppression timing.
- Gameplay numbers changed: no unit data, HP, damage, range, cooldown, speed, economy, reward, map, faction, or unit values changed.
- Save format changed: no.
- Behaviour modes implemented: yes, session-only Hold Ground, Guard Area, and Press Attack.
- Patrol implemented: no, design-only/deferred.
- Runtime art/assets changed: no.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.
- GitHub Actions should be rerun because runtime battle/input/HUD behavior changed.

### Next

- Have Emmanuel retest attack intent, left-click attack, adjacent melee engagement, Hold / Guard / Press modes, retreat/move-away behavior, HUD/minimap drag selection, tutorial completion/defeat, and snap-back risk.

## v0.14.5 Hosted Deep-Battle Minimap Fix - 2026-05-18

This checkpoint fixes the isolated GitHub Actions CI Release Matrix Dry Run #61 hosted deep-battle failure in the minimap/marquee section of `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`.

### Included

- Added `docs/V0145_HOSTED_DEEP_BATTLE_MINIMAP_REGRESSION_AUDIT.md`.
- Added `docs/V0145_HOSTED_DEEP_BATTLE_MINIMAP_FIX.md`.
- Updated `tests/e2e/deep-flow.spec.ts` so the minimap-crossing marquee check waits for the battlefield pointerdown to establish active drag state before moving into the minimap.
- Kept the active-drag-over-minimap and release-over-minimap assertions, with a scoped hosted-safe 3-second poll instead of the brittle 1-second midpoint poll.
- Added `try/finally` mouseup cleanup around the minimap drag segment.
- Added an explicit minimap-click camera movement assertion so minimap movement coverage is clearer, not weaker.

### Verdict

- Root cause: a hosted timing race in the new v0.14.4 minimap drag regression check, not a proven runtime product regression.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Minimap coverage preserved: yes; camera movement is now explicitly asserted.
- Hosted release matrix structure changed: no.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- Rerun GitHub Actions CI Release Matrix Dry Run and confirm the hosted deep-battle group passes.

## v0.14.4 Combat Control Retest Fixes - 2026-05-18

This checkpoint uses only Emmanuel's v0.14.3 retest of `PT-20260518-EMMANUEL-BASELINE-01` and fixes the remaining concrete combat/control issues without broad redesign, behaviour modes, unit panel redesign, maps, factions, units, runtime art/assets, save migration, or balance tuning.

### Included

- Added `docs/V0144_COMBAT_CONTROL_RETEST_FIX_REPORT.md`.
- Improved adjacent melee engagement by giving melee contact a small visual-footprint tolerance.
- Added regression coverage for melee visual contact and post-kill adjacent target reacquisition.
- Kept drag-selection responsive while the pointer crosses the side panel or minimap by updating the marquee from global pointer movement during active battlefield drags.
- Cleared handled HUD/minimap focus/deferred markup state so minimap interaction does not leave stale `No Selection` UI after keyboard selection.
- Added attack-hover feedback: selected units hovering a targetable hostile/neutral target now show a crosshair cursor and left-click issues an attack order.
- Changed `Complete Tutorial` to open the existing no-save/no-reward Results flow instead of going straight to Main Menu.
- Updated tutorial Crown Shrine copy from blue ownership to green ownership.
- Updated browser coverage for tutorial completion, attack cursor/left-click attack order, and release-over-minimap drag behavior.

### Verdict

- Runtime gameplay changed: yes, narrowly in melee contact interpretation, input drag responsiveness, attack-click intent, and tutorial completion routing.
- Gameplay numbers changed: no unit data, HP, damage, cooldown, economy, reward, map, faction, or unit values changed.
- Save format changed: no.
- Human feedback used: yes, only Emmanuel's v0.14.3 retest notes.
- Screenshot visual bug: not specifically fixed because no attached screenshot was available in the current thread or repo artifacts.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.
- GitHub Actions should be rerun because runtime battle/input/tutorial behavior changed.

### Next

- Have Emmanuel retest melee contact after kills, enemy contact attacks, drag-select over HUD/minimap, Complete Tutorial Results flow, and attack-hover/left-click attack orders.

## v0.14.3 Combat Selection Control Fixes - 2026-05-18

This checkpoint uses Emmanuel's v0.14.x retest of `PT-20260518-EMMANUEL-BASELINE-01` and fixes the remaining critical control/combat usability reports without adding maps, factions, units, runtime art/assets, save migration, broad AI/pathing rewrites, visual overhaul, or copied/protected RTS UI.

### Included

- Added `docs/V0143_EMMANUEL_RETEST_INTAKE.md`.
- Added `docs/V0143_REPRODUCTION_PLAN.md`.
- Added `docs/V0143_COMBAT_SELECTION_RETEST_FIX_REPORT.md`.
- Added `docs/V0143_UNIT_BEHAVIOUR_MODES_DESIGN.md`.
- Restored marquee selection when a drag starts on the battlefield and releases over the HUD/side panel.
- Added melee contact reach so adjacent melee units can attack reliably without changing unit data.
- Changed normal move-order combat suppression from indefinite to short-lived, preserving retreat intent without making retreat invincible.
- Routed tutorial defeat through no-save/no-reward Results guidance with `Retry Tutorial` and `Main Menu`.
- Added factual hero class/origin mechanical summaries from existing stats, origin bonuses, and primary abilities.
- Added focused unit and browser regression coverage for selection, melee engagement, retreat intent, tutorial defeat guidance, movement snap-back, and hero creation clarity.

### Verdict

- Runtime gameplay changed: yes, narrowly in input selection handling, melee contact engagement, move-order combat intent, tutorial defeat routing, and hero creation copy.
- Gameplay numbers changed: no unit data, damage, HP, economy, reward, map, or save values changed. The melee fix changes contact interpretation, not content data.
- Save format changed: no.
- Human feedback used: yes, only Emmanuel's supplied retest notes.
- Unit behaviour modes: design-only, not implemented.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.
- GitHub Actions should be rerun because runtime battle/input/tutorial behavior changed.

### Next

- Regenerate a clean private playtest package from the final commit and have Emmanuel retest marquee selection, melee attacks, retreat reliability, tutorial defeat, and hero creation explanations.

## v0.14.2 Hosted Settings Smoke Fix - 2026-05-18

This checkpoint fixes the isolated GitHub Actions CI Release Matrix Dry Run #55 hosted smoke timeout in `settings screen persists accessibility options @ci-fast`. It keeps the settings smoke assertions intact and does not change runtime gameplay, gameplay numbers, save format, content, art/assets, or hosted release matrix structure.

### Included

- Added `docs/V0142_HOSTED_SETTINGS_SMOKE_FAILURE_AUDIT.md`.
- Added `docs/V0142_HOSTED_SETTINGS_SMOKE_FIX.md`.
- Increased only the settings accessibility smoke test timeout from 60 seconds to 90 seconds.

### Verdict

- Root cause: v0.14.1 expanded this already multi-stage settings smoke path with battle pause overlay verification; local hosted repro passed but used about 45 seconds, leaving too little margin for slower GitHub-hosted runners.
- Settings assertions preserved: yes.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Save format changed: no.
- Hosted matrix structure changed: no.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- Rerun the GitHub Actions CI Release Matrix Dry Run and confirm the hosted smoke group passes.

## v0.14.1 Emmanuel Quick Playtest Intake And Critical Usability Fix Pass - 2026-05-18

This checkpoint ingests Emmanuel's first real private playtest session, `PT-20260518-EMMANUEL-BASELINE-01`, and fixes only narrow, high-confidence input, HUD, tutorial, and command usability problems. It does not add maps, factions, units, runtime art/assets, save migration, balance tuning, broad combat AI rewrites, automated simulation expansion, or invented tester feedback.

### Included

- New intake, reproduction, and fix-report docs for Emmanuel's Baseline Cautious quick route.
- Focused keyboard guard so global movement/camera hotkeys ignore focused editable inputs.
- Hero creation text input now accepts names containing `W`, `A`, `S`, and `D`.
- Battle selection drag state clears on pointer release/cancel/blur and when a stale drag loses the mouse button.
- Battle `Menu` now opens a pause overlay with `Resume` and `Exit to Main Menu`.
- Normal player move orders now override opportunistic combat engagement; attack-move still engages along the route.
- Movement correction avoids large blocked snap-back jumps.
- Hero ability controls now show concise effect/cost copy.
- Selected order copy clarifies that attacking should reduce enemy HP when in weapon range.
- Focused unit and browser tests cover text input, selection drag cleanup, pause menu, move vs attack-move, movement correction, and readability copy.

### Verdict

- Runtime gameplay changed: yes, narrowly in input handling, HUD/menu behavior, normal move command intent, and movement correction.
- Gameplay numbers changed: no.
- Save format changed: no.
- Human feedback used: yes, only Emmanuel's supplied session.
- Deferred/retest-dependent: deeper pathing or combat-readability work if the unit snap-back or hero attack clarity reports reproduce after this pass.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.
- GitHub Actions should be rerun because runtime input/HUD/battle behavior changed, even though local and hosted release gates passed.

### Next

- Build a clean v0.14.1 private playtest package and have Emmanuel rerun the same Baseline Cautious route, focusing on the nine reported issues.

## v0.14 Private Playtest Build Packaging And One-Click Tester Delivery - 2026-05-18

This checkpoint makes the existing browser prototype easier to package and send for private human playtesting. It preserves runtime gameplay, gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, hosted release patterns, automated lab behavior, and human-feedback boundaries.

### Included

- New package commands: `npm run build:playtest`, `npm run package:playtest`, and `npm run verify:playtest-package`.
- Playtest-safe build mode uses relative asset URLs so the package can be served from its own folder.
- New package generator: `tools/packagePlaytestBuild.ts`.
- New package verifier: `tools/verifyPlaytestPackage.ts`.
- New package validation helper and tests under `src/game/playtest/PlaytestPackageValidation*`.
- Private package output under ignored `artifacts/playtest/ascendant-realms-private-playtest-<commit>/`.
- Package contents include `game/`, tester README, feedback packet, route assignment plan, build metadata, a local server helper, and Windows/Mac/Linux launchers.
- New v0.14 docs for distribution audit, tester README, coordinator guide, and ready-to-send private message.
- Existing tester quick-start/coordinator docs now point to the private package flow.

### Verdict

- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Human feedback used: no.
- Private feedback storage changed: no raw feedback folders were created or committed.
- GitHub Actions rerun is optional because this is packaging/tooling/docs only.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- Generate a clean package after this commit, send it to real testers, then run feedback intake only after completed human forms exist.

## v0.13.1a Extended Scenario Lab Integrity Audit And Gap-Fix Pass - 2026-05-18

This checkpoint audits the v0.13.1 extended scenario lab instead of trusting the prior handoff. It preserves runtime gameplay, gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, hosted release patterns, and human-feedback boundaries.

### Included

- Integrity audit docs for implementation reality, script/output verification, statistical usefulness, and final audit verdict.
- New generated-output validator: `src/game/playtest/ScenarioLabOutputValidation.ts`.
- New command: `npm run playtest:lab:verify`.
- CSV profile comparison ordering now matches the ranked Markdown table.
- Extended JSON/Markdown now include `uniqueDerivedMetricFingerprints` and metric availability.
- Extended reports now state that the five default iterations are identical deterministic replays, not stochastic samples.
- CLI `--runs` validation now rejects invalid values instead of silently falling back.
- Threshold documentation now explains the rationale for conservative non-tuning statuses.

### Verdict

- v0.13.1 was real implementation, not mostly superficial docs.
- v0.13.1 was still missing a generated-output quality gate and had a CSV/Markdown ordering mismatch.
- Runtime gameplay changed: no.
- Gameplay numbers changed: no.
- Human feedback used: no.
- Automated decision remains no runtime tuning.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed.
- Next recommended long goal remains real human playtest execution using the v0.12.6 tester packet, followed by intake only after completed forms exist.

## v0.13.1 Extended Automated Scenario Lab, Multi-Run Evidence, and Balance Regression Dashboard - 2026-05-18

This checkpoint deepens the v0.13 automated scenario lab with repeated deterministic evidence, profile comparisons, node-risk dashboarding, and conservative future regression thresholds. It preserves the v0.13/v0.12.x green foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Extended scenario-lab runner, report writer, regression thresholds, and tests under `src/game/playtest/`.
- New commands: `npm run playtest:lab:extended`, `npm run playtest:watchpoints:extended`, and `npm run playtest:profiles:compare`.
- Generated extended automated evidence outputs: `PLAYTEST_SCENARIO_LAB_EXTENDED.md`, `PLAYTEST_SCENARIO_LAB_EXTENDED.json`, `PLAYTEST_PROFILE_COMPARISON.md`, `PLAYTEST_PROFILE_COMPARISON.csv`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`, and `PLAYTEST_WATCHPOINTS_EXTENDED.md`.
- v0.13.1 docs for lab limitations, node-risk dashboard spec, regression thresholds, evidence review, no-tuning decision, and final extended-lab report.
- Focused tests for repeated batch generation, profile comparison metrics, watchpoint threshold classification, required report sections, no human-feedback claims, and quick-lab preservation.

### Verdict

- Runtime code changed only in simulator/reporting tooling.
- Gameplay numbers changed: no.
- Human feedback used: no.
- Automated decision: no runtime tuning. Mixed-Veterans is the top-ranked stable automated profile, Retinue + Training Yard II requires human testing before any balance proposal, Greedy Economy remains a monitor item for conversion/time risk, Fast Army remains a monitor item for Cinderfen speed rather than a trivialization signal, early defeats are OK, and pressure fairness still needs human noticeability testing.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed.
- Next recommended long goal: real human playtest execution using the v0.12.6 tester packet, prioritized by the v0.13.1 dashboard, followed by feedback intake only after completed forms exist.

## v0.13 Automated Playtest Scenario Lab And Balance Telemetry V1 - 2026-05-18

This checkpoint adds an automated scenario-lab and watchpoint-classifier layer on top of the existing deterministic playtest simulator. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5/v0.12.6 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Scenario-lab profiles, metrics, classifier, report writer, and runner under `src/game/playtest/`.
- New commands: `npm run playtest:lab`, `npm run playtest:watchpoints`, and `npm run playtest:profiles`.
- Generated automated evidence outputs: `PLAYTEST_SCENARIO_LAB.md`, `PLAYTEST_SCENARIO_LAB.json`, `PLAYTEST_WATCHPOINT_SUMMARY.md`, `PLAYTEST_SCENARIO_PROFILES.md`, and `PLAYTEST_SCENARIO_PROFILES.json`.
- v0.13 docs for architecture audit, scenario profile spec, telemetry metrics, classifier rules, automated evidence decision, and final scenario-lab report.
- Focused tests for profile metadata, classifier conservatism, report sections, JSON shape, and no human-feedback claims.

### Verdict

- Runtime code changed only in simulator/reporting tooling.
- Gameplay numbers changed: no.
- Human feedback used: no.
- Automated decision: no runtime tuning. Retinue + Training Yard II needs human testing, Greedy Economy remains a monitor item for conversion/time risk, Fast Army remains a monitor item for Cinderfen speed, early defeats are no-change structurally, and pressure fairness still needs human noticeability testing.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed.
- Next recommended long goal: real human playtest execution using v0.12.6 tester packet, followed by feedback intake only after completed forms exist.

## v0.12.6 Playtest Distribution Readiness And Tester Onboarding - 2026-05-18

This checkpoint adds the distribution and onboarding layer needed to hand the current v0.12.x browser prototype to real human testers. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Tester quick-start: `docs/V0126_TESTER_QUICK_START.md`.
- Emmanuel/coordinator guide: `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`.
- Route assignment plan: `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`.
- Copy-paste feedback submission packet: `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`.
- Feedback storage plan: `docs/V0126_FEEDBACK_STORAGE_PLAN.md`.
- Ready-to-send tester message: `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`.
- Updated the v0.12.4 packet index and v0.12.5 intake hub so testers, coordinator workflow, and later triage are connected.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because v0.12.6 is docs-only.
- Next recommended long goal: v0.12.7 Real Human Playtest Feedback Review And Small-Polish Decision, only after real completed tester forms exist.

## v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage - 2026-05-18

This checkpoint adds the evidence-intake layer for completed v0.12.4 manual playtest packets. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, combat systems, campaign progression, and gameplay numbers.

### Included

- Feedback intake hub: `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md`.
- Evidence classification guide: `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`.
- Watchpoint aggregation sheet: `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md`.
- Triage decision tree: `docs/V0125_TRIAGE_DECISION_TREE.md`.
- Severity/priority rubric: `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`.
- Feedback-to-action matrix: `docs/V0125_FEEDBACK_TO_ACTION_MATRIX.md`.
- Issue-ready templates: `docs/V0125_ISSUE_READY_TEMPLATES.md`.
- Fictional sample feedback triage: `docs/V0125_SAMPLE_FEEDBACK_TRIAGE.md`.
- Updated the v0.12.4 packet index to point from filled tester forms into the v0.12.5 intake workflow.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because v0.12.5 is docs-only.
- Next recommended long goal: v0.12.6 Manual Playtest Feedback Review And Small-Polish Decision.

## v0.12.4 Manual Human Playtest Packet And Tester Checklist - 2026-05-18

This checkpoint packages the v0.12.x human balance watchpoints into practical tester-facing documentation. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, and gameplay mechanics.

### Included

- Main manual playtest packet: `docs/V0124_MANUAL_HUMAN_PLAYTEST_PACKET.md`.
- Route cards: `docs/V0124_PLAYTEST_ROUTE_CARDS.md`.
- Mission checklists: `docs/V0124_MISSION_CHECKLISTS.md`.
- Watchpoint rating sheet: `docs/V0124_WATCHPOINT_RATING_SHEET.md`.
- Bug/friction report template: `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`.
- Playtest summary form: `docs/V0124_PLAYTEST_SUMMARY_FORM.md`.
- Designer interpretation guide: `docs/V0124_DESIGNER_INTERPRETATION_GUIDE.md`.
- Playtest packet index: `docs/V0124_PLAYTEST_PACKET_INDEX.md`.
- Tester-facing guidance for what to judge now versus what belongs to the future visual overhaul.
- Interpretation rules to prevent one-off complaints from becoming premature tuning.

### Verification

- Final verification is recorded in `DEVELOPMENT_CHECKPOINT.md` and `LLM_GAME_HANDOFF.md`.

### Next

- GitHub Actions rerun is optional because v0.12.4 is docs-only.
- Next recommended long goal: v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage.

## v0.12.3 Human Campaign Balance Play Session - 2026-05-17

This checkpoint gathers direct human-style campaign balance evidence after v0.12.2 without changing runtime behavior. It preserves the v0.11.12/v0.12/v0.12.1/v0.12.2 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, and gameplay mechanics.

### Included

- Human campaign play-session protocol: `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`.
- Human-style campaign notes: `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`.
- Compact evidence table: `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`.
- No-change decision: `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`.
- Final report: `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`.
- Direct visible browser evidence from main menu through New Campaign, Campaign Map, Border Village guidance, and battle HUD launch.
- Route evidence for baseline, no-retinue, one-veteran, mixed-veterans, Retinue + Training Yard II, Greedy Economy, and Fast Army.

### Verification

- Final verification is recorded in `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`.

### Next

- GitHub Actions rerun is optional because v0.12.3 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check.
- Next recommended long goal: v0.12.4 Manual Human Playtest Packet And Tester Checklist.

## v0.12.2 Human Balance Watchpoint Review - 2026-05-17

This checkpoint reviews the v0.12/v0.12.1 balance watchpoints without changing runtime behavior. It preserves the v0.11.12/v0.12/v0.12.1 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, enemy pressure scope, and gameplay mechanics.

### Included

- Balance watchpoint protocol: `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`.
- Simulator balance review: `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`.
- Human-style balance notes: `docs/V0122_HUMAN_BALANCE_NOTES.md`.
- No-tuning decision: `docs/V0122_TUNING_DECISION.md`.
- Final watchpoint report: `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`.
- Retinue + Training Yard II was confirmed as the strongest watchpoint, especially in Ashen/Cinderfen, but not a current numeric nerf target.
- Greedy Economy failures were classified as risky conversion/timeouts rather than unfair early pressure or raw economy shortage.
- Fast Army was classified as a legitimate speed profile, not a free dominant route.
- Early campaign defeat evidence did not show a structural balance problem.
- Cinderfen pressure warnings remain fair and actionable in current structural evidence.

### Verification

- Final verification is recorded in `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`.

### Next

- GitHub Actions rerun is optional because v0.12.2 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check.
- Next recommended long goal: v0.12.3 Human Campaign Balance Play Session, focused on direct human runs through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch across retinue/Training Yard profiles.

## v0.12.1 Human-Paced Core Feel Playtest Review - 2026-05-17

This checkpoint validates the v0.12 readability pass through slow, human-paced play review and applies only tiny evidence-backed polish. It preserves the v0.11.12/v0.12 green release foundation, hosted release group structure, save compatibility, tutorial no-save/no-reward behavior, existing art, maps, factions, units, rewards, and gameplay mechanics.

### Included

- Human-paced playtest protocol: `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`.
- Human-paced playtest notes: `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`.
- Tiny polish plan: `docs/V0121_PLAYTEST_POLISH_PLAN.md`.
- No-tuning decision: `docs/V0121_TUNING_DECISION.md`.
- Visual QA review: `docs/V0121_VISUAL_QA_REVIEW.md`.
- Final report: `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.
- Aligned player-facing Cinderfen battle names to `Cinderfen Crossing` and `Cinderfen Watch` while keeping ids, files, routes, saves, and mechanics unchanged.
- Reworded the Cinder Shrine objective so the small tracker calls out the one-time +20 Aether surge and hold instruction more plainly.
- Made defeat guidance context-aware so skirmish defeats no longer suggest campaign-only camp/Chapel support.
- Updated focused tests for the changed copy and preserved release assertions after scene-transition/HUD-refresh timing was exposed by full release verification.

### Verification

- Final verification is recorded in `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.

### Next

- Rerun the manual GitHub Actions release matrix on the v0.12.1 checkpoint commit.
- Next recommended long goal: v0.12.2 Human Balance Watchpoint Review, focused on repeated evidence for retinue plus Training Yard II, Greedy Economy timeouts, Fast Army clear speed, early campaign defeat causes, and pressure-warning fairness.

## v0.12 Core Game Feel and Battle Readability Pass - 2026-05-16

This checkpoint improves the existing playable slice after the v0.11.12 hosted release matrix green closeout. It focuses on command acknowledgement, selected-order clarity, objective wording, scoped pressure readability, battle-status priority, side-panel hierarchy, results guidance, and evidence-backed no-change tuning decisions without adding new art, maps, factions, units, save migrations, broad AI/economy behavior, or CI plumbing.

### Included

- Core feel audit: `docs/V012_CORE_GAME_FEEL_AUDIT.md`.
- Battle readability audit: `docs/V012_BATTLE_READABILITY_AUDIT.md`.
- Balance/readability tuning note: `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`.
- Visual readability note: `docs/V012_VISUAL_READABILITY_NOTES.md`.
- Final pass report: `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`.
- Added a `command` battle-status priority so accepted commands can outlive routine income ticks while still yielding to pressure and objective messages.
- Added clearer move, attack, attack-move, rally, build, train, research, ability, and blocked-command feedback.
- Improved selected-group and current-order side-panel hierarchy using existing HUD styling.
- Marked the first unfinished objective as `Next` and tightened Ashen/Cinderfen objective copy.
- Clarified Cinderfen pressure warning counterplay without promoting pressure into workers, construction, economy AI, or a broad strategic planner.
- Improved defeat/results guidance while preserving reward/save behavior.
- Added/updated tests for objective state, status priority, pressure warning copy, and command acknowledgement.

### Verification

- Final verification is recorded in `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`.

### Next

- Rerun the manual GitHub Actions release matrix on the v0.12 checkpoint commit.
- Next recommended long goal: v0.12.1 Human-Paced Core Feel Playtest Review, with any follow-up changes kept small and evidence-driven.

## v0.11.12 Hosted Release Interaction Determinism Fix - 2026-05-15

This checkpoint keeps the hosted release groups on production preview and hardens the test-only interaction/readiness layer after GitHub run #19 passed `deep-meta` but still failed hosted `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted interaction failure audit: `docs/V1112_HOSTED_RELEASE_INTERACTION_FAILURE_AUDIT.md`.
- Hosted interaction determinism fix report: `docs/V1112_HOSTED_RELEASE_INTERACTION_DETERMINISM_FIX.md`.
- `clickReady` now supports a verified DOM click fallback for real enabled controls after normal Playwright click actionability fails; it does not apply to canvas/world clicks.
- Targeted hosted-problem raw DOM clicks now use `clickReady`, including tutorial command-log advancement, smoke setup/campaign controls, enemy-pressure launch controls, deep-flow Barracks/Train command points, layout navigation, and Chapter 2 helper campaign controls.
- Shared `expectBattleLoaded` now covers HUD, resources, hero panel, minimap shell, minimap test id, canvas, and active BattleScene readiness, and is reused across hosted pressure/smoke/layout/deep paths.
- Tutorial layout and smoke paths now wait for real overlay/button readiness and non-null layout boxes before measuring or advancing.
- Side-panel command reachability now waits for side-panel readiness, uses smaller per-button live-DOM geometry checks, and records diagnostics instead of one broad page evaluation.
- Deep-battle right-click movement now revalidates selected unit state and canvas-safe movement points before preserving the unchanged `Moving` assertion.

### Verification

- Final verification for this checkpoint is recorded in `docs/V1112_HOSTED_RELEASE_INTERACTION_DETERMINISM_FIX.md` and `DEVELOPMENT_CHECKPOINT.md`.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect the same production-preview hosted release jobs plus the unchanged `Release simulator`.

## v0.11.11 Hosted Release Preview Environment Fix - 2026-05-15

This checkpoint moves the manual hosted GitHub Actions release matrix from the Vite dev server to production preview after GitHub run #17 still failed all explicit hosted groups, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted release environment audit: `docs/V1111_HOSTED_RELEASE_ENVIRONMENT_AUDIT.md`.
- Hosted preview environment fix report: `docs/V1111_HOSTED_RELEASE_PREVIEW_ENVIRONMENT_FIX.md`.
- New `playwright.hosted-release.config.ts` for hosted release groups, serving `vite preview` on `127.0.0.1:5173` instead of the Vite dev server.
- New `npm run preview:hosted` script for strict-port production preview on the Playwright release URL.
- Hosted release group scripts now run with `--config=playwright.hosted-release.config.ts`.
- Hosted release Chromium launch args now include `--no-sandbox`, `--disable-dev-shm-usage`, `--disable-gpu`, and the existing SwiftShader/WebGL args.
- GitHub Actions already used `npx playwright install --with-deps chromium`; no dependency-install change was required.
- Small test-only actionability hardening on reported skirmish/tutorial launch paths, with no force-clicks and no weakened assertions.
- Deep-flow right-click movement command now tries nearby alternate world points before failing the unchanged `Moving` assertion.

### Verification

- Passed: `npm test` with 46 files / 351 tests.
- Passed: `npm run build` with the known Phaser vendor chunk warning.
- Passed: `npm run validate:content` and `npm run validate:art-intake`.
- Passed: `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, and `npm run playtest:sim`.
- Passed: all six hosted release preview groups locally, totaling 67 tests: `deep-meta` 12, `deep-battle` 11, `deep-campaign-pressure` 7, `layout-core` 16, `layout-cinderfen` 9, and `smoke` 12.
- Passed: targeted hosted-preview repros for the run #17 deep-meta, deep-battle movement, pressure, layout, and smoke failures.
- Passed: local `npm run test:e2e:smoke` on rerun after one dev-server app-root navigation timeout in the long Cinderfen Crossing smoke test.
- Passed: local `npm run test:e2e:release` with 67 tests in 35.2m after the first invocation exceeded the local tool timeout.
- Passed: `git diff --check`, with only the existing Windows CRLF warning on `.github/workflows/ci.yml`.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect the same six hosted group jobs plus the unchanged `Release simulator`, now running release groups against production preview.

## v0.11.10 Hosted Release Matrix Determinism Fix - 2026-05-14

This checkpoint replaces the v0.11.9 hosted native 6-way release shards with explicit hosted release groups after GitHub Actions run #15 still failed across all hosted shards, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted failure audit: `docs/V1110_HOSTED_RELEASE_MATRIX_FAILURE_AUDIT.md`.
- Hosted determinism fix report: `docs/V1110_HOSTED_RELEASE_MATRIX_DETERMINISM_FIX.md`.
- Replaced hosted `test:e2e:release:hosted:shard1of6` through `shard6of6` scripts with explicit hosted group scripts for deep meta, deep battle, deep campaign plus pressure, layout core, layout Cinderfen, and smoke.
- Removed hosted `--fully-parallel` test-level sharding from the GitHub manual release matrix.
- Updated `.github/workflows/ci.yml` so manual `run_release_matrix` runs six named hosted groups with the existing 45-minute timeout plus the unchanged release simulator.
- Added `seedSaveBeforeAppBoot` for deterministic test-only localStorage seeding before app boot, and applied it to shared seeded campaign saves, Chapter 2 seed helpers, and deep-flow local seed setup.
- Applied the existing non-forced `clickReady` helper to additional hosted-problem launch/setup interactions and kept real actionability checks intact.
- Added one retry around the hosted-problem right-click movement command while preserving the `Moving` assertion.
- Tagged release tests into hosted groups totaling the same 67 tests as the full release lane.
- README, release checklist, developer command guide, release lane reliability plan, development checkpoint, and handoff updates.

### Verification

- Required gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser vendor warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, targeted remote-failure reproductions, all six hosted release groups, full `npm run test:e2e:smoke`, full `npm run test:e2e:release`, `npm run playtest:sim`, and `git diff --check`.
- Hosted release groups passed with 67 total Playwright tests split 12/11/7/16/9/12.
- Full release passed 67 tests in about 36.5m after the deterministic seed/actionability changes.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect jobs named `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, plus the unchanged `Release simulator` job.

## v0.11.9 Hosted Release Matrix Split and Timeout Fix - 2026-05-14

This checkpoint makes the manually triggered GitHub Actions release matrix smaller and more CI-realistic after hosted 3-way release shards timed out or hit Chromium context instability, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Hosted release matrix split audit: `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_AUDIT.md`.
- Hosted release matrix fix report: `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_FIX.md`.
- New additive package scripts: `npm run test:e2e:release:hosted:shard1of6` through `npm run test:e2e:release:hosted:shard6of6`, using Playwright test-level sharding with `--fully-parallel --workers=1`.
- GitHub Actions manual `run_release_matrix` now runs six hosted release shard jobs with a 45-minute per-shard timeout plus the unchanged release simulator.
- Existing local full release, 2-way shard, and 3-way shard scripts remain available and unchanged.
- Applied the existing non-forced `clickReady` helper to the two `menu-reset-save` clicks called out by hosted shard-1 evidence.
- Added a final real-main-menu readiness check after transient app-root navigation retries in the shared helper, accepting recovery only when the actual main menu controls are visible.
- README, release checklist, developer command guide, release lane reliability plan, development checkpoint, and handoff updates.

### Verification

- Required gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser vendor warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, full `npm run test:e2e:smoke`, all six hosted release shards, `npm run playtest:sim`, and `git diff --check`.
- Hosted 6-way release shards passed with 67 total Playwright tests split 12/11/11/11/11/11.
- The existing local 3-way shard scripts were not rerun in this pass because they are unchanged and the corrected hosted 6-way scripts exercised the same 67-test release suite.

### Next

- Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and expect six jobs named `shard-1-of-6` through `shard-6-of-6`, plus the unchanged `Release simulator` job.

## v0.11.8 Hosted Release Matrix Stability Fix - 2026-05-13

This checkpoint stabilizes the manually triggered GitHub Actions 3-way release matrix after Fast confidence, Optional visual QA, and the release simulator were green, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, release coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Release matrix stability report: `docs/V118_HOSTED_RELEASE_MATRIX_STABILITY_FIX.md`.
- Reload/navigation audit: `docs/V118_RELEASE_MATRIX_RELOAD_NAVIGATION_AUDIT.md`.
- Removed remaining Playwright `page.reload()` usage from e2e/visual QA by routing deep-flow and smoke persistence checks through the shared hosted-safe app-root navigation helper.
- Unified `deep-flow.spec.ts` synthetic save setup with the shared `gotoReadyMainMenu` path and Continue Campaign readiness checks.
- Hardened `gotoReadyMainMenu` with commit-stage navigation, three setup-navigation attempts, same-URL interruption handling, longer menu-readiness probes, and clearer retry diagnostics.
- Added a narrow `clickReady` helper for hosted actionability stalls without using force-clicks or weakening assertions.
- Applied `clickReady` to reported release-path interactions: Broken Ford selection/start, seeded skirmish starts, Cinderfen campaign node/start helpers, and Border Village campaign start paths.
- Added a scoped 120s budget to the seeded Cinderfen layout readability test after remote shard-2 evidence and a local full-release reproduction showed the 90s budget could expire during setup-navigation recovery.

### Verification

- Required gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, full `npm run test:e2e:smoke`, `npm run visual:qa`, `npm run smoke:preview`, targeted hosted-failure reproductions, full release, all 3 release shards, `npm run playtest:sim`, and `git diff --check`.
- Full release passed with 67 tests in about 36.5m after the final helper/timeout refinement.
- 3-way release shards passed: shard1 28 tests, shard2 27 tests, shard3 12 tests.

### Next

- Emmanuel should rerun the manual GitHub Actions `Run manual 3-way release shard matrix and simulator` workflow input and confirm shards 1, 2, and 3 are green with any setup-navigation/actionability retries logged and recovered.

## v0.11.7 Optional Visual QA Screenshot Stability Fix - 2026-05-13

This checkpoint stabilizes the manually triggered GitHub Actions `Optional visual QA` job after v0.11.6 fixed hosted navigation but exposed a hosted screenshot-capture hang, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, screenshot coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Visual QA screenshot stability report: `docs/V117_VISUAL_QA_SCREENSHOT_STABILITY_FIX.md`.
- Split `npm run visual:qa` from one monolithic 18-screenshot test into 5 smaller visual QA tests with fresh Playwright pages.
- Added per-screenshot `START`, `DONE`, `FAIL`, and `RETRY` logging with capture group, file name, viewport, URL, elapsed time, duration, and retry status.
- Added a 45s per-screenshot timeout, one retry for transient screenshot timeout/capture failures, and disabled animations/caret during screenshots.
- Expanded the generated visual QA index with capture groups and screenshot retry count/status.
- Preserved all 18 visual QA screenshot targets and unchanged browser console error failure behavior.

### Verification

- Full checkpoint gate passed: `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser warning, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, split `npm run visual:qa`, `npm run smoke:preview`, full `npm run test:e2e:smoke`, `npm run playtest:sim`, all 3 release shards, and `git diff --check`.
- Split `npm run visual:qa` passed with 5 tests, 18 screenshots, 0 browser console errors, and 0 screenshot retries.

### Next

- Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm the log reaches `DONE screenshot ... cinderfen-crossing-tablet.png`, the job shows 5 visual QA tests, and `visual-qa-latest/index.md` reports 18 screenshots and 0 browser console errors.

## v0.11.6 Optional Visual QA Hosted Navigation Fix - 2026-05-12

This checkpoint stabilizes the manually triggered GitHub Actions `Optional visual QA` job after v0.11.5 made automatic `Fast confidence` green, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, screenshot coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Visual QA hosted navigation report: `docs/V116_VISUAL_QA_HOSTED_NAVIGATION_FIX.md`.
- Narrow setup-navigation retry in `tests/e2e/shared-helpers.ts` for transient hosted-runner `net::ERR_ABORTED`, frame-detached, and setup-navigation timeout errors during `gotoReadyMainMenu`; timed-out navigation is accepted only if the real main menu is already visible.
- Scoped optional visual QA test budget increase from 240s to 420s for the single 18-screenshot capture pass.
- All 18 visual QA screenshot targets, browser console error collection, and human-reviewed non-pixel-perfect policy remain unchanged.
- Release checklist, development checkpoint, and handoff updates.

### Verification

- Required local gate: `npm test`, `npm run build`, `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, `npm run visual:qa`, `npm run smoke:preview`, full `npm run test:e2e:smoke`, `npm run playtest:sim`, 3-way release shards, and `git diff --check` passed.

### Next

- Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm it uploads `visual-qa-latest` with `index.md`, 18 screenshots, and 0 browser console errors.

## v0.11.5 GitHub Actions Fast Confidence Lane Split - 2026-05-12

This checkpoint splits automatic GitHub browser confidence from the full smoke/release lanes without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, workflow coverage strength, maps, units, factions, rewards, or UI design.

### Included

- Fast-confidence lane split report: `docs/V115_FAST_CONFIDENCE_LANE_SPLIT.md`.
- New package script: `npm run test:e2e:smoke:fast`.
- Smoke test title tags:
  - `@ci-fast` for the six automatic fast-confidence checks.
  - `@extended-smoke` for the six longer campaign/skirmish smoke checks.
- GitHub Actions automatic `Fast confidence` now runs `npm run test:e2e:smoke:fast` instead of the full smoke suite.
- Full `npm run test:e2e:smoke`, full release, release shards, manual workflow lanes, and local final gates remain coverage-preserving.
- README, release checklist, developer command guide, release lane reliability plan, development checkpoint, and handoff updates.

### Verification

- Script inventory: `npm run test:e2e:smoke:fast -- --list` lists 6 tests; `npm run test:e2e:smoke -- --list` lists all 12 tests.
- Required local gate: `npm test` passed with 46 files / 351 tests; build passed with the known Phaser warning; `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke:fast`, full `npm run test:e2e:smoke`, `npm run smoke:preview`, full release, 3-way release shards, `visual:qa`, `playtest:sim`, and `git diff --check` passed.

### Next

- Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after this commit is pushed and confirm the e2e step runs `npm run test:e2e:smoke:fast`.
- Use full local smoke, manual release shards, or full release for the extended campaign/skirmish smoke coverage.

## v0.11.4 GitHub Actions Smoke Seed/Reload Stability Fix - 2026-05-12

This checkpoint stabilizes seeded campaign/skirmish smoke setup after the first v0.11.3 GitHub Actions `Fast confidence` rerun, without changing gameplay, content, tutorial behavior, save format, campaign progression, balance, visual assets, runtime art, workflow coverage, maps, units, factions, rewards, or UI design.

### Included

- Seed/reload smoke fix report: `docs/V114_FAST_CONFIDENCE_SEED_RELOAD_FIX.md`.
- Stable seeded-save setup in `tests/e2e/shared-helpers.ts`: boot to a ready main menu before localStorage mutation, navigate with `page.goto("/")` after writing storage instead of `page.reload()`, and verify seeded saves enable Continue Campaign.
- Chapter 2 seed helpers now use the same stable storage setup path for post-Ashen, post-Crossing, and completed-route saves.
- A narrowly scoped 60s timeout for only `skirmish difficulty selection changes fog and starting pressure`, justified by hosted CI evidence and a local traced run that took 44.9s after the safer seeded setup.
- Handoff, development checkpoint, and release-checklist updates.

### Verification

- Pre-fix local smoke passed: `npm run test:e2e:smoke`, 12 tests in about 5.0m.
- Pre-fix targeted runs passed locally for the reported post-Ashen, post-Crossing, skirmish difficulty, Border Village, and Broken Ford smoke paths, supporting a seed/reload CI stability diagnosis rather than a deterministic gameplay failure.
- Post-fix focused gate: `npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish difficulty selection changes fog and starting pressure" --retries=1 --trace=on` passed in 44.9s during the first post-helper run and 32.7s during the final focused gate.
- Required local gate: `npm test` passed with 46 files / 351 tests; build passed with the known Phaser warning; `validate:content`, `validate:art-intake`, all five reported focused smoke paths, `npm run test:e2e:smoke`, `npm run smoke:preview`, full release, 3-way release shards, `visual:qa`, `playtest:sim`, and `git diff --check` passed.
- One first-pass local `release:shard2of3` run hit a timeout in the enemy-pressure tutorial/skirmish guard test after 26/27 tests passed; the exact test passed on targeted rerun and the full shard passed on rerun, so no coverage was changed for that release-lane transient.

### Next

- Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after this commit is pushed and confirm the seeded campaign/skirmish smoke paths no longer fail around localStorage seed/reload.
- Treat the reported Border Village and Broken Ford failures as likely cascade/flaky context fallout unless the next hosted run shows fresh independent failures after seeded setup succeeds.

## v0.11.3 GitHub Actions Fast Confidence Smoke Fix - 2026-05-12

This checkpoint fixes the first reported remote GitHub Actions `Fast confidence` smoke timeout without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, workflow coverage, maps, units, factions, rewards, or UI design.

### Included

- Fast-confidence smoke fix report: `docs/V113_FAST_CONFIDENCE_SMOKE_FIX.md`.
- Settings accessibility smoke robustness in `tests/e2e/smoke.spec.ts`.
- A settings range-control helper that waits for the Settings scene's DOM re-rendered control state before continuing.
- Explicit state assertions after settings accessibility/fog controls change.
- A narrowly scoped 60s timeout for only `settings screen persists accessibility options`, justified by GitHub Actions evidence that the combined settings-persistence plus in-battle runtime-application smoke path exceeded the global 35s budget on the hosted runner.
- Handoff, development checkpoint, and release-checklist updates.

### Verification

- Focused reproduction before the fix: local full smoke passed, focused settings passed but consumed 23.6s of the 35s budget, and a serial 3x settings repeat passed at 22.4s, 23.8s, and 24.1s.
- Post-fix focused gate: `npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on` passed in 26.8s.
- Post-fix focused gate: `npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on` passed in 16.7s.
- Required local gate: `npm test` passed with 46 files / 351 tests; build passed with the known Phaser warning; `validate:content`, `validate:art-intake`, `npm run test:e2e:smoke`, `npm run smoke:preview`, full release, 3-way release shards, `visual:qa`, `playtest:sim`, and `git diff --check` passed.

### Next

- Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after this commit is pushed and confirm the settings accessibility smoke test no longer times out.
- Treat the previous Border Village `browser.newContext` failure as a likely cascade unless the next hosted run shows a fresh independent failure.

## v0.11.2 GitHub Actions Remote CI Observation and Timeout Tuning - 2026-05-11

This checkpoint documents remote GitHub Actions observation limits and CI no-change decisions without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, workflow YAML, helper code, Playwright coverage, maps, units, factions, rewards, or UI design.

### Included

- Remote CI observation capability report: `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`.
- GitHub Actions evidence limitation report: `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`.
- Static workflow review: `docs/V112_WORKFLOW_STATIC_REVIEW.md`.
- CI timeout tuning review: `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`.
- Preview helper remote portability review: `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`.
- CI artifact remote review: `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`.
- Manual GitHub Actions checklist for Emmanuel: `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`.
- CI no-fix decision: `docs/V112_CI_NO_FIX_DECISION.md`.
- v0.11.2 report: `docs/V112_REMOTE_CI_OBSERVATION_REPORT.md`.
- README, release checklist, roadmap, development checkpoint, and handoff updates.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed.
- Tooling gates: `npm run test:e2e:smoke` passed.
- Preview helper gates: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Artifact review/report gates: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Emmanuel should use `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` to capture authenticated GitHub Actions evidence.
- If GitHub UI evidence shows a real CI-only issue, run v0.11.3 GitHub Actions Evidence Follow-Up and Minimal Tuning.
- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.

## v0.11.1 CI Release Matrix Dry-Run and Preview Helper Portability - 2026-05-11

This checkpoint adds a conservative GitHub Actions CI dry-run and CI/release documentation without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, maps, units, factions, rewards, Playwright coverage, or UI design.

### Included

- CI matrix audit: `docs/V111_CI_MATRIX_AUDIT.md`.
- Preview helper portability audit: `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`.
- Small `npm run smoke:preview` portability improvements in `tools/smokePreview.ts`.
- CI release matrix plan: `docs/V111_CI_RELEASE_MATRIX_PLAN.md`.
- Conservative GitHub Actions workflow: `.github/workflows/ci.yml`.
- CI artifact strategy: `docs/V111_CI_ARTIFACT_STRATEGY.md`.
- CI/local parity check: `docs/V111_CI_LOCAL_PARITY_CHECK.md`.
- v0.11.1 report: `docs/V111_CI_RELEASE_MATRIX_REPORT.md`.
- README, release checklist, developer command guide, roadmap, development checkpoint, and handoff updates.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed.
- Tooling gates: `npm run test:e2e:smoke` passed.
- Preview helper gates: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Report gate: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Validate the pushed GitHub Actions workflow on GitHub before treating remote CI as proven.
- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.
- If neither is available, the next safe autonomous goal is v0.11.2 GitHub Actions Remote CI Observation and Timeout Tuning.

## v0.11 Technical Reliability, E2E Runtime, and Performance Gate - 2026-05-11

This checkpoint improves release reliability documentation, e2e runtime clarity, preview smoke repeatability, optional visual QA reporting, bundle/performance measurement, developer command ergonomics, and release-checklist maintainability without changing gameplay, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, maps, units, factions, rewards, or UI design.

### Included

- E2E runtime audit refresh: `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`.
- Release lane reliability plan: `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`.
- Automated production preview smoke helper: `npm run smoke:preview`, backed by `tools/smokePreview.ts`.
- Preview smoke reliability notes: `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`.
- Visual QA index/summary improvement plus `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`.
- Bundle/performance refresh: `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`.
- Developer command guide: `docs/DEVELOPER_COMMAND_GUIDE.md`.
- Tightened release checklist and v0.11 report: `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with the template-only empty intake.
- Preview helper gate: `npm run smoke:preview` passed with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.
- Visual QA gate: `npm run visual:qa` passed with 18 indexed screenshots and 0 recorded browser console errors.
- E2E smoke gate: `npm run test:e2e:smoke` passed.
- Phase/report gates: `git diff --check` passed.

### Next

- If Emmanuel provides tutorial feedback, run v0.10.1 Tutorial v2 Human-Feedback Polish.
- If source/license-documented candidate art exists, run v0.9.2 Controlled Cinderfen Style-Frame Candidate Review.
- If neither is available, the next safe autonomous goal is v0.11.1 CI Release Matrix Dry-Run and Preview Helper Portability.

## v0.10 Tutorial v2 Onboarding Refinement - 2026-05-11

This checkpoint refines Tutorial / Proving Grounds onboarding clarity, pacing documentation, overlay hierarchy, no-reward completion messaging, e2e lane documentation, visual QA review, and Emmanuel's manual playtest checklist without adding maps, units, factions, workers, enemy construction, economy AI, rewards, save persistence, campaign progression, generated art, imported art, runtime art replacement, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Tutorial v2 audit: `docs/V10_TUTORIAL_V2_AUDIT.md`.
- Tutorial pacing and scope plan: `docs/V10_TUTORIAL_V2_PACING_PLAN.md`.
- Tutorial copy refinement in `src/game/data/tutorials.ts` plus `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`.
- Small tutorial overlay hierarchy refinement in `src/game/ui/hudPanels/TutorialPanel.ts` and `src/game/styles/battle-feedback.css` plus `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`.
- Completion/no-reward clarity in the battle and main-menu handoff plus `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`.
- Tutorial e2e lane review: `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`.
- Tutorial visual QA review: `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.
- Manual Tutorial v2 playtest checklist for Emmanuel: `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`.
- v0.10 report: `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with the template-only empty intake.
- Tutorial source/UI gates: `npm run test:e2e:smoke` passed.
- Layout gate: `npm run test:e2e:layout` passed.
- E2E lane review: `npm run test:e2e:release` passed with 67 Playwright tests.
- Visual review: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Final gate: full smoke/release, 2-way shards, 3-way shards, visual QA, simulator, diff check, and production preview smoke passed.
- Phase gates: `git diff --check` passed.

### Next

- Recommended immediate human step: Emmanuel should run `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md` and report confusing steps, screenshots, 1-5 ratings, and whether no-reward completion feels acceptable.
- Recommended next player-facing goal after feedback: v0.10.1 Tutorial v2 human-feedback polish, still no rewards, persistence, maps, units, factions, art replacement, or broad UI redesign.
- Recommended visual goal remains v0.9.2 Controlled Cinderfen Style-Frame Candidate Review only after source/license-documented candidate images exist.

## v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review - 2026-05-10

This checkpoint creates the safe non-runtime intake pipeline for future Cinderfen style-frame candidates. It adds review folders, source/license metadata templates, review manifest schema/types, metadata-only validation, a candidate scan, screenshot comparison planning, Emmanuel's manual preparation guide, and a future v0.9.2 review brief without adding generated art, imported assets, candidate binaries, runtime art, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Intake protocol: `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`.
- Non-runtime review folder structure under `art-review/`.
- Source/license metadata guide and templates: `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`, and `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`.
- Review manifest schema and tooling-only types: `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md` and `tools/art-intake/StyleFrameReviewManifestTypes.ts`.
- Metadata-only validation: `npm run validate:art-intake`, `tools/art-intake/validateArtIntake.ts`, and `tools/art-intake/validateArtIntake.test.ts`.
- Current candidate scan: `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`.
- Screenshot comparison plan: `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`.
- Manual preparation guide for Emmanuel: `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`.
- Future review brief: `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`.
- v0.9.1 report: `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 46 test files and 351 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `npm run validate:art-intake` passed with a template-only intake.
- Report gate: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.
- Phase/report gates: `git diff --check` passed.

### Next

- Recommended next goal: v0.9.2 Controlled Cinderfen Style-Frame Candidate Review, only after Emmanuel provides source/license-documented candidates.
- Keep the next step non-runtime: validate metadata, reject unsafe candidates, catalogue safe candidates as reference/candidate only, run visual QA, and create a side-by-side human review.
- Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.9 Controlled Cinderfen Style-Frame Sprint - 2026-05-10

This checkpoint creates a docs/specs/prompts-only Cinderfen visual style-frame package before any art generation or runtime replacement. It defines the future ash-glass wetland identity, material language, shrine landmark direction, Ashen outpost architecture, unit/building scale standards, prompt pack, manifest templates, screenshot acceptance criteria, and future replacement sequence without adding generated art, imported assets, runtime art, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Cinderfen style-frame research packet: `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`.
- Cinderfen visual pillars: `docs/V09_CINDERFEN_VISUAL_PILLARS.md`.
- Terrain material sheet spec: `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`.
- Cinder Shrine/capture-site landmark spec: `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`.
- Ashen outpost architecture spec: `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`.
- Unit/building scale reference: `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`.
- Cinderfen style-frame prompt pack: `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`.
- Future Cinderfen manifest templates: `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`.
- Screenshot acceptance criteria: `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`.
- Future visual replacement implementation plan: `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`.
- v0.9 report: `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.

### Verification

- Phase gates: `npm test` passed with 45 test files and 340 tests.
- Phase gates: `npm run build` passed with the known Phaser vendor large-chunk warning.
- Phase gates: `npm run validate:content` passed.
- Phase gates: `git diff --check` passed.
- Report gate: `npm run visual:qa` passed with 18 indexed review screenshots and zero recorded browser console errors.
- Report gate: `npm run playtest:sim` passed with 255 simulated runs across 85 campaign battle nodes.

### Next

- Recommended next goal: v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review.
- Keep the next step non-runtime first: obtain 1 to 3 style-frame candidates, record source/license metadata, track as reference/candidate only, validate, run visual QA, and write a human source/screenshot review.
- Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion - 2026-05-10

This checkpoint hardens the visual asset pipeline by reviewing source/license risk, adding conservative source-review metadata, strengthening manifest validation, expanding optional screenshot QA coverage, and preparing a safe v0.9 visual direction without adding art, generated images, external assets, large binaries, gameplay content, new maps, new units, new factions, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Source/license review plan: `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`.
- Asset source/license audit: `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`.
- Manifest metadata refinement with `reviewStatus` and `sourceReviewNotes`.
- Manifest validation hardening for production approval, runtime/reference conflicts, deprecated runtime assets, critical replacement notes, and production-safe source/license requirements.
- Screenshot coverage expansion plan: `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`.
- Expanded optional `npm run visual:qa` harness from 10 to 18 indexed screenshots, including Asset Gallery, Hero Inventory, tutorial mobile, route-complete campaign map, Cinderfen Crossing tablet, Crossing pressure warning, victory Results, and defeat Results.
- Extended screenshot review: `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`.
- Visual risk register: `docs/VISUAL_RISK_REGISTER.md`.
- v0.9 controlled visual sprint brief: `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`.
- v0.8.2 report: `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 340 tests during phase/report gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase/report gates.
- `npm run validate:content`: passed with gameplay content and hardened visual asset metadata validation.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during screenshot/report gates.
- `npm run visual:qa`: passed with 18 indexed review screenshots and zero recorded browser console errors.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the report gate.
- `git diff --check`: passed during phase/report gates.

### Next

- Recommended next goal: v0.9 Controlled Cinderfen Style-Frame Sprint.
- Keep the first v0.9 visual step docs/specs/prompts-only: terrain material sheet, Cinder Shrine/capture-site landmark sheet, and Ashen outpost architecture sheet.
- Do not generate, import, download, commit, or wire runtime art assets until a future goal explicitly scopes source/license metadata, manifest updates, validation, and before/after screenshot QA.

## v0.8.1 Visual Asset Manifest and Screenshot QA Gate - 2026-05-10

This checkpoint creates the visual asset manifest, metadata validation, runtime asset cross-check, and non-brittle screenshot QA foundation without adding final art, generated art, external assets, large binaries, gameplay content, new maps, new units, new factions, workers, enemy construction, economy AI, rewards, save changes, campaign progression, desktop packaging, engine switching, a graphics overhaul, or broad systems.

### Included

- Existing asset inventory audit across `public/assets/`, manual/final/runtime assets, loader references, and source usage.
- Typed visual asset manifest schema and 89-entry initial manifest covering runtime assets, manual source originals, procedural terrain debt, and future prompt/spec references.
- Visual asset metadata validation integrated into `npm run validate:content`, including runtime file existence checks in the CLI path.
- Runtime asset usage cross-check for battle textures, ability icons, UI-kit CSS assets, faction emblem, and screen backgrounds.
- Optional screenshot QA harness: `npm run visual:qa`, backed by `playwright.visual-qa.config.ts` and `tests/visual-qa/visual-qa.spec.ts`.
- Ignored screenshot output under `/visual-qa/`, with generated review index and zero pixel-perfect assertions.
- Screenshot QA review for main menu, tutorial, campaign map, skirmish setup, Cinderfen Crossing, Cinder Shrine capture, Cinderfen Watch, and Watch pressure warning.
- Cinderfen visual asset replacement backlog.
- Safe future asset prompt/spec templates.
- v0.8.1 report: `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 339 tests during the final gate.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during the final gate.
- `npm run validate:content`: passed with gameplay content and visual asset metadata validation.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during the final gate.
- `npm run test:e2e:release`: passed with 67 Playwright tests during the final gate.
- `npm run test:e2e:release:shard1`: passed with 55 Playwright tests during the final gate.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests during the final gate.
- `npm run test:e2e:release:shard1of3`: passed with 28 Playwright tests during the final gate.
- `npm run test:e2e:release:shard2of3`: passed with 27 Playwright tests during the final gate.
- `npm run test:e2e:release:shard3of3`: passed with 12 Playwright tests during the final gate.
- `npm run visual:qa`: passed with 10 generated review screenshots and zero recorded browser console errors.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the final gate.
- Production preview smoke: passed at `http://127.0.0.1:57934/` with title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors verified.
- `git diff --check`: passed during the final gate.

### Next

- Recommended next goal: v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion.
- Keep future visual work manifest-backed, source/license-reviewed, and screenshot-QA reviewed before committing binary replacements.
- Tutorial v2 onboarding refinement remains the safest player-facing alternative.

## v0.8 Technical Performance, E2E Runtime, and Visual Foundation Gate - 2026-05-10

This checkpoint refreshes technical performance/e2e runtime facts and creates a disciplined visual foundation without adding workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, desktop packaging, engine switching, external generated assets, large binary assets, a full UI redesign, a graphics overhaul, or broad systems.

### Included

- Refreshed performance and bundle audit with current app JS, Phaser vendor, CSS, gzip sizes, analyzer findings, and production-leak scan.
- E2E runtime and shard imbalance audit for the 67-test release suite.
- Additive optional 3-shard release scripts: `test:e2e:release:shard1of3`, `test:e2e:release:shard2of3`, and `test:e2e:release:shard3of3`.
- Visual debt audit covering terrain, roads, water/swamp, capture sites, units, buildings, minimap, HUD, and style mismatch.
- Visual scale/readability audit covering hero/unit/building/capture-site/minimap/camera/fog/pathfinding scale rules.
- Explicit no-code visual readability decision for v0.8.
- 2026 art direction bible for future original dark heroic fantasy RTS/RPG visuals.
- Asset pipeline plan for future source/license/status/scale metadata.
- Cinderfen visual rework spec with future identity, readability requirements, art prompt templates, and implementation phases.
- v0.8 report: `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during phase gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase gates.
- `npm run validate:content`: passed during phase gates.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 6.1m during the visual readability gate.
- `npm run test:e2e:layout`: first attempt hit the command timeout with no failing-test output; after cleaning repo-local leftover Playwright/Vite Node processes and rerunning with a longer timeout, passed with 25 Playwright tests in 14.9m.
- `npm run test:e2e:release:shard1of3`: passed with 28 Playwright tests in 12.3m.
- `npm run test:e2e:release:shard2of3`: passed with 27 Playwright tests in 14.9m.
- `npm run test:e2e:release:shard3of3`: passed with 12 Playwright tests in 5.3m.
- Report-gate `npm run test:e2e:smoke`: passed with 12 Playwright tests in 6.3m.
- Report-gate `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: passed during phase gates.

### Next

- Recommended next goal: v0.8.1 Visual Asset Manifest and Screenshot QA Gate, with no new assets or graphics overhaul.
- Alternative player-facing goal: Tutorial v2 onboarding refinement.
- Keep pressure-specific work blocked on manual feedback and simulator-only first experiments; do not promote live reinforcement, route contesting, or defensive hold behavior yet.

## v0.7.3 Real-Input Cinderfen Pressure Playtest - 2026-05-09

This checkpoint reviews Cinderfen pressure with controlled browser input and simulator evidence without expanding Enemy Strategic Pressure into workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Real-input pressure playtest protocol and seeded browser setup notes.
- Controlled browser-input review for Cinderfen Crossing, including natural Cinder Shrine capture and seeded delayed-warning visibility evidence.
- Controlled browser-input review for Cinderfen Watch, including natural Watch Road capture, immediate warning visibility, delayed warning visibility, and pressure-priority protection against generic status churn.
- Strategy-profile pressure review for Safe Beginner, Greedy Economy, Fast Army, and Retinue + Training Yard II.
- Manual Cinderfen pressure checklist for Emmanuel with 1 to 5 ratings for warning clarity, timing, fairness, usefulness, fun, and frustration.
- Explicit evidence-backed no-change decision: no pressure copy, timing, status-duration, defeat-tip, telemetry, e2e, scope, wave-nudge, or balance change.
- v0.8 direction brief recommending technical performance/e2e runtime work before any pressure-specific simulator-only reinforcement experiment.
- v0.7.3 report: `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during phase gates.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during phase gates.
- `npm run validate:content`: passed during phase gates.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests during pressure review/polish/report gates.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during pressure review/polish/report gates.
- Pressure telemetry remains 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed during phase gates.

### Next

- Recommended next goal: v0.8 technical performance/e2e runtime pass, with Tutorial v2 onboarding refinement as the safer player-facing alternative.
- Emmanuel should still run the manual pressure checklist before any pressure-specific v0.8 work.
- If pressure work resumes, start with simulator-only `reinforce_next_wave`; do not promote live reinforcement, route contesting, defensive hold behavior, workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, or broad systems.

## v0.7.2 Human-Paced Cinderfen Pressure Review - 2026-05-09

This checkpoint reviews Cinderfen pressure feel and warning readability without expanding Enemy Strategic Pressure into workers, enemy construction, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Human-paced pressure review protocol and browser review notes.
- Seeded browser evidence and screenshot inspection for Cinderfen Crossing pressure warnings.
- Seeded browser evidence and screenshot inspection for Cinderfen Watch pressure warnings.
- Explicit no-change pressure readability decision: no warning copy, timing, status-duration, defeat-tip, telemetry, e2e, scope, or wave-nudge change.
- Retinue + Training Yard II pressure review documented as a saved-progress power watchpoint, not a pressure bug.
- Greedy Economy and Fast Army pressure review with no tuning applied.
- Fresh next-action decision keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- v0.7.2 report: `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests during the report gate.
- `npm run build`: passed with the known Phaser vendor large-chunk warning during the report gate.
- `npm run validate:content`: passed during the report gate.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.2m during the report gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes during the report gate.
- Pressure telemetry remains 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed during the report gate.

### Next

- Recommended next goal: v0.7.3 real-input Cinderfen pressure playtest.
- Focus on warning noticeability during actual unit commands, Cinder Shrine salience, Watch Road fairness, Greedy Economy timeout clarity, Fast Army quick-clear feel, and Retinue + Training Yard II power.
- Only after stronger human evidence should v0.8 consider a simulator-only `reinforce_next_wave` experiment.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, broad systems, live reinforcements, capture-site contest AI, and defensive-hold behavior.

## v0.7.1 Enemy Pressure Feel Review and Warning Polish - 2026-05-09

This checkpoint reviews, polishes, and hardens Enemy Strategic Pressure V1 without expanding it into real enemy construction, workers, economy AI, new maps, new units, new factions, rewards, save changes, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

### Included

- Pressure feel audit for Cinderfen Crossing and Cinderfen Watch.
- Clearer pressure warning copy and pressure-specific defeat tips.
- Pressure battle-status priority with a longer read window.
- Objective battle-status priority above pressure so `Cinder Shrine Surge` and capture feedback stay readable.
- Focused pressure e2e hardening for visible warning priority, Tutorial no-pressure protection, and skirmish no-pressure protection.
- Clearer simulator report wording with readable pressure plan/stage labels, triggered/quiet run counts, and per-strategy pressure reads.
- Pressure balance review with no tuning applied.
- Action promotion gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- v0.7.1 report: `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.

### Verification

- `npm test`: passed with 45 test files and 334 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.3m during the final gate.
- Focused pressure e2e: passed with 2 Playwright tests in 43.1s during visibility hardening.
- `npm run test:e2e:release`: passed with 67 Playwright tests in 32.9m during the final gate.
- `npm run test:e2e:release:shard1`: passed with 55 Playwright tests in 28.2m during the final gate.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 5.0m during the final gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- Pressure telemetry: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- Production preview smoke: passed at `http://127.0.0.1:57931/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.
- `git diff --check`: passed.

### Next

- Human-play Cinderfen Crossing and Cinderfen Watch to judge warning salience and fairness.
- Keep follow-up limited to copy, timing, scope, telemetry, or a simulator-first tiny combat experiment only if human evidence justifies it.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, broad systems, live reinforcements, capture-site contest AI, and defensive-hold behavior.

## v0.7 Enemy Strategic Pressure V1 - 2026-05-09

This checkpoint adds the first controlled enemy commander pressure prototype. It preserves the frozen v0.3 Cinderfen Route Baseline, v0.3.1 polish layer, v0.4 technical groundwork, v0.5 safety gate, v0.6 tutorial foundation, and v0.6.1 tutorial feel polish. It does not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

### Included

- Enemy Strategic Pressure research audit, design spec, and final report.
- Data model and metadata for `causeway_contest_pressure` and `ashen_watch_captain_pressure`.
- Content validation for pressure plan ids, stage ids, map/node references, trigger/action types, unit references, capture-site references, and forbidden worker/construction/economy fields.
- Campaign-only runtime pressure tracker for Cinderfen Crossing and Cinderfen Watch.
- Existing battle status warning copy and pressure-specific battle stats/telemetry.
- One safe existing-wave timing nudge; reinforcement, contest, and defensive-hold actions remain warning/telemetry-only.
- Pressure-aware defeat tip copy only when pressure actually triggered.
- Simulator telemetry and generated pressure balance-gate reporting.
- Targeted Playwright release coverage for Cinderfen Watch pressure and Tutorial/skirmish no-pressure guards.

### Verification

- `npm test`: passed with 44 test files and 328 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.4m during the balance gate.
- Focused pressure e2e: passed with 2 Playwright tests in 49.4s.
- `npm run test:e2e:release`: passed with 67 Playwright tests in 29.4m during the e2e coverage gate.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- Pressure telemetry: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 warnings, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.
- `git diff --check`: passed.

### Next

- Human-play Cinderfen Crossing and Cinderfen Watch for pressure warning salience and fairness.
- Keep follow-up limited to copy, timing, scope, telemetry, or a tiny combat effect only if human evidence justifies it.
- Continue postponing workers, real enemy construction, dynamic enemy economy, new maps, new units, new factions, rewards, save changes, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems.

## v0.6.1 Tutorial Feel Polish - 2026-05-09

This checkpoint finishes a small Browser-evidenced Tutorial / Proving Grounds feel pass. It preserves the existing no-reward, non-persistent tutorial shell and does not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

### Included

- Visible Browser review of main-menu Tutorial entry, desktop first objective, mobile-short first objective, Exit Tutorial, and console output.
- New review doc: `docs/V061_TUTORIAL_FEEL_REVIEW.md`.
- Mobile-short overlay priority polish so the tutorial panel renders above transient battle feedback instead of being interrupted by the battle status banner.
- Responsive layout assertion that protects tutorial overlay z-index priority over battle status feedback.
- v0.6.1 updates to the tutorial polish plan, readability surrogate review, and tutorial feel audit.

### Verification

- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:layout -- --grep "tutorial entry"`: passed with 4 Playwright tests in 43.2s.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 4.9m.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.4m.
- Production preview Browser smoke: passed at `http://127.0.0.1:57919/`; title, Tutorial launch/exit, first overlay, and zero browser warnings/errors were verified.

### Next

- Human-play the full twelve-step tutorial at normal speed before adding any tutorial content.
- Keep future follow-up limited to readability, overlay hierarchy, and no-reward completion clarity unless a narrow verified bug appears.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems.

## v0.6 Tutorial Onboarding And Testing Foundation - 2026-05-08

This checkpoint polishes and hardens the playable Tutorial / Proving Grounds shell while preserving the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward tutorial policy. It does not add rewards, save-version changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, campaign progression, or broad systems.

### Included

- Tutorial human-feel surrogate audit.
- Tutorial copy tightening and hierarchy polish.
- Mobile-short overlay width and footer layout polish.
- Session-only no-reward completion notice on the main menu.
- Tutorial e2e runtime placement review keeping full completion in smoke for now.
- Test-only semantic command-log V1 helper used by exactly one tutorial completion smoke path.
- Command-log V1 plan and report.
- Tutorial accessibility checks for polite live-region semantics, described instruction/condition text, and explicit button labels.
- Desktop/2026 visual-direction plan, planning only.
- v0.6 onboarding/testing foundation report.

### Verification

- Phase 11 report gate and final full verification passed.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 4.8m during the final gate.
- `npm run test:e2e:layout`: passed with 25 Playwright tests in 12.5m after accessibility polish.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.9m during the final gate.
- `npm run test:e2e:release:shard1`: passed with 53 Playwright tests in 24.0m.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 4.9m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57918/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Recommended next long-running goal: human-paced Tutorial / Proving Grounds review and small v0.6.1 tutorial feel polish.
- Keep command-log V1 test-only and at one consumer unless a concrete second test path needs it.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems until their gates are explicit and green.

## Tutorial / Proving Grounds Playable Shell - 2026-05-08

This checkpoint implements the first playable Tutorial / Proving Grounds shell on top of the v0.5 safety gate. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It does not add rewards, save-version changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, campaign progression, or broad systems.

### Included

- Main-menu Tutorial launch surface.
- Validated playable tutorial metadata for `proving_grounds_basics`.
- Dedicated `tutorial` battle launch mode with rewards disabled.
- Existing-content Tutorial / Proving Grounds shell on `first_claim` using transient Warlord Aster data.
- Lightweight tutorial HUD overlay with current objective, instruction, hint, progress, completion condition, Next Objective, Complete Tutorial, and Exit Tutorial.
- Linear twelve-step objective model for camera, selection, movement, capture, resources, Command Hall, Barracks, Militia, rally point, Rally Banner, safe pressure, and completion.
- Non-persistent no-reward completion and exit paths back to the main menu.
- XP/veterancy guard for rewards-disabled tutorial kills.
- Save/persistence audit, tutorial content-validation gate, readability surrogate review, and playable-shell report.
- Unit, content-validation, smoke e2e, and layout e2e coverage for the tutorial shell.

### Verification

- Phase 12 report verification and final full gate passed.
- `npm test`: passed with 42 test files and 315 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 Playwright tests in 5.2m.
- `npm run test:e2e:release`: passed with 65 Playwright tests in 28.5m.
- `npm run test:e2e:release:shard1`: passed with 53 Playwright tests in 24.4m.
- `npm run test:e2e:release:shard2`: passed with 12 Playwright tests in 4.9m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes and no telemetry diff.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57916/`; title, main menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Human-play Tutorial / Proving Grounds for length, clarity, mobile readability, building/training/rally timing, and no-reward completion clarity.
- Keep follow-up polish small: copy tightening, overlay hierarchy, completion clarity, and layout spacing only.
- Continue postponing rewards, campaign integration, save persistence, new maps, new units, new factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, and broad systems until their gates are explicit and green.

## v0.5 Save Content Validation Gate - 2026-05-08

This checkpoint builds the v0.5 safety foundation before broad mechanics or new content expansion. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork. It does not add playable tutorial content, gameplay balance changes, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization code, or broad army-management systems.

### Included

- File-backed save fixtures and test utilities under `tests/fixtures/saves/`.
- Fixture-based save migration and normalization tests for V1, V2, settings-only, invalid JSON, affixed inventory, legacy equipment, campaign progress, retinue, rivals, trophies, Chapter 2, and Cinderfen route state.
- Expanded save compatibility documentation and current save-version policy; save version remains `2`.
- Stronger content validation for campaign graph references, maps, reward tables, repeat rewards, event/town effects, modifiers, map objectives, enemy AI references, and tutorial metadata.
- Standalone `npm run validate:content` gate.
- Campaign graph and reward economy report.
- Command-log replay feasibility study recommending a future test-only semantic replay slice, not production replay.
- Simulator determinism report and tests locking the simulator matrix/schema and deterministic summary behavior.
- Candidate A, Tutorial / Proving Grounds, selected as the future vertical-slice candidate.
- Tutorial / Proving Grounds design brief plus a non-playable metadata-only scaffold.

### Verification

- Phase 14 documentation-gate verification passed.
- `npm test`: passed with 40 test files and 298 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests in 4.5m.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 28.4m.
- `npm run test:e2e:release:shard1`: passed with 49 Playwright tests in 23.9m.
- `npm run test:e2e:release:shard2`: passed with 10 Playwright tests in 4.4m.
- `npm run playtest:sim`: passed with 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57915/`; title, main menu copy, New Campaign, Continue Campaign, Skirmish Setup, and zero browser console errors were verified.

### Next

- Recommended next long-running goal after full v0.5 verification: implement the first Tutorial / Proving Grounds playable shell using existing content only.
- Keep the first tutorial implementation non-rewarding, validation-first, and save-compatible.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Overnight Autonomous Progress Checkpoint - 2026-05-08

This checkpoint completes the extended v0.4 technical, UX, save-safety, route-review, and planning pass while preserving the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not add gameplay, change balance, alter save format, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization code, or broad systems.

### Included

- Bundle analyzer report refreshed and the current production chunks documented.
- Test/dev hook production audit refreshed; no accidental large production leak was found.
- Analyzer-backed optimization decision recorded as no additional code optimization.
- E2E sharding plan and scripts verified while preserving the full 59-test release gate.
- One test-only rally wait in `tests/e2e/deep-flow.spec.ts` hardened against timing flake without changing gameplay.
- Settings readability copy clarified for colorblind minimap team markers and small-screen command-panel guidance.
- Save compatibility audited in `docs/SAVE_COMPATIBILITY_AUDIT.md`, with one new test preserving valid Chapter 2 selected chapter/node state.
- Automated route-feel surrogate review added in `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md`.
- Full-game architecture docs expanded for fifteen future-system tracks, including modding/data-driven content, tutorial/onboarding, monetization/packaging, and recommended order.
- Tiny no-gameplay polish backlog added in `docs/V04_POLISH_BACKLOG.md`.

### Verification

- `npm test`: passed with 38 test files and 271 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests in 4.6m.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 27.8m.
- `npm run test:e2e:release:shard1`: passed with 49 Playwright tests in 23.0m.
- `npm run test:e2e:release:shard2`: passed with 10 Playwright tests in 4.2m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57911/`; main menu, New Campaign, Continue Campaign, Skirmish Setup, and browser console error checks passed.

### Next

- Recommended next long-running goal: v0.5 save/content-validation gate.
- Add fixture-based migration tests, future content validation rules, deterministic command-log feasibility notes, and one explicitly approved vertical-slice candidate before broad mechanics.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Autonomous Goal Progress Checkpoint - 2026-05-07

This checkpoint advances v0.4 technical/readability planning while preserving the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It does not add gameplay, change balance, alter saves, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, or broad systems.

### Included

- Settings readability/accessibility polish: clearer toggle labels and hints, UI Scale explanation, Fog of War Override labels, and a broader keyboard/control reference.
- New accessibility plan: `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md`.
- New planning-only full-game architecture docs:
  - `docs/FULL_GAME_ROADMAP.md`
  - `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`
  - `docs/V05_SYSTEMS_DESIGN_BRIEF.md`
- Existing bundle analyzer, hook audit, no-op second optimization decision, and e2e shard scripts were validated and left behavior-preserving.

### Verification

- `npm test`: passed with 38 test files and 270 tests.
- `npm run build`: passed with the known Phaser vendor large-chunk warning.
- `npm run test:e2e:smoke`: passed with 10 Playwright tests.
- `npm run test:e2e:release`: passed with 59 Playwright tests in 26.1m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle nodes.
- `git diff --check`: passed.
- Production preview smoke: passed at `http://127.0.0.1:57705/`; main menu loaded and browser console errors stayed at 0.

### Next

- Recommended next milestone: v0.5 save/content-validation gate before broad mechanics.
- Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, and broad army-management systems until their gates are explicit and green.

## v0.3.1 Polish Release Frozen - 2026-05-06

The v0.3.1 polish release is now frozen. v0.3 remains the Cinderfen Route Baseline content release; v0.3.1 is a polish/readability/performance-audit/test-maintenance release on top of that baseline. This freeze does not add gameplay, change balance, refactor code, or add maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems.

### Freeze Verification

- `npm test`: passed with 38 test files and 270 tests.
- `npm run build`: passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: passed with 59 Playwright tests in 28.6m.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle node/profile summaries.
- `git diff --check`: passed with no whitespace errors.
- Production preview smoke: passed at `http://127.0.0.1:4188/`; main menu loaded with `Prototype v0.3` / `Cinderfen Route Baseline`, New Campaign reached Campaign Map, Continue Campaign returned to Campaign Map, Skirmish Setup opened, and browser console errors stayed at 0.

### Frozen Scope

- v0.3.1 preserves the frozen v0.3 Cinderfen content route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- v0.3.1 includes mobile/readability audit coverage, Cinderfen copy/hierarchy polish, route-complete clarity, Results copy improvements, performance/bundle audit documentation, e2e runtime audit documentation, and safe shared e2e helper cleanup.
- No risky bundle optimization or test coverage reduction was implemented.
- Release report: `docs/V031_POLISH_RELEASE_REPORT.md`.
- Next phase: **v0.4 planning or technical optimization**.
- Recommended next work: human readability review of the frozen route, measurement-first performance optimization, or explicit e2e default/release-gate script planning.
- Postponed next work: workers, enemy construction, new factions, new maps, new units, diplomacy, procedural systems, crafting, durability, and broad systems.

## v0.3 Cinderfen Route Baseline Frozen - 2026-05-05

The v0.3 Cinderfen Route Baseline is now frozen. This freeze does not add gameplay, change balance, refactor code, or add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad loot systems.

### Freeze Verification

- `npm test`: passed with 38 test files and 268 tests.
- `npm run build`: passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: passed with 52 Playwright tests.
- `npm run playtest:sim`: passed with 255 deterministic runs across 85 campaign battle node/profile summaries.
- `git diff --check`: passed with no whitespace errors.
- Production preview smoke: passed at `http://127.0.0.1:4187/`; main menu loaded with `Prototype v0.3` / `Cinderfen Route Baseline`, New Campaign, Continue Campaign, Skirmish Setup, and Campaign Map did not crash, and browser console errors stayed at 0.

### Frozen Scope

- Frozen route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- Cinderfen Aftermath remains the end of the current playable v0.3 slice.
- Next phase: **v0.3.1 polish and human readability review**.
- Allowed next work: copy clarity, UX hierarchy, mobile/readability checks, small bug fixes, and controlled polish on the existing frozen route.
- Postponed next work: workers, enemy construction, new factions, diplomacy, procedural generation, crafting, new maps, and broad systems.

## v0.3 Cinderfen Route Baseline Candidate - 2026-05-04

This checkpoint promotes the current Cinderfen route to the v0.3 vertical-slice baseline candidate. It does not add gameplay, change balance, or add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad loot systems. The visible in-game menu now labels the playable build as `Prototype v0.3` with the subtitle `Cinderfen Route Baseline`; v0.2 remains the previous systems baseline.

### Route Baseline

- Current playable route: Chapter 1 through `ashen_outpost`, then `cinderfen_overlook`, optional `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath`.
- Main menu product copy is aligned with the current route baseline: `Prototype v0.3` / `Cinderfen Route Baseline`.
- `docs/V03_CINDERFEN_ROUTE_BASELINE.md` records the current route order, rewards summary, simulator summary, e2e summary, known risks, forbidden next steps, and recommended next steps.
- The Chapter 2 reward-economy audit is complete: first clears remain useful, repeat clears now pay only tiny XP/resources, and repeat battle item rolls are disabled for the Cinderfen battles.
- Chapter 2 Playwright helper cleanup is complete in `tests/e2e/chapter2-helpers.ts`, with behavior-preserving helpers for post-Ashen setup, Waystation service flows, Crossing/Watch launch, shrine capture, and test-only victory fast-forwards.
- Chapter 1 reward values and route stability remain unchanged.

### Current Release Verification Expectations

- `npm test`: latest checkpoint passed with 38 test files and 268 tests.
- `npm run build`: latest checkpoint passed with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: latest full suite passed with 52 Playwright tests.
- `npm run playtest:sim`: latest simulator baseline passed with 255 deterministic runs across 85 campaign battle node/profile summaries, no structural too-hard nodes, no structural too-easy nodes, Ashen Outpost beatable, no Stronghold warnings, and Cinderfen repeat rewards reduced to tiny non-item payouts.
- Optional `npm run preview` plus Browser Use smoke remains useful for a visible production-preview check and browser console-error check.

### Next Phase

- Next phase: **automated route readiness + polish freeze**.
- Best current work is verification, readability, UX, copy clarity, mobile density checks, and controlled polish on the existing route.
- Continue to avoid workers, enemy construction, new factions, new maps, new units, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems unless explicitly requested.

## v0.2.1 Prototype Baseline Candidate - 2026-05-03

This checkpoint packages the v0.2 feature baseline with the follow-up technical and UX stabilization work. It does not add gameplay or change balance. At that historical checkpoint, the visible in-game menu labeled the playable prototype as `Prototype v0.2`; `v0.2.1` was the release-baseline candidate for docs, verification expectations, refactor state, and HUD/fog regression coverage.

### Completed Since v0.2

- CampaignRules module split completed: `CampaignRules.ts` is now a compatibility facade over focused pure campaign modules for nodes, choices, rewards, reputation, modifiers, town services, and rival hooks.
- HUD interaction polish completed: battle command hover no longer flickers under routine HUD refresh, and long side-panel scroll positions are preserved across refreshes.
- Captured-site fog polish completed: player-owned captured resource sites remain locally revealed after the capturing units move away.
- Permanent Playwright regression coverage added for command hover stability, side-panel scroll preservation, captured resource-site fog visibility, and desktop/tablet/mobile battle command reachability.
- Rival/Nemesis Persistence V1 and Rival Rewards and Trophies V1 are part of the completed v0.2.1 baseline rather than the next milestone.

### Historical v0.2.1 Verification Expectations

- `npm test`: expected to pass with 36 test files and 210 tests.
- `npm run build`: expected to pass with the known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: latest full suite passed with 49 Playwright tests after the HUD/fog regression coverage was added.
- `npm run playtest:sim`: latest simulator baseline passed with 180 deterministic runs, no structural too-hard nodes, no structural too-easy nodes, Ashen Outpost beatable, and no Stronghold warnings.
- Optional Browser Use preview sanity remains recommended for a visible production-preview check and browser console-error check.

### Historical Next Phase

- This milestone is superseded by the v0.3 Cinderfen route baseline candidate above.
- Before adding Chapter 2 content, do a human-paced readability pass on retinue, rival rewards/trophies, HUD hover/scroll feel, captured-site fog readability, and Ashen Outpost pressure.
- Continue to avoid workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems unless explicitly requested.

## v0.2 Prototype Baseline - 2026-05-02

This release baseline captures the current playable Ascendant Realms prototype so it is easier to share, test, and continue from. It does not represent a content-complete game; it is the stable RTS/RPG campaign spine with Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, and Rival Rewards and Trophies V1 included.

### Campaign And Skirmish Structure

- Main menu flow labels the build as `Prototype v0.2` with the subtitle `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`, and supports New Campaign, Continue Campaign, Skirmish, Hero Inventory, Settings, Asset Gallery, Info, and Reset Save.
- The Border Marches mini-campaign has eight authored nodes: Border Village, Old Stone Road, Marcher Camp, Aether Well Ruins, Bandit Hillfort, Chapel of the Marches, Refugee Caravan, and Ashen Outpost.
- Campaign battle nodes and standalone skirmishes launch through the shared `BattleLaunchRequest` path.
- Skirmish mode includes First Claim, Broken Ford, and Ashen Outpost with difficulty and AI-personality selection.
- Results return battle rewards, campaign node rewards, victory/defeat actions, and save updates through the shared Results flow.

### Hero Progression

- Heroes have class, origin, stats, XP, levels, skill points, skill trees, and class abilities.
- Current classes are Warlord, Arcanist, and Shepherd.
- Current equipment slots are weapon, armor, and trinket, with item instances stored in inventory and equipment referencing instance IDs.
- Victory rewards can grant XP, resources, and item instances; unique duplicate rewards convert into campaign resources.
- Equip Now and Hero Inventory both persist equipment changes and recalculate hero stats.

### RTS Battle Loop

- Battles include hero and unit selection, movement, attack commands, attack-move, projectiles, capture sites, neutral camps, enemy bases, and victory/defeat resolution.
- Player construction supports Barracks, Mystic Lodge, and Watchtower placement with previews, construction progress, production locks, and rally points.
- Unit training queues support Militia, Rangers, and Acolytes with visible progress and cancel/refund behavior.
- Research upgrades include current data-driven battle upgrades such as infantry, armor, ranger, and Aether study lines.
- Unit Veterancy V1 gives player non-hero units battle-local XP, Recruit/Seasoned/Veteran/Elite ranks, modest stat bonuses, selected-unit rank display, rank-up feedback, and Notable Veterans in victory Results.
- Retinue Camp V1 lets campaign victories save a small number of surviving Seasoned+ veterans, shows them on the Campaign Map, deploys them in future campaign battles, and removes them permanently if they die.
- Enemy Hero / Rival Commander V1 adds three named Ashen commanders: Gorak Emberhand on Bandit Hillfort, Veyra of the Cinders on Aether Well Ruins, and Captain Malrec on Ashen Outpost, with scout feedback, minimap markers, modest abilities, XP/objective/results credit, and simulator telemetry.
- Rival/Nemesis Persistence V1 saves commander encounters, defeats, victories against the player, last outcomes, dispositions, small repeat-encounter modifiers, Campaign Map intel, and Results consequence copy.
- Rival Rewards and Trophies V1 adds data-driven once-only first-defeat rewards, duplicate prevention, persistent trophy records, Results reward copy, and compact Campaign Map trophy display.
- Enemy AI expands, trains, defends, and sends pressure waves through data-driven personalities.

### Fog And Minimap

- Fog of war uses unseen, explored, and visible grid states, with Story difficulty able to disable fog.
- Enemy and neutral units/buildings are hidden outside current vision.
- The minimap renders units, buildings, capture sites, camps, rally points, pings, and the camera viewport.
- Minimap click-to-pan, fog toggles, alert pings, and colorblind minimap palette support are covered by automated browser tests.

### Stronghold Development

- Stronghold Development is a compact two-tier persistent-upgrade system, not a city-builder.
- Tier I upgrades are Training Yard I, Watch Post I, Quartermaster Stores I, Chapel Corner I, and Ranger Paths I.
- Tier II upgrades are Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Tier II upgrades require their matching Tier I upgrade.
- Implemented effects stay compact: starting units, starting resources, hero HP/Mana multipliers, warning lead time, Watchtower range, building vision, first-building construction speed, Militia/Ranger training speed, and Training Yard II's +1 Retinue capacity.

### Reputation Effects

- Reputation ranks exist for Free Marches, Common Folk, Old Faith, Ashen Covenant, and the Sylvan Concord placeholder.
- Shared thresholds are Friendly at 25, Honored at 50, Disliked at -25, and Hostile at -50.
- Common Folk Friendly discounts Marcher Camp services.
- Free Marches Friendly discounts Stronghold Crown costs.
- Old Faith Friendly improves Chapel Aether rewards.
- Ashen Covenant Hostile adds minor Ashen-node pressure through the existing launch-modifier path.
- Campaign choice cards show costs, adjusted rewards, reputation deltas, resulting reputation value/rank, modifiers, and completion behavior.

### Randomized Item Affixes V1

- Item instances can roll small, slot-filtered affixes from `src/game/data/itemAffixes.ts`.
- Current affixes are Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Rarity rules are common 0-1, uncommon 1, rare 1-2, epic 2, and legendary 2-3 affixes.
- Deterministic affix generation exists for tests and scripted e2e rewards.
- Affixes persist on item instances, old empty-affix saves remain valid, and equipped affixes contribute to hero stats.
- Results and Inventory display affix names, base stats, affix stat contribution, total item stats, and equip preview deltas.

### Automated Playtest Simulator

- `npm run playtest:sim` regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.
- The simulator currently runs 180 deterministic campaign battle runs across 60 profile-node summaries.
- Profiles include no Stronghold upgrades, Tier I paths, a Tier II Quartermaster path, and retinue-aware profiles for one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Telemetry includes assigned rival commander id, defeated state, attack-join timing, losses involving the rival, objective completion, rival state before/after, rival outcome, active rival modifiers, first-defeat reward state, duplicate prevention, and trophy-earned state.
- Latest simulator status: no too-easy nodes, no structural too-hard nodes, Ashen Outpost beatable, and no Stronghold warnings.

### Historical Verification Status

Latest full verification recorded at the v0.2 point after Rival Rewards and Trophies V1:

- `npm test`: 36 test files, 210 tests passing.
- `npm run build`: passing with the known Vite large-chunk warning.
- `npm run test:e2e -- --reporter=line`: 45 Playwright tests passing.
- `npm run playtest:sim`: 180 simulated runs passing.

Known release caveat: the Vite production build reports that the main Phaser bundle is larger than the default 500 kB chunk warning threshold. This is tracked as a warning, not a failure.

### Historical Next Milestone

- At the v0.2 baseline point, the next recommended pass was Rival Rewards Balance And Readability Review.
- This is now superseded by the v0.3 Cinderfen route baseline candidate above; the current next phase is `automated route readiness + polish freeze`.
