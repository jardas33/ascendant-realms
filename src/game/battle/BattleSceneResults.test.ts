import { describe, expect, it, vi } from "vitest";
import { createBattleRuntime } from "./BattleRuntime";
import { requireBattleLaunch } from "./BattleLaunchRequest";
import { endBattleAndOpenResults } from "./BattleSceneResults";
import { SCENE_KEYS } from "../core/SceneKeys";
import { createPlaytestHubBattleLaunchRequest, createPlaytestHubHeroSave } from "../playtest/PlaytestHubFixtures";
import type { Hero } from "../entities/Hero";
import type Phaser from "phaser";

describe("BattleSceneResults", () => {
  it("preserves private Playtest Hub context when a hub battle opens Results", () => {
    const heroSave = createPlaytestHubHeroSave();
    const launch = requireBattleLaunch(createPlaytestHubBattleLaunchRequest("benchmark_battle_results_transition", heroSave));
    const runtime = createBattleRuntime({ launch });
    const start = vi.fn();
    const scene = { scene: { start } } as unknown as Phaser.Scene;
    const hero = { toSaveData: () => heroSave } as unknown as Hero;

    endBattleAndOpenResults({ scene, runtime, hero, launch, outcome: "victory" });

    expect(start).toHaveBeenCalledWith(
      SCENE_KEYS.results,
      expect.objectContaining({
        privatePlaytestHub: true,
        launchRequest: expect.objectContaining({
          privatePlaytestHubScenarioId: "benchmark_battle_results_transition"
        })
      })
    );
  });
});
