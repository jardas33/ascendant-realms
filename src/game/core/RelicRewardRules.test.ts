import { describe, expect, it } from "vitest";
import { selectRelicRewardPreview } from "./RelicRewardRules";

describe("RelicRewardRules", () => {
  it("previews a rival relic after a victorious enemy champion defeat", () => {
    const preview = selectRelicRewardPreview({
      outcome: "victory",
      mode: "campaign_node",
      enemyHeroId: "captain_malrec",
      enemyHeroDefeated: true
    });

    expect(preview?.definition.id).toBe("outpost_command_signet");
    expect(preview?.earnedLabel).toContain("Captain Malrec");
    expect(preview?.persistenceLabel).toContain("not added to inventory or saved");
  });

  it("does not preview relics for escaped champions, defeats, unknown heroes, or tutorial rewards-disabled runs", () => {
    expect(
      selectRelicRewardPreview({
        outcome: "victory",
        mode: "campaign_node",
        enemyHeroId: "captain_malrec",
        enemyHeroDefeated: false
      })
    ).toBeUndefined();
    expect(
      selectRelicRewardPreview({
        outcome: "defeat",
        mode: "campaign_node",
        enemyHeroId: "captain_malrec",
        enemyHeroDefeated: true
      })
    ).toBeUndefined();
    expect(
      selectRelicRewardPreview({
        outcome: "victory",
        mode: "campaign_node",
        enemyHeroId: "missing_champion",
        enemyHeroDefeated: true
      })
    ).toBeUndefined();
    expect(
      selectRelicRewardPreview({
        outcome: "victory",
        mode: "tutorial",
        rewardsDisabled: true,
        enemyHeroId: "captain_malrec",
        enemyHeroDefeated: true
      })
    ).toBeUndefined();
  });
});
