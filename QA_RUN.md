# Ascendant Realms QA Run

Run date: 2026-04-26 onward

Last updated: 2026-05-03 00:16 -04:00

Scope: consolidated manual notes, automated verification, Browser Use sanity checks, and remaining manual-only QA areas for `LLM_GAME_HANDOFF.md`.

Tester: Codex.

## Latest Automated Verification - 2026-05-03 v0.2.1 Baseline Candidate

These are the current authoritative automated results after Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, Stronghold Tier II, reputation hooks, randomized item affixes V1, the CampaignRules split, HUD/fog polish, and permanent HUD/fog regression coverage. Older per-pass results remain below as historical notes.

```text
npm test
PASS: 36 test files passed, 210 tests passed during the v0.2.1 baseline candidate docs pass

npm run build
PASS: TypeScript compile passed, Vite production build passed during the v0.2.1 baseline candidate docs pass
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold. This is not a failure.

npm run test:e2e -- --reporter=line
Latest full recorded result: 49 Playwright tests passed after adding permanent HUD hover, side-panel scroll, captured-site fog, and command-reachability regression coverage. The e2e suite is slow; use a long timeout.

npm run playtest:sim
Latest simulator baseline: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json cover 180 simulated runs across 60 campaign battle node/profile summaries; no too-easy nodes; no structural too-hard nodes; Ashen Outpost beatable: yes; no Stronghold warnings
```

Current feature coverage includes Retinue rules/deployment/readability, Unit Veterancy rank/results display, Stronghold Tier II launch effects, affixed rewards and inventory stat contribution, reputation effects, enemy hero data validation, campaign node enemy-hero references, rival commander objective/results credit, persistent rival state normalization, campaign rival intel preview, Results rival outcome copy, battle-launch rival modifiers, first-defeat rival rewards, duplicate reward prevention, trophy save/load normalization, Campaign Map trophy display, Results trophy copy, CampaignRules facade/module behavior, HUD command hover stability, side-panel scroll preservation, captured-site fog visibility, desktop/tablet/mobile command reachability, and simulator telemetry for rival state before/after, outcome, modifiers, join timing, losses involving the rival, first-defeat rewards, duplicate prevention, and trophies.

The checkpoint containing Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, CampaignRules split, and HUD/fog polish was committed and pushed. Current HEAD before this v0.2.1 docs pass was `c277675`; the worktree also contained intentional uncommitted HUD/fog regression coverage and HUD refresh edits.

Do not reset, checkout, delete, or revert work unless the user explicitly asks. Future dirty work should be treated as intentional until proven otherwise.

## Latest Browser Use Sanity Checks

Latest recorded successful Browser Use check:

- Production preview at `http://127.0.0.1:4182/` rendered the Ascendant Realms main menu with `Prototype v0.2` and `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`.
- `Prototype v0.1` was absent.
- Browser console errors were 0.

Browser Use was used for visible local-browser confidence. Playwright remains the deterministic browser suite.

## Older Manual QA Notes

The sections below this point are chronological QA history from earlier visible Browser Use passes, focused Playwright runs, and manual-style checklist tracking. They are useful context, but the latest automated verification above supersedes older counts when they disagree.

Earlier manual/browser method:

- Used Browser Use against the in-app browser at `http://127.0.0.1:5173/` for visible smoke/play passes.
- Directly exercised settings persistence, campaign map inspection, Border Village launch, hero selection/movement, Crown Shrine capture, Command Hall selection, Barracks placement/construction, Militia/Ranger training, rally point setting, enemy pressure, minimap/fog visuals, and hero ability hotkeys `1`, `2`, and `3`.
- Did not click Reset Save in the user's in-app browser because it deletes local save data; reset-save behavior was verified in Playwright's isolated browser context.

## Current Remaining Manual-Only Areas

- Human-audible audio checks for music/SFX/mute behavior.
- Human-paced first battle feel through normal input: timing, stress, readability, and whether the first warning, Barracks completion, first trained unit, and first attack contact feel fair.
- Human-paced Normal branch checks for Aether Well Ruins and Bandit Hillfort from a typical early campaign save, including Veyra and Gorak readability.
- Human-paced Ashen Outpost assault with fog on, including Burned Shrine route readability, Captain Malrec/Hold the Line readability, fortress/tower pressure, and full-fight HUD clarity.
- Subjective campaign choice feel: Marcher Camp spending, Chapel preparation, reputation hooks, Retinue Camp choices, rival commander rewards/trophies, and whether Stronghold purchases make early campaign prep feel too generous or just meaningfully strategic.
- Rival and retinue readability still needs human-style review or additional automated surrogate tests around decision clarity, satisfaction, and whether rewards feel optional rather than mandatory.
- HUD hover/scroll feel and captured-site fog visibility now have automated regression checks, but the original bug was tactile and still deserves a human mouse-driven preview before release packaging.
- Mixed retinue and mixed retinue plus Training Yard II/Quartermaster II on Ashen Outpost need human review because telemetry flags them as strong but not structurally too easy.

No critical failures are currently known from automated verification.

## Crown Shrine Selected-Forces Copy Polish - 2026-04-30 21:13 -04:00

Scope: Browser Use follow-up on the Crown Shrine retake prompt after the building-selected selection guard.

Method:

- Inspected the live First Claim run after the previous retake hint fix.
- Found one more wording mismatch: with only Aster selected, the guide still said to right-click the Shrine with `hero and troops`.
- Changed the combat-selected retake prompt to say `Right-click the Crown Shrine with your selected forces.` so it remains accurate for the full squad, hero-only, or any selected player unit.
- Added unit coverage for the hero-only Crown Shrine retake prompt.
- Rechecked a fresh Browser Use skirmish: the opening starts with `4 units selected` and the guide now says `Right-click the Crown Shrine with your selected forces.`.

Verification:

```text
npm test -- --run src/game/battle/BattleSceneAlerts.test.ts
PASS: 1 test file passed, 4 tests passed

npm test
PASS: 30 test files passed, 145 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run playtest:sim
PASS: simulated 15 runs across 5 campaign battle nodes

Browser Use
PASS: fresh First Claim skirmish shows the selected-forces Crown Shrine prompt with the full starting squad selected.
```

## Crown Shrine Retake Selection Hint Polish - 2026-04-30 21:10 -04:00

Scope: Browser Use follow-up on the First Claim transition from tutorial economy into retaking or contesting the Crown Shrine.

Method:

- Continued the open Browser Use First Claim run until the enemy recaptured the Crown Shrine while the Barracks remained selected.
- Reproduced a clarity issue where right-clicking the Crown Shrine with Barracks selected set a rally point instead of moving the army, while the guide still said to right-click the shrine with hero and troops.
- Updated the first-battle tutorial hint to detect whether any player combat unit is selected before asking the player to retake a non-owned Crown Shrine.
- Added unit coverage for the building-selected retake state.
- Rechecked in Browser Use after Vite reloaded the local build: with Command Hall selected and the Crown Shrine not owned, the guide now says `Select your army, then right-click the Crown Shrine.`; combat-selected wording was tightened in the follow-up selected-forces copy pass.

Verification:

```text
npm test -- --run src/game/battle/BattleSceneAlerts.test.ts
PASS: 1 test file passed, 3 tests passed

npm test
PASS: 30 test files passed, 144 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run playtest:sim
PASS: simulated 15 runs across 5 campaign battle nodes

Browser Use
PASS: building-selected Crown Shrine retake prompt now asks for army selection; hero-selected state still asks the player to right-click the Crown Shrine.
```

## First Battle Construction Hint Polish - 2026-04-30 21:05 -04:00

Scope: Browser Use follow-up on the First Claim post-capture build flow after the opening squad and neutral-camp polish.

Method:

- Launched First Claim on Easy from Skirmish in Browser Use after reloading the patched dev build.
- Replayed the opening loop: move the starting squad to the Crown Shrine, capture it, select the Command Hall, enter Barracks placement, and place the highlighted Barracks site.
- Observed that the previous live flow briefly regressed the tutorial hint to `Select your Command Hall.` while the newly placed Barracks construction site was selected.
- Reordered the first-battle tutorial hint logic so an in-progress Barracks always shows the construction wait hint before checking Command Hall selection.
- Added unit coverage for the construction hint state and the earlier no-production Command Hall prompt.
- Continued the Browser Use run through Barracks completion and Militia training; the guide advanced to the first-defense prompt.

