# v0.81 Test Strategy And Rollback Plan

Status: docs-only future test plan. No runtime tests for Lume behavior were added because no runtime Lume behavior exists yet.

## Future Test Strategy

The first runtime Lume Network prototype should use focused tests that prove the small slice and preserve existing systems.

## Content Validation

Add validation for:

- unique Lume network ids;
- campaign node exists;
- node is a battle node;
- map id matches the node;
- eligible site ids exist on the map;
- each link endpoint exists, is eligible, and is not the same site;
- maximum three eligible sites for first prototype;
- maximum two active links for first prototype;
- benefit id is known;
- Tutorial/no-reward exclusion is explicit.

Expected files:

- `src/game/data/validation/validateLumeNetworks.ts`
- `src/game/data/contentValidation.test.ts`

## Pure Rule Tests

Add a pure resolver test suite:

- inactive when zero endpoints are player-owned;
- inactive when one endpoint is player-owned;
- active when both endpoints are player-owned;
- severed when an active endpoint becomes enemy-owned or neutral;
- reactivates when both endpoints are recaptured, if the design allows reactivation;
- max active-link cap is enforced;
- unknown site ids do not crash runtime;
- duplicate links are rejected by validation.

## Resource Site Integration Tests

Extend `src/game/systems/ResourceSystem.test.ts` or a dedicated resolver test:

- player capture can activate a link;
- enemy recapture can sever a link;
- Worker assignment continues unchanged;
- site upgrades continue unchanged;
- first-capture bonuses continue unchanged;
- non-Lume missions continue unchanged.

## Benefit Tests

For `linked_ward`:

- applies only when equipped/active? No: this is not a hero item. Apply only when link active.
- applies only near linked endpoint sites.
- does not stack across two links.
- ends when severed.
- does not apply in Tutorial/no-reward routes.
- does not alter resource income unless a later approved fallback chooses resource support.

## HUD And Results Tests

HUD:

- no Lume row outside selected mission;
- inactive state copy;
- active state copy;
- severed state copy;
- selected linked site summary;
- selected non-linked site stays uncluttered.

Results:

- no Lume block outside selected mission;
- activated/severed summary shown after selected mission;
- replay-safe copy shown;
- Tutorial/no-reward Results do not mention Lume.

## Hosted Browser Proxy

Keep hosted proxy stable and short:

1. Launch `aether_well_ruins`.
2. Verify briefing shows one Lume line.
3. Use existing scene/test helper or stable canvas interactions to capture the first linked site pair.
4. Verify HUD row changes to active.
5. Trigger or simulate enemy recapture only if stable.
6. Complete or snapshot Results summary.

Do not add force-click or DOM fallback for canvas/world clicks.

## Deterministic Simulator

Act 1 telemetry should remain green. The future prototype should not make Safe Beginner fail the Act 1 route. If Lume affects only the chosen mission and is defensive/non-stacking, telemetry risk should be low.

Recommended checks:

- `npm run playtest:act1`
- focused scenario telemetry before/after the chosen mission
- no degradation in Safe Beginner route completion

## Required Verification For Future Runtime Prototype

At minimum:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
npm run playtest:act1
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run package:playtest
npm run verify:playtest-package
git diff --check
```

Add hosted deep-battle and visual QA if UI or battle interactions become screenshot-sensitive.

## Rollback Plan

The first runtime prototype should be reversible by reverting one checkpoint.

Rollback-safe conditions:

- no save migration;
- no persistent Lume fields;
- no stable ID rename;
- one new data definition file;
- one tiny runtime resolver;
- one mission gate;
- one HUD row;
- one Results row;
- focused tests.

Rollback must restore:

- all non-Lume site capture;
- Worker assignment;
- site upgrades;
- enemy site AI;
- replay reward safety;
- Tutorial/no-reward simplicity.

## v0.81 Verification

v0.81 is docs-only. Its own verification is the standard docs/package gate, not Lume runtime tests.
