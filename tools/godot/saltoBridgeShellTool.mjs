import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.218";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0218");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0218-bridge-shell");
const requiredCaptureIds = [
  "old_bridge",
  "new_bridge_normal_rts",
  "close_bridge",
  "road_to_bridge_west",
  "road_to_bridge_east",
  "riverbank_seats",
  "units_crossing",
  "fallback"
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

function manifestPath(root, scenario) {
  return join(root, "capture", scenario, "screenshot-runtime-manifest.json");
}

function validationPath(root, scenario) {
  return join(root, "validation", scenario, "player-slice-validation-runtime.json");
}

function benchmarkPath(root, scenario) {
  return join(root, "benchmark", scenario, "worker-art-opt-in-benchmark-runtime.json");
}

function captureById(manifest, id) {
  return (manifest?.captures ?? []).find((capture) => capture?.id === id);
}

function captureStatus(capture) {
  return capture?.status && typeof capture.status === "object" ? capture.status : {};
}

function bridgeStatus(status) {
  return status?.saltoBridgeShellReboot && typeof status.saltoBridgeShellReboot === "object" ? status.saltoBridgeShellReboot : {};
}

function roadWaterStatus(status) {
  return status?.roadRiverbankWaterMaterialExperiment && typeof status.roadRiverbankWaterMaterialExperiment === "object" ? status.roadRiverbankWaterMaterialExperiment : {};
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

function createContactSheet(sourcePaths, outputPath, title, errors, columns = 3) {
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
cols = int(payload.get("columns", 3))
thumb_w = 440
thumb_h = 248
margin = 16
label_h = 28
title_h = 38
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (13, 17, 14))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 14)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
draw.text((margin, margin), title, fill=(228, 224, 186), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (29, 36, 29))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 226, 190), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  runPython(script, { sourcePaths: existing, outputPath, title, columns }, errors, `Contact sheet ${rel(outputPath)}`);
}