Verification:

```text
npm test -- --run src/game/battle/BattleSceneAlerts.test.ts
PASS: 1 test file passed, 2 tests passed

npm test
PASS: 30 test files passed, 143 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run playtest:sim
PASS: simulated 15 runs across 5 campaign battle nodes

git diff --check
PASS: no whitespace errors; existing .gitignore CRLF warning only

Browser Use
PASS: First Claim Easy now shows "Barracks is under construction. Hold near your base until it completes." while the construction site is selected, then advances to "Train Militia from your Barracks." and "Defend against the first attack near your Command Hall."
```

## First Claim Neutral Camp Opening Polish - 2026-04-30 20:57 -04:00

Scope: visible Browser Use follow-up on the First Claim opening after selecting the full starting squad by default.

Method:

- Launched First Claim on Easy from Skirmish in Browser Use.
- Reproduced a tutorial-readability issue where moving the full starting squad to the Crown Shrine could pull the nearby Sunken Road Pack into combat before production was built.
- Moved the Sunken Road Pack farther south-west on First Claim so the first capture remains clean, while keeping the camp visible as an optional nearby risk.
- Added a content validation test that keeps the tutorial Crown Shrine outside neutral-camp aggro plus opening formation spacing.

Verification:

```text
npm test -- --run src/game/data/contentValidation.test.ts
PASS: 1 test file passed, 6 tests passed

npm test
PASS: 29 test files passed, 141 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"
PASS: 1 targeted Playwright test passed

npm run playtest:sim
PASS: 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: First Claim Easy opening captures the Crown Shrine cleanly with no neutral combat, 0 XP gained, full hero HP, and the Sunken Road Pack visible lower on the map.
```

## Opening Squad Selection Polish - 2026-04-30 20:51 -04:00

Scope: visible Browser Use pass on the first skirmish opening after the automated telemetry and build checks.

Method:

- Opened the running dev build at `http://127.0.0.1:5173/` through Browser Use.
- Launched First Claim on Easy from Skirmish to avoid modifying the user's campaign save.
- Observed that the tutorial hint said to right-click the Crown Shrine with hero and troops, while only the hero was selected by default.
- Changed battle startup to select all starting player units, then added Playwright coverage that verifies the hero and all starting player units are selected on battle load.
- Rechecked the opening in Browser Use: the HUD now shows `4 units selected` with Aster, two Militia, and Ranger selected, and the first right-click can move the full squad toward the Crown Shrine.

Verification:

```text
npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"
PASS: 1 targeted Playwright test passed

npm run playtest:sim
PASS: 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: First Claim Easy opening visibly starts with the full player squad selected.
```

## Campaign Event Repeatability Coverage - 2026-04-30 19:42 -04:00

Scope: deterministic browser coverage for once-only campaign event choices that were still marked as partially unchecked.

Method:

- Expanded the existing campaign-choice Playwright flows instead of adding new runtime systems.
- Verified Refugee Caravan `Demand Tribute`, `Protect Them`, and `Recruit Volunteers` each record their `choiceIdsClaimed` entry.
- Verified the chosen Caravan option becomes disabled with `Already chosen`.
- Verified alternate Caravan options become disabled with `Node completed` after a completing choice.
- Verified Chapel `Ask for Guidance` remains non-completing but becomes disabled with `Already chosen`.
- Verified Chapel `Pray for Strength` and `Repair the Chapel` each record their claimed choice, complete the node, and disable alternate choices.
- Does not change gameplay, balance, rewards, save format, maps, factions, workers, affixes, or player-facing behavior.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Caravan once-only choices | [x] | Demand, Protect, and Recruit now have browser assertions for claimed IDs and disabled repeat buttons. |
| Caravan completed-node lockout | [x] | Alternate Caravan choices show `Node completed` after one completing choice resolves. |
| Chapel guidance repeat guard | [x] | Ask for Guidance keeps Chapel available but cannot be chosen twice. |
| Chapel completing choices | [x] | Pray and Repair now have browser assertions for claimed IDs, repeat lockout, and alternate-choice lockout. |
| Gameplay behavior | [x] | Coverage-only change; existing rules/UI already behaved correctly. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "campaign nodes, event choices|alternate Refugee Caravan|Chapel of the Marches guidance"
PASS: 3 targeted Playwright tests passed in 1.5m

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 38 Playwright tests passed in 13.0m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu title and New Campaign text visible at http://127.0.0.1:4177/ with 0 console errors
```

## Ashen Outpost Landmark Fog Coverage - 2026-04-30 19:24 -04:00

Scope: deterministic browser coverage for Ashen Outpost landmark scoutability and HUD overlap under fog.

Method:

- Added a Playwright layout test that launches Ashen Outpost on Normal so fog is active.
- Verifies the enemy Stronghold is hidden from the minimap before scouting.
- Uses test-only unit positioning to scout Burned Shrine, west/south/north resource sites, all neutral camps, enemy Stronghold, enemy Barracks, and the gate Watchtower.
- Verifies each scouted landmark becomes visible in the world and appears on the minimap.
- Verifies each centered landmark is not covered by the top bar, hero panel, side panel, minimap, objectives panel, status line, or hint line.
- Does not change gameplay, balance, maps, fog logic, save format, factions, workers, affixes, or player-facing behavior.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Fog baseline | [x] | Normal Ashen Outpost starts with fog cells and hides the enemy Stronghold marker before scouting. |
| Capture landmarks | [x] | Burned Shrine plus west/south/north resource sites become visible and minimap-marked after scouting. |
| Neutral camps | [x] | West Cinder Pack, North Ash Imps, and Shrine Ember Guardians labels and minimap markers appear after scouting. |
| Fortress landmarks | [x] | Enemy Stronghold, Enemy Barracks, and gate Watchtower become visible and minimap-marked after scouting. |
| HUD readability | [x] | Centered landmark points are not under the major HUD panels. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "Ashen Outpost landmarks"
PASS: 1 targeted Playwright test passed in 18.7s

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 38 Playwright tests passed in 13.3m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu heading and New Campaign button visible at http://127.0.0.1:4177/ with 0 console errors
```

## Minimap Marker And Ping Matrix Coverage - 2026-04-30 19:05 -04:00

Scope: deterministic browser coverage for the remaining minimap marker/ping checklist gap.

Method:

- Added a Playwright deep-flow test that launches First Claim on Story to avoid fog hiding marker families during this matrix check.
- Builds and completes a Barracks, selects it, and right-clicks a ground rally point through live input.
- Verifies the minimap snapshot includes unit, building, capture-site, camp, and rally marker families.
- Verifies player, enemy, and neutral marker teams are present.
- Verifies concrete marker IDs for Command Hall, Barracks, Crown Shrine, and the selected Barracks rally marker.
- Triggers live pings for `Rally point set`, `Enemy wave 1 incoming`, `Command Hall under attack`, and `Crown Shrine under attack`.
- Verifies the rendered minimap SVG contains site, building, unit, camp, rally, ping, and camera-rectangle elements.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Minimap marker families | [x] | Snapshot now has browser coverage for unit, building, capture-site, camp, and rally markers together. |
| Minimap teams | [x] | Snapshot covers player, enemy, and neutral marker teams. |
| Camera rectangle | [x] | Snapshot dimensions are positive and rendered SVG has one camera rectangle. |
| Live pings | [x] | Rally, enemy wave, base attack, and resource-site attack pings are covered in one deterministic browser test. |
| Render bridge | [x] | DOM/SVG assertions confirm snapshot families are actually rendered, not only present in data. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "minimap renders marker families"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 37 Playwright tests passed in 12.1m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Ability Hotkey Feedback Coverage - 2026-04-30 18:49 -04:00

Scope: deterministic browser coverage for the remaining hero ability hotkey gap.

Method:

