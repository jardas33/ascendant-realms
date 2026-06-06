# Release Checklist

Use this checklist for the v0.3 Cinderfen route baseline candidate and future prototype checkpoints. Run commands from the project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

For day-to-day command selection before the final freeze gate, see `docs/DEVELOPER_COMMAND_GUIDE.md`. The release checklist remains the stricter checkpoint/freeze reference.

## Gate Selection

Use the focused gate that matches the changed surface during routine work, then run the final freeze gate before a release handoff.

| Change type | Minimum gate | Additional focused gate |
| --- | --- | --- |
| Routine iteration | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `git diff --check` | Add `npm run test:e2e:smoke` for source/tooling changes. |
| Docs-only change | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `git diff --check` | None unless docs describe a changed executable workflow. |
| Desktop spike fixture/tooling change | Routine gate plus `npm run export:portable-content`, `npm run validate:portable-content`, `npm run test:save-translation-contract`, `npm run export:desktop-spike-fixture`, and `npm run validate:desktop-spike-fixture` | Add `npm run godot:all` for v0.117+ Godot spike work when Godot and export templates are available. Add `npm run godot:headed:smoke` and `npm run godot:capture:review` for v0.118 packaged-headed review changes. Add `npm run godot:validate:player-slice` and `npm run godot:capture:player-slice` for v0.124+ player-facing review-slice changes. Add `GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat` and `GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat` for v0.130 acceptance-pack changes. Add `npm run godot:validate:post-mine-flow` and `npm run godot:headed:post-mine-flow-smoke` for v0.133 post-mine player-facing flow changes. Add `GODOT_CAPTURE_STABILIZED_SALTO_REVIEW_WINDOWS.bat` for v0.139 stabilization review-pack changes. Add package generation and `npm run verify:playtest-package` only if browser playtest package metadata or package docs change. |
| Tutorial/UI change | Routine gate plus `npm run test:e2e:smoke` | Add `npm run test:e2e:layout` and `npm run visual:qa` for overlay/layout/screenshot-relevant changes. |
| Visual-intake change | Routine gate, especially `npm run validate:art-intake` and `npm run art:review:validate` | Add `npm run art:packet:salto-slice` for v0.107 Salto slice packet changes. Add `npm run art:reference:init`, `npm run art:reference:validate`, `npm run art:reference:contact-sheet`, and `npm run art:reference:review-pack` for v0.138+ reference-only candidate work. Add `npm run visual:qa` only when screenshot comparison docs or candidate-review evidence changes. |
| Runtime art slot/harness change | Routine gate plus `npm run validate:runtime-art-slots`, `npm run art:review:validate`, and `npm run visual:qa` | Add `npm run visual:review-pack`, `npm run package:playtest`, and `npm run verify:playtest-package` when package metadata/docs change. |
| Private benchmark/profile change | Routine gate plus `npm run benchmark:battle:smoke`, `npm run benchmark:battle:representative`, `npm run benchmark:battle:report`, `npm run perf:trusted:preview`, `npm run perf:trusted:dev`, `npm run perf:root-cause-matrix`, `npm run perf:trusted:report`, `npm run perf:phase-profile:preview`, `npm run perf:subsystem-matrix`, `npm run perf:density-ladder`, `npm run perf:browser-gate`, `npm run perf:v0110:report`, `npm run perf:allocation-audit`, `npm run perf:spatial-query-profile`, `npm run perf:render-lifecycle-audit`, `npm run perf:host-snapshot`, `npm run perf:controls:preview`, `npm run perf:trusted:clean-profile`, `npm run perf:controls:report`, `npm run test:e2e:smoke:fast`, and `npm run visual:qa` | Add `npm run benchmark:battle:stress`, `npm run visual:review-pack`, `npm run package:playtest`, and `npm run verify:playtest-package` when package metadata/docs change. |
| Content/data change | Routine gate plus `npm run test:e2e:smoke` and `npm run playtest:sim` | Add `npm run test:e2e:deep` or full release for campaign, battle, save, reward, or pressure risk. |
| Final freeze gate | Every required check below, all release lanes/shards, visual QA, simulator, preview smoke, and `git diff --check` | Push only after the repo is clean and synced or document the manual push command. |

Known current realities:

