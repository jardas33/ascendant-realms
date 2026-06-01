# v0.94 Campaign Density Rescue Spec

## Purpose

Improve map-first campaign usability after v0.93 by reducing dashboard feel, increasing useful map area, and compacting the selected mission panel while preserving campaign logic.

## Campaign Map

Presentation changes may:

- enlarge the useful map workspace;
- improve node label readability;
- strengthen selected routes;
- dim future locked routes;
- reduce visual competition from future nodes;
- improve node hit targets;
- preserve immediate map and primary action visibility.

Presentation changes must not:

- alter unlock rules;
- alter node ids;
- alter rewards;
- alter save writes;
- alter campaign progression.

## Mission Panel

Default mission panel should show only:

```text
Mission title
Status
One-line description
Primary objective
Reward chips
Difficulty chip
Primary action
[ More Details ]
```

Move behind More Details:

- doctrine;
- long briefings;
- build hints;
- extended reward copy;
- replay notes;
- telemetry;
- rival detail.

## Campaign Tabs

Tabs should prefer:

- primary summary card first;
- key actions second;
- optional details collapsed;
- less unused dead space;
- less prose;
- larger readable type;
- no functionality deletion.

## Acceptance

- Salto Outskirts remains selected on fresh campaign.
- Returning from another mission preview preserves the v0.93 scroll reset.
- Locked Aether Well preview still works.
- Private-demo launcher and tabs remain available.
- Default map tab avoids page scrolling at 1366x768.
- No node overlap at 1920x1080, 1600x900, or 1366x768.
