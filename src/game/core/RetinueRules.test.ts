import { describe, expect, it } from "vitest";
import { createFallbackCampaignSave } from "./SaveSystem";
import {
  addVeteranToRetinue,
  dismissRetinueUnit,
  formatRetinueDeploymentLabel,
  getRetinueCapacityBreakdown,
  getRetinueCapacity,
  retinueDeploymentUnits,
  retinueEligibilityReason,
  selectedRetinueUnitIds,
  toggleRetinueDeployment,
  updateRetinueAfterBattle,
  updateRetinueAfterBattleDetailed
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

  it("formats capacity and eligibility copy for presentation surfaces", () => {
    const campaign = {
      ...createFallbackCampaignSave(),
      strongholdUpgradeRanks: { training_yard_ii: 1 }
    };

    expect(getRetinueCapacityBreakdown(campaign)).toMatchObject({
      activeCount: 0,
      capacity: 5,
      rosterCapacity: 5,
      baseRosterCapacity: 5,
      deploymentCount: 0,
      deploymentCapacity: 3,
      baseDeploymentCapacity: 2,
      trainingYardDeploymentBonus: 1
    });
    expect(retinueEligibilityReason({ ...veteranMilitia, rank: "recruit", rankName: "Recruit" })).toBe(
      "Not eligible: needs Seasoned rank or better."
    );
    expect(retinueEligibilityReason({ ...veteranMilitia, survivedBattle: false })).toBe(
      "Not eligible: did not survive the battle."
    );
    expect(retinueEligibilityReason({ ...veteranMilitia, unitTypeId: "worker", unitName: "Worker" })).toBe(
      "Not eligible: only Militia, Rangers, and Acolytes can join the retinue."
    );
    expect(retinueEligibilityReason(veteranMilitia)).toBe("Eligible: survived at Seasoned rank or better.");
    expect(formatRetinueDeploymentLabel(addVeteranToRetinue(createFallbackCampaignSave(), veteranMilitia, "border_village").campaign.retinueUnits[0])).toBe(
      "Veteran Militia"
    );
  });

  it("enforces roster capacity separately from deployment capacity", () => {
    let campaign = createFallbackCampaignSave();
    for (let index = 1; index <= 5; index += 1) {
      const result = addVeteranToRetinue(campaign, { ...veteranMilitia, unitInstanceId: `unit-${index}` }, `battle-${index}`);
      expect(result.ok).toBe(true);
      campaign = result.campaign;
    }

    expect(getRetinueCapacity(campaign)).toBe(5);
    expect(campaign.retinueUnits).toHaveLength(5);
    expect(retinueDeploymentUnits(campaign)).toHaveLength(2);
    expect(addVeteranToRetinue(campaign, { ...veteranMilitia, unitInstanceId: "unit-6" }, "battle-6")).toMatchObject({
      ok: false,
      reason: "Retinue roster is full."
    });

    const upgraded = {
      ...campaign,
      strongholdUpgradeRanks: { training_yard_ii: 1 }
    };
    expect(retinueDeploymentUnits(upgraded)).toHaveLength(2);
    const toggled = toggleRetinueDeployment(upgraded, upgraded.retinueUnits[2].retinueUnitId);
    expect(toggled.ok).toBe(true);
    expect(retinueDeploymentUnits(toggled.campaign)).toHaveLength(3);
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
    expect(updated.retinueUnits[0]).toMatchObject({ battlesSurvived: 2, missionsDeployed: 1 });

    const removed = updateRetinueAfterBattle(updated, undefined, [existing.retinueUnitId]);
    expect(removed.retinueUnits).toEqual([]);
    expect(removed.retinueDeploymentIds).toEqual([]);
  });

  it("moves critically wounded survivors into recovery and blocks deployment until a first-clear step passes", () => {
    const added = addVeteranToRetinue(createFallbackCampaignSave(), veteranMilitia, "border_village");
    const retinueUnitId = added.campaign.retinueUnits[0].retinueUnitId;

    const injured = updateRetinueAfterBattleDetailed(
      added.campaign,
      {
        rankedUpUnits: [],
        notableVeterans: [{ ...veteranMilitia, unitInstanceId: retinueUnitId }],
        topSurvivor: undefined
      },
      {
        participatingRetinueUnitIds: [retinueUnitId],
        survivorHealth: [{ retinueUnitId, hpRatio: 0.25 }],
        progressionStepCompleted: false
      }
    );

    expect(injured.summary.enteredRecoveryIds).toEqual([retinueUnitId]);
    expect(injured.campaign.retinueUnits[0]).toMatchObject({
      status: "recovering",
      recoveryMissionsRemaining: 1
    });
    expect(injured.campaign.retinueDeploymentIds).toEqual([]);
    expect(toggleRetinueDeployment(injured.campaign, retinueUnitId)).toMatchObject({
      ok: false,
      reason: "Recovering Retinue units cannot deploy until ready."
    });

    const replaySafe = updateRetinueAfterBattleDetailed(injured.campaign, undefined, {
      progressionStepCompleted: false
    });
    expect(replaySafe.campaign.retinueUnits[0]).toMatchObject({
      status: "recovering",
      recoveryMissionsRemaining: 1
    });

    const recovered = updateRetinueAfterBattleDetailed(replaySafe.campaign, undefined, {
      progressionStepCompleted: true
    });
    expect(recovered.summary.returnedReadyIds).toEqual([retinueUnitId]);
    expect(recovered.campaign.retinueUnits[0]).toMatchObject({
      status: "active",
      recoveryMissionsRemaining: undefined
    });
  });

  it("dismisses and deploys only selected active units up to capacity", () => {
    const first = addVeteranToRetinue(createFallbackCampaignSave(), veteranMilitia, "border_village").campaign;
    const second = addVeteranToRetinue(first, { ...veteranMilitia, unitInstanceId: "unit-2" }, "old_stone_road").campaign;
    const third = addVeteranToRetinue(second, { ...veteranMilitia, unitInstanceId: "unit-3" }, "watchtower_ridge").campaign;

    expect(retinueDeploymentUnits(third).map((unit) => unit.retinueUnitId)).toEqual([
      third.retinueUnits[0].retinueUnitId,
      third.retinueUnits[1].retinueUnitId
    ]);
    expect(toggleRetinueDeployment(third, third.retinueUnits[2].retinueUnitId)).toMatchObject({
      ok: false,
      reason: "Retinue deployment cap reached."
    });
    const reserved = toggleRetinueDeployment(third, third.retinueUnits[0].retinueUnitId);
    expect(reserved.ok).toBe(true);
    expect(selectedRetinueUnitIds(reserved.campaign)).toEqual([third.retinueUnits[1].retinueUnitId]);
    const deployed = toggleRetinueDeployment(reserved.campaign, third.retinueUnits[2].retinueUnitId);
    expect(deployed.ok).toBe(true);
    expect(retinueDeploymentUnits(deployed.campaign).map((unit) => unit.retinueUnitId)).toEqual([
      third.retinueUnits[1].retinueUnitId,
      third.retinueUnits[2].retinueUnitId
    ]);
    const dismissed = dismissRetinueUnit(deployed.campaign, third.retinueUnits[1].retinueUnitId);
    expect(dismissed.retinueUnits).toHaveLength(2);
    expect(dismissed.retinueDeploymentIds).toEqual([third.retinueUnits[2].retinueUnitId]);
  });
});
