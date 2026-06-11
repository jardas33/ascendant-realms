import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.213";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0213");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0213-full-ui-qa");
const referencePath = join(process.env.TEMP || "C:/Users/barro/AppData/Local/Temp", "REFERENCE_UI_TARGET.png");

const requiredFullCaptures = [
  { id: "initial", manualName: "02_initial.png" },
  { id: "aster", manualName: "03_aster.png" },
  { id: "worker_barracks", manualName: "04_worker_barracks.png" },
  { id: "production", manualName: "05_production.png" },
  { id: "objective_log", manualName: "06_objective_log.png" },
  { id: "minimap", manualName: "07_minimap.png" },
  { id: "ashen_pressure", manualName: "08_ashen_pressure.png" },
  { id: "replay", manualName: "10_replay.png" }
];

const resolutionCaptures = [
  { id: "resolution_1920x1080", label: "1920x1080" },
  { id: "resolution_1600x900", label: "1600x900" },
  { id: "resolution_1366x768", label: "1366x768" }
];

const validationScenarios = [
  { id: "default-procedural", selection: false, production: false, minimap: false, shell: false, uiFallback: false },
  { id: "full-ui", selection: true, production: true, minimap: true, shell: true, uiFallback: false },
  { id: "prior-v0212-ui", selection: true, production: true, minimap: true, shell: false, uiFallback: false },
  { id: "procedural-fallback", selection: true, production: true, minimap: true, shell: true, uiFallback: true },
  { id: "portrait-fallback", selection: true, production: true, minimap: true, shell: true, uiFallback: false, portraitFallback: true }
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, entry]) => [key, stableSort(entry)]));
  }
  return value;
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(stableSort(value), null, 2)}\n`, "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}

function rel(path) {
  return relative(repoRoot, path).replaceAll("\\", "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function pythonCandidates() {
  const bundledPython = join(process.env.USERPROFILE || "", ".cache", "codex-runtimes", "codex-primary-runtime", "dependencies", "python", "python.exe");
  return [
    process.env.SALTO_CONTACT_SHEET_PYTHON,
    existsSync(bundledPython) ? bundledPython : null,
    "python"
  ].filter(Boolean);
}

function runPython(script, payload, errors, label) {
  let lastError = null;
  for (const pythonExe of pythonCandidates()) {
    try {
      execFileSync(pythonExe, ["-c", script], {
        cwd: repoRoot,
        env: { ...process.env, SALTO_TOOL_PAYLOAD: JSON.stringify(payload) },
        stdio: ["ignore", "pipe", "pipe"]
      });
      return true;
    } catch (error) {
      lastError = error;
    }
  }
  errors.push(`${label} failed: ${lastError?.message ?? "no Python runtime available"}`);
  return false;
}

function createContactSheet(sourcePaths, outputPath, title, errors) {
  const existing = sourcePaths.filter((path) => path && existsSync(path));
  if (existing.length === 0) {
    errors.push(`No source images for contact sheet ${rel(outputPath)}.`);
    return;
  }
  const script = String.raw`
import json, os
from PIL import Image, ImageDraw, ImageFont
payload = json.loads(os.environ["SALTO_TOOL_PAYLOAD"])
sources = payload["sourcePaths"]
output = payload["outputPath"]
title = payload["title"]
thumb_w = payload.get("thumbWidth", 500)
thumb_h = payload.get("thumbHeight", 281)
cols = payload.get("cols", 2)
margin = 18
label_h = 28
title_h = 36
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (16, 19, 17))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 16)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((margin, margin), title, fill=(226, 222, 184), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (29, 35, 30))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title }, errors, `Contact sheet ${rel(outputPath)}`);
}

