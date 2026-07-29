# v0.429 Tesana Disposable Runtime and Provenance Gate

## Executive result

v0.429 completed the Tesana export intake as an isolated, fail-closed runtime and provenance audit. The original `WB_tesana` source remained immutable. An authentic byte-preserving disposable copy was launched with the official Godot 4.3 Windows x86_64 executable. The local title screen rendered, but real navigation beyond the title did not complete because the fresh copy lacked imported `.godot/imported` resource caches and logged missing UI resources. No downstream gameplay state was fabricated.

The decisive result is **Outcome C — TESANA_DONOR_REJECTED**. No Tesana file is admitted to the accepted runtime. v0.430 is proposed as a bounded canonical Barrosan slice using only accepted, documentary-cleared materials; this report does not start v0.430.

## Baseline and branch

- v0.428 audit commit: `0a6f8f125445ad563bc56af6a676fb929e62de8d`
- v0.428 audit branch / new PR base: `codex/v0428-tesana-intake-audit`
- v0.429 branch: `codex/v0429-tesana-disposable-runtime-provenance`
- Accepted canonical branch: `codex/v0215-v0226-recovery`
- Accepted canonical SHA: `4a2de384b2f0c3f348f24ff549ab2293f29e3b7f`
- v0.428 draft PR #2 was not modified, force-pushed, merged, or closed.

## Source preservation and disposable copies

`D:\Code for projects\WB game like\WB_tesana` was treated as immutable and was never executed directly. v0.429 generated preflight and postflight manifests and compared every source path, byte size, and SHA-256. The comparison is zero added, zero removed, and zero changed files. The authentic Run A copy is outside both Git worktrees and excludes only runtime-generated `.godot` import cache files from the comparison.

Run B was **not used**. The observed blocker was missing first-import cache output, not a Tesana editor-service-specific incompatibility; therefore the service-isolation exception was not invoked and no service addon was edited.

## Godot engine receipt

The official portable non-.NET Godot 4.3 Windows x86_64 executable is outside the repository and both source projects:

- Version: `4.3.stable.official.77dcf97d8`
- Official archive: `Godot_v4.3-stable_win64.exe.zip`
- Official download: `https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip`
- Archive SHA-256: `8f2c75b734bd956027ae3ca92c41f78b5d5a255dacc0f20e4e3c523c545ad410`
- Archive SHA-512: `ad09b7e19949327700dfbe64e35880a2a08091c0751277f5cc21b915e5df9b4fe93fb43c50d6bdfb9d16b46168592491aa698e0d2dbe9f92132e163dd77b97e1`
- Official expected SHA-512 matched exactly.
- Executable SHA-256: `b554ba80fb2ad8f1817bc21242ac8adbb9e41f806c49ad5cc73603db71fee32f`
- Console-pair executable: not present in the official standard Windows archive; redirected headed logs were used.

The complete machine-readable receipt is in `v0429-godot-engine-receipt.json`.

## Authentic Run A

Run A launched `res://scenes/main.tscn` headed at 1920×1080 from the disposable copy. The first real frame displayed the local Ascendant Realms title menu. The real Skirmish click was attempted through the headed runtime; the screen did not transition. Logs contain missing imported `.ctex`, `.fontdata`, `.mp3str`, and related UI-resource errors. The bounded import attempt did not make a usable imported cache, so the audit remained fail-closed.

Flow counts: **2 PASS** (title boot, clean audit exit), **2 BLOCKED** (Skirmish setup, campaign map), **8 NOT_PRESENT** because the authentic run could not reach them. No movement, construction, production, AI/combat, or save/load result is claimed.

One real local screenshot was admitted: `01_LOCAL_TITLE_SCREEN.png`, with adjacent metadata. No hosted preview, title-card substitute, source texture, black frame, or fabricated downstream capture was admitted. The remaining requested captures are explicitly listed as unavailable in `v0429-capture-index.json`.

## Network and cleanup

The Tesana addon opened only its documented loopback services at `127.0.0.1:5180` and `127.0.0.1:5181`. No non-loopback or unexpected network activity was observed. Audit-owned Godot processes were stopped after evidence capture. Disposable Run A and temporary user-data directories were removed after the evidence was extracted; the immutable source and the reviewed Godot tool cache were retained.

