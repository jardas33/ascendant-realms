# Ascendant Realms Disaster-Recovery Manifest

Generated 2026-08-29 from the approved D: worktree. This is a recovery record, not a gameplay-task authorization. Protected canonical and `codex/current-godot-baseline-next` were not changed during the backup operation.

## 1. GitHub identity

- Repository: `https://github.com/jardas33/ascendant-realms.git`
- Development branch: `codex/p1-task463-production-spawn-reliability`
- Development branch backup: PASS
- Exact backed-up HEAD: `d7bf5b824d562032ffa668d4620329adcc09d58c`
- Annotated recovery tag: `ascendant-realms-recovery-2026-08-29-d7bf5b82`
- Recovery tag target: `d7bf5b824d562032ffa668d4620329adcc09d58c`
- Remote branch and tag were independently resolved to the exact backed-up HEAD.
- The development branch did not previously exist on `origin`; its local history was therefore entirely absent from that remote branch before this push.

## 2. Protected refs and source locations

- Active worktree: `D:\CodexData\worktrees\ascendant-realms-p1-normal-play-bug-sweep-01`
- Production project: `D:\CodexData\worktrees\ascendant-realms-p1-normal-play-bug-sweep-01\production\ascendant-realms-godot`
- Active branch: `codex/p1-task463-production-spawn-reliability`
- HEAD before/after backup: `d7bf5b824d562032ffa668d4620329adcc09d58c`
- HEAD subject: `feat: integrate task609 barrosan military portraits`
- Protected canonical before/after: `b9812797bba626a3b51e0b79739bc6e2cdf0bca4`
- `codex/current-godot-baseline-next` before/after: `491ce5a177c185cd155fbea7a2db308d5b0366a5`
- Task609 parent/base: `491ce5a177c185cd155fbea7a2db308d5b0366a5`
- No merge, rebase, cherry-pick, amend, hard reset, clean, force push, or canonical mutation occurred.

## 3. Godot and project wiring

- Godot version used: `4.6.3.stable.official.7d41c59c4`
- Official executable: `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`
- Expected project path after recovery: `<clone>\production\ascendant-realms-godot`
- `project.godot` main scene: `res://scenes/main.tscn`
- `res://scenes/main.tscn` wires the production main menu script; public menu flow enters `res://scenes/game_world.tscn` through `MainMenu`, `SkirmishSetup`, and `LoadingScreen`.
- `game_world.tscn` is the production battle scene whose root is `GameRoot`; it wires `GameWorld`, `RTSController`, HUD, enemy AI, pause, debug, and tutorial systems.
- The Task609 capture-only routing hooks and capture driver were removed before the recovery commit.

## 4. Current accepted game state

- Task608 was previously promoted to `codex/current-godot-baseline-next` at `491ce5a177c185cd155fbea7a2db308d5b0366a5`.
- Task609 candidate was committed as direct child `d7bf5b824d562032ffa668d4620329adcc09d58c`.
- Task609 added only accepted A08-B1 Stoneward Spears and Clan Levy portrait masters/import metadata and exact `UnitDefs` mappings.
- Task609 runtime evidence passed public GameWorld construction/production, selection, movement persistence, switching, fallback/group regression, and 1920x1080 plus 1366x768 coverage.
- Task609 remains a candidate awaiting Director visual classification; promotion was not authorized or applied.
- Retained backlog: `PLAYER_REPORTED_MOVEMENT_STALL_REMAINS_OPEN_NO_REPRO`; `COMMAND_CARD_PRESENTATION_REDESIGN_PENDING_AFTER_TASK598`.

## 5. External Grok art audit

