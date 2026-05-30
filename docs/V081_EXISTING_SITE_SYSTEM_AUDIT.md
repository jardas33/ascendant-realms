# v0.81 Existing Site System Audit

Status: docs-only architecture audit for the future Lume Site Network prototype. No runtime code was changed.

## Scope

This audit inspects the current resource-site, Worker, campaign, HUD, Results, event, AI, replay, Tutorial, save, and test architecture so the first future Lume Network runtime slice can be small, battle-local, and reversible.

## Current Site Data Model

Resource sites are map content, not save data. `src/game/types/MapTypes.ts` defines `CaptureSiteDefinition` with `id`, `name`, `resource`, `x`, `y`, `radius`, `incomeAmount`, `incomeInterval`, and optional `firstCaptureBonus`. Maps store these definitions on `BattleMapDefinition.captureSites`.

Existing maps with usable sites:

| Map | Sites | Notes for Lume |
| --- | --- | --- |
| `first_claim` | `crown_shrine`, `stone_quarry`, `iron_vein`, `aether_well` | Best early teaching map, but already carries basic economy, Worker, production, and first-battle onboarding. |
| `broken_ford` | `ford_toll`, `west_stone_cut`, `south_iron_cache`, `north_aether_spring` | Best v0.81 candidate testbed. It is already a Control mission with tight lanes and an Aether/Lume-adjacent node. |
| `ashen_outpost` | `burned_shrine`, `west_supply_pyre`, `south_iron_pit`, `north_stone_scar` | Finale map is too busy for first Lume teaching because it already has phases, commander gating, elites, events, relics, and milestone rewards. |
| `cinderfen_causeway` | `causeway_toll`, `reedcut_quarry`, `sunken_iron_cache`, `cinder_crossing` | Strong later thematic candidate, but it belongs to Chapter 2 and should not be the first Act 1 Lume prototype. |
| `cinderfen_watchpost` | `watch_road_toll`, `blackreed_stonecut`, `ash_cistern` | Three-site map is structurally convenient, but it is a later chapter watchpost route. |

## Live Site Entity

`src/game/entities/CaptureSite.ts` implements `CaptureSite`.

Important fields:

- `owner`: `neutral`, `player`, or `enemy`.
- `capturingTeam` and `captureProgress`: live capture state.
- `incomeTimer`: site income tick timing.
- `siteLevel`: current resource-site upgrade tier, 1 or 2.
- `workerAssignments`, `assignedWorkerId`, `assignedWorkerName`, `workerAssignmentStatusDetail`, `workerAssignmentBoostActive`: player Worker-site boost state.
- `abstractEnemyWorkerSlots`: enemy logistics boost count.

Important safety behavior:

- `setOwner(owner)` resets capture progress, capturing team, income timer, site level, Worker assignments, and enemy abstract slots.
- That owner-change reset is the cleanest future severing trigger for Lume links.
- The entity already owns placeholder-safe ring/progress rendering. A future Lume prototype can add a restrained marker without new art, but v0.81 does not do that.

## Capture And Income Rules

`src/game/systems/ResourceSystem.ts` owns site capture, Worker assignment, site upgrades, and income.

Current flow:

1. `ResourceSystem.update(deltaSeconds, sites, units)` calls `updateCapture`, `updateWorkerAssignment`, and `updateIncome` for each site.
2. `updateCapture` checks nearby living player and enemy units inside `site.radius`.
3. Contested sites or empty sites pause progress.
4. One uncontested team increments capture progress.
5. Full progress calls `site.setOwner(capturingTeam)`, then `options.onCapture`, then optional first-capture bonus.
6. `updateIncome` adds resources every `incomeInterval` for player/enemy-owned sites.

Current resource depth:

- Worker assignment bonus: `WORKER_SITE_ASSIGNMENT_BONUS_RATIO = 0.2`.
- Site upgrade bonus: `RESOURCE_SITE_UPGRADE_BONUS_RATIO = 0.15`.
- Max level: `RESOURCE_SITE_MAX_LEVEL = 2`.
- Upgrade cost: `RESOURCE_SITE_UPGRADE_COST = { crowns: 120, stone: 80 }`.

## Worker Interaction

Workers do not harvest in a carry/drop-off loop. They are assigned to already captured player sites through `requestWorkerAssignment`, `issueWorkerAssignmentOrder`, and `validateWorkerSiteAssignmentRequest`.

Safety findings:

- Workers remain relevant to site economy through site-local boosts.
- Worker assignment is already explicit and readable.
- Assignment clears automatically when a site is no longer player-owned.
- The first Lume prototype should not add Living Mines or Worker binding. Worker relevance can be preserved by keeping resource-site assignment unchanged.

## Campaign And Mission Posture

Campaign battle nodes are in `src/game/data/borderMarchesNodes.ts`.

Relevant nodes:

