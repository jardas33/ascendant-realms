import { V0103_PERFORMANCE_SCENARIOS, type PrivatePerformanceScenarioManifestEntry } from "./PrivatePerformanceProfiler";

export type PlaytestScenarioGroupId =
  | "campaign_shell"
  | "first_session"
  | "battle_shell"
  | "lume"
  | "meta"
  | "performance_lab";

export type PlaytestScenarioLaunchKind =
  | "campaign"
  | "hero_creation"
  | "battle"
  | "lume_battle"
  | "hero_progression"
  | "results"
  | "main_menu";

export interface PlaytestScenarioGroupDefinition {
  id: PlaytestScenarioGroupId;
  title: string;
}

export interface PlaytestScenarioDefinition {
  id: string;
  groupId: PlaytestScenarioGroupId;
  title: string;
  launchKind: PlaytestScenarioLaunchKind;
  purpose: string;
  expectedVisibleUi: string[];
  expectedAbsentUi: string[];
  manualReviewQuestion: string;
  screenshotId: string;
  automatedCoverage: string;
  launchContext: string;
  saveIsolationRule: string;
}

export const PLAYTEST_SCENARIO_GROUPS: PlaytestScenarioGroupDefinition[] = [
  { id: "campaign_shell", title: "Campaign Shell" },
  { id: "first_session", title: "First Session" },
  { id: "battle_shell", title: "Battle Shell" },
  { id: "lume", title: "Lume" },
  { id: "meta", title: "Meta" },
  { id: "performance_lab", title: "Performance Lab" }
];

const NO_SAVE_RULE =
  "Private hub preview only. Restore the pre-hub local save before returning; no rewards, XP, progress, Retinue, relic, or reputation mutation is kept.";

