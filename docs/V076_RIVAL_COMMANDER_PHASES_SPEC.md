# v0.76 Rival Commander Phases Spec

## Goal

Make Captain Malrec feel like a readable Act 1 commander encounter without adding a giant boss system or changing global enemy behavior.

## Commander Protection

- Captain Malrec is spawned through the existing enemy hero path.
- He is recorded in battle stats and scout copy as before.
- During Ashen Outpost finale phases 1 and 2, he is not allowed to join coordinated attack waves.
- In phase 3, he may join existing late pressure if escorted and AI requirements are already met.
- He can still defend his base if the player reaches him early; this avoids invulnerability or fake rules.

## Commander Release

Phase 3 starts when the fortified line is broken:

- `destroy_enemy_barracks` completed, or
- the enemy Barracks/production building is destroyed.

When phase 3 starts:

- HUD/status copy says Captain Malrec is committing to the final defense.
- Minimap ping marks the commander when possible.
- Battle stats record commander release timing.
- Existing enemy hero abilities remain cooldown-gated.

## Ability Scope

- No new active ability is required.
- Existing Captain Malrec abilities may fire through `EnemyHeroAbilitySystem`.
- Ability spam remains prevented by existing cooldowns.
- No infinite respawn or phase reset.

## Tactical-Plan Relationship

- Resource Push supports phase 1 by helping the foothold.
- Guarded Advance supports phase 2 by helping pressure survival.
- Champion Hunt supports phase 3 by framing commander pressure.
- Plan support is modest copy/stat evidence only; no plan auto-wins the encounter.

## Results Evidence

Results should show:

- phase progression,
- commander release,
- commander defeat status,
- milestone completion state,
- replay/claimed state through the existing campaign and rival reward panels.

## Test Expectations

- Phase 3 does not begin before the foothold/fortified-line signals.
- Commander wave participation is blocked before phase 3.
- Commander defeat records the existing secondary objective and rival outcome once.
- Tutorial and non-Ashen battles have no finale phase state.
