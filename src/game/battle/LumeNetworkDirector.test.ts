import { describe, expect, it } from "vitest";
import type { LumeSiteSnapshot, LumeTargetSnapshot } from "../core/GameTypes";
import { LUME_NETWORKS, selectLumeNetworkForLaunch } from "../data/lumeNetworks";
import { isLinkedWardTarget, resolveLumeNetworkState } from "./LumeNetworkDirector";

const network = LUME_NETWORKS[0];

describe("LumeNetworkDirector", () => {
  it("gates the v0.82 runtime slice to Aether Well Ruins campaign battles only", () => {
    expect(
      selectLumeNetworkForLaunch({
        mode: "campaign_node",
        campaignNodeId: "aether_well_ruins",
        mapId: "broken_ford",
        rewardsDisabled: false
      })?.id
    ).toBe("aether_well_ruins_lume_ward");
    expect(
      selectLumeNetworkForLaunch({
        mode: "campaign_node",
        campaignNodeId: "bandit_hillfort",
        mapId: "broken_ford",
        rewardsDisabled: false
      })
    ).toBeUndefined();
    expect(
      selectLumeNetworkForLaunch({
        mode: "tutorial",
        campaignNodeId: "aether_well_ruins",
        mapId: "broken_ford",
        rewardsDisabled: true
      })
    ).toBeUndefined();
  });

  it("activates, severs, and reactivates capture-only links from live site ownership", () => {
    const inactive = resolveLumeNetworkState(network, [
      site("west_stone_cut", "West Stone Cut", "neutral"),
      site("ford_toll", "Ford Toll", "neutral"),
      site("north_aether_spring", "North Aether Spring", "neutral")
    ]);
    expect(inactive.activeLinkIds).toEqual([]);
    expect(inactive.objectiveCompleted).toBe(false);

    const active = resolveLumeNetworkState(network, [
      site("west_stone_cut", "West Stone Cut", "player"),
      site("ford_toll", "Ford Toll", "player"),
      site("north_aether_spring", "North Aether Spring", "neutral")
    ], inactive);
    expect(active.activeLinkIds).toEqual(["west_stone_cut_to_ford_toll"]);
    expect(active.lifetimeActivatedLinkIds).toEqual(["west_stone_cut_to_ford_toll"]);
    expect(active.objectiveCompleted).toBe(true);

    const severed = resolveLumeNetworkState(network, [
      site("west_stone_cut", "West Stone Cut", "player"),
      site("ford_toll", "Ford Toll", "enemy"),
      site("north_aether_spring", "North Aether Spring", "neutral")
    ], active);
    expect(severed.activeLinkIds).toEqual([]);
    expect(severed.currentSeveredLinkIds).toEqual(["west_stone_cut_to_ford_toll"]);
    expect(severed.lifetimeSeveredLinkIds).toEqual(["west_stone_cut_to_ford_toll"]);

    const reactivated = resolveLumeNetworkState(network, [
      site("west_stone_cut", "West Stone Cut", "player"),
      site("ford_toll", "Ford Toll", "player"),
      site("north_aether_spring", "North Aether Spring", "neutral")
    ], severed);
    expect(reactivated.activeLinkIds).toEqual(["west_stone_cut_to_ford_toll"]);
    expect(reactivated.currentSeveredLinkIds).toEqual([]);
    expect(reactivated.lifetimeSeveredLinkIds).toEqual(["west_stone_cut_to_ford_toll"]);
  });

  it("keeps Linked Ward non-stacking and local to friendly targets near active endpoints", () => {
    const state = resolveLumeNetworkState(network, [
      site("west_stone_cut", "West Stone Cut", "player", { x: 100, y: 100 }),
      site("ford_toll", "Ford Toll", "player", { x: 260, y: 100 }),
      site("north_aether_spring", "North Aether Spring", "player", { x: 420, y: 100 })
    ]);

    expect(state.activeLinkIds).toEqual(["west_stone_cut_to_ford_toll", "ford_toll_to_north_aether_spring"]);
    expect(isLinkedWardTarget(network, state, [
      site("west_stone_cut", "West Stone Cut", "player", { x: 100, y: 100 }),
      site("ford_toll", "Ford Toll", "player", { x: 260, y: 100 }),
      site("north_aether_spring", "North Aether Spring", "player", { x: 420, y: 100 })
    ], target("player", { x: 145, y: 100 }))).toBe(true);
    expect(isLinkedWardTarget(network, state, [
      site("west_stone_cut", "West Stone Cut", "player", { x: 100, y: 100 }),
      site("ford_toll", "Ford Toll", "player", { x: 260, y: 100 }),
      site("north_aether_spring", "North Aether Spring", "player", { x: 420, y: 100 })
    ], target("enemy", { x: 145, y: 100 }))).toBe(false);
    expect(isLinkedWardTarget(network, state, [
      site("west_stone_cut", "West Stone Cut", "player", { x: 100, y: 100 }),
      site("ford_toll", "Ford Toll", "player", { x: 260, y: 100 }),
      site("north_aether_spring", "North Aether Spring", "player", { x: 420, y: 100 })
    ], target("player", { x: 900, y: 900 }))).toBe(false);
    expect(network.benefit.damageTakenMultiplier).toBe(0.92);
    expect(network.benefit.nonStacking).toBe(true);
  });
});

function site(id: string, name: string, owner: LumeSiteSnapshot["owner"], position = { x: 100, y: 100 }): LumeSiteSnapshot {
  return {
    id,
    name,
    owner,
    alive: true,
    position,
    radius: 76,
    captureProgress: 0,
    capturingTeam: "neutral"
  };
}

function target(team: LumeTargetSnapshot["team"], position: LumeTargetSnapshot["position"]): LumeTargetSnapshot {
  return {
    team,
    position,
    alive: true
  };
}
