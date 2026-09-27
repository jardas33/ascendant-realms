# Claude lane: convergence audit

Written 2026-09-27 by Claude, in reply to the director's request for an exact-ref, feature-bucket audit of `claude/perf-placeholders-r1` before any promotion. Nothing in this file changes code; it describes what the branch holds and how it could be promoted in gates.

## Exact refs (checked with git on 2026-09-27)

| Ref | Commit | Notes |
|---|---|---|
| Claude lane HEAD (`claude/perf-placeholders-r1`) | `f7616faa` | Pushed to GitHub as a backup branch on 2026-09-27; not merged into `main`. |
| `origin/main` | `38f84eb6` | Merge-base with the Claude lane is `38f84eb6` itself; the lane is 1,036 commits ahead. |
| Codex local `05d9f857` (Vorthak building gallery, 2026-09-26) | contained | Merged into the lane by `36bafcb2`. It is not on any `origin/` branch. |
| `origin/codex/astra-ui-battle-hud-visual-r1` | `b6bcbe25` | Contained. Merge-base with the lane is `b6bcbe25`; the lane is 182 commits past it. |
| `origin/codex/astra-character-quality-r1` | `f5283cd9` | Contained (merged by `03229502`). |
| `origin/codex/current-godot-baseline-next` | `ebef47ae` | Contained. |
| `origin/codex/barrosan-iron-forge-b01-r2-local-integration` | `0052293d` | Contained. |
| `origin/codex/astra-ui-current-baseline-intake-r1` | `4458749f` | Contained. |

Of the 1,036 commits ahead of `main`, 151 carry the Claude co-author trailer. The rest are Codex history the lane merged: `0642f988` (ornate HUD), `6ae2b154` (UI convergence `ad35fe9f`), `03229502` (Clan Levy `f5283cd9`) and `36bafcb2` (Vorthak portraits and gallery, through `05d9f857`). Every current Codex tip is an ancestor of the lane, so converging is a question of which of Claude's own commits to accept.

To re-check: `git merge-base --is-ancestor <codex-ref> f7616faa && echo contained`.

## The four gates

Each gate lists the commits and the evidence it should need before promotion. The commits within a gate are mostly independent of the later gates, but they are interleaved in history, so cherry-picking by gate will hit conflicts in `game_world.gd`, `unit.gd`, `enemy_ai.gd` and `hud.gd`. The simpler path is to promote the whole lane once each gate's evidence is accepted, or to revert individual commits that are rejected.

### Gate 1: presentation and world art

Scope: fog of war, the golden-hour grade and ground shader, dressing kits for each faction start, resource sites, water, grass and trees, weather, VFX, selection rings and banners, building construction and damage states, menus (skirmish council, result ledger, main menu, loading screen), minimap, and merged mesh parts for characters.

Commits: `4920f5fd` to `fe376f08` on 2026-09-25 and 26 (art passes), `b657c3ea` to `ff50b659`, `68a3ef45`, `dca4297d`.

Risk: low for gameplay. Mesh joins keep rigs and animations. The Bowcrusha was already a rigid statue before its join (its rig is 0.27 m against a 2.3 m body), and it belongs on the character-quality debt list.

Evidence to ask for: headed screenshots of each battlefield theme and every menu, plus the FPS benchmark.

### Gate 2: performance and engine

Scope: GPU fog, static batching, prewarming, the route-solver frame budget, target-scan throttling, part shadows, and the **30 Hz simulation with physics interpolation** (`a5e17fb6`, 120-unit fight from 11 to 43 fps).

Commits: `4920f5fd`, `5bbd2ed4`, `0a707e10`, `34071192`, `1b2cef75`, `a1502397`, `a5e17fb6`, plus the throttles inside the later plan commits.

Risk: medium. Changing simulation timing alters combat pacing, projectile flight and cooldown granularity. The 9 regression tests pass at 30 Hz, but the director is right that they are not a full gameplay gate.

Evidence to ask for: the 9 tests, compile-all, the menu smoke tour, a set of AI-vs-AI soaks with results, and at least one headed match per faction played by a person.

### Gate 3: gameplay, AI and balance

Scope: AI economy and deadlock fixes, housing and build placement, reachability checks, attack waves and difficulty behaviour, faction personalities, hero levels in battle, hero revival, enemy hero spells, balance changes from equal-cost duels, the four new units, elites, cleave, and renewable food.

Commits: `213e008c`, `f9e20a09`, `ad57edd3`, `03b0acf8`, `9bec691c`, `6c085c27`, `e37b8798`, `a5c1a0d8`, `5a09e33b`, `1b5c80ae`, `7677e089`, `b77666fd`, `30b39193` and the AI parts of the plan commits.

Risk: medium. These change how matches feel. AI-vs-AI soaks currently end in most matchups, but Barrosan still loses most AI-vs-AI games and Lioraen against Barrosan can stall (being fixed in plan 22).

Evidence to ask for: a soak matrix across all ten factions and duel tables, which Claude can produce on request.

### Gate 4: product direction

These define what Ascendant Realms is. On 2026-09-27 Emanuel said he trusts Claude to make these decisions, so they are treated as the current direction. Playtesting feedback can still change any of them:

1. **The Saga of the Seventy-Seventh Ascension** (`6f43f089` onward): a Barroso-inspired story bible, 5 acts and 44 chapters including side roads, a branching choice, three endings and the hero-death reveal. This replaced the earlier campaign; old progress is migrated.
2. **The Endless Road** (`00a9aa68` onward): generated stages with no last stage, twists, festivals every 10th stage, champions every 5th, and relics.
3. **Endless progression**: uncapped hero levels, mastery points, veterancy ranks and retinue size (Emanuel asked for no caps on 2026-09-27).
4. **Loot** (`a285e21f` onward): seeded drops, rarities, legendary powers, gear sets, salvage, locking, auto-salvage and Equip Best.
5. **Deeds and titles** (`1e79b035`): achievement tracks with no final tier.
6. **Battle events**: bounties, the Lume Surge, elites and named veterans.

Evidence worth gathering: a person plays through Act I and a few Endless Road stages and reports what feels too slow, too fast or unclear.

## What is not in the lane

- The Hugging Face character route was dropped on 2026-09-27; character model quality belongs to Codex.
- Multiplayer is only a design note (`docs/claude/MULTIPLAYER_READINESS.md`: host-authoritative, first milestone two-player LAN co-op against AI over ENet). No networking code exists yet.

## Regression gate used for every Claude pass

The compile-all check (`tests/claude_compileall.gd`, which compiles every script and opens every menu scene), a menu smoke tour, the 9 production tests, the saga data check, and AI-vs-AI soaks. Headed play by a person is still missing and should be added before any promotion.
