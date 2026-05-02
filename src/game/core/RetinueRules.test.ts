import { describe, expect, it } from "vitest";
import { createFallbackCampaignSave } from "./SaveSystem";
import {
  addVeteranToRetinue,
  dismissRetinueUnit,
  getRetinueCapacity,
  retinueDeploymentUnits,
  updateRetinueAfterBattle
} from "./RetinueRules";
import type { UnitVeterancySummaryEntry } from "./GameTypes";

const veteranMilitia: UnitVeterancySummaryEntry = {
  unitInstanceId: "unit-1",
  unitTypeId: "militia",
  unitName: "Militia",
  xp: 120,
  rank: "veteran",
  rankName: "Veteran",
  kills: 2,
  damageDealt: 96,
  survivedBattle: true,
  rankedUp: true,
  previousRank: "seasoned"
};

describe("RetinueRules", () => {
  it("adds a surviving Seasoned or better unit to the retinue", () => {
    const campaign = createFallbackCampaignSave();
    const result = addVeteranToRetinue(campaign, veteranMilitia, "border_village", "2026-05-02T12:00:00.000Z");

    expect(result.ok).toBe(true);
    expect(result.campaign.retinueUnits).toHaveLength(1);
    expect(result.campaign.retinueUnits[0]).toMatchObject({
      retinueUnitId: "retinue:border_village:unit-1",
      unitTypeId: "militia",
      rank: "veteran",
      xp: 120,
      kills: 2,
      status: "active"
    });
  });

  it("enforces capacity and Training Yard II capacity bonus", () => {
    const campaign = {
      ...createFallbackCampaignSave(),
      retinueUnits: [
        { ...addVeteranToRetinue(createFallbackCampaignSave(), veteranMilitia, "a").campaign.retinueUnits[0] },
        { ...addVeteranToRetinue(createFallbackCampaignSave(), { ...veteranMilitia, unitInstanceId: "unit-2" }, "b").campaign.retinueUnits[0] }
      ]
    };

    expect(getRetinueCapacity(campaign)).toBe(2);
    expect(addVeteranToRetinue(campaign, { ...veteranMilitia, unitInstanceId: "unit-3" }, "c").ok).toBe(false);

    const upgraded = {
      ...campaign,
      strongholdUpgradeRanks: { training_yard_ii: 1 }
    };
    expect(getRetinueCapacity(upgraded)).toBe(3);
    expect(addVeteranToRetinue(upgraded, { ...veteranMilitia, unitInstanceId: "unit-3" }, "c").ok).toBe(true);
  });

  it("updates survivor progress and removes dead retinue units after battle", () => {
    const added = addVeteranToRetinue(createFallbackCampaignSave(), veteranMilitia, "border_village");
    const campaign = added.campaign;
    const existing = campaign.retinueUnits[0];
    const updated = updateRetinueAfterBattle(campaign, {
      rankedUpUnits: [],
      notableVeterans: [
        {
          ...veteranMilitia,
          unitInstanceId: existing.retinueUnitId,
          xp: 190,
          rank: "elite",
          rankName: "Elite",
          kills: 4
        }
      ],
      topSurvivor: undefined
    });

    expect(updated.retinueUnits[0]).toMatchObject({ rank: "elite", xp: 190, kills: 4 });

    const removed = updateRetinueAfterBattle(updated, undefined, [existing.retinueUnitId]);
    expect(removed.retinueUnits).toEqual([]);
  });

  it("dismisses and deploys only active units up to capacity", () => {
    const first = addVeteranToRetinue(createFallbackCampaignSave(), veteranMilitia, "border_village").campaign;
    const second = addVeteranToRetinue(first, { ...veteranMilitia, unitInstanceId: "unit-2" }, "old_stone_road").campaign;

    expect(retinueDeploymentUnits(second).map((unit) => unit.unitTypeId)).toEqual(["militia", "militia"]);
    expect(dismissRetinueUnit(second, second.retinueUnits[0].retinueUnitId).retinueUnits).toHaveLength(1);
  });
});
