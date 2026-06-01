import { describe, expect, it } from "vitest";
import { renderOnboardingHelpSurface } from "./OnboardingHelp";

describe("OnboardingHelp", () => {
  it("renders compact first-session help groups without Lume by default", () => {
    const html = renderOnboardingHelpSurface({ testId: "help" });

    expect(html).toContain('data-testid="help"');
    expect(html).toContain("Camera");
    expect(html).toContain("Selection");
    expect(html).toContain("Workers And Sites");
    expect(html).toContain("Control Groups");
    expect(html).not.toContain("Lume links");
  });

  it("renders Lume help only when the caller marks it relevant", () => {
    const html = renderOnboardingHelpSurface({ testId: "help", includeLume: true });

    expect(html).toContain("Lume");
    expect(html).toContain("eligible missions");
  });
});
