# v0.12.1 Human-Paced Playtest Protocol

Date: 2026-05-17

Scope: v0.12.1 Human-Paced Core Feel Playtest Review. This protocol is for slow player-style review of the existing Ascendant Realms slice after the v0.12 Core Game Feel and Battle Readability Pass. It is not a feature expansion, CI-plumbing pass, art overhaul, save migration, map/content expansion, or broad AI/economy pass.

## Phase 0 Baseline Notes

- Current local branch: `main`.
- Current local commit: `d139c3e` (`Checkpoint v0.12 core game feel pass`).
- Local checkout after `git fetch origin main`: clean and synced with `origin/main`.
- User-provided remote baseline: GitHub Actions `CI Release Matrix Dry Run #42` is green on commit `d139c3e`.
- Local limitation: `gh` is unavailable in this environment, the GitHub connector exposes only PR-triggered commit workflow runs for this check, and unauthenticated Actions API access returns `404 Not Found` for this repository. Treat the user-provided #42 result as the remote truth and keep local verification strict.
- v0.12 status: local verification green; selection clarity, command feedback, objective clarity, enemy pressure readability, combat/status messaging, and results/defeat guidance were improved without numeric tuning or new assets.

Green-state constraints to preserve:

- Keep hosted release groups on `playwright.hosted-release.config.ts` and `npm run preview:hosted`.
- Keep local full release lanes separate from hosted release groups.
- Do not replace `clickReady` with force clicks.
- Do not use DOM fallback for canvas/world clicks.
- Do not weaken `Moving`, minimap, no-save/no-reward tutorial, battle command, side-panel reachability, settings runtime-application, or hosted-release assertions.
- Do not turn tutorial smoke semantic advancement back into raw `tutorial-next` click chains.
- Do not add maps, factions, units, generated art, runtime art replacements, multiplayer, procedural generation, monetization, save-format changes, broad AI/economy rewrites, or CI plumbing.

## Review Method

Use a slow, human-paced pass rather than a speedrun or release-lane script:

- Pause after scene transitions and read the screen before clicking.
- Give one command at a time when judging command feedback.
- Watch whether status messages remain visible long enough to understand.
- Use ordinary mistakes when useful: selecting the wrong thing, trying a locked command, moving before reading an objective, or returning to campaign without rushing.
- Capture screenshots or visual QA references where layout or hierarchy matters.
- Record observations before fixing them, unless a tiny typo or obviously broken label is discovered.

Severity labels:

- `must fix now`: small, player-facing, clearly harmful, and safe to change.
- `small polish now`: small, clear improvement with little risk.
- `defer`: not harmful enough for this pass or needs more evidence.
- `future art overhaul`: needs new art, runtime assets, icons, VFX, or major visual language.
- `future mechanics expansion`: needs new systems, tuning, AI behavior, maps, units, or save changes.

## Scenario A - First Launch And Main Menu

Starting state: clean app boot at the main menu, with either no campaign save or an existing local save.

Player goal: understand what the prototype offers and choose a first action.

What a normal player would probably try:

- Read the title/version/state copy.
- Open Tutorial / Proving Grounds first if unsure.
- Open New Campaign if ready.
- Check Settings or Hero Inventory briefly.

Expected feedback:

- Main menu controls are visible and stable.
- Tutorial communicates no-save/no-reward before the player commits too much time.
- Continue/New Campaign state is understandable.

Observe:

- Whether the menu reads as a playable prototype rather than a test harness.
- Whether first-click choices have enough context.
- Whether version/baseline copy is stale or confusing.

Friction:

- Ambiguous first action.
- No-save tutorial rule hidden too late.
- Buttons that appear enabled but do not explain why they cannot proceed.

Do not change in this pass:

- Main menu structure, branding, visual art, save-system behavior, or new onboarding flows.

## Scenario B - Tutorial / Proving Grounds

Starting state: launch Tutorial / Proving Grounds from the main menu.

Player goal: learn selection, movement, capture, build, train, rally, ability, combat, and completion rules.

What a normal player would probably try:

- Click the hero, follow step text, right-click a destination, capture the site, build/train when prompted, then fight.
- Occasionally click ahead or reselect units to check whether instructions still make sense.