- v0.144 is a controlled Codex image-generation Aster / Worker silhouette convergence human-review stop. It generates exactly three ignored local convergence boards plus matching metadata, contact sheet, review pack, and tracked docs only: no final character design lock, HUD, portrait, environment generation, broad unit roster, sprite, texture, model, UI kit, turnaround, animation pose, animation sheet, additional board, Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.145 work. Run the exact v0.144 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run art:reference:init`, `npm run art:reference:validate`, `npm run art:reference:contact-sheet`, `npm run art:reference:review-pack`, and `git diff --check`.
- v0.143 is a controlled Codex image-generation Aster / Worker silhouette-scale human-review stop. It generates exactly three ignored local comparison boards plus matching metadata, contact sheet, review pack, and tracked docs only: no final character design lock, HUD, portrait, environment generation, broad unit roster, sprite, texture, model, UI kit, turnaround, animation pose, animation sheet, additional board, Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.144 work. Run the exact v0.143 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run art:reference:init`, `npm run art:reference:validate`, `npm run art:reference:contact-sheet`, `npm run art:reference:review-pack`, and `git diff --check`.
- v0.142 is a reference-only style-lock ratification and future-brief preparation stop. It records R1 as the primary Salto environment style lock, R2 as the companion reference, R3 as a limited lane/Ashen-readability reference, and prepares `docs/art-prompts/V0143_01_ASTER_WORKER_SILHOUETTE_SCALE_BOARD.md` only: zero image generation, no HUD, Aster, Worker, unit, sprite, texture, model, portrait, UI kit, animation, extra candidates, Godot wiring, browser wiring, runtime import, manifest mutation, art-slot mutation, package inclusion, save change, stable-ID change, final runtime-art choice, protected-IP approval, or v0.143 execution. Run the exact v0.142 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run art:reference:init`, `npm run art:reference:validate`, `npm run art:reference:contact-sheet`, `npm run art:reference:review-pack`, and `git diff --check`.
- v0.141 is a controlled Codex image-generation revision round and human style-lock review stop. It generates exactly three revised ignored Salto environment reference-only candidates plus matching metadata, contact sheet, review pack, and tracked docs only: no HUD, Aster, Worker, unit, sprite, texture, model, UI kit, animation, extra candidates, Godot wiring, browser wiring, runtime import, art-slot mutation, save change, stable-ID change, final art choice, protected-IP approval, or v0.142 work. Run the exact v0.141 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run art:reference:init`, `npm run art:reference:validate`, `npm run art:reference:contact-sheet`, `npm run art:reference:review-pack`, and `git diff --check`.
- v0.140 is a controlled Codex image-generation canary and human style-lock stop. It generates exactly three ignored Salto environment reference-only candidates plus matching metadata, contact sheet, review pack, and tracked docs only: no HUD, Aster, Worker, unit, sprite, texture, model, animation, extra variants, Godot wiring, browser wiring, runtime import, art-slot mutation, save change, stable-ID change, final art choice, protected-IP approval, or v0.141 work. Run the exact v0.140 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run art:reference:init`, `npm run art:reference:validate`, `npm run art:reference:contact-sheet`, `npm run art:reference:review-pack`, and `git diff --check`.
- v0.139 consolidates the packaged Godot Salto player-facing slice into a stabilization gate, final human-review launcher, ignored v0.139 review pack, Emmanuel guide, and next-phase roadmap. It changes Godot wrapper scripts, v0.139 artifact generation, docs, and ignored Godot/artifact outputs only: no final engine choice, full port, Unity project, Unreal project, Electron wrapper, image generation, runtime art import, browser replacement, saves, stable IDs, rewards, balance, broad economy, broad building tree, broad recruitment, broad AI, pathing rewrite, maps, factions, multiplayer, PvP, co-op, campaign expansion, or v0.140 work. Run the exact v0.139 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run godot:all`, `npm run godot:fresh-checkout:validate`, `npm run art:reference:validate`, `npm run art:reference:review-pack`, and `git diff --check`. Also run `GODOT_CAPTURE_STABILIZED_SALTO_REVIEW_WINDOWS.bat` when refreshing the v0.139 ignored review pack.
- v0.133.1 repairs the Godot player-facing Objective 8 combat readability after Emmanuel's `test11` recording. It changes Godot spike scripts, v0.133 docs/tests, and ignored Godot/artifact outputs only: no final engine choice, full port, Unity project, Unreal project, Electron wrapper, image generation, runtime art import, browser replacement, saves, stable IDs, rewards, balance, broad economy, broad building tree, broad recruitment, broad AI, pathing rewrite, maps, factions, multiplayer, PvP, co-op, campaign expansion, or v0.134 work. Run the exact v0.133 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run godot:all`, `npm run godot:fresh-checkout:validate`, `npm run godot:validate:player-slice`, `npm run godot:validate:real-input`, `npm run godot:headed:real-input-smoke`, `npm run godot:validate:site-semantics`, `npm run godot:headed:site-semantics-smoke`, `npm run godot:validate:post-mine-flow`, `npm run godot:headed:post-mine-flow-smoke`, and `git diff --check`.
- v0.130 packages the existing Godot Salto player-facing slice as a human-review acceptance pack and prepares the first four reference-only art generation prompts. It changes Godot spike scripts, v0.130 one-click wrappers, v0.130 artifact generation, docs, and ignored Godot/build/package/artifact outputs only: no final engine choice, full port, Unity project, Unreal project, Electron wrapper, image generation, runtime art import, browser replacement, gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, multiplayer, PvP, co-op, content expansion, or v0.131 work. Run the exact v0.130 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run export:portable-content`, `npm run validate:portable-content`, `npm run export:desktop-spike-fixture`, `npm run validate:desktop-spike-fixture`, `npm run godot:all`, `npm run godot:fresh-checkout:validate`, `npm run godot:validate:player-slice`, `npm run godot:capture:player-slice`, and `git diff --check`. Also run `GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat` and `GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat` for the v0.130 artifact pack.
- v0.124 creates the player-facing Godot Salto review slice, private harness separation, procedural presentation shell, v0.124 validation/capture reports, and Emmanuel review guide. It changes Godot spike scripts, launch/capture/validate wrappers, package scripts, docs, package scripts, focused tests, and ignored Godot/build/package/artifact outputs only: no final engine choice, full port, Unity project, Unreal project, Electron wrapper, image generation, runtime art import, browser replacement, gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, multiplayer, PvP, co-op, content expansion, or v0.125 work. Run the exact v0.124 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run export:portable-content`, `npm run validate:portable-content`, `npm run export:desktop-spike-fixture`, `npm run validate:desktop-spike-fixture`, `npm run godot:all`, `npm run godot:fresh-checkout:validate`, `npm run godot:validate:player-slice`, `npm run godot:capture:player-slice`, and `git diff --check`.
- v0.123 creates the Godot continuation decision packet, Unity comparator boundary, Emmanuel review guide, reference-art boundary, implementation report, and eight reference-only art prompt docs. It changes docs and desktop-spike validation tests only: no final engine choice, full port, Unity project, Unreal project, Electron wrapper, image generation, runtime art import, browser replacement, gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, multiplayer, PvP, co-op, content expansion, or v0.124 work. Run the exact v0.123 requested stack: `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run export:portable-content`, `npm run validate:portable-content`, `npm run export:desktop-spike-fixture`, `npm run validate:desktop-spike-fixture`, `npm run godot:all`, `npm run godot:fresh-checkout:validate`, and `git diff --check`.
- v0.118 adds packaged-build headed smoke, deterministic screenshot capture, headed benchmarks, package validation, and Emmanuel's one-click review harness for the existing Godot Salto workflow spike. It changes text Godot spike files, scripts, docs, package scripts, focused tests, and ignored Godot/build/package/artifact outputs only: no final engine choice, full port, browser replacement, gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, imported art, runtime asset path, multiplayer, PvP, co-op, content expansion, or v0.119 work. When Godot 4.6.3 standard x86_64 and export templates are present, run `npm run godot:all`, `npm run godot:headed:smoke`, `npm run godot:capture:review`, and the desktop fixture gate before closeout.
- v0.117 creates the first repository-driven Godot desktop benchmark spike and one-click Windows workflow. It changes text project files, scripts, generated fixture data, docs, package scripts, tests, and ignored Godot/build/package artifacts only: no final engine choice, full port, browser replacement, gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, imported art, runtime asset path, multiplayer, PvP, co-op, content expansion, or v0.118 work. When Godot 4.6.3 standard x86_64 and export templates are present, run `npm run godot:all` plus the desktop fixture gate before closeout.
- v0.116 creates reviewed architecture docs, AI-first/editor-optional desktop spike criteria, a scorecard template, and deterministic engine-neutral Salto fixture export/validation tooling. It changes docs, tests, package scripts, and ignored generated fixture artifacts only: no engine selection, engine project, wrapper, desktop dependency, gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, art import, runtime asset path, public benchmark controls, desktop implementation, multiplayer, PvP, co-op, content, or v0.117 work. Package generation and package verification are not required unless package metadata or private package contents change.
- v0.115 consolidates v0.109-v0.114 trusted browser performance evidence, creates Emmanuel's clean-restart retest and decision packet, and sets the browser performance gate to RED. It changes docs, package metadata/docs, and validation tests only: no runtime gameplay, saves, stable IDs, rewards, balance, AI, pathing, maps, factions, art, runtime asset paths, public benchmark controls, engine posture, desktop work, multiplayer, PvP, co-op, content, or v0.116 work. The final clean package must have no `-dirty` suffix, must name `v0.115 Trusted Performance Consolidation, Clean-Restart Retest Packet, and Browser Gate`, include the v0.115 docs, run `npm run perf:host-snapshot`, `npm run perf:controls:preview`, `npm run perf:trusted:clean-profile`, `npm run perf:trusted:preview`, `npm run perf:phase-profile`, `npm run perf:allocation-audit`, `npm run perf:spatial-query-profile`, `npm run perf:render-lifecycle-audit`, `npm run perf:trusted:report`, the representative benchmark commands, `npm run package:playtest`, and `npm run verify:playtest-package`.
- v0.111 adds private host-environment calibration, browser control baselines, temporary clean Chromium profile comparison, machine-pressure classification, private Performance Lab instruction controls, and package metadata/docs. It changes private QA tooling, benchmark reports, docs, and package contents only: no unrelated process killing, reboot, OS setting change, user browser profile mutation, browser history/open-tab/profile-content/private command-line collection, save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, races, units, buildings, Living Mines, generated/imported art, runtime asset paths, public benchmark controls, desktop work, desktop saves, engine choice, runtime title, multiplayer, PvP, co-op, or v0.112 work. The final clean package must have no `-dirty` suffix, must name `v0.111 Host Environment Calibration, Clean-Browser Reproducibility, and Machine-Pressure Gate`, include the v0.111 docs, run `npm run perf:host-snapshot`, `npm run perf:controls:preview`, `npm run perf:trusted:clean-profile`, and `npm run perf:controls:report`, and verify with `npm run verify:playtest-package`.
- v0.110 adds private battle-loop phase profiling, subsystem isolation switches, density-scaling evidence, trusted browser gate reports, visual QA/review-pack coverage, and package metadata/docs. It changes private QA tooling, benchmark reports, docs, visual QA, and package contents only: no save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, races, units, buildings, Living Mines, generated/imported art, runtime asset paths, public benchmark controls, desktop work, desktop saves, engine choice, runtime title, multiplayer, PvP, co-op, or v0.111 work. The final clean package must have no `-dirty` suffix, must name `v0.110 Battle-Loop Phase Profiler, Runtime Bottleneck Isolation, and Controlled Performance Rescue`, include the v0.110 docs, refresh visual QA and the visual review pack to 244 screenshots / 10 contact sheets, run the v0.108/v0.109 benchmark lanes plus `npm run perf:phase-profile:preview`, `npm run perf:subsystem-matrix`, `npm run perf:density-ladder`, `npm run perf:browser-gate`, and `npm run perf:v0110:report`, and verify with `npm run verify:playtest-package`.
- v0.109 adds trusted browser benchmark methodology, production-preview-first sampling, dev comparison, private manual benchmark flow, root-cause diagnostic toggles, visual QA/review-pack coverage, and package metadata/docs. It changes private QA tooling, benchmark reports, docs, visual QA, and package contents only: no save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, generated/imported art, runtime asset paths, public benchmark controls, desktop work, desktop saves, engine choice, runtime title, multiplayer, PvP, co-op, or v0.110 work. The final clean package must have no `-dirty` suffix, must name `v0.109 Browser Benchmark Integrity Audit and Performance Root-Cause Isolation`, include the v0.109 docs, refresh visual QA and the visual review pack to 240 screenshots / 10 contact sheets, run the v0.108 representative benchmark lanes plus `npm run perf:trusted:preview`, `npm run perf:trusted:dev`, `npm run perf:root-cause-matrix`, and `npm run perf:trusted:report`, and verify with `npm run verify:playtest-package`.
- v0.108 adds a private no-save representative battle benchmark harness, benchmark scripts, provisional desktop acceptance profile, visual QA/review-pack coverage, and package metadata/docs. It changes private QA tooling, benchmark reports, docs, visual QA, and package contents only: no save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, generated/imported art, runtime asset paths, public benchmark controls, desktop work, desktop saves, engine choice, runtime title, multiplayer, PvP, or co-op. The final clean package must have no `-dirty` suffix, must name `v0.108 Representative Battle Benchmark Harness and Desktop Acceptance Profile`, include the v0.107/v0.108 docs, refresh visual QA and the visual review pack to 213 screenshots / 9 contact sheets, run `npm run benchmark:battle:smoke`, `npm run benchmark:battle:representative`, `npm run benchmark:battle:stress`, and `npm run benchmark:battle:report`, and verify with `npm run verify:playtest-package`.
- v0.107 defines the first Salto vertical-slice composition plan, asset-dimension contracts, deterministic manifest validation, dependency order, first-slice review gate, Emmanuel checklist, and metadata-only packet generator. It changes docs, tooling, tests, and ignored artifact rules only: no generated/imported art, runtime asset paths, runtime integration approval, save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, desktop work, runtime title, or package metadata. Package generation and package verification are not required unless a later checkpoint changes package metadata or private package contents.
- v0.106 adds a typed runtime art slot adapter, placeholder fallback harness, private-only diagnostics/mock routing, Art Slot Fallbacks private scenarios, and runtime-art slot validation. It changes art-slot contracts, private QA tooling, visual QA/review-pack coverage, docs, and package metadata only: no generated/imported art, unapproved runtime art loading, save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, desktop work, engine choice, or runtime title. The final clean package must have no `-dirty` suffix, must name `v0.106 Runtime Art Slot Adapter and Placeholder Fallback Harness`, include the v0.105/v0.106 art docs, refresh visual QA and the visual review pack to 203 screenshots / 8 contact sheets, run `npm run validate:runtime-art-slots`, and verify with `npm run verify:playtest-package`.
- v0.105 adds a deterministic reference-only visual asset registry, ignored candidate-review workspaces, strict art-review validation, SVG contact sheets, deterministic reports, and Emmanuel's first controlled art generation packet. It changes tooling, schema, docs, tests, and ignored artifact rules only: no generated/imported art, runtime asset paths, save-version bump, save fields, localStorage writes, stable IDs, gameplay, rewards, balance, maps, factions, desktop work, runtime title, or package metadata. Package generation and package verification are not required unless a later checkpoint changes package metadata or private package contents.
- v0.104 uses v0.103 profiler evidence to add targeted rendering skips and public Minimal battle HUD density. It changes rendering/HUD presentation, private QA tooling, visual QA, docs, hosted/visual harness timing, and package metadata only: no gameplay systems, balance, rewards, save-version bump, save fields, localStorage writes, stable IDs, campaign progression, Lume rules/mechanics, maps, factions, generated/imported art, desktop work, runtime title, or public Debug controls. The final clean package must have no `-dirty` suffix, must name `v0.104 Profiler-Guided Rendering Optimization and Public Battle HUD Minimal Mode`, include the v0.104 docs/retest checklist, refresh visual QA and the visual review pack to 189 screenshots / 7 contact sheets, run `npm run perf:profile:private` and `npm run perf:report:private`, and verify with `npm run verify:playtest-package`.
- v0.103 reduces stable battlefield clutter and adds a private/dev-only Performance Lab plus profiler. It changes runtime presentation, private QA tooling, visual QA, docs, and package metadata only: no gameplay systems, balance, rewards, save-version bump, save fields, localStorage writes, stable IDs, campaign progression, Lume rules, `linked_ward` 0.92 multiplier, maps, factions, generated/imported art, desktop work, or production shortcut exposure. The final clean package must have no `-dirty` suffix, must name `v0.103 Battlefield Clutter Reduction and Private Performance Profiler`, include the v0.103 docs/retest checklist/manifest, refresh visual QA and the visual review pack to 172 screenshots / 7 contact sheets, run `npm run perf:profile:private` and `npm run perf:report:private`, and verify with `npm run verify:playtest-package`.
- v0.102 adds deterministic fictional browser save fixtures, `npm run test:save-translation-contract`, and a proposed desktop save-envelope proof that validates fixture IDs against the v0.101 stable-ID snapshot. It changes tooling, tests, fixtures, docs, and ignored generated artifacts only: no runtime save behavior, `CURRENT_SAVE_VERSION`, localStorage keys, real-save writes, gameplay, rewards, stable IDs, content definitions, package metadata, desktop save path, profile UI, engine choice, or desktop implementation. Package generation and package verification are not required unless package metadata or private package contents change.
- v0.101 adds deterministic downstream-only portable content export tooling, `npm run export:portable-content`, `npm run validate:portable-content`, and a compact stable-ID snapshot. It changes tooling, schema validation, tests, docs, and ignored generated artifacts only: no runtime behavior, gameplay, balance, saves, stable IDs, package metadata, art/assets, desktop implementation, or engine choice. Generated portable content lives under ignored `artifacts/portable-content/latest/`; the committed freeze fixture is `src/game/portable/stable-id-snapshot.json`. Package generation and package verification are not required unless package metadata or private package contents change.
- v0.100 adds a private-package-only Playtest Hub, Scenario Gallery, and 8-minute visual tour. It changes private/dev QA routing, no-save fixture previews, visual QA, docs, and package metadata only: no production-posture shortcut exposure, save-version bump, save fields, localStorage keys, stable IDs, normal progression, unlock rules, rewards, replay rules, Retinue/reputation mutation, gameplay rules, balance, maps, factions, art/assets, generated images, imported assets, runtime rebrand, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.100 Private Playtest Hub and Scenario Gallery`, include the v0.100 docs and manifest, refresh visual QA and the visual review pack to 145 screenshots / 7 contact sheets, and verify with `npm run verify:playtest-package`.
- v0.99 polishes Act 1 mission presentation, objective clarity, Captain Malrec framing, compact next-step copy, and ordinary Results guidance. It changes presentation copy/rendering helpers/tests/visual QA/docs/package metadata only: no save-version bump, save fields, localStorage keys, persistent settings, stable IDs, campaign progression, unlock rules, rewards, replay rules, optional objective logic, difficulty, AI, balance, maps, factions, art/assets, generated images, imported assets, runtime rebrand, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.99 Act 1 mission presentation objective clarity and narrative polish`, include the v0.99 docs/retest checklist, refresh visual QA and the visual review pack to 136 screenshots / 7 contact sheets, and verify with `npm run verify:playtest-package`.
- v0.98 rescues Hero, Skills, Equipment, Inventory, Relic, Retinue, Stronghold, and Results-to-meta presentation. It changes meta-progression markup/CSS/tests, a derived Results summary, visual QA, docs, and package metadata only: no save-version bump, save fields, localStorage keys, persistent settings, stable IDs, progression rules, XP, relic stats, equipment rules, Retinue rules, Stronghold upgrade rules, rewards, replay rules, campaign progression, balance, maps, factions, art/assets, generated images, imported assets, runtime rebrand, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.98 hero Retinue inventory and Stronghold UX rescue`, include the v0.98 docs/retest checklist, refresh visual QA and the visual review pack to 126 screenshots / 7 contact sheets, and verify with `npm run verify:playtest-package`.
- v0.97 polishes camera, selection, orders, and tactical feedback. It changes selection focus cards, read-only enemy inspection, short-lived command markers, camera focus/minimap confirmations, command-panel disclosure copy, visual QA, docs, and package metadata only: no save-version bump, save fields, localStorage keys, persistent settings, stable IDs, gameplay systems, rewards, XP, balance, combat stats, pathing rules, campaign progression, maps, factions, art/assets, generated images, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.97 camera selection orders and tactical feedback polish`, include the v0.97 docs/retest checklist, refresh visual QA and the visual review pack to 118 screenshots / 7 contact sheets, and verify with `npm run verify:playtest-package`.
- v0.96 rescues first-session Tutorial/onboarding presentation. It changes Tutorial step metadata/copy, Tutorial panel controls, compact help surfaces, campaign first-step guidance, visual QA, docs, and package metadata only: no save-version bump, save fields, localStorage keys, stable IDs, gameplay rules, reward logic, balance, campaign progression, Lume mechanics, maps, factions, races, art/assets, generated images, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.96 first-time player onboarding and Tutorial UX rescue`, include the v0.96 docs/retest checklist, refresh visual QA and the visual review pack to 110 screenshots / 7 contact sheets, and verify with `npm run verify:playtest-package`.
- v0.95 rescues procedural battlefield readability and placeholder-world presentation. It changes Phaser primitive presentation, battle CSS, visual QA, docs, and package metadata only: no save-version bump, save fields, localStorage keys, stable IDs, gameplay rules, reward logic, balance, fog-of-war simulation, Lume mechanics, pathing, collision, maps, factions, art/assets, generated images, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.95 procedural battlefield readability and placeholder-world rescue`, include the v0.95 docs/retest checklist, refresh visual QA and the visual review pack to 102 screenshots / 7 contact sheets, and verify with `npm run verify:playtest-package`.
- v0.94 rescues the main menu, Ascendant creation, campaign-shell density, campaign-tab hierarchy, compact mission panel, and ordinary Results expanded details. It changes presentation markup/CSS/tests only: no save-version bump, save fields, localStorage keys, hero rules, rewards, XP, campaign progression, stable IDs, runtime rebrand, art/assets, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.94 main menu ascendant creation and campaign-shell density rescue`, include the v0.94 docs/retest checklist, refresh visual QA and the visual review pack, and verify with `npm run verify:playtest-package`.
- v0.93 adds runtime UI foundation tokens and a selected-mission panel reset fix. It changes presentation CSS and campaign-map node-selection UI state only: no save-version bump, save fields, localStorage keys, rewards, XP, campaign progression, stable IDs, runtime rebrand, art/assets, or desktop work. The final clean package must have no `-dirty` suffix, must name `v0.93 runtime UI foundation tokens and mission-panel state reset`, include the v0.93 docs/retest checklist, refresh the visual review pack after visual QA, and verify with `npm run verify:playtest-package`.
- v0.92 adds a local static visual review-pack generator. After `npm run visual:qa`, run `npm run visual:review-pack` to refresh `artifacts/visual-review/latest/`. The output is ignored by git and package validation is not required unless package metadata changes.
- v0.91 is a docs-only desktop-transition technical audit. Use the docs-only routine gate. Package generation and package verification are not required unless package metadata or private package contents change in a later follow-up.
- `npm run validate:art-intake` is part of the routine gate and must remain safe with an empty intake.
- `npm run visual:qa` is useful, optional, human-reviewed, and non-pixel-perfect.
- The local 3-way release shards remain a better-balanced local split than 2-way shards, but they do not replace the full release lane.
- The known Phaser vendor chunk warning remains expected and non-blocking.
- Full release e2e is intentionally slow and should use a long timeout.
- Production preview smoke should prefer `npm run smoke:preview` after `npm run build`.
- GitHub Actions now has a conservative `.github/workflows/ci.yml` dry-run: fast PR/push confidence runs the smaller `npm run test:e2e:smoke:fast` subset automatically, while full smoke, visual QA, hosted release groups, simulator, and full release remain local/manual release confidence.
- v0.29.1 records GitHub Actions run `26447947052` as blocked before checkout by GitHub HTTP 403 account-suspension response. Treat that historical run as remote CI unavailable, not a code/test failure. Checkout later recovered: push run `26484639124` on `6124d71` passed Fast confidence, and manual run `26484817685` checked out successfully across Fast confidence, Release simulator, and hosted release-matrix jobs. Do not claim remote CI green yet because hosted `deep-battle` failed in manual run `26484817685`.
- v0.29.2 is the hosted `deep-battle` recovery pass for manual run `26484817685`. It changes only hosted e2e harness/docs/package metadata: canvas-position right-clicks after canvas hit-test verification, durable scene-state movement assertions, deterministic Worker/site setup, and hover-stability assertions based on visible enabled controls. First fix commit `45c7eb1` passed Fast confidence in push run `26490257582`, but manual release-matrix run `26490433401` still failed one stale duplicate movement-summary assertion in hosted `deep-battle`. Follow-up fix commit `b7604e5` passed Fast confidence in push run `26493632871`, and manual release-matrix run `26493804376` passed Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`. The final clean package must have no `-dirty` suffix, must name the v0.29.2 checkpoint, and must verify with `npm run verify:playtest-package`.
- v0.42-v0.44 adds mission type, scenario modifier, briefing, and Results after-action metadata using existing maps/systems only. Run a fresh `npm run build` before local hosted-release scripts, because the hosted config serves the current production `dist/`. The final clean package must have no `-dirty` suffix, must name `v0.42-v0.44 mission variety and scenario modifier foundation`, and must verify with `npm run verify:playtest-package`.
- v0.51-v0.53 is a player-facing UX/readability polish pass: cursor affordances, command disabled reasons, Worker build/repair/site assignment clarity, hero ability cooldown/Mana readability, and Burn/status chip clarity. It does not add saves, art, maps, factions, new systems, Patrol, formations, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.51-v0.53 player-facing UX and command readability polish`, and must verify with `npm run verify:playtest-package`.
- v0.54-v0.56 adds session-only control groups, conservative group movement spacing, and minimal combat-unit Patrol. It uses no save-version bump and no new save fields, adds no maps/factions/art, keeps Worker build/repair/site commands and hero ability hotkeys covered, and does not add a formation editor, enemy formation AI, broad pathing rewrite, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.54-v0.56 control groups and Patrol foundation`, include the v0.54-v0.56 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.57-v0.59 adds battle-only army veterancy, unit-role identity copy, and tactical feedback polish. It uses no save-version bump and no new save fields, adds no maps/factions/art, does not add a permanent army roster, keeps control groups/Patrol/Worker commands covered, and does not add a formation editor, Patrol rewrite, broad pathing rewrite, global rebalance, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.57-v0.59 army veterancy and tactical feedback foundation`, include the v0.57-v0.59 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.60-v0.62 adds a small persistent Retinue roster and explicit campaign pre-battle deployment selection on top of the existing opt-in survivor flow. It uses no save-version bump, adds backward-compatible `retinueDeploymentIds` plus optional Retinue counters, adds no maps/factions/art, keeps normal unit veterancy battle-only unless recruited, and does not add a giant roster UI, permanent control groups, shop/crafting, broad pathing/AI rewrite, global rebalance, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.60-v0.62 persistent Retinue and deployment foundation`, include the v0.60-v0.62 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.63-v0.65 adds Retinue recovery, reserve readability, and a once-per-battle Call Retinue command. It uses no save-version bump, adds optional `recoveryMissionsRemaining`, normalizes legacy wounded/lost Retinue state safely, adds no maps/factions/art, keeps Tutorial/no-reward routes free of Retinue mutation, and does not add a giant roster UI, permanent control groups, shop/crafting, broad pathing/AI rewrite, global rebalance, formation editor, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.63-v0.65 Retinue recovery and reinforcement foundation`, include the v0.63-v0.65 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.66-v0.68 adds readable enemy tactical doctrines, capped battle-only elite squads, and counterplay copy using existing AI, units, maps, and UI. It uses no save-version bump and no new save fields, adds no maps/factions/art, does not globally rebalance difficulty, and does not add a broad pathing rewrite, enemy formation rewrite, giant roster, shop/crafting, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.66-v0.68 enemy tactical doctrines and elite squad foundation`, include the v0.66-v0.68 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.69-v0.71 adds pre-battle intelligence, session-only tactical plan selection, and counter-doctrine preparation using existing campaign, Retinue, hero, relic, skill, mission modifier, doctrine, elite squad, and launch systems. It uses no save-version bump and no new persistent save fields, adds no maps/factions/art, keeps Tutorial/no-reward routes simple, does not globally rebalance difficulty, and does not add shop/crafting, a formation editor, broad pathing rewrite, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.69-v0.71 pre-battle tactical preparation foundation`, include the v0.69-v0.71 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.72-v0.74 adds battle-session-only battlefield events, dynamic tactical objectives, and adaptive pressure readability using existing mission type, doctrine, elite squad, tactical plan, Retinue, resource-site, HUD, and Results systems. It uses no save-version bump and no new persistent save fields, adds no maps/factions/art, keeps Tutorial/no-reward routes protected, avoids random event spam, and does not add shop/crafting, a formation editor, broad AI/pathing rewrite, giant event system, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.72-v0.74 dynamic battlefield events and tactical objectives`, include the v0.72-v0.74 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.75-v0.77 turns Ashen Outpost into the Act 1 finale with deterministic phase copy, Captain Malrec release gating, existing battlefield-event integration, tactical-plan support notes, and milestone Results debriefs. It uses no save-version bump and no new persistent save fields, adds no maps/factions/art, keeps Tutorial/no-reward routes untouched, and does not add a giant boss system, broad AI/pathing rewrite, global rebalance, shop/crafting, or canvas/world force-click behavior. The final clean package must have no `-dirty` suffix, must name `v0.75-v0.77 Act 1 finale and rival commander milestone`, include the v0.75-v0.77 specs/reports/retest checklist, and verify with `npm run verify:playtest-package`.
- v0.78 is a docs-only creative identity lock and original-IP separation pass. It proposes `JARDAS: Oath of the Barrosan Marches`, Jardas/Lume/Salto/Barrosan Marches lore, eight race identities, future hero architecture, signature pillars, campaign direction, visual governance, browser-to-desktop gates, display-name migration safety, and an Emmanuel review packet. It uses no save-version bump and no new save fields, changes no runtime behavior, renames no internal IDs, adds no maps/factions/races/units/buildings/art/assets, starts no desktop port, chooses no engine, and adds no multiplayer/PvP/co-op. The final clean package must have no `-dirty` suffix, must name `v0.78 creative identity lock and original-IP separation pass`, include all v0.78 docs and the Emmanuel review packet, and verify with `npm run verify:playtest-package`.
- v0.79 is a docs-only Emmanuel creative review incorporation and direction lock. It records human approval for `JARDAS: Oath of the Barrosan Marches`, Salto, the Barrosan Marches, Lume, the Jardas meaning, Captain Malrec, the race-roster direction, Barrosan/Ashen/Wolfveil vertical-slice priority, future hero architecture, Lume Network as first future signature-system design priority, campaign/visual/desktop-roadmap direction, deferred decisions, and the safe v0.80-v0.82 sequence. It uses no save-version bump and no new save fields, changes no runtime behavior, renames no internal IDs, adds no maps/factions/races/units/buildings/classes/art/assets, starts no desktop port, starts no runtime rebrand or copy migration, and adds no multiplayer/PvP/co-op. The final clean package must have no `-dirty` suffix, must name `v0.79 Emmanuel creative review incorporation and direction lock`, include all v0.79 docs, and verify with `npm run verify:playtest-package`.
- v0.80 is a docs-only Salto/Lume/display-copy migration plan. It inventories 72 current runtime-facing strings/adjacent IDs, classifies safe display-copy candidates, recommends Lume as future world-facing living land-power while keeping Mana as tactical hero ability resource for now, and marks Aether as case-by-case review instead of a blanket rename. It uses no save-version bump and no new save fields, changes no runtime behavior, renames no internal IDs, adds no maps/factions/races/units/buildings/classes/art/assets, starts no desktop port, starts no runtime rebrand or copy migration, does not implement Lume Network, and adds no multiplayer/PvP/co-op. The final clean package must have no `-dirty` suffix, must name `v0.80 Salto Lume and display-copy migration plan`, include all v0.80 docs plus the JSON inventory, and verify with `npm run verify:playtest-package`.
- v0.81 is a docs-only Lume Site Network prototype specification and smallest-fun-slice gate. It audits existing resource-site, Worker, campaign, HUD, Results, event, AI, save, replay, Tutorial, and test architecture, then recommends mission-local Linked Control on `aether_well_ruins` / `broken_ford` with at most three eligible sites, two active links, and a small non-stacking `Linked Ward` benefit for future Emmanuel-approved implementation. It uses no save-version bump and no new save fields, changes no runtime behavior, renames no internal IDs, adds no maps/factions/races/units/buildings/classes/art/assets, starts no desktop port, starts no runtime rebrand or copy migration, does not implement Lume Network runtime behavior, and adds no multiplayer/PvP/co-op. The final clean package must have no `-dirty` suffix, must name `v0.81 Lume Site Network prototype specification and smallest-fun-slice gate`, include all v0.81 Lume planning docs and the Emmanuel review packet, and verify with `npm run verify:playtest-package`.
- v0.82 adds the smallest mission-local Lume Network runtime prototype on `aether_well_ruins` / `broken_ford`. It uses existing resource sites only, activates Linked Ward from two captured linked sites, provides a non-stacking 8% incoming-damage reduction near active linked sites, and shows briefing/HUD/selected-site/Results copy. It uses no save-version bump and no new save fields, renames no internal IDs, adds no maps/factions/races/units/buildings/classes/art/assets, starts no desktop port, starts no runtime rebrand or display-copy migration, does not add Jardas/Worker/hero binding, resource-production bonuses, global balance changes, enemy AI tuning, multiplayer, PvP, or co-op. The final clean package must have no `-dirty` suffix, must name `v0.82 mission-local Lume Network runtime prototype`, include the v0.82 spec/report/retest docs, and verify with `npm run verify:playtest-package`.
- v0.83 rescues the campaign map UX and adds a private package/dev quick-launch for the existing Aether Well Lume slice. It uses existing campaign nodes, `aether_well_ruins` / `broken_ford`, existing Lume rules, existing HUD/Results surfaces, and an explicit private-tool flag only. It uses no save-version bump and no new save fields, renames no internal IDs, adds no maps/factions/races/units/buildings/classes/art/assets, does not alter public campaign prerequisites, does not broaden Lume rules, and starts no desktop work, multiplayer, PvP, co-op, runtime rebrand, or display-copy migration. The final clean package must have no `-dirty` suffix, must name `v0.83 campaign map UX rescue and private playtest quick launch`, include the v0.83 docs/retest checklist, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.84 polishes the package/dev-only Aether Well Lume demo with a progressive Lume tracker, battlefield link rendering, focus controls, and fast Exit/Finish demo controls. It keeps `aether_well_ruins`, `broken_ford`, `west_stone_cut`, `ford_toll`, `north_aether_spring`, both Lume link ids, `linked_ward`, and the 0.92 incoming-damage multiplier unchanged. It uses no save-version bump and no new save fields, renames no internal IDs, adds no maps/factions/races/units/buildings/classes/art/assets, does not alter public campaign prerequisites, does not broaden Lume rules, and starts no desktop work, multiplayer, PvP, co-op, runtime rebrand, or display-copy migration. The final clean package must have no `-dirty` suffix, must name `v0.84 guided Lume demo readability and fast-retest polish`, include the v0.84 specs/reports/retest checklist/deferred findings, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.85 rescues contextual Lume overlay readability and the private-demo Results screen. It keeps `aether_well_ruins`, `broken_ford`, `west_stone_cut`, `ford_toll`, `north_aether_spring`, both Lume link ids, `linked_ward`, and the 0.92 incoming-damage multiplier unchanged. It uses no save-version bump, no new save fields, no persistent settings, no internal ID renames, no maps/factions/races/units/buildings/classes/art/assets, no broader Lume rules, no public campaign prerequisite changes, no desktop work, no multiplayer/PvP/co-op, and no runtime rebrand/display-copy migration. The final clean package must have no `-dirty` suffix, must name `v0.85 contextual Lume overlay and Results-screen UX rescue`, include the v0.85 specs/reports/retest checklist/deferred findings, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.86 rescues the general battlefield-shell presentation with compact command entries, notification priority categories, objective tracker cleanup, capture-site label contrast, selection-ring clarity, softened fog presentation, and minimap site markers. It uses no save-version bump, no new save fields, no persistent settings, no internal ID renames, no maps/factions/races/units/buildings/classes/art/assets, no gameplay-system or balance change, no broader Lume rules, no public campaign prerequisite changes, no desktop work, no multiplayer/PvP/co-op, and no runtime rebrand/display-copy migration. The final clean package must have no `-dirty` suffix, must name `v0.86 general battlefield-shell UX rescue`, include the v0.86 specs/reports/retest checklist/deferred findings, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.87 polishes the campaign shell and ordinary Results information architecture with a larger map-first layout, chapter lanes, compact selected-mission details, card-based campaign tabs, and progressive Results disclosure. It uses no save-version bump, no new save fields, no persistent settings, no internal ID renames, no maps/factions/races/units/buildings/classes/art/assets, no gameplay-system or balance change, no campaign progression/reward/XP change, no desktop work, no multiplayer/PvP/co-op, and no runtime rebrand/display-copy migration. The final clean package must have no `-dirty` suffix, must name `v0.87 campaign-shell second polish and Results information architecture`, include the v0.87 specs/reports/retest checklist/deferred findings, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.88 is a docs-first visual foundation, style-frame preparation, and AI-art intake gate. It defines screen hierarchy, proposed UI tokens, Barrosan/Ashen/Wolfveil briefs, future prompt templates, a planning-only vertical-slice asset manifest, and Emmanuel review packet. It uses no save-version bump, no new save fields, no persistent settings, no internal ID renames, no maps/factions/races/units/buildings/classes, no gameplay-system or balance change, no campaign progression/reward/XP change, no desktop engine selection, no image generation, no asset import, no runtime art, and no runtime rebrand/display-copy migration. The final clean package must have no `-dirty` suffix, must name `v0.88 visual foundation style-frame preparation and AI-art intake gate`, include the v0.88 visual foundation docs/review packet/manifest, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.89 is a controlled display-copy migration batch. It changes only approved current player-facing labels: Barrosan Freeholds, The Barrosan Marches, Salto Outskirts/Salto onboarding, Rootbound Concord, and Lume Surge. It uses no save-version bump, no new save fields, no serialized ID renames, no gameplay-system or balance change, no campaign progression/reward/XP change, no maps/factions/races/units/buildings/classes/art/assets, no runtime title rebrand, no public-title migration, and no repository/package folder rename. The final clean package must have no `-dirty` suffix, must name `v0.89 controlled display-copy migration batch A`, include the v0.89 ledger/deferred/test/visual/report/retest docs, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.90 is a QA-hardening pass for UX visual-regression and desktop viewport acceptance. It expands deterministic visual QA to 64 screenshots, validates `docs/V090_VISUAL_REGRESSION_MATRIX.json`, adds desktop layout assertions for campaign, Results, battle HUD, Lume, private-demo, replay, and Tutorial posture, and records lightweight performance baselines. It uses no save-version bump, no new save fields, no stable ID renames, no gameplay-system or balance change, no campaign progression/reward/XP change, no maps/factions/races/units/buildings/classes/art/assets, no runtime title rebrand, no desktop implementation, and no image generation/import. The final clean package must have no `-dirty` suffix, must name `v0.90 UX visual-regression harness and desktop-viewport acceptance hardening`, include the v0.90 QA docs, inject the private playtest tools flag into `game/index.html`, and verify with `npm run verify:playtest-package`.
- v0.11.6 keeps optional visual QA manual but makes hosted setup navigation more tolerant of transient `net::ERR_ABORTED`, frame-detach, and setup-navigation timeout errors while still requiring visible main-menu controls, and gives the 18-screenshot capture test a 420s budget.
- v0.11.7 splits optional visual QA into 5 smaller tests and adds per-screenshot logging, a 45s screenshot timeout, one screenshot retry, and retry metadata while keeping all 18 targets and console-error failure behavior.
- v0.11.8 keeps the 3-way release matrix intact while hardening hosted release setup navigation and actionability: no e2e `page.reload()` remains, deep-flow seeding uses the shared menu-ready path, `gotoReadyMainMenu` uses commit-stage app-root navigation with 3 attempts and same-URL interruption handling, and a narrow `clickReady` helper covers reported release-path click stalls without force-clicking.
- v0.11.11 keeps local full release, local 2-way shards, and local 3-way shards intact, but runs the manual GitHub release groups against production preview after run #17 showed hosted dev-server release groups still failed across app boot, actionability, and browser-context stability.
- v0.11.12 keeps hosted release coverage intact and hardens interaction determinism after run #19 showed remaining hosted failures in real DOM button clicks, battle-loaded waits, tutorial/layout box measurement, side-panel reachability checks, and canvas movement delivery.
- v0.16.1 keeps the automatic Fast confidence script unchanged but splits settings accessibility coverage into two focused `@ci-fast` tests so settings persistence and runtime battle application get separate browser contexts.
- v0.16.2 keeps the hosted release matrix shape unchanged after run #66, removes duplicated behaviour-mode switching from the older deep-battle HUD test because the dedicated hosted behaviour gauntlet owns that coverage, and gives only the settings runtime accessibility smoke a 90s hosted-safe budget.
- v0.16.3 keeps the same hosted smoke coverage after run #68, but gives only the settings runtime smoke battle `Menu`/`Resume` DOM buttons a short normal-click budget before verified DOM-control fallback so hosted CI does not burn the test timeout on repeated actionability waits.
- v0.16.4 keeps the same hosted deep-battle coverage after run #70, but treats `Moving` and `Repositioning` as valid right-click movement summaries and checks fog/cancel behaviour through durable scene state instead of transient status-line text that pressure messages can intentionally outrank.
- v0.16.5 keeps hosted deep-battle coverage intact after run #72, but splits the older broad minimap/fog/move/build/cancel HUD scenario into a movement/fog/move test and a focused Command Hall building placement/cancel test so each has its own hosted browser context and timeout budget.
- v0.16.6 keeps hosted first-campaign coverage intact after run #75, but lets the first-campaign training assertion fall back to the existing scene-backed training command helper if visible command clicks never expose a queue, and accepts newly trained Militia that have already reached the rally point.
- v0.16.7 changes runtime combat/control behaviour narrowly after Emmanuel's manual retest: melee visible-contact tolerance, local melee building contact, move-away suppression preservation, and conservative attack-hover hit tolerance. Rerun GitHub Actions CI Release Matrix Dry Run after push.
- v0.16.8 adds post-combat-fix verification docs, control-lab coverage for the v0.16.7 manual issues, and a public-repo safety audit. The v0.16.7 push run #78 only executed automatic Fast confidence, so manual CI Release Matrix Dry Run remains required for the enabled release lanes.
- v0.16.9 expands deterministic manual-retest proxy coverage to 18 control scenarios, adds first external tester docs, and keeps worker construction/design and visual-readability work docs-only. Push run #79 for v0.16.8 was Fast confidence only, then workflow-dispatch run #80 on the same `ad4eee0` commit passed Fast confidence, Release simulator, and the enabled hosted release matrix groups: deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke. Optional visual QA and full release e2e were skipped remotely.
- v0.16.10 freezes the current post-combat-fix candidate for Emmanuel retest or a 2-5 tester batch, adds backlog triage and public-safety docs, and expands the private package tester kit with release-candidate notes, Emmanuel retest checklist, short tester message, short feedback form, and route assignments. Push run #83 for `83f146e` passed Fast confidence only; no exact-final workflow-dispatch matrix was found for `83f146e`.
- v0.16.11 adds exact-final CI/release notes, ready-to-copy GitHub issue templates, tester launch packet index, and a no-code freeze note. Push run #84 for `7cc6eff` passed Fast confidence only; no exact-final workflow-dispatch matrix was found for `7cc6eff`. Run #80 on `ad4eee0` remains the enabled release-matrix evidence for the post-v0.16.7 runtime stack.
- v0.16.12 changes runtime combat/control narrowly after Emmanuel's `ec0608a` Tutorial retest: stationary visible-contact melee reacquisition, post-target-death Hold Ground contact rules, immediate melee contact over distant explicit targets, and top/head hover tolerance. Rerun GitHub Actions CI Release Matrix Dry Run after push.
- v0.16.13 follows the failed `bd26de3` package retest and widens only the local melee visible-contact boundary from the 57px Stone Imp cutoff to cover the 64px browser/manual proxy case. Rerun GitHub Actions CI Release Matrix Dry Run after push.
- v0.17 starts the post-combat-control polish/design line: Tutorial objective panel drag/Hide/Reset is session-only, Tutorial enemy escalation uses existing Story pacing only in Tutorial launches, and worker economy remains design-only. No worker construction, save migration, runtime art/assets, or global balance rewrite is included.
- v0.17.1 is a narrow Tutorial polish follow-up after Emmanuel's 171ba86 retest: whole safe-panel drag, existing-floating-text incoming `HIT -N` player damage feedback, and slower Tutorial-only enemy income/training/attack pacing. No worker construction, global AI/balance, save, art, unit/building/map/faction, or combat-control rewrite is included. Rerun GitHub Actions after push because runtime Tutorial behaviour changed.
- v0.17.2 is a narrow Tutorial polish follow-up after Emmanuel's a990f11 retest: Stone Imp hits against Aster now show compact incoming `-N` damage, incoming direct damage no longer includes `HIT`, and Tutorial-only enemy training/income/attack pacing is eased further. No worker construction, global AI/balance, save, art, unit/building/map/faction, or combat-control rewrite is included. Rerun GitHub Actions after push because runtime Tutorial behaviour changed.
- v0.17.3 is a narrow Tutorial/combat UI follow-up after Emmanuel's e448d18 retest: small melee units share the visible-contact floor for troop/Stone Imp/Wild Hound adjacency, explicit attack-target path failures suppress the no-path floating warning, selected side panel Hide/Show is session-only, and command buttons show explicit `Cost: ...` text. No worker construction, global AI/balance, save, art, unit/building/map/faction, or economy rewrite is included. Rerun GitHub Actions after push because runtime combat/UI behaviour changed.
- v0.17.4 is a narrow production-spawn/movement follow-up after Emmanuel's 532007d retest: trained units resolve spawn points against pathfinding/building-footprint clearance, and move-ordered units recover from blocked building start cells. No worker construction, global AI/balance, save, art, unit/building/map/faction, economy rewrite, or Tutorial pacing change is included. Rerun GitHub Actions after push because runtime movement/production behaviour changed.
- v0.17.5 fixes near-base invisible blockers by making exact world-point walkability use padded building rectangles inside coarse static cells and by allowing exact walkable endpoints. The final v0.17.5 handoff package was clean, and the GitHub Actions release matrix was green before v0.18 started.
- v0.18 adds the first Worker construction foundation only: Command Hall trains Worker, Worker builds Barracks, assigned Worker proximity gates construction progress, incomplete Barracks cannot produce, and completed Barracks keeps existing production. Command Hall no longer exposes direct Barracks/Mystic Lodge/Watchtower construction commands; Tutorial keeps its step count but routes the Barracks objective through Worker construction. No harvesting, repair, enemy construction AI, multiple-worker acceleration, save migration, new factions/maps, Patrol, formations, or runtime art/assets are included. Rerun GitHub Actions after push because runtime construction/production behavior changed.
- v0.18.2 expands Worker construction to the existing player building set only: Barracks, Mystic Lodge, and Watchtower. Command Hall remains Worker-training only, incomplete Watchtowers cannot attack, Tutorial keeps the Worker Barracks route, and no harvesting, repair, enemy construction AI, save migration, new factions/maps, Patrol, formations, runtime art/assets, or global economy rebalance are included. Rerun GitHub Actions after push because runtime construction options changed.
- v0.18.3 fixes Worker construction move-away/pause/resume and compact building-cluster pathing only. Explicit player move/attack orders pause construction intent, construction resumes only when the assigned Worker returns to range or construction intent is reissued, exact blocker interiors remain solid, and exact open edge points stay reachable. Rerun GitHub Actions after push because runtime construction/pathing changed.
- v0.18.3 baseline accepted after GitHub Actions CI Release Matrix Dry Run #26365296115 passed on `main` / `ce43d0e`: Fast confidence, Release simulator, and all six hosted release-matrix groups succeeded. Treat `ascendant-realms-private-playtest-ce43d0e` as the current Worker construction foundation baseline.
- v0.19 clarifies production roles without adding new content: Command Hall trains Workers only, Barracks owns basic army training and existing basic troop research, Mystic Lodge owns existing Acolyte/Aether Study actions, Watchtower remains completed-only defense, and incomplete buildings stay inactive with clearer role/unlock copy. Rerun GitHub Actions after push because runtime production ownership and UI changed.
- v0.19.1 verifies and lightly polishes the v0.19 production architecture before v0.20. It adds production-role audits, a focused hosted Tutorial proxy, clearer Command Hall/Mystic Lodge/Watchtower/incomplete-building copy, and a narrow hosted-layout expectation fix after exact v0.19 workflow-dispatch run #113 failed only stale Command Hall build/upgrade layout assertions.
- v0.20 adds the first small building-owned tech-tree layer: Command Hall core upgrade `Camp Foundations I`, Barracks-owned existing troop upgrades, Mystic Lodge `Aether Study I`, and Watchtower defensive upgrade `Sentry Bracing I`. Rerun GitHub Actions after push because runtime upgrade data, upgrade effects, and upgrade UI changed.
- v0.20.1 closes out v0.20 without runtime changes: `ae3d80d` was pushed, Fast confidence passed, package metadata now names the closeout checkpoint, and a manual workflow_dispatch release matrix with `run_release_matrix=true` remains recommended for exact remote hosted/simulator evidence.
- v0.21 adds the first safe Worker repair foundation: Workers can repair damaged friendly completed buildings, explicit move/attack orders pause repair intent, moving back or reissuing Repair resumes, incomplete buildings remain construction-only, and enemy/full-health buildings cannot start repair. Rerun GitHub Actions after push because runtime Worker action and HUD behavior changed.
- v0.21.1 closes out v0.21 without runtime changes: `79d038b` was pushed, Fast confidence passed, package metadata now names the closeout checkpoint, and a manual workflow_dispatch release matrix with `run_release_matrix=true` remains recommended for exact remote hosted/simulator evidence because push workflow rules skip those lanes.
- v0.21.2 follows Emmanuel's `f6a121b` Worker repair retest: construction and repair now require explicit Worker commands plus range instead of proximity-only start/resume, explicit Worker attack works against valid enemy buildings through existing weak Worker combat, idle Workers still do not auto-attack buildings by default, status badges sit beside healthbars, and future crossed-swords/hammer cursor affordances are docs-only. Rerun GitHub Actions after push because runtime Worker intent, combat targeting, and UI feedback changed.
- v0.21.3 follows Emmanuel's FAIL / MIXED Worker attack/status retest: explicit Worker building attacks now visibly and measurably damage valid enemy buildings through an explicit-order-only damage floor, Worker building hits show floating damage when enabled, idle Workers still do not auto-attack buildings, and Burn/status markers render as a labeled chip above the health bar. Rerun GitHub Actions after push because runtime combat/UI feedback changed.
- v0.22 keeps the existing capturable resource-site economy and adds explicit Worker assignment to friendly captured sites for a small site-local income bonus. Proximity alone does not assign Workers, baseline site income remains unchanged, and no classic carry/drop-off harvesting, cargo, drop-off loop, enemy worker mining AI, enemy construction AI, runtime art/assets, or save migration is included. Rerun GitHub Actions after push because runtime economy/Worker command UI changed.
- v0.23 adds controlled resource-site upgrade depth and Worker slot expansion: Level 1 captured sites keep one Worker slot, Level 2 improved sites add a modest site-local upgrade bonus and two Worker slots, and site loss clears slots/level. No classic carry/drop-off harvesting, enemy Worker mining AI, enemy construction AI, runtime art/assets, or save migration is included. Rerun GitHub Actions after push because runtime economy/Worker command UI changed.
- v0.24-v0.25 adds controlled enemy resource-site strategy and economy pressure: enemy AI can capture, retake, defend, upgrade, and raid around resource sites; enemy Worker slots are abstract logistics only; no classic carry/drop-off harvesting, full enemy Worker economy, runtime art/assets, save migration, global rebalance, broad pathing rewrite, Patrol, formations, new factions, or new maps are included. Rerun GitHub Actions after push because runtime enemy AI/economy behavior changed.
- v0.26-v0.27 adds abstract enemy base development, existing-tech progression, staged escalation, and defensive reserves: enemy AI can fortify, research, defend base/sites, and escalate when economy/site control is healthy. No classic harvesting, visible enemy Workers, enemy construction placement, runtime art/assets, save migration, global rebalance, broad pathing rewrite, Patrol, formations, new factions, or new maps are included. Rerun GitHub Actions after push because runtime enemy AI/upgrade behavior changed.
- v0.28-v0.29 adds the first safe player hero RPG foundation: live battle XP, modest live level-up stat gains, readable ability cooldown/mana states, and victory results battle XP summaries. No new factions/maps, runtime art/assets, save migration, broad AI/pathing rewrite, global rebalance, huge ability roster, inventory overhaul, enemy hero system, Patrol, or formations are included. Rerun GitHub Actions after push because runtime hero progression, HUD, and reward behavior changed.
- v0.29.1 is a closeout lane for blocked remote CI status, local fallback verification notes, and hero progression retest packaging. Follow-up commits add test-only hosted e2e stabilization and remote status docs. No runtime gameplay, balance, map, faction, asset, save, pathing, AI, or content behavior changed.
- v0.29.2 recovers the hosted `deep-battle` release-matrix lane before v0.30. No runtime gameplay changed. Do not start v0.30 or send a package while hosted `deep-battle` is red or undocumented.
- v0.30-v0.31 adds protected rival champion AI rules and preview-only relic reward results. Runtime/reward checkpoint commit `4b72481` passed local verification and Fast confidence, then two hosted deep-battle harness follow-ups (`e466870`, `62e35ae`) isolated minimap/canvas actionability timing and a stale rally-order assertion. Manual release-matrix run `26519266738` on `62e35ae` passed Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`. The clean package must name `v0.30-v0.31 rival champion and relic reward foundation`, include the v0.30-v0.31 docs, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.
- v0.32-v0.33 adds persistent relic inventory and one-slot hero relic loadout on top of existing inventory/equipment saves. It uses no save-version bump, blocks Tutorial/no-reward grants, auto-grants the tiny source relic pool after eligible rival champion defeats, and converts unique duplicates without repeat-farm loops. Rerun the requested release/package matrix because runtime reward, save, Results, Hero Inventory, and HUD behavior changed. The clean package must name `v0.32-v0.33 persistent relic inventory and hero loadout foundation`, include the v0.32-v0.33 docs, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.
- v0.34-v0.35 adds a tiny inline relic reward choice and Warrior/Seer/Commander build identity copy while keeping the existing three relics and one relic slot. It uses no save-version bump, blocks Tutorial/no-reward choices, offers the source champion relic first plus one unowned alternate when possible, and preserves unique duplicate conversion only when every relic is owned. The clean package must name `v0.34-v0.35 relic reward choice and hero build identity`, include the v0.34-v0.35 docs, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.
- v0.36-v0.38 adds a tiny Warrior/Seer/Commander hero skill tree, modest ability upgrades, and light equipped-relic synergy. It uses no save-version bump, existing hero skill points, existing ability definitions, existing allocated-skill saves, and the existing three relics/one relic slot. The clean package must name `v0.36-v0.38 hero skill tree and relic-build synergy foundation`, include the v0.36-v0.38 docs, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.
- v0.39-v0.41 adds campaign first-clear/replay state, mission reward labeling, one-time optional objective credit, and replay-safe campaign reward rules. It uses one backward-compatible campaign save field, no save-version bump, existing campaign nodes/maps, existing Results surfaces, existing relic choice, and existing hero XP/skill reminders. The clean package must name `v0.39-v0.41 campaign progression and mission reward foundation`, include the v0.39-v0.41 docs, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.
- v0.45-v0.47 adds a content-driven Act 1 campaign spine, difficulty pacing labels, and onboarding/next-action copy using existing campaign nodes/maps, mission metadata, Results surfaces, hero progression, and relic guidance. It uses no save-version bump and no new save fields. Full local release timed out at 40 minutes as non-pass evidence, but all three local release shards, required hosted lanes, visual QA, controls, content/art validation, and unit/build gates passed. The clean package must name `v0.45-v0.47 Act 1 campaign spine and onboarding polish`, include the v0.45-v0.47 docs, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.
- v0.48-v0.50 adds deterministic Act 1 playability telemetry, release-candidate copy polish, replay/reward clarity, and package hardening without gameplay-number changes or save changes. The clean package must name `v0.48-v0.50 Act 1 playability and release-candidate stabilization`, include the v0.48-v0.50 docs plus `ACT1_PLAYABILITY_TELEMETRY.md/json`, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`. Full local release timed out at 40 minutes as non-pass evidence; hosted production-preview lanes, visual QA, controls, unit/build/content/art gates, and local release shards passed after manually verifying a local dev server for the shard fallback.

