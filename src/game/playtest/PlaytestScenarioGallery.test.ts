import { describe, expect, it } from "vitest";
import { PLAYTEST_FAST_TOUR_SCENARIO_IDS, PLAYTEST_SCENARIO_GROUPS, PLAYTEST_SCENARIOS, scenarioById } from "./PlaytestScenarioGallery";
import { isPrivatePlaytestToolsEnabledForPosture } from "./PrivatePlaytestTools";

describe("PlaytestScenarioGallery", () => {
  it("defines the required private hub groups and unique scenario entries", () => {
    expect(PLAYTEST_SCENARIO_GROUPS.map((group) => group.id)).toEqual([
      "campaign_shell",
      "first_session",
      "battle_shell",
      "lume",
      "meta"
    ]);

    const ids = PLAYTEST_SCENARIOS.map((scenario) => scenario.id);
    const screenshotIds = PLAYTEST_SCENARIOS.map((scenario) => scenario.screenshotId);
    expect(new Set(ids).size).toBe(ids.length);
    expect(new Set(screenshotIds).size).toBe(screenshotIds.length);

    for (const scenario of PLAYTEST_SCENARIOS) {
      expect(scenario.purpose.trim().length, scenario.id).toBeGreaterThan(20);
      expect(scenario.expectedVisibleUi.length, scenario.id).toBeGreaterThan(0);
      expect(scenario.expectedAbsentUi.length, scenario.id).toBeGreaterThan(0);
      expect(scenario.manualReviewQuestion).toContain("?");
      expect(scenario.screenshotId).toMatch(/^v0100-hub-[a-z0-9-]+$/u);
      expect(scenario.saveIsolationRule).toContain("no rewards, XP, progress, Retinue, relic, or reputation mutation is kept");
    }
  });

  it("covers every requested gallery family and one-click review target", () => {
    [
      "campaign_fresh",
      "campaign_salto_selected",
      "campaign_locked_mission",
      "campaign_stronghold_tab",
      "campaign_hero_tab",
      "campaign_inventory_tab",
      "campaign_intel_tab",
      "campaign_reputation_tab",
      "ascendant_creation",
      "tutorial_proving_grounds",
      "salto_outskirts_start",
      "battle_ordinary_start",
      "battle_selected_hero",
      "battle_selected_worker",
      "battle_selected_squad",
      "battle_selected_building",
      "battle_contested_site",
      "battle_fog_minimap",
      "battle_notification_priority",
      "lume_launch_demo",
      "lume_first_link",
      "lume_overlay_hidden",
      "lume_overlay_auto",
      "lume_overlay_always",
      "private_demo_results",
      "meta_hero_overview",
      "meta_skills",
      "meta_equipment",
      "meta_relics",
      "meta_retinue_ready",
      "meta_retinue_recovering",
      "meta_stronghold_preview",
      "ordinary_results",
      "defeat_results"
    ].forEach((id) => expect(scenarioById(id), `missing ${id}`).toBeDefined());
  });

  it("keeps the eight-minute visual tour deterministic and private", () => {
    expect(PLAYTEST_FAST_TOUR_SCENARIO_IDS).toEqual([
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
    ]);
    for (const scenarioId of PLAYTEST_FAST_TOUR_SCENARIO_IDS) {
      expect(scenarioById(scenarioId), scenarioId).toBeDefined();
    }
  });

  it("hides private tools in public posture and enables them in dev or private package posture", () => {
    expect(isPrivatePlaytestToolsEnabledForPosture(false, false)).toBe(false);
    expect(isPrivatePlaytestToolsEnabledForPosture(false, undefined)).toBe(false);
    expect(isPrivatePlaytestToolsEnabledForPosture(true, false)).toBe(true);
    expect(isPrivatePlaytestToolsEnabledForPosture(false, true)).toBe(true);
  });
});
