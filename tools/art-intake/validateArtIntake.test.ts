import { mkdtempSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { validateArtIntake, validateCandidateMetadataRecord } from "./validateArtIntake";

const validRecord = {
  candidateId: "cinderfen_test_candidate",
  sourceType: "user-generated",
  createdBy: "Emmanuel",
  licenseStatus: "user-owned",
  usagePermission: "Non-runtime review only.",
  protectedIpRisk: "low",
  relatedSpecDoc: "docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md",
  reviewStatus: "candidate",
  productionApprovalStatus: "not-approved"
};

describe("validateCandidateMetadataRecord", () => {
  it("accepts a conservative metadata record", () => {
    const result = validateCandidateMetadataRecord(validRecord, "candidate.json", process.cwd());

    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it("fails when candidateId is missing", () => {
    const result = validateCandidateMetadataRecord({ ...validRecord, candidateId: "" }, "candidate.json", process.cwd());

    expect(result.errors.map((issue) => issue.message)).toContain("Candidate metadata is missing candidateId.");
  });

  it("fails when sourceType is missing", () => {
    const result = validateCandidateMetadataRecord({ ...validRecord, sourceType: "" }, "candidate.json", process.cwd());

    expect(result.errors.map((issue) => issue.message)).toContain("Candidate metadata is missing sourceType.");
  });

  it("blocks production approval for unknown source", () => {
    const result = validateCandidateMetadataRecord(
      { ...validRecord, sourceType: "unknown", productionApprovalStatus: "approved" },
      "candidate.json",
      process.cwd()
    );

    expect(result.errors.map((issue) => issue.message)).toContain(
      "Candidate with unknown sourceType must not be production-approved."
    );
  });

  it("blocks approved candidates with high protected IP risk", () => {
    const result = validateCandidateMetadataRecord(
      { ...validRecord, protectedIpRisk: "high", reviewStatus: "approved-for-prototype" },
      "candidate.json",
      process.cwd()
    );

    expect(result.errors.map((issue) => issue.message)).toContain(
      "Candidate with high or unknown protectedIpRisk must not be approved."
    );
  });

  it("requires source and license fields for runtime-test approval", () => {
    const result = validateCandidateMetadataRecord(
      {
        ...validRecord,
        createdBy: "",
        usagePermission: "",
        licenseStatus: "unknown",
        reviewStatus: "approved-for-runtime-test"
      },
      "candidate.json",
      process.cwd()
    );

    expect(result.errors.map((issue) => issue.message)).toContain(
      "Runtime-test candidate is missing createdBy."
    );
    expect(result.errors.map((issue) => issue.message)).toContain(
      "Runtime-test candidate is missing usagePermission."
    );
    expect(result.errors.map((issue) => issue.message)).toContain(
      "Runtime-test candidate must have usable licenseStatus."
    );
  });

  it("requires rejected candidates to explain rejection", () => {
    const result = validateCandidateMetadataRecord(
      { ...validRecord, reviewStatus: "rejected", reasonForRejection: "" },
      "candidate.json",
      process.cwd()
    );

    expect(result.errors.map((issue) => issue.message)).toContain(
      "Rejected candidate metadata must include reasonForRejection."
    );
  });

  it("flags missing related spec docs without failing the record", () => {
    const result = validateCandidateMetadataRecord({ ...validRecord, relatedSpecDoc: "" }, "candidate.json", process.cwd());

    expect(result.errors).toEqual([]);
    expect(result.warnings.map((issue) => issue.message)).toContain(
      "Candidate metadata is missing relatedSpecDoc."
    );
  });

  it("requires submitted candidate files to exist", () => {
    const result = validateCandidateMetadataRecord(
      {
        ...validRecord,
        fileStatus: "submitted",
        filePath: "art-review/cinderfen-style-frames/inbox/missing.png"
      },
      "candidate.json",
      process.cwd()
    );

    expect(result.errors.map((issue) => issue.message)).toContain(
      "Submitted candidate file does not exist: art-review/cinderfen-style-frames/inbox/missing.png."
    );
  });
});

describe("validateArtIntake", () => {
  it("passes with an empty intake metadata directory", () => {
    const root = mkdtempSync(path.join(tmpdir(), "ascendant-realms-art-intake-empty-"));
    mkdirSync(path.join(root, "art-review", "cinderfen-style-frames", "metadata"), { recursive: true });

    const result = validateArtIntake(root);

    expect(result.errors).toEqual([]);
    expect(result.checkedMetadataFiles).toBe(0);
  });

  it("validates candidate metadata JSON files from the intake directory", () => {
    const root = mkdtempSync(path.join(tmpdir(), "ascendant-realms-art-intake-record-"));
    const metadataDir = path.join(root, "art-review", "cinderfen-style-frames", "metadata");
    mkdirSync(metadataDir, { recursive: true });
    writeFileSync(path.join(metadataDir, "candidate.json"), JSON.stringify(validRecord, null, 2));

    const result = validateArtIntake(root);

    expect(result.errors).toEqual([]);
    expect(result.checkedMetadataFiles).toBe(1);
  });
});