## Required Automated Checks

1. Unit and pure-rule tests:

```bash
npm test
```

Expected current prototype result:

```text
PASS: 46 test files, 351 tests
```

Current v0.15 checkpoint result:

```text
PASS: 55 test files, 393 tests
```

Current v0.16.2 checkpoint result:

```text
PASS: 56 test files, 406 tests
```

Current v0.16.7 checkpoint result:

```text
PASS: 57 test files, 414 tests
```

Current v0.16.8 checkpoint result:

```text
PASS: 57 test files, 414 tests
```

Current v0.16.9 checkpoint result:

```text
PASS: 57 test files, 415 tests
```

Current v0.16.12 checkpoint result:

```text
PASS: 57 test files, 421 tests
```

Current v0.17 checkpoint result:

```text
PASS: 57 test files, 422 tests
```

Current v0.17.1 checkpoint result:

```text
PASS: 58 test files, 425 tests
```

Current v0.17.4 checkpoint result:

```text
PASS: 60 test files, 431 tests
```

Current v0.18 checkpoint result:

```text
PASS: 61 test files, 440 tests
```

Current v0.18.2 checkpoint result:

```text
PASS: 61 test files, 442 tests
```

Current v0.18.3 checkpoint result:

```text
PASS: 61 test files, 450 tests
```

