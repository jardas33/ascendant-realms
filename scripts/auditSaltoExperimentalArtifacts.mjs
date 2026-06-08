import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { dirname, extname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto");
const outputRootDefault = join(artifactRoot, "v0165", "artifact-hygiene");
const deleteFlag = "--delete-approved-disposable";

const selectedLocalSources = new Set([
  "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png",
  "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
  "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png"
]);

const selectedLocalMetadata = new Set([
  "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json",
  "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.metadata.json"
]);

const selectedHashes = new Set([
  "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc",
  "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f",
  "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
]);

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

function walk(root) {
  if (!existsSync(root)) return [];
  const result = [];
  const stack = [root];
  while (stack.length) {
    const current = stack.pop();
    const stats = statSync(current);
    if (stats.isDirectory()) {
      for (const entry of readdirSync(current)) stack.push(join(current, entry));
    } else if (stats.isFile()) {
      result.push({ path: current, rel: relativeRepo(current), bytes: stats.size, mtimeMs: stats.mtimeMs });
    }
  }
  return result.sort((a, b) => a.rel.localeCompare(b.rel));
}

function gitTrackedSet() {
  return new Set(execSync("git ls-files", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replace(/\\/gu, "/")));
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function classify(file, tracked) {
  const rel = file.rel;
  const ext = extname(rel).toLowerCase();
  const isTracked = tracked.has(rel);
  const isV0165RequiredTrackedIntent =
    rel.startsWith("docs/V0165_") ||
    rel === "scripts/auditSaltoExperimentalArtifacts.mjs" ||
    rel === "tools/godot/saltoThreeSlotVisualHardeningTool.mjs" ||
    rel === "tools/godot/validateGodotSaltoThreeSlotVisualHardeningWindows.ps1" ||
    rel === "GODOT_AUDIT_SALTO_EXPERIMENTAL_ARTIFACTS_WINDOWS.bat" ||
    rel === "GODOT_VALIDATE_SALTO_THREE_SLOT_VISUAL_HARDENING_WINDOWS.bat";
  if ((isTracked || isV0165RequiredTrackedIntent) && (rel.startsWith("docs/") || rel.startsWith("tools/godot/") || rel.startsWith("desktop-spikes/godot-salto/") || rel.endsWith(".bat") || rel.startsWith("scripts/"))) {
    return "required tracked source/tooling/docs";
  }
  if (isTracked && /fallback|placeholder|diagnostic/iu.test(rel)) {
    return "required tracked diagnostic fallbacks";
  }
  if (selectedLocalSources.has(rel)) {
    return "selected ignored local derivatives currently used by opt-in launchers";
  }
  if (selectedLocalMetadata.has(rel)) {
    return "required local metadata";
  }
  if (/v0165\/(capture|computer-use|audit|benchmark|validation|artifact-hygiene)\//u.test(rel) || /v0165-three-slot/u.test(rel)) {
    return "latest human-review captures";
  }
  if (ext === ".png" && /v01(4[6-9]|5[0-9]|6[0-4])\//u.test(rel)) {
    return "superseded local derivatives";
  }
  if (/\/(benchmark|capture|screenshots|review|scorecard)\//u.test(rel) && !/v0165\//u.test(rel)) {
    return "superseded benchmark captures";
  }
  if (/\.(tmp|temp|log|bak)$/iu.test(rel) || /v0146-smoke|raw-pre-docs|parse2|converted|script-node|start-entry/iu.test(rel)) {
    return "stale temporary files";
  }
  if (/report|scorecard|validation|benchmark|summary/iu.test(rel) && /\.(json|md|svg)$/iu.test(rel) && !/v0165\//u.test(rel)) {
    return "duplicate generated reports";
  }
  if (/\/(\.godot|builds|reports)\//u.test(rel) || /\.(import|uid)$/iu.test(rel)) {
    return "disposable cache/build residue";
  }
  return "unknown files requiring human review";
}

function candidateDisposition(category, file) {
  if (category === "disposable cache/build residue" || category === "stale temporary files") {
    return { action: "safe-to-delete-future-approved", reason: "Regenerable validation/cache residue; v0.165 leaves it intact." };
  }
  if (category === "superseded benchmark captures" || category === "superseded local derivatives" || category === "duplicate generated reports") {
    return { action: "safe-to-archive-not-delete-yet", reason: "Historical evidence may still be useful for comparator review." };
  }
  if (category === "unknown files requiring human review") {
    return { action: "manual-review", reason: "Unknown scope; fail closed until Emmanuel approval." };
  }
  if (selectedLocalSources.has(file.rel) || selectedLocalMetadata.has(file.rel)) {
    return { action: "retain", reason: "Selected opt-in source/metadata used by launchers." };
  }
  return { action: "retain", reason: "Required source, tooling, fallback, or current evidence." };
}

function summarize(files) {
  const categories = {};
  for (const file of files) {
    categories[file.category] ??= { count: 0, bytes: 0, files: [] };
    categories[file.category].count += 1;
    categories[file.category].bytes += file.bytes;
    if (categories[file.category].files.length < 20) categories[file.category].files.push(file.rel);
  }
  return categories;
}

function largestDirectories(files) {
  const dirs = new Map();
  for (const file of files) {
    const dir = file.rel.split("/").slice(0, -1).join("/");
    dirs.set(dir, (dirs.get(dir) ?? 0) + file.bytes);
  }
  return Array.from(dirs.entries()).map(([dir, bytes]) => ({ dir, bytes })).sort((a, b) => b.bytes - a.bytes).slice(0, 20);
}

function duplicateHashes(files) {
  const buckets = new Map();
  for (const file of files.filter((entry) => entry.bytes > 0 && entry.bytes <= 5_000_000)) {
    const hash = createHash("sha256").update(readFileSync(file.path)).digest("hex");
    buckets.set(hash, [...(buckets.get(hash) ?? []), file.rel]);
  }
  return Array.from(buckets.entries())
    .filter(([, paths]) => paths.length > 1)
    .map(([hash, paths]) => ({ hash, paths }))
    .sort((a, b) => b.paths.length - a.paths.length)
    .slice(0, 25);
}

function markdown(report) {
  const categoryLines = Object.entries(report.categories)
    .map(([name, value]) => `- ${name}: ${value.count} files, ${value.bytes} bytes`)
    .join("\n");
  const deleteLines = report.safeToDeleteCandidates.slice(0, 40).map((entry) => `- ${entry.path}: ${entry.reason}`).join("\n") || "- none";
  const archiveLines = report.archiveCandidates.slice(0, 40).map((entry) => `- ${entry.path}: ${entry.reason}`).join("\n") || "- none";
  const manualLines = report.manualReviewCandidates.slice(0, 40).map((entry) => `- ${entry.path}: ${entry.reason}`).join("\n") || "- none";
  return [
    "# v0.165 Salto Experimental Artifact Hygiene Inventory",
    "",
    `Status: ${report.status}`,
    `Dry run: ${report.dryRun}`,
    `Total files: ${report.totalFiles}`,
    `Total bytes: ${report.totalBytes}`,
    "",
    "## Categories",
    categoryLines,
    "",
    "## Safe-To-Delete Future-Approved Candidates",
    deleteLines,
    "",
    "## Archive Candidates",
    archiveLines,
    "",
    "## Manual Review Candidates",
    manualLines,
    "",
    "## Retained Selected Evidence",
    ...report.selectedEvidenceToPreserve.map((entry) => `- ${entry}`),
    ""
  ].join("\n");
}

function main() {
  const tracked = gitTrackedSet();
  const deleteRequested = process.argv.includes(deleteFlag);
  const outputRoot = outputRootFromArgs();
  const scannedRoots = [
    artifactRoot,
    join(repoRoot, "desktop-spikes", "godot-salto"),
    join(repoRoot, "tools", "godot"),
    join(repoRoot, "docs")
  ];
  const seen = new Set();
  const files = scannedRoots.flatMap(walk).filter((file) => {
    if (seen.has(file.rel)) return false;
    seen.add(file.rel);
    return true;
  }).map((file) => {
    const category = classify(file, tracked);
    const disposition = candidateDisposition(category, file);
    return { ...file, category, disposition };
  });
  const selectedEvidenceToPreserve = [...selectedLocalSources, ...selectedLocalMetadata].filter((path) => existsSync(join(repoRoot, path)));
  const missingSelectedEvidence = [...selectedLocalSources, ...selectedLocalMetadata].filter((path) => !existsSync(join(repoRoot, path)));
  const hashedSelectedEvidence = selectedEvidenceToPreserve.map((path) => ({ path, sha256: sha256(join(repoRoot, path)).toLowerCase() }));
  const badSelectedHashes = hashedSelectedEvidence.filter((entry) => entry.path.endsWith(".png") && !selectedHashes.has(String(entry.sha256).toLowerCase()));
  const safeToDeleteCandidates = files.filter((file) => file.disposition.action === "safe-to-delete-future-approved").map((file) => ({ path: file.rel, bytes: file.bytes, reason: file.disposition.reason }));
  const archiveCandidates = files.filter((file) => file.disposition.action === "safe-to-archive-not-delete-yet").map((file) => ({ path: file.rel, bytes: file.bytes, reason: file.disposition.reason }));
  const manualReviewCandidates = files.filter((file) => file.disposition.action === "manual-review").map((file) => ({ path: file.rel, bytes: file.bytes, reason: file.disposition.reason }));
  const errors = [];
  if (missingSelectedEvidence.length > 0) errors.push(`Missing selected evidence: ${missingSelectedEvidence.join(", ")}`);
  if (badSelectedHashes.length > 0) errors.push(`Selected PNG hash mismatch: ${badSelectedHashes.map((entry) => entry.path).join(", ")}`);
  if (deleteRequested) errors.push(`${deleteFlag} is intentionally not executable in v0.165; run a separately approved cleanup checkpoint.`);
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.165",
    status: errors.length === 0 ? "PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN" : "FAIL_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN",
    dryRun: true,
    deletionAttempted: false,
    deleteFlag,
    scannedRoots: scannedRoots.map(relativeRepo),
    totalFiles: files.length,
    totalBytes: files.reduce((sum, file) => sum + file.bytes, 0),
    categories: summarize(files),
    largestDirectories: largestDirectories(files),
    duplicateHashes: duplicateHashes(files),
    selectedEvidenceToPreserve,
    hashedSelectedEvidence,
    safeToDeleteCandidates,
    archiveCandidates,
    manualReviewCandidates,
    requiredTrackedFilesNeverDeleted: true,
    selectedSourcesNeverDeleted: true,
    currentMetadataNeverDeleted: true,
    trackedFallbacksNeverDeleted: true,
    latestReviewPacketNeverDeleted: true,
    unknownFilesFailClosed: true,
    errors
  };
  mkdirSync(outputRoot, { recursive: true });
  writeFileSync(join(outputRoot, "salto-experimental-artifact-inventory.json"), stableStringify(report), "utf8");
  writeFileSync(join(outputRoot, "salto-experimental-artifact-inventory.md"), markdown(report), "utf8");
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
