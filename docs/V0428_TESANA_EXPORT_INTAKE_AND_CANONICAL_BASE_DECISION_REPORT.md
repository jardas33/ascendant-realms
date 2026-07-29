# v0.428 Tesana Export Intake, Runtime Audit, and Canonical-Base Decision

## Executive decision

**Recommendation: B — donor only.** `WB_tesana` is an immutable, plain Godot 4.3 export with useful breadth, but it is not a safe canonical replacement for the accepted runtime. The export contains gameplay, AI, save, editor-service, and generated/imported asset material that was not runtime-verified in this environment. Its provenance is materially unclear: the source has no standalone license or attribution file, while many asset names identify generated/imported `tripo` material. No Tesana asset was copied into the accepted project.

The runtime portion is intentionally fail-closed. No Godot executable was available on `PATH` or through `V0428_GODOT_BIN`, so the source export was not executed and no fake runtime screenshots were admitted.

## Boundary and baseline

- Accepted baseline: `4a2de384b2f0c3f348f24ff549ab2293f29e3b7f`.
- Accepted project: `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery`.
- Audit branch: `codex/v0428-tesana-intake-audit`.
- Candidate: `D:\Code for projects\WB game like\WB_tesana`.
- `WB_tesana` is not a Git repository and is not tracked by the accepted checkout.
- The workspace-level `.git` directory is not a usable repository; the two Ascendant Realms directories are independent checkouts.
- No merge, staging, copy, upgrade, dependency installation, or source edit was performed.

## Project type and safety audit

Tesana is a Godot 4.3 Forward Plus project with `res://scenes/main.tscn` as its entry scene and a Web export preset. It autoloads gameplay and UI systems plus `addons/tesana_world_editor/scene_export.gd`. That addon opens loopback WebSocket `127.0.0.1:5180` and HTTP `127.0.0.1:5181` services. It does not establish permission to run the source directly; any future runtime review must use a disposable copy with explicit port/process cleanup.

The export has no package manifest or install hooks. It does contain runtime file access for `user://ascendant_save.json`, project asset loading, gameplay scripts, projectile code, AI, and generated/import-cache sidecars. Those are audit findings, not accepted runtime changes.

## Inventory and reference integrity

The pre-runtime source manifest contains 628 files totaling 85,283,160 bytes:

- 40 GDScript files
- 10 scenes
- 75 GLB models
- 19 PNGs
- 120 JPGs
- 45 TRES resources
- 2 shaders
- 14 MP3 files
- 1 font
- imported/generated sidecars and metadata

Static reference scanning found dynamic format-string asset paths, documentation examples, absolute `/var/games/...` paths embedded in the asset manifest, local service URLs, and references that cannot be proven without Godot import/runtime resolution. The structured reference audit preserves the complete findings.

## Content and architecture

The export contains menu, skirmish, campaign, world, worker/building, AI, projectile, save/profile, UI, and editor-service modules. The breadth is real at the source level, but source presence is classified as partial or unable-to-verify where behavior requires runtime execution.

The largest and most fragile areas are the world controller, game world, unit/building systems, loading screen, HUD, profile manager, enemy AI, and the Tesana editor service. Moving those systems into the accepted Phaser/Vite runtime would be a production migration, not an intake action.

## License and provenance

No standalone `LICENSE`, `NOTICE`, credits, or attribution file was found in the export inventory. The export includes `assets/manifest.json`, `assets/generation-meta.json`, `README_EXPORT.md`, and many filenames containing `tripo`, but those do not establish redistribution rights for each model, texture, font, or audio file. License/provenance risk is therefore **HIGH_UNCLEAR_PROVENANCE**. No asset may be integrated until provenance is resolved asset-by-asset.

## Engine compatibility

The accepted project is Phaser 3.90 + TypeScript + Vite with optional historical Godot spike tooling. Tesana is Godot 4.3 Forward Plus with a Web export. Direct runtime replacement has low compatibility and high migration risk. A controlled hybrid remains possible only after provenance, runtime, and asset-level compatibility gates are satisfied.

## Decision matrix

| Strategy | Result | Reason |
| --- | --- | --- |
| A — new canonical base | Reject | Would abandon the accepted state chain and default runtime without verified runtime/provenance. |
| B — donor only | **Recommended** | Preserves the accepted runtime while allowing later, reviewed asset studies. |
| C — controlled hybrid migration | Defer | Potentially useful, but high integration burden and boundary risk. |
| D — reject entirely | Not selected | The export may contain useful authored/generated breadth, subject to proof. |

## Runtime and visual evidence status

Runtime execution is **blocked**, not passed: no Godot executable was available. Therefore the title, skirmish setup, campaign map, gameplay, worker/build menu, placement, AI/combat, save/load, and exit flows remain unverified. Required screenshots are intentionally absent rather than replaced with title cards, source textures, hosted previews, or fabricated compositions. See `v0428-runtime-errors.txt` and `v0428-capture-blocker.txt`.

This is the correct evidence state for an intake audit: it preserves trust and makes the missing dependency explicit.

## Preservation result

The source hash manifest was captured before any runtime attempt. The audit regenerated and compared the source manifest; the source remained byte-for-byte unchanged. The accepted tracked implementation remained at the baseline commit on the isolated audit branch. The intentional pre-existing untracked artifact backlog in the accepted checkout remains preserved and was not staged.

## Validation evidence

- Static audit command: `npm run godot:audit:v0428-tesana-intake`.
- Dedicated validator: `npm run godot:validate:v0428-tesana-intake`.
- Review pack: `artifacts/manual-review/v0428-tesana-export-intake/`.
- Required structured audit files are generated in the review pack.
- Runtime evidence is fail-closed because the engine executable is unavailable.

The retained static ladder actually run on this branch covers 24 existing commands: v0.400, v0.401, and v0.406 through v0.427. All 24 passed. The repository matrix also passed: `npm test` (122 files / 887 tests), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`. These are accepted-project/static checks; they do not substitute for the missing Tesana runtime capture. No claim is made that Tesana runtime screenshots exist.

## Exact v0.429 proposal

**v0.429 — Tesana Disposable Runtime Enablement and Provenance Gate.** Install or provide a reviewed Godot 4.3 executable outside `WB_tesana`, run only from a disposable copy with loopback ports isolated, capture the ten real local flows, verify import/runtime errors, and resolve asset license/provenance before admitting any donor asset. Do not integrate assets or change the accepted runtime in v0.429.

## Final status

The intake decision is donor-only and fail-closed. Neither project was modified by the audit, the accepted runtime/state chain is preserved, and no Tesana asset has entered the accepted project.
