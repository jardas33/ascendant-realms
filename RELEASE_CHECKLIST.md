# Release Checklist

Use this checklist for the v0.2 prototype baseline and future prototype checkpoints. Run commands from the project root:

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
PASS: 35 test files, 194 tests
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
PASS: 43 Playwright tests
```

Use a long timeout. The full suite intentionally runs with one worker for stability and currently takes about 15 to 16 minutes on this machine.

4. Deterministic playtest simulator:

```bash
npm run playtest:sim
```

Expected current prototype result:

```text
PASS: 150 simulated runs across 50 campaign battle node/profile summaries
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

- Main menu renders.
- Browser console has no new hard errors.
- Continue/New Campaign, Skirmish, Hero Inventory, Settings, and Asset Gallery are reachable from an appropriate save state.

## Manual QA Areas Not Fully Automated

- Full human-paced Border Village and Old Stone Road playthroughs on Easy, including first warning, Barracks timing, first trained unit, and first enemy contact.
- Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save.
- Ashen Outpost with and without Chapel repair, including final approach readability, tower pressure, and objective-panel placement.
- Stronghold Tier I and II purchase feel in a real campaign economy, especially Watch Post II and Quartermaster Stores II.
- Reputation hooks in normal campaign flow: Common Folk Marcher Camp discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, and Ashen Covenant Hostile pressure.
- Affixed reward readability in Results and Inventory, including base/affix/total stat copy.
- Audio behavior with human ears.
- Visual polish across generated/manual UI-kit assets.
- Production preview sanity after release packaging.

## Release Notes To Check

- `CHANGELOG.md` describes the current feature baseline.
- `README.md` has current setup, feature summary, known limitations, and verification counts.
- `ROADMAP.md` names the next milestone as human campaign balance/readability review with Retinue Camp V1 included.
- `LLM_GAME_HANDOFF.md` marks the current state as the v0.2 prototype baseline plus Unit Veterancy V1 and Retinue Camp V1.
