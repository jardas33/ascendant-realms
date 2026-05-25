# v0.21.3 Emmanuel Worker Attack Retest Intake

Date: 2026-05-24
Package tested: latest v0.21.x Worker repair/intent package after v0.21.2
Route: Worker explicit attack damage and Burn/status marker clarity
Result: FAIL / MIXED

## Manual Retest Evidence

1. Worker still does not actually damage enemy buildings when explicitly ordered to attack.
   - Worker moves to the enemy building.
   - Worker stands beside or near it.
   - No damage numbers appear.
   - Enemy building HP does not visibly decrease.
   - Do not claim Worker attack works unless actual HP reduction is proven.

2. Worker and other units show a red/orange dot at the beginning of the health bar when hit by a ranged enemy and Burn is active.
   - This may be an intended status/Burn marker.
   - If intended, it must read clearly as a status marker instead of a broken health-bar artifact.
   - If unintended, it should be fixed.
   - Burn/status feedback should be preserved.

3. Future UI/VFX note:
   - Attack cursor should eventually be crossed swords.
   - Repair/build/finish construction cursor should eventually be a hammer.
   - Do not add new runtime art assets now unless using existing safe CSS/native cursor only.

## v0.21.3 Bugfix Scope

This is a narrow polish/clarity pass before v0.22. It fixes or clarifies Worker explicit attack damage and Burn/status marker readability without starting harvesting.

Hard exclusions:

- No harvesting.
- No enemy repair AI.
- No enemy construction AI.
- No new units, buildings, maps, or factions.
- No runtime art/assets unless using existing CSS/native cursor only.
- No save migration.
- No broad AI/pathing rewrite.
- No global rebalance.
- No Patrol or formations.
- No test weakening.

## Acceptance Targets

- Worker explicit attack accepts enemy buildings as valid targets.
- Worker moves into valid range/contact and applies measurable building HP damage.
- Damage feedback appears for explicit Worker building hits when floating text is enabled.
- Worker remains weak and does not become a real soldier.
- Idle Workers still do not auto-attack nearby enemy buildings by default.
- Repair/build/construction commands remain distinct from attack commands.
- Burn/status marker is clearly separated from the health fill and remains readable as status feedback.
- Normal HP reduction and damage numbers remain intact.
- Crossed-swords attack cursor and hammer repair/build cursor remain future UI work in this pass.