- Added a Playwright deep-flow test that seeds a level-4 Warlord with Rally Banner, Cleave, and War Cry unlocked.
- Verifies the HUD exposes `1. Rally Banner`, `2. Cleave`, and `3. War Cry`.
- Presses `1`, `2`, and `3` through keyboard input and verifies mana is spent, cooldowns start, Rally Banner buffs allies, and Cleave/War Cry damage nearby enemies.
- Fixed successful ability feedback being overwritten by near-immediate duplicate cooldown retries.
- Ability SFX now plays only when the ability cast succeeds.
- The expanded hero creation/menu test now has a 60s timeout because its two hero creation passes can exceed the default 35s timeout on this machine.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Hotkey 1 | [x] | Rally Banner casts through keyboard input, spends mana, starts cooldown, and buffs nearby allies. |
| Hotkey 2 | [x] | Cleave casts through keyboard input, spends mana, starts cooldown, and damages nearby enemies. |
| Hotkey 3 | [x] | War Cry casts through keyboard input, spends mana, starts cooldown, buffs allies, and damages enemies. |
| Ability feedback | [x] | Fresh success messages are no longer replaced by immediate duplicate cooldown warnings. |
| Ability audio | [x] | Cast SFX is gated behind successful casts. |
| Test stability | [x] | Hero creation/menu flow timeout now matches observed runtime. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "unlocked hero ability hotkeys"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line -g "main menu, info"
PASS: 1 targeted Playwright test passed in 35.9s with the explicit 60s timeout

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 36 Playwright tests passed in 13.3m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Hero Creation And Click Selection Coverage - 2026-04-29 21:30 -04:00

Scope: deterministic browser coverage for two remaining player-control checklist gaps.

Method:

- Expanded the main menu/create/reset e2e flow to verify Arcanist and Shepherd hero class selections persist to the save, complementing the existing Warlord campaign battle creation path.
- Expanded the battle HUD e2e flow to center the camera on the live hero, click the hero on the canvas, verify the BattleScene selection contains the hero, and verify the side panel/order summary updates before using the `H` hotkey.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Hero class creation | [x] | Browser e2e now creates and verifies Arcanist and Shepherd saves; Warlord remains covered by the first campaign battle path. |
| Direct hero click selection | [x] | Browser e2e click-selects the hero on the battlefield canvas and verifies selected-hero HUD state. |
| Gameplay behavior | [x] | Coverage-only change; no runtime gameplay or balance behavior changed. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "main menu, info"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 35 Playwright tests passed in 12.1m after rerunning a transient local `net::ERR_NO_BUFFER_SPACE` browser resource failure

npm run test:e2e -- --reporter=line -g "all skirmish maps"
PASS: the previously interrupted skirmish launch test passed in isolation

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## First Enemy Wave Survival Coverage - 2026-04-29 21:00 -04:00

Scope: deterministic browser coverage for the remaining first-wave pressure checklist gap.

Method:

- Added a Playwright deep-flow test that launches Border Village through the live campaign battle path.
- Uses existing BattleScene test hooks to track the first enemy Raider wave, place it in melee range of the Command Hall, and tick live combat.
- Verifies the Command Hall takes damage, the `Enemy wave 1 incoming` and `Command Hall under attack` minimap pings are emitted, and the attack status is shown.
- Defeats the tracked wave and verifies `enemyWavesSurvived` increments to 1, the tracked wave clears, the Command Hall remains alive, and the HUD/status path reports `Enemy wave 1 defeated`.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| First-wave pressure | [x] | Live combat damage lowers Command Hall HP under tracked wave pressure. |
| First-wave alerts | [x] | E2E verifies incoming-wave and Command Hall under-attack minimap pings. |
| First-wave survival bookkeeping | [x] | E2E verifies the wave clears and `enemyWavesSurvived` increments. |
| Gameplay behavior | [x] | Coverage-only change; no runtime tuning or player-facing behavior changed. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "first enemy wave pressure can damage the base and be survived"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 35 Playwright tests passed in 12.7m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Difficulty Pacing And Fog Coverage - 2026-04-29 20:40 -04:00

Scope: coverage-only continuation pass for the remaining difficulty-selection gap after fog/minimap leakage coverage.

Method:

- Added a battle-pacing unit test that verifies Story, Easy, Normal, and Hard remain ordered from forgiving to punishing across first attack delay, attack interval, wave size, enemy income multiplier, training interval, and fog defaults.
- Added a browser smoke test that launches Story and Normal skirmishes from the UI and verifies the selected difficulty reaches the live BattleScene.
- Verified Story launches without fog and with only one starting Raider.
- Verified Normal launches with fog and a larger starting enemy roster: two Raiders, one Hexer, and one Enemy Commander.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Difficulty pacing data | [x] | Unit coverage checks ordered first attack delays, intervals, wave sizes, income, training intervals, and fog defaults. |
| Difficulty UI-to-battle bridge | [x] | Playwright verifies Story and Normal selections change live battle difficulty, fog state, and starting pressure. |
| Gameplay behavior | [x] | No runtime gameplay or balance changes were made in this pass. |

Verification:

```text
npm test -- battlePacing
PASS: 1 test file passed, 3 tests passed

npm run test:e2e -- --reporter=line -g "skirmish difficulty selection changes fog and starting pressure"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 140 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 34 Playwright tests passed in 11.5m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Fog And Minimap Visibility Coverage - 2026-04-29 20:25 -04:00

Scope: coverage-only continuation pass for the remaining fog/minimap information-leak concern after the in-world fog visibility test was already present.

Method:

- Strengthened the Border Village Playwright smoke flow so it checks both world visibility and minimap snapshot visibility while fog is active.
- Verified the unseen Stone Quarry site, Quarry Imps camp marker, and hidden neutral units are not exposed through minimap marker IDs before the player scouts them.
- Verified the minimap snapshot reports fog enabled and includes fog cells during the default Border Village campaign launch.
- Left minimap ping/full marker-matrix visual QA as a separate checklist item because this pass targeted fog leakage, not every possible minimap state.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| In-world fog hiding | [x] | Existing e2e still verifies hidden quarry camp label, hidden neutral units, hidden Stone Quarry view, and visible Crown Shrine. |
| Minimap fog state | [x] | E2E now verifies the snapshot has fog enabled and fog cells. |
| Minimap hidden-marker leakage | [x] | E2E now verifies hidden quarry camp/site/unit IDs are absent from minimap markers before scouting. |
| Gameplay behavior | [x] | No runtime gameplay or balance changes were made in this pass. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "campaign Border Village launches a battle scene"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 139 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 33 Playwright tests passed in 10.5m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 15 simulated runs across 5 campaign battle nodes

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Reward Keep-In-Inventory Clarity And Objective HUD Refresh - 2026-04-29 20:08 -04:00

Scope: Results usability and browser-test stability continuation pass after QA still listed the non-equip reward path as uncovered.

Method:

- Added a clear `Keep in Inventory` action beside `Equip Now` for newly earned equippable rewards.
- Added Results status feedback confirming the item is already saved and can be equipped later from Hero Inventory.
- Added reward-card copy that explains the item is already saved to inventory before the player chooses whether to equip it.
- Added unit coverage for the keep-in-inventory Results helper.
- Added Playwright coverage that keeps a victory reward unequipped, opens Hero Inventory, verifies the reward is still marked `New`, and verifies the weapon slot remains empty.
- Tightened the live first-campaign reward test so victory rewards are verified as saved but not auto-equipped.
- Fixed a flaky Ashen objective HUD path by refreshing the battle HUD immediately when secondary objectives complete, then added an explicit completed-objective ID assertion to the e2e test.
- Used Browser Use on the rebuilt production preview to confirm the main menu loads at `http://127.0.0.1:4177/` with 0 console errors.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Reward non-equip path | [x] | Players can explicitly keep a reward in inventory and get status feedback. |
| Inventory persistence coverage | [x] | E2E verifies the reward appears in Hero Inventory as new and the equipment slot remains empty. |
| Objective HUD freshness | [x] | Secondary objective completion now refreshes the HUD immediately instead of waiting for a later scene tick. |
| Gameplay behavior | [x] | No rewards, balance values, save format, maps, factions, workers, or affixes changed. |

Verification:

