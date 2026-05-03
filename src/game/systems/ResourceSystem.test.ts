import { describe, expect, it, vi } from "vitest";
import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import type { CaptureSiteDefinition, ResourceBag, Team } from "../core/GameTypes";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";
import { ResourceSystem } from "./ResourceSystem";

const EMPTY_RESOURCES: ResourceBag = { crowns: 0, stone: 0, iron: 0, aether: 0 };

function createSite(definition: Partial<CaptureSiteDefinition> = {}): CaptureSite {
  const siteDefinition: CaptureSiteDefinition = {
    id: "cinder_crossing",
    name: "Cinder Shrine",
    resource: "aether",
    x: 100,
    y: 100,
    radius: 80,
    incomeAmount: 16,
    incomeInterval: 999,
    firstCaptureBonus: {
      id: "cinder_shrine_surge",
      label: "Cinder Shrine Surge",
      description: "The first claim releases +20 Aether.",
      resources: { aether: 20 }
    },
    ...definition
  };
  const site = {
    definition: siteDefinition,
    owner: "neutral" as Team,
    team: "neutral" as Team,
    capturingTeam: "neutral" as Team,
    captureProgress: 0,
    incomeTimer: 0,
    position: { x: siteDefinition.x, y: siteDefinition.y },
    radius: siteDefinition.radius,
    setOwner(owner: Team) {
      this.owner = owner;
      this.team = owner;
      this.capturingTeam = "neutral";
      this.captureProgress = 0;
      this.incomeTimer = 0;
    },
    updateVisuals() {}
  };
  return site as unknown as CaptureSite;
}

function createUnit(team: Team, x = 100, y = 100): Unit {
  return {
    alive: true,
    team,
    position: { x, y }
  } as unknown as Unit;
}

function createResourceBank(): Record<"player" | "enemy", ResourceBag> {
  return {
    player: { ...EMPTY_RESOURCES },
    enemy: { ...EMPTY_RESOURCES }
  };
}

describe("ResourceSystem first-capture bonuses", () => {
  it("grants a capture-site first-capture bonus when the player claims the site", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(site.owner).toBe("player");
    expect(resources.player.aether).toBe(20);
    expect(onCaptureBonus).toHaveBeenCalledWith(site, "player", site.definition.firstCaptureBonus);
  });

  it("does not duplicate a first-capture bonus when the same team recaptures the site", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);
    site.setOwner("neutral");
    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(resources.player.aether).toBe(20);
    expect(onCaptureBonus).toHaveBeenCalledTimes(1);
  });

  it("tracks first-capture bonuses separately for player and enemy teams", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);
    site.setOwner("neutral");
    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("enemy")]);

    expect(resources.player.aether).toBe(20);
    expect(resources.enemy.aether).toBe(20);
    expect(onCaptureBonus).toHaveBeenCalledTimes(2);
  });

  it("falls back to ordinary capture behavior when a site has no bonus", () => {
    const resources = createResourceBank();
    const site = createSite({ firstCaptureBonus: undefined });
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(site.owner).toBe("player");
    expect(resources.player.aether).toBe(0);
    expect(onCaptureBonus).not.toHaveBeenCalled();
  });
});
