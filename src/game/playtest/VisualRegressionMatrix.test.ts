import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

type VisualRegressionEntry = {
  screenshotId: string;
  route: string;
  viewport: string;
  state: string;
  expectedVisibleControls: string[];
  expectedAbsentControls: string[];
  reviewNotes: string;
  updateRules: string;
  owner: string;
  lastReviewedCheckpoint: string;
};

type VisualRegressionMatrix = {
  schemaVersion: number;
  checkpoint: string;
  title: string;
  updatePolicy: string;
  entries: VisualRegressionEntry[];
};

function loadMatrix(): VisualRegressionMatrix {
  return JSON.parse(readFileSync(resolve("docs", "V090_VISUAL_REGRESSION_MATRIX.json"), "utf8")) as VisualRegressionMatrix;
}

describe("V090 visual regression matrix", () => {
  it("keeps deterministic screenshot metadata for the desktop acceptance harness", () => {
    const matrix = loadMatrix();
    expect(matrix.schemaVersion).toBe(1);
    expect(matrix.checkpoint).toBe("v0.90");
    expect(matrix.updatePolicy).toContain("Do not blindly auto-accept");
    expect(matrix.entries).toHaveLength(28);

    const ids = matrix.entries.map((entry) => entry.screenshotId);
    expect(new Set(ids).size).toBe(ids.length);
    for (const entry of matrix.entries) {
      expect(entry.screenshotId).toMatch(/^v090-[a-z0-9-]+$/u);
      expect(entry.route.trim().length).toBeGreaterThan(0);
      expect(entry.viewport).toMatch(/^\d+x\d+$/u);
      expect(entry.state.trim().length).toBeGreaterThan(0);
      expect(entry.expectedVisibleControls.length, `${entry.screenshotId} visible controls`).toBeGreaterThan(0);
      expect(entry.reviewNotes.trim().length).toBeGreaterThan(20);
      expect(entry.updateRules).toContain("Update only");
      expect(entry.owner).toBe("QA");
      expect(entry.lastReviewedCheckpoint).toBe("v0.90");
    }
  });

  it("covers the required v0.90 viewport and screen-state matrix", () => {
    const entries = loadMatrix().entries;
    const viewports = [...new Set(entries.map((entry) => entry.viewport))];
    expect(viewports).toEqual(expect.arrayContaining(["1920x1080", "1600x900", "1366x768"]));

    const ids = new Set(entries.map((entry) => entry.screenshotId));
    [
      "v090-main-menu-1920",
      "v090-fresh-campaign-map-1920",
      "v090-fresh-campaign-map-1366",
      "v090-selected-unlocked-mission-1920",
      "v090-selected-locked-mission-1366",
      "v090-campaign-tab-map-1600",
      "v090-campaign-tab-stronghold-1600",
      "v090-campaign-tab-hero-1600",
      "v090-campaign-tab-inventory-1600",
      "v090-campaign-tab-intel-1600",
      "v090-campaign-tab-reputation-1600",
      "v090-ordinary-battle-start-1920",
      "v090-selected-units-1600",
      "v090-selected-building-1366",
      "v090-contested-capture-site-1600",
      "v090-lume-inactive-1920",
      "v090-lume-active-stable-1920",
      "v090-lume-selected-highlighted-1600",
      "v090-lume-hidden-1366",
      "v090-lume-always-visible-1366",
      "v090-private-results-compact-1366",
      "v090-private-results-expanded-1366",
      "v090-normal-victory-results-1600",
      "v090-normal-defeat-results-1366",
      "v090-replay-results-1600",
      "v090-tutorial-1600"
    ].forEach((id) => expect(ids.has(id), `missing matrix entry ${id}`).toBe(true));
  });
});
