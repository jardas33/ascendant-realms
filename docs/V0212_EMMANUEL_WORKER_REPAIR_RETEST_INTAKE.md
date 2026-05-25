# v0.21.2 Emmanuel Worker Repair Retest Intake

Date: 2026-05-24
Package tested: `ascendant-realms-private-playtest-f6a121b`
Route: Worker repair / construction / intent / combat clarity retest
Result: MOSTLY PASS, with clarity follow-up

## Manual Retest Pass

- Friendly completed-building repair works.
- Move-away pauses repair.
- Move-back or reissuing Repair resumed repair in the tested package.
- Enemy building repair is blocked.
- Full-health repair is disabled or clearly unnecessary.
- Incomplete repair/construction interaction seemed mostly fine.

## New Feedback

1. Worker did not attack an enemy building when close to it.
2. When hit by a ranged enemy unit, Worker showed a red dot at the beginning of its health bar.
3. Worker auto-resumes or starts repairing or finishing construction just by being near the building. This feels wrong.
4. Expected RTS behavior: player must explicitly select Worker and click or command the damaged or incomplete building to repair or continue construction. Being near the building should be required, but proximity alone should not start or resume work.
5. Future UI should use clearer cursor icons:
   - crossed swords for attack
   - hammer for repair/build/construction

## v0.21.2 Bugfix Scope

This is a narrow polish/clarity pass before v0.22. Resolve explicit Worker intent rules, Worker attack behavior, and the healthbar visual issue, then preserve the accepted repair/build boundaries.

Hard exclusions:

- No harvesting.
- No repair expansion beyond polish.
- No enemy repair AI.
- No enemy construction AI.
- No new units, buildings, maps, or factions.
- No runtime art/assets unless using existing built-in cursor/CSS only.
- No save migration.
- No broad AI/pathing rewrite.
- No global rebalance.
- No Patrol or formations.
- No test weakening.

## Acceptance Targets

- Worker explicit attack on a valid enemy building works through the existing weak Worker combat stats, or the UI clearly blocks the order by design.
- Worker does not become aggressive or auto-suicidal by default.
- Repair/build commands remain distinct from attack commands.
- Worker near an incomplete friendly construction site does not progress construction without an explicit Build or Resume Construction command.
- Worker near a damaged friendly completed building does not repair without an explicit Repair command.
- Move-away stops active construction or repair intent; moving back alone does not resume.
- Reissuing Build/Resume Construction or Repair resumes progress while the Worker is alive and in range.
- Enemy building repair remains blocked.
- Full-health and incomplete buildings remain invalid repair targets.
- Worker health after ranged/status damage shows normal HP reduction without a stray dot inside the health bar.
- Cursor-icon improvement stays documented for a later UI pass unless it can be done safely without new art.
