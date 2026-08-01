# v0.436-R1J Complete Combat Attribution and Conditional Repair

## Primary status

`BLOCKED_R1J_COMPLETE_ATTRIBUTION_INCONCLUSIVE`

R1J completed the requested fresh, headed, comparable production sessions and
closed the R1I attribution gaps at the evidence-contract level. The complete
graphs are internally linked and the dedicated validator passes. The evidence
does not prove one localized production defect, so no combat repair was made.
This is a truthful diagnosis publication, not a balance change and not a
conquest result.

## Scope and provenance

- Branch: `codex/v0436-first-complete-conquest-victory`
- Starting SHA: `ae9fe9022fd2efeafd90f207a448358b52ed419c`
- R1I evidence source SHA: `bfc04f73a152bdeb108184dec72328ab5a3cfd9c`
- Final R1J publication SHA: recorded in the final validation/closeout after publication
- Production scene: `scenes/main.tscn -> scenes/game_world.tscn`
- Renderer: headed Windows Godot 4.3 Forward Plus
- PR: #10, kept open, draft, and unmerged
- R1J capture: enabled only by `ASCENDANT_V0436_R1J_CAPTURE=1`
- Historical R1G/R1H/R1I evidence was not reused or relabeled

R1G remains `BLOCKED_R1G_PLAYER_ASSAULT_FORCE_ELIMINATED`, R1H remains
`BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED`, and R1I remains
`BLOCKED_R1I_COMBAT_CAUSALITY_INCONCLUSIVE`.

## Why R1J exists

R1I proved real public attack orders, production damage, a destroyed Thorn
Ranger, a damaged Hero Warden, and elimination of the prepared Barrosan force,
but could not connect each public order to unit receipt, target continuity,
attack cadence, projectile lifecycle, damage, and death. R1J adds that causal
chain as read-only evidence so a repair is authorized only if one localized
defect is proven.

## Exact configuration and force

Both sessions used Barrosan versus one Lioraen Easy opponent on Hollowspan with
standard resources, Skirmish, Conquest, and game speed 2.0. The prepared force
was produced through the normal economy and queue path: one starting
`barrosan_spear_guard`, two normally queued Spear Guards, two normally queued
`barrosan_crag_archer` units, and the live `barrosan_hero_thane`. The enemy
composition included `lioraen_thorn_ranger`, `lioraen_hero_warden`,
`lioraen_bloomdancer`, and `lioraen_rootwarden_guard` combatants recorded by
the fresh inventories.

Session A used defender-first target order. Session B used hero-first target
order. The force, configuration, renderer, scene, and production path were
otherwise held comparable.

## Complete attribution evidence

The fresh final-SHA sessions recorded:

| Session | Orders | Unit commands | Target transitions | Attacks | Projectiles | Damage | Deaths | Bounded samples |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| A | 4 | 43 | 93 | 116 | 86 | 110 | 7 | 100,000 |
| B | 2 | 28 | 76 | 120 | 99 | 110 | 6 | 100,000 |

Every public order has an order ID, selected units, requested command/target,
and receipt path. Unit command and target-transition graphs include explicit
reasons. Every attack has attacker/target identities, range, distance, state,
command, and timestamp. Every projectile has an originating attack and a
terminal lifecycle phase. Every damage event has attacker/victim IDs, formula
inputs, expected damage, observed HP before/after, and HP delta. Every captured
death has a final damage-event link and contributing-damage list. The dedicated
validator passes these requirements for both sessions.

Lethal overkill is represented correctly: formula damage can exceed remaining
HP while observed HP delta is clamped to the victim's remaining HP. The R1J
validator was corrected to validate this runtime rule; it does not weaken
attribution or accept contradictory HP transitions.

## Uptime, DPS, range, and formation evidence

The per-attacker uptime and effective-DPS files are generated from the fresh
session graphs, while range/reachability and formation/collision audits remain
read-only observations. The evidence shows real attack starts, projectile
lifecycles, impacts, target-dead transitions, fallback targets, and public-order
transitions. It does not isolate a single lost-attack cause attributable to
command continuity, cadence, projectile ownership, damage application, or
formation/navigation.