function validateBridgeStatus(status, expectation, label, errors) {
  const bridge = bridgeStatus(status);
  const material = roadWaterStatus(status);
  if (expectation.kind !== "default" && status.saltoPresentationRebootEnabled !== true && bridge.presentationRebootOnly !== true) errors.push(`${label} did not enable presentation reboot.`);
  if (status.saltoUiShellFallbackActive === true) errors.push(`${label} UI shell fallback unexpectedly active.`);
  if (status.roadRiverbankWaterMaterialRuntimeSlotAdded === true) errors.push(`${label} reported v0.217 runtime slot addition.`);
  if (status.roadRiverbankWaterMaterialProductionSlotAdded === true) errors.push(`${label} reported v0.217 production slot addition.`);
  if (expectation.kind === "default") {
    if (status.saltoPresentationRebootEnabled === true) errors.push(`${label} default launcher unexpectedly enabled presentation reboot.`);
    if (status.saltoBridgeShellRebootEnabled === true) errors.push(`${label} default launcher unexpectedly enabled v0.218 bridge shell.`);
    return;
  }
  if (status.saltoBridgeShellRebootEnabled !== true) errors.push(`${label} did not report bridge-shell reboot enabled.`);
  if (bridge.enabled !== true) errors.push(`${label} bridge status was not enabled.`);
  if (bridge.generatedImageCount !== 0 || bridge.aiImageGenerated !== false) errors.push(`${label} reported generated image usage.`);
  if (bridge.newRuntimeArtSlots !== 0 || bridge.newArtSlotsAdded !== 0 || bridge.productionRuntimeArtSlotAdded !== false) errors.push(`${label} reported art-slot leakage.`);
  if (bridge.defaultLauncherChanged !== false) errors.push(`${label} reported default launcher mutation.`);
  if (bridge.browserRuntimeChanged !== false) errors.push(`${label} reported browser runtime mutation.`);
  if (bridge.gameplayPathingChanged !== false || bridge.collisionGeometryChanged !== false || bridge.stableIdsChanged !== false) errors.push(`${label} reported gameplay/pathing/collision/stable-id mutation.`);
  if (bridge.unitOcclusionRegression !== false) errors.push(`${label} reported unit occlusion regression.`);
  if (bridge.markerOcclusionRegression !== false) errors.push(`${label} reported marker occlusion regression.`);
  if (material.sourceLoaded !== true) errors.push(`${label} did not retain selected v0.217 road/riverbank/water bundle.`);
  if (expectation.kind === "selected") {
    if (bridge.selectedBridgeShellActive !== true) errors.push(`${label} selected bridge shell was not active.`);
    if (bridge.legacyBridgeComparatorActive === true) errors.push(`${label} selected bridge shell reported legacy comparator.`);
    if (Number(bridge.visualNodeCount ?? 0) < 26) errors.push(`${label} bridge visual node count too low: ${bridge.visualNodeCount}.`);
    if (Number(bridge.visualNodeCount ?? 0) > Number(bridge.visualNodeBudget ?? 48)) errors.push(`${label} bridge visual node count exceeded budget: ${bridge.visualNodeCount}.`);
    for (const [key, description] of [
      ["stoneAbutmentsUsed", "stone abutments"],
      ["crossingDeckUsed", "crossing deck"],
      ["edgeRailsUsed", "edge rails"],
      ["bridgeShouldersUsed", "bridge shoulders"],
      ["bankSeatingUsed", "bank seating"],
      ["approachTransitionsUsed", "approach transitions"],
      ["contactShadowsUsed", "contact shadows"],
      ["subtleDepthCuesUsed", "subtle depth cues"]
    ]) {
      if (bridge[key] !== true) errors.push(`${label} missing ${description}.`);
    }
    if (bridge.normalRtsOverviewImproved !== true) errors.push(`${label} did not report normal RTS bridge improvement.`);
    if (bridge.roadToBridgeWestConnected !== true || bridge.roadToBridgeEastConnected !== true) errors.push(`${label} road-to-bridge transitions not both connected.`);
    if (bridge.bridgeSeatsIntoBanks !== true || bridge.foundationsMeetGroundCleanly !== true) errors.push(`${label} bridge did not seat cleanly into banks.`);
  } else if (expectation.kind === "legacy") {
    if (bridge.legacyBridgeComparatorActive !== true) errors.push(`${label} legacy comparator was not active.`);
    if (bridge.selectedBridgeShellActive === true) errors.push(`${label} legacy comparator still reported selected bridge shell.`);
    if (Number(bridge.visualNodeCount ?? 0) !== 0) errors.push(`${label} legacy comparator unexpectedly recorded v0.218 bridge nodes.`);
  }
}

