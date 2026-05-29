# v0.43 Scenario Modifiers Implementation Report

Date: 2026-05-28

## Scope

v0.43 adds small mission-local scenario modifiers through the existing campaign battle launch modifier path. The modifiers are visible in briefing and Results and apply only to the launched battle.

## Scenario Modifiers

Initial mission modifiers:

- Rich Veins: resource sites produce 10% more during the mission.
- Enemy Patrols: enemy attack intervals are 5% faster.
- Fortified Enemy: enemy initial attack delay is slightly longer, but defensive reserve size is +1.
- Aether Surge: hero maximum Mana is +8% for the mission.

Values are conservative and content-validated. Tutorial launches receive no campaign scenario modifiers.

## Runtime Hooks

- `applyCampaignCaptureSiteModifierEffects` adjusts capture-site income for mission launches.
- `applyCampaignEnemyAIModifierEffects` adjusts enemy attack pacing and defensive squad size through existing AI config fields.
- Existing hero launch modifier logic applies Aether Surge through the existing hero Mana multiplier path.
- Existing battle start summary can display mission modifier names because they are normal launch modifiers.

## Save Format

No save-version bump. Scenario modifier ids live on campaign node definitions and are passed through battle launch requests. They are not persisted as new campaign state and do not alter v0.41 reward/objective claim fields.

## Verification

Focused verification completed:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm run validate:content PASS.
npx vitest run src/game/data/campaignModifiers.test.ts src/game/core/CampaignRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts PASS, 4 files / 71 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS after a fresh build, 2 hosted tests.
```

## Deferrals

- Low Supplies resource penalties.
- Randomized modifiers.
- Player-selected mutators.
- Large modifier catalog.
- Modifier-specific art.