Current v0.19 checkpoint result:

```text
PASS: 61 test files, 454 tests
```

Current v0.19.1 checkpoint result:

```text
PASS: 62 test files, 458 tests
```

Current v0.20 checkpoint result:

```text
PASS: 63 test files, 465 tests
```

Current v0.20.1 checkpoint result:

```text
PASS: 63 test files, 465 tests
```

Current v0.21 checkpoint result:

```text
PASS: 64 test files, 478 tests
```

Current v0.21.2 checkpoint result:

```text
PASS: 65 test files, 485 tests
```

Current v0.21.3 checkpoint result:

```text
PASS: 65 test files, 485 tests
```

Current v0.22 checkpoint result:

```text
PASS: 66 test files, 500 tests
```

Current v0.23 checkpoint result:

```text
PASS: 66 test files, 506 tests
```

Current v0.24-v0.25 checkpoint result:

```text
PASS: 66 test files, 516 tests
```

Current v0.26-v0.27 checkpoint result:

```text
PASS: 66 test files, 522 tests
```

Current v0.28-v0.29 checkpoint result:

```text
PASS: 72 test files, 533 tests
```

Current v0.29.1 checkpoint result:

```text
PASS: 72 test files, 533 tests
```

Current v0.16.13 checkpoint result:

```text
PASS: 57 test files, 421 tests
```

