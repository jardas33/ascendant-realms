import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { generateVisualReviewPack, REQUIRED_REVIEW_SCREEN_GROUPS } from "./VisualReviewPack";

const TMP_ROOT = path.resolve("tmp-test-logs", "visual-review-pack");

afterEach(async () => {
  await rm(TMP_ROOT, { recursive: true, force: true });
});

describe("Visual review pack generator", () => {
  it("generates deterministic review output from the visual QA index and manifest", async () => {
    const fixture = await createFixture();
    const first = await generateVisualReviewPack({
      visualQaIndexPath: fixture.indexPath,
      visualRegressionMatrixPath: fixture.matrixPath,
      screenshotDirectory: fixture.screenshotDir,
      outputDirectory: path.join(fixture.root, "out-a")
    });
    const second = await generateVisualReviewPack({
      visualQaIndexPath: fixture.indexPath,
      visualRegressionMatrixPath: fixture.matrixPath,
      screenshotDirectory: fixture.screenshotDir,
      outputDirectory: path.join(fixture.root, "out-b")
    });

    const firstManifest = await readFile(first.manifestPath, "utf8");
    const secondManifest = await readFile(second.manifestPath, "utf8");
    const firstIndex = await readFile(first.indexPath, "utf8");
    const secondIndex = await readFile(second.indexPath, "utf8");
    expect(firstManifest).toBe(secondManifest);
    expect(firstIndex).toBe(secondIndex);
    expect(first.screenshotCount).toBe(13);
    expect(first.contactSheetCount).toBe(8);
  });

  it("maps manifest entries to screenshot files and keeps source screenshots unchanged", async () => {
    const fixture = await createFixture();
    const sourceBefore = await readFile(path.join(fixture.screenshotDir, "v090-main-menu-1920.png"), "utf8");
    const result = await generateVisualReviewPack({
      visualQaIndexPath: fixture.indexPath,
      visualRegressionMatrixPath: fixture.matrixPath,
      screenshotDirectory: fixture.screenshotDir,
      outputDirectory: path.join(fixture.root, "out")
    });
    const manifest = JSON.parse(await readFile(result.manifestPath, "utf8"));
    const menu = manifest.screenshots.find((entry: { screenshotId: string }) => entry.screenshotId === "v090-main-menu-1920");
    expect(menu.matrixMatched).toBe(true);
    expect(existsSync(path.join(result.outputDirectory, menu.reviewFile))).toBe(true);
    expect(await readFile(path.join(fixture.screenshotDir, "v090-main-menu-1920.png"), "utf8")).toBe(sourceBefore);
  });

  it("fails clearly when a screenshot file is missing", async () => {
    const fixture = await createFixture({ omitScreenshot: "v090-main-menu-1920.png" });
    await expect(
      generateVisualReviewPack({
        visualQaIndexPath: fixture.indexPath,
        visualRegressionMatrixPath: fixture.matrixPath,
        screenshotDirectory: fixture.screenshotDir,
        outputDirectory: path.join(fixture.root, "out")
      })
    ).rejects.toThrow(/Missing screenshot file for v090-main-menu-1920/u);
  });

  it("fails clearly when duplicate screenshot IDs are present", async () => {
    const fixture = await createFixture({ duplicateFirstCapture: true });
    await expect(
      generateVisualReviewPack({
        visualQaIndexPath: fixture.indexPath,
        visualRegressionMatrixPath: fixture.matrixPath,
        screenshotDirectory: fixture.screenshotDir,
        outputDirectory: path.join(fixture.root, "out")
      })
    ).rejects.toThrow(/Duplicate screenshot ID/u);
  });

  it("includes all required screen groups, target viewports, and contact sheets", async () => {
    const fixture = await createFixture();
    const result = await generateVisualReviewPack({
      visualQaIndexPath: fixture.indexPath,
      visualRegressionMatrixPath: fixture.matrixPath,
      screenshotDirectory: fixture.screenshotDir,
      outputDirectory: path.join(fixture.root, "out")
    });
    const html = await readFile(result.indexPath, "utf8");
    REQUIRED_REVIEW_SCREEN_GROUPS.forEach((group) => expect(html).toContain(group));
    ["1920x1080", "1600x900", "1366x768"].forEach((viewport) => expect(html).toContain(viewport));
    [
      "contact-sheets/viewport-1920x1080.html",
      "contact-sheets/viewport-1600x900.html",
      "contact-sheets/viewport-1366x768.html",
      "contact-sheets/campaign-shell.html",
      "contact-sheets/battle-shell.html",
      "contact-sheets/lume-flow.html",
      "contact-sheets/art-slot-fallbacks.html",
      "contact-sheets/results-flow.html"
    ].forEach((file) => expect(existsSync(path.join(result.outputDirectory, file))).toBe(true));
  });
});

