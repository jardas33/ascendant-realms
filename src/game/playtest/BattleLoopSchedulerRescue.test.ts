import { describe, expect, it } from "vitest";
import { LUME_NETWORKS } from "../data/lumeNetworks";
import {
  DirtyFlag,
  HiddenPanelWorkGate,
  MinimapInvalidationTracker,
  ReusableObjectPool,
  StableLabelCache,
  V0112_IDLE_COST_CASES,
  V0112_SCHEDULER_MAP,
  createV0112ParitySummary,
  renderAllocationAuditMarkdown,
  renderEmmanuelRetestChecklistMarkdown,
  renderSchedulerMapMarkdown
} from "./BattleLoopSchedulerRescue";

describe("BattleLoopSchedulerRescue", () => {
  it("tracks dirty reasons and clears them after consumption", () => {
    const dirty = new DirtyFlag<"selection" | "fog">("selection");
    dirty.mark("fog");

    expect(dirty.isDirty()).toBe(true);
    expect(dirty.consume().sort()).toEqual(["fog", "selection"]);
    expect(dirty.isDirty()).toBe(false);
  });

  it("resets pooled entries and avoids leaking active objects", () => {
    const pool = new ReusableObjectPool(
      () => ({ label: "", active: false }),
      (entry) => {
        entry.label = "";
        entry.active = false;
      }
    );

    const first = pool.acquire();
    first.label = "capture-ring";
    first.active = true;
    const second = pool.acquire();
    pool.release(first);
    pool.release(second);

    expect(pool.activeCount()).toBe(0);
    expect(pool.freeCount()).toBe(2);
    const reused = pool.acquire();
    expect(reused).toMatchObject({ label: "", active: false });
    expect(pool.activeCount()).toBe(1);
  });

  it("skips hidden panel work and wakes up dirty when shown again", () => {
    const gate = new HiddenPanelWorkGate<string>();
    let builds = 0;

    expect(gate.resolve("hero:1", () => `view-${++builds}`)).toBe("view-1");
    gate.setVisible(false);
    expect(gate.resolve("hero:2", () => `view-${++builds}`)).toBe("view-1");
    gate.setVisible(true);
    expect(gate.resolve("hero:2", () => `view-${++builds}`)).toBe("view-2");
    expect(builds).toBe(2);
  });

  it("invalidates cached labels and minimap signatures", () => {
    const labels = new StableLabelCache<string>();
    let labelBuilds = 0;

    expect(labels.resolve("crown_shrine", "neutral", () => `label-${++labelBuilds}`)).toBe("label-1");
    expect(labels.resolve("crown_shrine", "neutral", () => `label-${++labelBuilds}`)).toBe("label-1");
    labels.invalidate("crown_shrine");
    expect(labels.resolve("crown_shrine", "player", () => `label-${++labelBuilds}`)).toBe("label-2");

    const minimap = new MinimapInvalidationTracker();
    expect(minimap.shouldRefresh("camera-a")).toBe(true);
    expect(minimap.shouldRefresh("camera-a")).toBe(false);
    expect(minimap.shouldRefresh("camera-b")).toBe(true);
    minimap.invalidate();
    expect(minimap.shouldRefresh("camera-b")).toBe(true);
  });

  it("keeps Tier M, Tutorial, save, stable-ID, and linked_ward parity explicit", () => {
    const summary = createV0112ParitySummary();
    const linkedWard = LUME_NETWORKS.find((network) => network.benefit.id === "linked_ward")?.benefit;

    expect(V0112_IDLE_COST_CASES.map((entry) => entry.id)).toContain("v0112_tier_m_combat");
    expect(summary.savesChanged).toBe(false);
    expect(summary.stableIdsChanged).toBe(false);
    expect(summary.pathingOutputsChanged).toBe(false);
    expect(summary.aiDecisionRulesChanged).toBe(false);
    expect(summary.parityChecks.map((entry) => entry.id)).toContain("saves-stable-ids");
    expect(renderEmmanuelRetestChecklistMarkdown()).toContain("Tutorial");
    expect(linkedWard?.damageTakenMultiplier).toBe(0.92);
    expect(summary.linkedWardDamageTakenMultiplier).toBe(0.92);
  });

  it("documents scheduler and allocation scope without save/content expansion", () => {
    expect(V0112_SCHEDULER_MAP.length).toBeGreaterThanOrEqual(16);
    expect(renderSchedulerMapMarkdown()).toContain("does not approve gameplay");
    expect(renderAllocationAuditMarkdown()).toContain("status-empty-carriers");
  });
});
