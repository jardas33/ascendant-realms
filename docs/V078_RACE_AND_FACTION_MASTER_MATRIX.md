# v0.78 Race And Faction Master Matrix

Date: 2026-05-30

## Status

This is a human-review draft. Names, silhouettes, mechanics, and campaign timing are proposals. No runtime races, factions, units, buildings, art, or IDs are added in v0.78.

## Mandatory Race Tests

Silhouette test: could a player recognize the race from black silhouettes of its Worker, basic troop, elite unit, hero, and Command Hall?

Gameplay test: each final playable race must eventually have at least one unique economy decision, one unique relationship with mines or strategic sites, one signature unit, a recognizable architectural language, a distinct battlefield rhythm, meaningful strengths and weaknesses, race-specific hero interactions, and a compelling motive in the Lume conflict.

## Master Roster Summary

| Race | Species | Humanoid degree | Lume relationship | Battlefield rhythm | Priority |
| --- | --- | --- | --- | --- | --- |
| Barrosan Freeholds | Human | Human | Communal stewardship | Steady defense and site control | Early, vertical slice candidate |
| Ashen Covenant | Mixed altered civilization | Human plus constructs | Controlled overuse | Aggressive pressure and siege | Early rival/enemy, later playable review |
| Moura Court | Subterranean fae | Partly humanoid, clearly non-human | Bargain and concealment | Deception and elite movement | Mid-campaign |
| Granitborn | Living stone beings | Low to moderate humanoid | Stone memory | Slow durable territory | Mid/late |
| Wolfveil Clans | Lupine beastkin | Beastlike humanoid | Pack territory and paths | Fast scouting/flanking | Mid-campaign |
| Careto Host | Masked winter spirits/possessed warbands | Variable | Ritual disruption | Tempo swings and fear | Mid/late |
| Rootbound Concord | Plant/fungal/woodland beings | Low to variable | Ecosystem growth | Regeneration and terrain control | Later |
| Deepbell League | Subterranean smithfolk and helpers | Non-human smithfolk plus machines | Engineered resonance | Mines, tunnels, traps | Mid/late |

## 1. Barrosan Freeholds

- Species/anatomy: human highland communities; rugged, practical, layered wool/leather/iron; fully humanoid.
- Culture: granite halls, communal loyalty, oath stones, hearth defense, stubborn survival.
- Lume philosophy: Lume is a living trust held by villages, not a commodity.
- Moral position: protective but can become insular or possessive.
- Campaign motive: defend Salto and restore the broken oath.
- Worker silhouette: hooded villager with tools, lantern, and pack frame.
- Basic troop silhouette: shielded militia with short spear or axe.
- Ranged troop silhouette: cloak, bow/crossbow, highland stance.
- Elite silhouette: oathguard with tall shield, banner, and hearth-marked armor.
- Hero silhouette: Jardas with cloak, oath blade/staff, visible Lume binding mark.
- Command Hall silhouette: granite longhouse with hearth chimney and oath stone.
- Architecture: stone, timber, slate, red ember windows, practical walls.
- Economy identity: reliable Workers, recovery, defensive upkeep, strong site assignment.
- Mine/site interaction: safer extraction and village-linked site recovery.
- Signature mechanic concept: Hearth Oath, improving nearby Workers/Retinue when defending linked sites.
- Tempo: balanced, resilient, good comeback stability.
- Strengths: durability, recovery, Retinue depth, defensive site control.
- Weaknesses: less explosive pressure, slower high-tech spikes.
- Hero-race traits: oath defense, Retinue loyalty, village recovery.
- Animation/VFX/audio implications: grounded tool work, shield bracing, hearth embers, bells and wind.
- AI-art risks: generic medieval humans; must anchor with granite/hearth/highland silhouettes.
- Complexity: low to moderate.
- Existing placeholder mapping: `free_marches` can remain internal; future display name could become Barrosan Freeholds.
- Original-IP notes: avoid generic human kingdom or direct historical reproduction.
- Implementation priority: first polished faction candidate.
- Campaign timing: early.
- Silhouette test: likely pass if oath stone, hooded Worker, hearth hall, and shield line are enforced.

## 2. Ashen Covenant