The observed causal alternatives remain inseparable: target-order divergence,
enemy composition/hero overmatch, normal target fallback, and combat
reachability can all contribute to the bounded outcome. The evidence therefore
does not authorize a production repair.

## Causal classification and repair decision

Classification:

`BLOCKED_R1J_COMPLETE_ATTRIBUTION_INCONCLUSIVE`

Repair decision:

`repair_authorized: false`

No HP, damage, armor, cooldown, range, target-selection, movement, projectile,
AI, economy, resource, result, save, stable-ID, or production-definition change
was made. The only repairs in this checkpoint are opt-in evidence-entry guards,
typed instrumentation locals, a capture-pack field mapping, and the validator's
correct lethal-clamp assertion.

## Implementation and exact commands

Added the opt-in recorder, event IDs, public-order receipts, target transitions,
attack/projectile/damage/death links, capture runner, validator, tests, and
package commands. R1J capture enters the production scene only when the R1J
environment flag is set. Normal runtime behavior and retained R1G/R1H/R1I
contracts remain unchanged.

```text
npm run godot:test:v0436-r1j-complete-combat-attribution
npm run godot:smoke:v0436-r1j-complete-combat-attribution
npm run godot:capture:v0436-r1j-complete-combat-attribution
npm run godot:validate:v0436-r1j-complete-combat-attribution
```

Dedicated validator result: passed, with status
`BLOCKED_R1J_COMPLETE_ATTRIBUTION_INCONCLUSIVE`.

## Review pack

`artifacts/manual-review/v0436-r1j-complete-combat-attribution-and-conditional-repair/`

The root pack contains preflight, executable provenance, launch contract,
frozen R1I baseline, comparability, production/damage audits, complete command,
target, attack, projectile, damage, and death graphs, uptime/DPS, range and
formation audits, expected-versus-observed data, causal/repair decisions,
accepted/rejected evidence, capture manifest, and final validation. `session-a`
and `session-b` contain real headed production frames, configuration and force
audits, public-order/first-contact/terminal frames, complete per-session graphs,
and contact sheets. The inspected public-order frame is a non-blank real
production gameplay image, not a title card.

## Retained validation and CI

The final publication records the retained R1F, R1D, R1B, navigation, R1G, R1H,
R1I, legacy-diagnose, repository-wide, and `godot:all` results. Phase-A exact
CI `30708294160` for `f531789d6c91ed3ca05fb0df90b2ef7fd7b69d14` and startup-repair
CI `30709073607` for `84acb4e8e3f3871cd59181a7707153487107effc` succeeded. The
metadata-guard CI `30709917957` for `64aeb08b0c82305658994e3c86c9f694726c2a00`
succeeded. Superseded intermediate runs were cancelled by GitHub after later
R1J commits; the final publication SHA/run is authoritative.

## Backlog disposition

- `P0-GAME-001` records the fresh R1J inconclusive attribution result only.
- `P0-NAV-001` is not marked as a new combat/navigation defect because no
  navigation or formation cause was proven.
- `P0-RESULT-001` remains open.
- P1-P4 remain untouched.

## Preserved boundaries

- True default runtime unchanged.
- Accepted R1/R1A/R1B/R1D/R1F/R1G/R1H/R1I behavior and truthful blocked statuses retained.
- No gameplay repair, balance tuning, direct state writes, free units,
  resource injection, AI suppression, or result manipulation.
- No R1K, v0.437, merge, or PR readiness transition.
- Unrelated/generated dirty paths were preserved; the broader worktree is not
  claimed clean.

## Final state

The final publication SHA, exact final GitHub Actions run, PR metadata, scoped
dirty status, and ahead/behind proof are written at closeout after the final
validation and publication commit. The intended final repo state is
`HEAD == origin/codex/v0436-first-complete-conquest-victory`, ahead/behind
`0/0`, with only pre-existing unrelated/generated dirty paths remaining.
