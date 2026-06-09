import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const outputRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0166", "artifact-cleanup");
const applyFlag = "--apply-safe-only";

const selectedEvidence = new Set([
  "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png",
  "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
  "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png",
  "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png",
  "artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png",
  "artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.png",
  "artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.metadata.json"
]);

const selectedHashes = new Set([
  "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc",
  "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f",
  "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb",
  "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a",
  "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8",
  "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10"
]);

const requiredTrackedIntent = new Set([
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/road_material_single_slot_comparator.gd",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.contract.json"
]);

const safeSidecarPatterns = [
  /^desktop-spikes\/godot-salto\/comparators\/runtime_art_pipeline\/[^/]+\.gd\.uid$/u,
  /^desktop-spikes\/godot-salto\/comparators\/runtime_art_pipeline\/fallback\/[^/]+\.png\.import$/u
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, entry]) => [key, stableSort(entry)]));
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(stableSort(value), null, 2)}\n`;
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function outputRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--output-root="));
  return explicit ? resolve(explicit.slice("--output-root=".length)) : outputRootDefault;
}

function gitTrackedSet() {
  return new Set(execSync("git ls-files", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replace(/\\/gu, "/")));
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function walk(root) {
  if (!existsSync(root)) return [];
  const result = [];
  const stack = [root];
  while (stack.length > 0) {
    const current = stack.pop();
    const stats = statSync(current);
    if (stats.isDirectory()) {
      for (const entry of readdirSync(current)) stack.push(join(current, entry));
    } else if (stats.isFile()) {
      result.push({
        path: current,
        rel: relativeRepo(current),
        bytes: stats.size,
        sha256: sha256(current)
      });
    }
  }
  return result.sort((a, b) => a.rel.localeCompare(b.rel));
}

function classify(file, tracked) {
  if (tracked.has(file.rel)) {
    return { category: "tracked-required-file", action: "retain", reason: "Tracked repository file; never delete." };
  }
  if (requiredTrackedIntent.has(file.rel)) {
    return { category: "tracked-required-file-intent", action: "retain", reason: "Private comparator/fallback required tracked intent; never delete." };
  }
  if (selectedEvidence.has(file.rel)) {
    return { category: "selected-art-or-metadata", action: "retain", reason: "Selected opt-in source art or metadata." };
  }
  if (safeSidecarPatterns.some((pattern) => pattern.test(file.rel))) {
    return { category: "safe-godot-generated-sidecar", action: "delete-if-apply-safe-only", reason: "Godot regenerates this comparator .gd.uid/.png.import sidecar from source/cache; prompt 01 proved no tracked runtime reference depends on it." };
  }
  return { category: "unknown-files-requiring-human-review", action: "block", reason: "Unknown untracked file in cleanup scan scope; fail closed." };
}

function summarize(files) {
  const categories = {};
  for (const file of files) {
    categories[file.category] ??= { count: 0, bytes: 0 };
    categories[file.category].count += 1;
    categories[file.category].bytes += file.bytes;
  }
  return categories;
}

function snapshot(scannedRoots, tracked) {
  const seen = new Set();
  const files = scannedRoots.flatMap(walk).filter((file) => {
    if (seen.has(file.rel)) return false;
    seen.add(file.rel);
    return true;
  }).map((file) => ({ ...file, ...classify(file, tracked) }));
  return {
    files,
    totalFiles: files.length,
    totalBytes: files.reduce((sum, file) => sum + file.bytes, 0),
    categories: summarize(files),
    safeDeleteCandidates: files.filter((file) => file.action === "delete-if-apply-safe-only"),
    blockedUnknownFiles: files.filter((file) => file.action === "block")
  };
}

function markdown(report) {
  const safeLines = report.before.safeDeleteCandidates.map((file) => `- ${file.rel} (${file.bytes} bytes): ${file.reason}`).join("\n") || "- none";
  const deletedLines = report.deletedFiles.map((file) => `- ${file.rel} (${file.bytes} bytes, ${file.sha256}): ${file.reason}`).join("\n") || "- none";
  const blockedLines = report.before.blockedUnknownFiles.map((file) => `- ${file.rel}: ${file.reason}`).join("\n") || "- none";
  return [
    "# v0.166 Salto Experimental Artifact Cleanup",
    "",
    `Status: ${report.status}`,
    `Dry run: ${report.dryRun}`,
    `Apply flag: ${report.applyFlag}`,
    "",
    "## Safe Delete Candidates",
    safeLines,
    "",
    "## Deleted Files",
    deletedLines,
    "",
    "## Unknown Files",
    blockedLines,
    "",
    "## Preservation",
    "- tracked files retained",
    "- selected Worker/Barracks/Militia sources retained; Aster/Ashen retained as selected active evidence too",
    "- selected metadata retained",
    "- tracked fallbacks retained",
    "- current v0.165/v0.166 evidence retained",
    ""
  ].join("\n");
}

function main() {
  const applySafeOnly = process.argv.includes(applyFlag);
  const tracked = gitTrackedSet();
  const outputRoot = outputRootFromArgs();
  const scannedRoots = [
    join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline")
  ];
  const missingSelectedEvidence = [...selectedEvidence].filter((rel) => !existsSync(join(repoRoot, rel)));
  const selectedHashMismatches = [...selectedEvidence]
    .filter((rel) => rel.endsWith(".png") && existsSync(join(repoRoot, rel)))
    .map((rel) => ({ rel, sha256: sha256(join(repoRoot, rel)) }))
    .filter((entry) => !selectedHashes.has(entry.sha256));
  const before = snapshot(scannedRoots, tracked);
  const errors = [];
  if (missingSelectedEvidence.length > 0) errors.push(`Missing selected evidence: ${missingSelectedEvidence.join(", ")}`);
  if (selectedHashMismatches.length > 0) errors.push(`Selected image hash mismatch: ${selectedHashMismatches.map((entry) => entry.rel).join(", ")}`);
  if (before.blockedUnknownFiles.length > 0) errors.push(`Unknown cleanup-scope files: ${before.blockedUnknownFiles.map((file) => file.rel).join(", ")}`);

  const deletedFiles = [];
  if (errors.length === 0 && applySafeOnly) {
    const allowedRoot = resolve(join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline"));
    for (const file of before.safeDeleteCandidates) {
      const resolved = resolve(file.path);
      if (!resolved.startsWith(allowedRoot)) {
        errors.push(`Refusing to delete outside cleanup root: ${file.rel}`);
        continue;
      }
      if (tracked.has(file.rel)) {
        errors.push(`Refusing to delete tracked file: ${file.rel}`);
        continue;
      }
      deletedFiles.push(file);
      rmSync(resolved, { force: true });
    }
  }

  const after = snapshot(scannedRoots, tracked);
  const status = errors.length === 0
    ? (applySafeOnly ? "PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP" : "PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN")
    : "FAIL_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP";
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.166",
    status,
    dryRun: !applySafeOnly,
    applyFlag,
    deletionAttempted: applySafeOnly,
    scannedRoots: scannedRoots.map(relativeRepo),
    before,
    after,
    deletedFiles,
    trackedFilesNeverDeleted: true,
    selectedSourcesNeverDeleted: true,
    selectedMetadataNeverDeleted: true,
    trackedFallbacksNeverDeleted: true,
    latestEvidenceNeverDeleted: true,
    unknownFilesFailClosed: true,
    errors
  };
  mkdirSync(outputRoot, { recursive: true });
  writeFileSync(join(outputRoot, "salto-experimental-cleanup-before.json"), stableStringify(before), "utf8");
  writeFileSync(join(outputRoot, "salto-experimental-cleanup-after.json"), stableStringify(after), "utf8");
  writeFileSync(join(outputRoot, "salto-experimental-cleanup-report.json"), stableStringify(report), "utf8");
  writeFileSync(join(outputRoot, "salto-experimental-cleanup-report.md"), markdown(report), "utf8");
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
