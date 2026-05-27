import { describe, expect, it } from "vitest";
import { ITEM_BY_ID } from "../data/contentIndex";
import { createFallbackHeroSave } from "./SaveSystem";
import { grantEligibleRelicReward, selectEligibleRelicRewardDefinition } from "./RelicRewardRules";
import { createItemInstance } from "./HeroProgressionRules";

describe("RelicRewardRules", () => {
  it("selects a rival relic after a victorious enemy champion defeat", () => {
    const definition = selectEligibleRelicRewardDefinition({
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(definition?.id).toBe("outpost_command_signet");
    expect(definition?.sourceLabel).toContain("Captain Malrec");
    expect(definition?.persistenceStatus).toBe("persistent_inventory");
  });

  it("does not select relics for escaped champions, defeats, unknown heroes, or tutorial rewards-disabled runs", () => {
    expect(
      selectEligibleRelicRewardDefinition({
        outcome: "victory",
        mode: "campaign_node",
        enemyHeroId: "captain_malrec",
        enemyHeroDefeated: false
      })
    ).toBeUndefined();
    expect(
      selectEligibleRelicRewardDefinition({
        outcome: "defeat",
        mode: "campaign_node",
        enemyHeroId: "captain_malrec",
        enemyHeroDefeated: true
      })
    ).toBeUndefined();
    expect(
      selectEligibleRelicRewardDefinition({
        outcome: "victory",
        mode: "campaign_node",
        enemyHeroId: "missing_champion",
        enemyHeroDefeated: true
      })
    ).toBeUndefined();
    expect(
      selectEligibleRelicRewardDefinition({
        outcome: "victory",
        mode: "tutorial",
        rewardsDisabled: true,
        enemyHeroId: "captain_malrec",
        enemyHeroDefeated: true
      })
    ).toBeUndefined();
  });

  it("grants a persistent relic item and converts unique duplicates", () => {
    const first = grantEligibleRelicReward({
      hero: createFallbackHeroSave(),
      itemById: ITEM_BY_ID,
      acquiredAt: "2026-05-27T21:30:00.000Z",
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(first.relicReward?.status).toBe("granted");
    expect(first.relicReward?.itemInstance?.itemId).toBe("outpost_command_signet");
    expect(first.hero.inventory.map((instance) => instance.itemId)).toContain("outpost_command_signet");

    const duplicate = grantEligibleRelicReward({
      hero: {
        ...createFallbackHeroSave(),
        inventory: [createItemInstance("outpost_command_signet", "test", "2026-05-27T21:29:00.000Z", { affixes: [] })]
      },
      itemById: ITEM_BY_ID,
      acquiredAt: "2026-05-27T21:30:00.000Z",
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(duplicate.relicReward?.status).toBe("duplicate_converted");
    expect(duplicate.hero.inventory.filter((instance) => instance.itemId === "outpost_command_signet")).toHaveLength(1);
    expect(duplicate.relicReward?.duplicateConversion?.resources).toEqual({ aether: 45 });
  });
});
