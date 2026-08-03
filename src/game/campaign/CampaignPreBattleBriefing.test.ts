import { describe, expect, it } from "vitest";
import { createNewHeroSave } from "../data/heroes";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { renderCampaignPreBattleBriefing } from "./CampaignPreBattleBriefing";

describe("campaign pre-battle briefing", () => {
  it("shows canonical setup and readiness without using the campaign pacing tier as difficulty", () => {
    const html = renderCampaignPreBattleBriefing({
      node: CAMPAIGN_NODES.find((node) => node.id === "border_village")!,
      heroSave: createNewHeroSave("Aster", "warlord", "exiled_noble"),
      campaignName: "The Barrosan Marches",
      stateLabel: "available",
      lockReason: "",
      canStart: true
    });

    expect(html).toContain('data-testid="campaign-prebattle-briefing"');
    expect(html).toContain("First Claim");
    expect(html).toContain("Barrosan Freeholds");
    expect(html).toContain("Ashen Covenant");
    expect(html).toContain("Easy");
    expect(html).toContain("Ready to launch.");
    expect(html).toContain("Destroy the enemy Stronghold after securing Salto&#039;s Crown Shrine.");
    expect(html).not.toContain(">Low<");
  });

  it("keeps locked availability explicit and non-actionable", () => {
    const node = { ...CAMPAIGN_NODES.find((entry) => entry.id === "old_stone_road")!, difficulty: "easy" as const };
    const html = renderCampaignPreBattleBriefing({
      node,
      heroSave: createNewHeroSave("Aster", "warlord", "exiled_noble"),
      campaignName: "The Barrosan Marches",
      stateLabel: "locked",
      lockReason: "Requires Salto Outskirts.",
      canStart: false
    });

    expect(html).toContain("Unavailable: Requires Salto Outskirts.");
    expect(html).toContain("Availability");
    expect(html).toContain(">locked<");
    expect(html).not.toContain("Ready to launch.");
  });

  it("does not project battle setup onto non-battle campaign nodes", () => {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const html = renderCampaignPreBattleBriefing({
      node,
      heroSave: createNewHeroSave("Aster", "warlord", "exiled_noble"),
      campaignName: "The Barrosan Marches",
      stateLabel: "locked",
      lockReason: "Requires Salto Outskirts.",
      canStart: false
    });

    expect(html).toBe("");
  });
});
