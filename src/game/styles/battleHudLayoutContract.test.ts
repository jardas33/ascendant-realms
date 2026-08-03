import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";

const battleHudCss = readFileSync(fileURLToPath(new URL("./battle-hud.css", import.meta.url)), "utf8");
const responsiveCss = readFileSync(fileURLToPath(new URL("./responsive.css", import.meta.url)), "utf8");

describe("battle HUD safe-layout contract", () => {
  it("keeps player-facing gutters safe-area aware and dense panels internally reachable", () => {
    expect(battleHudCss).toContain("--hud-safe-top: max(12px, env(safe-area-inset-top, 0px))");
    expect(battleHudCss).toContain("--hud-safe-right: max(12px, env(safe-area-inset-right, 0px))");
    expect(battleHudCss).toContain("--hud-safe-bottom: max(12px, env(safe-area-inset-bottom, 0px))");
    expect(battleHudCss).toContain("--hud-safe-left: max(12px, env(safe-area-inset-left, 0px))");
    expect(battleHudCss).toContain("top: var(--hud-safe-top);");
    expect(battleHudCss).toContain("right: var(--hud-safe-right);");
    expect(battleHudCss).toContain("bottom: var(--hud-safe-bottom);");
    expect(battleHudCss).toContain("max-height: min(220px, calc(100vh - var(--hud-safe-top) - var(--hud-safe-bottom) - 164px));");
    expect(battleHudCss).toContain("max-height: min(164px, calc(100vh - var(--hud-safe-top) - var(--hud-safe-bottom) - 96px));");

    const objectivesBlock = battleHudCss.slice(battleHudCss.indexOf(".objectives-panel {"), battleHudCss.indexOf(".objectives-panel > strong"));
    const heroBlock = battleHudCss.slice(battleHudCss.indexOf(".hero-panel {"), battleHudCss.indexOf(".portrait {"));
    expect(objectivesBlock).toContain("overflow: auto;");
    expect(objectivesBlock).toContain("scrollbar-gutter: stable;");
    expect(heroBlock).toContain("overflow: auto;");
    expect(heroBlock).toContain("scrollbar-gutter: stable;");
    expect(responsiveCss).toContain("right: max(8px, env(safe-area-inset-right, 0px));");
    expect(responsiveCss).toContain("left: max(8px, env(safe-area-inset-left, 0px));");
    expect(responsiveCss).toContain("bottom: calc(110px + env(safe-area-inset-bottom, 0px));");
    expect(responsiveCss).toContain("top: calc(202px + env(safe-area-inset-top, 0px));");
    expect(responsiveCss).toContain("bottom: calc(100px + env(safe-area-inset-bottom, 0px));");
  });
});
