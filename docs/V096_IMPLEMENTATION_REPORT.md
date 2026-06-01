# v0.96 Implementation Report

Status: runtime implementation and local verification complete; final clean package is generated after the final commit.

## Scope

`v0.96 First-Time Player Onboarding and Tutorial UX Rescue` improves first-session presentation, Tutorial guidance, campaign next-step copy, and compact help access. It does not add gameplay systems, change rewards, alter saves, rename stable IDs, add content, add art, or change balance.

## Runtime Changes

- Reordered the playable Proving Grounds sequence so the first visible action is selecting Aster, followed by troop selection, movement, site capture, Command Hall selection, Barracks construction, Worker site assignment, Militia training, rally placement, Rally Banner, safe pressure, and completion.
- Extended Tutorial step metadata with short `reason`, collapsed `moreHelp`, and player-initiated `focusTarget` fields.
- Added `selectTroops` and `assignWorker` Tutorial completion checks so the first-session route teaches existing army selection and Worker site assignment explicitly.
- Added non-blocking Tutorial panel controls for `More Help`, `Focus Objective`, `Dismiss`, and `Reopen`.
- Added a shared collapsed onboarding help surface for battle HUD, pause menu, and campaign shell.
- Added a compact fresh-campaign Salto next-action card without changing campaign progression, rewards, saves, or node ids.
- Added focused unit, smoke, layout, hosted layout, and visual-QA coverage for first-session onboarding and help states.

## Save Format

- No save-version bump.
- No new save fields.
- No new localStorage keys or persistent onboarding preferences.
- No stable IDs, mission IDs, node IDs, map IDs, Lume IDs, reward IDs, save fields, or serialized values changed.
- Tutorial remains no-save/no-reward.

## Verification

```text
npm test - PASS, 95 files / 689 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 29 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 12 tests / 110 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 110 screenshots / 7 contact sheets.
```

Non-pass evidence resolved during implementation:

- Initial fast-smoke coverage exposed that Tutorial mode still preselected Aster, auto-completing the new first step; Tutorial launch now starts with no preselected unit.
- Initial fast-smoke/layout coverage exposed that the campaign onboarding card and help surface could push the primary Start Battle action below the fold; the campaign card now sits below the primary action and the help surface opens upward from the action row.
- Tutorial `More Help` initially conflicted with the draggable Tutorial panel handler; the drag selector now treats `summary` and `details` as interactive controls.
- An early 20-minute visual-QA run timed out before completion; the final long-timeout run passed with the full 110-screenshot set.
- Hosted layout-core caught a stale build first, then a one-pixel campaign action overflow and hidden help-grid mobile overflow; rebuilding and tightening CSS resolved both, and hosted layout-core passed.

## Package

The final clean package is generated after the final commit so the package hash and dirty flag match the committed tree. The exact path is reported in the closeout response.

## Push

Final commit and push status are reported in the closeout response.
