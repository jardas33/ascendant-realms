import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const outputRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0167", "artifact-retention");
const checkpoint = "v0.167";

const retainedArtifacts = [
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png",
    category: "selected-active-derivative",
    slot: "worker_billboard_static_v0147",
    sha256: "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.metadata.json",
    category: "required-metadata",
    slot: "worker_billboard_static_v0147"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
    category: "selected-active-derivative",
    slot: "barrosan_barracks_material_v0149",
    sha256: "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json",
    category: "required-metadata",
    slot: "barrosan_barracks_material_v0149"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png",
    category: "selected-active-derivative",
    slot: "militia_billboard_static_v0154",
    sha256: "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.metadata.json",
    category: "required-metadata",
    slot: "militia_billboard_static_v0154"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png",
    category: "selected-active-derivative",
    slot: "aster_billboard_static_v0151",
    sha256: "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.metadata.json",
    category: "required-metadata",
    slot: "aster_billboard_static_v0151"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png",
    category: "selected-active-derivative",
    slot: "ashen_raider_billboard_static_v0156",
    sha256: "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.metadata.json",
    category: "required-metadata",
    slot: "ashen_raider_billboard_static_v0156"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png",
    category: "selected-active-environment-derivative",
    slot: "barrosan_foothold_ground_material_v0175",
    sha256: "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.metadata.json",
    category: "required-metadata",
    slot: "barrosan_foothold_ground_material_v0175"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.png",
    category: "selected-private-comparator-environment-derivative",
    slot: "barrosan_foothold_road_material_v0180",
    sha256: "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.metadata.json",
    category: "required-metadata",
    slot: "barrosan_foothold_road_material_v0180"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png",
    category: "selected-private-comparator-environment-derivative",
    slot: "barrosan_wet_granite_bridge_riverbank_material_v0189",
    sha256: "638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.metadata.json",
    category: "required-metadata",
    slot: "barrosan_wet_granite_bridge_riverbank_material_v0189"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0166/v0166-three-slot-visual-coherence-scorecard.json",
    category: "latest-required-evidence"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0166/review/worker-barracks-militia/screenshot-runtime-manifest.json",
    category: "latest-required-evidence"
  },
  {
    rel: "artifacts/desktop-spikes/godot-salto/v0166/real-input/worker-barracks-militia-post-mine-flow/headed-post-mine-flow-smoke.json",
    category: "latest-required-evidence"
  }
];

const trackedFallbacks = [
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.contract.json"
];

const requiredTrackedIntent = new Set([
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/road_material_single_slot_comparator.gd",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_road_material_v0180_fallback.contract.json",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/bridge_riverbank_material_single_slot_comparator.gd",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.png",
  "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.contract.json"
]);

const safeSidecarPatterns = [
  /^desktop-spikes\/godot-salto\/comparators\/runtime_art_pipeline\/[^/]+\.gd\.uid$/u,
  /^desktop-spikes\/godot-salto\/comparators\/runtime_art_pipeline\/fallback\/[^/]+\.png\.import$/u
];

function outputRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--output-root="));
  return explicit ? resolve(explicit.slice("--output-root=".length)) : outputRootDefault;
}

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
      result.push({ path: current, rel: relativeRepo(current), bytes: stats.size });
    }
  }
  return result.sort((a, b) => a.rel.localeCompare(b.rel));
}