function createGapNote(outputPath, errors) {
  const lines = [
    "v0.213 Candid Reference Gap Note",
    "",
    "REFERENCE_UI_TARGET.png was used only as a hierarchy and polish benchmark.",
    "The current Salto review path is not at parity with that target.",
    "",
    "Strengths:",
    "- HUD zoning now matches the intended RTS grammar: resources, objectives, minimap, selection and production.",
    "- Tooltips, alerts and minimap markers are functional and readable in supported review resolutions.",
    "- Shell-v2 terrain/roads/river/structures are coherent enough for tactical review.",
    "",
    "Remaining prototype gaps:",
    "- Battlefield asset density and authored material richness are still far below the reference.",
    "- Structure and terrain detail remain restrained procedural placeholders rather than finished production art.",
    "- Character and building portraits/icons are serviceable but not reference-quality fantasy RTS presentation.",
    "",
    "v0.213 made no new art, no browser wiring and no default launcher change."
  ];
  const script = String.raw`
import json, os, textwrap
from PIL import Image, ImageDraw, ImageFont
payload = json.loads(os.environ["SALTO_TOOL_PAYLOAD"])
output = payload["outputPath"]
lines = payload["lines"]
width, height = 1600, 900
canvas = Image.new("RGB", (width, height), (17, 20, 18))
draw = ImageDraw.Draw(canvas)
try:
    title_font = ImageFont.truetype("arial.ttf", 38)
    body_font = ImageFont.truetype("arial.ttf", 24)
except Exception:
    title_font = ImageFont.load_default()
    body_font = title_font
y = 64
for index, line in enumerate(lines):
    font = title_font if index == 0 else body_font
    fill = (230, 219, 164) if index == 0 else (208, 218, 186)
    if line == "":
        y += 18
        continue
    wrapped = textwrap.wrap(line, width=96) or [line]
    for chunk in wrapped:
        draw.text((78, y), chunk, fill=fill, font=font)
        y += 48 if index == 0 else 34
    if index == 0:
        y += 12
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { outputPath, lines }, errors, "Gap note PNG");
}

function manifestPath(root, scenario) {
  return join(root, "capture", scenario, "screenshot-runtime-manifest.json");
}

function validationPath(root, scenario) {
  return join(root, "validation", scenario, "player-slice-validation-runtime.json");
}

function benchmarkPath(root, scenario) {
  return join(root, "benchmark", scenario, "worker-art-opt-in-benchmark-runtime.json");
}

function effectiveStatusFromCapture(capture) {
  return capture?.status && typeof capture.status === "object" ? capture.status : {};
}

function captureById(manifest, id) {
  return (manifest?.captures ?? []).find((capture) => capture?.id === id);
}

function capturePath(manifest, id, errors) {
  const capture = captureById(manifest, id);
  const absolutePath = capture?.absolutePath ? resolve(capture.absolutePath) : "";
  if (!absolutePath || !existsSync(absolutePath)) {
    errors.push(`Missing capture '${id}'.`);
    return "";
  }
  return absolutePath;
}

function shellEnabled(report) {
  return report?.environmentPresentationShellV2?.enabled === true ||
    report?.environmentShellV2GroundingProps?.enabled === true ||
    report?.environmentPresentationShellV2?.groundingProps?.enabled === true;
}

function validateManifest(root, scenario, options) {
  const errors = [];
  const path = manifestPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${scenario} capture status was ${manifest.status}.`);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} expected ${checkpoint}, received ${manifest.checkpoint}.`);
  if (manifest.saltoSelectionCommandPanelEnabled !== options.selection) errors.push(`${scenario} selection panel expected ${options.selection}.`);
  if (manifest.saltoProductionObjectivesLogEnabled !== options.production) errors.push(`${scenario} production objectives log expected ${options.production}.`);
  if (manifest.saltoMinimapTooltipAccessibilityEnabled !== options.minimap) errors.push(`${scenario} minimap tooltip accessibility expected ${options.minimap}.`);
  if (manifest.saltoUiShellFallbackActive !== options.uiFallback) errors.push(`${scenario} UI fallback expected ${options.uiFallback}.`);
  if (options.shell && !shellEnabled(manifest)) errors.push(`${scenario} did not report shell-v2 final posture enabled.`);
  if (manifest.saltoUiShellProductionSlotAdded !== false) errors.push(`${scenario} reported production UI/art slot leakage.`);
  if (options.portraitFallback && manifest.saltoAsterPortraitFallbackActive !== true) errors.push(`${scenario} did not report portrait fallback active.`);
  for (const spec of requiredFullCaptures) {
    const capture = captureById(manifest, spec.id);
    if (!capture) {
      errors.push(`${scenario} missing capture id ${spec.id}.`);
      continue;
    }
    if (!existsSync(resolve(capture.absolutePath ?? ""))) errors.push(`${scenario} missing capture file for ${spec.id}.`);
    const status = effectiveStatusFromCapture(capture);
    if (status.saltoSelectionCommandPanelEnabled !== options.selection) errors.push(`${scenario}/${spec.id} selection panel mismatch.`);
    if (status.saltoProductionObjectivesLogEnabled !== options.production) errors.push(`${scenario}/${spec.id} production log mismatch.`);
    if (status.saltoMinimapTooltipAccessibilityEnabled !== options.minimap) errors.push(`${scenario}/${spec.id} minimap tooltip mismatch.`);
  }
  for (const spec of resolutionCaptures) {
    const capture = captureById(manifest, spec.id);
    if (!capture) errors.push(`${scenario} missing resolution capture ${spec.id}.`);
  }
  return { errors, manifest };
}

function validateRuntimeReport(root, scenario, options) {
  const errors = [];
  const path = validationPath(root, scenario.id);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, report: null };
  }
  const report = readJson(path);
  if (report.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario.id} validation status was ${report.status}.`);
  if (report.checkpoint !== checkpoint) errors.push(`${scenario.id} expected ${checkpoint}, received ${report.checkpoint}.`);
  if (report.saltoSelectionCommandPanelEnabled !== options.selection) errors.push(`${scenario.id} selection panel expected ${options.selection}.`);
  if (report.saltoProductionObjectivesLogEnabled !== options.production) errors.push(`${scenario.id} production log expected ${options.production}.`);
  if (report.saltoMinimapTooltipAccessibilityEnabled !== options.minimap) errors.push(`${scenario.id} minimap tooltip expected ${options.minimap}.`);
  if (report.saltoUiShellFallbackActive !== options.uiFallback) errors.push(`${scenario.id} UI fallback expected ${options.uiFallback}.`);
  if (options.shell && !shellEnabled(report)) errors.push(`${scenario.id} did not report shell-v2 enabled.`);
  if (options.portraitFallback && report.saltoAsterPortraitFallbackActive !== true) errors.push(`${scenario.id} did not report portrait fallback active.`);
  if (report.saltoUiShellProductionSlotAdded !== false) errors.push(`${scenario.id} reported production slot leakage.`);
  return { errors, report };
}