2. Standalone content validation:

```bash
npm run validate:content
```

Expected current prototype result:

```text
PASS: Ascendant Realms content validation passed.
```

This gate runs the content validator without opening the game UI. It should be used before trusting new or edited data for units, buildings, abilities, rewards, campaign nodes, maps, rivals, Stronghold upgrades, campaign modifiers, tutorial metadata, enemy pressure plans, visual asset metadata, and future expansion metadata. The CLI path also checks runtime visual asset file paths without bundling Node filesystem checks into the browser boot path.

For future non-runtime Cinderfen style-frame intake metadata, also run:

```bash
npm run validate:art-intake
```

Expected current intake result:

```text
PASS: Art intake validation passed.
```

This gate validates JSON source/license metadata and any future review-manifest JSON under `art-review/cinderfen-style-frames/metadata/`. It is intentionally metadata-only, passes with an empty intake, does not require image files unless metadata marks a candidate as submitted, and does not make any candidate safe for runtime use by itself.

3. Production build:

```bash
npm run build
```

Expected current prototype result:

```text
PASS: TypeScript compile and Vite production build
Current output shape after the v0.4 Phaser vendor split:
- app JS chunk: assets/index-DY-3qp2P.js, 477.04 kB / gzip 127.86 kB
- Phaser vendor chunk: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB
- CSS chunk: assets/index-BiGdwuWI.css, 44.51 kB / gzip 9.16 kB
```