export const PLAYTEST_SCENARIOS: PlaytestScenarioDefinition[] = [
  scenario("main_menu", "first_session", "Main menu sample", "main_menu", "Review the current private-package main menu without starting progression.", ["main-menu", "menu-new-campaign", "menu-playtest-hub"], ["private-demo-actions"], "Does the first screen make the play path obvious?", "v0100-hub-main-menu", "smoke private hub visibility", "private main-menu preview", NO_SAVE_RULE),
  scenario("campaign_fresh", "campaign_shell", "Fresh campaign map", "campaign", "Open a fresh safe campaign preview with the first node selected.", ["campaign-map", "campaign-node-border_village", "campaign-selected-panel"], ["results-panel"], "Is the map readable at a glance?", "v0100-hub-campaign-fresh", "visual QA campaign shell gallery", "campaign map preview with Salto selected", NO_SAVE_RULE),
  scenario("campaign_salto_selected", "campaign_shell", "Salto selected", "campaign", "Show Salto Outskirts selected with the primary action visible.", ["campaign-selected-panel", "campaign-start-node"], ["private-demo-actions"], "Is Salto's first action obvious?", "v0100-hub-salto-selected", "smoke private hub launcher", "campaign map preview selecting border_village", NO_SAVE_RULE),
  scenario("campaign_locked_mission", "campaign_shell", "Locked mission selected", "campaign", "Preview a locked Aether Well mission without weakening prerequisites.", ["campaign-node-aether_well_ruins", "campaign-selected-panel"], ["private-demo-actions"], "Is the lock reason readable without feeling broken?", "v0100-hub-locked-mission", "smoke private hub lock guard", "campaign map preview selecting aether_well_ruins", NO_SAVE_RULE),
  scenario("campaign_stronghold_tab", "campaign_shell", "Stronghold tab", "campaign", "Open the campaign Stronghold tab for hierarchy review.", ["campaign-tab-panel-stronghold", "stronghold-overview"], ["results-panel"], "Can the stronghold state be scanned quickly?", "v0100-hub-stronghold-tab", "visual QA campaign tab gallery", "campaign map preview on stronghold tab", NO_SAVE_RULE),
  scenario("campaign_hero_tab", "campaign_shell", "Hero tab", "campaign", "Open the campaign Hero and Retinue summary tab.", ["campaign-tab-panel-hero", "retinue-panel"], ["results-panel"], "Are hero and Retinue next steps clear?", "v0100-hub-hero-tab", "visual QA campaign tab gallery", "campaign map preview on hero tab", NO_SAVE_RULE),
  scenario("campaign_inventory_tab", "campaign_shell", "Inventory tab", "campaign", "Open the campaign Inventory action tab.", ["campaign-tab-panel-inventory", "campaign-inventory-inline"], ["results-panel"], "Is the inventory call-to-action clear?", "v0100-hub-inventory-tab", "visual QA campaign tab gallery", "campaign map preview on inventory tab", NO_SAVE_RULE),
  scenario("campaign_intel_tab", "campaign_shell", "Intel tab", "campaign", "Open the campaign Intel tab with route and rival context.", ["campaign-tab-panel-intel", "campaign-chapter-border_marches"], ["results-panel"], "Does Intel feel useful rather than verbose?", "v0100-hub-intel-tab", "visual QA campaign tab gallery", "campaign map preview on intel tab", NO_SAVE_RULE),
  scenario("campaign_reputation_tab", "campaign_shell", "Reputation tab", "campaign", "Open reputation standings in the campaign shell.", ["campaign-tab-panel-reputation"], ["results-panel"], "Are reputation standings understandable?", "v0100-hub-reputation-tab", "visual QA campaign tab gallery", "campaign map preview on reputation tab", NO_SAVE_RULE),
  scenario("ascendant_creation", "first_session", "Ascendant creation", "hero_creation", "Review class, origin, and hero review choices.", ["hero-creation", "hero-creation-step-class", "hero-creation-step-origin"], ["results-panel"], "Can a class and origin be compared within seconds?", "v0100-hub-ascendant-creation", "visual QA first-session gallery", "hero creation preview", NO_SAVE_RULE),
  scenario("tutorial_proving_grounds", "first_session", "Tutorial / Proving Grounds", "battle", "Launch the protected Tutorial route with no rewards.", ["battle-hud", "tutorial-panel"], ["private-demo-finish"], "Is the tutorial guidance readable enough?", "v0100-hub-tutorial", "smoke tutorial no-save guard", "tutorial battle preview", NO_SAVE_RULE),
  scenario("salto_outskirts_start", "first_session", "Salto Outskirts start", "battle", "Launch the first real battle as a no-save private preview.", ["battle-hud", "battle-objectives"], ["private-demo-finish"], "Does the first battle start state explain what to do?", "v0100-hub-salto-battle", "hosted smoke private hub battle", "Salto Outskirts battle preview", NO_SAVE_RULE),
  scenario("battle_ordinary_start", "battle_shell", "Ordinary battle start", "battle", "Open an ordinary battle start state for HUD and minimap review.", ["battle-hud", "battle-minimap"], ["private-demo-finish"], "Is the HUD readable before any action?", "v0100-hub-battle-start", "visual QA battle shell gallery", "ordinary private battle preview", NO_SAVE_RULE),
  scenario("battle_selected_hero", "battle_shell", "Selected hero", "battle", "Select the hero and show command/identity panels.", ["battle-hero-panel", "unit-order-summary"], ["private-demo-finish"], "Is the selected hero obvious?", "v0100-hub-selected-hero", "visual QA selected units", "battle preview with hero selected", NO_SAVE_RULE),
  scenario("battle_selected_worker", "battle_shell", "Selected Worker", "battle", "Select a Worker and show utility command posture.", ["battle-selection-card", "command-panel"], ["private-demo-finish"], "Are Worker commands understandable?", "v0100-hub-selected-worker", "visual QA selected units", "battle preview with Worker selected", NO_SAVE_RULE),
  scenario("battle_selected_squad", "battle_shell", "Selected squad", "battle", "Select a small player squad and show group command posture.", ["battle-selection-card", "unit-order-summary"], ["private-demo-finish"], "Does multi-select communicate count and intent?", "v0100-hub-selected-squad", "visual QA selected units", "battle preview with squad selected", NO_SAVE_RULE),
  scenario("battle_selected_building", "battle_shell", "Selected building", "battle", "Select Command Hall and show production/rally posture.", ["battle-selection-card", "command-panel"], ["private-demo-finish"], "Are building actions legible?", "v0100-hub-selected-building", "visual QA selected buildings", "battle preview with building selected", NO_SAVE_RULE),
  scenario("battle_contested_site", "battle_shell", "Contested site", "battle", "Show a capture site in a contested or emphasized state.", ["battle-resource-sites", "battle-minimap"], ["private-demo-finish"], "Is site ownership pressure readable?", "v0100-hub-contested-site", "visual QA capture sites", "battle preview focused on resource site", NO_SAVE_RULE),
  scenario("battle_fog_minimap", "battle_shell", "Fog/minimap sample", "battle", "Center the camera for fog and minimap readability review.", ["battle-minimap", "battle-objectives"], ["private-demo-finish"], "Is the minimap and fog posture readable enough?", "v0100-hub-fog-minimap", "visual QA fog and minimap", "battle preview with camera focus marker", NO_SAVE_RULE),
  scenario("battle_notification_priority", "battle_shell", "Notification-priority sample", "battle", "Show a concise high-priority command/status line.", ["battle-status", "battle-hud"], ["private-demo-finish"], "Are urgent and routine messages distinct?", "v0100-hub-notification-priority", "visual QA battle feedback", "battle preview with priority notification", NO_SAVE_RULE),
  scenario("lume_launch_demo", "lume", "Launch Aether Well Lume Demo", "lume_battle", "Open the existing private Aether Well Lume demo.", ["private-playtest-demo-warning", "lume-network-status"], ["results-panel"], "Can the Lume task be understood quickly?", "v0100-hub-lume-demo", "smoke private Lume demo", "Aether Well Lume private demo", NO_SAVE_RULE),
  scenario("lume_first_link", "lume", "First-link activation sample", "lume_battle", "Open the Lume demo with the first link already awakened for visual review.", ["lume-links-progress", "private-demo-finish"], ["results-panel"], "Is the awakened link state clear?", "v0100-hub-lume-first-link", "visual QA Lume flow", "Aether Well Lume active-link sample", NO_SAVE_RULE),
  scenario("lume_overlay_hidden", "lume", "Hidden overlay sample", "lume_battle", "Open the Lume demo with link rendering hidden.", ["lume-visibility-controls", "private-demo-actions"], ["results-panel"], "Is Hidden mode clearly quieter?", "v0100-hub-lume-hidden", "visual QA Lume flow", "Lume overlay hidden sample", NO_SAVE_RULE),
  scenario("lume_overlay_auto", "lume", "Auto overlay sample", "lume_battle", "Open the Lume demo in default Auto overlay mode.", ["lume-visibility-controls", "private-demo-actions"], ["results-panel"], "Does Auto help without clutter?", "v0100-hub-lume-auto", "visual QA Lume flow", "Lume overlay auto sample", NO_SAVE_RULE),
  scenario("lume_overlay_always", "lume", "Always overlay sample", "lume_battle", "Open the Lume demo with all eligible links visible.", ["lume-visibility-controls", "private-demo-actions"], ["results-panel"], "Is Always mode useful for inspection?", "v0100-hub-lume-always", "visual QA Lume flow", "Lume overlay always sample", NO_SAVE_RULE),
  scenario("private_demo_results", "lume", "Private-demo Results", "results", "Open the compact private-demo Results summary.", ["private-demo-lume-summary", "private-demo-primary-actions"], ["results-primary-actions"], "Does private-demo Results make no-save status obvious?", "v0100-hub-private-results", "visual QA private results", "private demo Results fixture", NO_SAVE_RULE),
  scenario("meta_hero_overview", "meta", "Hero overview", "hero_progression", "Open the Hero overview with seeded private progression data.", ["hero-overview", "skills-panel"], ["results-panel"], "Is the hero overview a useful first card?", "v0100-hub-hero-overview", "visual QA meta gallery", "hero progression preview", NO_SAVE_RULE),
  scenario("meta_skills", "meta", "Skills", "hero_progression", "Open the skills section with points and purchased nodes.", ["skills-panel", "skill-tree-grid"], ["results-panel"], "Are available and locked skill states clear?", "v0100-hub-skills", "visual QA meta gallery", "hero skills preview", NO_SAVE_RULE),
  scenario("meta_equipment", "meta", "Equipment", "hero_progression", "Open the equipped loadout and comparison posture.", ["equipment-panel", "inventory-list"], ["results-panel"], "Is equipped versus stored gear clear?", "v0100-hub-equipment", "visual QA meta gallery", "equipment preview", NO_SAVE_RULE),
  scenario("meta_relics", "meta", "Relics", "hero_progression", "Open relic-equipped hero progression for build identity review.", ["equipment-panel", "build-identity-panel"], ["results-panel"], "Do relic effects and synergy read clearly?", "v0100-hub-relics", "visual QA meta gallery", "relic preview", NO_SAVE_RULE),
  scenario("meta_retinue_ready", "meta", "Retinue Ready", "campaign", "Open a ready Retinue preview on the Campaign Hero tab.", ["retinue-panel", "campaign-tab-panel-hero"], ["results-panel"], "Can ready reserves be understood quickly?", "v0100-hub-retinue-ready", "visual QA retinue gallery", "Retinue ready preview", NO_SAVE_RULE),
  scenario("meta_retinue_recovering", "meta", "Retinue Recovering", "campaign", "Open a recovering Retinue preview with deployment blocked.", ["retinue-panel", "campaign-tab-panel-hero"], ["results-panel"], "Is recovering status readable and non-actionable?", "v0100-hub-retinue-recovering", "visual QA retinue gallery", "Retinue recovery preview", NO_SAVE_RULE),
  scenario("meta_stronghold_preview", "meta", "Stronghold preview", "campaign", "Open the Stronghold tab with available and locked upgrades.", ["stronghold-overview", "campaign-tab-panel-stronghold"], ["results-panel"], "Are upgrade costs and locks clear?", "v0100-hub-stronghold-preview", "visual QA stronghold gallery", "Stronghold preview", NO_SAVE_RULE),
  scenario("ordinary_results", "meta", "Ordinary Results", "results", "Open a normal victory Results fixture.", ["results-overview", "results-primary-actions"], ["private-demo-primary-actions"], "Is the ordinary Results summary concise enough?", "v0100-hub-ordinary-results", "visual QA normal results", "ordinary victory Results fixture", NO_SAVE_RULE),
  scenario("defeat_results", "meta", "Defeat Results", "results", "Open a normal defeat Results fixture.", ["results-overview", "results-primary-actions"], ["private-demo-primary-actions"], "Does defeat explain next action without noise?", "v0100-hub-defeat-results", "visual QA normal results", "ordinary defeat Results fixture", NO_SAVE_RULE),
  ...V0103_PERFORMANCE_SCENARIOS.map((entry) =>
    scenario(
      entry.launchScenarioId,
      "performance_lab",
      entry.title,
      performanceLaunchKind(entry),
      entry.purpose,
      entry.expectedVisibleUi,
      ["results-primary-actions"],
      "Which visible cost feels most likely to create clutter or sluggishness?",
      `v0103-${entry.id.replaceAll("_", "-")}`,
      "v0.103 private performance lab",
      `private performance lab: ${entry.title}`,
      entry.saveIsolationRule
    )
  )
];

