import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";
import {
  createCandidateMetadataTemplate,
  validateArtReviewCandidateMetadata,
  validateVisualAssetRegistryDocument,
  type ArtReviewCandidateMetadata,
  type VisualAssetRegistry,
  type VisualAssetRegistryEntry,
  type V088AssetManifest
} from "./VisualAssetReviewRegistry";

const registry = readJson<VisualAssetRegistry>("src/game/art/visual-asset-registry.json");
const registrySchema = readJson<Record<string, unknown>>("src/game/art/visual-asset-registry.schema.json");
const v088Manifest = readJson<V088AssetManifest>("docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json");

describe("v0.105 visual asset registry", () => {
  it("ships a valid schema and registry document", () => {
    expect(registrySchema.$schema).toBe("https://json-schema.org/draft/2020-12/schema");
    expect(registrySchema.title).toBe("Ascendant Realms Visual Asset Registry");

    const result = validateVisualAssetRegistryDocument(registry, v088Manifest);

    expect(result.errors).toEqual([]);
  });

  it("keeps deterministic asset ordering", () => {
    const assetIds = registry.assets.map((asset) => asset.assetId);
    const sortedAssetIds = [...assetIds].sort((left, right) => left.localeCompare(right));

    expect(assetIds).toEqual(sortedAssetIds);
  });

  it("preserves all v0.88 asset IDs", () => {
    const registryIds = new Set(registry.assets.map((asset) => asset.assetId));
    const manifestIds = v088Manifest.assets.map((asset) => String(asset.assetId));

    expect(manifestIds.every((assetId) => registryIds.has(assetId))).toBe(true);
  });

  it("rejects a registry missing a v0.88 asset", () => {
    const missingOne: VisualAssetRegistry = {
      ...registry,
      assets: registry.assets.filter((asset) => asset.assetId !== "v088_hud_frame_style_frame")
    };

    const result = validateVisualAssetRegistryDocument(missingOne, v088Manifest);

    expect(result.errors.map((issue) => issue.message)).toContain(
      "Registry is missing v0.88 asset ID v088_hud_frame_style_frame."
    );
  });

  it("rejects duplicate asset IDs", () => {
    const duplicate: VisualAssetRegistry = {
      ...registry,
      assets: [...registry.assets, { ...registry.assets[0] }]
    };

    const result = validateVisualAssetRegistryDocument(duplicate, v088Manifest);

    expect(result.errors.map((issue) => issue.message)).toContain(
      `Duplicate visual asset registry assetId: ${registry.assets[0].assetId}.`
    );
  });

  it("keeps registry review paths away from runtime asset paths", () => {
    const runtimePathFragments = ["public/assets", "src/game/assets"];

    expect(
      registry.assets.some((asset) =>
        Object.values(asset.reviewWorkspace).some((workspacePath) =>
          runtimePathFragments.some((fragment) => workspacePath.includes(fragment))
        )
      )
    ).toBe(false);
  });
});

describe("v0.105 art review candidate metadata", () => {
  it("rejects unclear candidate license terms", () => {
    const metadata = candidateReadyMetadata(registry.assets[0]);
    metadata.license.terms = "unclear";

    const result = validateArtReviewCandidateMetadata(metadata, registry);

    expect(result.errors.map((issue) => issue.message)).toContain("candidate-ready candidates must have clear license terms.");
  });

  it("rejects missing prompt version", () => {
    const metadata = candidateReadyMetadata(registry.assets[0]);
    metadata.prompt.promptVersion = "";

    const result = validateArtReviewCandidateMetadata(metadata, registry);

    expect(result.errors.map((issue) => issue.message)).toContain("Candidate metadata is missing prompt version.");
  });

  it("rejects missing protected-IP assessment", () => {
    const metadata = candidateReadyMetadata(registry.assets[0]);
    metadata.protectedIp.assessment = "";

    const result = validateArtReviewCandidateMetadata(metadata, registry);

    expect(result.errors.map((issue) => issue.message)).toContain(
      "candidate-ready candidates must include a protected-IP assessment."
    );
  });

  it("keeps style-approved candidates non-runtime", () => {
    const metadata = candidateReadyMetadata(registry.assets[0]);
    metadata.reviewState = "style-approved";
    metadata.humanReview.reviewer = "Emmanuel";
    metadata.humanReview.status = "style-approved";
    metadata.runtimeSlotPosture.posture = "future-runtime-candidate:not-integrated";

    const result = validateArtReviewCandidateMetadata(metadata, registry);

    expect(result.errors.map((issue) => issue.message)).toContain(
      "style-approved remains reference-only and must not be marked runtime-ready."
    );
  });

  it("rejects runtime-integrated without future integration proof", () => {
    const metadata = candidateReadyMetadata(registry.assets[0]);
    metadata.reviewState = "runtime-integrated";
    metadata.humanReview.reviewer = "Emmanuel";
    metadata.humanReview.status = "runtime-integrated";
    metadata.runtimeSlotPosture.posture = "future-runtime-candidate:not-integrated";
    metadata.integrationReadiness = "ready-for-future-runtime-integration-gate";

    const result = validateArtReviewCandidateMetadata(metadata, registry);

    expect(result.errors.map((issue) => issue.message)).toContain("runtime-integrated requires future integration proof.");
  });
});

function candidateReadyMetadata(asset: VisualAssetRegistryEntry): ArtReviewCandidateMetadata {
  const metadata = createCandidateMetadataTemplate(asset);
  return {
    ...metadata,
    reviewState: "candidate-ready",
    candidateFiles: [{ filename: "candidate-a.png", promptVersion: asset.promptVersion, reviewStatus: "candidate-ready" }],
    source: {
      tool: "manual-generation-tool",
      model: "review-model-v1",
      generatedBy: "Emmanuel",
      generatedAtUtc: "2026-06-02T00:00:00Z",
      sourceType: "generated",
      notes: "No external source images were used."
    },
    license: {
      terms: "User-controlled generated output for reference review.",
      usagePermission: "reference-only:not-runtime"
    },
    protectedIp: {
      assessment: "Original prompt with no protected franchise, artist, logo, UI, or faction imitation.",
      risk: "low",
      notes: "Review remains required before style approval."
    },
    humanReview: {
      reviewer: "",
      reviewedAtUtc: "",
      status: "not-reviewed",
      summary: ""
    }
  };
}

function readJson<T>(relativePath: string): T {
  return JSON.parse(readFileSync(path.join(process.cwd(), relativePath), "utf8")) as T;
}
