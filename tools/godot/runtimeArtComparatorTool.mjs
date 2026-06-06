import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0146");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const runtimeReportName = "runtime-art-comparator-runtime.json";
const approaches = ["ORTHO_3D_MESH", "BILLBOARD_2D_ATLAS", "HYBRID_3D_WORLD_BILLBOARD_UNITS"];
const tiers = ["S", "M", "L"];

function stableSort(value) {
  if (Array.isArray(value)) {
    return value.map(stableSort);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, entry]) => [key, stableSort(entry)])
    );
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(stableSort(value), null, 2)}\n`;
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function hashFile(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function walkFiles(root) {
  if (!existsSync(root)) {
    return [];
  }
  const files = [];
  for (const entry of readdirSync(root)) {
    const path = join(root, entry);
    const stats = statSync(path);
    if (stats.isDirectory()) {
      files.push(...walkFiles(path));
    } else {
      files.push(path);
    }
  }
  return files;
}

function validate() {
  const errors = [];
  const requiredFiles = [
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.tscn",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd",
    "tools/godot/runtimeArtComparatorTool.mjs",
    "tools/godot/runGodotRuntimeArtComparatorValidation.ps1",
    "tools/godot/runGodotRuntimeArtComparatorBenchmarkWindows.ps1",
    "tools/godot/captureGodotRuntimeArtComparatorWindows.ps1",
    "GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat",
    "docs/V0146_RUNTIME_ART_PIPELINE_COMPARATOR_SPEC.md",
    "docs/V0146_RUNTIME_ART_PIPELINE_BENCHMARK_REPORT.md",
    "docs/V0146_RUNTIME_ART_PIPELINE_SCORECARD.md",
    "docs/V0146_RUNTIME_ART_PIPELINE_RECOMMENDATION.md",
    "docs/V0146_EMMANUEL_RUNTIME_ART_PIPELINE_REVIEW_GUIDE.md",
    "docs/V0146_REFERENCE_ONLY_AND_COMPARATOR_BOUNDARY.md",
    "docs/V0146_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.146 comparator file: ${file}`);
    }
  }

  const packageJson = readJson(join(repoRoot, "package.json"));
  const requiredScripts = [
    "godot:runtime-art-comparator:validate",
    "godot:runtime-art-comparator:benchmark:headed",
    "godot:runtime-art-comparator:capture"
  ];
  for (const script of requiredScripts) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script: ${script}`);
    }
  }

  const dependencies = {
    ...(packageJson.dependencies ?? {}),
    ...(packageJson.devDependencies ?? {})
  };
  for (const dependency of ["godot", "three", "@react-three/fiber", "electron", "unity", "unreal"]) {
    if (dependency in dependencies) {
      errors.push(`Comparator must not add desktop/rendering dependency ${dependency}.`);
    }
  }

  const project = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "project.godot"), "utf8");
  if (!project.includes('run/main_scene="res://scenes/salto_spike_root.tscn"')) {
    errors.push("Godot default main scene changed; comparator must stay isolated.");
  }

  const stabilizedLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"), "utf8");
  if (stabilizedLauncher.includes("ART_PIPELINE_COMPARATOR") || stabilizedLauncher.includes("runtime_art_pipeline")) {
    errors.push("Default stabilized Salto review launcher references the comparator.");
  }

  const comparatorFiles = walkFiles(comparatorRoot);
  const forbiddenAssetExtensions = new Set([".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg", ".glb", ".gltf", ".fbx", ".blend", ".aseprite"]);
  for (const file of comparatorFiles) {
    const extension = file.slice(file.lastIndexOf(".")).toLowerCase();
    if (forbiddenAssetExtensions.has(extension)) {
      errors.push(`Comparator path contains an asset-like file instead of procedural diagnostics: ${relativeRepo(file)}`);
    }
  }

  const comparatorScript = existsSync(join(comparatorRoot, "runtime_art_pipeline_comparator.gd"))
    ? readFileSync(join(comparatorRoot, "runtime_art_pipeline_comparator.gd"), "utf8")
    : "";
  for (const approach of approaches) {
    if (!comparatorScript.includes(approach)) {
      errors.push(`Comparator script does not define approach ${approach}.`);
    }
  }
  for (const boundary of [
    "generatedReferenceImagesImported",
    "downloadedAssetsUsed",
    "normalPlayerSliceWired",
    "browserRuntimeWired",
    "finalEngineSelection"
  ]) {
    if (!comparatorScript.includes(boundary)) {
      errors.push(`Comparator script is missing boundary flag ${boundary}.`);
    }
  }

  const report = {
    schemaVersion: 1,
    checkpoint: "v0.146",
    status: errors.length === 0 ? "PASS_V0146_RUNTIME_ART_COMPARATOR_STATIC_VALIDATION" : "FAIL_V0146_RUNTIME_ART_COMPARATOR_STATIC_VALIDATION",
    comparatorRoot: relativeRepo(comparatorRoot),
    requiredScripts,
    approaches,
    tiers,
    errors,
    zeroGeneratedReferenceImport: true,
    zeroDownloadedAssets: true,
    comparatorHarnessOnly: true,
    normalSaltoPlayerSliceLauncherPreserved: errors.every((error) => !error.includes("launcher"))
  };
  writeJson(join(artifactRootFromArgs(), "runtime-art-comparator-static-validation.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  return report;
}

function qualitativeScorecard() {
  const rows = [
    {
      approach: "HYBRID_3D_WORLD_BILLBOARD_UNITS",
      modern2026VisualCeiling: 5,
      saltoBarrosanFit: 5,
      unitReadabilityAtRtsDistance: 4,
      environmentRichness: 5,
      vfxPotential: 5,
      animationBurden: 4,
      contentProductionBurden: 4,
      aiFirstEditorOptionalOperability: 4,
      maintainability: 4,
      performanceRisk: 4,
      migrationRisk: 4,
      nextExperimentSuitability: 5,
      posture: "recommended-next-single-slot-experiment",
      reason:
        "Best balance of 3D terrain/architecture ambition, billboard-unit readability, restrained animation burden, and fit with the locked Salto environment plus Aster/Worker silhouette references."
    },
    {
      approach: "ORTHO_3D_MESH",
      modern2026VisualCeiling: 5,
      saltoBarrosanFit: 4,
      unitReadabilityAtRtsDistance: 4,
      environmentRichness: 5,
      vfxPotential: 5,
      animationBurden: 2,
      contentProductionBurden: 2,
      aiFirstEditorOptionalOperability: 4,
      maintainability: 3,
      performanceRisk: 3,
      migrationRisk: 3,
      nextExperimentSuitability: 4,
      posture: "fallback-comparator",
      reason:
        "Strongest lighting/material ceiling and clean 3D continuity, but unit animation and production scope are too heavy for the next narrow runtime-art experiment."
    },
    {
      approach: "BILLBOARD_2D_ATLAS",
      modern2026VisualCeiling: 3,
      saltoBarrosanFit: 3,
      unitReadabilityAtRtsDistance: 5,
      environmentRichness: 2,
      vfxPotential: 3,
      animationBurden: 3,
      contentProductionBurden: 3,
      aiFirstEditorOptionalOperability: 4,
      maintainability: 3,
      performanceRisk: 5,
      migrationRisk: 3,
      nextExperimentSuitability: 2,
      posture: "deferred-or-rejected-for-next-slot",
      reason:
        "Readable and likely cheap, but pure atlas posture under-serves Salto terrain/architecture richness and risks direction/readability compromises as production art deepens."
    }
  ];
  return rows.map((row) => ({
    ...row,
    totalOutOf60:
      row.modern2026VisualCeiling +
      row.saltoBarrosanFit +
      row.unitReadabilityAtRtsDistance +
      row.environmentRichness +
      row.vfxPotential +
      row.animationBurden +
      row.contentProductionBurden +
      row.aiFirstEditorOptionalOperability +
      row.maintainability +
      row.performanceRisk +
      row.migrationRisk +
      row.nextExperimentSuitability
  }));
}

function report() {
  validate();
  const artifactRoot = artifactRootFromArgs();
  const rawPath = join(artifactRoot, runtimeReportName);
  if (!existsSync(rawPath)) {
    throw new Error(`Missing Godot runtime comparator report: ${relativeRepo(rawPath)}`);
  }
  const raw = readJson(rawPath);
  const errors = [];
  const benchmarkRows = raw.benchmarks ?? [];
  if (benchmarkRows.length !== approaches.length * tiers.length) {
    errors.push(`Expected ${approaches.length * tiers.length} benchmark rows, found ${benchmarkRows.length}.`);
  }
  for (const approach of approaches) {
    for (const tier of tiers) {
      if (!benchmarkRows.some((row) => row.approach === approach && row.tier === tier)) {
        errors.push(`Missing benchmark row ${approach} ${tier}.`);
      }
    }
  }

  const screenshotRoot = join(artifactRoot, "screenshots");
  const screenshots = [];
  for (const capture of raw.captures ?? []) {
    const path = join(screenshotRoot, capture.fileName);
    if (!existsSync(path)) {
      errors.push(`Missing screenshot file ${relativeRepo(path)}.`);
      continue;
    }
    screenshots.push({
      id: capture.id,
      approach: capture.approach,
      tier: capture.tier,
      path: relativeRepo(path),
      absolutePath: path,
      width: capture.width,
      height: capture.height,
      sha256: hashFile(path)
    });
  }

  const scorecardRows = qualitativeScorecard();
  const recommendation = {
    schemaVersion: 1,
    checkpoint: "v0.146",
    recommendedNextSingleSlotExperiment: "HYBRID_3D_WORLD_BILLBOARD_UNITS",
    fallbackComparator: "ORTHO_3D_MESH",
    deferredOrRejectedApproach: "BILLBOARD_2D_ATLAS",
    notFinalEngineSelection: true,
    notRuntimeArtIntegrationApproval: true,
    noGeneratedReferenceImageImported: true,
    noDownloadedAssets: true,
    noNormalSaltoSliceMutation: true,
    noBrowserRuntimeWiring: true,
    summary:
      "Proceed, if Emmanuel approves, with one bounded hybrid 3D world plus billboard-unit runtime-art experiment. Keep orthographic full-3D as fallback evidence and defer pure billboard atlas as a comparator only."
  };

  const benchmarkSummary = {
    schemaVersion: 1,
    checkpoint: "v0.146",
    status: errors.length === 0 ? "PASS_V0146_RUNTIME_ART_COMPARATOR_EVIDENCE" : "FAIL_V0146_RUNTIME_ART_COMPARATOR_EVIDENCE",
    sourceRuntimeReport: relativeRepo(rawPath),
    headedDisplay: raw.headedDisplay,
    workloadParitySource: raw.workloadParitySource,
    benchmarkRows,
    screenshots: screenshots.map(({ absolutePath, ...entry }) => entry),
    scorecardRows,
    recommendation,
    boundaries: {
      zeroGeneratedReferenceImageImport: raw.generatedReferenceImagesImported === false,
      zeroDownloadedAssets: raw.downloadedAssetsUsed === false,
      comparatorHarnessOnly: true,
      normalPlayerSliceWired: raw.normalPlayerSliceWired === true,
      browserRuntimeWired: raw.browserRuntimeWired === true,
      manifestMutation: raw.manifestMutation === true,
      artSlotMutation: raw.artSlotMutation === true,
      productionAssetAdded: raw.productionAssetAdded === true,
      saveWritesAllowed: raw.saveWritesAllowed === true,
      stableIdChanges: raw.stableIdChanges === true,
      finalEngineSelection: raw.finalEngineSelection === true
    },
    errors
  };

  writeJson(join(artifactRoot, "runtime-art-comparator-evidence.json"), benchmarkSummary);
  writeJson(join(artifactRoot, "screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint: "v0.146",
    status: errors.length === 0 ? "PASS_V0146_RUNTIME_ART_COMPARATOR_SCREENSHOTS" : "FAIL_V0146_RUNTIME_ART_COMPARATOR_SCREENSHOTS",
    screenshotCount: screenshots.length,
    screenshots: screenshots.map(({ absolutePath, ...entry }) => entry)
  });
  writeJson(join(artifactRoot, "scorecard.json"), {
    schemaVersion: 1,
    checkpoint: "v0.146",
    status: "PASS_V0146_RUNTIME_ART_PIPELINE_SCORECARD",
    rows: scorecardRows,
    recommendation
  });
  writeText(join(artifactRoot, "benchmark-summary.md"), benchmarkMarkdown(benchmarkSummary));
  writeText(join(artifactRoot, "scorecard.md"), scorecardMarkdown(scorecardRows, recommendation));
  writeText(join(artifactRoot, "contact-sheet.svg"), contactSheetSvg(screenshots));
  writeText(join(artifactRoot, "recommendation.md"), recommendationMarkdown(recommendation));

  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  return benchmarkSummary;
}

function benchmarkMarkdown(summary) {
  const lines = [
    "# v0.146 Runtime-Art Pipeline Comparator Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    "",
    "| Approach | Tier | Avg FPS | p95 ms | p99 ms | Frames | Duration ms | Entities | Objects | Animation updates | Screenshot |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.benchmarkRows) {
    const shot = summary.screenshots.find((entry) => entry.approach === row.approach && entry.tier === row.tier);
    lines.push(
      `| ${row.approach} | ${row.tier} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.p99FrameTimeMs} | ${row.frameCount} | ${row.benchmarkDurationMs} | ${row.entityCount} | ${row.renderedObjectProxy} | ${row.animationUpdateProxy} | ${shot ? shot.path : "missing"} |`
    );
  }
  lines.push("");
  lines.push("Screenshots are diagnostic visual evidence only. Headed benchmark rows are local comparator evidence, not packaged Salto microloop proof.");
  return `${lines.join("\n")}\n`;
}

function scorecardMarkdown(rows, recommendation) {
  const lines = [
    "# v0.146 Runtime-Art Pipeline Comparator Scorecard",
    "",
    "| Approach | Total / 60 | Posture | Reason |",
    "| --- | ---: | --- | --- |"
  ];
  for (const row of rows) {
    lines.push(`| ${row.approach} | ${row.totalOutOf60} | ${row.posture} | ${row.reason} |`);
  }
  lines.push("");
  lines.push(`Recommended next single-slot experiment: ${recommendation.recommendedNextSingleSlotExperiment}.`);
  lines.push(`Fallback comparator: ${recommendation.fallbackComparator}.`);
  lines.push(`Deferred/rejected for next slot: ${recommendation.deferredOrRejectedApproach}.`);
  lines.push("");
  lines.push("This is not final engine selection and is not runtime-art integration approval.");
  return `${lines.join("\n")}\n`;
}

function recommendationMarkdown(recommendation) {
  return `# v0.146 Runtime-Art Pipeline Comparator Recommendation

