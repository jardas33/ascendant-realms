import { describe, expect, it } from "vitest";
import type { CombatStats } from "../core/GameTypes";
import {
  UNIT_VETERANCY_XP_RULES,
  addUnitVeterancyXp,
  applyUnitVeterancyStatBonuses,
  createUnitVeterancyBattleSummary,
  createUnitVeterancyRankUpEvent,
  createUnitVeterancyState,
  getUnitVeterancyRankForXp,
  getUnitVeterancyXpForDamage,
  markUnitVeterancySurvived,
  recordUnitVeterancyDamage,
  recordUnitVeterancyKill
} from "./unitVeterancy";

describe("unit veterancy rules", () => {
  it("calculates ranks from XP thresholds", () => {
    expect(getUnitVeterancyRankForXp(0).id).toBe("recruit");
    expect(getUnitVeterancyRankForXp(54).id).toBe("recruit");
    expect(getUnitVeterancyRankForXp(55).id).toBe("seasoned");
    expect(getUnitVeterancyRankForXp(130).id).toBe("veteran");
    expect(getUnitVeterancyRankForXp(230).id).toBe("elite");
  });

  it("applies rank stat bonuses without mutating base stats", () => {
    const base: CombatStats = {
      maxHp: 100,
      damage: 12,
      range: 90,
      attackCooldown: 1.4,
      speed: 72,
      armor: 2
    };

    expect(applyUnitVeterancyStatBonuses(base, "seasoned")).toMatchObject({
      maxHp: 104,
      damage: 12.5,
      armor: 2
    });
    expect(applyUnitVeterancyStatBonuses(base, "veteran")).toMatchObject({
      maxHp: 108,
      damage: 13,
      armor: 2
    });
    expect(applyUnitVeterancyStatBonuses(base, "elite")).toMatchObject({
      maxHp: 112,
      damage: 13.4,
      armor: 3
    });
    expect(base.maxHp).toBe(100);
  });

  it("records rank-up behavior as XP is gained", () => {
    const recruit = createUnitVeterancyState("unit-1", "militia");

    const first = addUnitVeterancyXp(recruit, 35);
    expect(first.rankedUp).toBe(false);
    expect(first.state.rank).toBe("recruit");

    const second = addUnitVeterancyXp(first.state, 20);
    expect(second.rankedUp).toBe(true);
    expect(second.previousRank.id).toBe("recruit");
    expect(second.currentRank.id).toBe("seasoned");
    expect(second.state.rankedUpThisBattle).toBe(true);
  });

  it("awards small deterministic XP from damage and survival", () => {
    expect(getUnitVeterancyXpForDamage(0)).toBe(0);
    expect(getUnitVeterancyXpForDamage(3)).toBe(1);
    expect(getUnitVeterancyXpForDamage(16)).toBe(4);
    expect(UNIT_VETERANCY_XP_RULES.survivalXp).toBe(12);
  });

  it("summarizes ranked-up and top surviving units for battle results", () => {
    let militia = createUnitVeterancyState("unit-1", "militia", 125);
    militia = recordUnitVeterancyDamage(militia, 64);
    militia = recordUnitVeterancyKill(militia);
    const ranked = addUnitVeterancyXp(militia, 15);
    militia = markUnitVeterancySurvived(ranked.state);
    const rankEvent = createUnitVeterancyRankUpEvent(
      { state: militia, unitName: "Militia" },
      ranked.previousRank.id,
      ranked.currentRank.id
    );

    const ranger = markUnitVeterancySurvived(createUnitVeterancyState("unit-2", "ranger", 80));
    const summary = createUnitVeterancyBattleSummary(
      [
        { state: militia, unitName: "Militia" },
        { state: ranger, unitName: "Ranger" }
      ],
      [rankEvent]
    );

    expect(summary.rankedUpUnits).toHaveLength(1);
    expect(summary.rankedUpUnits[0]).toMatchObject({
      unitName: "Militia",
      rank: "veteran",
      kills: 1,
      damageDealt: 64,
      rankedUp: true
    });
    expect(summary.topSurvivor?.unitName).toBe("Militia");
    expect(summary.notableVeterans.map((entry) => entry.unitName)).toContain("Militia");
  });
});
