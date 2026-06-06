# v0.133 Test11 Recording Combat Readability Repair

Status: `POST_MINE_FLOW_GREEN_REPAIRED`

Source reviewed: `C:/Users/barro/Downloads/Recording 2026-06-05 test11.mp4`

The manual recording showed the post-mine sequence reached Objective 8, but the fight was not human-readable enough to finish confidently. The player could reach the Ashen wave, yet the selected state, top-screen chrome, enemy formation size, and combat guidance made the encounter feel unclear and unwinnable.

Observed failures:

- Objective 8 started while the HUD could still imply Worker or Barracks context instead of a fighting squad.
- The top battle shell repeated the full objective chain and competed with the resource row and current objective strip.
- Too many red units remained visible for a four-attacker review wave, making the pressure look much larger than the required proof.
- The active Ashen attackers were not all target-marked, so the player had to infer which red units mattered.
- Empty or off-target box selection during the fight could erase the already-valid defender selection.

Implemented repair:

- Objective 8 now stages only the active four-unit Ashen wave and the intended defender line in a readable road-lane fight.
- Non-wave red reserves and non-defender friendly reserves are hidden from the player-facing review wave without changing stable IDs or importing art.
- The fight now hands off to the defender squad automatically at wave launch and records `combat_defender_handoff`.
- Empty combat box-select attempts preserve the defender squad and record `box_select_empty_preserved_defenders`.
- The visible `Attack` button now issues a wave-defense order that keeps defenders assigned across all live Ashen attackers instead of stopping after one target falls.
- A scaled Objective 8 Attack-button hit zone preserves the visible button path in maximized packaged windows instead of treating the click as empty terrain.
- Non-review combat reserves are moved offstage as well as marked hidden before and during the wave, so wide or maximized windows show the intended four-attacker fight instead of a misleading reserve wall.
- The four revealed Ashen attackers use review-slice health and damage values, keeping the ordinary combat simulation intact while making the instructed defender group able to win.
- All active Ashen wave units are marked as targets during Objective 8.
- The redundant top battle objective banner was removed; the in-scene HUD owns battle guidance.
- Objective 8 copy now says how many Ashen attackers remain and points the player to the visible `Attack` button or right-click target path.

Scope guard:

- No Godot editor work.
- No generated or imported runtime art.
- No save change.
- No stable-ID change.
- No browser runtime change.
- No full port or final engine choice.
- No v0.134 work.

Required proof remains ordinary player-facing input and normal simulation. Private-harness shortcuts, debug triggers, direct state mutation, fixture-only helper calls, and screenshot-only assertions do not count as human playability evidence.
