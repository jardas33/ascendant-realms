# v0.110 Density Scaling Report

Density rows reuse existing private Playtest Hub/representative battle fixtures. No new units, maps, factions, balance values, stable IDs, saves, or art are added.

| Case | Category | FPS avg | p95 frame | Units | Buildings | Display objects | Labels | DOM | Top phase |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| v0110_empty_static | static | 3.3 | 416.7 | 14 | 3 | 27 | 1 | 678 | HUD DOM |
| v0110_static_hud_minimal | static | 3.3 | 400 | 14 | 3 | 27 | 1 | 678 | Fog simulation |
| v0110_tier_s_density | density | 2.5 | 499.9 | 21 | 4 | 37 | 2 | 810 | Status effects |
| v0110_tier_m_density | density | 2.5 | 550 | 41 | 4 | 56 | 2 | 829 | Movement/pathing |
| v0110_tier_l_density | density | 2 | 666.7 | 63 | 4 | 80 | 4 | 847 | Status effects |
