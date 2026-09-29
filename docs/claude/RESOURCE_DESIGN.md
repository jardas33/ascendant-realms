# Resource gathering: review and redesign

Written 2026-09-28 by Claude, in answer to Emanuel's ask: "is there a better, more awesome, addicting way to collect resources, does it make sense and is it fun?"

## How it works today

- Four resources: food, timber, stone and gold.
- Each start has the same fixed fields: one grain harvest (1,200 food), two log stacks (800 timber each), one quarry (700 stone) and two gold veins (900 each), all within about 15 m of the hall.
- Workers walk to a field, take 3 per second up to a load of 10, walk back and drop it at the hall. Houses add 1 food a second.
- Lume Spire capture points around the map give a trickle of income, vision, healing or mana to whoever holds them.

## What is wrong with it

1. **It is flat.** Every start is identical and everything a player needs sits beside the hall. Nothing pulls a player out across the map before the first fight, so the midgame is only about armies.
2. **Workers are chores, not decisions.** The only choices are how many workers and where to send them. The walking loop is invisible busywork once set up.
3. **Food is the one real bottleneck.** In the AI tests, the single food field decided whole matches (Barrosan starved on food while 3,000 gold sat unspent).
4. **Raids are one-sided.** Workers standing in the open die in batches, and there is nothing to defend except the workers themselves.
5. **Little feedback.** Income arrives silently; there is no moment of "that paid off".

## The design: Veins of the Highland

Warlords Battlecry, the game that inspired Ascendant Realms, made map control the heart of its economy: mines you seize and staff. That fits this game perfectly, so the base loop stays and a second, bigger loop is added on top.

1. **Home fields stay:** the fields by the hall still work as now, so the opening is familiar. They are a little smaller, so they carry the early game rather than the whole match.
2. **Veins across the map:** each battlefield gets neutral veins between the bases: a gold vein, a granite quarry, an old-growth grove and a terraced farm, one of each or more on bigger maps.
3. **Claim and staff:** a worker claims a vein by raising a small outpost on it (cheap, fast). Workers sent to an outpost go inside and work it: each worker inside adds steady income, with no walking and no exposure. An outpost holds 3 workers at first.
4. **Upgrade:** an outpost upgrades twice (Camp, Works, Great Works). Each level adds 2 worker slots and 25% output, and the top level adds a watch-fire that shoots at raiders.
5. **Fight over them:** outposts can be attacked. When one falls, the workers inside spill out and the vein goes neutral again. The AI claims, staffs, defends and raids veins too.
6. **Rich veins:** a few minutes into a battle, a Lume-rich vein flares (like the Lume Surge): double output for whoever holds it.
7. **Feedback:** a small "+12 gold" rises over an outpost each time it pays, and the top bar shows income per minute beside each resource.

## Why this is better

- **Map control becomes the economy.** Expanding, defending lines of outposts and raiding the enemy's veins make the whole map matter from minute three.
- **Real decisions:** where to expand, how many workers to commit to one vein, when to upgrade, what to guard.
- **Raids have a target that isn't just helpless workers.** An outpost is a small fortification with a watch-fire, so raiding it takes a real force.
- **It sounds like progress:** outposts grow, pay visibly and upgrade.
- **Endless-friendly:** Endless Road stages can place richer veins deeper on the road, and talents or relics can boost vein output.

## Build order

1. Vein sites on every map (placement from the map layout, between bases).
2. The outpost building for all ten factions (reusing each faction's small building model, scaled), with claim, garrison, output and upgrade.
3. The HUD: income per minute, the "+N" popups, and outpost slots in the command card.
4. AI: claim, staff, upgrade, defend and raid veins.
5. Balance: home fields at about 70% of today's size, then AI-versus-AI soaks to tune output.
6. Regression, including the existing economy test (home gathering must keep working exactly as before).

## Added since (plans 39 to 50)

- **Caravan trade** (main hall): buy 50 food, timber or stone for gold. The price starts at 100, rises 6 per trade and eases back 1 gold every 4 s. Sell 100 of a surplus for a flat 30 gold, so there is no buy-sell loop. The AI buys when a store drops under 150 and it has gold to spare, and sells piles over 900 when its gold runs short. Goes through the command bus (`trade`).
- **Food cliff feedback:** when the food node by the hall runs dry, an alert says what feeds an army next (houses, a food vein, the caravan).
- **Buried Lume jars** (`scripts/world/lume_jar.gd`): from minute 4, a jar surfaces between the bases every 150 s, with at most 2 out at a time. Troops of one side standing over it alone for 6 s dig it up: 150 gold plus 100 of that side's scarcest store. When both sides stand over it, nobody digs. Jars show on the minimap, the AI sends idle soldiers after them, and the Endless twist "Jar Season" doubles them. There is a deeds track for jars dug, and the result screen lists them. In live AI matches, all 45 matches of one round had jars dug, about 5.6 per match.
- **Workers are sturdier** (+40% health): ranged raids were deciding matches on their own. See the plan 50 progress entry.
