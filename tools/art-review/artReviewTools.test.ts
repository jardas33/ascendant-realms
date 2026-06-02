import { mkdirSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { createCandidateMetadataTemplate } from "../../src/game/art/VisualAssetReviewRegistry";
import { generateArtReviewContactSheet } from "./generateArtReviewContactSheet";
import { generateArtReviewReport } from "./generateArtReviewReport";
import { initializeArtReviewWorkspace, loadVisualAssetRegistry, workspacePaths } from "./shared";
import { validateArtReviewWorkspace } from "./validateArtReview";

const ASSET_ID = "v088_salto_environment_style_frame";

describe("v0.105 art review tooling", () => {
  it("initializes a candidate review workspace with templates", async () => {
    const projectRoot = createTempProject();
    const result = await initializeArtReviewWorkspace(projectRoot, ASSET_ID);

    expect(result.asset.assetId).toBe(ASSET_ID);
    expect(readFileSync(result.paths.metadataPath, "utf8")).toContain(`"assetId": "${ASSET_ID}"`);
    expect(readFileSync(result.paths.promptReferencePath, "utf8")).toContain('"reviewPurpose": "reference-only:not-runtime"');
    expect(readFileSync(result.paths.reviewerChecklistPath, "utf8")).toContain("style-approved");

    const validation = await validateArtReviewWorkspace(projectRoot);
    expect(validation.errors).toEqual([]);
    expect(validation.checkedCandidateMetadataFiles).toBe(1);
  });

  it("generates a safe empty contact sheet when no candidates exist", async () => {
    const projectRoot = createTempProject();
    await initializeArtReviewWorkspace(projectRoot, ASSET_ID);

    const result = await generateArtReviewContactSheet(projectRoot, ASSET_ID);
    const svg = readFileSync(result.svgPath, "utf8");

    expect(result.imageCount).toBe(0);
    expect(svg).toContain("No candidates found in images workspace.");
    expect(svg).toContain(ASSET_ID);
  });

  it("labels manually placed candidates in a contact sheet", async () => {
    const projectRoot = createTempProject();
    const registry = await loadVisualAssetRegistry(projectRoot);
    const asset = registry.assets.find((candidate) => candidate.assetId === ASSET_ID);
    expect(asset).toBeDefined();
    const paths = workspacePaths(projectRoot, ASSET_ID);
    await initializeArtReviewWorkspace(projectRoot, ASSET_ID);
    writeFileSync(path.join(paths.imagesDir, "candidate-a.png"), tinyPng());

    const metadata = createCandidateMetadataTemplate(asset!);
    metadata.reviewState = "candidate-ready";
    metadata.candidateFiles = [{ filename: "candidate-a.png", promptVersion: asset!.promptVersion, reviewStatus: "candidate-ready" }];
    metadata.source = {
      tool: "manual-generation-tool",
      model: "review-model-v1",
      generatedBy: "Emmanuel",
      generatedAtUtc: "2026-06-02T00:00:00Z",
      sourceType: "generated",
      notes: "No external source images were used."
    };
    metadata.license = {
      terms: "User-controlled generated output for reference review.",
      usagePermission: "reference-only:not-runtime"
    };
    metadata.protectedIp = {
      assessment: "Original prompt with no protected franchise, artist, logo, UI, or faction imitation.",
      risk: "low",
      notes: "Review remains required before style approval."
    };
    writeFileSync(paths.metadataPath, `${JSON.stringify(metadata, null, 2)}\n`);

    const validation = await validateArtReviewWorkspace(projectRoot);
    expect(validation.errors).toEqual([]);

    const result = await generateArtReviewContactSheet(projectRoot, ASSET_ID);
    const svg = readFileSync(result.svgPath, "utf8");

    expect(result.imageCount).toBe(1);
    expect(svg).toContain("candidate-a.png");
    expect(svg).toContain("1x1");
    expect(svg).toContain(ASSET_ID);
    expect(svg).toContain(asset!.promptVersion);
  });

  it("generates deterministic review reports", async () => {
    const projectRoot = createTempProject();
    await initializeArtReviewWorkspace(projectRoot, ASSET_ID);
    await generateArtReviewContactSheet(projectRoot, ASSET_ID);

    const first = await generateArtReviewReport(projectRoot, ASSET_ID);
    const firstMarkdown = readFileSync(first.markdownPath, "utf8");
    const firstJson = readFileSync(first.jsonPath, "utf8");
    const second = await generateArtReviewReport(projectRoot, ASSET_ID);

    expect(readFileSync(second.markdownPath, "utf8")).toBe(firstMarkdown);
    expect(readFileSync(second.jsonPath, "utf8")).toBe(firstJson);
  });

  it("keeps generated workspace files out of runtime asset paths", async () => {
    const projectRoot = createTempProject();
    const result = await initializeArtReviewWorkspace(projectRoot, ASSET_ID);
    const generatedPaths = [
      result.paths.candidateDir,
      result.paths.contactSheetDir,
      result.paths.reportDir,
      result.paths.metadataPath,
      result.paths.promptReferencePath,
      result.paths.reviewerChecklistPath
    ].map((filePath) => filePath.replaceAll("\\", "/"));

    expect(generatedPaths.every((filePath) => filePath.includes("/artifacts/art-review/"))).toBe(true);
    expect(generatedPaths.some((filePath) => filePath.includes("/public/assets/"))).toBe(false);
    expect(generatedPaths.some((filePath) => filePath.includes("/src/game/assets/"))).toBe(false);
  });
});

function createTempProject(): string {
  const projectRoot = mkdtempSync(path.join(tmpdir(), "ascendant-realms-art-review-"));
  copyFixture(projectRoot, "src/game/art/visual-asset-registry.json");
  copyFixture(projectRoot, "src/game/art/visual-asset-registry.schema.json");
  copyFixture(projectRoot, "docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json");
  return projectRoot;
}

function copyFixture(projectRoot: string, relativePath: string): void {
  const target = path.join(projectRoot, relativePath);
  mkdirSync(path.dirname(target), { recursive: true });
  writeFileSync(target, readFileSync(path.join(process.cwd(), relativePath)));
}

function tinyPng(): Buffer {
  return Buffer.from(
    "89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000a49444154789c6300010000050001a0f64540000000049454e44ae426082",
    "hex"
  );
}