- Species/anatomy: mixed altered humans, forge-blooded exiles, ember-marked beings, controlled constructs.
- Culture: disciplined flame, blackened iron, chains, furnaces, survival through dangerous control.
- Lume philosophy: Lume must be contained and forced before it destroys everyone.
- Moral position: authoritarian and destructive, but not irrational.
- Campaign motive: prevent catastrophe through command of the Marches.
- Worker silhouette: ember-marked laborer with furnace tools or chain winch.
- Basic troop silhouette: lean iron infantry with forward blades and ember vents.
- Ranged troop silhouette: fire-lance or ash crossbow profile.
- Elite silhouette: forgebound construct or ember knight with furnace core.
- Hero silhouette: commander/Seer framed by iron halo, coat, or heat vent.
- Command Hall silhouette: blackened fortress furnace with smoke stacks and chain anchors.
- Architecture: iron ribs, ember slits, soot-black stone, disciplined geometry.
- Economy identity: fast extraction and overcharge at risk.
- Mine/site interaction: can force a site for immediate strength with later cost.
- Signature mechanic concept: Overburn, trading site health/stability for tempo.
- Tempo: aggressive, siege-oriented, volatile.
- Strengths: pressure, burn effects, siege, fast spikes.
- Weaknesses: self-damage, instability, recovery problems.
- Hero-race traits: controlled burn, commander pressure, dangerous Lume surge.
- Animation/VFX/audio implications: heat shimmer, sparks, iron impacts, furnace drones.
- AI-art risks: drifting into generic demons/evil empire; keep disciplined survival logic.
- Complexity: moderate.
- Existing placeholder mapping: `ashen_covenant` already aligns and should remain stable.
- Original-IP notes: avoid copied orc/demon/undead faction language.
- Implementation priority: early enemy/rival; playable later after review.
- Campaign timing: early as antagonist, playable review later.
- Silhouette test: strong if forge stacks, ember vents, and constructs are distinct.

## 3. Moura Court

- Species/anatomy: clearly non-human subterranean fae; elongated hands, reflective eyes, mineral ornaments, root-lit features.
- Culture: hidden springs, buried palaces, ancient treasures, illusions, broken promises.
- Lume philosophy: Lume is a secret current guarded by bargains and memory.
- Moral position: protective but manipulative.
- Campaign motive: reclaim hidden routes and prevent surface misuse.
- Worker silhouette: small robed digger with mirror-lantern and curved tools.
- Basic troop silhouette: slender spear/knife guard with crescent posture.
- Ranged troop silhouette: crystal slinger or mirror caster.
- Elite silhouette: veil knight with reflective shield and impossible cape shape.
- Hero silhouette: Seer with crown-like stones and spring-light staff.
- Command Hall silhouette: half-buried palace arch, spring pool, luminous roots.
- Architecture: polished stone, arches, reflective pools, subterranean gardens.
- Economy identity: hidden routes and shrine/spring manipulation.
- Mine/site interaction: can veil sites, open hidden paths, or bargain for output.
- Signature mechanic concept: Veiled Passage, repositioning through controlled sites.
- Tempo: deceptive, elite, ambush-oriented.
- Strengths: mobility tricks, shrine control, ambushes, elite forces.
- Weaknesses: fragile economy if revealed, lower brute durability.
- Hero-race traits: foresight, illusions, spring binding.
- Animation/VFX/audio implications: refracted light, soft bells, water echoes.
- AI-art risks: generic elves/fairies; must remain subterranean, mineral, uncanny.
- Complexity: high.
- Existing placeholder mapping: no runtime faction change; future display only.
- Original-IP notes: use regional folklore inspiration carefully, not copied depictions.
- Implementation priority: mid-campaign after visual review.
- Campaign timing: Act 2.
- Silhouette test: needs strong non-human anatomy and palace/spring shapes to pass.

## 4. Granitborn