Known warning:

```text
Some chunks are larger than 500 kB after minification.
```

This Vite warning is expected for the current Phaser vendor chunk and is not a release blocker unless a later optimization explicitly targets lazy scene/data loading or warning-policy cleanup. The app chunk is below the default 500 kB threshold after the v0.4 vendor split; the warning remains because Phaser itself is still large.

4. Browser smoke lanes:

```bash
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
```

Expected current prototype result:

```text
PASS: 8 Playwright tests for smoke:fast
PASS: 14 Playwright tests
```

`npm run test:e2e:smoke:fast` runs the eight `@ci-fast` smoke checks used by automatic GitHub Fast confidence: main menu, hero name input, Tutorial entry/return, Tutorial exit without saving, Settings persistence, Settings runtime accessibility in battle, New Campaign map/locked-node checks, and inventory reachability.

`npm run test:e2e:smoke` runs all 14 tests in `tests/e2e/smoke.spec.ts` and is the full smoke browser check. It keeps main menu, Tutorial / Proving Grounds no-reward completion and exit, Settings, New Campaign, campaign launch, Cinderfen reward/save/duplicate-prevention, skirmish, difficulty, and inventory smoke coverage visible. The v0.10 tutorial e2e lane review keeps full Tutorial completion in smoke while the lane remains inside the local watch band; move completion deeper only if local smoke repeatedly grows beyond that band. v0.10 did not add smoke tests or change lane counts.

v0.11.3 gives only `settings screen persists accessibility options` a 60s per-test budget after GitHub Actions evidence showed this combined settings-persistence plus in-battle runtime-application check can exceed the global 35s Playwright timeout on hosted runners. The test remains in smoke and keeps its real persistence/runtime assertions. If `campaign Border Village launches a battle scene` fails immediately after a settings timeout, first treat it as possible browser/context cascade; if it fails again after settings passes, investigate it independently.

v0.16.1 supersedes the combined settings path shape for Fast confidence: `settings screen persists accessibility options @ci-fast` now covers save/reopen persistence and localStorage/document dataset assertions, while `settings accessibility options apply in battle @ci-fast` covers floating text disabled, fog override, colorblind minimap runtime state and marker colors, and battle pause/resume. v0.16.2 keeps the persistence test at a scoped 60s budget and gives only the runtime battle-application test a scoped 90s budget after GitHub run #66 showed hosted production-preview smoke could exceed 60s around battle resume. v0.16.3 keeps the assertions and timeout but shortens only the settings runtime smoke Menu/Resume normal-click attempts before verified DOM-control fallback, because run #68 showed both DOM fallbacks fired only after hosted CI had already spent the test budget. Inventory remains a separate `@ci-fast` smoke test; if it fails during browser context setup immediately after settings failures, first investigate settings/context pressure before changing inventory behavior.

v0.11.4 stabilizes seeded smoke setup by waiting for a ready main menu before localStorage mutation and navigating back to `/` after writing seeded saves instead of relying on `page.reload()`. `skirmish difficulty selection changes fog and starting pressure` now has a scoped 60s budget because it launches two seeded battles back-to-back and GitHub Actions evidence showed the seed/reload path could exceed the global timeout. The test remains in smoke and keeps its fog/pressure assertions.

v0.11.8 extends the same hosted-safe navigation rule to deep-flow and extended smoke release paths: remaining raw e2e reloads were replaced with app-root navigation plus real main-menu assertions, and reported release-path clicks now use `clickReady` without `force`. Full smoke remains the 12-test coverage lane.

5. Full browser release-gate suite:

```bash
npm run test:e2e:release
```

Expected current prototype result:

```text
PASS: 67 Playwright tests
```

Current v0.26-v0.27 checkpoint result:

```text
PASS: 89 Playwright tests
```

Current v0.28-v0.29 checkpoint result:

```text
Attempted: npm run test:e2e:release exceeded a 30-minute tool window before producing usable output.
PASS equivalent release coverage: shard1of3 44 tests, shard2of3 34 tests, shard3of3 14 tests.
```

Current v0.29.2 hosted deep-battle recovery result:

```text
PASS: test:e2e:smoke:fast 8 tests, test:e2e:smoke 14 tests, hosted deep-battle 27 tests, hosted smoke 14 tests, hosted deep-campaign-pressure 7 tests, visual:qa 5 tests / 18 screenshots / 0 console errors / 0 retries.
Original remote CI run 26447947052 was blocked before checkout by GitHub HTTP 403 account-suspension response; no remote repo tests ran in that historical run.
Remote checkout recovered: push run 26484639124 on 6124d71 passed Fast confidence with checkout success.
Remote release matrix before v0.29.2: manual run 26484817685 on 6124d71 passed Fast confidence, Release simulator, deep-meta, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke; hosted deep-battle failed after tests ran.
Latest remote release matrix: manual run 26493804376 on b7604e5 passed Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke.
Final package verification: npm run verify:playtest-package passed with 90 checks against a clean v0.29.2 package with no -dirty suffix.
```

Current v0.30-v0.31 rival champion/relic foundation result:

