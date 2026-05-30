import { describe, expect, it } from "vitest";
import {
  HERO_ROLE_IDENTITY,
  PLAYER_UNIT_ROLE_IDS,
  UNIT_ROLE_IDENTITIES,
  formatUnitRoleTags,
  getUnitRoleIdentity,
  summarizeUnitRoleMix
} from "./unitRoles";

describe("unit role identities", () => {
  it("defines readable role identities for the player army", () => {
    expect(PLAYER_UNIT_ROLE_IDS.map((id) => getUnitRoleIdentity(id).label)).toEqual([
      "Utility / Site Support",
      "Frontline / Melee",
      "Ranged / Focus Fire",
      "Aether / Support Damage"
    ]);
    expect(getUnitRoleIdentity("militia").tags).toEqual(["frontline", "melee", "holds-ground"]);
    expect(getUnitRoleIdentity("ranger").tacticalHint).toContain("behind Militia");
    expect(getUnitRoleIdentity("acolyte").summary).toContain("aether");
    expect(getUnitRoleIdentity("worker").summary).toContain("last resort");
  });

  it("formats role tags and hero ids consistently", () => {
    expect(formatUnitRoleTags(getUnitRoleIdentity("militia"))).toBe("Frontline / Melee / Holds Ground");
    expect(getUnitRoleIdentity("hero_warlord")).toBe(HERO_ROLE_IDENTITY);
  });

  it("summarizes mixed selected army roles", () => {
    expect(
      summarizeUnitRoleMix([
        { definition: { id: "militia" } },
        { definition: { id: "militia" } },
        { definition: { id: "ranger" } },
        { definition: { id: "acolyte" } }
      ])
    ).toBe("2 Frontline / Melee, 1 Ranged / Focus Fire, 1 Aether / Support Damage");
  });

  it("keeps role ids unique", () => {
    expect(new Set(UNIT_ROLE_IDENTITIES.map((identity) => identity.unitId)).size).toBe(UNIT_ROLE_IDENTITIES.length);
  });
});