- Species/anatomy: living stone beings; asymmetrical stone bodies, moss seams, standing-stone faces; low humanoid reliance.
- Culture: awakened cliffs, old fortresses, mountain guardians, ancient patience.
- Lume philosophy: Lume is memory held in stone and pressure.
- Moral position: slow to act, dangerous when awakened.
- Campaign motive: stop the land from being wounded beyond repair.
- Worker silhouette: squat stone shaper with chisel arms or pebble helpers.
- Basic troop silhouette: blocky shield-stone walker.
- Ranged troop silhouette: shard thrower or resonance pillar bearer.
- Elite silhouette: monolith guardian or walking gate.
- Hero silhouette: Binder formed around a standing stone core.
- Command Hall silhouette: ring of standing stones fused into a fortress heart.
- Architecture: megaliths, terraces, carved cliffs, heavy gates.
- Economy identity: slow expansion, strong fortified sites.
- Mine/site interaction: can awaken stone sites into defenses.
- Signature mechanic concept: Living Wall, converting site control into terrain defense.
- Tempo: slow, deliberate, almost immovable.
- Strengths: durability, defense, territorial control.
- Weaknesses: speed, map response, early pressure.
- Hero-race traits: stone binding, damage reduction near linked sites.
- Animation/VFX/audio implications: heavy steps, dust, rock resonance, low drums.
- AI-art risks: generic golems; must have culture and architecture, not just rocks.
- Complexity: high for animation.
- Existing placeholder mapping: none; do not repurpose IDs in v0.78.
- Original-IP notes: avoid direct elemental race imitation.
- Implementation priority: deferred until silhouette pipeline matures.
- Campaign timing: Act 2 or Act 4.
- Silhouette test: strong if non-humanoid proportions are enforced.

## 5. Wolfveil Clans

- Species/anatomy: lupine beastkin; digitigrade legs, muzzles, ridge cloaks, pack markings.
- Culture: mist walkers, highland hunters, beast-binders, moonlit raids.
- Lume philosophy: Lume is scent, path, territory, and pack memory.
- Moral position: loyal to pack and land, dangerous to outsiders.
- Campaign motive: preserve ridge paths and resist fortress control.
- Worker silhouette: light scout-builder with pack harness.
- Basic troop silhouette: low-running claw/spear fighter.
- Ranged troop silhouette: ridge javelin or shortbow hunter.
- Elite silhouette: mist alpha or beast-binder with companion silhouette.
- Hero silhouette: Hunter with wolf cloak, long weapon, and forward lean.
- Command Hall silhouette: hide-and-stone pack lodge with tall signal poles.
- Architecture: mobile-looking lodges, ridge markers, bone/wood signal frames.
- Economy identity: scouting, fast site harassment, mobile logistics.
- Mine/site interaction: can mark paths between sites for speed.
- Signature mechanic concept: Pack Trail, bonuses when attacking from scouted routes.
- Tempo: fast, mobile, flanking.
- Strengths: scouting, raids, worker/site pressure.
- Weaknesses: static defense, siege durability.
- Hero-race traits: pursuit, ambush, pack morale.
- Animation/VFX/audio implications: fast gait, mist trails, howls, footfall rhythm.
- AI-art risks: generic werewolves; avoid horror-only treatment.
- Complexity: high due anatomy and animation.
- Existing placeholder mapping: none.
- Original-IP notes: must not copy familiar beast faction rosters.
- Implementation priority: strong visual-slice candidate after Barrosans.
- Campaign timing: Act 3.
- Silhouette test: likely pass with digitigrade anatomy and pack lodge.

## 6. Careto Host

- Species/anatomy: masked winter spirits and possessed ritual warbands; bodies vary under masks, bells, straw, smoke, and cloth.
- Culture: winter rituals, masks, bells, unsettling celebration, seasonal power.
- Lume philosophy: Lume is awakened through ritual noise, fear, laughter, and inversion.
- Moral position: chaotic but not mindless; they enforce old seasonal laws.
- Campaign motive: punish broken oaths and disrupt false order.
- Worker silhouette: masked ritual tender with bells and bundle tools.
- Basic troop silhouette: leaping masked fighter with bell cords.
- Ranged troop silhouette: smoke-thrower or sling dancer.
- Elite silhouette: towering mask spirit with antler/bell frame.
- Hero silhouette: Marshal or Seer behind a massive ritual mask.
- Command Hall silhouette: winter bonfire ring, mask poles, smoke canopy.
- Architecture: temporary ritual camps, carved masks, bells, smoke, bright cloth.
- Economy identity: tempo disruption and ritual timing windows.
- Mine/site interaction: can invert a site's effect briefly or disrupt enemy links.
- Signature mechanic concept: Winter Revel, pulsed buffs/debuffs on a ritual beat.
- Tempo: unpredictable, disruptive, bursty.
- Strengths: morale pressure, feints, battlefield disruption.
- Weaknesses: consistency, long stable economy, direct siege.
- Hero-race traits: fear, rhythm, temporary oath inversion.
- Animation/VFX/audio implications: bells, stomps, masks, smoke bursts.
- AI-art risks: cultural caricature; needs respectful fictionalization and review.
- Complexity: high due animation/audio identity.
- Existing placeholder mapping: none.
- Original-IP notes: use broad ritual inspiration carefully, avoid literal appropriation.
- Implementation priority: human review required before production.
- Campaign timing: Act 3 or Act 4.
- Silhouette test: strong if masks and bell frames are unmistakable.