function validateCaptureScenario(root, scenario, expectation) {
  const errors = [];
  const path = manifestPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { errors, manifest: null };
  }
  const manifest = readJson(path);
  if (manifest.status !== "PASS_PLAYER_SLICE_CAPTURE") errors.push(`${scenario} capture status was ${manifest.status}.`);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} expected ${checkpoint}, received ${manifest.checkpoint}.`);
  for (const id of requiredCaptureIds) {
    const capture = captureById(manifest, id);
    if (!capture) {
      errors.push(`${scenario} missing capture ${id}.`);
      continue;
    }
    if (!existsSync(resolve(capture.absolutePath ?? ""))) errors.push(`${scenario}/${id} image missing.`);
    validateBridgeStatus(captureStatus(capture), expectation, `${scenario}/${id}`, errors);
  }
  validateBridgeStatus(manifest, expectation, scenario, errors);
  return { errors, manifest };
}

function copyManualReviewPack(root) {
  const errors = [];
  const selected = validateCaptureScenario(root, "selected-bridge-shell", { kind: "selected" });
  const legacy = validateCaptureScenario(root, "legacy-bridge-comparator", { kind: "legacy" });
  errors.push(...selected.errors, ...legacy.errors);
  if (!selected.manifest || !legacy.manifest) return { errors, manualPaths: [] };

  mkdirSync(manualReviewRoot, { recursive: true });
  const copies = [
    [legacy.manifest, "old_bridge", "01_old_bridge.png"],
    [selected.manifest, "new_bridge_normal_rts", "02_new_bridge_normal_rts.png"],
    [selected.manifest, "close_bridge", "03_close_bridge.png"],
    [selected.manifest, "road_to_bridge_west", "04_road_to_bridge_west.png"],
    [selected.manifest, "road_to_bridge_east", "05_road_to_bridge_east.png"],
    [selected.manifest, "riverbank_seats", "06_riverbank_seats.png"],
    [selected.manifest, "units_crossing", "07_units_crossing.png"],
    [legacy.manifest, "fallback", "08_fallback.png"]
  ];
  const copiedPaths = [];
  for (const [manifest, id, fileName] of copies) {
    const source = capturePath(manifest, id, errors);
    const target = join(manualReviewRoot, fileName);
    if (source) {
      copyFileSync(source, target);
      copiedPaths.push(target);
    }
  }
  createContactSheet(copiedPaths, join(manualReviewRoot, "09_contact_sheet.png"), "v0.218 bridge shell readability review", errors, 3);
  const manualPaths = [
    "01_old_bridge.png",
    "02_new_bridge_normal_rts.png",
    "03_close_bridge.png",
    "04_road_to_bridge_west.png",
    "05_road_to_bridge_east.png",
    "06_riverbank_seats.png",
    "07_units_crossing.png",
    "08_fallback.png",
    "09_contact_sheet.png"
  ].map((file) => join(manualReviewRoot, file));
  for (const path of manualPaths) {
    if (!existsSync(path)) errors.push(`Missing manual review output ${rel(path)}.`);
  }
  return { errors, manualPaths };
}

function runCapture(root) {
  const result = copyManualReviewPack(root);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: result.errors.length === 0 ? "PASS_V0218_BRIDGE_SHELL_REVIEW_PACK" : "FAIL_V0218_BRIDGE_SHELL_REVIEW_PACK",
    artifactRoot: root,
    manualReviewRoot,
    manualReviewPngs: result.manualPaths.map(rel),
    generatedImageCount: 0,
    errors: result.errors
  };
  writeJson(join(root, "v0218-bridge-shell-capture-report.json"), report);
  if (result.errors.length) {
    console.error(result.errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0218_BRIDGE_SHELL_REVIEW_PACK");
}

function validateValidationScenario(root, scenario, expectation) {
  const errors = [];
  const path = validationPath(root, scenario);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return errors;
  }
  const manifest = readJson(path);
  if (manifest.status !== "PASS_PLAYER_SLICE_VALIDATION") errors.push(`${scenario} validation status was ${manifest.status}.`);
  if (manifest.checkpoint !== checkpoint) errors.push(`${scenario} validation expected ${checkpoint}, received ${manifest.checkpoint}.`);
  validateBridgeStatus(manifest, expectation, `${scenario} validation`, errors);
  return errors;
}

function runValidation(root) {
  const errors = [];
  errors.push(...validateValidationScenario(root, "default-procedural", { kind: "default" }));
  errors.push(...validateValidationScenario(root, "selected-bridge-shell", { kind: "selected" }));
  errors.push(...validateValidationScenario(root, "legacy-bridge-comparator", { kind: "legacy" }));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0218_BRIDGE_SHELL_VALIDATION" : "FAIL_V0218_BRIDGE_SHELL_VALIDATION",
    artifactRoot: root,
    generatedImageCount: 0,
    errors
  };
  writeJson(join(root, "v0218-bridge-shell-validation-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0218_BRIDGE_SHELL_VALIDATION");
}

function runBoundary(root) {
  const errors = [];
  const output = execFileSync("git", ["diff", "--name-only"], { cwd: repoRoot, encoding: "utf8" });
  const changed = output.split(/\r?\n/u).filter(Boolean);
  const allowedPrefixes = [
    "desktop-spikes/godot-salto/scripts/",
    "tools/godot/",
    "package.json",
    "docs/",
    "CHANGELOG.md",
    "DEVELOPMENT_CHECKPOINT.md",
    "LLM_GAME_HANDOFF.md",
    "ROADMAP.md",
    "artifacts/manual-review/v0218-bridge-shell/"
  ];
  const forbidden = changed.filter((path) => !allowedPrefixes.some((prefix) => path.startsWith(prefix)));
  for (const path of forbidden) {
    if (path.startsWith("src/") || path.startsWith("public/") || path.includes("browser")) {
      errors.push(`Forbidden browser/runtime path changed: ${path}.`);
    } else {
      errors.push(`Unexpected changed path for v0.218 bridge shell scope: ${path}.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0218_BRIDGE_SHELL_BOUNDARY" : "FAIL_V0218_BRIDGE_SHELL_BOUNDARY",
    changedPaths: changed,
    errors
  };
  writeJson(join(root, "v0218-bridge-shell-boundary-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0218_BRIDGE_SHELL_BOUNDARY");
}

