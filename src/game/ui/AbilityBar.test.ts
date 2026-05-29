import { describe, expect, it } from "vitest";
import { ABILITY_BY_ID } from "../data/contentIndex";
import { abilityLabel, abilityResourceState } from "./AbilityBar";

describe("AbilityBar", () => {
  it("labels ability cooldowns and readiness states", () => {
    const ability = ABILITY_BY_ID.rally_banner;

    expect(abilityLabel(ability, 0)).toBe("1. Rally Banner");
    expect(abilityLabel(ability, 4.1)).toBe("1. Rally Banner (5s)");
    expect(abilityResourceState(ability, { mana: 40, abilityCooldowns: {} })).toEqual({
      disabled: false,
      label: "Ready",
      className: "ready"
    });
    expect(abilityResourceState(ability, { mana: 40, abilityCooldowns: { rally_banner: 3.2 } })).toEqual({
      disabled: true,
      label: "Cooldown 4s",
      className: "cooldown"
    });
    expect(abilityResourceState(ability, { mana: 7, abilityCooldowns: {} })).toEqual({
      disabled: true,
      label: "Need 18 Mana",
      className: "mana"
    });
  });
});
