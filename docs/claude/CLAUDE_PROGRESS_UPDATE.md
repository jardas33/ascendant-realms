# Ascendant Realms: Claude progress update

Last updated: 2026-09-27, 23:00 UTC. Claude updates this file after every pass. (Earlier entries were stamped 2026-09-29 by mistake; all of this work happened on 2026-09-25 to 27.)

## Where the work is

- **Game:** Godot 4.6.3 project at `production/ascendant-realms-godot`.
- **Branch:** `claude/perf-placeholders-r1`, in the clone at `D:\ClaudeWork\ar-lane`.
  - It is based on Codex's `codex/current-godot-baseline-next` (ebef47ae).
  - It merges Codex's ornate HUD branch (b6bcbe25).
  - About 155 Claude commits; every current Codex branch tip is included (see `docs/claude/CONVERGENCE_AUDIT.md`).
- **Status:** pushed to GitHub as a backup branch (2026-09-27); not merged into main. Claude pushes it after each batch of commits.
- **Codex work included:** the branch merges Codex's newest committed work: the UI convergence branch (ad35fe9f: War Chest armory, HUD icon atlases, skill constellation, top metrics, production/research legibility, hero ability art, living Groveheart HQ) and the Clan Levy character branch (f5283cd9). All tests pass on the combined build. Later merged Codex's Vorthak HUD portraits and building-gallery work (4d34f2b2); tests pass and the portraits show in play.
- **Handoff notes:** the commit-by-commit notes for Codex are in `docs/claude/CLAUDE_LANE_HANDOFF.md`.
- **Constraints kept throughout:**
  - Everything lives on disk D.
  - No paid tools.
  - Codex worktrees are never touched.
- **Tests:** the nine self-checking tests pass after every change:
  - economy
  - identity
  - combat
  - easy AI wave
  - conquest victory
  - navigation repair
  - combat-hit audio, in both modes
  - projectile-impact audio

## The saga (lore overhaul, 2026-09-27)