External root: `D:\CodexData\external-art-intake\`

- Total files: `1121`
- Total size: `3,204,952,806` bytes (`2.985 GB` decimal display from the audit)
- Extensions: PNG 744 / 1,975,738,871 bytes; JPG 72 / 27,062,845 bytes; GLB 61 / 215,954,448 bytes; BLEND 36 / 521,241,830 bytes; BLEND1 28 / 462,110,699 bytes; JSON 32; MD 67; PY 35; TXT 29; LOG 17.
- Largest audited file family was A07 Iron Forge Blender source, approximately 31.41 MB per file. Other large source families include A06 Ground Integration and the AAA kit.

Important preserved lane roots and audited totals:

| Lane | Root | Files | Bytes |
|---|---|---:|---:|
| A01 | `grok-art-a01-barrosan-main-hall` | 42 | 122,569,233 |
| A02 | `grok-art-a02-barrosan-war-hall` | 65 | 185,636,256 |
| A03 | `grok-art-a03-barrosan-houses` | 45 | 129,874,221 |
| A04 | `grok-art-a04-barrosan-worker-militia` | 297 | 727,891,052 |
| A04B | `grok-art-a04b-barrosan-character-rebuild` | 33 | 71,904,848 |
| A05 | `grok-art-a05-barrosan-settlement-dressing` | 68 | 219,912,110 |
| A06 | `grok-art-a06-barrosan-ground-integration` | 253 | 844,227,251 |
| A07 | `grok-art-a07-barrosan-iron-forge` | 90 | 439,689,450 |
| A08 | `grok-art-a08-barrosan-visual-identity` | 128 | 32,504,073 |

The four-item `barrosan-aaa-kit-20260826` tree was also included in the total audit. Historical pass/preserved folders were not modified. Grok artwork remains separate from production; this backup audit did not authorize any import.

## 6. External-art off-machine status

`EXTERNAL_ART_OFF_MACHINE_BACKUP = BLOCKED`

No safe GitHub upload route was available for the full external tree during this operation. GitHub CLI was not installed; Git LFS is installed but the repository has no LFS-tracked files or configured LFS policy, and pushing approximately 3 GB of mixed historical masters, duplicate `.blend1` files, exports, and images into a normal repository branch would be an unsafe and potentially quota-expensive archive. No large archive was created and no false protection claim is made.

The exact local-only external asset set is the complete `D:\CodexData\external-art-intake\` tree, including A01, A02, A03, A04, A04B, A05, A06, A07, A08, the AAA kit, all source masters, exports, textures, reports, and historical pass folders.

Single later action required for full Grok protection: choose and authorize a storage target that supports this 2.985 GB source archive (for example a properly quota-verified Git LFS or release/archive repository), then upload a verified archive or LFS-backed mirror and record its checksums here. A D:-only ZIP is not off-machine protection.

## 7. Non-repository context and evidence

The following D: recovery context was prepared for an isolated GitHub context branch named `ascendant-realms-recovery-context-2026-08-29`:

- `D:\CodexData\ASCENDANT_REALMS_STUDIO_QUEUE.md`
- `D:\CodexData\DIRECTOR_OUTBOX.md`
- `D:\CodexData\ASCENDANT_REALMS_DISASTER_RECOVERY_MANIFEST_2026-08-29.md`
- `D:\CodexData\evidence\p1-task609-a08-stoneward-clan-levy-portrait-integration\REPORT.md`
- `D:\CodexData\evidence\p1-task609-a08-stoneward-clan-levy-portrait-integration\source-audit.md`
- `D:\CodexData\evidence\p1-task609-a08-stoneward-clan-levy-portrait-integration\runtime\final\task609-runtime.json`
- `D:\CodexData\evidence\p1-task609-a08-stoneward-clan-levy-portrait-integration\runtime\final\task609-production-audit.json`

`PROJECT_CONTEXT_BACKUP = PARTIAL` until that isolated context branch is verified remotely. A current handoff PDF was not found in the D:-scoped context search. The user-referenced PDF under the Windows Downloads area was not copied during this D:-only maintenance operation and remains local-only unless separately transferred.

## 8. Worktree classification at audit time

The active worktree contained 423 tracked modifications, 134 untracked status entries, and no staged files after the Task609 commit. These were not blindly added:

- `artifacts\` — 186 tracked and 19 untracked evidence/capture items: evidence-only, generated, or temporary capture drift; preserved.
- `production\` — 237 tracked and 118 untracked items, predominantly Godot `.import`/`.uid` generated metadata, derived textures, old harness files, and unclassified historical drift; preserved and not committed.
- `docs\P1_NORMAL_PLAY_BUG_SWEEP_01_REPORT.md` — untracked historical/report drift; preserved.
- `production\ascendant-realms-godot\command-card-manifest.json` — untracked historical/runtime documentation drift; preserved.
- No credentials, tokens, GitHub authentication files, save/profile data, or runtime user data were intentionally staged.

Because these items were not clearly part of the accepted Task609 state, they remain local-only and are not represented by the recovery tag. They must be separately reviewed before any future commit.

## 9. LFS and archive status

- Git LFS executable is present (`git-lfs/3.7.1`).
- Repository LFS configuration is present only at the global/filter level; `git lfs ls-files` returned no tracked files.
- No LFS migration or `.gitattributes` change was made.
- Recovery archives created: NONE.
- Recovery archive SHA256: NONE.

## 10. New Windows PC recovery procedure

Install Git and Godot 4.6.3 on the new PC, then use a D: data drive if available:

```powershell
git clone --branch codex/p1-task463-production-spawn-reliability https://github.com/jardas33/ascendant-realms.git D:\AscendantRealms
Set-Location D:\AscendantRealms
git fetch origin --tags
git checkout --detach ascendant-realms-recovery-2026-08-29-d7bf5b82
```

The recovery tag reproduces the exact backed-up development state. To continue development instead:

```powershell
git switch codex/p1-task463-production-spawn-reliability
git pull --ff-only origin codex/p1-task463-production-spawn-reliability
```

Do not check out or mutate `b9812797bba626a3b51e0b79739bc6e2cdf0bca4`; it is the protected canonical reference. `codex/current-godot-baseline-next` is a local coordination ref and was not part of this backup mutation.

Install/open Godot 4.6.3 and import:

```powershell
& 'D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe' --editor --path 'D:\AscendantRealms\production\ascendant-realms-godot'
```

Or launch the project directly:

```powershell
& 'D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe' --path 'D:\AscendantRealms\production\ascendant-realms-godot'
```

Restore separately, outside Git, before expecting full continuity:

1. The complete `D:\CodexData\external-art-intake\` tree, until an off-machine archive is created.
2. The isolated recovery context branch listed above, once pushed and verified.
3. Any current handoff PDF not present in the isolated context branch.
4. Any intentionally retained but uncommitted worktree drift listed in section 8, only after human review.

## 11. Recovery truth table

- `CODE_RECOVERABLE_FROM_GITHUB = true` for the committed development history through the backed-up tag.
- `PRODUCTION_ART_RECOVERABLE_FROM_GITHUB = true` for production assets tracked by the backed-up commit/tag; uncommitted derived or historical drift is excluded.
- `GROK_SOURCE_ART_RECOVERABLE_OFF_MACHINE = false`.
- `PROJECT_CONTEXT_RECOVERABLE_OFF_MACHINE = false` until the context branch is verified and missing handoff material is separately backed up.
- Overall readiness: `PARTIAL`.

## 12. Explicit not-backed-up statement

If this computer and D: fail immediately, GitHub contains the committed Ascendant Realms development branch and immutable recovery tag at `d7bf5b824d562032ffa668d4620329adcc09d58c`. GitHub does **not** yet contain the complete 2.985 GB external Grok art intake, the uncommitted worktree drift, or every current handoff/context document. This manifest deliberately reports that limitation rather than implying full disaster recovery.

Next action after this maintenance operation: Director/Emanuel review of the disaster-recovery result. No gameplay task was started from the backup authorization.
