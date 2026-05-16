# v0.12 Core Game Feel Audit

Date: 2026-05-16

Scope: Phase 1 audit for the v0.12 Core Game Feel and Battle Readability Pass. This audit records what the existing playable slice should communicate, what is unclear today, what should wait for the future visual overhaul, and which safe changes are candidates for v0.12. No gameplay code was changed during this phase.

Green-state guardrails:

- Preserve GitHub Actions `CI Release Matrix Dry Run #39` green closeout on commit `dadb241`.
- Keep hosted release groups on `playwright.hosted-release.config.ts` and `npm run preview:hosted`.
- Keep local full release lanes separate from hosted release lanes.
- Do not replace `clickReady` with force clicks.
- Do not use DOM click fallback for canvas/world clicks.
- Do not weaken Moving, minimap, no-save/no-reward tutorial, battle command, side-panel reachability, settings runtime-application, or hosted release assertions.
- Do not turn tutorial smoke semantic advancement back into long raw `tutorial-next` click chains.
- Treat this as game-feel/readability work, not CI plumbing.

## Tutorial / Proving Grounds

What the player should understand:

- Proving Grounds is optional, no-save, and no-reward.
- The player should learn camera movement, hero selection, right-click movement, capture income, construction, training, rally points, hero ability use, grouped combat, and safe completion.
- Selected units are the only units that receive commands.
- Battle resources are temporary and not campaign rewards.

Currently unclear:

- The tutorial copy is accurate, but command acknowledgement competes with income, XP, objective, and pressure messages in the shared battle-status line.
- The selected-unit panel says what a selected unit is doing, but the tutorial does not strongly reinforce that the panel is where command acceptance is confirmed.
- The final tutorial no-save/no-reward rule is clear in text, but it is easy to miss because it appears late and uses the same status presentation as routine messages.
- Tutorial advancement is now semantic in smoke coverage, which is good. Any v0.12 tutorial update should preserve that pattern and avoid fragile click chains.

Feedback too late, too fast, too subtle, or too noisy:

- Movement acceptance has no explicit status acknowledgement when a valid right-click succeeds.
- Attack-move mode announces the setup state, but the actual destination acceptance is quiet.
- Floating resource income can overwrite command feedback in the status line.
- Build placement has strong ghost feedback, but training and rally confirmation are more dependent on one-line status text.

Visual-only debt to defer:

- The tutorial map and unit art remain prototype-level. Do not replace assets in v0.12.
- Tutorial overlay polish that requires new icons, illustrations, or art direction belongs to the future visual overhaul.

Fix-now candidates:

- Add concise accepted-command text for movement, attack, rally, build, train, and research where behavior already succeeds.
- Make tutorial objective copy point the player toward the order summary and current objective rather than adding new mechanics.
- Preserve no-save/no-reward behavior and tests.

Risk:

- Low for copy and status-message changes.
- Medium for tutorial flow changes because smoke tests and semantic command logs depend on tutorial state transitions.

Likely files:

- `src/game/data/tutorials.ts`
- `src/game/tutorial/TutorialStepModel.ts`
- `src/game/ui/hudPanels/TutorialPanel.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/scenes/BattleScene.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/semantic-command-log.ts`

## Border Village / First Campaign Battle

What the player should understand:

- This is the first full campaign battle loop: select army, capture the first economy site, build Barracks, train troops, rally new units, survive pressure, and destroy the enemy base.
- The player should understand when a command was accepted and what the selected unit or building is doing next.
- First-clear rewards, XP, and campaign completion should feel earned.

Currently unclear:

- The side panel lists orders and stats, but the order summary is visually close to normal stat blocks and can be easy to miss.
- Multi-selection summarizes order counts, but the player does not get a strong "these selected units are now moving/attacking" acknowledgement in the moment.
- The battle-start summary is informative but long; it competes with early player commands.
- Training and building messages exist, but they use the same normal status priority as income ticks and can disappear quickly.

Feedback too late, too fast, too subtle, or too noisy:

- Move and attack commands are accepted silently unless pathing fails.
- Rally point confirmation exists and pings the minimap, but it can be overwritten by resource income.
- `+30 crowns` style income messages are useful but noisy during command-heavy moments.
- Building placement failure reasons are good, but command-button disabled states only say lock/cost reasons inside the button; there is no separate explanation when the button cannot be clicked.

Visual-only debt to defer:

- Command Hall, Barracks, and unit silhouettes can be visually richer later, but no new art is needed for v0.12.
- Battle terrain readability improvements that require new tiles or rendered landmarks should wait.

Fix-now candidates:

