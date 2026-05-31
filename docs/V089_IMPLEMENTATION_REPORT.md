# v0.89 Implementation Report

Checkpoint: v0.89 Controlled Display-Copy Migration Batch A

## Summary

v0.89 applies the first approved low-risk display-copy migration batch. It updates current player-facing labels for Barrosan Freeholds, the Barrosan Marches, Salto Outskirts, Rootbound Concord, and Lume Surge while preserving stable IDs and save compatibility.

## Runtime Changed

- Faction display:
  - `free_marches` now displays as Barrosan Freeholds.
  - `sylvan_concord` now displays as Rootbound Concord.
- Campaign display:
  - Chapter 1 now displays as The Barrosan Marches.
  - `border_village` now displays as Salto Outskirts.
  - opening/onboarding/results copy now points players to Salto Outskirts.
- Results and reward copy:
  - first-battle Results use Salto Outskirts.
  - Free Marches reputation reward copy now displays Barrosan Freeholds reputation.
  - rival first-defeat consequence uses Barrosan Marches regional framing.
- Lume Surge:
  - `mission_aether_surge` display name is Lume Surge.
  - `aether_surge` battlefield event display name and battle message are Lume Surge.
- Asset metadata:
  - display families use Barrosan Freeholds and Rootbound Concord.
  - prototype file paths are unchanged.

## Save Format

No save migration. `CURRENT_SAVE_VERSION` remains 2. Stable IDs and serialized values remain unchanged.

## Explicitly Not Changed

- Runtime/internal title remains Ascendant Realms.
- Public title migration to JARDAS is deferred.
- Mana remains the hero tactical ability resource.
- Aether resource keys, Aether Well Ruins, Aether Lens, Aether Flow, and other ambiguous Aether terms remain unchanged.
- Campaign progression, rewards, balance, maps, factions, art assets, and gameplay systems are unchanged.

## Verification

Post-fix local and hosted closeout evidence:

```text
npm test PASS, 91 files / 676 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 16 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 36 screenshots / 0 console errors / 0 screenshot retries.
```

Resolved non-pass evidence:

```text
npm run test:e2e:release:hosted:deep-battle initially failed 2 of 29 tests after the copy migration.
The behaviour-mode gauntlet passed on exact rerun.
The first-campaign placement failure was fixed by keeping active building-placement instructions visible over battlefield-event status text.
The exact first-campaign hosted test passed after rebuild, then the full hosted deep-battle lane passed 29/29.
```

## Package

Package metadata has been prepared for v0.89; final clean package generation and package verification run after the final v0.89 commit so build info can record a clean commit and `dirty: no`.
