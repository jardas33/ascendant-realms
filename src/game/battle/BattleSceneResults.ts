import Phaser from "phaser";
import { completeCampaignNodeWithRewards, createStartedCampaignSave } from "../core/CampaignRules";
import { updateRetinueAfterBattle } from "../core/RetinueRules";
import { updateRivalAfterBattle, type RivalBattleOutcomeSummary } from "../core/RivalRules";
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
  const rewardsDisabled = launch.request.mode === "tutorial" || launch.request.rewardsDisabled === true;
  const completion = runtime.completeBattle({
    outcome,
    heroSave: hero.toSaveData(),
    rewardsDisabled
  });
  if (!completion) {
    return;
  }
  const resultsHeroSave = outcome === "victory" ? completion.heroSave : startingHeroSave;
  if (completion.shouldSaveHero && launch.request.mode !== "campaign_node") {
    SaveSystem.saveHero(completion.heroSave);
  }
  let rivalResult: RivalBattleOutcomeSummary | undefined;

  if (launch.request.mode === "campaign_node") {
    const storedCampaign = SaveSystem.load()?.campaign ?? createStartedCampaignSave();
    const campaignWithRetinueUpdates = updateRetinueAfterBattle(
      storedCampaign,
      completion.stats.veteranSummary,
      completion.stats.retinueUnitIdsLost
    );
    if (outcome !== "victory") {
      const rivalUpdate = updateRivalAfterBattle({
        campaign: campaignWithRetinueUpdates,
        hero: startingHeroSave,
        nodeId: launch.request.campaignNodeId,
        enemyHeroId: launch.request.enemyHeroId,
        playerWon: false,
        enemyHeroDefeated: false
      });
      rivalResult = rivalUpdate.rivalResult;
      SaveSystem.saveCampaign(rivalUpdate.campaign, rivalUpdate.hero);
    }
  }

  if (outcome === "victory" && launch.request.mode === "campaign_node" && launch.request.campaignNodeId) {
    const node = requireCampaignNode(launch.request.campaignNodeId);
    const storedCampaign = updateRetinueAfterBattle(
      SaveSystem.load()?.campaign ?? createStartedCampaignSave(),
      completion.stats.veteranSummary,
      completion.stats.retinueUnitIdsLost
    );
    const unlockedBefore = new Set(storedCampaign.unlockedNodeIds);
    const campaignCompletion = completeCampaignNodeWithRewards({
      campaign: storedCampaign,
      hero: completion.heroSave,
      node,
      completedObjectiveIds: completion.stats.completedObjectiveIds
    });
    const rivalUpdate = updateRivalAfterBattle({
      campaign: campaignCompletion.campaign,
      hero: campaignCompletion.hero,
      nodeId: node.id,
      enemyHeroId: launch.request.enemyHeroId,
      playerWon: true,
      enemyHeroDefeated: Boolean(completion.stats.enemyHeroDefeated)
    });
    rivalResult = rivalUpdate.rivalResult;
    const stats = {
      ...completion.stats,
      xpGained: completion.stats.xpGained + campaignCompletion.nodeReward.xp + (rivalUpdate.rivalResult?.rewardXp ?? 0)
    };
    const newlyUnlockedNodeIds = campaignCompletion.campaign.unlockedNodeIds.filter(
      (nodeId) => !unlockedBefore.has(nodeId) && nodeId !== node.id
    );
    SaveSystem.saveGame(rivalUpdate.hero, rivalUpdate.campaign);
    scene.scene.start(SCENE_KEYS.results, {
      stats,
      heroSave: rivalUpdate.hero,
      startingHeroSave,
      rewardItemIds: completion.rewardItemIds,
      reward: completion.reward,
      rewardLevelUp: completion.rewardLevelUp,
      launchRequest: cloneBattleLaunchRequestWithHero(launch.request, rivalUpdate.hero),
      campaignResult: {
        completedNodeId: node.id,
        completedNodeName: node.name,
        unlockedNodeIds: newlyUnlockedNodeIds,
        unlockedNodeNames: newlyUnlockedNodeIds.map((nodeId) => requireCampaignNode(nodeId).name),
        nodeReward: campaignCompletion.nodeReward,
        nodeLevelUp: campaignCompletion.nodeLevelUp,
        campaignResources: rivalUpdate.campaign.resources,
        wasFirstClear: campaignCompletion.wasFirstClear,
        wasReplay: campaignCompletion.wasReplay,
        nodeRewardClaimed: campaignCompletion.nodeRewardClaimed,
        nodeRewardAlreadyClaimed: campaignCompletion.nodeRewardAlreadyClaimed,
        optionalObjectives: campaignCompletion.optionalObjectives
      },
      rivalResult,
      relicReward: rivalResult?.relicReward,
      relicRewardChoice: rivalResult?.relicRewardChoice
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
    launchRequest: cloneBattleLaunchRequestWithHero(launch.request, resultsHeroSave),
    rivalResult,
    relicReward: rivalResult?.relicReward,
    relicRewardChoice: rivalResult?.relicRewardChoice
  });
}