Expected feedback:

- Step instructions are concrete and do not require test-like timing.
- Selection panel confirms who is selected.
- Move/build/train/rally/ability commands acknowledge success.
- Tutorial still clearly says no save and no rewards.

Observe:

- First 30 seconds: does selection/movement feel readable?
- Whether command acknowledgement competes with income/combat messages.
- Whether steps feel too wordy or too terse.
- Whether failure/locked states explain what to do next.

Friction:

- Losing the selected unit/order state.
- Missing command acceptance.
- Tutorial copy that says what to do but not where to look.
- No-save/no-reward notice feeling like a surprise.

Do not change in this pass:

- Tutorial persistence, rewards, save behavior, step ids/signals, map, units, or smoke semantic advancement.

## Scenario C - New Campaign Start

Starting state: main menu with no active playable campaign save or after choosing New Campaign.

Player goal: create/start a campaign and understand the first available node.

What a normal player would probably try:

- Pick a hero/class.
- Open the campaign map.
- Click the first available node and inspect locked neighbors.

Expected feedback:

- The first playable node stands out.
- Locked nodes explain why they are locked.
- Campaign state leads naturally into Border Village / First Claim.

Observe:

- Whether the campaign flow tells the player what is next.
- Whether locked-node feedback is readable without feeling like a bug.
- Whether the return path to battle setup is obvious.

Friction:

- Unsure which node to play.
- Locked node feels clickable but inert.
- Campaign map copy feels like lore instead of direction.

Do not change in this pass:

- Campaign unlock rules, saves, rewards, node graph, or hero progression.

## Scenario D - Border Village

Starting state: first campaign battle from Border Village / First Claim.

Player goal: establish economy, build/training loop, survive pressure, and win.

What a normal player would probably try:

- Select the hero and army.
- Move to the nearby capture site.
- Build Barracks once affordable.
- Train units, rally them, and attack after enough troops exist.

Expected feedback:

- Selection and current orders are obvious.
- Move, build, train, and rally orders are acknowledged.
- Objective tracker makes the next useful action visible.
- Defeat pressure feels understandable if the player is slow.

Observe:

- Whether `Next` objective state helps.
- Whether command feedback remains visible long enough.
- Whether side-panel order/status content is useful during real mouse movement.
- Whether early defeat teaches something.

Friction:

- Resource ticks burying command feedback.
- Build/train disabled reasons not clear.
- Army state hard to read once multiple units exist.

Do not change in this pass:

- First battle economy, wave counts, unit rosters, map layout, rewards, or save format unless evidence proves a tiny tuning need.

## Scenario E - Ashen Outpost

Starting state: Ashen Outpost available from campaign/skirmish path.

Player goal: understand Burned Shrine payoff, enemy fort pressure, Captain Malrec threat, and final push timing.

What a normal player would probably try:

- Capture nearby income.
- Read the shrine objective.
- Probe the fortress, notice tower/commander danger, regroup, and push.

Expected feedback:

- Objective copy says what action matters and why.
- Pressure/threat messaging is readable during combat.
- Defeat/victory results explain whether the player underbuilt, overextended, or succeeded.

Observe:

- Whether Burned Shrine and tower payoff are understandable.
- Whether combat readability holds during the dense fortress push.
- Whether results make the next campaign step feel earned.

Friction:

- Failing without knowing whether towers, commander, economy, or army size caused it.
- Objective payoff missed because it is too dense.
- Commander warning disappearing under combat/status noise.

Do not change in this pass:

- Fortress art, tower art, commander systems, map layout, enemy AI, or reward structure.

## Scenario F - Cinderfen Crossing

Starting state: Cinderfen Crossing reachable after campaign setup or seeded review path.

Player goal: understand the Cinder Shrine tempo prize, pressure response, and when to hold/regroup/push.

What a normal player would probably try:

- Read the first unfinished objective.
- Capture side income or the shrine.
- React to pressure warning.
- Push after surviving/regrouping.

Expected feedback:

- Shrine payoff is plain-language enough to understand.
- Pressure warning tells what is happening and what practical response helps.
- Campaign return flow makes completion and next route clear.

