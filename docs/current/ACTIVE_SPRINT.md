# Active Sprint 1 - Golden Battle

Activated: 2026-08-11 after Director review in the central Ascendant Realms ChatGPT conversation.

## Target

Hollowspan Crossing - Barrosan Clans vs Lioraen Concord - Easy - standard 1.0x. The quality target is a materially better player-facing opening and battle loop, not more validator artifacts.

## Lanes

| Lane | Branch | Worktree | Player outcome | Owned systems | Status | Integration order |
| --- | --- | --- | --- | --- | --- | --- |
| Core Gameplay | `codex/golden-s1-core` | `D:\CodexData\worktrees\ascendant-realms-golden-s1-core` | dependable select -> move -> gather -> construct -> produce -> rally -> combat loop | battle, entities, pathfinding, results | ready for specialist kickoff | 1 |
| AI / Skirmish | `codex/golden-s1-ai` | `D:\CodexData\worktrees\ascendant-realms-golden-s1-ai` | coherent Lioraen Easy economy, production, movement, first contact, pressure, recovery | `src/game/ai`, battle AI data | ready for specialist kickoff | 3, after core dependencies |
| World / Visuals | `codex/golden-s1-world` | `D:\CodexData\worktrees\ascendant-realms-golden-s1-world` | clearer unit/building/terrain/bridge/road/water readability | art metadata, opt-in visual path | ready for specialist kickoff | 2, conflict-audited |
| UI/UX + Combat Feel | `codex/golden-s1-combat` | `D:\CodexData\worktrees\ascendant-realms-golden-s1-combat` | clearer objective, selection, command, health, action, and combat feedback | `src/game/ui`, feedback presentation | ready for specialist kickoff | 2, conflict-audited |
| Lead / Performance / QA | `codex/golden-s1-integration` | `D:\CodexData\worktrees\ascendant-realms-golden-s1-integration` | buildability, tests, evidence, conflicts, daily candidate | docs, validation, integration | npm test/build green; Godot smoke blocked by signal 11 | continuous |

## Rules

- Each specialist reads `AGENTS.md`, `docs/codex/AUTONOMY_POLICY.md`, `docs/codex/PARALLEL_WORK_POLICY.md`, and this file.
- Each specialist owns only its named systems and records changed files, tests, evidence, blockers, and local commit SHA.
- Local commits are authorized in specialist worktrees when scoped and validated.
- The Lead integrates only accepted commits into the dedicated local integration branch.
- No lane may push, modify PR metadata, merge to shared/protected branches, rebase shared history, or touch the protected checkout.
- At most one meaningful human playtest should be requested per day; Codex inspects evidence first.
- If a lane is blocked, the other lanes continue.

## Bootstrap status

The candidate is registered in the Codex app as the Git project `Ascendant Realms` at `D:\CodexData\worktrees\ascendant-realms-human-playtest4-movement` (`isGitRepository=true`). Five local Git worktrees are materialized from candidate HEAD `3a49c2d2901fa5c868f5bb2c2cd81d6b0e4625b8`; each is clean and contains the shared control docs. Stale detached launches from `45d85d2686679784c2d00da45a67f4de4fe95a6b` remain rejected and no-op.

## Integration queue

1. Core Gameplay establishes the reproduction and smallest causal repair.
2. World and UI/Combat Feel are conflict-audited against Core; they may integrate independently if they do not alter gameplay semantics.
3. AI integrates after the core opening path and any navigation/building-clearance dependency is understood.
4. Lead runs risk-based combined validation, creates `DAILY_DIRECTOR_BRIEF.md`, and prepares a playable local candidate when meaningful improvements exist.

## Integration baseline

- `npm ci --no-audit --no-fund`: pass in the clean Integration worktree; dependencies are local to that D: worktree.
- `npm test`: pass, 136 test files / 956 tests.
- `npm run build`: pass.
- `git diff --check`: pass.
- `npm run godot:smoke:production`: blocked before usable runtime proof by Godot 4.3.stable signal 11; no source mutation or headed playtest was attempted.
- Baseline classification: `GOLDEN_S1_INTEGRATION_BASELINE_PARTIAL_GODOT_SIGNAL_11`.

## I1 checkpoint result — 2026-08-14

The canonical D: lane completed the approved local I1 integration sequence from `5822bcd5e677b88ee9f017c119fb5848c7981ae3` through:

- `b816eef2923fd3f9db923406b6ea05785e90cc44` — resource-node identity;
- `e430abf8` — building placement readability only;
- `d0767f1c` — normal-player construction-label cleanup;
- `195d265b991d359afd6c12c1ecc31c74a6864fb7` — combat impact presentation only.

Fresh v0.432 and v0.434 headed proof, independent resource proof, focused economy tests, three official v0.434 startup/capture runs, package tests/build/content/art/runtime-slot/artifact-retention checks, and `npm run godot:all` passed at the final HEAD. The retained v0.433 headed capture remains yellow because its food-deposit-before-gold-switch assertion fails identically on the untouched RESOURCES-01 specialist lane; no validator or production repair was made for that unrelated harness contract.

WORLD-02 remains parked as `YELLOW_P1_WORLD02_VISUAL_PAYOFF_INSUFFICIENT`. PLAY-01A / AI-01 remains the next player-facing priority after director review.