function copyManualReviewPack(root) {
  const errors = [];
  const { errors: fullErrors, manifest: fullManifest } = validateManifest(root, "full-ui", { selection: true, production: true, minimap: true, shell: true, uiFallback: false });
  errors.push(...fullErrors);
  const { errors: portraitErrors, manifest: portraitManifest } = validateManifest(root, "portrait-fallback", { selection: true, production: true, minimap: true, shell: true, uiFallback: false, portraitFallback: true });
  errors.push(...portraitErrors);
  const { errors: proceduralErrors, manifest: proceduralManifest } = validateManifest(root, "procedural-fallback", { selection: true, production: true, minimap: true, shell: true, uiFallback: true });
  errors.push(...proceduralErrors);
  if (!fullManifest || !portraitManifest || !proceduralManifest) return { errors, manualPaths: [] };

  mkdirSync(manualReviewRoot, { recursive: true });
  const manualPaths = [];
  const gapNote = join(manualReviewRoot, "01_gap_note.png");
  createGapNote(gapNote, errors);
  if (existsSync(gapNote)) manualPaths.push(gapNote);

  for (const spec of requiredFullCaptures) {
    const source = capturePath(fullManifest, spec.id, errors);
    if (!source) continue;
    const destination = join(manualReviewRoot, spec.manualName);
    copyFileSync(source, destination);
    manualPaths.push(destination);
  }

  const fallbackSheet = join(manualReviewRoot, "09_fallbacks.png");
  createContactSheet([
    capturePath(portraitManifest, "aster", errors),
    capturePath(proceduralManifest, "initial", errors)
  ], fallbackSheet, "v0.213 portrait and procedural fallback evidence", errors);
  if (existsSync(fallbackSheet)) manualPaths.push(fallbackSheet);

  const resolutionSheet = join(manualReviewRoot, "11_resolution_matrix.png");
  createContactSheet(resolutionCaptures.map((spec) => capturePath(fullManifest, spec.id, errors)), resolutionSheet, "v0.213 resolution matrix", errors);
  if (existsSync(resolutionSheet)) manualPaths.push(resolutionSheet);

  const contactSheet = join(manualReviewRoot, "12_contact_sheet.png");
  createContactSheet(manualPaths, contactSheet, "v0.213 full HUD and environment cohesion QA", errors);
  if (existsSync(contactSheet)) manualPaths.push(contactSheet);

  writeText(
    join(manualReviewRoot, "README.md"),
    [
      "# v0.213 Salto Full UI QA",
      "",
      "Ignored manual review PNG pack for the combined shell-v2 environment and fantasy RTS HUD QA checkpoint.",
      "",
      "- `01_gap_note.png`",
      "- `02_initial.png`",
      "- `03_aster.png`",
      "- `04_worker_barracks.png`",
      "- `05_production.png`",
      "- `06_objective_log.png`",
      "- `07_minimap.png`",
      "- `08_ashen_pressure.png`",
      "- `09_fallbacks.png`",
      "- `10_replay.png`",
      "- `11_resolution_matrix.png`",
      "- `12_contact_sheet.png`",
      "",
      "The reference image is used only as a hierarchy and polish benchmark and is not copied into this pack."
    ].join("\n")
  );

  writeJson(join(root, "v0213-full-ui-qa-review-pack.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0213_FULL_UI_QA_REVIEW_PACK" : "FAIL_V0213_FULL_UI_QA_REVIEW_PACK",
    manualReviewRoot,
    manualPaths: manualPaths.map(rel),
    referenceAvailable: existsSync(referencePath),
    referenceUsage: "hierarchy-and-polish-benchmark-only",
    generatedImages: false,
    downloadedAssets: false,
    errors
  });
  return { errors, manualPaths };
}

