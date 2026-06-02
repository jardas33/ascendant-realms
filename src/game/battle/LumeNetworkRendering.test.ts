import { describe, expect, it } from "vitest";
import { resolveLumeLinkPresentation } from "./LumeNetworkRendering";

const link = {
  id: "west_stone_cut_to_ford_toll",
  state: "inactive" as const,
  fromSiteId: "west_stone_cut",
  toSiteId: "ford_toll"
};

const baseContext = {
  visibilityMode: "auto" as const,
  privateDemo: false,
  objectiveCompleted: false,
  selectedSiteIds: [],
  firstLinkId: "west_stone_cut_to_ford_toll",
  optionalLinkId: "ford_toll_to_north_aether_spring",
  elapsedSeconds: 12,
  pulsePhase: 0.5
};

describe("LumeNetworkRendering", () => {
  it("hides inactive links in normal Auto mode", () => {
    const visual = resolveLumeLinkPresentation(link, baseContext);

    expect(visual.visible).toBe(false);
    expect(visual.alpha).toBe(0);
  });

  it("shows only the relevant private-demo teaching guide in Auto mode", () => {
    const primary = resolveLumeLinkPresentation(link, {
      ...baseContext,
      privateDemo: true
    });
    const optional = resolveLumeLinkPresentation(
      {
        ...link,
        id: "ford_toll_to_north_aether_spring",
        fromSiteId: "ford_toll",
        toSiteId: "north_aether_spring"
      },
      {
        ...baseContext,
        privateDemo: true
      }
    );

    expect(primary).toMatchObject({ visible: true, style: "guide", emphasis: "teaching" });
    expect(primary.alpha).toBeLessThanOrEqual(0.18);
    expect(optional.visible).toBe(false);
  });

  it("hides stable active links in Auto after transition pulses and keeps Always readable", () => {
    const activeLink = { ...link, state: "active" as const };
    const auto = resolveLumeLinkPresentation(activeLink, baseContext);
    const always = resolveLumeLinkPresentation(activeLink, {
      ...baseContext,
      visibilityMode: "always"
    });

    expect(auto.visible).toBe(false);
    expect(always.alpha).toBeGreaterThan(auto.alpha);
  });

  it("reveals active links in Auto when a relevant endpoint is selected", () => {
    const activeLink = { ...link, state: "active" as const };
    const visual = resolveLumeLinkPresentation(activeLink, {
      ...baseContext,
      selectedSiteIds: ["west_stone_cut"]
    });

    expect(visual).toMatchObject({ visible: true, style: "highlight", emphasis: "selected" });
    expect(visual.alpha).toBeGreaterThan(0.4);
  });

  it("lets Hidden suppress stable links while preserving transition pulses", () => {
    const hiddenStable = resolveLumeLinkPresentation({ ...link, state: "active" as const }, {
      ...baseContext,
      visibilityMode: "hidden"
    });
    const hiddenPulse = resolveLumeLinkPresentation({ ...link, state: "active" as const }, {
      ...baseContext,
      visibilityMode: "hidden",
      pulse: {
        kind: "activated",
        startedAtSeconds: 11,
        durationSeconds: 2.8
      }
    });

    expect(hiddenStable.visible).toBe(false);
    expect(hiddenPulse).toMatchObject({ visible: true, style: "highlight", emphasis: "pulse", pulseKind: "activated" });
  });

  it("uses amber and red for contested and severed pulses", () => {
    const contested = resolveLumeLinkPresentation({ ...link, state: "contested" as const }, {
      ...baseContext,
      pulse: {
        kind: "contested",
        startedAtSeconds: 11,
        durationSeconds: 2.8
      }
    });
    const severed = resolveLumeLinkPresentation({ ...link, state: "severed" as const }, {
      ...baseContext,
      pulse: {
        kind: "severed",
        startedAtSeconds: 11,
        durationSeconds: 2.8
      }
    });

    expect(contested).toMatchObject({ visible: true, style: "contested", color: 0xf0d978 });
    expect(severed).toMatchObject({ visible: true, style: "severed", color: 0xff6b6b });
  });
});