- **Story bible:** docs/lore/ASCENDANT_REALMS_SAGA.md, "The Saga of the Seventy-Seventh Ascension". It is set in the Terras Frias, a fictional highland drawn from Barroso: Salto, Montalegre's castle, the castros, the Larouco, drowned villages, the communal oven, the Chega de Bois, witch-nights, the Santa Compaña, Caretos, mouras encantadas, the wine of the dead. Lume is memory that burns. Every 77 years it ascends and chooses a Jardas, and every Ascension has ended in war, which finally explains the name Ascendant Realms. The hero died at the spring in the prologue and does not learn it until Act III.
- **Campaign:** replaced the 6-battle Border Marches with 5 Acts and 39 battles (scripts/game/campaign_defs.gd): 31 on the main road, 7 optional side roads holding seven jars of Wine of the Dead, and a branching choice at the Rabagão Wall (break it or seize it) that seals the other road. There are three endings: The Oath Kept, The Ascendant Realm, and a true ending, The Chega, which needs all seven jars.
- **Campaign screen:** Act tabs, main road plus side roads, a pulsing next battle, jar count and choice in the header, and a chronicle briefing page before every battle. Campaign battles return to the saga map.
- **In battle:** an opening line, the enemy commander speaking at 3 and 8 minutes, and a victory chronicle on the result ledger that moves the story forward.
- **Factions, units and buildings:** all 10 factions rewritten into the saga (Barrosan Clans, Lioraen Concord as the Mouras, Vorthak as drowned Furna, Aurean Dominion, the Compaña, Careto Host, Wolfveil Clans, Granitborn, Ironmaw Horde, Moura Court). 73 unit and 39 building names and descriptions were rewritten; the Barrosan hero is now the Jardas. Ids, stats and portraits are unchanged.
- **Review fixes:** a data check confirmed all 39 chapters have valid maps, factions and links, every chapter is reachable, and there are exactly 7 jars. Story fixes: Avó Brites is now Malrec's younger sister, born in Furna (their ages did not work before). The Compaña's battle hero is the Candle-King rather than Leonor, so you no longer kill your own mother in every Compaña battle. The Vorthak and Dominion battle heroes are generic ranks, because Malrec dies in Act IV and the Regent surrenders, yet both armies keep fighting. The Seventh Son side road no longer has you fighting the wolves you came to save. Both roads of the Wall choice pulse while the choice is open. Every enemy faction the saga uses was checked in AI matches with no errors.
- **Every hero fits the story:** a Lioraen hero is a Moura foundling Avó Brites found in the spring; a Vorthak hero carries Furna's blood through their grandmother. Each origin is added to the prologue briefing and the Act III ledger reveal.
- **Plan 3 (done):**
  - Old Border Marches progress now clears the matching Act I chapters.
  - The battle HUD shows the chapter title.
  - A title card (Act, chapter, first line of the chronicle) opens every campaign battle.
  - Four survival chapters (Night of the Witches, Rising Water, Pilgrims' Bridge, and the final Seventy-Seventh Oath) are won by holding out for 6 to 10 minutes, with a live countdown.
  - Defeat shows a chronicle line inviting a retry, and the final chapter is headed THE SAGA ENDS.
  - The main menu reads Begin the Saga or Continue the Saga, Act N.
  - Every briefing shows a suggested hero level.
  - Each Act tints the campaign map (ember, drowned teal, grave blue, bronze, violet).
  - Codex had no new commits, and a full regression passed: all tests, the saga data check, the mode sweep and the tour.
- **Plan 4 (done):**
  - In campaign battles every enemy faction reacts when its stronghold falls or its hero dies.
  - Jar chapters end with a violet "A jar of Wine of the Dead · N of 7" line.
  - Each new Act is announced with a full-screen card the first time it opens.
  - After a win, the campaign map opens the next chronicle automatically.
  - Side roads give 1.5 times the hero experience.
  - Lioraen and Vorthak heroes have their own first words on the night of the Ascension.
  - The hero sheet shows saga progress (chapters and jars).
  - Skirmish map names were kept: they already fit the world.
  - Codex had nothing new, and the regression passed.
  - Review probes now restore the whole profile afterwards. Earlier test victories had added some experience to the local test hero.
- **Plan 5 (done, commit 3ec5d877):**
  - Every enemy faction now fights with its own personality: swarm factions (Ironmaw, Wolfveil, the Compaña) attack early in small waves; disciplined ones (Aurean Dominion, Granitborn) mass bigger armies before marching.
  - Chapters can send mid-battle reinforcement waves for either side, with a spoken line. Some chapters give the player allied troops (village levies, a Careto band). Allies do not use the player's population.
  - Each of the 7 side roads pays out a named relic item for the hero the first time it is won (for example the Esconjuro Bowl), shown on the result ledger.
  - Cleared chapters can be replayed as a Heroic Replay: every enemy is one difficulty step harder and experience is 1.5 times higher. Replays never pay a jar or relic twice.
  - In a campaign battle the pause menu names the chapter and its goal.
  - The Hero Forge shows each race's saga origin, and every one of the 10 factions now has its own origin story (prologue briefing and Act III ledger reveal) and its own first words on the night of the Ascension.
  - Regression passed: all 9 tests and the saga data check (39 chapters, 7 jars, 0 problems).
  - Codex check: the only unmerged Codex UI branch is `astra-complete-ui-overhaul-r1` (22 Sept). Codex's later convergence work (26 Sept, already merged) branched around it and it conflicts with that newer HUD work in about 20 places, so I treated it as superseded and did not merge it. If Codex still wants it, it needs a rebase onto the convergence branch.
- **Plan 6 (done):**
  - **Retinue**, the Warlords Battlecry signature: after a campaign win, the best living veterans (rank 1 and up) join the Jardas's retinue and march into the next battle already promoted. The cap is 2 plus one every 5 hero levels, up to 6. After a defeat, only retinue members who survived stay. Retinue troops don't use population. The result ledger and hero sheet show the retinue.
  - **Heroic laurels:** winning a Heroic Replay marks the chapter "Heroic laurel" in gold on the map; the hero sheet counts them.
  - **Survival chapters:** all four were soaked with a Normal-level AI playing the Jardas, and all four are winnable. The soak exposed two AI economy bugs that made every enemy weaker than intended:
    - Brutal's passive income was rounded down to 0 every frame, so Brutal never got its bonus. Fixed.
    - AI workers only switched to a resource nobody was gathering, so food sat near 0 while gold piled up in the thousands. The AI now also moves a gatherer off a large hoard.
    - Food was the bottleneck for every side, the player too (under 100 food against 1,400+ gold). House gardens now make 1 food per second (was 0.5).
    - After the fixes the final chapter is genuinely tense: the defending player fell to 1 to 3 soldiers while enemy armies reached 13 to 22, and still held. A standard Hard skirmish still ends (minute 17).
  - **Draw calls:** the sun now uses two shadow cascades instead of four. Draw calls in the opening dropped from 2,687 to 2,086 (22 percent), with identical screenshots at play zoom.
  - **Difficulty curve:** audited all 39 chapters. Act V conquest battles had two or three Brutal enemies at once, which became a wall once Brutal income worked. Each main-road battle now has one Brutal leader; the rest are Hard or Normal. The finale keeps three Brutal enemies because it is a survival chapter and was tested winnable. Heroic Replay still offers the double-Brutal fights.
  - **Chronicle:** a Chronicle button on the campaign map opens a scrolling book of every cleared chapter, act by act: its briefing, its victory text, and side-road and laurel tags.
  - **Result ledger:** defeats showed raw ids ("hq_destroyed") on screen; they now read "Your stronghold was razed" and "Your last hall burned". The ledger adds Buildings Razed and Units Lost.
  - **Hero revival:** a fallen hero was gone for the rest of the battle. Now the Lume raises them at their stronghold after 45 seconds, plus one second per hero level (at most 90), with a golden flare and an alert. This applies to enemy heroes too. With no stronghold standing, the revival waits until there is one.
  - **Enemy heroes cast spells:** enemy heroes were bare stat blocks with no abilities. They now get a spell kit that fits their race (none on Easy, 1 on Normal, 2 on Hard, 3 on Brutal) and cast it in fights (heal when hurt, slam into crowds, roots, charge, bolts). In the campaign they grow tougher with each chapter (more health, damage and mana).
  - **Late-game performance soak:** an 18-minute Hard AI-vs-AI match in a window. Memory grows slowly (205 to 314 MB) with no leak in object counts. But frame rate falls in the late game: a normal-speed profile at minute 14 shows 12.3 ms of physics per tick with only 62 units, about three quarters of the frame budget. This is the first item of plan 7.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 7 (done):**
  - **Big battles run 3 to 4 times faster.** In a window, a 120-unit fight ran at 11 fps (a 60-unit fight held 60). The simulation now runs at 30 Hz (the usual RTS rate) with Godot's physics interpolation, so movement is still drawn smoothly at full frame rate. The same 120-unit fight now runs at 43 fps. Supporting changes:
    - The camera is excluded from interpolation and follows zoom every frame.
    - Unit turning speed no longer depends on the tick rate.
    - Units reset interpolation when spawned, so they never streak in from the map origin.
    - Effects are animated per frame.
    - At most 4 catch-up ticks run per frame, so a heavy moment slows slightly instead of freezing.
    - Every projectile flies at least one visible tick (point-blank arrows used to land unseen).
    - Only a character's main body casts a shadow; its 10 to 16 armour and weapon parts no longer do.
    - Attack-moving units scan for targets 5 times a second instead of every tick.
    - A fighting unit no longer re-queues a path query every tick.
    - Building-avoidance steering has a smaller per-tick budget and caches detours longer.
    - All 9 tests pass, including a projectile test that needed the one-tick flight fix.
  - **Note for Codex (test tooling):** in headless runs, freeing a character costs about 15 ms per mesh part, which makes deaths look like 150 ms hitches. This does not happen in a real window. Headless timings of deaths are misleading.
  - **Navigation agents:** the "extra" agents are building obstacles, which Godot counts as agents. There is no leak.
  - **AI stalemates and stuck units:**
    - Construction sites that a builder touched once and then could never reach sat at a sliver of progress forever. The AI counted them as working barracks and never built a real one. Sites with no progress for 75 seconds are now cancelled and refunded.
    - A side reduced to a few workers spent all its food on replacement soldiers and never rebuilt: matches deadlocked with 0 workers and 5,000+ unspent gold. The AI now trains workers first when it has fewer than 6.
    - Worker balancing now aims for a target share per resource (food 35%, timber 25%, gold 25%, stone 15%), adjusted by stockpile. Before, a Barrosan AI sat on 180 gold all game and could not afford soldiers.
    - Result: 4 of 5 twenty-minute AI matches ended decisively at minutes 7 to 10 (most used to stall), with 0 to 4 stuck units.
  - **Enemy heroes** now fall back to their stronghold below 30% health when they cannot heal. They regenerate slowly and rejoin the next wave.
  - **Chapter moods:** 14 chapters now set their own hour and weather over the map's light. Night covers the Spring of Seven Mouths, the witches, the Candle Road and the Compaña chapters. Ember covers the Burning Oven, Malrec's Pyre, the Burning Geira and the finale. Storm covers Furna and Rising Water. Dusk covers the Sun Regent and The Ascendant. Night was brightened after a first capture was too dark to play.
  - **Hero revival presentation:** a pillar of golden Lume light with a light flash, and the hero grows up out of it.
  - **Loading tips** for the retinue, hero revival, Heroic Replay, the Chronicle and enemy hero spells.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 8 (done):**
  - **AI matches:** 6 follow-up cross-faction matches all ended (minutes 9 to 20). Matches between evenly matched sides can still run past 20 minutes. The remaining stuck units are wedged between buildings of their own dense bases (plan 9).
  - **Faction balance:** Barrosan lost all 4 of its AI matches. Unit data showed its tier-2 Outrider was the weakest mid unit (1.8 value per cost, against 3.3 for the Vorthak Rift Blade and 2.6 for the Gloom Hound), and its Clan Levy cost more than the other basic infantry.
    - Outrider: health 120 to 150, damage 15 to 19.
    - Clan Levy: food 60 to 50.
    - Crag Archer: damage 16 to 17.
    - After the change Barrosan went 2 losses and 2 draws. All tests still pass.
  - **Weather matches the chapter moods:** rain streaks in storm chapters, fireflies at night, embers and ash in fire chapters.
  - **Mood ambience (generated, no downloads):** crickets at night; steady rain with distant thunder every 18 to 40 seconds in storms; fire crackle in ember chapters.
  - **Minimap:** while your hero is down, a gold ring pulses on your stronghold where they will rise.
  - **Hero abilities:**
    - Heal Wave, Entangling Roots and Avatar of War had buttons but no keys; they are now Y, U and V.
    - A failed cast now says why (recharging with seconds left, not enough mana, or out of range) instead of doing nothing.
    - HUD buttons for aimed spells (Roots, Bolt, Charge) target the nearest enemy instead of the hero's own feet.
  - **Click feel at 30 Hz:** clicks hit the simulated position, which is at most one tick (about 13 cm at walking speed) behind the drawn unit. That is not noticeable, so no change was made.
  - **Chapter tour:** all 39 chapters load and start with the right factions and heroes, with no script errors.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 9 (done):**
  - **Easy difficulty was broken.** A new player idling against Easy saw no attack in 15 minutes:
    - The first wave waited for every soldier to reach the rally point, and one straggler held it back forever. Staging now times out after 40 seconds.
    - Easy never sent a second wave. It now sends a follow-up wave every 150 seconds once its idle army reaches wave size.
    - The Easy wave test still passes.
  - **AI base layout:** buildings now keep a walking lane between both footprints and stay off resource nodes, and the search reaches further out as a base fills.
  - **Late-game pressure:** after 15 minutes every AI commits whatever army it has (8 or more). All 5 cross-faction soak matches ended (minutes 7 to 18).
  - **AI economy and building fixes:**
    - A second barracks is built when food and timber pile up.
    - No towers are built while the AI is short of housing.
    - Up to six spots are tried before pausing on a blocked placement. A Barrosan AI failed to place its house 5 times in 8 minutes because of its hamlet dressing; Lioraen never failed.
  - **Open finding: the Barrosan AI still loses most AI matches.** It lost 13 of 16 recent matches across three maps and both seats. Economy, housing, placement and unit stats were all adjusted, and the trend held. Plan 10 starts with equal-cost army fights to tell unit strength apart from AI decisions.
  - **Chapter briefings** now introduce each enemy faction the first time the saga fields it (for example "New enemy: The Compaña...").
  - **Controls:** the settings controls list and the pause menu now show all seven hero ability keys.
  - **Medium quality:** weather uses half the particles.
  - Unit render cost in 100+ unit battles is moved to plan 10.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 10 (done):**
  - **Equal-cost army duels** (a new probe spawns about 1,200 resources of each faction's units and has them fight in the open). Before: Barrosan's tier-1 army lost every duel, with a third to half of the enemy army still standing, whichever side of the map it was on. The order was Vorthak, then Lioraen, then Barrosan. Changes:
    - Barrosan: Clan Levy damage 12 to 14, Spear Guard 14 to 17, Crag Archer 17 to 19, Outrider 17 (was 15, briefly 19).
    - Vorthak's cheap swarm: Ash Thrall food 40 to 50 and health 95 to 88; Cinder Spitter food 55 to 65 and damage 17 to 15.
    - Tier-1 duels are now a close triangle: Barrosan beats Vorthak, Vorthak narrowly beats Lioraen, Barrosan and Lioraen split.
    - With tier 2, Barrosan beats Vorthak, Lioraen, Aurean Dominion, Moura Court, Compaña, Careto Host and Wolfveil. Granitborn beats Barrosan.
  - **AI fairness:** the "swarm" personality also made those AIs think 15% faster, an unfair economic edge I added in plan 5. Removed; only the attack-size difference remains.
  - **Open finding:** in full AI-vs-AI games the Barrosan AI still loses (0 of 6 after these changes), even though its armies now win equal-cost fights. The cause is its decision-making, not unit strength. Human players mostly play Barrosan, so this mainly matters when Barrosan is the enemy (Chega de Bois and Barrosan skirmish opponents).
  - **Duel artifact noted:** a Grimtusk-versus-Barrosan mass duel stalled with both armies "attacking" and no damage, identically in headless and windowed runs. One-on-one Grimtusk units fight normally and full AI matches against Grimtusk play out, so this is limited to that test setup.
  - **Headless-only noise for Codex:** "Parameter material is null" errors from material_get_instance_shader_parameters come from the headless dummy renderer with the orc_grunt model, not from real play.
  - **Result screen:** a battle-story line shows kills by your hero and veteran promotions.
  - **Mood sound:** thunder lowered to sit under the music.
  - Hero revival and the retinue are already introduced through alerts, the result ledger and loading tips, so no tutorial change was needed.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 11 (done so far):**
  - **Unreachable build sites:**
    - Found by comparing the Barrosan and Vorthak AIs minute by minute: the Barrosan AI's first house sat unbuilt from minute 1 to minute 5, so it was capped at 12 population with no army.
    - The site was 41 m away across the settlement dressing, and the builder stalled on the way.
    - The AI now accepts only spots its worker can path to by a reasonably direct route, within a tighter cone toward the battlefield.
    - Houses now go up on time. Checked separately: a worker builds a Clan Croft in open ground in 24 seconds, and every faction gathers at the same rate per worker.
  - **Barrosan AI:** it still loses full AI matches (0 of 6), though it now survives up to 21 minutes. Its armies win equal-cost fights and its economy matches, so what remains is strategy (attack timing and composition). This stays open. It does not affect human players of Barrosan.
  - **Aurean Dominion:** its units were the old, weaker Barrosan stats. The legions now fit the saga's main villain:
    - Legionary: health 140, damage 14, armour 2.
    - Phalanx: health 200, damage 16.
    - Archer: damage 18.
    - Charioteer: health 145, damage 19.
    - In duels it now crushes Vorthak and loses narrowly to Barrosan (it used to be wiped out).
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
  - Carried to plan 12: unit render cost in 100+ unit battles, Hard and Brutal from a player's view, and matching every chapter's map to its story.
- **Plan 12 (done):**
  - **Character draw cost.** A census of every unit model found characters built from many separately drawn pieces:
    - Ironmaw Ogre: 146. Bowcrusha: 119. Rift Blade: 43. Stoneward Spears: 42. Outrider and Veil Warlock: about 43 with their accessory kits. Crag Archer: 17.
    - **Bodies:** six models were re-exported from Blender with every rig-driven piece joined into one mesh (Ogre 146 to 1, Rift Blade 43 to 1, Stoneward Spears 32 to 1, plus Clan Levy, Ash Thrall and the Vorthak worker). Rig, bones and animations are unchanged; walk animation was verified on each, and screenshots match. The joined bodies now cast their full shadow (before, only the largest piece did), so they look slightly better. Originals are backed up in D:\ClaudeWork\tmp\glb_backup and noted in the handoff for Codex.
    - **Accessory kits:** the pieces of each attachment are merged at runtime, built once and shared by every unit (Outrider, Veil Warlock and Crag Archer went from about 43 parts to 4 or 5).
    - **Result:** the 120-unit fight went from 43 to 46 fps while also drawing full character shadows. The Bowcrusha (119 rigid pieces) is not joined yet; its pieces are not attached to bones directly.
  - **Hard and Brutal:** against a player who does nothing, Normal and Hard first attack at minute 4 and Brutal at minute 5 with a larger army (18 soldiers). With Easy's gentle waves, that is a sensible ramp.
  - **Chapter maps:** all 39 chapter-to-map pairings fit their stories (winter chapters on snow maps, the Dominion's south on desert and canyon maps, the fountain grove on the verdant map, the drowned villages on water maps). No swaps needed.
  - **Barrosan AI strategy:** still open (it loses AI-vs-AI games on strategy, not units or economy).
  - Regression passed: all 9 tests. Codex had nothing new.
- **Direction from Emanuel (2026-09-27):** the game should take a very long time to finish while staying fun and addictive; heroes need endless levels and upgrades with no limits; online PvP and co-op should be possible later. Hugging Face character work is dropped (quality too poor); Codex owns character model quality.
- **Plan 13 (done):**
  - **No more caps:**
    - Unit veterancy ranks are endless; each rank asks a few more kills (3, 9, 18, 30...).
    - Hero mastery keeps paying with no ceiling. Before, 100 ranks were worth about 13; now they are worth about 63.
    - The retinue grows by one veteran every 6 hero levels, with no maximum.
    - Hero levels were already endless.
  - **The Endless Road**, a new long-play mode on the campaign map, opened by the first chapter win:
    - A chain of battles with no last stage. Opponents grow from one Easy enemy to three, every enemy reaches Brutal, and past stage 12 the enemy gets rising bonus income forever.
    - Experience grows with each stage (x1.08 at stage 1, x9 at stage 100).
    - Every fifth stage forges a relic for the hero whose stats scale with the stage without limit (rare, then epic from stage 15, legendary from 35).
    - Every stage is generated from its number alone, so the same stage is the same battle for every player. That is ready for leaderboards and online play later.
    - Stage names use Barroso places (Pitões das Júnias, Tourém Ford, Cabril Gorge...).
  - **Ironmaw freeze (a real bug):** the Ironmaw Slinger's animations target a rig its model does not have (all 60 tracks unresolved), and every animation change rebuilt the mixer for about 4.3 seconds. Every Slinger shot froze the whole battle; this is why battles against Ironmaw ran slowly and the earlier Grimtusk duel "stalled". Units whose animations do not match their rig now skip animation. Only the five siege engines have no animation, which is expected.
  - **Character joins:** the Ironmaw Slinger (Bowcrusha) joined, 120 pieces to 1. Note for Codex: it never animated, because its 52-bone rig is about 0.27 m tall against a 2.3 m body.
  - **Barrosan AI:**
    - Houses may now be started while the population is capped (the AI sat at 12/12 for minutes with 650 food).
    - Build spots must be reachable by a worker.
    - The AI keeps buildings out of the lanes between its stronghold and nearby resources; houses dropped there were walling off the food and gold gatherers in some matches.
    - Result: all 8 soak matches ended with 0 to 5 stuck units. Barrosan still loses AI-vs-AI games, though its armies now win equal-cost fights against every faction. This stays an open strategy question and does not affect human players of Barrosan.
  - **Balance for the other seven factions** (equal-cost duels against Barrosan, Vorthak and Lioraen):
    - Granitborn was far too strong: its passive gives +1 armour and +8% health (was +2 and +12%), and its basic Warrior and Ironbreaker are slightly less tanky. It now sits mid-pack at tier 1. It looked dominant at tier 2 only because it has no tier-2 units, so its test armies had no weak support units.
    - Moura Court (Precision, +7% damage) and Wolfveil (Pack Hunt, +10% damage) lost every duel; each now beats two of the three reference factions.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 14 (done):**
  1. **Battle loot (new).** Battles never dropped items before; the only gear was a starter kit and relics.
     - Every battle now rolls gear: one item for a win, more on Hard and Brutal, and a 30% chance of one even in defeat.
     - The Fortune attribute (which did nothing before) raises both the number of drops and their rarity.
     - Rarities run common, uncommon, rare, epic and legendary, with more affixes at higher rarity and Barroso-flavoured names ("Oathbound Spear of Salto", "Wolfbone Mail of the Masked Winter").
     - Item power grows with item level forever (hero level, plus Endless Road stage, plus campaign depth). Movement and attack speed grow along a square root so heroes never become absurdly fast.
     - Loot is shown in rarity colour on the result screen, and rolls are seeded from the battle's own numbers.
  2. **War Chest:** items sort by rarity and item level. Each item has a Salvage button showing the experience it gives, and "Salvage Commons" melts every common and uncommon item at once.
  3. **Barrosan AI:** it now builds houses earlier (6 free population instead of 3) because its soldiers take more population each. Barrosan won its first AI match (against Lioraen). All 6 soak matches ended.
  4. **Hero sheet:** a record line shows the Endless Road stage reached, battles, victories and foes slain.
  5. **Endless mastery:** mastery points can be spent without limit, now five at a time with a "+5" button.
  6. **Save safety:** the profile keeps a rolling backup (at most every 2 minutes). A corrupted save used to reset to a blank profile and overwrite the file. It now restores from the backup, which was tested on a copy of the real save with the original put back afterwards.
  7. **Multiplayer readiness:**
     - One match seed now drives the AI's random choices, and units stagger their target scans by creation order.
     - A two-run test confirmed the simulation is not yet deterministic. Godot physics, navigation avoidance and frame-timed AI are the blockers.
     - docs/claude/MULTIPLAYER_READINESS.md recommends a host-authoritative design (Godot's high-level multiplayer), not lockstep, and lists what must change. The suggested first milestone is two-player LAN co-op against the AI.
  8. **Big battles:** units no longer write two audit metadata values every tick. Benchmark runs are noisy (38 to 46 fps for 120 units), so there is no measurable gain to claim.
  9. Codex had nothing new. 10. Regression passed: all 9 tests and the saga data check.
- **Plan 15 (done):**
  - **Legendary powers:** legendary loot now carries a power (Cleave, 8% Lifesteal, Execute or Last Stand) as well as stats.
  - **Bug fixed:** the skill-tree node "Hero attacks splash to nearby enemies" set a cleave flag that nothing implemented, so the skill did nothing. Cleave now deals half damage to enemies around the target (tested: all three clustered enemies die instead of one).
  - **Endless Road twists:** from stage 3 every stage has one or two twists: night, storm, ember or dusk moods (with matching weather and sound), Champions (enemy heroes half again as tough), Warband (enemy reinforcements at 3 minutes) or Rich Spoils (an extra loot roll and +25% experience). Enemy heroes also grow with every stage.
  - **Deeds:** achievement tracks for victories, foes slain, Endless Road depth, saga chapters, heroic laurels and legendary finds. Tiers never end: after the named tiers the goal doubles and the title gains a numeral ("Legend of the Larouco VII"). Each tier grants a mastery point. New deeds are announced on the result screen; the hero sheet shows the hero's title and every track with its next goal. Existing heroes are credited for past deeds.
  - **Named veterans:** at rank 3 a soldier earns a Barroso name ("Rosa the Quiet", "Chico the Garrano"), announced in battle and kept in the retinue.
  - **Auto-salvage setting:** Off, Common, Up to Uncommon or Up to Rare.
  - **Hero sheet:** a Hero Power rating and a list of the hero's active powers.
  - **Trapped armies (a real bug):** stuck-unit logs showed Barrosan soldiers circling inside their own base. The AI had been building across its army's road out. It now keeps a lane clear toward the battlefield. Stuck units fell from 9 to 21 per long match to 1 to 4.
  - **Barrosan AI:** still loses most AI-vs-AI games. This is noted honestly and does not affect human players of Barrosan.
- **Plan 16 (done):**
  - **New units** fill tier gaps, reusing existing models: Granitborn Castro Rider (tier 2 cavalry), Moura Court Silver Colossus (tier 3), Aurean Dominion Sun Scorpion (tier 3 siege) and Wolfveil Moon Bear (tier 3). All four spawn and animate (the Scorpion is a machine, like the other siege engines).
  - **Elite enemies:** about 1 in 30 enemy soldiers is an Elite (80% more health, 50% more damage, larger, gold-edged). Each Elite you kill adds a loot roll with better odds and is announced when it falls.
  - **Gear sets:** epic and legendary drops can belong to one of four sets (Oath of Salto, Furna's Ashglass, Moura Silver, Careto Masks). Two pieces give a stat that grows with the set's item level; four pieces grant a power (for example Careto Masks give Cleave).
  - **Festival stages:** every tenth Endless Road stage is a Barroso feast with its own foes, mood and rich spoils: Entrudo (Careto Host), the Chega de Bois (rival Barrosan clans, a mirror match), the Night of the Witches in Montalegre (the Compaña), Magusto (Wolfveil) and the Fires of São João (Vorthak).
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new. The 120-unit fight benchmark stays at about 36 to 46 fps.
- **Plan 17 (done):**
  - **Spells grow forever:** hero spells dealt fixed damage (Slam 60, Charge 50, Lume Bolt 70) and faded into nothing as heroes grew. Spell damage and healing now scale with the hero's real damage (levels, gear, mastery). Tested: the same Slam went from 98 to 160 damage when the hero hit harder.
  - **Battle bounties:** every battle offers one optional objective, chosen from the match seed: slay an enemy hero, win within 12 to 18 minutes, lose no more than 8 to 15 units, or raze 4 to 8 buildings. It is announced at the start. Meeting it with a victory gives an extra loot roll and +20% experience, shown on the result screen.
  - **Barrosan AI:**
    - Houses were being blocked by other construction, so the AI sat at its population cap with hundreds of unused food.
    - Houses now come first: nothing else starts while the army needs room, and an urgent house gets two builders.
    - Barrosan no longer caps at minute 3 (21/28 and 23/36 in the checks).
    - It still loses most AI-vs-AI games, but lasts longer (up to 17 minutes against Vorthak).
  - **First-loot tip:** the first result screen with loot points players to the War Chest.
  - **War Chest:** set items show how many pieces of their set are worn.
  - **Hero sheet:** lists the retinue by name and rank.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 18 (done):**
  - **Smarter AI armies:** every AI now favours units whose damage type counters the most common armour in the enemy army (for example slashing troops against Vorthak's unarmoured swarm). Barrosan won 1 of 4 soak matches (it beat Lioraen).
  - **Lorecraft:** a new endless mastery constellation that raises spell power with no ceiling.
  - **Lume Surge (world event):** once per battle, at a seeded time between minutes 4 and 10, the Lume rises at a spot near the middle of the field. The first side to hold it alone for 8 seconds gets 200 gold and 200 food; for the player it also gives hero experience.
  - **War Chest:** items can be locked so "Salvage Commons" never melts them. Comparison with equipped gear already existed.
  - **Endless Road milestones:** every 25th stage also guarantees a legendary item, forged at that depth.
  - **Save check:** a 3,000-item War Chest saves in 42 ms and loads in 36 ms (about 1 MB).
  - **Performance:** the 120-unit fight benchmark holds at about 42 fps.
  - Regression passed: all 9 tests and the saga data check. Codex had nothing new.
- **Plan 19 (done):**
  - **Five new side roads**, one per Act, each with a Barroso story and an epic relic: The People's Bull (the village's communal bull, stolen), The Smugglers' Path (the contrabandistas of Tourém), The Castro of Lesenho (Granitborn guardians wake), The Monastery of the Júnias (the Dominion's archive) and The Last Queimada (the witch-night fire before the final oath). The saga now has 44 chapters. The saga data check passes (44 chapters, 7 jars, 0 problems), and the story bible has a section on them.
  - **Chapter counts** in the interface now come from the data instead of a hard-coded 39, and the saga and laurel deeds were extended to 44.
  - **Bug fixed:** the campaign map script did not compile after plan 15 (a variable name used twice in the Endless Road window), so the campaign map could not open. No existing test opens the map. A new check (tests/claude_compileall.gd) now compiles every script and loads every menu scene, and it is part of the regression.
  - **AI and the Lume Surge:** AI armies now race for the surge with nearby idle soldiers.
  - **Vorthak economy trim:** the Thrall Pit gives 8 population like every other house (was 9).
  - **Mastery respec:** a free "Reset Mastery" button on the hero sheet (skill respec already existed).
  - Regression passed: the compile check, all 9 tests and the saga data check. Codex had nothing new.
- **Plan 20 (done):**
  - **Menu smoke test:** every menu (main menu, campaign map, hero sheet, War Chest, settings, skirmish setup, skill tree, Hero Forge) opens and runs for real with no errors. Screenshots checked.
  - **Main menu:** a direct "Endless Road · Stage N" button once the first chapter is won. It opens the stage window on the campaign map. Button height and spacing were tightened so seven buttons fit above the subtitle.
  - **Levelling pace:** a typical won battle gives about 1,800 experience: about 2 battles per level at level 10, 3 to 4 at level 50 and about 9 at level 100, before Endless Road multipliers. Slow and steady, never capped. No change needed.
  - **New units duel-checked at tier 3:** Aurean Dominion and Vorthak narrowly win, Granitborn and Wolfveil narrowly lose. The Moura Court's Silver Colossus got more health and damage; the Moura Court still trails at tier 3, partly because its test army carries weak healers.
  - **Loading tips** for bounties, Lume Surges, elites, gear sets, festivals, deeds, named veterans and item locking.
  - **Soak:** 5 of 6 matches ended. One Lioraen-versus-Barrosan match ran the full 25 minutes with 22 stuck units, so stuck units have returned in that matchup (plan 21).
  - Regression passed: the compile check, all 9 tests and the saga data check. Codex had nothing new.
- **Plan 21 (done):**
  - **Endless Road stage select:** the Endless Road window has "< Stage" and "Stage >" buttons to replay any stage already reached.
  - **War Chest "Equip Best":** puts on the strongest item for every slot in one click.
  - **Deeds:** each deed's next goal shows in a tooltip on the hero sheet.
  - **Veteran rank stars** float over ranked units.
  - **New sounds** for the Lume Surge, elite kills and named veterans.
  - **Balance:** Barrosan AI presses earlier; Moura Court healers are stronger.
- **Plan 22 (done):**
  - **Champion stages:** every fifth Endless Road stage (except festivals) brings an enemy champion.
  - **Elite kills** raise a gold pillar of light where the elite fell.
  - **Found the cause of the stalled Lioraen-versus-Barrosan matches:** the Barrosan War Hall model has a yard wall, and its collision was one solid block reaching 11.7 m from the hall's centre against a 5 m footprint (the Clan Croft's reached 8.9 m against 3.6 m). Troops trained inside the block could never leave, which is also why Barrosan lost most AI-versus-AI games. Collision now stops near each building's footprint. All three Lioraen-versus-Barrosan test matches now finish (before: stalls with 20 to 30 stuck units).
  - **Barrosan players can build several houses at once.** An old guard allowed only one Clan Croft under construction at a time and silently refused the rest.
  - **AI build stalls:** the first house of a match froze the game for about 0.25 s because its collision was not prepared at load. It now is, and the AI's worst decision time fell from about 300 ms to about 40 ms.
  - **Movement:** units crowding the same route corner now count it as reached and move on, and AI bases keep a walking gap between buildings.
  - **Convergence audit** for the director: `docs/claude/CONVERGENCE_AUDIT.md` lists the exact commits and confirms every current Codex tip, including 05d9f857, is already in this branch. Emanuel pushed the branch to GitHub as a backup; Claude will push it after each batch from now on.
  - **Merged Codex's work from 27 September:** the HUD order rack, Vorthak portraits, field-order atlas and Nighthold colours, authored ash-and-basalt ground on volcanic maps, tactical hero range dashes, the Groveheart base and quieter building selection halos (2fad7cf1 and a552e10e). One conflict in the ground shader was resolved by keeping both sides.
  - Regression passed on the merged build: compile check, menu smoke tour, all 9 tests and the saga data check. Pushed to GitHub.
- **Plan 23 (done):**
  - **Hero talents:** every tenth hero level offers a choice of three talents (Bloodthirst, Executioner, Thornhide, Giant's Blood, Swift Blade, Warlord, Stormcaller, Quartermaster, Treasure Hunter). Talents stack forever with no cap. The offer is fixed per pick, so reloading can't reroll it. They're shown on the hero sheet, and the result screen says when a pick is waiting. Old saves get their picks from their level.
  - **Five new Endless Road twists:** Blood Moon (every blow 25% harder, both sides), Lean Season (half starting stores), Fortified (the enemy starts with two towers), Veteran Foes (enemy soldiers arrive ranked) and Allies (four of your soldiers join you).
  - **Three new legendary powers:** Thornmail (melee attackers take 15% back), Stormcall (every fourth blow arcs lightning, deterministic so it works online later) and Bloodrush (a kill speeds up attacks by 40% for 4 seconds).
  - **Save safety:** a new save round-trip test covers every progression system. It found a bug where the old campaign unlock list gained an entry on every load (one save had 445). Fixed.
  - **Fog of war:** explored resources now stay on the map and can be ordered, as in any RTS. Before, only resources in live sight could be, so workers stood idle.
  - **Balance:** Barrosan Clan Levy trains in 11 s (was 14), Barrosan workers cost 45 food and take 11 s (was 50 and 12, now like other factions), and the Barrosan AI raises a second War Hall earlier. From the AI seat, Barrosan now beats Vorthak, Sunspear and Lioraen and draws with Hollow. Note: AI-versus-AI tests are harder for the side in the player's seat, which follows the fog of war and uses the test profile's hero, so earlier "Barrosan loses" results were partly that seat.
  - **Building collision audit:** every building of all ten factions now has collision within its footprint.
  - **Multiplayer groundwork:** every player order (move, attack, attack-move, gather, build, repair, stop, hold, patrol) now travels through a command bus as plain data with network ids, and survives a JSON round trip. This is the seam a host-authoritative online mode needs.
  - **Checked windowed:** about 40 fps in the 120-unit fight, no regression from the Codex merges. Volcanic maps show Codex's new ash-and-basalt ground.
  - Regression passed: compile check, menu smoke tour, all 9 tests, the saga data check, plus new checks for save round trip, talents, command bus and twists.
  - Merged Codex's carved slate waystones for Lioraen starts (1e70d881); compile check and conquest test pass, screenshot checked. Pushed to GitHub.
- **Extras:** the main menu subtitle and five new lore tips on the loading screen.

## Performance and stability

- **AI playtest fixes (plan item 1):** 20-minute AI-vs-AI soaks on Hollowspan and Autumn Reach found and fixed:
  - the new timber, food and gold models had wide collision that walled workers out of the gather ring (a regression from the model pass), so the AI economy starved;
  - builders could freeze beside their sites when the route solver returned a path that ended short; units now re-plan once a second in that case;
  - the AI placed buildings behind its base where the settlement dressing could wall them off; it now builds on the side facing the battlefield, keeps at most two sites open and cancels (with a refund) any site nobody could start within 90 seconds;
  - AI squads sent to capture points attack-moved into the solid landmark and stayed stuck forever; they now stand inside the capture ring.
  After the fixes the enemy AI builds armies of 25 to 50 and destroys the opponent.

- **Fog of war:** it is now drawn from a GPU texture instead of rebuilding an 18,000-vertex mesh every 0.2 s. Speed at 4x game speed went from 6 FPS to the vsync cap.
- **Mid-match stalls:** building collision is cached, and every unit, building, effect and projectile is warmed up while the match loads. The worst frame in a 10-minute run at 4x went from 300 ms to about 33 ms.
- **Enemy AI deadlock:** the AI economy could stall. It now rebalances gatherers, rescues stuck gatherers and finishes abandoned construction. On Normal and above it builds an army and attacks.
- **Large battles:** unit and building lists are snapshotted once per physics frame. Chase re-planning is throttled, and path solving has a per-frame budget. Big-battle physics time went from 19 ms to 9 ms, and 4x battle stalls dropped from 150–260 ms to under 100 ms.
- **Edge scrolling:** it only happens while the game window is focused and the cursor is inside it.
- **Static batching (plan item 3):** the hamlet, holdfast, grove and base dressing are merged into one mesh per material at match start (scripts/world/static_batcher.gd). The hamlet went from 191 draw surfaces to 22 and the holdfast from 55 to 19; total draw calls in the opening view fell from about 3,240 to about 2,690 with no visible change. The remaining cost is mostly the multi-part building models.
- **Error sweep:** these all ran with zero script errors:
  - a 10-minute match at 4x
  - the tutorial
  - the campaign opening
  - starts as all three factions

## World and terrain

- **Lighting:** there is a golden-hour grade on the highland maps and a battlefield grade on every other theme, including tropical.
- **Ground:**
  - Anti-tiling, broad painterly colour fields, rolling relief shading and soft cloud shadows drifting across it.
  - Fixed a real bug: the noise function lost precision on the GPU and drew hard 20–50 m squares across the ground and water.
- **Grass and wildflowers:**
  - About 20,000 instanced tufts that sway in travelling wind gusts. Colour and density follow the theme.
  - They stay off roads, water, start yards, bare dirt and rock.
  - They clear under buildings, resources and capture points, and get trampled where units die.
- **Trees:**
  - They sway in the wind, with a shaded understory, a sunlit crown and light coming through the leaves.
  - They are about a quarter smaller than before, so canopies no longer hide whole squads.
  - They are no longer rendered as shiny metal. The imported models had been metallic.
- **River:** there is a walkable ford under the bridge on the six bridge maps. The water has current streaks, a foam line at the banks and clearer shallows.
- **Weather per map:** pollen over meadows, falling leaves in autumn, snow, blowing sand, and embers and ash on volcanic maps.
- **Fog of war:** it looks like drifting mist with soft, moving edges and extends past the map border.
- **Faction starting bases:**
  - A lived-in Barrosan hamlet with houses, chimney smoke, lanterns, woodpiles and fences.
  - A scorched Vorthak holdfast with charred walls, ash-glass shards and violet braziers, on cracked basalt ground with glowing ember seams.
  - A living Lioraen grove with a bloom meadow, moonstones, glowing blooms and floating motes.
  - Every map dresses each faction's start this way.
- **Blender-made props** (scripts in `tools/blender/`):
  - a dry-stone wall
  - a granite quarry (the stone resource)
  - cairns and heather
  - Vorthak and Lioraen dressing
  - a grain harvest (the food resource, which used to reuse the timber pile)
  - a stacked log pile with ringed end grain, a chopping stump and an axe (the timber resource, which used to be a flat orange block)
  - a rock outcrop split by glowing gold veins, with an ore pile and a pickaxe (the gold resource)
- **Capture sites:**
  - Each has its own landmark: a ruined pillar-circle chapel, and a rocky lookout with a signal brazier. Before, they reused the Lume Spire and gold-mine models.
  - A rune circle marks the real capture area. While a team is capturing, an arc fills around it in that team's colour.
- **Base tracks and yards:** they fade softly into the grass instead of looking like hard, translucent strips.
- **Fixes:** stone walls were rendering nearly black, and a boundary marker was lying on its side. Both are fixed.

## Units, buildings and combat

- **Barrosan worker:** replaced with a sculpted, AI-generated character. The pipeline is free (FLUX, then Hunyuan3D, then a Blender rig fit) and lives in `tools/charpipe/`. Emanuel runs the Hugging Face step himself.
- **Unit materials:** the metallic sheen on unit materials is capped, so cloth and skin no longer look grey-teal.
- **Combat effects:** sparks, flash, dust, death clouds, new arrows and ember bolts, all pre-built so they cost nothing mid-fight.
- **Hero abilities:**
  - Soft shockwave rings.
  - Glowing motes on allies touched by Rally and Heal.
  - Dust, clods and a short camera shake for Slam. The existing reduce-shake setting turns the shake off.
- **Readability:**
  - Team-coloured combat rings.
  - Health bars that appear for 5 seconds after any hit.
  - Glowing selection rings with slowly turning brackets.
  - Team-coloured silhouettes for units hidden behind trees or buildings.
- **Battle marks:** fallen units leave churned, darkened ground that fades after about 25 seconds.
- **Construction:** a building rises behind a moving work line, with its walls and floors going up, instead of a see-through fade.
- **Placement preview:** it shows the real, textured building.
- **Damaged buildings:** smoke rises from a building below 70% health, and flames break out below 40%. Both disappear when it is repaired.
- **Collapse dust and grain (plan item 9):** the collapse dust cloud is twice as dense and larger so it reads at normal zoom, and the food site grain is a richer gold.
- **Destroyed buildings:** they list to one side and sink into a dust cloud with thrown debris and a short camera shake, leaving a rubble heap and scorched ground for the rest of the match. Before, they just shrank into the ground.
- **Hero battle levels:** heroes now level up during a match from kills made within 18 m of them (soldiers 12 XP, workers 6, enemy heroes 60), up to level 5 at 60/150/280/450 XP. Each level adds 10% health, heals a quarter, adds 8% damage, bursts with golden light and fires the "Hero reached level N" alert, which existed but never fired before.
- **Veterans:** when a unit is promoted after three kills, a golden flare marks it and your promotions get an alert. Before, promotion had no visible sign at all.
- **New recruits:** a freshly trained unit arrives in a burst of team-coloured light with a small ring.
- **Banners:** every building flies a waving banner in its owner's colour.
- **Orders:** a soft ring shrinks onto the clicked spot. Attack orders also show inward chevrons.

## Sound

- **Battle ambience:** matches used to have music and no ambience at all; the highland wind recording in the project was never played. Now every map has gusting wind, green maps add birdsong phrases, volcanic maps add fire crackle, and highland and verdant maps also play the wind recording. The sounds are synthesised once at match start (no downloads, about 70 ms) and sit on the Sound Effects slider.
- **Combat feel (plan item 4):** checked: hits, flinches and impact sounds already line up, and the two combat-audio timing tests cover it. No change needed.

## Interface

- **Rally points:** a selected building shows its rally point as a small banner in the owner's colour, with a dashed trail flowing to it from the building.
- **Alert pings:** alerts with a location (base under attack, building lost, point captured) flash a ring on the minimap, red for threats and gold otherwise. Backspace jumps the camera to the latest alert, and the key is listed in the pause menu and the Settings field manual.
- **Settings:** a new Graphics Quality option. Low turns off shadows, ambient occlusion, grass and weather and cuts draw calls from about 2,800 to about 1,000. Medium halves the grass and shortens shadows. High is the full look. A new Reduce Screen Shake toggle controls the camera shake; that setting existed but had no switch.
- **Tutorial:** the step panel covered the Population, Opponents and idle counters that the steps refer to, and long steps spilled their goal line out below the panel. The panel now sits under the top bar, grows to fit, and shows the goal as a separate gold line. The attack step wrongly said A for attack-move; it now says J.
- **Loading screen:** a gilded progress bar and a random tip on every load, covering controls, capture points, veterans, repair and scouting.
- **Main menu:** the painted background drifts slowly, gold motes rise across the realm, a vignette frames it, the title and buttons fade in, and buttons lift on hover.
- **Minimap:** it shows a real top-down picture of the battlefield, taken at match start with units and fog left out. Unexplored areas are shaded lighter so the terrain still reads.
- **Skirmish setup:** rebuilt as a war-council screen, with faction banner cards, a dossier and a tactical map preview.
- **Other screens:** the hero forge preview, skill tree, War Chest and campaign map are reskinned to match.
- **Victory and defeat:** a result ledger on the ornate plate.
- **Campaign map:** the briefing now opens on your next battle with a "Click to march" hint (it used to show whichever region the cursor last crossed), the next battle gently pulses, and sealed regions recede so the path forward stands out.
- **Buttons:** every button uses a forged-bronze frame. The pause menu sits on the ornate plate, and its control list is easier to read.

## Top-10 plan (started 2026-09-27)

1. DONE. Full AI-vs-AI playtests on several maps and difficulties to catch gameplay bugs: stuck units, AI stalls, matches that never end.
2. DONE. Hero progression in battle: the level-up alert exists but nothing ever fires it; wire in-match hero XP and level-ups.
3. DONE. Rendering cost: cut the ~2,800 draw calls in the opening by merging static base dressing.
4. CHECKED. Combat feel audit: attack timing, hit reactions and impact sounds lining up.
5. DONE. Audio atmosphere: per-map ambience and missing sound cues, using only free or generated sound.
6. REVIEWED. Lioraen and Vorthak units: a free material and silhouette pass. The full model rebuild still needs the Hugging Face token run.
7. DONE. Tutorial and first-match onboarding review.
8. DONE (all working). Verify recent features in real play: Medium quality, Backspace jump, veteran flare.
9. DONE. Polish known weak spots: collapse dust at normal zoom and pale grain on the food site.
10. DONE. Campaign map screen polish with what is available now; the painted map still needs the token.

- **Lioraen and Vorthak units (plan item 6):** reviewed up close; they read clearly at play zoom with team colours and silhouettes. A worthwhile upgrade needs the model rebuild, which still waits on the Hugging Face token run.

## Second plan (started 2026-09-27)

1. DONE. Matches now reach a result. AI-vs-AI games ran 20 minutes with no winner. Three causes, all fixed:
   - **Food ran out for good around minute 8.** Each base had one 600-food node and every unit costs food. Food nodes now hold 1,200, and every finished house adds 2 food every 4 seconds. This applies to the player too.
   - **Soldiers reaching an enemy base stood idle beside buildings.** Idle AI soldiers near a hostile building now attack the nearest one.
   - **A lone construction site kept a beaten side alive**, because attackers ignored unbuilt sites. The AI now targets them too.
   - Attack waves also stop growing after the third, so the AI keeps attacking.
   A Hard Vorthak AI now wins a 20-minute soak at about minute 18.
2. DONE. A Vorthak player on Hollowspan now gets the scorched holdfast (Lioraen already had its grove). Noted for Codex: the Vorthak worker (Bondservant) selection portrait shows a T-posed model instead of portrait art.
3. DONE. Units walking in place: a unit pressing into a crowd of its own soldiers or an obstacle the pathfinder does not know about used to walk on the spot for the rest of the match. A stall watchdog now side-steps it (alternating sides) and requests a fresh route when it has not moved 35 cm in 1.5 s. Stuck units in a 10-minute AI soak fell from 4 to 1.
4. DONE. Frame cost: a feature-by-feature GPU bisect showed the ground shader alone cost about 11 ms of GPU per frame at 1600x900, mostly the Vorthak/Lioraen zone noise and cracks being computed on every pixel of the map. Zones and the ford now skip that work outside their area, and the broad low-frequency fields use two noise octaves instead of four. GPU time for the whole frame dropped from about 16.7 ms to about 12 ms with no visible change.

## Still open

- **Draw calls:** about 2,800 draw calls in the opening. Instancing the decor would be the next rendering win.