Observe:

- Whether `Cinder Shrine Surge` is flavor plus usable instruction, not flavor alone.
- Whether warning-only pressure is perceived as fair and legible.
- Whether objective text remains readable in the tracker.

Friction:

- Player does not know whether pressure means hidden construction, faster wave, or a warning-only event.
- Shrine payoff is missed.
- Enemy pressure feels cheap because counterplay is unclear.

Do not change in this pass:

- Pressure mechanics, reinforcement systems, enemy workers/economy, Cinderfen art, or route rewards.

## Scenario G - Cinderfen Watch

Starting state: Cinderfen Watch reachable after Crossing/Waystation path or seeded review path.

Player goal: capture Watch Road, scout into fog, handle pressure, and push the raider camp/watchtower.

What a normal player would probably try:

- Capture visible income.
- Follow objective text into fog.
- Regroup when a tower or pressure warning appears.

Expected feedback:

- Watch Road objective reads as a practical next step.
- Fog threats feel discoverable rather than arbitrary.
- Pressure warning names route/counterplay.

Observe:

- Whether fog makes objective language more important.
- Whether minimap and objective copy work together.
- Whether tower danger feels like a readable risk.

Friction:

- Watchtower appears abruptly with no clear lesson.
- Objective text truncates the actionable part.
- Pressure messages are noticed but not useful.

Do not change in this pass:

- Fog system, map layout, tower art, new scouts/detection mechanics, or enemy planning.

## Scenario H - Defeat Case

Starting state: any safe battle where a defeat can be reached without corrupting a real save, preferably tutorial/no-save or disposable seeded campaign review.

Player goal: understand why defeat happened and what to try next.

What a normal player would probably try:

- Underbuild or overextend.
- Let an enemy wave reach base.
- Read defeat screen before retrying or returning.

Expected feedback:

- Defeat result is direct but helpful.
- Tips mention actionable causes: economy, production, regrouping, wave survival, army size.
- No reward/save language is honest.

Observe:

- Whether tips match the actual failure.
- Whether defeat feels earned or cheap.
- Whether return/retry choices are clear.

Friction:

- Generic tips after a specific failure.
- Rewards/save language unclear.
- Retry/campaign return choice hidden.

Do not change in this pass:

- Defeat save rules, rewards, campaign progression, or major balance.

## Scenario I - Victory And Campaign Return Flow

Starting state: win Border Village, Ashen Outpost, Cinderfen Crossing, or Cinderfen Watch.

Player goal: understand what was earned, what was completed, and what to do next.

What a normal player would probably try:

- Read results summary.
- Inspect rewards and veterans.
- Return to campaign map.
- Choose next node or service.

Expected feedback:

- Victory result explains outcome and rewards concisely.
- Completed objectives feel meaningful.
- Campaign return indicates the next useful choice.

Observe:

- Whether results are satisfying or just ledger-like.
- Whether route unlocks and repeat reward limits are clear.
- Whether campaign return flow feels smooth.

Friction:

- Too much reward/stat text before the next action.
- Next campaign choice unclear.
- Victory does not explain why the player succeeded.

Do not change in this pass:

- Rewards, unlock graph, retinue behavior, item generation, or save persistence.

## Scenario J - Skirmish Setup And Broken Ford

Starting state: main menu to Skirmish Setup, optionally Broken Ford.

Player goal: pick a map/difficulty/personality and understand command/readability feel outside campaign.

What a normal player would probably try:

- Change difficulty and AI personality.
- Launch Broken Ford.
- Select/move/build/train as in campaign.

Expected feedback:

- Setup labels feel clear enough to choose without reading source docs.
- Battle-start summary does not vanish before the player understands map risk.
- Command feedback works the same as campaign.

Observe:

- Whether setup copy is dense or ambiguous.
- Whether Broken Ford pathing feels intentional.
- Whether command acknowledgement is consistent.

Friction:

- Difficulty/personality choices feel like internal test labels.
- Tight lanes feel like pathing bugs.
- Battle-start status disappears too quickly.

Do not change in this pass:

- New skirmish options, AI behavior, difficulty balance, maps, or map art.