```text
npm test -- ResultsViewModel
PASS: 1 test file passed, 4 tests passed

npm run test:e2e -- --reporter=line -g "victory reward can be kept"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line -g "victory and defeat result actions"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line -g "first campaign battle path"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 139 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 33 Playwright tests passed in 11.0m

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Defeat Inventory Prep Action - 2026-04-29 19:37 -04:00

Scope: Results usability continuation pass after the defeat screen gave prep advice but did not offer the same direct inventory action available after victory.

Method:

- Added `Open Hero Inventory` to defeat Results actions alongside Retry and Campaign Map/Main Menu.
- Reused the saved-hero continuation path for defeat inventory navigation, matching Retry behavior and preventing unsaved battle XP or skill points from appearing in prep.
- Updated the progression screen eyebrow so defeat inventory prep is labeled `Hero Inventory` rather than `Victory Progression`.
- Expanded the Results navigation unit test to verify defeat inventory data uses the saved hero.
- Expanded the Playwright victory/defeat Results flow to click defeat `Open Hero Inventory` and verify the prep screen shows `Hero Inventory`, saved Level 1, and 0 skill points after synthetic unsaved battle XP.
- Used Browser Use on the rebuilt production preview to confirm the main menu loads at `http://127.0.0.1:4177/` with 0 console errors.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Defeat prep navigation | [x] | Defeat Results now provide direct Hero Inventory access. |
| Saved hero state | [x] | Defeat inventory prep uses saved hero progress, not unsaved battle XP/skill points. |
| Browser coverage | [x] | E2E verifies Retry, Open Hero Inventory, Campaign Map, and saved inventory progress after defeat. |
| Gameplay behavior | [x] | No gameplay, balance, save format, maps, factions, workers, or affixes changed. |

Verification:

```text
npm test -- ResultsViewModel
PASS: 1 test file passed, 3 tests passed

npm run test:e2e -- --reporter=line -g "victory and defeat result actions"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 138 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 32 Playwright tests passed in 11.7m

Browser Use
PASS: production preview main menu visible at http://127.0.0.1:4177/ with 0 console errors
```

## Defeat Results Saved Progress Clarity - 2026-04-29 19:03 -04:00

Scope: player-facing Results fix after Browser Use found an Ashen Outpost Defeat screen showing unsaved live battle XP as permanent hero progress.

Method:

- Updated the Results view model so defeats display the saved starting hero as the after-battle hero, because defeat does not persist live battle XP or level-ups.
- Updated the XP summary to show `XP saved: 0` on defeat, and to label any earned combat XP as `Battle XP earned` with `(not saved)`.
- Updated the Results scene so the top Hero Level badge, defeat tips, and current hero stat strip use saved hero progress on defeat.
- Updated the live BattleScene-to-Results handoff so normal defeat payloads use saved hero progress instead of the live in-battle hero snapshot.
- Expanded unit coverage for defeat progress display and Playwright coverage for defeat Results wording.
- Used Browser Use on the rebuilt production preview to verify the app boots with 0 console errors.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Defeat XP clarity | [x] | Defeat Results no longer present unsaved live XP/levels as permanent hero progress. |
| Saved hero display | [x] | The Hero Level badge and current stats use the saved hero on defeat. |
| Browser coverage | [x] | E2E verifies `XP saved`, `Battle XP earned`, `(not saved)`, no level-up, and Retry/Campaign actions. |
| Gameplay behavior | [x] | No gameplay, balance, save format, maps, factions, workers, or affixes changed. |

Verification:

```text
npm test -- ResultsViewModel
PASS: 1 test file passed, 3 tests passed

npm run test:e2e -- --reporter=line -g "victory and defeat result actions"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 138 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 32 Playwright tests passed in 11.6m
```

## Ashen Fortress Readability And Minimap Palette Coverage - 2026-04-27 22:23 -04:00

Scope: coverage and HUD-readability continuation pass for Ashen Outpost after Browser Use showed the desktop objective panel could occupy the right-side fortress view lane.

Method:

- Moved the desktop battle objectives panel from the right side under the minimap to the upper-left under the resource row.
- Added a deterministic desktop layout test that centers Ashen Outpost on the enemy stronghold area and verifies the objective panel does not cover the enemy Stronghold, enemy Barracks, or gate Watchtower focus points.
- Expanded the settings/accessibility Playwright test to verify rendered colorblind minimap SVG colors for player and enemy units, not only saved settings state.
- Used Browser Use on the rebuilt production preview to launch Ashen Outpost, click the minimap toward the upper-right fortress lane, and confirm the objectives panel stayed clear of that side of the playfield with 0 console errors.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Ashen objective placement | [x] | Objectives now sit upper-left on desktop, away from the minimap and enemy fortress lane. |
| Fortress overlap guard | [x] | Playwright verifies the objective panel does not cover Ashen stronghold, barracks, or gate Watchtower focus points. |
| Colorblind minimap rendering | [x] | Settings e2e now asserts the rendered player/enemy minimap colors use the colorblind palette. |
| Gameplay behavior | [x] | No gameplay, balance, save format, or runtime battle logic changed in this pass. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "settings screen persists accessibility options"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line -g "Ashen Outpost objectives do not cover"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 137 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 32 Playwright tests passed in 11.3m
```

## Old Stone Road Live Completion Coverage - 2026-04-27 22:04 -04:00

Scope: coverage-only continuation pass for the remaining direct Old Stone Road post-victory campaign gap.

Method:

- Added a deterministic Playwright test that seeds a Border Village-complete campaign, launches Old Stone Road through the live campaign battle path, forces victory through the existing BattleScene result path, and validates the saved campaign state.
- Verified Old Stone Road grants its first-clear campaign resources, records its reward claim, unlocks Aether Well Ruins, Bandit Hillfort, Refugee Caravan, and Marcher Camp, and returns to the campaign map with Old Stone Road marked Completed.
- Verified the completed Old Stone Road node cannot be started again from the campaign map, protecting against repeated live reward claims through the browser UI.
- Used Browser Use on the in-app browser to visually sanity-check Ashen Outpost launch and the building placement feedback loop after the prior HUD polish.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Old Stone Road live victory | [x] | Victory now has browser coverage through BattleScene Results, not only pure campaign rules. |
| Next-layer unlocks | [x] | Aether Well Ruins, Bandit Hillfort, Refugee Caravan, and Marcher Camp become Available. |
| Repeat reward protection | [x] | Completed Old Stone Road disables Start Battle on the campaign map after rewards are claimed. |
| Browser build feedback | [x] | Ashen Outpost Command Hall -> Build Barracks showed placement mode, valid-site text, ghost feedback, and construction-start confirmation. |
| Gameplay behavior | [x] | No gameplay, balance, save format, or runtime behavior changed in this pass. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "Old Stone Road victory"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 137 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 31 Playwright tests passed in 12.5m
```

## Alternate Campaign Choice Browser Coverage - 2026-04-27 21:43 -04:00

Scope: coverage-only continuation pass for early campaign choice branches that were still documented as optional/manual depth.

Method:

- Added a deterministic Playwright test for alternate Refugee Caravan and Chapel of the Marches branches.
- Verified Recruit Volunteers is locked for level 1 heroes with the visible "Requires hero level 2" reason.
- Verified Protect Them spends Crowns, completes Refugee Caravan, grants Scout's Bow, Inspired Militia, XP, and reputation.
- Verified Recruit Volunteers spends Crowns, grants Iron, Marcher Plate, Inspired Militia, XP, and reputation.
- Verified Pray for Strength completes Chapel of the Marches, grants Aether, Blessed Road, XP, reputation, and unlocks Ashen Outpost.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Refugee Caravan alternate choices | [x] | Protect Them and Recruit Volunteers now have browser e2e coverage. |
| Refugee Caravan lock reason | [x] | Recruit Volunteers shows a level requirement and is disabled for level 1 heroes. |
| Chapel alternate completion | [x] | Pray for Strength now has browser e2e coverage. |
| Gameplay behavior | [x] | No gameplay, balance, save format, or runtime behavior changed in this pass. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "alternate Refugee Caravan"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 137 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 30 Playwright tests passed in 10.9m
```

## Ashen Defeat Tip Browser Coverage - 2026-04-27 21:26 -04:00

Scope: coverage-only continuation pass for the Ashen Outpost objective-aware defeat advice added in the previous pass.

Method:

- Extended the synthetic Results e2e helper so browser tests can launch Results for a specific map, campaign node, difficulty, reward table, and completed secondary-objective state.
- Added a Playwright test that opens Ashen Outpost defeat Results before Burned Shrine completion and after Burned Shrine completion.
- Verified the Results screen shows Burned Shrine / gate Watchtower advice first, then Enemy Barracks / Stronghold advice after the shrine objective is already complete.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Browser defeat tips | [x] | Ashen Outpost defeat Results now have deterministic e2e coverage for staged objective recovery advice. |
| Suite growth | [x] | Full Playwright suite increased from 28 to 29 tests. |
| Gameplay behavior | [x] | No gameplay or balance code changed in this pass. |

Verification:

```text
npm run test:e2e -- --reporter=line -g "Ashen Outpost defeat tips"
PASS: 1 targeted Playwright test passed