```text
PASS: npm test 73 files / 540 tests, npm run build, validate:content, validate:art-intake, smoke:fast 8 tests, smoke 14 tests, playtest controls normal/extended/verify, hosted deep-meta 12 tests, hosted deep-battle 27 tests, hosted smoke 14 tests, hosted deep-campaign-pressure 7 tests, visual:qa 5 tests / 18 screenshots / 0 console errors / 0 retries, and git diff --check.
ATTEMPTED: npm run test:e2e:release. One deep-meta New Campaign transition helper failed after the click had already reached hero creation. The narrow helper call fix passed in the targeted test and hosted deep-meta group.
Remote follow-up: push runs 26510324409, 26512926475, and 26518961193 passed Fast confidence. Manual matrix runs 26510633476 and 26513207423 isolated hosted deep-battle harness issues. Manual matrix run 26519266738 on 62e35ae passed Fast confidence, Release simulator, hosted deep-meta, hosted deep-battle, hosted deep-campaign-pressure, layout-core, layout-cinderfen, and hosted smoke; full release e2e and optional visual QA were skipped by dispatch inputs.
Final package must be regenerated from the final docs/package closeout commit after remote status is documented.
```

Current v0.32-v0.33 persistent relic inventory/loadout result:

```text
PASS: focused relic/rival/save/progression/results/HUD/content tests with 107 tests, npm test 73 files / 546 tests, npm run build, npm run validate:content, npm run validate:art-intake, targeted hosted Ashen Outpost relic reward/equip proxy, fast smoke 8 tests, full smoke 14 tests, controls normal/extended/verify, hosted deep-battle 27 tests, hosted smoke 14 tests, hosted deep-campaign-pressure 7 tests, dirty pre-commit package generation, package verification 100 checks, visual QA 5 tests / 18 screenshots / 0 console errors / 0 retries, and git diff --check.
Extra local full release: npm run test:e2e:release was attempted and reported transient local dev-server boot/layout/smoke timing failures; exact affected file:line rerun passed 7 tests. Required hosted release lanes are green.
Final clean package must be regenerated from the final checkpoint commit before tester distribution.
```

Current v0.34-v0.35 relic reward choice/build identity result:

```text
PASS: focused relic/rival/results/HUD/content/package tests with 70 tests, npm test 73 files / 549 tests, npm run build, npm run validate:content, npm run validate:art-intake, targeted hosted Ashen Outpost relic-choice/equip proxy, fast smoke 8 tests, full smoke 14 tests, controls normal/extended/verify, hosted deep-battle 27 tests, hosted smoke 14 tests, hosted deep-campaign-pressure 7 tests, visual QA 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification 105 checks, and git diff --check.
ATTEMPTED: npm run test:e2e:release. The first run exposed a mobile-short layout itinerary budget issue and the exact case passed after a scoped hosted-layout-core timeout. The second run exposed the new relic-choice click helper treating a successful disappearing choice button as failure; focused Ashen Outpost and hosted deep-campaign passed after the helper-call fix. Required hosted release lanes are green.
Final clean package must be regenerated from the final checkpoint commit before tester distribution.
```

Current v0.36-v0.38 hero skill tree/relic-build synergy result:

```text
PASS: focused skill/save/ability/HUD/results/content/package tests with 109 tests, npm test 73 files / 554 tests, npm run build, npm run validate:content, npm run validate:art-intake, targeted hosted skill-tree/relic-synergy proxy with 2 tests, fast smoke 8 tests, full smoke 14 tests, controls normal/extended/verify, hosted deep-battle 27 tests, hosted smoke 14 tests, hosted deep-campaign-pressure 7 tests, visual QA 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification 112 checks, and git diff --check.
NOT RUN: npm run test:e2e:release. Required hosted release lanes plus visual QA are the final release evidence for this checkpoint.
Final clean package must be regenerated from the final checkpoint commit before tester distribution.
```

Current v0.39-v0.41 campaign progression/mission reward result:

```text
PASS: TypeScript no-emit, focused save/campaign/view-model/results tests with 110 tests, focused package validation tests with 3 tests, npm test 73 files / 558 tests, npm run build, npm run validate:content, npm run validate:art-intake, targeted hosted campaign objective/replay proxy with 2 tests, fast smoke 8 tests, full smoke 14 tests, controls normal/extended/verify, hosted deep-battle 27 tests, hosted smoke 14 tests, hosted deep-campaign-pressure 7 tests, visual QA 5 tests / 18 screenshots / 0 console errors / 0 retries, dirty pre-commit package generation, package verification 119 checks, and git diff --check.
ATTEMPTED: npm run test:e2e:release. The extra optional local full-suite run hit the 30-minute command timeout before returning a summary; temporary Playwright/dev-server processes from that attempt were stopped. Required hosted release lanes plus visual QA are the final release evidence for this checkpoint.
Final clean package must be regenerated from the final checkpoint commit before tester distribution.
```

Current v0.16.7 checkpoint result:

```text
PASS: 79 Playwright tests
```

Current v0.15 checkpoint result:

```text
PASS: 75 Playwright tests
```

Current v0.16.4 checkpoint result:

```text
PASS: 77 Playwright tests
```

`npm run test:e2e` also remains the full Playwright suite. Use a long timeout. The full suite intentionally runs with one worker for stability. The v0.16.4 checkpoint full release gate is 77 tests across the release spec set while smoke is 14 tests. The v0.16.4 all-in-one release run took about 40.9 minutes locally on Windows; set command timeouts accordingly.

6. Optional CI sharded release gate:

```bash
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Both shards must pass to equal the full release gate. Keep `npm run test:e2e:release` as the canonical one-command local release check; the shard scripts are mainly for CI matrix jobs where they can run in parallel. If run sequentially on a local machine, the total runtime may not be better than the full suite and reports are split by shard.

Latest local 2-shard verification after the v0.10 final gate, 2026-05-11:

```text
Shard 1: passed, 55 Playwright tests in about 24.3m.
Shard 2: passed, 12 Playwright tests in about 4.8m.
```

The current 2-shard split is coverage-preserving but uneven because shard 1 includes the deep-flow and layout-heavy side of the suite. Keep this as a CI wall-clock optimization, not a mandatory local workflow.

v0.8 adds optional 3-shard release scripts for CI runs that need a less lopsided split:

```bash
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

All three 3-shard scripts must pass to equal the full release gate. They preserve the canonical one-command release lane and the existing 2-shard scripts. Current list checks split the 67-test suite into 28 deep-flow tests, 27 layout+pressure tests, and 12 smoke tests. They do not change Playwright workers, parallelism, serving mode, or coverage.

Latest v0.10 local 3-shard verification:

```text
Shard 1 of 3: passed, 28 Playwright tests in about 11.5m.
Shard 2 of 3: passed, 27 Playwright tests in about 12.9m.
Shard 3 of 3: passed, 12 Playwright tests in about 4.9m.
```

Final verification should still run the full release lane, both existing 2-shard scripts, and all three 3-shard scripts before push. The 3-shard scripts remain the additive CI option; they do not replace the canonical full release lane.

v0.11.12 keeps the explicit hosted release groups against production preview through `playwright.hosted-release.config.ts`, with additional test-only interaction hardening for hosted DOM controls, battle-loaded readiness, layout measurement, side-panel scrolling, and canvas movement:

```bash
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
```

All six hosted groups must pass to equal the same full release suite in GitHub Actions; the v0.16.4 checkpoint hosted group counts are 12 deep-meta, 12 deep-battle, 7 deep-campaign-pressure, 20 layout-core, 12 layout-cinderfen, and 14 smoke tests. They are additive, manual-only CI ergonomics for hosted runners and do not remove or replace the full release lane, the 2-way scripts, or the local 3-way scripts. The hosted groups intentionally avoid `--fully-parallel` and use production preview instead of Vite dev server after GitHub run #17 showed dev-server hosted release groups still produced seed/navigation, actionability, layout, and extended-smoke instability. Hosted helpers keep assertions intact while allowing a verified DOM click fallback only for real enabled DOM controls after normal Playwright click actionability fails. Canvas/world actions still use real pointer input. v0.16.2 keeps behaviour-mode switching coverage in the dedicated hosted behaviour gauntlet instead of duplicating those transitions inside the older minimap/fog/build/cancel/command-hall HUD test. v0.16.4 keeps that older HUD test focused on minimap/fog/build/cancel/command hall behaviour and asserts fog/cancel via scene state when hosted pressure messages can legitimately occupy the status line.

Run `npm run build` before using these hosted scripts locally. The GitHub release matrix jobs already run `npm run build` before the hosted group command.

## GitHub Actions CI Dry Run

v0.11.1 adds `.github/workflows/ci.yml`.

Automatic `pull_request` and `push` to `main` fast confidence runs:

```text
npm ci
npx playwright install --with-deps chromium
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke:fast
npm run smoke:preview
```

Manual `workflow_dispatch` inputs:

| Input | Runs | Use when |
| --- | --- | --- |
| `run_visual_qa` | `npm run visual:qa` and uploads `visual-qa/latest/` | Human screenshot review is needed. |
| `run_release_matrix` | Explicit hosted release groups plus `npm run playtest:sim` | CI release gate dry-run or pre-freeze confidence on GitHub-hosted runners. |
| `run_full_release` | `npm run test:e2e:release` | Major freeze or one-command release-lane confirmation in CI. |

The workflow uses Node 22, `npm ci`, Playwright Chromium install, npm cache, no secrets, no paid services, and short-retention artifacts. v0.11.2 could not inspect remote Actions runs from the Codex environment because `gh` is unavailable, the GitHub connector token is expired, and unauthenticated Actions API access returns `404 Not Found`. Use `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` to collect the first hosted-run URL, `fast-confidence` duration, `smoke:preview` result, manual-job status, and artifact evidence from GitHub UI. Do not weaken local release gates until CI has proven itself on the remote.

v0.11.6 remote evidence confirmed automatic Fast confidence was green on commit `1948ce5`, then showed the manual `Optional visual QA` job timing out during setup navigation rather than failing a screenshot or console-error assertion. v0.11.7 remote evidence on commit `caeff57` then showed navigation was no longer the issue, but a hosted `page.screenshot` call hung around the Cinderfen Crossing tablet capture. The visual QA job remains manual and coverage-preserving; rerun it from GitHub UI when human screenshot review is needed and inspect `visual-qa-latest` for `index.md`, 18 screenshots, 5 capture groups, screenshot retry status, and 0 browser console errors.

v0.11.8 remote evidence showed the manual 3-way release matrix was the remaining hosted lane: shard 1 failed in deep-flow `seedSave` on raw reload, shard 2 failed in seeded Cinderfen layout setup navigation, and shard 3 stalled on Broken Ford actionability. Rerun the manual `run_release_matrix` workflow input after v0.11.8 and check that retries are logged with context and recover without missing any release tests.

v0.11.9 remote evidence showed the v0.11.8 helper hardening was not enough for GitHub-hosted wall-clock limits: shard 1 and shard 2 hit the 35-minute job timeout, while shard 3 still showed hosted browser/context instability in extended smoke. The manual `run_release_matrix` input now runs six hosted shards named `shard-1-of-6` through `shard-6-of-6` with a 45-minute per-shard timeout, plus the unchanged release simulator. The old hosted 3-way jobs should not appear in new manual release-matrix runs, but the local 3-way scripts remain available.

v0.11.10 remote evidence on run #15 showed the v0.11.9 native 6-way split was still unstable across all hosted shards, with seed setup navigation aborts, right-click movement actionability, layout launch timing, and extended-smoke seeded campaign failures. The manual `run_release_matrix` input now runs explicit hosted groups named `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, plus the unchanged release simulator. If rerunning the matrix, expect those six group names rather than `shard-1-of-6` through `shard-6-of-6`.

v0.11.11 remote evidence on run #17 showed the explicit groups were still failing when hosted against Vite dev server. The hosted group scripts now use `playwright.hosted-release.config.ts`, which starts `npm run preview:hosted` on `127.0.0.1:5173` and adds hosted-only Chromium stability flags. The workflow already uses `npx playwright install --with-deps chromium`; no dependency-install change was needed.

v0.11.12 remote evidence on run #19 showed `deep-meta` passing on production preview while `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke` still failed around hosted interaction determinism: Build Barracks click actionability, `Moving` vs `Guarding`, minimap readiness, tutorial-next layout boxes/click hangs, and side-panel command measurement. Rerun the manual `run_release_matrix` workflow input after v0.11.12 and inspect whether any remaining failure is app boot, battle-loaded readiness, DOM actionability, canvas movement, layout measurement, or browser/page/context closure.

