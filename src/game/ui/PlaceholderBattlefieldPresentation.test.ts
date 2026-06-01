import { describe, expect, it } from "vitest";
import {
  resolveBuildingPlaceholderPresentation,
  resolveUnitPlaceholderPresentation
} from "./PlaceholderBattlefieldPresentation";

describe("PlaceholderBattlefieldPresentation", () => {
  it("assigns distinct placeholder silhouettes to hero, Worker, frontline, ranged, caster, and commander units", () => {
    expect(resolveUnitPlaceholderPresentation({ unitId: "hero", team: "player", kind: "hero", baseColor: 0x88cc88 }).silhouette).toBe(
      "hero"
    );
    expect(resolveUnitPlaceholderPresentation({ unitId: "worker", team: "player", kind: "unit", baseColor: 0x88cc88 }).silhouette).toBe(
      "worker"
    );
    expect(resolveUnitPlaceholderPresentation({ unitId: "militia", team: "player", kind: "unit", baseColor: 0x88cc88 }).silhouette).toBe(
      "frontline"
    );
    expect(resolveUnitPlaceholderPresentation({ unitId: "ranger", team: "player", kind: "unit", baseColor: 0x88cc88 }).silhouette).toBe(
      "ranged"
    );
    expect(resolveUnitPlaceholderPresentation({ unitId: "acolyte", team: "player", kind: "unit", baseColor: 0x88cc88 }).silhouette).toBe(
      "caster"
    );
    expect(
      resolveUnitPlaceholderPresentation({ unitId: "enemy_commander", team: "enemy", kind: "unit", baseColor: 0xcc6666 }).silhouette
    ).toBe("commander");
  });

  it("keeps important labels visible while routine army labels stay quieter by default", () => {
    expect(
      resolveUnitPlaceholderPresentation({ unitId: "hero", team: "player", kind: "hero", baseColor: 0x88cc88 }).labelVisibleByDefault
    ).toBe(true);
    expect(
      resolveUnitPlaceholderPresentation({ unitId: "enemy_commander", team: "enemy", kind: "unit", baseColor: 0xcc6666 }).labelVisibleByDefault
    ).toBe(true);
    expect(
      resolveUnitPlaceholderPresentation({ unitId: "militia", team: "player", kind: "unit", baseColor: 0x88cc88 }).labelVisibleByDefault
    ).toBe(false);
  });

  it("assigns readable placeholder building silhouettes without changing building ids", () => {
    expect(
      resolveBuildingPlaceholderPresentation({ buildingId: "command_hall", team: "player", baseColor: 0x607050 }).silhouette
    ).toBe("command");
    expect(
      resolveBuildingPlaceholderPresentation({ buildingId: "enemy_barracks", team: "enemy", baseColor: 0x805050 }).silhouette
    ).toBe("barracks");
    expect(resolveBuildingPlaceholderPresentation({ buildingId: "watchtower", team: "player", baseColor: 0x607050 }).silhouette).toBe(
      "tower"
    );
  });
});