npm test
PASS: 29 test files passed, 137 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 29 Playwright tests passed in 9.9m
```

## Telemetry Verdict And Defeat Tip Refinement - 2026-04-27 19:50 -04:00

Scope: continued improvement pass after the simulator was over-labeling fair-opening Normal nodes as structurally too hard.

Method:

- Refined `ScriptedBattlePlaytest` verdict logic so Safe Beginner victories plus fair first-wave/Barracks timing become `needs_human_review` strategy-spread findings instead of `too_hard`.
- Regenerated `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.
- Added Ashen Outpost objective-aware defeat tips for Burned Shrine, Enemy Barracks, and Outpost Captain sequencing.
- Used Browser Use against the production preview at `http://127.0.0.1:4177/` for a visible main-menu smoke check.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Telemetry verdicts | [x] | No current node reports structural `too_hard`; Aether Well Ruins, Bandit Hillfort, and Ashen Outpost are now marked `needs_human_review`. |
| Ashen defeat tips | [x] | Unit tests verify Burned Shrine advice appears before generic tips, then advances to Enemy Barracks advice after shrine completion. |
| Playtest artifacts | [x] | `npm run playtest:sim` regenerated both telemetry files from 15 deterministic runs. |
| Browser smoke | [x] | In-app browser loaded the production preview with 0 console errors. |

Verification:

```text
npm test
PASS: 29 test files passed, 137 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 28 Playwright tests passed in 10.2m

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json from 15 simulated runs across 5 campaign nodes
```

Remaining caveats:

- The simulator now avoids overclaiming unfairness, but it still cannot judge whether Normal risk scripts should be viable by design.
- Human judgment is still needed for final-assault stress, Ashen fortress readability, and whether Greedy/Fast strategies should be supported on milestone nodes.

## Ashen Objective Readability And Live Effect - 2026-04-27 19:29 -04:00

Scope: continued improvement pass for Ashen Outpost readability after telemetry treated the Burned Shrine as a staged assault advantage but live battle only recorded it as a completed objective.

Method:

- Added a focused live battle effect for the existing Ashen Outpost Burned Shrine objective.
- Added a compact battle objective HUD for maps with secondary objectives.
- Extended the existing Ashen Outpost Playwright flow to verify the objective panel and the live Watchtower weakening effect.
- Used Browser Use against `http://127.0.0.1:4177/` for a visible Ashen Outpost HUD check.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Ashen objective HUD | [x] | Ashen Outpost now shows Objectives 0/3 with Burned Shrine, Enemy Barracks, and Outpost Captain goals. |
| Burned Shrine live effect | [x] | Completing the Burned Shrine objective weakens the enemy gate Watchtower without destroying it. |
| Results objective states | [x] | Results still displays all three Ashen secondary objectives as Completed when test hooks complete them. |
| Telemetry alignment | [x] | Simulator output still reports Ashen Outpost beatable by Safe Beginner after Burned Shrine staging. |
| Browser smoke | [x] | In-app browser rendered the Ashen HUD with 0 console errors. |

Verification:

```text
npm test
PASS: 29 test files passed, 133 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json from 15 simulated runs across 5 campaign nodes

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives"
PASS: 1 targeted Playwright test passed

npm run test:e2e -- --reporter=line
PASS: 28 Playwright tests passed in 9.7m
```

Remaining caveats:

- The objective effect is intentionally Ashen-specific; broader secondary-objective reward/effect data should wait until the campaign has more objective variety.
- Human judgment is still needed for whether the new objective panel is the right long-term HUD placement during full fortress play.

## Enemy AI Config And Telemetry Balance Follow-Up - 2026-04-27 19:03 -04:00

Scope: continued improvement pass for automated balance credibility and early/milestone battle pacing after the config-aligned simulator exposed faster Easy pressure and a still-too-static Ashen fortress read.

Method:

- Fixed live `EnemyAIController` to respect map-level `scenario.enemyAI` timing and wave values instead of only the global difficulty defaults.
- Fixed `ScriptedBattlePlaytest` to use the same map-level enemy AI config so automated telemetry matches live runtime pacing.
- Tuned only existing pacing/balance data and dev-only telemetry modeling; no new maps, factions, workers, affixes, or player-facing systems were added.
- Used Browser Use against `http://127.0.0.1:4177/` for a final visible main-menu smoke check.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Live enemy AI config usage | [x] | Unit coverage verifies first attack delay and wave size come from map AI config. |
| Simulator config usage | [x] | Playtest sim now uses map attack/train/expand cadence and unit plan after personality modifiers. |
| Easy opening timing | [x] | Border Village and Old Stone Road remain 3/3 wins with no late Barracks pressure risk. |
| Ashen Outpost beatability | [x] | Safe Beginner wins Ashen after Burned Shrine staging; Greedy Economy and Fast Army still time out. |
| Browser smoke | [x] | In-app browser rendered the main menu with 0 console errors. |

Verification:

```text
npm test
PASS: 28 test files passed, 130 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 28 Playwright tests passed in 9.4m

npm run playtest:sim
PASS: 15 simulated runs across 5 campaign nodes; Ashen Outpost beatable: yes
```

Remaining caveats:

- Bandit Hillfort and Ashen Outpost still report `too_hard` by strict script-count because only Safe Beginner wins.
- Human judgment is still needed for long-form battle stress, fortress readability, and whether Greedy/Fast should be viable on Normal milestone nodes.

## Battle Feedback And Fog Polish - 2026-04-27 18:27 -04:00

Scope: continued improvement pass for player-facing battle clarity and deterministic regressions after reported issues around building placement feedback, unclear research effects, auto-attacks, and fog.

Method:

- Used Browser Use against the local app at `http://127.0.0.1:5173/` for a visible HUD sanity check.
- Used unit tests for order-state text, player auto-attack behavior, and exact fog visibility.
- Used Playwright e2e for HUD placement/order feedback and Border Village fog visibility.
- Used the automated playtest simulator as a structural balance smoke check after the UI/systems pass.

Changes verified:

| Area | Pass | Notes |
|---|:---:|---|
| Building placement feedback | [x] | Placement mode now shows a dedicated banner and suppresses conflicting first-battle hints. |
| Research/build/train clarity | [x] | Command buttons show descriptions and concise stat/effect summaries. |
| Unit auto-attack behavior | [x] | Units stop to fight enemies in weapon range, idle units guard-chase nearby threats, and normal move orders avoid distant aggro pulls. |
| Selected-unit order clarity | [x] | HUD shows Guarding/Moving/Attack-moving/Attacking for selected units and summarizes mixed unit selections. |
| Fog entity visibility | [x] | Exact source-distance checks prevent coarse cells from revealing distant entities; neutral camp labels and unowned sites require current vision. |
| Fog settings/debug | [x] | Fog debug respects the current battle/settings override and reports when fog is disabled. |

Verification:

```text
npm test -- UnitOrderSummary CombatSystem FogOfWarSystem
PASS: 3 test files, 12 tests

npm run test:e2e -- --reporter=line tests/e2e/smoke.spec.ts -g "campaign Border Village launches a battle scene"
PASS: 1 targeted Playwright test

npm run test:e2e -- --reporter=line tests/e2e/deep-flow.spec.ts -g "battle HUD supports"
PASS: 1 targeted Playwright test

npm test
PASS: 28 test files passed, 129 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 28 Playwright tests passed in 10.5m

npm run playtest:sim
PASS: regenerated telemetry from 15 simulated runs across 5 campaign nodes
```

