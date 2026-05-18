# v0.13 Automated Scenario Profile Catalog

These are deterministic automated evidence profiles, not human tester reports.

## Baseline Cautious

- Behavior model: Uses the Safe Beginner script with no persistent Stronghold or retinue power.
- Route assumptions: No deliberate optimization; Read objectives; React to warnings; Preserve units.
- Scripts: safe_beginner
- Stronghold/profile rows: no_stronghold
- Nodes: border_village, old_stone_road, aether_well_ruins, bandit_hillfort, ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Stable openings; Good first-wave survival; Clear baseline for early defeat checks.
- Expected weaknesses: Slower clears; May time out if final assault is delayed.
- Watchpoint relevance: early_defeats, pressure_fairness, ashen_outpost_stability

## No-Retinue

- Behavior model: Runs Safe Beginner through the non-retinue Stronghold profiles.
- Route assumptions: Avoid carried veteran power; Allow normal non-retinue Stronghold paths; Check fairness without saved units.
- Scripts: safe_beginner
- Stronghold/profile rows: no_stronghold, training_yard_path, defensive_watch_post_path, economy_quartermaster_path, tier_two_quartermaster_path, chapel_corner_path, ranger_paths_path, waystation_shrine_attunement
- Nodes: border_village, old_stone_road, aether_well_ruins, bandit_hillfort, ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Separates campaign fairness from retinue carryover; Shows whether normal upgrades are enough.
- Expected weaknesses: Can expose milestone timeouts; Does not test veteran power fantasy.
- Watchpoint relevance: early_defeats, ashen_outpost_stability, cinderfen_crossing_fairness, cinderfen_watch_fairness

## One-Veteran

- Behavior model: Runs Safe Beginner with the Veteran Militia and Veteran Ranger retinue profiles.
- Route assumptions: Bring one meaningful veteran; Do not stack every carryover advantage; Check whether one veteran feels earned.
- Scripts: safe_beginner
- Stronghold/profile rows: retinue_veteran_militia, retinue_veteran_ranger
- Nodes: ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Modest carryover help; Good comparison against no-retinue baseline.
- Expected weaknesses: Single-veteran differences can be narrow; Does not test max-stacked power.
- Watchpoint relevance: retinue_training_yard_ii, ashen_outpost_stability, cinderfen_crossing_fairness

## Mixed-Veterans

- Behavior model: Runs Safe Beginner and Fast Army through the Mixed Veterans profile.
- Route assumptions: Use a normal experienced-player carryover setup; Do not deliberately max all advantages.
- Scripts: safe_beginner, fast_army
- Stronghold/profile rows: retinue_mixed_veterans
- Nodes: ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Shows ordinary veteran carryover strength; Highlights whether mixed veterans become mandatory.
- Expected weaknesses: Can blur cautious and aggressive play if reviewed without route notes.
- Watchpoint relevance: retinue_training_yard_ii, fast_army, ashen_outpost_stability

## Retinue + Training Yard II

- Behavior model: Runs all three existing scripts through the Retinue + Training Yard II profile.
- Route assumptions: Deliberately stack the known strong profile; Check for trivialization across Ashen and Cinderfen.
- Scripts: safe_beginner, greedy_economy, fast_army
- Stronghold/profile rows: retinue_training_yard_path
- Nodes: border_village, old_stone_road, aether_well_ruins, bandit_hillfort, ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Strongest earned-power profile; Best stress test for trivialization.
- Expected weaknesses: Can look too clean in automation while still feeling earned to humans.
- Watchpoint relevance: retinue_training_yard_ii, ashen_outpost_stability, cinderfen_crossing_fairness, cinderfen_watch_fairness

## Greedy Economy

