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
      title: "LUME WARD",
      objective: "Capture West Stone Cut",
      status: "LUME LINKS 0/2",
      benefit: "Friendly units and buildings near active linked sites take 8% less incoming damage.",
      counterplay: "Enemy recapture severs the link; retake both endpoints to restore it.",
      activeLinkCount: 0,
      maxActiveLinks: 2,
      progressLabel: "LUME LINKS 0/2",
      visibilityMode: "auto",
      visibilityLabel: "Auto",
      visibilityControls: [
        { mode: "auto", label: "Auto", active: true, description: "Show contextual links only." },
        { mode: "always", label: "Always", active: false, description: "Keep eligible links visible." },
        { mode: "hidden", label: "Hidden", active: false, description: "Hide stable links." }
      ]
    });

    expect(html).toContain('data-testid="lume-network-status"');
    expect(html).toContain("LUME WARD");
    expect(html).toContain("Capture West Stone Cut");
    expect(html).toContain("LUME LINKS 0/2");
    expect(html).toContain('data-testid="lume-links-progress"');
    expect(html).toContain('data-testid="lume-visibility-controls"');
    expect(html).toContain('data-testid="lume-visibility-auto"');
    expect(html).toContain('aria-pressed="true"');
    expect(html).not.toContain("Objectives 0/0");
    expect(html).toContain("8% less incoming damage");
  });

  it("renders private Lume demo focus, finish, and exit controls after activation", () => {
    const html = renderObjectives(
      [],
      undefined,
      undefined,
      {
        title: "LUME WARD ACTIVE",
        objective: "West Stone Cut ↔ Ford Toll",
        status: "Nearby allies take 8% less damage",
        benefit: "Friendly units and buildings near active linked sites take 8% less incoming damage.",
        counterplay: "Enemy recapture severs the link; retake both endpoints to restore it.",
        activeLinkCount: 1,
        maxActiveLinks: 2,
        progressLabel: "LUME LINKS 1/2",
        optionalSiteName: "North Aether Spring",
        privateDemo: true,
        finishDemoAvailable: true,
        focusControls: [
          { siteId: "west_stone_cut", siteName: "West Stone Cut", label: "Focus West Stone Cut" },
          { siteId: "ford_toll", siteName: "Ford Toll", label: "Focus Ford Toll" },
          { siteId: "north_aether_spring", siteName: "North Aether Spring", label: "Focus North Aether Spring" }
        ]
      },
      "Private playtest demo: rewards and campaign progress are disabled for this Aether Well Lume run."
    );

    expect(html).toContain("PRIVATE DEMO - rewards and campaign progress disabled");
    expect(html).toContain('data-testid="lume-focus-west_stone_cut"');
    expect(html).toContain('data-testid="lume-focus-ford_toll"');
    expect(html).toContain('data-testid="lume-focus-north_aether_spring"');
    expect(html).toContain('data-testid="private-demo-exit"');
    expect(html).toContain('data-testid="private-demo-finish"');
    expect(html).toContain("OPTIONAL LINK");
  });
});