Recommended next single-slot experiment: ${recommendation.recommendedNextSingleSlotExperiment}.

Fallback comparator: ${recommendation.fallbackComparator}.

Deferred/rejected for the next slot: ${recommendation.deferredOrRejectedApproach}.

${recommendation.summary}

This is not final engine selection. This is not runtime-art integration approval. No generated reference image was imported.
`;
}

function contactSheetSvg(screenshots) {
  const cellWidth = 360;
  const cellHeight = 250;
  const margin = 24;
  const width = margin * 2 + cellWidth * 3;
  const height = margin * 2 + cellHeight * 3;
  const rows = screenshots
    .map((shot, index) => {
      const x = margin + (index % 3) * cellWidth;
      const y = margin + Math.floor(index / 3) * cellHeight;
      const href = shot.path.replace("artifacts/desktop-spikes/godot-salto/v0146/", "");
      return `<g transform="translate(${x}, ${y})">
  <rect width="340" height="232" rx="4" fill="#101719" stroke="#4c5f59"/>
  <image href="${href}" x="10" y="28" width="320" height="180" preserveAspectRatio="xMidYMid meet"/>
  <text x="10" y="18" fill="#dce8d8" font-family="Arial" font-size="12">${shot.approach} ${shot.tier}</text>
  <text x="10" y="224" fill="#91aaa0" font-family="Arial" font-size="10">${shot.sha256.slice(0, 16)}</text>
</g>`;
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#081012"/>
<text x="${margin}" y="18" fill="#dce8d8" font-family="Arial" font-size="14">v0.146 runtime-art pipeline comparator diagnostic screenshots</text>
${rows}
</svg>
`;
}

const command = process.argv[2] ?? "help";

try {
  if (command === "validate") {
    console.log(stableStringify(validate()));
  } else if (command === "report") {
    console.log(stableStringify(report()));
  } else {
    console.log("Usage: node tools/godot/runtimeArtComparatorTool.mjs <validate|report> [--artifact-root=<path>]");
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
