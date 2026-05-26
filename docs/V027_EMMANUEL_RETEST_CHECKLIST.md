# v0.27 Emmanuel Retest Checklist

Date: 2026-05-26

Package target: clean `ascendant-realms-private-playtest-<v0.26-v0.27 commit>`.

## Enemy Base Development

1. Start a skirmish or campaign battle with normal resource sites.
2. Let the enemy hold one or more sites for several minutes.
3. Watch for readable base-stage behavior: early site capture, mid fortifying/defense, and later stronger pressure.
4. Confirm no enemy construction placement, visible enemy Workers, cargo, harvesting route, or drop-off loop appears.

## Enemy Tech Progression

1. Let the enemy hold sites and build a resource stockpile.
2. Confirm enemy tech can advance after a delay rather than instantly at battle start.
3. Confirm upgrades feel research-gated and paced, not a sudden free global buff.
4. If an enemy Watchtower exists, confirm defense upgrades do not happen before base fortification prerequisites.

## Strategic Escalation

1. Early: enemy should still prioritize neutral site capture and light pressure.
2. Mid: enemy should defend valuable owned sites, improve sites, and start tech when affordable.
3. Late: enemy may send stronger coordinated pressure if it has healthy site/economy control.
4. Confirm late pressure is still made from existing units and does not become nonstop spam.

## Defensive Intelligence

1. Move player units near the enemy base and confirm the enemy responds defensively.
2. Threaten an upgraded enemy-owned site and confirm the enemy can defend it.
3. Confirm the enemy does not send every unit away while the base is under threat.
4. Confirm weak or outmatched site raids still regroup rather than suiciding forever.

## Regression Watch

- Enemy resource-site capture, retake, defense, upgrades, raids, and abstract logistics from v0.24-v0.25 still work.
- Player Worker assignment, site upgrades, second Worker slot, and site-loss cleanup from v0.22-v0.23 still work.
- Worker construction, repair, and explicit attack remain distinct commands.
- No new maps, factions, runtime art, save migration, Patrol, formations, broad pathing rewrite, or global rebalance should be present.
