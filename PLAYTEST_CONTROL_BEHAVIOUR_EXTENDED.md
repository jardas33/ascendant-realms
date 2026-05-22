# Playtest Control Behaviour Lab

Generated: 2026-05-22T10:16:26.281Z
Build commit: 169bb21
Run mode: extended
Iterations: 5
Scenarios: 12

## What This Is

This is deterministic automated evidence for v0.15/v0.16 RTS controls. It checks behaviour-mode semantics, explicit order precedence, retreat suppression, melee contact reacquisition, and the contracts covered by browser-level attack cursor and HUD/minimap tests.

## What This Is Not

- Deterministic automated evidence only.
- Not human fun evidence.
- Not balance proof.
- Does not replace Emmanuel's manual retest.
- Does not invent human observations.

## Scenario Results

| Scenario | Mode | Order | Verdict | Confidence | Key Evidence |
| --- | --- | --- | --- | --- | --- |
| Hold Ground Contact Defence | hold_ground | none | pass | high | contact attack frame observed; no chase target required; Hold Ground contact target took damage without chase movement. |
| Hold Ground Distant Threat Refusal | hold_ground | none | pass | high | no target retained; no chase target assigned; Hold Ground did not assign a chase target for an idle distant enemy. |
| Guard Area Default Local Defence | guard_area | none | pass | high | target acquired; local chase target assigned; Guard Area assigned a local chase target. |
| Press Attack Bounded Pursuit | press_attack | none | pass | high | press-leash target acquired; far target refused; Press Attack pursued a target beyond Guard Area reach.; Press Attack refused the farther map-wide target. |
| Explicit Attack Overrides Mode | hold_ground | attack | pass | high | explicit target retained; pursuit target assigned; Explicit attack target remained active and assigned pursuit under Hold Ground. |
| Move-Away Suppression | press_attack | move | pass | high | move target retained; same-frame reacquisition suppressed; Suppression blocked contact reacquisition on the expiry frame.; Combat resumed after the grace window. |
| Post-Kill Adjacent Reacquisition | guard_area | none | pass | high | first target killed; second contact target damaged; Adjacent second target took damage after the first explicit target died. |
| Enemy Melee Building Aggro | not_applicable | none | pass | high | building target damaged; local building aggro only; Enemy melee damaged the local Command Hall footprint without a global chase. |
| Attack Hover Tolerance Boundary | guard_area | attack | pass | high | visible body edge resolves; nearby empty terrain does not resolve; Visible enemy body edge resolved as attack intent.; Nearby empty terrain remained non-targetable. |
| Group Mixed Mode Application | mixed | mode_change | pass | high | mixed detected; group mode applied count; Mixed group normalized to Guard Area for 3 units. |
| Attack Cursor/Intent Integrity | guard_area | attack | pass | medium | selected units plus valid enemy should expose attack intent; empty click should not attack; Contract is covered by Playwright: selected units hovering a valid enemy expose attack cursor intent.; Contract is covered by Playwright: left-click valid enemy issues attack, empty click does not. |
| HUD/Minimap/Selection Regression Protection | not_applicable | ui_regression | pass | medium | marquee cleanup; minimap movement; hero selection refresh; Contract is covered by Playwright: marquee cleanup across HUD/minimap remains asserted.; Contract is covered by Playwright: minimap movement and H hero-select refresh remain asserted. |
| Hold Ground Contact Defence | hold_ground | none | pass | high | contact attack frame observed; no chase target required; Hold Ground contact target took damage without chase movement. |
| Hold Ground Distant Threat Refusal | hold_ground | none | pass | high | no target retained; no chase target assigned; Hold Ground did not assign a chase target for an idle distant enemy. |
| Guard Area Default Local Defence | guard_area | none | pass | high | target acquired; local chase target assigned; Guard Area assigned a local chase target. |
| Press Attack Bounded Pursuit | press_attack | none | pass | high | press-leash target acquired; far target refused; Press Attack pursued a target beyond Guard Area reach.; Press Attack refused the farther map-wide target. |
| Explicit Attack Overrides Mode | hold_ground | attack | pass | high | explicit target retained; pursuit target assigned; Explicit attack target remained active and assigned pursuit under Hold Ground. |
| Move-Away Suppression | press_attack | move | pass | high | move target retained; same-frame reacquisition suppressed; Suppression blocked contact reacquisition on the expiry frame.; Combat resumed after the grace window. |
| Post-Kill Adjacent Reacquisition | guard_area | none | pass | high | first target killed; second contact target damaged; Adjacent second target took damage after the first explicit target died. |
| Enemy Melee Building Aggro | not_applicable | none | pass | high | building target damaged; local building aggro only; Enemy melee damaged the local Command Hall footprint without a global chase. |
| Attack Hover Tolerance Boundary | guard_area | attack | pass | high | visible body edge resolves; nearby empty terrain does not resolve; Visible enemy body edge resolved as attack intent.; Nearby empty terrain remained non-targetable. |
| Group Mixed Mode Application | mixed | mode_change | pass | high | mixed detected; group mode applied count; Mixed group normalized to Guard Area for 3 units. |
| Attack Cursor/Intent Integrity | guard_area | attack | pass | medium | selected units plus valid enemy should expose attack intent; empty click should not attack; Contract is covered by Playwright: selected units hovering a valid enemy expose attack cursor intent.; Contract is covered by Playwright: left-click valid enemy issues attack, empty click does not. |
| HUD/Minimap/Selection Regression Protection | not_applicable | ui_regression | pass | medium | marquee cleanup; minimap movement; hero selection refresh; Contract is covered by Playwright: marquee cleanup across HUD/minimap remains asserted.; Contract is covered by Playwright: minimap movement and H hero-select refresh remain asserted. |
| Hold Ground Contact Defence | hold_ground | none | pass | high | contact attack frame observed; no chase target required; Hold Ground contact target took damage without chase movement. |
| Hold Ground Distant Threat Refusal | hold_ground | none | pass | high | no target retained; no chase target assigned; Hold Ground did not assign a chase target for an idle distant enemy. |
| Guard Area Default Local Defence | guard_area | none | pass | high | target acquired; local chase target assigned; Guard Area assigned a local chase target. |
| Press Attack Bounded Pursuit | press_attack | none | pass | high | press-leash target acquired; far target refused; Press Attack pursued a target beyond Guard Area reach.; Press Attack refused the farther map-wide target. |
| Explicit Attack Overrides Mode | hold_ground | attack | pass | high | explicit target retained; pursuit target assigned; Explicit attack target remained active and assigned pursuit under Hold Ground. |
| Move-Away Suppression | press_attack | move | pass | high | move target retained; same-frame reacquisition suppressed; Suppression blocked contact reacquisition on the expiry frame.; Combat resumed after the grace window. |
| Post-Kill Adjacent Reacquisition | guard_area | none | pass | high | first target killed; second contact target damaged; Adjacent second target took damage after the first explicit target died. |
| Enemy Melee Building Aggro | not_applicable | none | pass | high | building target damaged; local building aggro only; Enemy melee damaged the local Command Hall footprint without a global chase. |
| Attack Hover Tolerance Boundary | guard_area | attack | pass | high | visible body edge resolves; nearby empty terrain does not resolve; Visible enemy body edge resolved as attack intent.; Nearby empty terrain remained non-targetable. |
| Group Mixed Mode Application | mixed | mode_change | pass | high | mixed detected; group mode applied count; Mixed group normalized to Guard Area for 3 units. |
| Attack Cursor/Intent Integrity | guard_area | attack | pass | medium | selected units plus valid enemy should expose attack intent; empty click should not attack; Contract is covered by Playwright: selected units hovering a valid enemy expose attack cursor intent.; Contract is covered by Playwright: left-click valid enemy issues attack, empty click does not. |
| HUD/Minimap/Selection Regression Protection | not_applicable | ui_regression | pass | medium | marquee cleanup; minimap movement; hero selection refresh; Contract is covered by Playwright: marquee cleanup across HUD/minimap remains asserted.; Contract is covered by Playwright: minimap movement and H hero-select refresh remain asserted. |
| Hold Ground Contact Defence | hold_ground | none | pass | high | contact attack frame observed; no chase target required; Hold Ground contact target took damage without chase movement. |
| Hold Ground Distant Threat Refusal | hold_ground | none | pass | high | no target retained; no chase target assigned; Hold Ground did not assign a chase target for an idle distant enemy. |
| Guard Area Default Local Defence | guard_area | none | pass | high | target acquired; local chase target assigned; Guard Area assigned a local chase target. |
| Press Attack Bounded Pursuit | press_attack | none | pass | high | press-leash target acquired; far target refused; Press Attack pursued a target beyond Guard Area reach.; Press Attack refused the farther map-wide target. |
| Explicit Attack Overrides Mode | hold_ground | attack | pass | high | explicit target retained; pursuit target assigned; Explicit attack target remained active and assigned pursuit under Hold Ground. |
| Move-Away Suppression | press_attack | move | pass | high | move target retained; same-frame reacquisition suppressed; Suppression blocked contact reacquisition on the expiry frame.; Combat resumed after the grace window. |
| Post-Kill Adjacent Reacquisition | guard_area | none | pass | high | first target killed; second contact target damaged; Adjacent second target took damage after the first explicit target died. |
| Enemy Melee Building Aggro | not_applicable | none | pass | high | building target damaged; local building aggro only; Enemy melee damaged the local Command Hall footprint without a global chase. |
| Attack Hover Tolerance Boundary | guard_area | attack | pass | high | visible body edge resolves; nearby empty terrain does not resolve; Visible enemy body edge resolved as attack intent.; Nearby empty terrain remained non-targetable. |
| Group Mixed Mode Application | mixed | mode_change | pass | high | mixed detected; group mode applied count; Mixed group normalized to Guard Area for 3 units. |
| Attack Cursor/Intent Integrity | guard_area | attack | pass | medium | selected units plus valid enemy should expose attack intent; empty click should not attack; Contract is covered by Playwright: selected units hovering a valid enemy expose attack cursor intent.; Contract is covered by Playwright: left-click valid enemy issues attack, empty click does not. |
| HUD/Minimap/Selection Regression Protection | not_applicable | ui_regression | pass | medium | marquee cleanup; minimap movement; hero selection refresh; Contract is covered by Playwright: marquee cleanup across HUD/minimap remains asserted.; Contract is covered by Playwright: minimap movement and H hero-select refresh remain asserted. |
| Hold Ground Contact Defence | hold_ground | none | pass | high | contact attack frame observed; no chase target required; Hold Ground contact target took damage without chase movement. |
| Hold Ground Distant Threat Refusal | hold_ground | none | pass | high | no target retained; no chase target assigned; Hold Ground did not assign a chase target for an idle distant enemy. |
| Guard Area Default Local Defence | guard_area | none | pass | high | target acquired; local chase target assigned; Guard Area assigned a local chase target. |
| Press Attack Bounded Pursuit | press_attack | none | pass | high | press-leash target acquired; far target refused; Press Attack pursued a target beyond Guard Area reach.; Press Attack refused the farther map-wide target. |
| Explicit Attack Overrides Mode | hold_ground | attack | pass | high | explicit target retained; pursuit target assigned; Explicit attack target remained active and assigned pursuit under Hold Ground. |
| Move-Away Suppression | press_attack | move | pass | high | move target retained; same-frame reacquisition suppressed; Suppression blocked contact reacquisition on the expiry frame.; Combat resumed after the grace window. |
| Post-Kill Adjacent Reacquisition | guard_area | none | pass | high | first target killed; second contact target damaged; Adjacent second target took damage after the first explicit target died. |
| Enemy Melee Building Aggro | not_applicable | none | pass | high | building target damaged; local building aggro only; Enemy melee damaged the local Command Hall footprint without a global chase. |
| Attack Hover Tolerance Boundary | guard_area | attack | pass | high | visible body edge resolves; nearby empty terrain does not resolve; Visible enemy body edge resolved as attack intent.; Nearby empty terrain remained non-targetable. |
| Group Mixed Mode Application | mixed | mode_change | pass | high | mixed detected; group mode applied count; Mixed group normalized to Guard Area for 3 units. |
| Attack Cursor/Intent Integrity | guard_area | attack | pass | medium | selected units plus valid enemy should expose attack intent; empty click should not attack; Contract is covered by Playwright: selected units hovering a valid enemy expose attack cursor intent.; Contract is covered by Playwright: left-click valid enemy issues attack, empty click does not. |
| HUD/Minimap/Selection Regression Protection | not_applicable | ui_regression | pass | medium | marquee cleanup; minimap movement; hero selection refresh; Contract is covered by Playwright: marquee cleanup across HUD/minimap remains asserted.; Contract is covered by Playwright: minimap movement and H hero-select refresh remain asserted. |

## Determinism Notes

- Repeated extended runs replay the same deterministic scenarios.
- Iteration counts are repeatability checks, not stochastic samples.
- Browser pointer and HUD regressions are represented here as contracts and verified by Playwright gates.
