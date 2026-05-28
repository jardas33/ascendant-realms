import { describe, expect, it } from "vitest";
import { ITEM_BY_ID } from "../data/contentIndex";
import { createFallbackHeroSave } from "./SaveSystem";
import {
  createEligibleRelicRewardChoice,
  grantEligibleRelicReward,
  grantRelicRewardChoiceSelection,
  selectEligibleRelicRewardDefinition
} from "./RelicRewardRules";
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

  it("creates a source-weighted relic choice and grants the selected relic", () => {
    const choice = createEligibleRelicRewardChoice({
      hero: createFallbackHeroSave(),
      itemById: ITEM_BY_ID,
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(choice.duplicateReward).toBeUndefined();
    expect(choice.choice?.options.map((option) => option.definition.id)).toEqual([
      "outpost_command_signet",
      "cinderseer_focus"
    ]);
    expect(choice.choice?.options[0]).toMatchObject({
      sourceMatched: true,
      owned: false
    });
    expect(choice.choice?.options[0].definition.buildArchetype).toBe("commander");

    const granted = grantRelicRewardChoiceSelection({
      hero: createFallbackHeroSave(),
      choice: choice.choice!,
      relicRewardId: "cinderseer_focus",
      itemById: ITEM_BY_ID,
      acquiredAt: "2026-05-27T22:10:00.000Z"
    });

    expect(granted.ok).toBe(true);
    expect(granted.relicReward?.status).toBe("granted");
    expect(granted.relicReward?.itemInstance?.itemId).toBe("cinderseer_focus");
    expect(granted.hero.inventory.map((instance) => instance.itemId)).toContain("cinderseer_focus");
    expect(granted.message).toContain("Seer build");
  });

  it("returns one-choice confirmation or duplicate conversion when relic availability narrows", () => {
    const almostFullHero = {
      ...createFallbackHeroSave(),
      inventory: [
        createItemInstance("outpost_command_signet", "test", "2026-05-27T21:00:00.000Z", { affixes: [] }),
        createItemInstance("cinderseer_focus", "test", "2026-05-27T21:00:00.000Z", { affixes: [] })
      ]
    };
    const oneChoice = createEligibleRelicRewardChoice({
      hero: almostFullHero,
      itemById: ITEM_BY_ID,
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(oneChoice.choice?.options.map((option) => option.definition.id)).toEqual(["emberbrand_shard"]);
    expect(oneChoice.choice?.choiceLabel).toContain("Confirm");

    const allOwned = createEligibleRelicRewardChoice({
      hero: {
        ...almostFullHero,
        inventory: [
          ...almostFullHero.inventory,
          createItemInstance("emberbrand_shard", "test", "2026-05-27T21:00:00.000Z", { affixes: [] })
        ]
      },
      itemById: ITEM_BY_ID,
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(allOwned.choice).toBeUndefined();
    expect(allOwned.duplicateReward?.status).toBe("duplicate_converted");
    expect(allOwned.duplicateReward?.duplicateConversion?.resources).toEqual({ aether: 45 });
  });
});
