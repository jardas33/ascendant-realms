import { mkdirSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { generateReferenceArtContactSheet } from "./generateReferenceArtContactSheet";
import { generateReferenceArtReviewPack } from "./generateReferenceArtReviewPack";
import {
  initializeReferenceArtWorkspace,
  referenceWorkspacePaths,
  type ReferenceCandidateMetadata
} from "./shared";
import { validateReferenceArtWorkspace } from "./validateReferenceArt";

describe("v0.138 reference-art tooling", () => {
  it("initializes the ignored workspace layout with a local README", async () => {
    const projectRoot = createTempProject();
    const paths = await initializeReferenceArtWorkspace(projectRoot);

    expect(readFileSync(paths.readmePath, "utf8")).toContain("v0.138 Reference-Art Workspace");
    expect(paths.candidatesDir.replaceAll("\\", "/")).toContain("artifacts/art-review/v0138/candidates");
    expect(paths.contactSheetsDir.replaceAll("\\", "/")).toContain("artifacts/art-review/v0138/contact-sheets");
    expect(paths.metadataDir.replaceAll("\\", "/")).toContain("artifacts/art-review/v0138/metadata");
    expect(paths.reviewNotesDir.replaceAll("\\", "/")).toContain("artifacts/art-review/v0138/review-notes");
  });

  it("reports a clear pending state when no candidates exist", async () => {
    const projectRoot = createTempProject();
    await initializeReferenceArtWorkspace(projectRoot);

    const validation = await validateReferenceArtWorkspace(projectRoot);
    const contactSheet = await generateReferenceArtContactSheet(projectRoot);
    const reviewPack = await generateReferenceArtReviewPack(projectRoot);

    expect(validation.errors).toEqual([]);
    expect(validation.status).toBe("PENDING_V0138_REFERENCE_ART_CANDIDATES");
    expect(contactSheet.status).toBe("PENDING_V0138_CONTACT_SHEET_NO_CANDIDATES");
    expect(readFileSync(contactSheet.svgPath, "utf8")).toContain("Pending candidate images");
    expect(reviewPack.status).toBe("PENDING_V0138_REFERENCE_REVIEW_PACK_NO_CANDIDATES");
  });

  it("validates a manually placed reference candidate and metadata record", async () => {
    const projectRoot = createTempProject();
    const paths = referenceWorkspacePaths(projectRoot);
    await initializeReferenceArtWorkspace(projectRoot);
    const imagePath = path.join(paths.candidatesDir, "aster-a.png");
    writeFileSync(imagePath, tinyPng());
    writeFileSync(path.join(paths.metadataDir, "aster-a.json"), `${JSON.stringify(validMetadata(), null, 2)}\n`);

    const validation = await validateReferenceArtWorkspace(projectRoot);
    const contactSheet = await generateReferenceArtContactSheet(projectRoot);

    expect(validation.errors).toEqual([]);
    expect(validation.status).toBe("PASS_V0138_REFERENCE_METADATA");
    expect(contactSheet.status).toBe("PASS_V0138_REFERENCE_CONTACT_SHEET");
    expect(readFileSync(contactSheet.svgPath, "utf8")).toContain("aster-a.png");
  });

  it("blocks metadata that tries to permit runtime integration", async () => {
    const projectRoot = createTempProject();
    const paths = referenceWorkspacePaths(projectRoot);
    await initializeReferenceArtWorkspace(projectRoot);
    writeFileSync(
      path.join(paths.metadataDir, "bad-runtime.json"),
      `${JSON.stringify({ ...validMetadata(), runtimeIntegrationStatus: "approved" }, null, 2)}\n`
    );

    const validation = await validateReferenceArtWorkspace(projectRoot);

    expect(validation.status).toBe("FAIL_V0138_REFERENCE_METADATA");
    expect(validation.errors.map((issue) => issue.message)).toContain(
      "runtimeIntegrationStatus must remain exactly `forbidden`."
    );
  });
});

function createTempProject(): string {
  return mkdtempSync(path.join(tmpdir(), "ascendant-realms-art-reference-"));
}

function validMetadata(): ReferenceCandidateMetadata {
  return {
    schemaVersion: 1,
    candidateId: "aster-a",
    briefId: "V0138_03_ASTER_HERO_SILHOUETTE_SHEET",
    purpose: "Reference-only Aster silhouette review.",
    generator: "external-gpt-image-generation",
    model: "review-model",
    date: "2026-06-06",
    source: {
      type: "generated-reference",
      promptDocument: "docs/art-prompts/V0138_03_ASTER_HERO_SILHOUETTE_SHEET.md",
      candidateImagePath: "artifacts/art-review/v0138/candidates/aster-a.png",
      notes: "Generated from the v0.138 copy-ready prompt without external source images."
    },
    licencePosture: {
      status: "user-controlled-reference",
      terms: "Reference review only.",
      runtimeUse: "forbidden",
      notes: "No runtime rights are granted in v0.138."
    },
    protectedIpReview: {
      status: "clear",
      protectedLookalikeRisk: "low",
      notes: "No protected faction, logo, UI, character, or artist imitation."
    },
    visualNotes: ["Readable cloak and staff silhouette at fixed-camera RTS distance."],
    humanStatus: "pending-review",
    runtimeIntegrationStatus: "forbidden",
    hash: {
      algorithm: "sha256",
      value: "0812a88dcb9c129ce1d81a5aefad0ea87f67b24fc11ef750a1edef68cf2609c5"
    },
    dimensions: { width: 1, height: 1, unit: "px" },
    aspect: "1:1",
    revisionLineage: { parentCandidateId: null, revision: 1, notes: "First candidate." }
  };
}

function tinyPng(): Buffer {
  return Buffer.from(
    "89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000a49444154789c6300010000050001a0f64540000000049454e44ae426082",
    "hex"
  );
}