function validateCaptures(root) {
  const results = [
    validateManifest(root, "full-ui", { selection: true, production: true, minimap: true, shell: true, uiFallback: false }),
    validateManifest(root, "portrait-fallback", { selection: true, production: true, minimap: true, shell: true, uiFallback: false, portraitFallback: true }),
    validateManifest(root, "procedural-fallback", { selection: true, production: true, minimap: true, shell: true, uiFallback: true })
  ];
  return results.flatMap((result) => result.errors);
}

function validateRuntime(root) {
  return validationScenarios.flatMap((scenario) => validateRuntimeReport(root, scenario, scenario).errors);
}

function validateBoundary(root) {
  const errors = [];
  const statusLines = execFileSync("git", ["status", "--short", "--untracked-files=all"], { cwd: repoRoot, encoding: "utf8" })
    .split(/\r?\n/u)
    .filter(Boolean);
  const changed = statusLines.map((line) => line.slice(3).replaceAll("\\", "/"));
  const allowed = [
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_root\.gd$/u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_scene_3d\.gd$/u,
    /^package\.json$/u,
    /^tools\/godot\/captureGodotSaltoFullUiQaWindows\.ps1$/u,
    /^tools\/godot\/validateGodotSaltoFullUiQaWindows\.ps1$/u,
    /^tools\/godot\/runGodotSaltoFullUiQaBenchmarkWindows\.ps1$/u,
    /^tools\/godot\/saltoFullUiQaTool\.mjs$/u,
    /^docs\/V0213_FULL_UI_QA_SCORECARD\.md$/u,
    /^docs\/V0213_ARTIFACT_HYGIENE_REPORT\.md$/u,
    /^docs\/V0213_IMPLEMENTATION_REPORT\.md$/u
  ];
  for (const path of changed) {
    if (!allowed.some((pattern) => pattern.test(path))) errors.push(`Unexpected changed path for v0.213 boundary: ${path}`);
    if (path.endsWith(".png") || path.includes("REFERENCE_UI_TARGET")) errors.push(`Tracked image/reference-copy path is not allowed in v0.213 boundary: ${path}`);
    if (path.startsWith("src/")) errors.push(`Browser runtime or web app source changed unexpectedly: ${path}`);
  }
  writeJson(join(root, "boundary", "v0213-full-ui-qa-boundary.json"), {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0213_FULL_UI_QA_BOUNDARY" : "FAIL_V0213_FULL_UI_QA_BOUNDARY",
    changed,
    generatedImages: false,
    downloadedAssets: false,
    defaultLauncherChanged: false,
    browserRuntimeChanged: false,
    errors
  });
  return errors;
}

function benchmarkMetrics(report) {
  return {
    averageFps: Number(report?.averageFps ?? report?.fpsAverage ?? report?.meanFps ?? 0),
    p95FrameTimeMs: Number(report?.p95FrameTimeMs ?? report?.frameTimeP95Ms ?? report?.p95FrameMs ?? 0),
    entityCount: Number(report?.entityCount ?? report?.entities ?? 0),
    drawNodeCount: Number(report?.drawNodeCount ?? report?.renderedObjectProxy ?? report?.renderNodeCount ?? 0),
    uiNodeCount: Number(report?.uiNodeCount ?? report?.controlNodeCount ?? 0),
    multimeshUsage: report?.multiMeshUsage ?? report?.multimeshUsage ?? report?.environmentShellV2GroundingProps?.multiMeshUsage ?? "not-reported"
  };
}

