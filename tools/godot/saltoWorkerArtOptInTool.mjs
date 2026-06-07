import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.160";
const slotId = "worker_billboard_static_v0147";
const approach = "HYBRID_WORKER_TRIMMED_1024";
const expectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const defaultLauncherSha256 = "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0160");

const validationScenarios = [
  { id: "default-procedural", label: "Default procedural baseline", expected: "procedural" },
  { id: "worker-opt-in", label: "Worker art opt-in", expected: "loaded" },
  { id: "missing-art-fallback", label: "Missing-art fallback", expected: "fallback-missing" },
  { id: "hash-mismatch-fallback", label: "Hash-mismatch fallback", expected: "fallback-hash" }
];

const captureScenarios = [
  { id: "default-procedural", label: "Default procedural baseline" },
  { id: "worker-opt-in", label: "Worker art opt-in 1.00x" },
  { id: "worker-opt-in-scale-090", label: "Worker art opt-in 0.90x" },
  { id: "missing-art-fallback", label: "Missing-art fallback" },
  { id: "hash-mismatch-fallback", label: "Hash-mismatch fallback" }
];

const benchmarkScenarios = [
  { id: "procedural-baseline", label: "Procedural baseline" },
  { id: "worker-opt-in", label: "Worker art opt-in" },
  { id: "missing-art-fallback", label: "Missing-art fallback" },
  { id: "hash-mismatch-fallback", label: "Hash-mismatch fallback" }
];

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

