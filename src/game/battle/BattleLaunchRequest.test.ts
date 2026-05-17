import { describe, expect, it } from "vitest";
import { createFallbackHeroSave } from "../core/SaveSystem";
import {
  cloneBattleLaunchRequestWithHero,
  createCampaignBattleLaunchRequest,
  createBattleLaunchRequest,
  createTutorialBattleLaunchRequest,
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
      aiPersonalityId: "balanced_warlord",
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

  it("creates a no-reward tutorial launch request for the Proving Grounds shell", () => {
    const heroSave = createFallbackHeroSave();
    const request = createTutorialBattleLaunchRequest(heroSave);
    const resolved = resolveBattleLaunchRequest(request);

    expect(request).toMatchObject({
      requestId: "tutorial:proving_grounds_basics:first_claim",
      mode: "tutorial",
      mapId: "first_claim",
      sourceId: "proving_grounds_basics",
      difficulty: "story",
      rewardsDisabled: true
    });
    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.request.rewardsDisabled).toBe(true);
      expect(resolved.launch.rewardTable.id).toBe("first_claim_rewards");
    }
  });

  it("resolves a selected skirmish map and difficulty", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), {
      mapId: "broken_ford",
      difficulty: "easy",
      enemyProfileId: "ashen_covenant",
      aiPersonalityId: "raider_rush",
      sourceId: "skirmish_setup"
    });
    const resolved = resolveBattleLaunchRequest(request);

    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.map.name).toBe("Broken Ford");
      expect(resolved.launch.rewardTable.id).toBe("broken_ford_rewards");
      expect(resolved.launch.request.difficulty).toBe("easy");
      expect(resolved.launch.request.enemyProfileId).toBe("ashen_covenant");
      expect(resolved.launch.request.aiPersonalityId).toBe("raider_rush");
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
      difficulty: "nightmare" as never,
      aiPersonalityId: "missing_personality" as never,
      enemyPressurePlanId: "missing_pressure"
    });

    expect(resolved.ok).toBe(false);
    if (!resolved.ok) {
      expect(resolved.errors).toEqual(
        expect.arrayContaining([
          "Battle launch request references missing map missing_map.",
          "Battle launch request references missing reward table missing_rewards.",
          "Battle launch request references missing difficulty nightmare.",
          "Battle launch request references missing AI personality missing_personality.",
          "Battle launch request references missing enemy pressure plan missing_pressure.",
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

  it("rejects tutorial launch requests that can grant rewards", () => {
    const request = createBattleLaunchRequest(createFallbackHeroSave(), {
      mode: "tutorial",
      sourceId: "proving_grounds_basics",
      rewardsDisabled: false
    });
    const resolved = resolveBattleLaunchRequest(request);

    expect(resolved.ok).toBe(false);
    if (!resolved.ok) {
      expect(resolved.errors).toContain("Tutorial battle launch requests must disable rewards.");
    }
  });

  it("creates a campaign battle launch from node data", () => {
    const heroSave = createFallbackHeroSave();
    const request = createCampaignBattleLaunchRequest(heroSave, "border_village");
    const roadRequest = createCampaignBattleLaunchRequest(heroSave, "old_stone_road");
    const resolved = resolveBattleLaunchRequest(request);

    expect(request).toMatchObject({
      mode: "campaign_node",
      campaignNodeId: "border_village",
      mapId: "first_claim",
      difficulty: "easy",
      enemyProfileId: "ashen_covenant",
      aiPersonalityId: "balanced_warlord"
    });
    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.request.campaignNodeId).toBe("border_village");
      expect(resolved.launch.map.id).toBe("first_claim");
    }
    expect(roadRequest.aiPersonalityId).toBe("raider_rush");
  });

  it("carries campaign enemy hero assignments into battle launches", () => {
    const heroSave = createFallbackHeroSave();
    const request = createCampaignBattleLaunchRequest(heroSave, "ashen_outpost");
    const override = createCampaignBattleLaunchRequest(heroSave, "ashen_outpost", { enemyHeroId: "gorak_emberhand" });
    const invalid = resolveBattleLaunchRequest({ ...request, enemyHeroId: "missing_commander" });

    expect(request.enemyHeroId).toBe("captain_malrec");
    expect(override.enemyHeroId).toBe("gorak_emberhand");
    expect(invalid.ok).toBe(false);
    if (!invalid.ok) {
      expect(invalid.errors).toContain("Battle launch request references missing enemy hero missing_commander.");
    }
  });

  it("resolves the first playable Chapter 2 battle map", () => {
    const heroSave = createFallbackHeroSave();
    const request = createCampaignBattleLaunchRequest(heroSave, "cinderfen_crossing");
    const resolved = resolveBattleLaunchRequest(request);

    expect(request).toMatchObject({
      mode: "campaign_node",
      campaignNodeId: "cinderfen_crossing",
      mapId: "cinderfen_causeway",
      difficulty: "normal",
      enemyProfileId: "ashen_covenant",
      aiPersonalityId: "hexfire_cult",
      enemyPressurePlanId: "causeway_contest_pressure"
    });
    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.map.name).toBe("Cinderfen Crossing");
      expect(resolved.launch.rewardTable.id).toBe("cinderfen_causeway_rewards");
      expect(resolved.launch.request.enemyHeroId).toBeUndefined();
    }
  });

  it("resolves the second playable Chapter 2 battle map", () => {
    const heroSave = createFallbackHeroSave();
    const request = createCampaignBattleLaunchRequest(heroSave, "cinderfen_watch");
    const resolved = resolveBattleLaunchRequest(request);

    expect(request).toMatchObject({
      mode: "campaign_node",
      campaignNodeId: "cinderfen_watch",
      mapId: "cinderfen_watchpost",
      difficulty: "normal",
      enemyProfileId: "ashen_covenant",
      aiPersonalityId: "hexfire_cult",
      enemyPressurePlanId: "ashen_watch_captain_pressure"
    });
    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.map.name).toBe("Cinderfen Watch");
      expect(resolved.launch.rewardTable.id).toBe("cinderfen_watchpost_rewards");
      expect(resolved.launch.request.enemyHeroId).toBeUndefined();
    }
  });

  it("carries sanitized retinue units on campaign launches", () => {
    const heroSave = createFallbackHeroSave();
    const request = createCampaignBattleLaunchRequest(heroSave, "border_village", {
      retinueUnits: [
        {
          retinueUnitId: "retinue:border_village:unit-1",
          unitTypeId: "militia",
          rank: "veteran",
          xp: 120,
          kills: 2,
          sourceBattleId: "border_village",
          acquiredAt: "2026-05-02T12:00:00.000Z",
          status: "active"
        },
        {
          retinueUnitId: "bad",
          unitTypeId: "missing",
          rank: "elite",
          xp: 999,
          kills: 9,
          sourceBattleId: "bad",
          acquiredAt: "bad",
          status: "active"
        }
      ]
    });
    const resolved = resolveBattleLaunchRequest(request);

    expect(request.retinueUnits).toHaveLength(1);
    expect(resolved.ok).toBe(true);
    if (resolved.ok) {
      expect(resolved.launch.request.retinueUnits?.[0]).toMatchObject({
        retinueUnitId: "retinue:border_village:unit-1",
        unitTypeId: "militia",
        rank: "veteran"
      });
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