async function createFixture(
  options: { omitScreenshot?: string; duplicateFirstCapture?: boolean } = {}
): Promise<{ root: string; screenshotDir: string; indexPath: string; matrixPath: string }> {
  const root = path.join(TMP_ROOT, `fixture-${Date.now()}-${Math.random().toString(16).slice(2)}`);
  const screenshotDir = path.join(root, "visual-qa", "latest");
  const docsDir = path.join(root, "docs");
  await mkdir(screenshotDir, { recursive: true });
  await mkdir(docsDir, { recursive: true });

  const captures = [
    ["v090-main-menu-1920.png", "Main menu", "1920x1080 full-hd", "Desktop title screen."],
    ["v090-fresh-campaign-map-1920.png", "Fresh campaign map", "1920x1080 full-hd", "Campaign map."],
    ["v090-campaign-tab-stronghold-1600.png", "Campaign tab Stronghold", "1600x900 wide-desktop", "Stronghold tab."],
    ["v090-ordinary-battle-start-1920.png", "Ordinary battle start", "1920x1080 full-hd", "Battle HUD."],
    ["v090-selected-units-1600.png", "Selected units", "1600x900 wide-desktop", "Selected army group."],
    ["v090-selected-building-1366.png", "Selected building", "1366x768 laptop", "Selected Command Hall."],
    ["v090-contested-capture-site-1600.png", "Contested capture site", "1600x900 wide-desktop", "Resource-site selection."],
    ["v086-battlefield-shell-1366.png", "Battlefield shell", "1366x768 laptop", "Fog softness and minimap markers."],
    ["v090-lume-inactive-1920.png", "Lume inactive", "1920x1080 full-hd", "Lume controls."],
    ["v090-private-results-compact-1366.png", "Private-demo Results compact", "1366x768 laptop", "Private Results."],
    ["v090-normal-victory-results-1600.png", "Normal Victory Results", "1600x900 wide-desktop", "Normal Results."],
    ["v090-tutorial-1600.png", "Tutorial", "1600x900 wide-desktop", "Tutorial overlay."],
    ["v0106-art-slot-menu-fallback.png", "v0.106 Art Slot menu fallback", "1366x768 laptop", "Runtime art slot fallback diagnostics."]
  ];
  if (options.duplicateFirstCapture) {
    captures.push(captures[0]);
  }

  for (const [fileName] of captures) {
    if (fileName !== options.omitScreenshot) {
      await writeFile(path.join(screenshotDir, fileName), `fake screenshot ${fileName}`, "utf8");
    }
  }

  const indexLines = [
    "# Ascendant Realms Visual QA Capture",
    "",
    "Generated: 2026-05-31T00:00:00.000Z",
    "",
    "## Captures",
    ""
  ];
  captures.forEach(([fileName, title, viewport, note]) => {
    indexLines.push(`- ${title}`);
    indexLines.push("  - Group: `fixture`");
    indexLines.push(`  - File: \`${fileName}\``);
    indexLines.push(`  - Viewport: ${viewport}`);
    indexLines.push("  - Retry used: no");
    indexLines.push("  - Screenshot duration: 1 ms");
    indexLines.push(`  - Note: ${note}`);
  });
  indexLines.push("");
  indexLines.push("## Console Errors");
  indexLines.push("");
  indexLines.push("None recorded.");
  const indexPath = path.join(screenshotDir, "index.md");
  await writeFile(indexPath, `${indexLines.join("\n")}\n`, "utf8");

  const matrix = {
    schemaVersion: 1,
    checkpoint: "v0.90",
    title: "Fixture visual regression matrix",
    updatePolicy: "Do not blindly auto-accept changed screenshots.",
    entries: captures
      .filter(([fileName]) => fileName.startsWith("v090-"))
      .map(([fileName, title, viewport, note]) => ({
        screenshotId: fileName.replace(/\.png$/u, ""),
        route: "fixture-route",
        viewport: viewport.match(/\d+x\d+/u)?.[0] ?? viewport,
        state: title,
        expectedVisibleControls: ["fixture-visible"],
        expectedAbsentControls: ["fixture-absent"],
        reviewNotes: note,
        updateRules: "Update only when fixture changes.",
        owner: "QA",
        lastReviewedCheckpoint: "v0.90"
      }))
  };
  const matrixPath = path.join(docsDir, "V090_VISUAL_REGRESSION_MATRIX.json");
  await writeFile(matrixPath, `${JSON.stringify(matrix, null, 2)}\n`, "utf8");

  return { root, screenshotDir, indexPath, matrixPath };
}