- Improve command acknowledgement copy and read windows.
- Make selected order summaries more prominent and player-facing.
- Add concise "Next" language to objective/status areas when a campaign battle starts or an objective updates.
- Keep behavior and challenge intact unless simulator evidence says otherwise.

Risk:

- Low for HUD copy/hierarchy.
- Medium for battle-status priority/duration changes because e2e tests assert status behavior.
- Medium for movement responsiveness tuning because pathing, attack-move, and `Moving` assertions depend on order state.

Likely files:

- `src/game/systems/InputSystem.ts`
- `src/game/systems/MovementSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/ui/UnitOrderSummary.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `src/game/ui/hudPanels/CommandPanel.ts`
- `src/game/styles/battle-hud.css`
- `src/game/results/ResultsViewModel.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

## Ashen Outpost

What the player should understand:

- Ashen Outpost is a current mini-campaign milestone and expects a working army loop.
- The Burned Shrine is valuable but exposed.
- The player should break enemy production and defeat Captain Malrec before or during the final fortress push.

Currently unclear:

- The objectives are clear on paper, but "weaken the gate Watchtower" from the Burned Shrine objective is hard to see without stronger objective/result feedback.
- The fortress focus area is visually dense, so players may not immediately understand whether they are losing to tower range, commander pressure, or poor army grouping.
- Captain Malrec is named in objectives and results, but commander threat feedback could be more explicit when first sighted.

Feedback too late, too fast, too subtle, or too noisy:

- Objective completion messages exist, but they share the same top status channel as combat/resource messages.
- Combat damage numbers show hits, but not enough summary exists to explain why a fortress push is succeeding or failing.
- Enemy commander sighting appears once; it may be missed during a hectic push.

Visual-only debt to defer:

- Fortress silhouette, tower range art, terrain landmarks, and Cinderfen/Ashen visual overhaul remain future art work.

Fix-now candidates:

- Tighten objective text to say the immediate action and expected payoff.
- Improve enemy commander/tower warning copy using existing status and minimap ping channels.
- Improve results summary/tips so a defeat explains base loss, wave pressure, or insufficient army staging.

Risk:

- Low for map objective copy.
- Medium for combat/result summary additions because tests assert some exact strings.

Likely files:

- `src/game/data/maps/ashenOutpost.ts`
- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneObjectives.ts`
- `src/game/results/ResultsViewModel.ts`
- `src/game/results/ResultsObjectiveSummary.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

## Cinderfen Crossing

What the player should understand:

- The Cinder Shrine is a tempo prize: first capture grants one-time Aether, then normal Aether income.
- The shrine route can provoke scoped enemy pressure.
- The player should secure side income or regroup before pushing the enemy camp.

Currently unclear:

- The Cinder Shrine text is improved from earlier versions, but it is still dense in the small objective panel.
- "Cinder Shrine Surge" is flavorful but needs enough plain-language payoff nearby.
- Pressure warnings are scoped and non-systemic, but players may not know whether the enemy is actually building, sending a wave sooner, or merely reacting with existing pressure rules.

Feedback too late, too fast, too subtle, or too noisy:

- Capture bonus feedback has objective priority and minimap ping, which is good.
- Follow-up pressure warnings can arrive while the player is reading income and combat messages.
- Normal income ticks after shrine capture can bury more important command feedback.

Visual-only debt to defer:

- Shrine art, ash-marsh terrain, and cinder landmark readability belong to the future Cinderfen visual overhaul.

Fix-now candidates:

- Shorten objective panel copy while preserving exact payoff.
- Adjust pressure warning copy to include the player-facing action: hold route, regroup, break wave, then push.
- Add result language that confirms first-clear route rewards and next node unlock clarity.

Risk:

- Low for copy, if tests are updated.
- Medium for pressure timing or behavior changes; avoid unless simulator/playtest evidence supports it.

Likely files:

- `src/game/data/maps/cinderfenCauseway.ts`
- `src/game/data/enemyPressurePlans.ts`
- `src/game/battle/EnemyPressureRuntime.ts`
- `src/game/results/ResultsViewModel.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/enemy-pressure.spec.ts`

## Cinderfen Watch

What the player should understand:

- Capture the raised Watch Road first to fund the push into fog.
- Fog hides the central Watchtower and raider camp.
- Pressure warnings are scoped responses, not a broad enemy economy simulation.
- Waystation preparation helps but is not required.

Currently unclear:

- The Watch Road objective is understandable but could better say that the next move is to hold income, scout the tower, and regroup.
- Pressure warnings tell the player enemy intent but not always the practical counterplay.
- The watchtower threat can feel abrupt when fog reveals it.

Feedback too late, too fast, too subtle, or too noisy:

