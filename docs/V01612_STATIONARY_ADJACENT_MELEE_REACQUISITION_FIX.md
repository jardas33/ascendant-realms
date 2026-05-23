# v0.16.12 Stationary Adjacent Melee Reacquisition Fix

Date: 2026-05-23

## Scope

Fix Emmanuel's `ec0608a` Tutorial retest failure where a Hold Ground hero and adjacent Stone Imps could stand in contact without combat starting, especially after the first adjacent target died. This is a v0.16.x bugfix only, not v0.17.

Out of scope: worker construction, new units, new buildings, new maps, new factions, Patrol, broad AI/pathing rewrites, balance/stat/wave changes, save changes, runtime art/assets, force clicks, or DOM fallback for canvas/world clicks.

## Evidence

Manual intake: `docs/V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md`.

Key failed pattern:

- Hero in Hold Ground stood beside two Stone Imps.
- Sometimes nobody attacked until the hero moved.
- After the first imp died, the second imp and hero could remain adjacent and idle until the hero moved again.

## Audit Summary

Reviewed:

- `src/game/systems/CombatSystem.ts`
- `src/game/systems/BehaviourModeSystem.ts`
- `src/game/entities/Unit.ts`
- `src/game/systems/MovementSystem.ts`
- `src/game/systems/CollisionSystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/scenes/BattleScene.ts`
- deterministic control-lab and hosted regression coverage

Root cause:

- The v0.16.7 contact tests covered clean center-distance contact, but Emmanuel's case is a messier visible-contact edge where sprites can read as adjacent while centers are a little farther apart.
- Explicit attack targets stayed higher priority than immediate melee body contact. Enemy melee already ordered toward the Command Hall could stand beside a player unit and keep trying to resolve the distant explicit target instead of accepting the local contact fight.
- When a player explicit attack target died, `attackMove` stayed true. For Hold Ground, that could accidentally behave like an attack-move follow-up instead of returning to Hold Ground's local-contact/direct-attacker rules.

## Runtime Changes

- Increased melee visual-contact tolerance narrowly for melee units.
- Added immediate melee-contact target priority when a melee unit has a hostile in contact and its explicit target is not already in effective range.
- Cleared explicit attack/attack-move state when the explicit target is dead or invalid, so Hold Ground resumes Hold Ground rules after the target dies.
- Added a narrow top/head hit-test extension for enemy units and buildings in world entity targeting.
- Kept nearby side terrain non-targetable.

## Behaviour Boundaries

- Hold Ground still refuses idle distant enemies.
- Hold Ground can fight immediate visible-contact hostiles without movement.
- Guard Area keeps its local default behavior.
- Press Attack keeps its bounded pursuit behavior.
- Enemy melee can still attack a local Command Hall/building footprint.
- No gameplay data, save format, art assets, waves, stats, maps, units, buildings, factions, or worker systems changed.

## Building Aggro Clarity

Deterministic tests now continue to prove local melee enemy building aggro through `CombatSystem` and the control behaviour lab. Emmanuel's note that melee building attacks are visually hard to verify remains readability debt; this pass did not add art or VFX.

## Hover Tolerance

The attack hover/click hit test now includes a narrow upward visible area for units and buildings. Existing side-boundary checks keep nearby empty terrain non-targetable.

## Tutorial Box

Emmanuel's note that the Tutorial objective box can obstruct the view is valid future QoL. This pass defers draggable/movable tutorial objectives because the request is a combat bugfix and the UI change is not necessary for the v0.16.12 fix.

## Verification So Far

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts BehaviourModeSystem.test.ts ControlBehaviourScenarioLab.test.ts
PASS, 5 files / 45 tests.

npm test
PASS, 57 files / 421 tests.

npm run build
PASS with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifests checked.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.8m.

npm run playtest:controls
PASS, 18 scenarios / 18 pass rows.

npm run playtest:controls:extended
PASS, 18 scenarios / 5 iterations / 90 pass rows.

npm run playtest:controls:verify
PASS, 1658 checks.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line
PASS, 1 test in 24.4s.

Browser preview sanity at http://127.0.0.1:5173/
PASS, main menu loaded, Tutorial reached BattleScene, browser console errors: 0.

npm run package:playtest
PASS against the pre-commit dirty tree; generated artifacts/playtest/ascendant-realms-private-playtest-ec0608a-dirty.

npm run verify:playtest-package
PASS, 31 checks.
```

Final clean package should be regenerated after the v0.16.12 commit so it uses the final commit hash and does not end in `-dirty`.
