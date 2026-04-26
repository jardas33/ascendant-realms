import { describe, expect, it } from "vitest";
import { createFallbackHeroSave } from "../core/SaveSystem";
import {
  cloneBattleLaunchRequestWithHero,
  createCampaignBattleLaunchRequest,
  createBattleLaunchRequest,
  createSkirmishBattleLaunchRequest,
  resolveBattleLaunchRequest
} from "./BattleLaunchRequest";

describe("BattleLaunchRequest", () => {
  it("creates a deterministic default skirmish launch request", () => {
    const heroSave = createFallbackHeroSave();
    const request = createSkirmishBattleLaunchRequest(heroSave, { sourceId: "main_menu_continue" });

    expect(request).toMatchObject({
      requestId: "skirmish:main_menu_continue:first_claim",
      mode: "skirmish",
      mapId: "first_claim",
      sourceId: "main_menu_continue",
      difficulty: "normal",
      modifiers: []
    });
    expect(request.heroSave).toBe(heroSave);
  });

  it("resolves map and reward table data for the runtime", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), { difficulty: "hard" });
    const resolved = resolveBattleLaunchRequest(request);

    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.map.id).toBe("first_claim");
      expect(resolved.launch.rewardTable.id).toBe("first_claim_rewards");
      expect(resolved.launch.request.difficulty).toBe("hard");
      expect(resolved.launch.request.heroSave.level).toBe(1);
    }
  });

  it("resolves a selected skirmish map and difficulty", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), {
      mapId: "broken_ford",
      difficulty: "easy",
      enemyProfileId: "ashen_covenant",
      sourceId: "skirmish_setup"
    });
    const resolved = resolveBattleLaunchRequest(request);

    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.map.name).toBe("Broken Ford");
      expect(resolved.launch.rewardTable.id).toBe("broken_ford_rewards");
      expect(resolved.launch.request.difficulty).toBe("easy");
      expect(resolved.launch.request.enemyProfileId).toBe("ashen_covenant");
    }
  });

  it("rejects missing maps, missing reward tables, invalid difficulty, and invalid hero data", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), {
      mapId: "missing_map",
      rewardTableId: "missing_rewards"
    });
    const resolved = resolveBattleLaunchRequest({
      ...request,
      heroSave: { ...request.heroSave, level: "bad" } as never,
      difficulty: "nightmare" as never
    });

    expect(resolved.ok).toBe(false);
    if (!resolved.ok) {
      expect(resolved.errors).toEqual(
        expect.arrayContaining([
          "Battle launch request references missing map missing_map.",
          "Battle launch request references missing reward table missing_rewards.",
          "Battle launch request references missing difficulty nightmare.",
          "Battle launch request includes invalid hero save data."
        ])
      );
    }
  });

  it("requires campaign and scenario source ids for future modes", () => {
    const heroSave = createFallbackHeroSave();
    const campaign = resolveBattleLaunchRequest(
      createBattleLaunchRequest(heroSave, { mode: "campaign_node", sourceId: "campaign" })
    );
    const scenario = resolveBattleLaunchRequest(
      createBattleLaunchRequest(heroSave, { mode: "scenario_mission", sourceId: "scenario" })
    );

    expect(campaign.ok).toBe(false);
    expect(scenario.ok).toBe(false);
  });

  it("creates a campaign battle launch from node data", () => {
    const heroSave = createFallbackHeroSave();
    const request = createCampaignBattleLaunchRequest(heroSave, "border_village");
    const resolved = resolveBattleLaunchRequest(request);

    expect(request).toMatchObject({
      mode: "campaign_node",
      campaignNodeId: "border_village",
      mapId: "first_claim",
      difficulty: "easy",
      enemyProfileId: "ashen_covenant"
    });
    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.request.campaignNodeId).toBe("border_village");
      expect(resolved.launch.map.id).toBe("first_claim");
    }
  });

  it("clones an existing request with updated hero progress", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), { sourceId: "results_retry" });
    const nextHero = { ...request.heroSave, level: 3 };
    const cloned = cloneBattleLaunchRequestWithHero(request, nextHero, { sourceId: "retry" });

    expect(cloned.mapId).toBe(request.mapId);
    expect(cloned.rewardTableId).toBe(request.rewardTableId);
    expect(cloned.heroSave.level).toBe(3);
    expect(cloned.sourceId).toBe("retry");
  });
});