7. Optional focused e2e lanes:

```bash
npm run test:e2e:layout
npm run test:e2e:deep
```

`test:e2e:layout` runs responsive/mobile/readability coverage, including Tutorial / Proving Grounds overlay reachability, the v0.6 overlay width guard, and accessibility-era overlay layout checks across desktop, tablet, and mobile viewports. `test:e2e:deep` runs release-critical deep gameplay and save-flow coverage. Enemy Strategic Pressure V1 coverage lives in the full release suite via `tests/e2e/enemy-pressure.spec.ts`; use `npx playwright test tests/e2e/enemy-pressure.spec.ts --reporter=line` for a focused pressure lane. These focused lanes are available for targeted work; they do not replace the full release gate.

8. Deterministic playtest simulator:

```bash
npm run playtest:sim
```

Expected current prototype result:

```text
PASS: 255 simulated runs across 85 campaign battle node/profile summaries
No too-easy nodes
No structural too-hard nodes
Ashen Outpost beatable
No Stronghold warnings
No enemy-pressure warnings
75 pressure-enabled Cinderfen runs
63 triggered pressure runs
12 quiet/untriggered pressure runs
149 pressure warnings
147 losses after pressure
0 simulated reinforcement applications
Cinderfen repeat rewards remain tiny XP/resources with no repeat item roll
```

This command regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.

For v0.16 RTS control/behaviour diagnostics, also run:

```bash
npm run playtest:controls
npm run playtest:controls:extended
npm run playtest:controls:verify
```

Expected v0.16 result:

```text
PASS: normal control lab writes 18 scenario rows
PASS: extended control lab writes 5 deterministic iterations / 90 scenario rows
PASS: verifier checks unique scenario ids, allowed verdicts, metric availability, Markdown/dashboard consistency, and no invented human-feedback claims
```

These commands regenerate `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`, `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`, `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md`, `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json`, `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`, and `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`. They are deterministic automated evidence only; they do not replace Emmanuel's manual retest and are not balance proof.

Latest v0.10 report-gate simulator verification, 2026-05-11:

```text
PASS: 255 simulated runs across 85 campaign battle node/profile summaries.
```

Latest v0.7.3 pressure-playtest interpretation: no balance tuning is applied. Cinderfen Crossing and Cinderfen Watch pressure remain scoped, readable in controlled browser-input review, and warning/telemetry-only for `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold`. Emmanuel's manual checklist remains the missing direct human evidence before any simulator-only reinforcement experiment.

9. Optional visual screenshot QA:

```bash
npm run visual:qa
```

Expected current prototype result:

```text
PASS: 5 Playwright visual QA capture tests
18 review screenshots generated under visual-qa/latest/
Browser console errors recorded in the generated index: 0
Generated index summary records screenshot count 18, console error count 0, desktop/tablet/mobile viewport coverage, capture groups, and screenshot retry status
```

This v0.8.2 lane is optional and review-oriented. It captures main menu, Asset Gallery, Hero Inventory, Tutorial desktop/mobile, campaign map, route-complete campaign map, Skirmish Setup, Cinderfen Crossing desktop/tablet, Cinder Shrine, Crossing pressure warning, Cinderfen Watch, Watch pressure warning, and victory/defeat Results views. It is not a pixel-perfect visual regression test and it does not replace smoke, layout, release, content validation, or simulator gates. Generated screenshots are intentionally ignored by git.

v0.11.6 keeps all 18 targets and console-error failure behavior intact. The single capture test now has a 420s budget because GitHub-hosted runners showed the prior 240s limit could expire during setup navigation, and the shared app-boot helper retries only transient setup-navigation aborts/timeouts before requiring the real main menu.

v0.11.7 supersedes the single-test visual QA shape: the same 18 captures now run as 5 smaller tests with fresh pages, per-screenshot `START`/`DONE` logs, a 45s screenshot timeout, one retry for screenshot timeout/capture failures, and index retry metadata. If hosted visual QA fails, use the last `[visual-qa] START`, `FAIL`, or `RETRY` line to identify the exact screenshot target before changing the harness again.

Future Cinderfen visual work should also review `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md` and `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`. v0.9.1 keeps this lane as human-review evidence: no pixel-perfect diffing, no generated/imported runtime art, and no production approval without source/license metadata plus manifest validation. Tutorial-specific v0.10 observations live in `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.

10. Whitespace diff check:

```bash
git diff --check
```

Expected current prototype result:

```text
PASS: no whitespace errors
```

## Optional Preview Check

After `npm run build`, prefer the automated preview helper:

```bash
npm run smoke:preview
```

Manual fallback:

```bash
npm run preview
```

Open the local preview URL and confirm:

- Main menu renders `Prototype v0.3` and `Cinderfen Route Baseline`.
- Tutorial / Proving Grounds launches and exits without crashing.
- Browser console has no new hard errors.
- Continue/New Campaign, Skirmish, Hero Inventory, Settings, and Asset Gallery are reachable from an appropriate save state.

Browser Use preview sanity is optional after the automated suite. Use the local preview URL printed by Vite for a manual fallback; previous clean preview checks used `127.0.0.1` ports with browser console errors at 0. The current visible product copy is `Prototype v0.3` / `Cinderfen Route Baseline`.

Latest production preview smoke, 2026-05-26:

```text
PASS: http://127.0.0.1:4173/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
PASS: helper-owned preview process tree shut down.
NOTE: v0.11 added `npm run smoke:preview` after v0.10 exposed child-process cleanup friction. The final helper starts Vite preview through the local Vite CLI, uses the project Chromium GPU args, captures console errors, and shuts down the process tree it started.
```

After build-output or chunking changes, run a production preview smoke when feasible and confirm the main menu loads, `Prototype v0.3` / `Cinderfen Route Baseline` copy remains visible, key menu routes open without crashing, browser console errors stay at 0, and the preview process exits cleanly.

## Private Playtest Package Check

For private human playtest distribution, build and verify the package after the normal gate:

```bash
npm run package:playtest
npm run verify:playtest-package
```

The package is written under ignored `artifacts/playtest/ascendant-realms-private-playtest-<commit>/`. Send that folder or a manual zip, not the full repo. The verifier checks the built game, tester README, feedback form, route assignment plan, v0.16 control retest materials, v0.16.12 and v0.16.13 retest/fix notes, current v0.17-v0.82 implementation/retest/closeout docs, build metadata, local server helpers, package-safe relative asset URLs, and absence of `node_modules`, `.git`, raw private feedback folders, and obvious secret files.

If the package name ends in `-dirty`, the working tree had uncommitted changes when it was created. Regenerate after the checkpoint commit before sending to outside testers.

## Manual QA Areas Not Fully Automated

- Full human-paced Border Village and Old Stone Road playthroughs on Easy, including first warning, Barracks timing, first trained unit, and first enemy contact.
- Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save, including Veyra of the Cinders and Gorak Emberhand scout/readability checks.
- Ashen Outpost with and without Chapel repair, including Captain Malrec readability, Hold the Line ability readability, final approach readability, tower pressure, and objective-panel placement.
- Stronghold Tier I and II purchase feel in a real campaign economy, especially Watch Post II and Quartermaster Stores II.
- v0.7.3 follow-up: Emmanuel's manual Cinderfen Crossing and Cinderfen Watch pressure checklist, especially warning noticeability during actual unit commands, Cinder Shrine salience, Watch Road fairness, Greedy Economy timeout clarity, Fast Army quick-clear feel, and Retinue + Training Yard II power.
- Reputation hooks in normal campaign flow: Common Folk Marcher Camp discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, and Ashen Covenant Hostile pressure.
- Affixed reward readability in Results and Inventory, including base/affix/total stat copy.
- Retinue and rival readability in normal human-paced play, including whether first-defeat rewards and trophies feel satisfying without becoming mandatory.
- Cinderfen pressure feel in normal human-paced play, including whether pressure warnings are noticed, whether Cinder Shrine and Watch Road responses feel fair, and whether stronger actions should remain warning/telemetry-only.
- Full human-paced Cinderfen route from Ashen Outpost through Overlook, Waystation, Crossing, Watch, and Aftermath, including Cinder Shrine surge/attunement readability and modest reward feel.
- Full human-paced Tutorial / Proving Grounds run using `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`, especially first-30-seconds clarity, twelve-step length, mobile-short overlay readability, building/training/rally timing, enemy pressure fairness, and no-reward completion satisfaction.
- HUD hover/scroll feel and captured-site fog readability under real mouse movement, even though the regression paths now have Playwright coverage.
- Audio behavior with human ears.
- Visual polish across generated/manual UI-kit assets.
- v0.8 visual foundation follow-up: review current Cinderfen battlefield screenshots against `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, and `docs/CINDERFEN_VISUAL_REWORK_SPEC.md` before approving any art sprint.
- Existing asset/source hygiene: future visual work should start with an asset manifest and source/license/status/scale metadata instead of importing new binaries directly.
- Production preview sanity after release packaging.

## Release Notes To Check

- `CHANGELOG.md` describes the current feature baseline.
- `README.md` has current setup, feature summary, known limitations, and verification counts.
- `docs/V03_CINDERFEN_ROUTE_BASELINE.md` records the current route, rewards, simulator/e2e summaries, known risks, forbidden next steps, and recommended next steps.
- `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md` records the v0.4 Settings readability/accessibility pass.
- `docs/SAVE_COMPATIBILITY_AUDIT.md` records current save version 2 behavior and v0.4 compatibility coverage.
- `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md` records the automated route-feel surrogate review and remaining human-feel watch items.
- `docs/FULL_GAME_ROADMAP.md`, `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`, and `docs/V05_SYSTEMS_DESIGN_BRIEF.md` plan future systems without implementing them.
- `docs/V04_POLISH_BACKLOG.md` records safe/medium-risk/high-risk/blocked tiny polish candidates.
- `docs/V05_SAVE_CONTENT_VALIDATION_GATE_REPORT.md` summarizes the v0.5 save, content-validation, determinism, and expansion-readiness gate.
- `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`, `docs/TUTORIAL_SAVE_PERSISTENCE_AUDIT.md`, `docs/TUTORIAL_CONTENT_VALIDATION_GATE.md`, and `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md` summarize the first playable Tutorial / Proving Grounds shell.
- `docs/V08_PERFORMANCE_AUDIT.md`, `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`, and `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md` summarize the v0.8 bundle/performance and e2e runtime work.
- `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, `docs/ASSET_PIPELINE_PLAN.md`, and `docs/CINDERFEN_VISUAL_REWORK_SPEC.md` define the visual foundation without implementing a graphics overhaul.
- `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md` summarizes the v0.8 technical and visual foundation gate.
- `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md` summarizes the current non-runtime Cinderfen style-frame intake pipeline, including metadata templates, validation, scan results, screenshot comparison planning, and the future v0.9.2 review brief.
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md` summarizes the current Tutorial v2 onboarding refinement, including copy, overlay, completion, e2e lane, visual QA, and manual playtest checklist results.
- `ROADMAP.md` marks Cinderfen Overlook, Waystation, Crossing, Watch, Aftermath, the first no-reward Tutorial / Proving Grounds shell, the v0.7.3 pressure playtest gate, v0.8 technical/visual foundation gate, v0.8.1 manifest/screenshot gate, v0.8.2 source/license screenshot gate, v0.9 style-frame spec gate, v0.9.1 intake gate, and v0.10 Tutorial v2 refinement as done, with the next recommended player-facing phase set to v0.10.1 only after Emmanuel's manual checklist feedback.
- `LLM_GAME_HANDOFF.md` marks the current state as the v0.10 tutorial onboarding refinement and warns future sessions not to add rewards, persistence, maps, units, factions, broad systems, generated art, imported art, or runtime visual replacement before their gates are explicit and green.