## 7. Rootbound Concord

- Species/anatomy: plant, fungal, and woodland beings; bark armor, root limbs, mushroom seers, seed-creatures.
- Culture: living roots, ecosystems, slow awakening, territorial restoration.
- Lume philosophy: Lume is a growing network that must be healed.
- Moral position: restorative but can consume villages into ecology.
- Campaign motive: stop extraction and regrow wounded sites.
- Worker silhouette: root-tender with branching arms and seed pack.
- Basic troop silhouette: bark shieldling or thorn walker.
- Ranged troop silhouette: spore caster or seed archer.
- Elite silhouette: ancient treant/fungal knight hybrid.
- Hero silhouette: Shepherd or Binder with root halo and living staff.
- Command Hall silhouette: grown hall-tree with root gates and fungal lamps.
- Architecture: living structures, root bridges, fungal vents, woven bark.
- Economy identity: regeneration, spreading influence, evolving sites.
- Mine/site interaction: can heal or biologically convert sites.
- Signature mechanic concept: Root Network, slow spreading bonuses and recovery.
- Tempo: slow start, strong territorial snowball if protected.
- Strengths: regeneration, defensive ecosystem, attrition.
- Weaknesses: fire/burst pressure, slow relocation.
- Hero-race traits: healing, protection, growth specialization.
- Animation/VFX/audio implications: growth, spores, creaking wood, soft chimes.
- AI-art risks: generic ents/dryads; make fungal/woodland society specific.
- Complexity: high due non-human animation and building growth.
- Existing placeholder mapping: `sylvan_concord` can remain internal only; future display name could become Rootbound Concord if approved.
- Original-IP notes: avoid direct elf/treant faction substitutes.
- Implementation priority: later after art direction matures.
- Campaign timing: Act 4 or late Act 3.
- Silhouette test: pass if non-humanoid workers and grown Command Hall are enforced.

## 8. Deepbell League

- Species/anatomy: non-human subterranean smithfolk plus engineered helpers; compact bodies, resonant helmets, tool-limbs, bell machinery.
- Culture: mine artisans, tunnel crews, bell-forgers, resonant logistics.
- Lume philosophy: Lume can be engineered through resonance if handled with craft discipline.
- Moral position: pragmatic, inventive, sometimes exploitative.
- Campaign motive: secure mines and prevent reckless surface control.
- Worker silhouette: compact engineer with bell pack and drill/tool arms.
- Basic troop silhouette: armored tunnel guard with wide stance.
- Ranged troop silhouette: bolt-thrower or resonance carbine carrier.
- Elite silhouette: bell engine, tunneling machine, or exosuit.
- Hero silhouette: Artificer with resonant frame and mine lantern.
- Command Hall silhouette: underground lift tower with great bell and gear arms.
- Architecture: stone-metal mineworks, bells, rails, braces, resonant pylons.
- Economy identity: mining, tunnels, traps, planned technology.
- Mine/site interaction: strongest mine specialization and tunnel logistics.
- Signature mechanic concept: Bellworks, resonant mine upgrades and trap routes.
- Tempo: deliberate, economic, technical.
- Strengths: mining, defensive traps, machinery, tech scaling.
- Weaknesses: mobility before tunnel setup, vulnerable surface expansion.
- Hero-race traits: mine engineering, constructs, trap support.
- Animation/VFX/audio implications: bells, pistons, drills, low metallic resonance.
- AI-art risks: generic dwarves/gnomes; must be anatomically and culturally distinct.
- Complexity: moderate-high.
- Existing placeholder mapping: none.
- Original-IP notes: avoid familiar dwarf faction expression.
- Implementation priority: good later systems candidate after mine identity is approved.
- Campaign timing: Act 2 or Act 4.
- Silhouette test: likely pass if bell machinery and compact non-human anatomy lead.

## Diversity Summary

The roster intentionally avoids eight cosmetic human kingdoms. It contains one human faction, one mixed altered civilization, and six strongly non-human factions. The highest risk races are those closest to familiar fantasy shorthand: Ashen Covenant, Rootbound Concord, and Deepbell League. They need silhouette sheets, architecture sheets, and original-IP review before runtime work.