function runBenchmarkSummary(root) {
  const scenarios = ["pre-v0203-shell-v2-comparator", "full-ui-opt-in", "procedural-fallback"];
  const errors = [];
  const rows = [];
  for (const id of scenarios) {
    const path = benchmarkPath(root, id);
    if (!existsSync(path)) {
      errors.push(`Missing ${rel(path)}.`);
      continue;
    }
    const report = readJson(path);
    if (!String(report.status ?? "").startsWith("PASS")) errors.push(`${id} benchmark status was ${report.status}.`);
    rows.push({ id, ...benchmarkMetrics(report), path: rel(path) });
  }
  const comparator = rows.find((row) => row.id === "pre-v0203-shell-v2-comparator");
  const optIn = rows.find((row) => row.id === "full-ui-opt-in");
  const fallback = rows.find((row) => row.id === "procedural-fallback");
  const ratios = {
    optInAverageFpsVsComparator: comparator?.averageFps ? Number((optIn.averageFps / comparator.averageFps).toFixed(3)) : 0,
    optInP95FrameTimeVsComparator: comparator?.p95FrameTimeMs ? Number((optIn.p95FrameTimeMs / comparator.p95FrameTimeMs).toFixed(3)) : 0,
    fallbackAverageFpsVsComparator: comparator?.averageFps ? Number((fallback.averageFps / comparator.averageFps).toFixed(3)) : 0,
    fallbackP95FrameTimeVsComparator: comparator?.p95FrameTimeMs ? Number((fallback.p95FrameTimeMs / comparator.p95FrameTimeMs).toFixed(3)) : 0
  };
  if (ratios.optInAverageFpsVsComparator && ratios.optInAverageFpsVsComparator < 0.65) errors.push("Opt-in average FPS ratio fell below 0.65 comparator threshold.");
  if (ratios.optInP95FrameTimeVsComparator && ratios.optInP95FrameTimeVsComparator > 1.75) errors.push("Opt-in p95 frame-time ratio exceeded 1.75 comparator threshold.");
  const summary = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0213_FULL_UI_QA_BENCHMARK" : "FAIL_V0213_FULL_UI_QA_BENCHMARK",
    rows,
    ratios,
    errors
  };
  writeJson(join(root, "benchmark", "v0213-full-ui-qa-benchmark-summary.json"), summary);
  writeText(join(root, "benchmark", "v0213-full-ui-qa-benchmark-summary.md"), benchmarkMarkdown(summary));
  return errors;
}

function benchmarkMarkdown(summary) {
  const lines = [
    "# v0.213 Full UI QA Benchmark",
    "",
    `Status: ${summary.status}`,
    "",
    "| Scenario | Average FPS | p95 frame ms | entity count | draw/node count | UI nodes | MultiMesh |",
    "| --- | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.rows) {
    lines.push(`| ${row.id} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.entityCount} | ${row.drawNodeCount} | ${row.uiNodeCount} | ${row.multimeshUsage} |`);
  }
  lines.push("", `Opt-in FPS ratio vs comparator: ${summary.ratios.optInAverageFpsVsComparator}`);
  lines.push(`Opt-in p95 frame-time ratio vs comparator: ${summary.ratios.optInP95FrameTimeVsComparator}`);
  if (summary.errors.length > 0) lines.push("", "Errors:", ...summary.errors.map((error) => `- ${error}`));
  return `${lines.join("\n")}\n`;
}

function main() {
  const root = artifactRootFromArgs();
  const command = process.argv[2] ?? "capture";
  let errors = [];
  if (command === "capture") {
    errors = [...validateCaptures(root), ...copyManualReviewPack(root).errors];
    if (errors.length === 0) console.log("PASS_V0213_FULL_UI_QA_REVIEW_PACK");
  } else if (command === "validation") {
    errors = [...validateRuntime(root), ...validateCaptures(root)];
    writeJson(join(root, "validation", "v0213-full-ui-qa-validation.json"), {
      schemaVersion: 1,
      checkpoint,
      status: errors.length === 0 ? "PASS_V0213_FULL_UI_QA_VALIDATION" : "FAIL_V0213_FULL_UI_QA_VALIDATION",
      errors
    });
    if (errors.length === 0) console.log("PASS_V0213_FULL_UI_QA_VALIDATION");
  } else if (command === "boundary") {
    errors = validateBoundary(root);
    if (errors.length === 0) console.log("PASS_V0213_FULL_UI_QA_BOUNDARY");
  } else if (command === "benchmark") {
    errors = runBenchmarkSummary(root);
    if (errors.length === 0) console.log("PASS_V0213_FULL_UI_QA_BENCHMARK");
  } else {
    errors = [`Unknown command ${command}.`];
  }
  if (errors.length > 0) {
    for (const error of errors) console.error(error);
    process.exitCode = 1;
  }
}

main();