## Content and runtime breadth

Static source inventory confirmed 10 scenes, 40 GDScript files, 75 GLB models, 141 image textures, 14 audio files, 1 font, and 2 addon files. These counts establish export breadth only. They do not establish working local runtime coverage. The runtime matrix records the title as PASS and downstream breadth as blocked or not reached.

## Provenance admission matrix

The audit inspected README/export metadata, manifests, generation metadata where present, and embedded source references. Candidate asset rows were generated for the full 628-file source manifest. No candidate was marked `CLEARED_FOR_DONOR_EVALUATION` because attribution, commercial rights, modification/redistribution rights, standalone restrictions, and the applicable account plan were not documentary-complete.

The Tripo official terms page was recorded as evidence that plan-dependent rights matter; the actual export account plan was not provided, so the assets remain `TERMS_OR_PLAN_EVIDENCE_REQUIRED`. No authoritative Tesana terms page was identified in the bounded official search or export metadata. The complete rows and permitted statuses are in `v0429-asset-admission-matrix.json` and `v0429-provenance-source-register.json`.

## Decision and v0.430 boundary

**Outcome C — TESANA_DONOR_REJECTED.** The combination of incomplete runtime breadth and uncleared provenance is insufficient to admit even a single donor slice. No Tesana asset, scene, script, cache, engine binary, account identifier, or runtime behavior entered the accepted project.

The exact bounded proposal recorded for v0.430 is: **canonical Barrosan vertical-slice continuation without Tesana donor integration**, using accepted runtime systems and documentary-cleared authored materials only. It is a proposal, not work started by v0.429.

## Changed and unchanged

Changed only the explicit v0.429 audit tooling, package commands, report, and structured evidence/review pack. The accepted implementation, state chain, stable IDs, saves, true default runtime, and existing v0.428 audit were not changed. `WB_tesana` remained unchanged byte-for-byte. No integration, merge, PR close, or accepted-runtime mutation occurred.

## Review pack and validator

- Review pack: `artifacts/manual-review/v0429-tesana-disposable-runtime-provenance-gate/`
- Dedicated audit command: `npm run godot:audit:v0429-tesana-runtime-provenance`
- Dedicated validator command: `npm run godot:validate:v0429-tesana-runtime-provenance`
- Validator: `tools/tesana/v0429TesanaRuntimeProvenance.mjs`

The validator asserts exact baseline, engine verification, source pre/post equality, disposable-copy boundaries, truthful blocked/not-present runtime status, real PNG metadata, Run B gating, permitted provenance statuses, one Outcome C, one bounded v0.430 proposal, no integration, and no accepted-runtime mutation.

## Validation evidence

Local validation completed before commit:

- `npm run godot:validate:v0429-tesana-runtime-provenance` — PASS; 2 PASS, 2 BLOCKED, 8 NOT_PRESENT; 1 real capture; Outcome C; no integration.
- `npm run godot:validate:v0428-tesana-intake` — PASS.
- Available retained v0.427–v0.400 validators — PASS, 25 commands. v0.402–v0.405 package commands are absent and were not claimed.
- `npm test` — PASS, 122 test files and 887 tests.
- `npm run build` — PASS.
- `npm run validate:content` — PASS.
- `npm run validate:art-intake` — PASS.
- `npm run validate:runtime-art-slots` — PASS, 52 slots.
- `npm run validate:artifact-retention` — PASS.
- `npm run godot:all` — PASS, exit code 0.
- `git diff --check` — PASS.

The retained checks validate the canonical project and audit tooling; they do not substitute for the fail-closed Tesana runtime evidence.

## Final state requirement

Audit-owned processes were stopped after capture and the disposable Run A directory was removed after evidence extraction. The intentional pre-existing untracked backlog was preserved. Only explicit v0.429 files are to be committed. The final closeout must record the implementation commit, draft PR targeting `codex/v0428-tesana-intake-audit`, exact-SHA GitHub Actions success, clean tracked working tree, and unchanged pre-existing untracked backlog.
