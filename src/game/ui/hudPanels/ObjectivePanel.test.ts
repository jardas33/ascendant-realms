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
});
