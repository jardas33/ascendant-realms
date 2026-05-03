# Release Checklist

Use this checklist for the v0.2.1 prototype baseline candidate and future prototype checkpoints. Run commands from the project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

## Required Automated Checks

1. Unit and pure-rule tests:

```bash
npm test
```

Expected current prototype result:

```text
PASS: 36 test files, 210 tests
```

2. Production build:

```bash
npm run build
```

Expected current prototype result:

```text
PASS: TypeScript compile and Vite production build
```

Known warning:

```text
Some chunks are larger than 500 kB after minification.
```

This Vite warning is expected for the current Phaser bundle and is not a release blocker unless bundle optimization is the explicit release goal.

3. Browser e2e suite:

```bash
npm run test:e2e -- --reporter=line
```

Expected current prototype result:

```text
PASS: 49 Playwright tests
```

Use a long timeout. The full suite intentionally runs with one worker for stability and currently takes about 23 minutes on this machine.

4. Deterministic playtest simulator:

```bash
npm run playtest:sim
```

Expected current prototype result:

```text
PASS: 180 simulated runs across 60 campaign battle node/profile summaries
No too-easy nodes
No structural too-hard nodes
Ashen Outpost beatable
No Stronghold warnings
```

This command regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.

## Optional Preview Check

After `npm run build`, run:

```bash
npm run preview
```

Open the local preview URL and confirm:

- Main menu renders `Prototype v0.2` and `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`.
- Browser console has no new hard errors.
- Continue/New Campaign, Skirmish, Hero Inventory, Settings, and Asset Gallery are reachable from an appropriate save state.

Browser Use preview sanity is optional after the automated suite. The latest expected visible sanity check is the production preview at `http://127.0.0.1:4182/` with the v0.2 main menu visible and browser console errors at 0. The release baseline candidate is `v0.2.1`, while the visible product copy remains `Prototype v0.2`.

## Manual QA Areas Not Fully Automated

- Full human-paced Border Village and Old Stone Road playthroughs on Easy, including first warning, Barracks timing, first trained unit, and first enemy contact.
- Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save, including Veyra of the Cinders and Gorak Emberhand scout/readability checks.
- Ashen Outpost with and without Chapel repair, including Captain Malrec readability, Hold the Line ability readability, final approach readability, tower pressure, and objective-panel placement.
- Stronghold Tier I and II purchase feel in a real campaign economy, especially Watch Post II and Quartermaster Stores II.
- Reputation hooks in normal campaign flow: Common Folk Marcher Camp discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, and Ashen Covenant Hostile pressure.
- Affixed reward readability in Results and Inventory, including base/affix/total stat copy.
- Retinue and rival readability in normal human-paced play, including whether first-defeat rewards and trophies feel satisfying without becoming mandatory.
- HUD hover/scroll feel and captured-site fog readability under real mouse movement, even though the regression paths now have Playwright coverage.
- Audio behavior with human ears.
- Visual polish across generated/manual UI-kit assets.
- Production preview sanity after release packaging.

## Release Notes To Check

- `CHANGELOG.md` describes the current feature baseline.
- `README.md` has current setup, feature summary, known limitations, and verification counts.
- `ROADMAP.md` marks Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, CampaignRules split, and HUD/fog polish as completed, with the next phase set to `v0.3 planning: Chapter 2 vertical slice`.
- `LLM_GAME_HANDOFF.md` marks the current state as the v0.2.1 baseline candidate on top of Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, the CampaignRules split, and HUD/fog polish.
