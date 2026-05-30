# v0.62 Emmanuel Retest Checklist

Use a clean package named `ascendant-realms-private-playtest-<commit>` with no `-dirty` suffix.

## Retinue Recruitment

- Complete an eligible campaign battle with a surviving Seasoned or better Militia, Ranger, or Acolyte.
- On Results, confirm Retinue Camp shows roster capacity, deployment selected count, eligible recruits, and current Retinue.
- Add one eligible survivor and confirm the status says the unit joined the Retinue.
- Confirm Worker, Hero, building, enemy, neutral, Recruit, and dead-unit cases are not eligible.

## Campaign Map Deployment

- Open the Campaign Map Retinue Camp.
- Confirm roster count and selected deployment count are separate.
- Confirm role, rank, XP, kills, battles survived, and deployed count are readable.
- Use `Reserve` and `Deploy` and confirm the selected count updates.
- Fill the deployment cap and confirm extra reserves show `Deployment Full`.

## Battle Continuity

- Start an eligible campaign battle with one selected Retinue unit.
- Confirm battle status says the Retinue deployed.
- Select the unit and confirm rank, XP, kills, role, and Retinue veterancy copy are visible.
- Verify control groups, Patrol, move, attack, and Worker commands still behave normally.

## Results And Losses

- Finish a campaign battle with deployed Retinue survivors and confirm Results shows Retinue deployed / survived.
- If a deployed Retinue unit dies, confirm Results marks it lost and it is removed from the Campaign Map roster afterward.
- Confirm surviving deployed units update their campaign counters.

## Protected Routes

- Tutorial / Proving Grounds should show no Retinue recruitment and no Retinue deployment complexity.
- Skirmish should ignore Retinue deployment.
- Replay should not create duplicate Retinue entries or bypass roster/duplicate limits.

## Regression Smoke

- Hero XP, skill-point reminders, relic choice/equip, control groups, Patrol, formation-aware movement, Worker build/repair/site assignment, and Act 1 route guidance should remain intact.