- Pressure status uses a higher priority and longer duration than normal messages, which is good.
- Minimap markers help, but the pressure warning does not always name the route/counterplay in a compact way.
- Objective rows may truncate the most useful part of long descriptions on smaller viewports.

Visual-only debt to defer:

- Watchtower, raised road, and fog landmark readability require art direction later.
- Do not add new map icons or art in v0.12.

Fix-now candidates:

- Improve Watch Road objective copy and pressure warnings with concise action verbs.
- Keep pressure runtime warning-only or existing-wave-only; do not promote it into a broad AI/economy system.

Risk:

- Low for copy.
- Medium for tests that assert exact pressure warning strings.

Likely files:

- `src/game/data/maps/cinderfenWatchpost.ts`
- `src/game/data/enemyPressurePlans.ts`
- `src/game/battle/EnemyPressureRuntime.ts`
- `tests/e2e/enemy-pressure.spec.ts`
- `tests/e2e/layout.spec.ts`

## Skirmish Setup And Broken Ford

What the player should understand:

- Skirmish setup lets the player choose map, enemy profile, AI personality, and difficulty.
- Broken Ford is a tighter two-lane map with a risky center and safer side resources.
- Difficulty changes fog and starting pressure.

Currently unclear:

- Skirmish setup can list maps and launch correctly, but the player-facing difference between personalities/difficulty settings is mostly text-driven.
- Broken Ford's central ford risk is documented in map notes but not surfaced strongly once the battle begins.
- The player may not know whether tighter pathing is intentional map pressure or a pathing problem.

Feedback too late, too fast, too subtle, or too noisy:

- Battle-start summary mentions map/difficulty/personality, but it is easy to lose under early inputs.
- Path failure feedback is helpful but only appears when pathing fails; it does not distinguish "tight map lane" from a blocked destination.

Visual-only debt to defer:

- River crossing, ruin silhouettes, and lane readability are future map-art work.

Fix-now candidates:

- Clarify battle-start summary and pathing feedback copy without adding mechanics.
- Keep difficulty and AI behavior untouched unless simulator evidence shows unfair or unclear spikes.

Risk:

- Low for setup/battle-start copy.
- Medium for movement/pathing logic changes.

Likely files:

- `src/game/scenes/SkirmishSetupScene.ts`
- `src/game/data/maps/brokenFord.ts`
- `src/game/data/battlePacing.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

## Battle Results And Campaign Return Flow

What the player should understand:

- Victory means rewards, XP, node completion, and unlocks were applied according to mode.
- Defeat means victory rewards and battle XP were not saved.
- Repeat clears give reduced rewards and do not duplicate campaign node rewards.
- The next campaign choice should be obvious.

Currently unclear:

- Results contain many useful stats, but they read more like a ledger than a player-facing explanation.
- The player can see objectives completed/incomplete, but there is little "why you won/lost" interpretation.
- Campaign return status is mostly node/reward text; it could better point to the next useful action.

Feedback too late, too fast, too subtle, or too noisy:

- Victory status is concise but may not surface the most useful next campaign choice strongly enough.
- Defeat message is honest, but its advice is generic.
- Veteran and reward panels can push core battle outcome information down the page.

Visual-only debt to defer:

- Results background art and victory/defeat screen illustration quality are future art-overhaul items.

Fix-now candidates:

- Add concise "Battle readout" or improve existing guidance text so victory/defeat explains the outcome in player terms.
- Improve defeat tips using existing stats: captured sites, enemy waves survived, buildings built, units trained.
- Keep reward/save logic unchanged.

Risk:

- Low for guidance copy.
- Medium for result view model/tests, because results tests assert status and guidance strings.

Likely files:

- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/results/ResultsViewModel.ts`
- `src/game/results/ResultsObjectiveSummary.ts`
- `src/game/results/ResultsCampaignFlow.ts`
- `src/game/campaign/CampaignNodePanel.ts`
- `src/game/campaign/CampaignNavigation.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

## Phase 1 Candidate Priority

High-value, safe candidates for implementation:

1. Add clearer command acknowledgement for successful movement, attack, rally, build, train, and research without changing command semantics.
2. Make the selected order summary more prominent and readable in the side panel.
3. Shorten or clarify objective descriptions for Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.
4. Tune battle-status copy/read windows carefully so command and objective feedback is not buried by income ticks.
5. Improve pressure warning copy to name counterplay while preserving warning-only scope.
6. Improve results guidance so victory/defeat tells the player what happened and what to do next.

Deferred:

- New art, generated art, icons, terrain replacement, or asset swaps.
- New maps, factions, units, workers, enemy economy, or construction AI.
- Save-system changes.
- Broad balance changes without simulator evidence.
- Broad mechanics expansion beyond readability and feedback.