- `border_village`: `first_claim`, Skirmish/Training. Too early.
- `old_stone_road`: `first_claim`, Control with Rich Veins. Good economy teaching, but still basic base-development onboarding.
- `aether_well_ruins`: `broken_ford`, Control with `mission_aether_surge`, enemy hero `veyra_cinders`. Best first Lume testbed.
- `bandit_hillfort`: `broken_ford`, Assault with `mission_enemy_patrols`, rival pressure. Too commander/pressure focused.
- `ashen_outpost`: `ashen_outpost`, Assault finale with `mission_fortified_enemy`, Captain Malrec. Too crowded.

Act 1 pacing lives in `src/game/data/act1CampaignSpine.ts`. `act1_aether_well_resource_control` already teaches resource sites, Worker assignment, site upgrades, and ability pacing. That makes it the safest first point where the player knows enough to learn one new territorial idea.

## HUD And Selection Surfaces

Current site surfaces:

- `src/game/ui/hudPanels/SelectedEntityPanel.ts` renders selected `CaptureSite` status: control, level, resource, income, upgrade bonus, Worker slots, Worker bonus, total income, and status.
- `src/game/ui/hudPanels/ObjectivePanel.ts` renders objectives, enemy doctrine, and one active battlefield event row.
- `src/game/campaign/CampaignNodePanel.ts` renders mission type, modifiers, reward state, enemy doctrine, tactical plan, optional objectives, and pre-battle intelligence.
- `src/game/ui/MinimapView.ts` renders capture-site markers.

Best future Lume UI surface:

- Battle HUD: one objective/event-style row, not a giant overlay.
- Selected site panel: local link state, if a linked site is selected.
- Results: one compact Lume outcome row.
- Campaign briefing: one sentence and one tag row for the chosen testbed mission only.

## Results And Telemetry

`src/game/results/ResultsObjectiveSummary.ts` already renders:

- first site captured;
- sites captured;
- enemy doctrine;
- tactical plan;
- battlefield events;
- special objectives;
- Act 1 finale;
- Retinue;
- relics and XP.

`BattleStats` in `src/game/types/MapTypes.ts` already carries battle-local telemetry arrays for events and finale phases. A future Lume prototype can follow that pattern with battle-local stats copied into Results only. v0.81 recommends no persistent Lume state.

## Enemy AI And Event Posture

Existing AI already understands sites:

- `src/game/ai/EnemyResourceSiteStrategy.ts` scores capture, retake, defend, and raid targets.
- `src/game/ai/EnemyAIController.ts` uses site scoring for raids, expansion, defense, upgrades, and abstract enemy worker logistics.
- `src/game/battle/BattlefieldEventDirector.ts` can target player-owned sites through `site_under_threat`.

The smallest Lume slice can rely on existing enemy recapture and site pressure. It does not need a new AI system. The only later AI hook that may be justified is a small score bonus toward active linked sites in the chosen mission.

## Save, Replay, And Tutorial Posture

Save files do not store site ownership. `src/game/save/SaveTypes.ts` stores hero data, campaign progression, rewards, optional objective completions, active modifiers, Retinue state, rivals, and selected campaign node/chapter.

Safety findings:

- `src/game/save/SaveDefaults.ts` keeps `CURRENT_SAVE_VERSION = 2`.
- `src/game/save/SaveNormalization.ts` filters unknown campaign modifiers, optional objective keys, Retinue units, rival records, and equipment safely.
- Tutorial launches are created by `createTutorialBattleLaunchRequest` in `src/game/battle/BattleLaunchRequest.ts`, with `rewardsDisabled: true`.
- `BattlefieldEventDirector.isBattlefieldEventDirectorEnabled` already gates events to `mode === "campaign_node"` and not rewards-disabled.

v0.81 recommendation: future Lume state should be battle-local, derived from map/site definitions and live ownership, not persisted. Tutorial and no-reward routes must be excluded.

## Test Coverage Extension Points

Existing relevant tests:

- `src/game/systems/ResourceSystem.test.ts`: capture, first-capture bonuses, Worker assignment, upgrades, enemy abstract slots.
- `src/game/data/contentValidation.test.ts`: maps, campaign, rewards, tutorials, modifiers, objectives.
- `src/game/battle/BattlefieldEventDirector.test.ts`: event selection, no-spam, objective outcomes, tactical-plan interaction.
- `src/game/battle/BattleRuntime.test.ts`: battle stats cloning and Results-facing stats.
- `src/game/campaign/CampaignPresentationViewModels.test.ts`: campaign briefing and node details.
- `src/game/results/ResultsViewModel.test.ts`: Results summary and reward clarity.
- `src/game/save` tests: save normalization and old-save safety.

Future Lume tests should be focused and reversible: pure link rules, map-content validation, Tutorial/no-reward exclusion, replay safety, HUD summary, Results summary, and one hosted proxy for the selected mission.

## Conclusion

The current site system is suitable for a small Lume Network prototype if the first slice stays mission-local and battle-local. The safest extension points are content-driven eligible-site metadata, a tiny link-state resolver, existing capture ownership, existing enemy site pressure, one HUD row, one Results row, and existing content validation. The first prototype should not add save fields, new resources, Living Mines, a graph-management UI, new AI architecture, or new art.