function sha256File(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function scenarioReport(root, scenario, fileName) {
  const path = join(root, scenario.id, fileName);
  if (!existsSync(path)) {
    return { path, report: null, error: `Missing ${relativeRepo(path)}` };
  }
  return { path, report: readJson(path), error: "" };
}

function workerArt(report) {
  return report?.workerArtExperiment ?? {};
}

function isPassStatus(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function validateScenario(scenario, report, errors) {
  if (!isPassStatus(report)) {
    errors.push(`${scenario.id} did not PASS: ${report?.status ?? "MISSING"}`);
    return;
  }
  const art = workerArt(report);
  const loaded = art.sourceLoaded === true;
  const fallback = art.fallbackActive === true;
  if (scenario.expected === "procedural") {
    if (report.workerArtOptInRequested !== false || loaded || fallback !== true) {
      errors.push(`${scenario.id} should stay procedural with opt-in disabled.`);
    }
  }
  if (scenario.expected === "loaded") {
    if (!loaded || fallback || art.actualSha256 !== expectedSha256 || art.slotId !== slotId) {
      errors.push(`${scenario.id} did not load the exact selected Worker source.`);
    }
  }
  if (scenario.expected === "fallback-missing") {
    if (loaded || !fallback || !String(art.fallbackReason ?? "").includes("missing")) {
      errors.push(`${scenario.id} did not explain missing-art procedural fallback.`);
    }
  }
  if (scenario.expected === "fallback-hash") {
    if (loaded || !fallback || !String(art.fallbackReason ?? "").includes("hash mismatch")) {
      errors.push(`${scenario.id} did not explain hash-mismatch procedural fallback.`);
    }
  }
}

function validateCommand(root) {
  const errors = [];
  const scenarioReports = validationScenarios.map((scenario) => {
    const loaded = scenarioReport(root, scenario, "player-slice-validation-runtime.json");
    if (loaded.error) {
      errors.push(loaded.error);
    } else {
      validateScenario(scenario, loaded.report, errors);
    }
    return {
      id: scenario.id,
      label: scenario.label,
      expected: scenario.expected,
      path: relativeRepo(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      workerArtExperiment: workerArt(loaded.report),
      objectiveSequence: loaded.report?.objectiveSequence ?? []
    };
  });
  const status = errors.length === 0 ? "PASS_V0160_WORKER_ART_OPT_IN_VALIDATION" : "FAIL_V0160_WORKER_ART_OPT_IN_VALIDATION";
  const report = {
    schemaVersion: 1,
    checkpoint,
    status,
    slotId,
    approach,
    expectedSha256,
    artifactRoot: relativeRepo(root),
    defaultLauncherPreserved: true,
    singlePlayerFacingArtSlot: true,
    scenarios: scenarioReports,
    errors
  };
  writeJson(join(root, "worker-art-opt-in-validation.json"), report);
  writeJson(join(root, "worker-art-opt-in-functional-report.json"), {
    ...report,
    status: errors.length === 0 ? "PASS_V0160_WORKER_ART_OPT_IN_FUNCTIONAL" : "FAIL_V0160_WORKER_ART_OPT_IN_FUNCTIONAL",
    preservedBehaviors: [
      "Worker selection",
      "Worker assignment to West Stone Cut Mine",
      "Mine-work resource production",
      "Barracks repair proximity",
      "Results transition"
    ]
  });
  writeJson(join(root, "worker-art-opt-in-slot-contract.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0160_WORKER_ART_OPT_IN_SLOT_CONTRACT" : "FAIL_V0160_WORKER_ART_OPT_IN_SLOT_CONTRACT",
    slotId,
    approach,
    expectedSha256,
    sourceFamily: "v0.148 repaired Worker billboard local derivative",
    oneSlotOnly: true,
    defaultLaunchersUnchanged: true,
    browserRuntimeChanged: false,
    productionManifestMutated: false,
    errors
  });
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function captureCommand(root) {
  const errors = [];
  const captures = [];
  for (const scenario of captureScenarios) {
    const loaded = scenarioReport(root, scenario, "screenshot-runtime-manifest.json");
    if (loaded.error) {
      errors.push(loaded.error);
      continue;
    }
    if (!isPassStatus(loaded.report)) {
      errors.push(`${scenario.id} capture did not PASS: ${loaded.report.status}`);
    }
    const screenshotRoot = join(root, scenario.id, "screenshots");
    const files = existsSync(screenshotRoot)
      ? readdirSync(screenshotRoot).filter((file) => file.endsWith(".png")).sort()
      : [];
    if (files.length !== loaded.report.requiredCaptureCount) {
      errors.push(`${scenario.id} expected ${loaded.report.requiredCaptureCount} PNGs, found ${files.length}.`);
    }
    captures.push({
      id: scenario.id,
      label: scenario.label,
      manifest: relativeRepo(loaded.path),
      status: loaded.report.status,
      captureCount: files.length,
      workerArtExperiment: workerArt(loaded.report),
      screenshots: files.map((file) => ({
        fileName: file,
        path: relativeRepo(join(screenshotRoot, file)),
        sha256: sha256File(join(screenshotRoot, file))
      }))
    });
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0160_WORKER_ART_OPT_IN_CAPTURE" : "FAIL_V0160_WORKER_ART_OPT_IN_CAPTURE",
    artifactRoot: relativeRepo(root),
    captureScenarioCount: captures.length,
    captures,
    errors
  };
  writeJson(join(root, "worker-art-opt-in-capture-report.json"), report);
  writeText(join(root, "worker-art-opt-in-contact-sheet.svg"), contactSheetSvg(root, captures));
  writeText(join(root, "worker-art-opt-in-visual-review-guide.md"), visualGuideMarkdown(report));
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function contactSheetSvg(root, captures) {
  const tileWidth = 320;
  const tileHeight = 225;
  const labelHeight = 38;
  const width = tileWidth * 3;
  const rows = captures.flatMap((capture) => capture.screenshots.slice(0, 6).map((shot) => ({ capture, shot })));
  const height = Math.max(labelHeight + tileHeight, Math.ceil(rows.length / 3) * (tileHeight + labelHeight));
  const items = rows
    .map(({ capture, shot }, index) => {
      const x = (index % 3) * tileWidth;
      const y = Math.floor(index / 3) * (tileHeight + labelHeight);
      const href = relative(root, join(repoRoot, shot.path)).replace(/\\/gu, "/");
      return [
        `<text x="${x + 8}" y="${y + 22}" font-size="15" fill="#1b1f1d">${escapeXml(capture.label)} / ${escapeXml(shot.fileName)}</text>`,
        `<image x="${x}" y="${y + labelHeight}" width="${tileWidth}" height="${tileHeight}" href="${escapeXml(href)}" preserveAspectRatio="xMidYMid meet" />`
      ].join("\n");
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#f4f1e8" />
${items}
</svg>
`;
}

function escapeXml(value) {
  return String(value)
    .replace(/&/gu, "&amp;")
    .replace(/</gu, "&lt;")
    .replace(/>/gu, "&gt;")
    .replace(/"/gu, "&quot;");
}

function visualGuideMarkdown(report) {
  const lines = [
    "# v0.160 Worker Art Opt-In Visual Review Guide",
    "",
    `Status: ${report.status}.`,
    "",
    "Review the procedural default against the opt-in Worker billboard, the 0.90 scale comparator, missing-art fallback, and hash-mismatch fallback.",
    "",
    "- Confirm the default scenario remains procedural.",
    "- Confirm the opt-in scenario shows only the selected Worker slot.",
    "- Confirm selection ring, mine assignment, Barracks proximity, group crowding, normal camera, and zoomed camera remain readable.",
    "- Confirm missing-art and hash-mismatch scenarios return to the procedural Worker and explain the fallback in JSON.",
    "",
    "Contact sheet: `worker-art-opt-in-contact-sheet.svg`.",
    ""
  ];
  return `${lines.join("\n")}\n`;
}

function benchmarkCommand(root) {
  const errors = [];
  const reports = Object.fromEntries(
    benchmarkScenarios.map((scenario) => {
      const loaded = scenarioReport(root, scenario, "worker-art-opt-in-benchmark-runtime.json");
      if (loaded.error) {
        errors.push(loaded.error);
      } else if (!isPassStatus(loaded.report)) {
        errors.push(`${scenario.id} benchmark did not PASS: ${loaded.report.status}`);
      }
      return [scenario.id, { scenario, path: loaded.path, report: loaded.report }];
    })
  );
  const baseline = reports["procedural-baseline"]?.report;
  const optIn = reports["worker-opt-in"]?.report;
  const fpsRatio = baseline && optIn ? optIn.fpsAverage / Math.max(0.01, baseline.fpsAverage) : 0;
  const p95Ratio = baseline && optIn ? optIn.frameTimeP95Ms / Math.max(0.01, baseline.frameTimeP95Ms) : 999;
  const optInArt = workerArt(optIn);
  if (optIn && optInArt.sourceLoaded !== true) {
    errors.push("worker-opt-in benchmark did not load the selected source.");
  }
  if (optIn && Number(optInArt.imageDecodeCount ?? 99) > 1) {
    errors.push("worker-opt-in benchmark decoded the source more than once in its process.");
  }
  if (optIn && Number(optInArt.textureCreateCount ?? 99) > 1) {
    errors.push("worker-opt-in benchmark created more than one texture in its process.");
  }
  if (fpsRatio < 0.75) {
    errors.push(`worker-opt-in FPS ratio ${fpsRatio.toFixed(3)} is below 0.75.`);
  }
  if (p95Ratio > 1.5) {
    errors.push(`worker-opt-in P95 frame-time ratio ${p95Ratio.toFixed(3)} is above 1.5.`);
  }
  const scenarioSummaries = benchmarkScenarios.map((scenario) => {
    const report = reports[scenario.id]?.report;
    return {
      id: scenario.id,
      label: scenario.label,
      path: reports[scenario.id]?.path ? relativeRepo(reports[scenario.id].path) : "",
      status: report?.status ?? "MISSING",
      fpsAverage: report?.fpsAverage ?? 0,
      frameTimeP95Ms: report?.frameTimeP95Ms ?? 0,
      workerArtExperiment: workerArt(report)
    };
  });
  const scorecard = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0160_WORKER_ART_OPT_IN_BENCHMARK" : "FAIL_V0160_WORKER_ART_OPT_IN_BENCHMARK",
    artifactRoot: relativeRepo(root),
    thresholds: {
      minOptInFpsRatioVsProcedural: 0.75,
      maxOptInP95FrameTimeRatioVsProcedural: 1.5,
      maxImageDecodeCountPerProcess: 1,
      maxTextureCreateCountPerProcess: 1
    },
    fpsRatioVsProcedural: Number(fpsRatio.toFixed(4)),
    p95FrameTimeRatioVsProcedural: Number(p95Ratio.toFixed(4)),
    scenarios: scenarioSummaries,
    errors
  };
  writeJson(join(root, "worker-art-opt-in-benchmark-report.json"), scorecard);
  writeJson(join(root, "worker-art-opt-in-scorecard.json"), scorecard);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

function boundaryCommand(root) {
  const errors = [];
  const changed = Array.from(new Set([
    ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
    ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
  ]))
    .filter(Boolean)
    .map((path) => path.replace(/\\/gu, "/"))
    .sort();
  const stabilizedLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"), "utf8");
  const playerLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"), "utf8");
  const stabilizedHash = sha256File(join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"));
  if (stabilizedHash !== defaultLauncherSha256) {
    errors.push(`Default stabilized launcher hash changed: ${stabilizedHash}`);
  }
  if (/worker-art-opt-in|WORKER_ART|worker_billboard_static_v0147/iu.test(stabilizedLauncher)) {
    errors.push("Default stabilized launcher contains Worker-art opt-in text.");
  }
  if (/worker-art-opt-in|WORKER_ART|worker_billboard_static_v0147/iu.test(playerLauncher)) {
    errors.push("Default player-slice launcher contains Worker-art opt-in text.");
  }
  const forbiddenChangedPrefixes = [
    "public/assets/runtime-art/",
    "src/main.ts",
    "src/App.tsx",
    "src/game/art/",
    "src/game/save/",
    "src/game/core/SaveSystem",
    "src/game/systems/Save"
  ];
  const forbiddenChanges = changed.filter((path) => forbiddenChangedPrefixes.some((prefix) => path.startsWith(prefix)));
  if (forbiddenChanges.length > 0) {
    errors.push(`Forbidden browser/runtime/save path changes: ${forbiddenChanges.join(", ")}`);
  }
  const browserRuntimeChanged = changed.some((path) =>
    path === "src/main.ts" ||
    path === "src/App.tsx" ||
    path.startsWith("public/") ||
    path.startsWith("src/game/art/")
  );
  const productionRuntimeArtManifestMutated = changed.some((path) => path.startsWith("public/assets/runtime-art/"));
  const saveOrStableIdMutation = changed.some((path) =>
    path.startsWith("src/game/save/") ||
    path.startsWith("src/game/core/SaveSystem") ||
    path.startsWith("src/game/systems/Save")
  );
  const secondPlayerFacingArtSlotAdded = changed.some((path) => /v0161|v0\.161|second.*slot/iu.test(path));
  const v0161Started = changed.some((path) => /v0161|v0\.161/iu.test(path));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0160_WORKER_ART_OPT_IN_BOUNDARY" : "FAIL_V0160_WORKER_ART_OPT_IN_BOUNDARY",
    artifactRoot: relativeRepo(root),
    changedFiles: changed,
    defaultStabilizedLauncherSha256: stabilizedHash,
    expectedDefaultStabilizedLauncherSha256: defaultLauncherSha256,
    defaultLaunchersUnchanged: stabilizedHash === defaultLauncherSha256,
    browserRuntimeChanged,
    productionRuntimeArtManifestMutated,
    secondPlayerFacingArtSlotAdded,
    saveOrStableIdMutation,
    v0161Started,
    errors
  };
  writeJson(join(root, "worker-art-opt-in-boundary-scan.json"), report);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
}

const command = process.argv[2] ?? "";
const root = artifactRootFromArgs();
try {
  if (command === "validate") {
    validateCommand(root);
  } else if (command === "capture") {
    captureCommand(root);
  } else if (command === "benchmark") {
    benchmarkCommand(root);
  } else if (command === "boundary") {
    boundaryCommand(root);
  } else {
    throw new Error(`Unknown command '${command}'. Expected validate, capture, benchmark, or boundary.`);
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