export const PLAYTEST_FAST_TOUR_SCENARIO_IDS = [
  "main_menu",
  "ascendant_creation",
  "campaign_fresh",
  "campaign_salto_selected",
  "battle_selected_hero",
  "battle_selected_worker",
  "lume_first_link",
  "private_demo_results",
  "meta_retinue_ready",
  "campaign_fresh"
] as const;

export function scenarioById(id: string): PlaytestScenarioDefinition | undefined {
  return PLAYTEST_SCENARIOS.find((scenario) => scenario.id === id);
}

function scenario(
  id: string,
  groupId: PlaytestScenarioGroupId,
  title: string,
  launchKind: PlaytestScenarioLaunchKind,
  purpose: string,
  expectedVisibleUi: string[],
  expectedAbsentUi: string[],
  manualReviewQuestion: string,
  screenshotId: string,
  automatedCoverage: string,
  launchContext: string,
  saveIsolationRule: string
): PlaytestScenarioDefinition {
  return {
    id,
    groupId,
    title,
    launchKind,
    purpose,
    expectedVisibleUi,
    expectedAbsentUi,
    manualReviewQuestion,
    screenshotId,
    automatedCoverage,
    launchContext,
    saveIsolationRule
  };
}

function performanceLaunchKind(entry: PrivatePerformanceScenarioManifestEntry): PlaytestScenarioLaunchKind {
  if (entry.group === "campaign") {
    return "campaign";
  }
  if (entry.group === "results") {
    return "results";
  }
  if (entry.group === "lume") {
    return "lume_battle";
  }
  return "battle";
}
