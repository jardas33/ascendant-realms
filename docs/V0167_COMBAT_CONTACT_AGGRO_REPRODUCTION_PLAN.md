# v0.16.7 Combat Contact And Aggro Reproduction Plan

Date: 2026-05-21

## Purpose

Plan focused reproductions for Emmanuel's v0.16.6 manual retest findings without broadening into v0.17 design, balance tuning, pathing rewrites, worker construction, runtime art, or new content.

## A. Adjacent Melee After First Kill

Setup:

- Use a hero or melee player unit in Hold Ground.
- Place two melee enemies close to the unit.
- Let the first enemy attack and die.
- Keep the second enemy adjacent or in contact range.

Expected:

- If the second enemy is hostile and adjacent/contact-valid, either the enemy attacks or the player unit engages according to behaviour-mode rules.
- Hold Ground must still refuse distant idle threats.

Manual actual:

- Both the second enemy and the player unit can idle after the first enemy dies.

Automation:

- Add a focused combat/unit test where the first adjacent enemy dies and the player unit reacquires or attacks the second contact-valid hostile.
- Keep a paired assertion that Hold Ground does not chase a distant idle enemy.

## B. Enemy Building Aggro

Setup:

- Place melee enemy units near a friendly Command Hall or other valid player building.
- No better player unit target should be active.

Expected:

- Enemy melee units near a valid hostile building should target/attack it instead of idling indefinitely.
- Enemies should not globally chase buildings from far away.
- Building HP, enemy damage, ranges, wave timings, and map data must remain unchanged.

Manual actual:

- Many melee enemies stand inside friendly territory doing nothing while ranged units attack.

Automation:

- Add a focused combat/unit test proving a melee enemy near a Command Hall/building can acquire that building.
- Add a distance guard proving a far enemy does not globally chase the building unless existing design already does so.

## C. Retreat Near Multiple Enemies

Setup:

- Put one hero/unit or a small group near multiple enemies.
- Issue a normal move-away or retreat command.

Expected:

- Explicit move-away clears explicit attack target state.
- Opportunistic combat reacquisition must not cancel the retreat in the same frame or immediately after.
- Suppression should eventually expire; retreat is not invulnerability if the unit remains stuck or is attacked.

Manual actual:

- Usually retreat works, but near multiple enemies some units stop obeying and keep fighting until death.
- In one group retreat, most units moved but one unit stopped.

Automation:

- Add focused tests around normal move commands near multiple enemies.
- Verify target reacquisition is suppressed during the move-away window and still eventually resumes after the intended window.

## D. Attack Cursor Hit Tolerance

Setup:

- Select a controllable player unit.
- Hover over enemy sprite/body/label/healthbar-adjacent visible area.
- Also hover empty nearby terrain and HUD/minimap.

Expected:

- Attack intent should appear over a forgiving enemy interaction area consistent with visible enemy size.
- Empty nearby terrain should not become attack intent.
- HUD/minimap hover should not create attack intent.

Manual actual:

- The attack cursor only appears over a tiny precise spot.

Automation:

- Add focused input tests if the hit-test function is isolated enough.
- Otherwise extend a targeted hosted-safe control gauntlet path without overloading existing release tests.

## Reproduction Stop Rules

- If code and tests confirm a narrow root cause, fix that root cause directly.
- If a symptom cannot be made deterministic, document the audit finding and add guard coverage only where a real contract is clear.
- Do not add features, content, new art, balance changes, or broad AI/pathing rewrites.