function trackedFiles() {
  return new Set(execSync("git ls-files", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((entry) => entry.replace(/\\/gu, "/")));
}

function summarize(items) {
  return items.reduce((summary, item) => {
    const category = item.category ?? "uncategorized";
    summary[category] ??= { count: 0, bytes: 0 };
    summary[category].count += 1;
    summary[category].bytes += Number(item.bytes ?? 0);
    return summary;
  }, {});
}

function markdown(report) {
  const retainedLines = report.retainedArtifacts.map((entry) => `- ${entry.category}: ${entry.rel}`).join("\n");
  const sidecarLines = report.sidecarScan.safeDeleteCandidates.map((entry) => `- ${entry.rel} (${entry.bytes} bytes)`).join("\n") || "- none";
  const unknownLines = report.sidecarScan.unknownFiles.map((entry) => `- ${entry.rel}`).join("\n") || "- none";
  return [
    "# v0.167 Salto Experimental Artifact Retention Validation",
    "",
    `Status: ${report.status}`,
    "",
    "## Retained Required Artifacts",
    retainedLines,
    "",
    "## Tracked Fallbacks",
    ...report.trackedFallbacks.map((entry) => `- ${entry.rel}`),
    "",
    "## Known Godot Sidecars",
    sidecarLines,
    "",
    "## Unknown Files",
    unknownLines,
    ""
  ].join("\n");
}

function main() {
  const outputRoot = outputRootFromArgs();
  const tracked = trackedFiles();
  const errors = [];

  const retained = retainedArtifacts.map((entry) => {
    const absolute = join(repoRoot, entry.rel);
    const exists = existsSync(absolute);
    const bytes = exists ? statSync(absolute).size : 0;
    const actualSha256 = exists && entry.sha256 ? sha256(absolute) : undefined;
    if (!exists) errors.push(`Missing retained artifact: ${entry.rel}`);
    if (entry.sha256 && actualSha256 !== entry.sha256) errors.push(`Hash mismatch for ${entry.rel}: expected ${entry.sha256}, got ${actualSha256}`);
    return { ...entry, exists, bytes, actualSha256 };
  });

  const fallbackStatus = trackedFallbacks.map((rel) => {
    const absolute = join(repoRoot, rel);
    const exists = existsSync(absolute);
    const isTracked = tracked.has(rel);
    if (!exists) errors.push(`Missing tracked fallback: ${rel}`);
    if (!isTracked) errors.push(`Fallback is not tracked: ${rel}`);
    return { rel, category: "tracked-fallback", exists, tracked: isTracked, bytes: exists ? statSync(absolute).size : 0 };
  });

  const sidecarFiles = walk(join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline"))
    .filter((file) => !tracked.has(file.rel) && !requiredTrackedIntent.has(file.rel));
  const sidecarScan = {
    safeDeleteCandidates: sidecarFiles.filter((file) => safeSidecarPatterns.some((pattern) => pattern.test(file.rel))).map((file) => ({ ...file, category: "known-godot-generated-transient-sidecar" })),
    unknownFiles: sidecarFiles.filter((file) => !safeSidecarPatterns.some((pattern) => pattern.test(file.rel))).map((file) => ({ ...file, category: "unknown-file" }))
  };
  if (sidecarScan.unknownFiles.length > 0) {
    errors.push(`Unknown files in Godot comparator cleanup scope: ${sidecarScan.unknownFiles.map((file) => file.rel).join(", ")}`);
  }

  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION" : "FAIL_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION",
    retainedArtifacts: retained,
    retainedSummary: summarize(retained),
    trackedFallbacks: fallbackStatus,
    sidecarScan,
    sidecarPolicy: {
      deleteOnlyWithSafeOnlyCleanup: true,
      legacyFutureDerivativeCategoryRetiredAfterFiveSlotFreeze: "selected-future-derivative",
      unknownFilesBlock: true,
      preserveSelectedArtDerivativesMetadataFallbacksAndEvidence: true
    },
    errors
  };

  mkdirSync(outputRoot, { recursive: true });
  writeFileSync(join(outputRoot, "salto-experimental-artifact-retention-report.json"), stableStringify(report), "utf8");
  writeFileSync(join(outputRoot, "salto-experimental-artifact-retention-report.md"), markdown(report), "utf8");
  console.log(report.status);
  if (errors.length > 0) {
    for (const error of errors) console.error(error);
    process.exitCode = 1;
  }
}

main();
