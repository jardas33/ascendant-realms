# v0.81 Race Extensibility Matrix

Status: docs-only future extensibility plan. No races, factions, race-specific rules, art, units, buildings, or runtime Lume behavior were added.

## First Slice Posture

The first Lume Site Network prototype should be race-neutral or Barrosan-baseline. It should establish common vocabulary:

- eligible site;
- link;
- active;
- severed;
- ward/benefit;
- enemy recapture;
- battle-local Results.

Race-specific Lume mechanics must remain deferred until the base system is fun and readable.

## Matrix

| Future race/culture | Lume expression | Possible later mechanic | First-slice status |
| --- | --- | --- | --- |
| Barrosan Freeholds | Stewardship, oaths, reliable local defense, recovery | Linked Ward, safer Retinue recovery, Worker/site steadiness | Baseline flavor only |
| Ashen Covenant | Overcharge, temporary strength, instability, consequence | Stronger temporary buffs that can damage or exhaust sites | Deferred |
| Moura Court | Hidden paths, veiled links, spring bargains, elite movement | Concealed link state, short reposition options, bargain costs | Deferred |
| Granitborn | Living walls, awakened stone, slow durable territory | Stronger fortification near linked stone sites | Deferred |
| Wolfveil Clans | Trail marking, scouting, flanking, movement | Movement or vision links along held paths | Deferred |
| Careto Host | Inversion, disruption, rhythm-based effects | Temporary enemy link disruption or reversed benefits | Deferred |
| Rootbound Concord | Biological spreading, recovery, ecosystem links | Regeneration, root spread, linked healing zones | Deferred |
| Deepbell League | Engineering, tunnels, resonance, specialization | Tuned junctions, tunnel logistics, buildable resonance anchors | Deferred |

## Barrosan Baseline Recommendation

For the first prototype, express Barrosan stewardship without adding a race system:

- Benefit: Linked Ward.
- Tone: defend what the land remembers.
- Counterplay: enemies sever by recapturing sites.
- No race selection, no Barrosan-only rules, no permanent oath choices.

This keeps the prototype compatible with the current browser build, where playable race identity is not yet implemented.

## Deferred Race Questions

Questions for later, not v0.81:

- Should each race have one Lume link benefit, or should the benefit come from hero class/oath?
- Are Living Mines universal, Barrosan-specific, or Deepbell/Granitborn-specialized?
- Can enemy factions corrupt or overcharge player links?
- Should race-specific network choices persist across a campaign?
- Should a later desktop version support richer visual link language per race?

## Stable IDs

Do not rename current internal faction IDs while planning race extensibility:

- `free_marches`
- `ashen_covenant`
- `sylvan_concord`
- `common_folk`
- `old_faith`

Future display names can change through a separate display-copy migration gate, not through the first Lume prototype.

## Expansion Rule

Each future race-specific Lume expansion should add one new behavior at a time, with:

- a design spec;
- content validation;
- battle-local tests first;
- save migration only if absolutely necessary;
- clear rollback notes;
- Emmanuel approval before adding runtime asymmetry.