Remaining caveats:

- The in-app browser tab had local saved settings, so Browser Use was treated as a HUD readability sanity check rather than the source of truth for default fog behavior.
- Human judgment is still needed for audible audio, long-form battle stress, and Ashen Outpost fortress readability.

## Targeted Battle Commands QA - 2026-04-26 20:15 -04:00

Scope: focused browser QA for the recently changed battle HUD, building placement feedback, construction, training, rally, responsive command panels, audio settings, and nearby regressions.

Method:

- Used Browser Use after session resume for a non-destructive visible sanity check of the local app main menu at `http://127.0.0.1:5173/`.
- Used Playwright against the local app at `http://127.0.0.1:5173/` for the detailed targeted battle-command pass in an isolated browser context.
- Used real browser clicks, right-clicks, pointer moves, and key presses for player-facing command behavior.
- Used deterministic scene time advancement for construction/training timers to avoid waiting several real minutes.
- Captured screenshots under `test-results/targeted-battle-commands/`.
- No source code changes were made and no bugs were fixed, so `npm test`, `npm run build`, and full e2e were not rerun during this documentation-only QA update. The latest safety checkpoint already has all three passing.

### Targeted Results

| Area | Pass | Fail | Notes | Bug severity | Follow-up action |
|---|:---:|:---:|---|---|---|
| Start new campaign and launch Border Village | [x] | [ ] | New Warlord campaign launched First Claim / Border Village battle HUD. | None | None. |
| Select Command Hall | [x] | [ ] | Command Hall selected by canvas click; building commands were visible. | None | None. |
| Build Barracks placement ghost | [x] | [ ] | Ghost appeared immediately near Command Hall, about 146px from the source building. Screenshot: `test-results/targeted-battle-commands/02-barracks-placement-ghost.png`. | None | None. |
| Active placement status | [x] | [ ] | Status line showed `Placing Barracks - click a highlighted site or choose another location.` | None | None. |
| Valid/invalid placement reasons | [x] | [ ] | Moving pointer over Command Hall showed `Overlaps another structure.` Moving back to a valid site showed `Valid building site.` | None | None. |
| Resources before placement | [x] | [ ] | Resources were unchanged while the placement ghost was active and before final placement. | None | None. |
| Esc cancels placement | [x] | [ ] | Pending placement cleared, status changed to `Building placement cancelled`, and resources stayed unchanged. | None | None. |
| Right-click cancels placement | [x] | [ ] | Right-click also cleared pending placement, status changed to `Building placement cancelled`, and resources stayed unchanged. | None | None. |
| Place Barracks cost timing | [x] | [ ] | Resources deducted only after placement: Crowns 380 -> 200, Stone 255 -> 135. Screenshot: `test-results/targeted-battle-commands/03-barracks-under-construction.png`. | None | None. |
| Under-construction Barracks | [x] | [ ] | Barracks appeared under construction with progress visible; incomplete Barracks exposed no train buttons. | None | None. |
| Completed Barracks training controls | [x] | [ ] | After deterministic construction completion, Militia and Ranger training buttons were visible. Screenshot: `test-results/targeted-battle-commands/04-barracks-completed-train-buttons.png`. | None | None. |
| Queue Militia and Ranger | [x] | [ ] | Militia and Ranger both queued; resources were paid on queue. Screenshot: `test-results/targeted-battle-commands/05-training-queue.png`. | None | None. |
| Cancel queued unit refund | [x] | [ ] | Canceling queued Ranger left Militia active and refunded Ranger cost; resources returned to Crowns 140, Iron 120 after Militia remained paid. | None | None. |
| Trained unit spawn | [x] | [ ] | Militia spawned after training completion. | None | None. |
| Rally point | [x] | [ ] | Barracks rally point set by right-click; world rally marker appeared. Screenshot: `test-results/targeted-battle-commands/06-rally-marker.png`. | None | None. |
| Rally minimap marker | [x] | [ ] | Minimap snapshot contained one rally marker for the selected Barracks. | None | None. |
| Trained unit rally behavior | [x] | [ ] | Newly trained Militia received rally behavior and moved/arrived near the rally point. | None | None. |
| Tablet command panel | [x] | [ ] | Hero panel, Command Hall build buttons, and Barracks train/research buttons fit with no horizontal overflow at 820x620. Screenshot: `test-results/targeted-battle-commands/07-responsive-tablet-short.png`. | None | None. |
| Mobile-tall command panel | [x] | [ ] | Hero panel, Command Hall build buttons, and Barracks train/research buttons fit with no horizontal overflow at 390x844. Screenshot: `test-results/targeted-battle-commands/07-responsive-mobile-tall.png`. | None | None. |
| Mobile-short command panel | [x] | [ ] | Hero panel, Command Hall build buttons, and Barracks train/research buttons fit with no horizontal overflow at 360x640. Screenshot: `test-results/targeted-battle-commands/07-responsive-mobile-short.png`. | None | None. |
| SFX mute/unmute behavior | [x] | [ ] | Fake AudioContext verified SFX volume 0 suppressed battle oscillator starts and SFX volume 0.75 produced starts. Actual audible output still requires human ears. | None | Human audible check remains. |
| Hero ability hotkey regression | [x] | [ ] | `1` cast Rally Banner and consumed mana. Screenshot: `test-results/targeted-battle-commands/01-hero-selected-ellipse.png`. | None | None. |
| Minimap click regression | [x] | [ ] | Clicking minimap changed camera scroll. | None | None. |
| Fog toggle regression | [x] | [ ] | Pressing `F` updated fog debug/status feedback. | None | None. |
| Flat selection marker regression | [x] | [ ] | Selected hero marker was a flat `Ellipse2` footprint, 61.1x16.12. | None | None. |

### Targeted Bugs Found

| ID | Severity | Area | Reproduction | Expected | Actual | Fix applied |
|---|---|---|---|---|---|---|
| None | None | Battle commands | Targeted Playwright pass across build, construction, train/cancel/refund, rally, responsive panels, audio settings, minimap, fog, and selection markers. | No blocking failures. | No confirmed game bug found. | None. |

### Targeted Caveats

- Audible audio was not human-verified. Automation only verified the WebAudio creation path is suppressed when SFX volume is zero and active when SFX is unmuted.
- Construction and training completion were advanced deterministically through scene time rather than waiting real-time durations.
- The responsive check verified horizontal fit and command reachability, not long-session ergonomics under combat pressure.

## Automated Coverage Expansion - 2026-04-27 00:01 -04:00

Scope: targeted Playwright coverage for implemented systems that were still under-tested in browser/e2e. No gameplay features, balance values, maps, factions, workers, or affixes were added.

Method:

- Added deterministic browser tests in `tests/e2e/deep-flow.spec.ts` for Chapel of the Marches, Mystic Lodge/Acolyte, Watchtower combat, research UI, and Ashen Outpost special objective Results states.
- Expanded `tests/e2e/smoke.spec.ts` settings coverage for floating text, reduced motion, fog override, and colorblind minimap persistence.
- Used existing battle-scene systems and Playwright-only acceleration/repositioning to avoid long real-time waits.
- Used test-only objective hooks for Ashen Outpost secondary objectives, then verified the player-facing Results screen displays the completed states.

Verification:

```text
npm run test:e2e -- --reporter=line -g "Chapel|Mystic|Ashen|settings screen persists"
PASS: 4 targeted Playwright tests passed in 1.7m

npm test
PASS: 26 test files passed, 121 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 28 Playwright tests passed in 11.2m
```

### Coverage Added

