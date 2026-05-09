import { describe, expect, it } from "vitest";
import { createFallbackHeroSave } from "../core/SaveSystem";
import {
  createCampaignBattleLaunchRequest,
  createSkirmishBattleLaunchRequest,
  createTutorialBattleLaunchRequest,
  requireBattleLaunch
} from "./BattleLaunchRequest";
import { createBattleRuntime } from "./BattleRuntime";
import { createEnemyPressureRuntime } from "./EnemyPressureRuntime";

describe("EnemyPressureRuntime", () => {
  it("creates pressure only for explicitly attached campaign battle plans", () => {
    const hero = createFallbackHeroSave();
    const campaignLaunch = requireBattleLaunch(createCampaignBattleLaunchRequest(hero, "cinderfen_watch"));
    const campaignRuntime = createBattleRuntime({ launch: campaignLaunch });
    const tutorialLaunch = requireBattleLaunch(createTutorialBattleLaunchRequest(hero));
    const tutorialRuntime = createBattleRuntime({ launch: tutorialLaunch });
    const skirmishLaunch = requireBattleLaunch(
      createSkirmishBattleLaunchRequest(hero, {
        mapId: "cinderfen_watchpost",
        enemyPressurePlanId: "ashen_watch_captain_pressure"
      })
    );
    const skirmishRuntime = createBattleRuntime({ launch: skirmishLaunch });
    const unscopedCampaignLaunch = requireBattleLaunch(createCampaignBattleLaunchRequest(hero, "old_stone_road"));
    const unscopedCampaignRuntime = createBattleRuntime({ launch: unscopedCampaignLaunch });

    expect(
      createEnemyPressureRuntime({
        planId: campaignLaunch.request.enemyPressurePlanId,
        mode: campaignLaunch.request.mode,
        mapId: campaignLaunch.map.id,
        campaignNodeId: campaignLaunch.request.campaignNodeId,
        runtime: campaignRuntime,
        showWarning: () => undefined
      })?.planId
    ).toBe("ashen_watch_captain_pressure");

    expect(
      createEnemyPressureRuntime({
        planId: campaignLaunch.request.enemyPressurePlanId,
        mode: tutorialLaunch.request.mode,
        mapId: tutorialLaunch.map.id,
        campaignNodeId: tutorialLaunch.request.campaignNodeId,
        runtime: tutorialRuntime,
        showWarning: () => undefined
      })
    ).toBeUndefined();

    expect(
      createEnemyPressureRuntime({
        planId: skirmishLaunch.request.enemyPressurePlanId,
        mode: skirmishLaunch.request.mode,
        mapId: skirmishLaunch.map.id,
        campaignNodeId: skirmishLaunch.request.campaignNodeId,
        runtime: skirmishRuntime,
        showWarning: () => undefined
      })
    ).toBeUndefined();

    expect(
      createEnemyPressureRuntime({
        planId: unscopedCampaignLaunch.request.enemyPressurePlanId,
        mode: unscopedCampaignLaunch.request.mode,
        mapId: unscopedCampaignLaunch.map.id,
        campaignNodeId: unscopedCampaignLaunch.request.campaignNodeId,
        runtime: unscopedCampaignRuntime,
        showWarning: () => undefined
      })
    ).toBeUndefined();
  });

  it("triggers capture-site warning stages once and records telemetry", () => {
    const launch = requireBattleLaunch(createCampaignBattleLaunchRequest(createFallbackHeroSave(), "cinderfen_watch"));
    const runtime = createBattleRuntime({ launch });
    const warnings: string[] = [];
    const pressure = createEnemyPressureRuntime({
      planId: launch.request.enemyPressurePlanId,
      mode: launch.request.mode,
      mapId: launch.map.id,
      campaignNodeId: launch.request.campaignNodeId,
      runtime,
      showWarning: (message) => warnings.push(message)
    })!;

    runtime.tick(120);
    pressure.recordPlayerCapturedSite("watch_road_toll");
    pressure.update();
    pressure.recordPlayerCapturedSite("watch_road_toll");
    pressure.update();

    expect(warnings).toEqual(["Enemy commander is reinforcing the watch road."]);
    expect(runtime.stats.enemyPressurePlanId).toBe("ashen_watch_captain_pressure");
    expect(runtime.stats.enemyPressureTriggeredStageIds).toEqual(["watch_road_response"]);
    expect(runtime.stats.enemyPressureWarningsShown).toBe(1);
    expect(runtime.stats.enemyPressureFirstTriggeredAtSeconds).toBe(120);
  });

  it("fires delayed stages and applies safe wave timing actions", () => {
    const launch = requireBattleLaunch(createCampaignBattleLaunchRequest(createFallbackHeroSave(), "cinderfen_crossing"));
    const runtime = createBattleRuntime({ launch });
    const warnings: string[] = [];
    const waveTimingAdjustments: number[] = [];
    const pressure = createEnemyPressureRuntime({
      planId: launch.request.enemyPressurePlanId,
      mode: launch.request.mode,
      mapId: launch.map.id,
      campaignNodeId: launch.request.campaignNodeId,
      runtime,
      showWarning: (message) => warnings.push(message),
      adjustNextWaveTiming: (seconds) => waveTimingAdjustments.push(seconds)
    })!;

    runtime.tick(390);
    pressure.update();

    expect(warnings).toEqual(["Ashen forces are gathering for a late causeway push."]);
    expect(waveTimingAdjustments).toEqual([-12]);
    expect(runtime.stats.enemyPressureTriggeredStageIds).toEqual(["late_causeway_push"]);
    expect(runtime.stats.enemyPressureReinforcementApplied).toBeUndefined();
  });
});
