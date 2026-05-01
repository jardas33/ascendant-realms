import Phaser from "phaser";
import { completeCampaignNodeWithRewards, createStartedCampaignSave } from "../core/CampaignRules";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { requireCampaignNode } from "../data/contentIndex";
import { Hero } from "../entities/Hero";
import type { BattleRuntime } from "./BattleRuntime";
import { cloneBattleLaunchRequestWithHero, type ResolvedBattleLaunch } from "./BattleLaunchRequest";

interface BattleSceneResultsOptions {
  scene: Phaser.Scene;
  runtime: BattleRuntime;
  hero: Hero;
  launch: ResolvedBattleLaunch;
  outcome: "victory" | "defeat";
}

export function endBattleAndOpenResults(options: BattleSceneResultsOptions): void {
  const { scene, runtime, hero, launch, outcome } = options;
  const startingHeroSave = launch.request.heroSave;
  const completion = runtime.completeBattle({
    outcome,
    heroSave: hero.toSaveData()
  });
  if (!completion) {
    return;
  }
  const resultsHeroSave = outcome === "victory" ? completion.heroSave : startingHeroSave;
  if (completion.shouldSaveHero && launch.request.mode !== "campaign_node") {
    SaveSystem.saveHero(completion.heroSave);
  }

  if (outcome === "victory" && launch.request.mode === "campaign_node" && launch.request.campaignNodeId) {
    const node = requireCampaignNode(launch.request.campaignNodeId);
    const storedCampaign = SaveSystem.load()?.campaign ?? createStartedCampaignSave();
    const unlockedBefore = new Set(storedCampaign.unlockedNodeIds);
    const campaignCompletion = completeCampaignNodeWithRewards({
      campaign: storedCampaign,
      hero: completion.heroSave,
      node
    });
    const stats = {
      ...completion.stats,
      xpGained: completion.stats.xpGained + campaignCompletion.nodeReward.xp
    };
    const newlyUnlockedNodeIds = campaignCompletion.campaign.unlockedNodeIds.filter(
      (nodeId) => !unlockedBefore.has(nodeId) && nodeId !== node.id
    );
    SaveSystem.saveGame(campaignCompletion.hero, campaignCompletion.campaign);
    scene.scene.start(SCENE_KEYS.results, {
      stats,
      heroSave: campaignCompletion.hero,
      startingHeroSave,
      rewardItemIds: completion.rewardItemIds,
      reward: completion.reward,
      rewardLevelUp: completion.rewardLevelUp,
      launchRequest: cloneBattleLaunchRequestWithHero(launch.request, campaignCompletion.hero),
      campaignResult: {
        completedNodeId: node.id,
        completedNodeName: node.name,
        unlockedNodeIds: newlyUnlockedNodeIds,
        unlockedNodeNames: newlyUnlockedNodeIds.map((nodeId) => requireCampaignNode(nodeId).name),
        nodeReward: campaignCompletion.nodeReward,
        nodeLevelUp: campaignCompletion.nodeLevelUp,
        campaignResources: campaignCompletion.campaign.resources
      }
    });
    return;
  }

  scene.scene.start(SCENE_KEYS.results, {
    stats: completion.stats,
    heroSave: resultsHeroSave,
    startingHeroSave,
    rewardItemIds: completion.rewardItemIds,
    reward: completion.reward,
    rewardLevelUp: completion.rewardLevelUp,
    launchRequest: cloneBattleLaunchRequestWithHero(launch.request, resultsHeroSave)
  });
}
