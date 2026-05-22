import type { ControlBehaviourScenarioProfile } from "./ControlBehaviourScenarioTypes";

export const CONTROL_BEHAVIOUR_SCENARIO_PROFILES: ControlBehaviourScenarioProfile[] = [
  {
    id: "hold_ground_contact_defence",
    name: "Hold Ground Contact Defence",
    mode: "hold_ground",
    purpose: "Confirm Hold Ground fights immediate body-contact threats.",
    expectedEvidence: ["contact attack frame observed", "no chase target required"],
    limitations: ["Uses deterministic combat-system state, not a full human-input battle."]
  },
  {
    id: "hold_ground_distant_threat_refusal",
    name: "Hold Ground Distant Threat Refusal",
    mode: "hold_ground",
    purpose: "Confirm Hold Ground refuses idle distant targets.",
    expectedEvidence: ["no target retained", "no chase target assigned"],
    limitations: ["Does not prove the mode feels exciting; it proves bounded refusal."]
  },
  {
    id: "guard_area_default_local_defence",
    name: "Guard Area Default Local Defence",
    mode: "guard_area",
    purpose: "Confirm the default mode reacquires nearby local threats.",
    expectedEvidence: ["target acquired", "local chase target assigned"],
    limitations: ["Does not tune the default leash."]
  },
  {
    id: "press_attack_bounded_pursuit",
    name: "Press Attack Bounded Pursuit",
    mode: "press_attack",
    purpose: "Confirm Press Attack pursues farther than Guard Area but still refuses map-wide chase.",
    expectedEvidence: ["press-leash target acquired", "far target refused"],
    limitations: ["Does not judge whether the current leash is fun or optimal."]
  },
  {
    id: "explicit_attack_overrides_mode",
    name: "Explicit Attack Overrides Mode",
    mode: "hold_ground",
    purpose: "Confirm an explicit attack order overrides passive mode refusal.",
    expectedEvidence: ["explicit target retained", "pursuit target assigned"],
    limitations: ["The lab does not replace browser click attack coverage."]
  },
  {
    id: "move_away_suppression",
    name: "Move-Away Suppression",
    mode: "press_attack",
    purpose: "Confirm a move-away order suppresses immediate reacquisition and avoids same-frame snap-back.",
    expectedEvidence: ["move target retained", "same-frame reacquisition suppressed"],
    limitations: ["Pathfinding blockage and human perception still need browser/manual checks."]
  },
  {
    id: "post_kill_adjacent_reacquisition",
    name: "Post-Kill Adjacent Reacquisition",
    mode: "guard_area",
    purpose: "Confirm melee units can reacquire another adjacent target after a kill.",
    expectedEvidence: ["first target killed", "second contact target damaged"],
    limitations: ["Uses compact deterministic combat ticks."]
  },
  {
    id: "enemy_melee_building_aggro",
    name: "Enemy Melee Building Aggro",
    mode: "not_applicable",
    purpose: "Confirm enemy melee units can attack a local hostile building footprint.",
    expectedEvidence: ["building target damaged", "local building aggro only"],
    limitations: ["Does not add global enemy building chase or judge wave balance."]
  },
  {
    id: "attack_hover_tolerance_boundary",
    name: "Attack Hover Tolerance Boundary",
    mode: "guard_area",
    purpose: "Confirm attack hover tolerance reaches the visible enemy footprint but not empty nearby terrain.",
    expectedEvidence: ["visible body edge resolves", "nearby empty terrain does not resolve"],
    limitations: ["Cursor rendering and left-click attack remain browser-level coverage."]
  },
  {
    id: "manual_proxy_hold_ground_adjacent_followup",
    name: "Manual Proxy Hold Ground Adjacent Follow-Up",
    mode: "hold_ground",
    purpose: "Proxy Emmanuel's two-adjacent-enemy Hold Ground report after the first enemy dies.",
    expectedEvidence: ["first adjacent enemy killed", "second adjacent enemy damaged", "distant idle enemy refused"],
    limitations: ["Deterministic proxy only; it does not replace Emmanuel's human retest."]
  },
  {
    id: "manual_proxy_group_retreat_resume",
    name: "Manual Proxy Group Retreat And Resume",
    mode: "press_attack",
    purpose: "Proxy group retreat near multiple enemies and confirm combat resumes after suppression expires.",
    expectedEvidence: ["retreat command accepted", "reacquisition suppressed", "combat resumes after suppression"],
    limitations: ["Does not prove pathing feel or collision readability under human input."]
  },
  {
    id: "combat_edge_hero_three_melee_followup",
    name: "Combat Edge Hero Versus Three Melee",
    mode: "hold_ground",
    purpose: "Confirm a hero does not idle after killing the first enemy with two more melee enemies adjacent.",
    expectedEvidence: ["first melee enemy killed", "follow-up adjacent enemy damaged"],
    limitations: ["Uses compact combat ticks rather than a full battle wave."]
  },
  {
    id: "combat_edge_two_friendlies_three_enemies",
    name: "Combat Edge Two Friendlies Versus Three Enemies",
    mode: "guard_area",
    purpose: "Confirm multiple friendly units engage nearby enemies without requiring a single explicit target.",
    expectedEvidence: ["multiple enemies damaged", "friendlies keep local engagement"],
    limitations: ["Does not rebalance group focus fire or enemy wave size."]
  },
  {
    id: "combat_edge_building_aggro_matrix",
    name: "Combat Edge Building Aggro Matrix",
    mode: "not_applicable",
    purpose: "Confirm local building aggro stays local and melee building contact remains valid.",
    expectedEvidence: ["local building damaged", "distant building not chased"],
    limitations: ["Ranged projectile building aggro is verified in CombatSystem tests to avoid Phaser view setup in the lab."]
  },
  {
    id: "combat_edge_mode_difference_matrix",
    name: "Combat Edge Mode Difference Matrix",
    mode: "mixed",
    purpose: "Confirm Hold, Guard, and Press keep their intended pursuit differences.",
    expectedEvidence: ["Hold refuses distant", "Guard uses local leash", "Press uses bounded pursuit"],
    limitations: ["Does not tune leash distances or player feel."]
  },
  {
    id: "group_mixed_mode_application",
    name: "Group Mixed Mode Application",
    mode: "mixed",
    purpose: "Confirm mixed selected units report mixed state and normalize when a group mode is applied.",
    expectedEvidence: ["mixed detected", "group mode applied count"],
    limitations: ["HUD click handling is covered separately by browser tests."]
  },
  {
    id: "attack_cursor_intent_integrity",
    name: "Attack Cursor/Intent Integrity",
    mode: "guard_area",
    purpose: "Track the browser-covered attack hover and left-click attack intent contract.",
    expectedEvidence: ["selected units plus valid enemy should expose attack intent", "empty click should not attack"],
    limitations: ["This lab records the contract and paired tests; real cursor state is verified by Playwright."]
  },
  {
    id: "hud_minimap_selection_regression",
    name: "HUD/Minimap/Selection Regression Protection",
    mode: "not_applicable",
    purpose: "Track the browser-covered HUD, minimap, marquee, and hero-select regression contract.",
    expectedEvidence: ["marquee cleanup", "minimap movement", "hero selection refresh"],
    limitations: ["This lab records the contract and paired tests; DOM/canvas interaction is verified by Playwright."]
  }
];
