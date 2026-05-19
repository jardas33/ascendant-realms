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
