import { describe, expect, it } from "vitest";
import { requireCampaignNode, requireEnemyHero } from "../data/contentIndex";
import { createFallbackCampaignSave, createFallbackHeroSave } from "./SaveSystem";
import {
  applyRivalModifiersToEnemyHeroStats,
  createInitialRivalState,
  formatRivalStateSnapshot,
  getRivalBattleLaunchModifiers,
  getRivalTrophyIntel,
  getRivalNodePreview,
  updateRivalAfterBattle
} from "./RivalRules";

describe("RivalRules", () => {
  it("creates initial unseen rival state", () => {
    expect(createInitialRivalState("veyra_cinders")).toEqual({
      enemyHeroId: "veyra_cinders",
      encounters: 0,
      defeats: 0,
      victoriesAgainstPlayer: 0,
      lastOutcome: "unseen",
      disposition: "wary",
      activeModifiers: [],
      isKnownToPlayer: false
    });
  });

  it("records a victory with the enemy hero defeated and grants the first-defeat campaign reward once", () => {
    const campaign = createFallbackCampaignSave();
    const hero = createFallbackHeroSave();

    const first = updateRivalAfterBattle({
      campaign,
      hero,
      nodeId: "aether_well_ruins",
      enemyHeroId: "veyra_cinders",
      playerWon: true,
      enemyHeroDefeated: true,
      acquiredAt: "2026-05-02T19:58:00.000Z"
    });

    expect(first.campaign.rivals[0]).toMatchObject({
      enemyHeroId: "veyra_cinders",
      encounters: 1,
      defeats: 1,
      lastOutcome: "defeated",
      disposition: "humiliated",
      activeModifiers: [],
      isKnownToPlayer: true
    });
    expect(first.campaign.resources.aether).toBe(20);
    expect(first.hero.xp).toBe(90);
    expect(first.hero.inventory.map((item) => item.itemId)).toContain("cinderseer_lens");
    expect(first.hero.factionReputation.old_faith).toBe(1);
    expect(first.campaign.rivalTrophies[0]).toMatchObject({
      trophyId: "trophy_veyra_cinder_lens",
      enemyHeroId: "veyra_cinders",
      sourceNodeId: "aether_well_ruins",
      label: "Cinder-Seer's Cracked Lens"
    });
    expect(first.rivalResult?.firstDefeatRewardEarned).toBe(true);
    expect(first.rivalResult?.rewardText).toContain("+20 Aether");
    expect(first.rivalResult?.rewardText).toContain("Trophy: Cinder-Seer's Cracked Lens");

    const second = updateRivalAfterBattle({
      campaign: first.campaign,
      hero: first.hero,
      nodeId: "aether_well_ruins",
      enemyHeroId: "veyra_cinders",
      playerWon: true,
      enemyHeroDefeated: true
    });

    expect(second.campaign.resources.aether).toBe(20);
    expect(second.hero.xp).toBe(90);
    expect(second.hero.inventory.filter((item) => item.itemId === "cinderseer_lens")).toHaveLength(1);
    expect(second.campaign.rivalTrophies).toHaveLength(1);
    expect(second.campaign.rivals[0]).toMatchObject({ defeats: 2, disposition: "enraged" });
    expect(second.rivalResult?.firstDefeatRewardEarned).toBe(false);
    expect(second.rivalResult?.duplicateFirstDefeatRewardPrevented).toBe(true);
  });

  it("records escaped and triumphant outcomes with small next-encounter modifiers", () => {
    const escaped = updateRivalAfterBattle({
      campaign: createFallbackCampaignSave(),
      hero: createFallbackHeroSave(),
      nodeId: "bandit_hillfort",
      enemyHeroId: "gorak_emberhand",
      playerWon: true,
      enemyHeroDefeated: false
    });

    expect(escaped.campaign.rivals[0]).toMatchObject({
      lastOutcome: "escaped",
      disposition: "wary",
      activeModifiers: ["rival_wary_hp_5"]
    });

    const triumphant = updateRivalAfterBattle({
      campaign: createFallbackCampaignSave(),
      hero: createFallbackHeroSave(),
      nodeId: "ashen_outpost",
      enemyHeroId: "captain_malrec",
      playerWon: false,
      enemyHeroDefeated: false
    });

    expect(triumphant.campaign.rivals[0]).toMatchObject({
      lastOutcome: "triumphant",
      disposition: "emboldened",
      victoriesAgainstPlayer: 1,
      activeModifiers: ["rival_emboldened_damage_5"]
    });
  });

  it("aggregates launch modifiers and applies them to enemy hero stats", () => {
    const node = requireCampaignNode("aether_well_ruins");
    const hero = requireEnemyHero("veyra_cinders");
    const escaped = updateRivalAfterBattle({
      campaign: createFallbackCampaignSave(),
      hero: createFallbackHeroSave(),
      nodeId: node.id,
      enemyHeroId: hero.id,
      playerWon: true,
      enemyHeroDefeated: false
    });

    const modifiers = getRivalBattleLaunchModifiers(escaped.campaign, node);
    const adjusted = applyRivalModifiersToEnemyHeroStats(hero.stats, modifiers);

    expect(modifiers).toEqual([{ id: "rival_wary_hp_5", value: "veyra_cinders" }]);
    expect(adjusted.maxHp).toBe(Math.round(hero.stats.maxHp * 1.05));
    expect(adjusted.damage).toBe(hero.stats.damage);
  });

  it("creates campaign preview and telemetry snapshot copy", () => {
    const node = requireCampaignNode("ashen_outpost");
    const outcome = updateRivalAfterBattle({
      campaign: createFallbackCampaignSave(),
      hero: createFallbackHeroSave(),
      nodeId: node.id,
      enemyHeroId: "captain_malrec",
      playerWon: false,
      enemyHeroDefeated: false
    });

    const preview = getRivalNodePreview(outcome.campaign, node);

    expect(preview?.summaryText).toBe("Triumphant - Emboldened");
    expect(preview?.effectText).toContain("+5% damage");
    expect(formatRivalStateSnapshot(outcome.campaign.rivals[0])).toContain("Triumphant / Emboldened");
  });

  it("summarizes earned rival trophies for campaign intel", () => {
    const outcome = updateRivalAfterBattle({
      campaign: createFallbackCampaignSave(),
      hero: createFallbackHeroSave(),
      nodeId: "bandit_hillfort",
      enemyHeroId: "gorak_emberhand",
      playerWon: true,
      enemyHeroDefeated: true,
      acquiredAt: "2026-05-02T20:00:00.000Z"
    });

    expect(getRivalTrophyIntel(outcome.campaign)[0]).toMatchObject({
      enemyHeroId: "gorak_emberhand",
      enemyHeroName: "Gorak Emberhand",
      label: "Gorak's Emberbrand",
      sourceNodeName: "Bandit Hillfort"
    });
  });
});
