# Active Sprint 1 — Golden Battle

Activated: 2026-08-11 after Director review in the central Ascendant Realms ChatGPT conversation.

## Target

Hollowspan Crossing — Barrosan Clans vs Lioraen Concord — Easy — standard 1.0x. The quality target is a materially better player-facing opening and battle loop, not more validator artifacts.

## Lanes

| Lane | Branch | Worktree | Player outcome | Owned systems | Status | Integration order |
| --- | --- | --- | --- | --- | --- | --- |
| Core Gameplay | `codex/golden-s1-core` | assigned isolated worktree | dependable select → move → gather → construct → produce → rally → combat loop | battle, entities, pathfinding, results | starting | 1 |
| AI / Skirmish | `codex/golden-s1-ai` | assigned isolated worktree | coherent Lioraen Easy economy, production, movement, first contact, pressure, recovery | `src/game/ai`, battle AI data | starting | 3, after core dependencies |
| World / Visuals | `codex/golden-s1-world` | assigned isolated worktree | clearer unit/building/terrain/bridge/road/water readability | art metadata, opt-in visual path | starting | 2, conflict-audited |
| UI/UX + Combat Feel | `codex/golden-s1-combat` | assigned isolated worktree | clearer objective, selection, command, health, action, and combat feedback | `src/game/ui`, feedback presentation | starting | 2, conflict-audited |
| Lead / Performance / QA | local integration | dedicated integration worktree | buildability, tests, evidence, conflicts, daily candidate | docs, validation, integration | active | continuous |

## Rules

- Each specialist reads `AGENTS.md`, `docs/codex/AUTONOMY_POLICY.md`, `docs/codex/PARALLEL_WORK_POLICY.md`, and this file.
- Each specialist owns only its named systems and must record changed files, tests, evidence, blockers, and local commit SHA.
- Local commits are authorized in specialist worktrees when scoped and validated.
- The Lead integrates only accepted commits into a dedicated local integration branch.
- No lane may push, modify PR metadata, merge to shared/protected branches, rebase shared history, or touch the protected checkout.
- At most one meaningful human playtest should be requested per day; Codex must inspect evidence first.
- If a lane is blocked, the other lanes continue.

## Integration queue

1. Core Gameplay establishes the reproduction and smallest causal repair.
2. World and UI/Combat Feel are conflict-audited against Core; they may integrate independently if they do not alter gameplay semantics.
3. AI integrates after the core opening path and any navigation/building-clearance dependency is understood.
4. Lead runs risk-based combined validation, creates `DAILY_DIRECTOR_BRIEF.md`, and prepares a playable local candidate when meaningful improvements exist.
