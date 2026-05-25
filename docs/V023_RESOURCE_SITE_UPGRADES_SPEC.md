# v0.23 Resource Site Upgrades Spec

Date: 2026-05-25

## Mission

Expand the v0.22 resource-site Worker assignment foundation with a small upgrade layer. Captured sites should feel more strategically important, but Ascendant Realms still uses site-control income rather than classic carry/drop-off harvesting.

## Design Direction

The economy remains Warlords Battlecry-like:

- Captured resource sites provide passive income.
- Explicitly assigned Workers boost friendly captured sites.
- Site upgrades deepen captured sites with better income and Worker slot capacity.
- Workers do not carry cargo, seek drop-off buildings, or harvest from loose resource nodes.

This keeps the resource game focused on capturing, holding, improving, and staffing map sites instead of introducing a separate villager economy loop.

## Site Levels

v0.23 starts with two runtime levels only:

| Level | Name | Income | Worker slots |
| --- | --- | --- | --- |
| 1 | Captured Site | Existing base passive income | 1 |
| 2 | Improved Site | Existing base income plus a 15% rounded upgrade bonus, minimum +1 | 2 |

Site level is battle-runtime state only. Losing site control resets the site to Level 1 and clears assigned Workers.

## Upgrade Rules

- Upgrade target: alive friendly captured resource site.
- Invalid targets: neutral site, enemy site, destroyed/invalid site, already improved site.
- Cost: 120 Crowns and 80 Stone.
- Completion: instant in v0.23 to avoid adding a new construction/progress system for sites.
- Result: Level 2 site with upgrade income bonus and one additional Worker slot.
- Enemy AI: no enemy Worker/resource-site upgrade AI in v0.23.
- Save data: no save migration. Site upgrades are battle-runtime state only.

## Worker Slot Rules

- Level 1 sites allow 1 assigned Worker.
- Level 2 sites allow 2 assigned Workers.
- The same Worker cannot fill more than one slot.
- A full site rejects additional Worker assignment with clear feedback.
- Moving, attacking, building, repairing, dying, or assigning elsewhere clears the relevant Worker slot.
- Losing site control clears all Worker slots and the level upgrade.
- Proximity alone never assigns a Worker.

## Income Model

Each income tick uses the site's existing resource identity:

```text
total income = base site income + level upgrade bonus + active assigned Worker bonuses
```

- Base site income is unchanged.
- Upgrade bonus is 15% of base income, rounded, minimum +1, only at Level 2.
- Worker bonus remains 20% of base income, rounded, minimum +1, per active assigned Worker in range.

## UI Copy

Resource-site panels should show:

- Level.
- Resource type.
- Base income.
- Upgrade bonus.
- Worker slots used/available.
- Assigned Worker names or Empty.
- Worker bonus.
- Total income.
- Upgrade status or invalid reason.

Worker command buttons should show assignability, slots used/available, total tick income, and neutral/enemy/full reasons.

## Tutorial Impact

No Tutorial step requires site upgrades in v0.23. The Tutorial can continue teaching passive capture-site resources first; Worker assignment and site upgrades remain optional economy depth for later play.

## Deferrals

- No classic harvesting.
- No cargo/drop-off loop.
- No enemy Worker mining AI.
- No enemy site upgrade AI.
- No new maps, factions, units, buildings, or runtime art.
- No save persistence for site upgrades.