| Area | Pass | Notes |
|---|:---:|---|
| Chapel of the Marches guidance | [x] | Ask for Guidance unlocks/scouts but does not complete the node. |
| Chapel completing choice | [x] | Repair the Chapel spends resources, grants rewards, removes Angered Raiders, adds Local Support, and completes the node. |
| Mystic Lodge | [x] | Built through battle placement, accelerated to completion, selected through the HUD. |
| Acolyte training | [x] | Trained through Mystic Lodge UI and verified as a live player unit. |
| Watchtower combat | [x] | Built/completed Watchtower damages a repositioned enemy unit in range. |
| Research UI | [x] | Insufficient-resource lock reason verified, then Infantry Weapons I, Reinforced Armor I, Ranger Training I, and Aether Study I researched through UI buttons. |
| Ashen Outpost objectives | [x] | Burned Shrine, Enemy Barracks, and Outpost Captain objective completions appear as Completed on Results. |
| Settings/accessibility persistence | [x] | Floating text off, reduced motion, fog override disabled, and colorblind minimap palette persist after save/reopen and into battle settings. |
| Floating text display regression | [x] | With floating text disabled, forced combat damage does not add damage-number text. |
| Fog/minimap settings bridge | [x] | Fog override disables active battle fog; colorblind minimap palette is reflected in the minimap snapshot. |

### Coverage Caveats

- Watchtower combat uses an existing enemy unit repositioned through Playwright so the test is deterministic.
- Ashen Outpost secondary objectives use a Playwright test hook to mark objective completion before forcing victory.
- Reduced motion is verified as persisted and applied to the document dataset; full visual animation feel remains a human/browser visual check.
- Audio audibility remains a human check.

Status legend:

- Pass checked: verified in this QA run through Playwright browser coverage.
- Fail checked: reproduced failure.
- Neither checked: not fully verified in this QA run; see notes.

Severity legend:

- Critical: blocks boot, save, campaign/battle launch, or corrupts progress.
- High: blocks a core flow but has workaround.
- Medium: confusing or broken secondary flow.
- Low: polish/clarity issue.
- None: no bug found.

## Summary

| Area | Status | Notes |
|---|---|---|
| Settings persistence | Pass | Browser Use directly verified earlier settings changes; Playwright now covers floating text, reduced motion, fog override, colorblind minimap persistence, and rendered player/enemy colorblind minimap colors in battle. |
| New campaign and hero creation | Pass | Playwright verifies Warlord, Arcanist, and Shepherd creation paths persist to save. |
| Campaign map and node state | Pass | Browser Use inspected the campaign map; Playwright verifies available/locked nodes, resources, choices, and town services. |
| First battle RTS loop | Pass with caveat | Browser Use directly verified capture/build/train/rally/enemy pressure; Playwright verifies deterministic victory rewards. Full long-form balance feel still needs human play. |
| Defeat/victory/rewards | Pass with caveat | Playwright verifies Results flows, Equip Now, defeat tips, live objective resolution, and defeat-only unsaved battle XP labeling; full human-paced win still pending. |
| Campaign events and town services | Pass with caveat | Refugee Caravan Demand/Protect/Recruit, Marcher Camp, and Chapel guidance/repair/pray are covered; human preference feel remains manual. |
| Skirmish maps and Ashen Outpost | Pass with caveat | All maps launch; Ashen Outpost Results objective states, objective-panel placement, landmark scoutability under fog, minimap markers, and major HUD-overlap guards are covered. Human full-fight readability feel remains manual. |
| Critical failures | Pass | None found. |

## Checklist