- Behavior model: Runs Greedy Economy across the full Stronghold/retinue matrix.
- Route assumptions: Prioritize resources and value; Delay conversion into army; Check whether timeouts feel like risk or weakness.
- Scripts: greedy_economy
- Stronghold/profile rows: no_stronghold, training_yard_path, defensive_watch_post_path, economy_quartermaster_path, tier_two_quartermaster_path, chapel_corner_path, ranger_paths_path, retinue_veteran_militia, retinue_veteran_ranger, retinue_mixed_veterans, retinue_training_yard_path, retinue_quartermaster_path, waystation_shrine_attunement
- Nodes: border_village, old_stone_road, aether_well_ruins, bandit_hillfort, ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: High resource ceiling; Useful pressure test for conversion timing.
- Expected weaknesses: Timeout prone; Can confuse players if surplus resources do not become army pressure.
- Watchpoint relevance: greedy_economy, pressure_fairness, cinderfen_crossing_fairness, cinderfen_watch_fairness

## Fast Army

- Behavior model: Runs Fast Army across the full Stronghold/retinue matrix.
- Route assumptions: Build quickly; Push objectives early; Accept higher risk for clear speed.
- Scripts: fast_army
- Stronghold/profile rows: no_stronghold, training_yard_path, defensive_watch_post_path, economy_quartermaster_path, tier_two_quartermaster_path, chapel_corner_path, ranger_paths_path, retinue_veteran_militia, retinue_veteran_ranger, retinue_mixed_veterans, retinue_training_yard_path, retinue_quartermaster_path, waystation_shrine_attunement
- Nodes: border_village, old_stone_road, aether_well_ruins, bandit_hillfort, ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Fast clear speed; Good probe for Cinderfen trivialization.
- Expected weaknesses: Can fail outside the speed-friendly slice; May skip pressure before it proves noticeability.
- Watchpoint relevance: fast_army, pressure_fairness, cinderfen_crossing_fairness, cinderfen_watch_fairness

## Pressure-Ignoring

- Behavior model: Uses Fast Army on pressure-enabled Cinderfen nodes as the current no-new-script proxy.
- Route assumptions: Prioritize winning quickly over reacting to pressure warnings; Check whether pressure can be bypassed.
- Scripts: fast_army
- Stronghold/profile rows: no_stronghold, retinue_training_yard_path
- Nodes: cinderfen_crossing, cinderfen_watch
- Expected strengths: Reveals whether warnings are late or avoidable; Shows speed versus pressure interaction.
- Expected weaknesses: Cannot model human attention directly; Does not prove warnings were noticed.
- Watchpoint relevance: pressure_fairness, fast_army, cinderfen_crossing_fairness, cinderfen_watch_fairness

## Objective-Rush

- Behavior model: Uses Fast Army across Ashen and Cinderfen watchpoint nodes with baseline and strong stacked profiles.
- Route assumptions: Push the win condition early; Do not fully stabilize every side objective first.
- Scripts: fast_army
- Stronghold/profile rows: no_stronghold, retinue_training_yard_path
- Nodes: ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Finds speed/trivialization risks; Separates objective race from economy greed.
- Expected weaknesses: Can produce legitimate losses if the rush is reckless; Does not test slow readability.
- Watchpoint relevance: fast_army, retinue_training_yard_ii, ashen_outpost_stability

## Safe Beginner

- Behavior model: Runs Safe Beginner across the full Stronghold/retinue matrix.
- Route assumptions: Use the safest existing script as a structural fairness reference; Compare against every profile.
- Scripts: safe_beginner
- Stronghold/profile rows: no_stronghold, training_yard_path, defensive_watch_post_path, economy_quartermaster_path, tier_two_quartermaster_path, chapel_corner_path, ranger_paths_path, retinue_veteran_militia, retinue_veteran_ranger, retinue_mixed_veterans, retinue_training_yard_path, retinue_quartermaster_path, waystation_shrine_attunement
- Nodes: border_village, old_stone_road, aether_well_ruins, bandit_hillfort, ashen_outpost, cinderfen_crossing, cinderfen_watch
- Expected strengths: Best structural fairness proxy; Keeps pressure and first-wave checks conservative.
- Expected weaknesses: Can hide speed-route rewards; Cannot judge human boredom or stress.
- Watchpoint relevance: early_defeats, pressure_fairness, cinderfen_crossing_fairness, cinderfen_watch_fairness