function readBenchmark(root, scenario) {
  const path = benchmarkPath(root, scenario);
  return existsSync(path) ? readJson(path) : null;
}

function runBenchmark(root) {
  const errors = [];
  const selected = readBenchmark(root, "selected-bridge-shell");
  const legacy = readBenchmark(root, "legacy-bridge-comparator");
  if (!selected) errors.push("Missing selected v0.218 bridge benchmark manifest.");
  if (!legacy) errors.push("Missing legacy bridge comparator benchmark manifest.");
  if (selected) {
    if (!String(selected.status ?? "").startsWith("PASS_")) errors.push(`Selected benchmark status was ${selected.status}.`);
    validateBridgeStatus(selected, { kind: "selected" }, "selected benchmark", errors);
  }
  if (legacy) {
    if (!String(legacy.status ?? "").startsWith("PASS_")) errors.push(`Legacy benchmark status was ${legacy.status}.`);
    validateBridgeStatus(legacy, { kind: "legacy" }, "legacy benchmark", errors);
  }
  const selectedFrame = Number(selected?.frameTimeP95Ms ?? 0);
  const legacyFrame = Number(legacy?.frameTimeP95Ms ?? 0);
  const p95Ratio = selectedFrame > 0 && legacyFrame > 0 ? selectedFrame / legacyFrame : null;
  if (p95Ratio !== null && p95Ratio > 1.35) errors.push(`Selected bridge p95 frame-time ratio too high: ${p95Ratio.toFixed(3)}.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0218_BRIDGE_SHELL_BENCHMARK" : "FAIL_V0218_BRIDGE_SHELL_BENCHMARK",
    selected: selected ? {
      fpsAverage: selected.fpsAverage,
      frameTimeP95Ms: selected.frameTimeP95Ms,
      bridgeShell: selected.saltoBridgeShellReboot
    } : null,
    legacy: legacy ? {
      fpsAverage: legacy.fpsAverage,
      frameTimeP95Ms: legacy.frameTimeP95Ms,
      bridgeShell: legacy.saltoBridgeShellReboot
    } : null,
    p95FrameTimeRatio: p95Ratio,
    generatedImageCount: 0,
    errors
  };
  writeJson(join(root, "v0218-bridge-shell-benchmark-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log("PASS_V0218_BRIDGE_SHELL_BENCHMARK");
}

function main() {
  const command = process.argv[2] ?? "";
  const root = artifactRootFromArgs();
  if (command === "capture") return runCapture(root);
  if (command === "validation") return runValidation(root);
  if (command === "boundary") return runBoundary(root);
  if (command === "benchmark") return runBenchmark(root);
  console.error("Usage: node tools/godot/saltoBridgeShellTool.mjs <capture|validation|boundary|benchmark> [--artifact-root=...]");
  process.exit(1);
}

main();