| # | QA item | Pass | Fail | Notes | Bug severity | Follow-up action |
|---:|---|:---:|:---:|---|---|---|
| 1 | Start dev server and open `http://127.0.0.1:5173/`. | [x] | [ ] | Playwright started Vite and opened local app. | None | None. |
| 2 | Main menu appears. | [x] | [ ] | `main-menu` visible in smoke/deep tests. | None | None. |
| 3 | Settings opens from main menu. | [x] | [ ] | Settings screen visible in smoke test. | None | None. |
| 4 | Change audio volume, reduced motion, floating text, UI scale, fog override, and colorblind minimap palette. | [x] | [ ] | Browser Use changed master volume to 40%, UI scale to 110%, reduced motion on, floating text off, colorblind minimap on, and fog override disabled. | None | None. |
| 5 | Save settings, return to menu, reopen Settings, and verify persistence. | [x] | [ ] | Browser Use reopened Settings and confirmed saved values persisted. | None | None. |
| 6 | Reset Save works from the main menu. | [x] | [ ] | Deep test verifies reset disables Continue Campaign and Inventory in an isolated browser context. Direct in-app reset was intentionally not clicked because it deletes local save data. | None | None. |
| 7 | New Campaign with no playable save opens hero creation. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 8 | Create each hero class at least once. | [x] | [ ] | Deep Playwright now verifies Arcanist and Shepherd creation persists to save; Warlord is exercised in the first campaign battle path. | None | None. |
| 9 | Campaign map opens after hero creation. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 10 | Campaign bank displays Crowns, Stone, Iron, and Aether. | [x] | [ ] | Deep test verifies campaign bank text and resources. | None | None. |
| 11 | Reputation and active modifiers display. | [x] | [ ] | Deep test verifies reputation/modifier state through campaign choices. | None | None. |
| 12 | Border Village is available at campaign start. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 13 | Locked nodes cannot start. | [x] | [ ] | Smoke test verifies locked node disables launch. | None | None. |
| 14 | Border Village launches First Claim. | [x] | [ ] | Browser Use launched Border Village and observed the First Claim battle HUD. | None | None. |
| 15 | In battle, select hero with click and `H`. | [x] | [ ] | Deep battle HUD test now click-selects the hero on the canvas, verifies selected-hero HUD state, then keeps the existing `H` hotkey coverage. | None | None. |
| 16 | Move hero/units with right-click. | [x] | [ ] | Browser Use right-clicked Crown Shrine; hero moved from base to the site. | None | None. |
| 17 | Capture Crown Shrine. | [x] | [ ] | Browser Use observed Crown Shrine ownership/capture ring turning player-green and resource income increasing. | None | None. |
| 18 | Select Command Hall. | [x] | [ ] | Browser Use clicked Command Hall and verified the side panel/actions. | None | None. |
| 19 | Place Barracks and verify valid/invalid placement reasons. | [x] | [ ] | Targeted battle pass confirmed nearby Barracks ghost, valid/invalid placement messages, cancellation, and final placement cost timing. | None | None. |
| 20 | Barracks appears under construction and cannot train until complete. | [x] | [ ] | Browser Use observed Construction state first, then Train actions only after completion. | None | None. |
| 21 | Completed Barracks can train Militia and Ranger. | [x] | [ ] | Browser Use trained Militia and Ranger from a completed Barracks. | None | None. |
| 22 | Queue progress displays and cancel/refund works. | [x] | [ ] | Targeted battle pass queued Militia and Ranger, canceled Ranger, left Militia active, and confirmed the Ranger refund. | None | None. |
| 23 | Set Barracks rally point with right-click ground. | [x] | [ ] | Browser Use set a ground rally point; HUD changed to `Rally Point: Set`. | None | None. |
| 24 | Rally marker appears and trained units move to it. | [x] | [ ] | Targeted battle pass confirmed world rally marker, minimap rally marker, and newly trained Militia rally behavior. | None | None. |
| 25 | Build Mystic Lodge and train Acolyte. | [x] | [ ] | Deep Playwright now builds Mystic Lodge, completes construction, trains Acolyte, and verifies a live Acolyte. | None | None. |
| 26 | Build Watchtower and verify it attacks when enemies approach. | [x] | [ ] | Deep Playwright now builds/completes Watchtower, repositions an existing enemy unit into range, and verifies HP decreases. | None | Human visual confirmation still useful. |
| 27 | Research Infantry Weapons I, Ranger Training I, Reinforced Armor I, and Aether Study I. | [x] | [ ] | Deep Playwright now researches all four through HUD buttons and verifies researched lock states. | None | None. |
| 28 | Verify locked train/upgrade buttons show reasons. | [x] | [ ] | Deep Playwright verifies an insufficient-resource upgrade lock reason in the Research UI. | None | Broader lock-reason matrix still optional. |
| 29 | Use hero abilities with `1`, `2`, `3`. | [x] | [ ] | Deep Playwright now seeds an unlocked Warlord, verifies all three ability labels, presses `1`, `2`, and `3`, and confirms mana/cooldown plus buff/damage effects. | None | None. |
| 30 | Verify audio cues are audible when volume is on and silent/muted when volume is zero. | [ ] | [ ] | Automation cannot honestly verify audibility. | None | Human audio check required. |
| 31 | Verify floating text can be disabled. | [x] | [ ] | Smoke Playwright persists floating text off and verifies forced combat damage does not add damage-number text. | None | None. |
| 32 | Verify reduced motion removes floating text tweening and CSS motion. | [x] | [ ] | Smoke Playwright verifies reduced motion persists and applies to the document dataset. | None | Human visual animation feel still useful. |
| 33 | Verify fog hides enemy/neutral entities outside vision. | [x] | [ ] | Smoke Playwright verifies the unseen quarry camp label, neutral units, Stone Quarry site, and matching minimap markers stay hidden while Crown Shrine remains visible. | None | Human visual pass still useful for subjective fog readability. |
| 34 | Press `F` on fog-enabled difficulty and verify fog debug toggles. | [x] | [ ] | Deep battle HUD test verifies fog status feedback. | None | None. |
| 35 | Verify Settings fog override can disable/enable fog regardless of difficulty default. | [x] | [ ] | Smoke Playwright verifies disabled fog override persists and makes Normal battle fog inactive. | None | Enabled override on Story remains optional. |
| 36 | Verify minimap shows units, buildings, sites, camera rectangle, rally marker, and pings. | [x] | [ ] | Deep Playwright now verifies snapshot and rendered SVG coverage for unit/building/site/camp/rally markers, camera rectangle, player/enemy/neutral teams, and rally/wave/base/resource pings. | None | Human visual readability remains useful, but the marker/ping matrix is covered. |
| 37 | Verify colorblind minimap palette changes player/enemy/neutral colors. | [x] | [ ] | Smoke Playwright verifies the persisted colorblind palette reaches the battle minimap snapshot and rendered player/enemy SVG colors. | None | Human neutral-color comparison still useful. |
| 38 | Click minimap and confirm the camera recenters. | [x] | [ ] | Deep battle HUD test covers minimap click handling. | None | None. |
| 39 | Survive or intentionally lose the first wave. | [x] | [ ] | Deep Playwright now tracks a live first Raider wave, verifies Command Hall damage/alerts, defeats the wave, and confirms `enemyWavesSurvived` increments. | None | Human feel pass still useful for natural pacing and stress. |
| 40 | Defeat screen shows contextual tips and retry/campaign return. | [x] | [ ] | Deep tests verify defeat tips/actions and that unsaved battle XP is labeled as not saved. | None | None. |
| 41 | Victory screen shows map, difficulty, battle time, XP, level progress, item rewards, campaign rewards, and campaign bank. | [x] | [ ] | Synthetic/live Results tests verify major fields; defeat Results now separately verify saved-progress display. | None | Human full victory still recommended. |
| 42 | Equip Now changes stats and persists after leaving Results. | [x] | [ ] | Deep test verifies Equip Now save path. | None | None. |
| 43 | Send-to-inventory behavior leaves item in inventory. | [x] | [ ] | Deep Playwright verifies `Keep in Inventory`, the reward remains marked New in Hero Inventory, and the relevant equipment slot stays empty. | None | None. |
| 44 | Campaign victory completes Border Village and unlocks Old Stone Road. | [x] | [ ] | Deep live battle objective-resolution test verifies. | None | None. |
| 45 | Continue Campaign returns to saved campaign state. | [x] | [ ] | Deep/smoke tests verify. | None | None. |
| 46 | Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, Marcher Camp, and Refugee Caravan unlock. | [x] | [ ] | Deep Playwright now launches Old Stone Road through the live campaign battle path, forces victory, and verifies all four next routes become Available. | None | None. |
| 47 | Open Marcher Camp and verify repeatable services, once-only purchases, costs, locked reasons, and save persistence. | [x] | [ ] | Deep test verifies repeatable service and once-only purchase persistence. | None | None. |
| 48 | Open Refugee Caravan and verify choices, costs, locked reasons, and reputation/resource effects. | [x] | [ ] | Deep tests verify Demand Tribute, Protect Them, Recruit Volunteers, and the Recruit level lock reason. | None | None. |
| 49 | Open Chapel of the Marches and verify choices, non-completing guidance choice, and completing choices. | [x] | [ ] | Deep Playwright verifies Ask for Guidance keeps the node open, Repair the Chapel completes with rewards/removals, and Pray for Strength completes with Blessed Road. | None | None. |
| 50 | Verify once-only choices cannot be repeated. | [x] | [ ] | Marcher Camp once-only purchase verified. Chapel/Caravan once-only not fully checked. | None | Extend event-specific coverage later. |
| 51 | Verify campaign node rewards cannot be claimed repeatedly. | [x] | [ ] | Border Village and Old Stone Road reward claims are verified; Old Stone Road also verifies completed battle nodes disable Start Battle in the browser UI after first claim. | None | Core duplicate-reward guard remains covered by unit tests. |
| 52 | Skirmish Setup opens separately from campaign. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 53 | First Claim launches from Skirmish Setup. | [x] | [ ] | Deep map launch loop verifies. | None | None. |
| 54 | Broken Ford launches from Skirmish Setup. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 55 | Ashen Outpost launches from Skirmish Setup. | [x] | [ ] | Deep map launch loop verifies. | None | None. |
| 56 | Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers. | [x] | [ ] | Playwright now verifies Normal fog is active, enemy Stronghold stays hidden before scouting, Burned Shrine/resource sites/neutral camps/Stronghold/Barracks/gate Watchtower become visible and minimap-marked after scouting, and centered landmarks are not under major HUD panels. | None | Human full-fight readability remains useful for feel, but the landmark/fog/HUD matrix is automated. |
| 57 | Ashen Outpost Results screen shows special objective completion states. | [x] | [ ] | Deep Playwright marks the Burned Shrine, Enemy Barracks, and Outpost Captain objectives complete, then verifies Results shows Completed for each. | None | Human visual fortress pass still recommended. |
| 58 | Difficulty selection changes AI pacing/fog behavior. | [x] | [ ] | Unit tests verify ordered difficulty pacing/fog defaults; Smoke Playwright verifies Story vs Normal selection changes live battle fog and starting enemy pressure. | None | Human feel comparison still useful for whether each difficulty feels right. |
| 59 | AI personality selection changes displayed enemy style and launches without errors. | [x] | [ ] | Deep map/personality launch loop verifies. | None | None. |
| 60 | Hero Inventory opens from main menu. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 61 | Equipping/unequipping items changes hero stats. | [x] | [ ] | Deep inventory test verifies equip/unequip persistence. | None | None. |
| 62 | Skill point spending persists. | [x] | [ ] | Deep inventory/skill test verifies. | None | None. |
| 63 | Asset Gallery opens without crashing. | [x] | [ ] | Deep test verifies gallery navigation. | None | None. |
| 64 | Browser console has no new hard errors. | [x] | [ ] | Deep tests attach console/pageerror failure hooks; no hard errors in passing run. | None | None. |
| 65 | Production build preview boots if using `npm run preview`. | [x] | [ ] | Browser Use loaded the rebuilt production preview at `http://127.0.0.1:4177/` after the latest build and found 0 console errors. | None | None. |

## Bugs Found

| ID | Severity | Area | Reproduction | Expected | Actual | Follow-up |
|---|---|---|---|---|---|---|
| RES-001 | Medium | Defeat Results | Lose after earning enough live battle XP to level up during the attempt. | Defeat should show saved hero progress and explain that battle XP was not saved. | Results showed unsaved live levels as the after-battle hero, including confusing level-up/skill-point text. | Fixed in the 2026-04-29 Results clarity pass and verified by full e2e. |

## Follow-Up Actions

| Priority | Action | Owner | Notes |
|---|---|---|---|
| P1 | Complete human-audible audio checks. | Human/manual QA | Browser automation cannot confirm hearing output. |
| P1 | Complete human-paced first battle playthrough through first wave. | Human/manual QA | Automated suite verifies deterministic path; feel and enemy pressure still need human play. |
| P2 | Complete human-paced Ashen assault visual QA with fog on. | Human/manual QA | Objective-panel overlap, landmark scoutability, fog/minimap visibility, and rendered player/enemy colorblind minimap colors now have browser coverage; full-fight stress and subjective tower/readability feel still need human judgment. |
