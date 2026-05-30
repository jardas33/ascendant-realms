import { describe, expect, it } from "vitest";
import { renderObjectives } from "./ObjectivePanel";

describe("ObjectivePanel", () => {
  it("marks the first unfinished objective as the next action", () => {
    const html = renderObjectives([
      {
        id: "capture_site",
        name: "Capture The Road",
        description: "Claim the road income first.",
        completed: true
      },
      {
        id: "clear_camp",
        name: "Clear Camp",
        description: "Break the nearby raiders.",
        completed: false
      },
      {
        id: "destroy_tower",
        name: "Destroy Tower",
        description: "Bring down the watchtower.",
        completed: false
      }
    ]);

    expect(html).toContain("Objectives 1/3");
    expect(html).toContain("Done");
    expect(html).toContain("Next");
    expect(html).toContain("Open");
    expect(html).toContain('data-objective-id="clear_camp"');
    expect(html).toContain('class="objective-row current"');
  });

  it("renders enemy doctrine counterplay inside the objective surface", () => {
    const html = renderObjectives([], {
      name: "Raider",
      status: "Raider doctrine: economy pressure",
      warning: "Raiders will look for exposed Workers and resource sites.",
      counterplay: "Protect sites with Militia screens.",
      elite: "Elite Vanguard"
    });

    expect(html).toContain('data-testid="enemy-doctrine-status"');
    expect(html).toContain("Raider doctrine: economy pressure");
    expect(html).toContain("Counterplay: Protect sites");
    expect(html).toContain("Elite: Elite Vanguard");
    expect(html).toContain("Objectives 0/0");
  });

  it("renders a dynamic battlefield event with plan support", () => {
    const html = renderObjectives([], undefined, {
      title: "Site Under Threat",
      objective: "Hold Crown Shrine",
      progress: "Held - 24s",
      counterplay: "Screen the site with Militia.",
      remainingSeconds: 24,
      planMatched: true
    });

    expect(html).toContain('data-testid="battlefield-event-status"');
    expect(html).toContain("Site Under Threat");
    expect(html).toContain("Hold Crown Shrine - Held - 24s");
    expect(html).toContain("Counterplay: Screen the site");
    expect(html).toContain("Plan support: active");
  });

  it("renders a compact Lume Network row in the objective surface", () => {
    const html = renderObjectives([], undefined, undefined, {
      title: "Linked Ward",
      objective: "Hold West Stone Cut and Ford Toll.",
      status: "Inactive",
      benefit: "Friendly units and buildings near active linked sites take 8% less incoming damage.",
      counterplay: "Enemy recapture severs the link; retake both endpoints to restore it.",
      activeLinkCount: 0,
      maxActiveLinks: 2
    });

    expect(html).toContain('data-testid="lume-network-status"');
    expect(html).toContain("Linked Ward - Inactive");
    expect(html).toContain("Hold West Stone Cut and Ford Toll.");
    expect(html).toContain("8% less incoming damage");
    expect(html).toContain("Counterplay: Enemy recapture severs the link");
  });
});
