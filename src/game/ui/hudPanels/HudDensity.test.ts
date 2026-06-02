import { describe, expect, it } from "vitest";
import {
  createHudDensityControls,
  normalizeHudDensityMode,
  shouldRenderHudDebugCounters
} from "./HudDensity";

describe("HudDensity", () => {
  it("keeps public battle HUD density minimal and hides private controls", () => {
    expect(normalizeHudDensityMode(undefined, false)).toBe("minimal");
    expect(normalizeHudDensityMode("debug", false)).toBe("minimal");
    expect(createHudDensityControls("minimal", false)).toEqual([]);
    expect(shouldRenderHudDebugCounters("debug", false)).toBe(false);
  });

  it("keeps Standard and Debug private-only, session-only controls", () => {
    const controls = createHudDensityControls("standard", true);

    expect(normalizeHudDensityMode(undefined, true)).toBe("standard");
    expect(normalizeHudDensityMode("debug", true)).toBe("debug");
    expect(controls.map((control) => control.mode)).toEqual(["minimal", "standard", "debug"]);
    expect(controls.find((control) => control.mode === "standard")?.active).toBe(true);
    expect(shouldRenderHudDebugCounters("debug", true)).toBe(true);
  });
});
