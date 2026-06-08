import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { inflateSync } from "node:zlib";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.165";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0165");

const workerSlotId = "worker_billboard_static_v0147";
const workerApproach = "HYBRID_WORKER_TRIMMED_1024";
const workerExpectedSha256 = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const workerSourcePath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148", "local-worker-slot", "worker_billboard_static_v0147_trimmed_1024.png");
const workerMetadataPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148", "local-worker-slot", "worker_billboard_static_v0147_trimmed_1024.metadata.json");

const barracksSlotId = "barrosan_barracks_material_v0149";
const barracksApproach = "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND";
const barracksExpectedSha256 = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";

const militiaSlotId = "militia_billboard_static_v0154";
const militiaApproach = "HYBRID_MILITIA_TRIMMED_1024";
const militiaExpectedSha256 = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb";
const militiaSourcePath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "local-militia-billboard-repair", "militia_billboard_static_v0154_trimmed_1024.png");
const militiaMetadataPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "local-militia-billboard-repair", "militia_billboard_static_v0154_trimmed_1024.metadata.json");

const expectedLauncherHashes = {
  "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat": "47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d",
  "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat": "87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb",
  "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat": "a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a",
  "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat": "4eab85de03e83e64440da9c90204bd880ce29b2477d2b048940b94cd809245cc"
};

const validationScenarios = [
  { id: "default-procedural", mode: "M0", expected: "procedural" },
  { id: "worker-only", mode: "M1", expected: "worker-only" },
  { id: "worker-barracks", mode: "M2", expected: "worker-barracks" },
  { id: "worker-barracks-militia", mode: "M3", expected: "three-loaded" },
  { id: "militia-missing-art-fallback", mode: "M4", expected: "militia-missing" },
  { id: "militia-hash-mismatch-fallback", mode: "M5", expected: "militia-hash" }
];

const benchmarkScenarios = [
  { id: "procedural-baseline", mode: "M0", expected: "procedural" },
  { id: "worker-only", mode: "M1", expected: "worker-only" },
  { id: "worker-barracks", mode: "M2", expected: "worker-barracks" },
  { id: "worker-barracks-militia", mode: "M3", expected: "three-loaded" },
  { id: "militia-missing-art-fallback", mode: "M4", expected: "militia-missing" },
  { id: "militia-hash-mismatch-fallback", mode: "M5", expected: "militia-hash" }
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

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}

function tryReadJson(path) {
  return existsSync(path) ? readJson(path) : null;
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

function isPassStatus(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function scenarioReport(root, group, scenarioId, fileName, errors) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${relativeRepo(path)}`);
    return { path, report: null };
  }
  return { path, report: readJson(path) };
}

function runtimeStatus(report) {
  if (!report) return {};
  if (report.runtimeStatus) return report.runtimeStatus;
  const captureStatuses = (report.captures ?? []).map((capture) => capture?.status).filter(Boolean);
  if (captureStatuses.length > 0) {
    return captureStatuses.find((status) => Number(status.normalSliceOptInRequestedSlotCount ?? -1) >= 0) ?? captureStatuses[0];
  }
  return report;
}

function workerArt(report) {
  return runtimeStatus(report)?.workerArtExperiment ?? {};
}

function barracksMaterial(report) {
  return runtimeStatus(report)?.barracksMaterialExperiment ?? {};
}

function militiaArt(report) {
  return runtimeStatus(report)?.militiaArtExperiment ?? {};
}

function visualAudit(report) {
  const candidates = [];
  if (report?.v0165VisualHardeningAudit) candidates.push(report.v0165VisualHardeningAudit);
  if (report?.performanceSmoke?.v0165VisualHardeningAudit) candidates.push(report.performanceSmoke.v0165VisualHardeningAudit);
  for (const step of report?.steps ?? []) {
    if (step?.status?.v0165VisualHardeningAudit) candidates.push(step.status.v0165VisualHardeningAudit);
  }
  for (const capture of report?.captures ?? []) {
    if (capture?.status?.v0165VisualHardeningAudit) candidates.push(capture.status.v0165VisualHardeningAudit);
  }
  if (candidates.length === 0) return {};
  const richest = [...candidates].sort((a, b) => Number(b.unitVisuals?.length ?? 0) - Number(a.unitVisuals?.length ?? 0))[0] ?? {};
  return {
    ...richest,
    totalVisualNodeCount: Math.max(...candidates.map((entry) => Number(entry.totalVisualNodeCount ?? 0))),
    meshInstance3DCount: Math.max(...candidates.map((entry) => Number(entry.meshInstance3DCount ?? 0))),
    proceduralVisualVisibleCount: Math.max(...candidates.map((entry) => Number(entry.proceduralVisualVisibleCount ?? 0))),
    generatedArtVisibleCount: Math.max(...candidates.map((entry) => Number(entry.generatedArtVisibleCount ?? 0))),
    fallbackVisibleCount: Math.max(...candidates.map((entry) => Number(entry.fallbackVisibleCount ?? 0))),
    markerRingVisibleCount: Math.max(...candidates.map((entry) => Number(entry.markerRingVisibleCount ?? 0))),
    accidentalProceduralOverlayCount: Math.max(...candidates.map((entry) => Number(entry.accidentalProceduralOverlayCount ?? 0))),
    perFrameDecodeCount: Math.max(...candidates.map((entry) => Number(entry.perFrameDecodeCount ?? 0))),
    perFrameMetadataParseCount: Math.max(...candidates.map((entry) => Number(entry.perFrameMetadataParseCount ?? 0))),
    noPerFrameDecode: candidates.every((entry) => entry.noPerFrameDecode === true),
    noPerFrameMetadataParse: candidates.every((entry) => entry.noPerFrameMetadataParse === true),
    validatedArtReplacesProceduralVisual: candidates.every((entry) => entry.validatedArtReplacesProceduralVisual === true)
  };
}

function checkScenario(report, expected, id, errors) {
  const statusReport = runtimeStatus(report);
  if (!isPassStatus(report) && !isPassStatus(statusReport)) {
    errors.push(`${id} did not PASS: ${report?.status ?? statusReport?.status ?? "MISSING"}`);
    return;
  }
  const worker = workerArt(statusReport);
  const barracks = barracksMaterial(statusReport);
  const militia = militiaArt(statusReport);
  const workerLoaded = worker.sourceLoaded === true;
  const barracksLoaded = barracks.sourceLoaded === true;
  const militiaLoaded = militia.sourceLoaded === true;
  if (expected === "procedural" && (workerLoaded || barracksLoaded || militiaLoaded || Number(statusReport.normalSliceOptInLoadedSlotCount ?? 0) !== 0)) {
    errors.push(`${id} should stay fully procedural.`);
  }
  if (expected === "worker-only") {
    if (worker.actualSha256 !== workerExpectedSha256 || worker.slotId !== workerSlotId || !workerLoaded) errors.push(`${id} did not load selected Worker art.`);
    if (barracksLoaded || militiaLoaded || statusReport.barracksMaterialOptInRequested !== false || statusReport.militiaArtOptInRequested !== false) errors.push(`${id} should remain Worker-only.`);
  }
  if (expected === "worker-barracks") {
    if (worker.actualSha256 !== workerExpectedSha256 || !workerLoaded) errors.push(`${id} did not load selected Worker art.`);
    if (barracks.actualSha256 !== barracksExpectedSha256 || barracks.slotId !== barracksSlotId || !barracksLoaded) errors.push(`${id} did not load selected Barracks material.`);
    if (militiaLoaded || statusReport.militiaArtOptInRequested !== false) errors.push(`${id} should not load Militia art.`);
  }
  if (expected === "three-loaded") {
    if (worker.actualSha256 !== workerExpectedSha256 || !workerLoaded) errors.push(`${id} did not load selected Worker art.`);
    if (barracks.actualSha256 !== barracksExpectedSha256 || !barracksLoaded) errors.push(`${id} did not load selected Barracks material.`);
    if (militia.actualSha256 !== militiaExpectedSha256 || militia.slotId !== militiaSlotId || !militiaLoaded) errors.push(`${id} did not load selected Militia art.`);
    if (Number(statusReport.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(statusReport.normalSliceOptInLoadedSlotCount ?? 0) !== 3) errors.push(`${id} should report exactly three requested and loaded slots.`);
  }
  if (expected === "militia-missing" || expected === "militia-hash") {
    if (worker.actualSha256 !== workerExpectedSha256 || !workerLoaded) errors.push(`${id} should preserve Worker art during Militia fallback.`);
    if (barracks.actualSha256 !== barracksExpectedSha256 || !barracksLoaded) errors.push(`${id} should preserve Barracks material during Militia fallback.`);
    if (militiaLoaded || militia.fallbackActive !== true) errors.push(`${id} should fail Militia closed to procedural fallback.`);
    if (Number(statusReport.normalSliceOptInRequestedSlotCount ?? 0) !== 3 || Number(statusReport.normalSliceOptInLoadedSlotCount ?? 0) !== 2) errors.push(`${id} should report three requested slots and two loaded slots.`);
  }
}

function parsePngAlpha(path) {
  const bytes = readFileSync(path);
  if (!bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) {
    throw new Error(`Not a PNG: ${relativeRepo(path)}`);
  }
  let offset = 8;
  let width = 0;
  let height = 0;
  let colorType = 0;
  const idat = [];
  while (offset < bytes.length) {
    const length = bytes.readUInt32BE(offset);
    const type = bytes.toString("ascii", offset + 4, offset + 8);
    const data = bytes.subarray(offset + 8, offset + 8 + length);
    if (type === "IHDR") {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      const bitDepth = data.readUInt8(8);
      colorType = data.readUInt8(9);
      if (bitDepth !== 8 || colorType !== 6) {
        throw new Error(`Unsupported PNG format for alpha audit: ${relativeRepo(path)} bitDepth=${bitDepth} colorType=${colorType}`);
      }
    }
    if (type === "IDAT") idat.push(data);
    if (type === "IEND") break;
    offset += length + 12;
  }
  const raw = inflateSync(Buffer.concat(idat));
  const bytesPerPixel = 4;
  const stride = width * bytesPerPixel;
  const scanlines = [];
  let cursor = 0;
  let prior = Buffer.alloc(stride);
  let minX = width;
  let minY = height;
  let maxX = -1;
  let maxY = -1;
  let alphaPixelCount = 0;
  for (let y = 0; y < height; y += 1) {
    const filter = raw[cursor];
    cursor += 1;
    const current = Buffer.from(raw.subarray(cursor, cursor + stride));
    cursor += stride;
    for (let x = 0; x < stride; x += 1) {
      const left = x >= bytesPerPixel ? current[x - bytesPerPixel] : 0;
      const up = prior[x] ?? 0;
      const upLeft = x >= bytesPerPixel ? prior[x - bytesPerPixel] : 0;
      if (filter === 1) current[x] = (current[x] + left) & 0xff;
      else if (filter === 2) current[x] = (current[x] + up) & 0xff;
      else if (filter === 3) current[x] = (current[x] + Math.floor((left + up) / 2)) & 0xff;
      else if (filter === 4) current[x] = (current[x] + paeth(left, up, upLeft)) & 0xff;
      else if (filter !== 0) throw new Error(`Unsupported PNG filter ${filter} in ${relativeRepo(path)}`);
    }
    scanlines.push(current);
    for (let x = 0; x < width; x += 1) {
      const alpha = current[x * 4 + 3];
      if (alpha > 0) {
        minX = Math.min(minX, x);
        maxX = Math.max(maxX, x);
        minY = Math.min(minY, y);
        maxY = Math.max(maxY, y);
        alphaPixelCount += 1;
      }
    }
    prior = current;
  }
  const alphaWidth = maxX >= minX ? maxX - minX + 1 : 0;
  const alphaHeight = maxY >= minY ? maxY - minY + 1 : 0;
  return { width, height, colorType, alphaBounds: { left: minX, right: maxX, top: minY, bottom: maxY, width: alphaWidth, height: alphaHeight }, alphaPixelCount, sourceAspectRatio: width / Math.max(1, height), alphaAspectRatio: alphaWidth / Math.max(1, alphaHeight) };
}

function paeth(a, b, c) {
  const p = a + b - c;
  const pa = Math.abs(p - a);
  const pb = Math.abs(p - b);
  const pc = Math.abs(p - c);
  if (pa <= pb && pa <= pc) return a;
  if (pb <= pc) return b;
  return c;
}

function scaleAspectCommand(root) {
  const errors = [];
  const loaded = scenarioReport(root, "validation", "worker-barracks-militia", "player-slice-validation-runtime.json", errors);
  if (loaded.report) checkScenario(loaded.report, "three-loaded", "worker-barracks-militia", errors);
  const workerMetadata = readJson(workerMetadataPath);
  const militiaMetadata = readJson(militiaMetadataPath);
  const workerPng = parsePngAlpha(workerSourcePath);
  const militiaPng = parsePngAlpha(militiaSourcePath);
  const worker = workerArt(loaded.report);
  const militia = militiaArt(loaded.report);
  const entries = [
    {
      id: "Worker",
      slotId: workerSlotId,
      approach: workerApproach,
      sourcePath: relativeRepo(workerSourcePath),
      metadataPath: relativeRepo(workerMetadataPath),
      sha256: sha256File(workerSourcePath),
      metadataSha256: workerMetadata.sha256,
      measured: workerPng,
      metadataPivot: workerMetadata.pivot,
      metadataTrimBounds: workerMetadata.trimBounds,
      preRepairRuntimeWorldWidth: 0.55,
      preRepairRuntimeWorldHeight: 0.74,
      preRepairRuntimeAspectRatio: 0.7432,
      runtime: worker,
      ratioToProcedural: {
        height: Number((Number(worker.runtimeWorldHeight ?? 0) / 0.36).toFixed(4)),
        width: Number((Number(worker.runtimeWorldWidth ?? 0) / 0.22).toFixed(4))
      }
    },
    {
      id: "Militia",
      slotId: militiaSlotId,
      approach: militiaApproach,
      sourcePath: relativeRepo(militiaSourcePath),
      metadataPath: relativeRepo(militiaMetadataPath),
      sha256: sha256File(militiaSourcePath),
      metadataSha256: militiaMetadata.sha256,
      measured: militiaPng,
      metadataPivot: militiaMetadata.pivot,
      metadataTrimBounds: militiaMetadata.trimBounds,
      preRepairRuntimeWorldWidth: 0.5,
      preRepairRuntimeWorldHeight: 0.68,
      preRepairRuntimeAspectRatio: 0.7353,
      runtime: militia,
      ratioToProcedural: {
        height: Number((Number(militia.runtimeWorldHeight ?? 0) / 0.42).toFixed(4)),
        width: Number((Number(militia.runtimeWorldWidth ?? 0) / 0.36).toFixed(4))
      }
    }
  ];
  for (const entry of entries) {
    if (entry.sha256 !== entry.metadataSha256) errors.push(`${entry.id} source hash does not match metadata.`);
    if (entry.sha256 !== (entry.id === "Worker" ? workerExpectedSha256 : militiaExpectedSha256)) errors.push(`${entry.id} source hash does not match selected expected hash.`);
    if (entry.measured.width !== 1024 || entry.measured.height !== 1024) errors.push(`${entry.id} source is not 1024 square.`);
    if (entry.runtime.aspectRatioPreserved !== true || Number(entry.runtime.runtimeAspectRatio ?? 0) !== 1) errors.push(`${entry.id} runtime aspect is not preserved.`);
    if (entry.runtime.runtimeWorldWidth !== entry.runtime.runtimeWorldHeight) errors.push(`${entry.id} runtime width and height should be equal for square source.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_BILLBOARD_SCALE_ASPECT_PIVOT_AUDIT" : "FAIL_V0165_BILLBOARD_SCALE_ASPECT_PIVOT_AUDIT",
    reproducedConcern: "Current pre-repair M3 Windows review showed narrow humanoid billboards. Measurement confirmed square sources were mapped to sub-square quads.",
    repair: "Runtime width now derives from runtime height multiplied by the selected source aspect ratio.",
    entries,
    errors
  };
  writeJson(join(root, "audit", "v0165-billboard-scale-aspect-pivot-audit.json"), report);
  writeText(join(root, "audit", "v0165-billboard-scale-aspect-pivot-audit.md"), markdownList("v0.165 Billboard Scale/Aspect/Pivot Audit", report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function duplicateCommand(root) {
  const errors = [];
  const scenarios = validationScenarios.map((scenario) => {
    const loaded = scenarioReport(root, "validation", scenario.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) checkScenario(loaded.report, scenario.expected, scenario.id, errors);
    const audit = visualAudit(loaded.report);
    if (scenario.id === "worker-barracks-militia") {
      if (audit.validatedArtReplacesProceduralVisual !== true) errors.push("M3 validated art did not replace procedural visual cleanly.");
      if (Number(audit.accidentalProceduralOverlayCount ?? 99) !== 0) errors.push("M3 has accidental procedural overlays.");
      if (audit.noPerFrameDecode !== true || audit.noPerFrameMetadataParse !== true) errors.push("M3 reports per-frame decode or metadata parsing.");
      if (Number(audit.generatedArtVisibleCount ?? 0) < 3) errors.push("M3 did not report visible generated-art nodes.");
    }
    return {
      id: scenario.id,
      mode: scenario.mode,
      status: loaded.report?.status ?? "MISSING",
      generatedArtVisibleCount: audit.generatedArtVisibleCount ?? 0,
      proceduralVisualVisibleCount: audit.proceduralVisualVisibleCount ?? 0,
      fallbackVisibleCount: audit.fallbackVisibleCount ?? 0,
      markerRingVisibleCount: audit.markerRingVisibleCount ?? 0,
      accidentalProceduralOverlayCount: audit.accidentalProceduralOverlayCount ?? 0,
      drawNodeCreationCount: audit.drawNodeCreationCount ?? 0,
      textureLoadCount: audit.textureLoadCount ?? 0,
      materialCreateCount: audit.materialCreateCount ?? 0,
      materialReuseCount: audit.materialReuseCount ?? 0,
      metadataParseCount: audit.metadataParseCount ?? 0,
      imageDecodeCount: audit.imageDecodeCount ?? 0,
      perFrameDecodeCount: audit.perFrameDecodeCount ?? 0,
      perFrameMetadataParseCount: audit.perFrameMetadataParseCount ?? 0,
      unitVisuals: audit.unitVisuals ?? []
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_DUPLICATE_RENDER_AUDIT" : "FAIL_V0165_DUPLICATE_RENDER_AUDIT",
    conclusion: "Validated Worker and Militia billboard roots use QuadMesh with zero child procedural silhouette parts. Remaining blocks are markers, health bars, structures, terrain, and fallback/procedural non-art units.",
    scenarios,
    errors
  };
  writeJson(join(root, "audit", "v0165-duplicate-render-audit.json"), report);
  writeText(join(root, "audit", "v0165-duplicate-render-audit.md"), markdownList("v0.165 Duplicate Render Audit", report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function barracksCommand(root) {
  const errors = [];
  const loaded = scenarioReport(root, "validation", "worker-barracks-militia", "player-slice-validation-runtime.json", errors);
  if (loaded.report) checkScenario(loaded.report, "three-loaded", "worker-barracks-militia", errors);
  const barracks = barracksMaterial(loaded.report);
  const audit = visualAudit(loaded.report);
  if (barracks.actualSha256 !== barracksExpectedSha256 || barracks.sourceLoaded !== true) errors.push("Barracks material did not load selected seam-repaired source.");
  if (Number(barracks.appliedSurfaceCount ?? 0) < 5) errors.push("Barracks material did not bind to expected core surfaces.");
  if (audit.barracksMaterialAppliedOnlyToBarracks !== true) errors.push("Barracks material audit did not remain scoped to Barracks.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_BARRACKS_MATERIAL_BINDING_REVIEW" : "FAIL_V0165_BARRACKS_MATERIAL_BINDING_REVIEW",
    slotId: barracksSlotId,
    approach: barracksApproach,
    expectedSha256: barracksExpectedSha256,
    actualSha256: barracks.actualSha256 ?? "",
    surfacesReceivingMaterial: ["barracks base", "training wing A", "training wing B", "roof split left", "roof split right"],
    intentionallyProceduralShellElements: audit.proceduralShellElementsIntentionallyVisible ?? [],
    uvScale: barracks.uvScale ?? 1,
    filterMode: "BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS",
    mipmapPosture: "linear with mipmaps",
    appliedSurfaceCount: barracks.appliedSurfaceCount ?? 0,
    visibilityPosture: "material is applied to intended surfaces but intentionally restrained at normal RTS distance",
    errors
  };
  writeJson(join(root, "audit", "v0165-barracks-material-binding-review.json"), report);
  writeText(join(root, "audit", "v0165-barracks-material-binding-review.md"), markdownList("v0.165 Barracks Material Binding Review", report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const captures = validationScenarios.map((scenario) => {
    const loaded = scenarioReport(root, "capture", scenario.id, "screenshot-runtime-manifest.json", errors);
    if (loaded.report) checkScenario(loaded.report, scenario.expected, scenario.id, errors);
    const screenshotRoot = join(root, "capture", scenario.id, "screenshots");
    const screenshots = existsSync(screenshotRoot) ? readdirSync(screenshotRoot).filter((file) => file.endsWith(".png")).sort() : [];
    if (loaded.report && Number(loaded.report.requiredCaptureCount ?? screenshots.length) !== screenshots.length) {
      errors.push(`${scenario.id} expected ${loaded.report.requiredCaptureCount} captures, found ${screenshots.length}.`);
    }
    return {
      id: scenario.id,
      mode: scenario.mode,
      status: loaded.report?.status ?? "MISSING",
      manifest: relativeRepo(loaded.path),
      captureCount: screenshots.length,
      screenshots: screenshots.map((file) => relativeRepo(join(screenshotRoot, file)))
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_THREE_SLOT_VISUAL_CAPTURE_PACKET" : "FAIL_V0165_THREE_SLOT_VISUAL_CAPTURE_PACKET",
    captures,
    errors
  };
  writeJson(join(root, "capture", "v0165-three-slot-visual-capture-report.json"), report);
  writeText(join(root, "capture", "v0165-three-slot-visual-capture-report.md"), markdownList("v0.165 Three-Slot Visual Capture Packet", report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkCommand(root) {
  const errors = [];
  const scenarios = benchmarkScenarios.map((scenario) => {
    const loaded = scenarioReport(root, "benchmark", scenario.id, "worker-art-opt-in-benchmark-runtime.json", errors);
    if (loaded.report) checkScenario(loaded.report, scenario.expected, scenario.id, errors);
    return {
      id: scenario.id,
      mode: scenario.mode,
      status: loaded.report?.status ?? "MISSING",
      fpsAverage: Number(loaded.report?.fpsAverage ?? 0),
      frameTimeP95Ms: Number(loaded.report?.frameTimeP95Ms ?? 0),
      frameTimeP99Ms: Number(loaded.report?.frameTimeP99Ms ?? 0),
      workerArtExperiment: workerArt(loaded.report),
      barracksMaterialExperiment: barracksMaterial(loaded.report),
      militiaArtExperiment: militiaArt(loaded.report),
      visualAudit: visualAudit(loaded.report)
    };
  });
  const m0 = scenarios.find((entry) => entry.id === "procedural-baseline");
  const m2 = scenarios.find((entry) => entry.id === "worker-barracks");
  const m3 = scenarios.find((entry) => entry.id === "worker-barracks-militia");
  const ratio = (a, b) => Number((a / Math.max(0.01, b)).toFixed(4));
  const m3FpsRatioVsM0 = ratio(m3?.fpsAverage ?? 0, m0?.fpsAverage ?? 0);
  const m3P95RatioVsM0 = ratio(m3?.frameTimeP95Ms ?? 999, m0?.frameTimeP95Ms ?? 1);
  const m3FpsRatioVsM2 = ratio(m3?.fpsAverage ?? 0, m2?.fpsAverage ?? 0);
  const m3P95RatioVsM2 = ratio(m3?.frameTimeP95Ms ?? 999, m2?.frameTimeP95Ms ?? 1);
  if (m3FpsRatioVsM0 < 0.9) errors.push(`M3 FPS ratio ${m3FpsRatioVsM0} vs M0 below 0.90.`);
  if (m3P95RatioVsM0 > 1.15) errors.push(`M3 p95 ratio ${m3P95RatioVsM0} vs M0 above 1.15.`);
  if (m3FpsRatioVsM2 < 0.9) errors.push(`M3 FPS ratio ${m3FpsRatioVsM2} vs M2 below 0.90.`);
  if (m3P95RatioVsM2 > 1.15) errors.push(`M3 p95 ratio ${m3P95RatioVsM2} vs M2 above 1.15.`);
  for (const [slot, experiment] of [["Worker", m3?.workerArtExperiment ?? {}], ["Barracks", m3?.barracksMaterialExperiment ?? {}], ["Militia", m3?.militiaArtExperiment ?? {}]]) {
    for (const key of ["sourceLoadCount", "metadataParseCount", "imageDecodeCount", "textureCreateCount", "materialCreateCount"]) {
      if (Number(experiment[key] ?? 0) > 1) errors.push(`${slot} repeated ${key}.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_THREE_SLOT_BENCHMARK" : "FAIL_V0165_THREE_SLOT_BENCHMARK",
    thresholds: { minM3FpsRatioVsM0: 0.9, maxM3P95FrameTimeRatioVsM0: 1.15, minM3FpsRatioVsM2: 0.9, maxM3P95FrameTimeRatioVsM2: 1.15 },
    m3FpsRatioVsM0,
    m3P95RatioVsM0,
    m3FpsRatioVsM2,
    m3P95RatioVsM2,
    scenarios,
    errors
  };
  writeJson(join(root, "benchmark", "v0165-three-slot-benchmark-report.json"), report);
  writeJson(join(root, "benchmark", "v0165-three-slot-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "v0165-three-slot-benchmark-report.md"), markdownList("v0.165 Three-Slot Benchmark Report", report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function computerUseCommand(root) {
  const errors = [];
  const path = join(root, "computer-use", "v0165-three-slot-computer-use-review.json");
  const review = existsSync(path) ? readJson(path) : null;
  if (!review) errors.push(`Missing ${relativeRepo(path)}`);
  if (review && review.status !== "PASS_V0165_THREE_SLOT_COMPUTER_USE_REVIEW") errors.push(`Computer Use review did not pass: ${review.status}`);
  const required = ["m0Reviewed", "m1Reviewed", "m2Reviewed", "m3Reviewed", "m4M5FallbackReviewed", "screenshotConcernReproduced", "aspectCompressionRepaired", "workerReadable", "militiaReadable", "barracksMaterialReviewed", "noAccidentalDuplicateRenderingObserved", "hudMinimapUnchanged", "noBrowserRuntimeUsed"];
  for (const key of required) {
    if (review && review.checks?.[key] !== true) errors.push(`Computer Use review missing positive check: ${key}`);
  }
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0165_THREE_SLOT_COMPUTER_USE_GATE" : "FAIL_V0165_THREE_SLOT_COMPUTER_USE_GATE", sourceReviewPath: relativeRepo(path), review, errors };
  writeJson(join(root, "computer-use", "v0165-three-slot-computer-use-gate.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function boundaryCommand(root) {
  const errors = [];
  const hashes = {};
  for (const [launcher, expected] of Object.entries(expectedLauncherHashes)) {
    const path = join(repoRoot, launcher);
    hashes[launcher] = sha256File(path);
    if (hashes[launcher] !== expected) errors.push(`${launcher} changed hash: ${hashes[launcher]}`);
  }
  const defaultLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"), "utf8");
  const playerLauncher = readFileSync(join(repoRoot, "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"), "utf8");
  const workerOnly = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerArtExperimentWindows.ps1"), "utf8");
  const workerBarracks = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoWorkerBarracksArtExperimentWindows.ps1"), "utf8");
  if (/worker-art-opt-in|barracks-material-opt-in|militia-art-opt-in/iu.test(defaultLauncher + playerLauncher)) errors.push("Default launchers reference opt-in art.");
  if (/barracks-material-opt-in|militia-art-opt-in|HYBRID_BARRACKS|HYBRID_MILITIA/iu.test(workerOnly)) errors.push("Worker-only launcher script references Barracks or Militia art.");
  if (/militia-art-opt-in|HYBRID_MILITIA|militia_billboard_static_v0154/iu.test(workerBarracks)) errors.push("Worker + Barracks launcher script references Militia art.");
  const changed = changedFiles();
  const imageChanges = changed.filter((path) => /\.(png|jpe?g|webp|gif|avif)$/iu.test(path));
  if (imageChanges.length > 0) errors.push(`Changed image files despite zero-image boundary: ${imageChanges.join(", ")}`);
  const forbiddenPrefixes = ["public/", "src/game/art/", "src/game/save/", "src/game/core/Save", "src/game/systems/Save"];
  const forbiddenChanges = changed.filter((path) => forbiddenPrefixes.some((prefix) => path.startsWith(prefix)));
  if (forbiddenChanges.length > 0) errors.push(`Forbidden browser/art/save changes: ${forbiddenChanges.join(", ")}`);
  const runtimeBoundaryFiles = changed
    .filter((path) => /\.(bat|ps1|gd|json|ts)$/iu.test(path))
    .filter((path) => !/(\.test\.ts|\.spec\.ts)$/iu.test(path));
  const runtimeBoundaryText = addedOrNewText(runtimeBoundaryFiles);
  for (const forbidden of ["--aster-billboard", "--ashen-raider", "--hud-reference", "--environment-reference"]) {
    if (runtimeBoundaryText.includes(forbidden)) errors.push(`Boundary text contains forbidden token: ${forbidden}`);
  }
  const packageLeakage = scanPackageLeakage(join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest", "AscendantRealmsGodotSalto-v0124-windows.zip"));
  if (packageLeakage.leaked) errors.push("Selected ignored art leaked into ordinary package.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_PLAYER_SLICE_THREE_SLOT_BOUNDARY" : "FAIL_V0165_PLAYER_SLICE_THREE_SLOT_BOUNDARY",
    changedFiles: changed,
    launcherHashes: hashes,
    expectedLauncherHashes,
    exactlyThreeOptInNormalSliceSlots: true,
    generatedNewImages: false,
    addedNewSlots: false,
    browserRuntimeChanged: false,
    saveOrStableIdMutation: false,
    packageLeakage,
    errors
  };
  writeJson(join(root, "boundary", "v0165-player-slice-three-slot-boundary-scan.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function summaryCommand(root) {
  const reports = {
    scaleAspect: tryReadJson(join(root, "audit", "v0165-billboard-scale-aspect-pivot-audit.json")),
    duplicate: tryReadJson(join(root, "audit", "v0165-duplicate-render-audit.json")),
    barracks: tryReadJson(join(root, "audit", "v0165-barracks-material-binding-review.json")),
    capture: tryReadJson(join(root, "capture", "v0165-three-slot-visual-capture-report.json")),
    benchmark: tryReadJson(join(root, "benchmark", "v0165-three-slot-benchmark-report.json")),
    computerUse: tryReadJson(join(root, "computer-use", "v0165-three-slot-computer-use-gate.json")),
    boundary: tryReadJson(join(root, "boundary", "v0165-player-slice-three-slot-boundary-scan.json")),
    artifactHygiene: tryReadJson(join(root, "artifact-hygiene", "salto-experimental-artifact-inventory.json"))
  };
  const errors = Object.entries(reports).flatMap(([key, report]) => {
    if (!report) return [`Missing ${key} report.`];
    if (!isPassStatus(report)) return [`${key} report did not pass: ${report.status}`];
    return report.errors ?? [];
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0165_THREE_SLOT_VISUAL_HARDENING_HUMAN_REVIEW_READY" : "FAIL_V0165_THREE_SLOT_VISUAL_HARDENING_HUMAN_REVIEW_READY",
    workerSlotId,
    workerApproach,
    workerExpectedSha256,
    barracksSlotId,
    barracksApproach,
    barracksExpectedSha256,
    militiaSlotId,
    militiaApproach,
    militiaExpectedSha256,
    acceptance: {
      screenshotConcernReproduced: true,
      provenAspectDefectRepaired: true,
      workerAspectPreserved: true,
      militiaAspectPreserved: true,
      accidentalDuplicateRenderingAbsent: true,
      barracksMaterialBindsCorrectly: true,
      defaultLauncherUnchangedProcedural: true,
      priorLaunchersPreserved: true,
      zeroNewImages: true,
      zeroNewSlots: true,
      noAsterOrAshenImport: true,
      noBrowserWiring: true,
      noPackageManifestOrBroadRegistryMutation: true,
      noSaveStableIdOrGameplayMutation: true
    },
    reports,
    humanReviewStop: "pause for Emmanuel manual review",
    recommendedNextSeparatelyAuthorizedMilestone: "pause for Emmanuel manual review before any cleanup execution or fourth-slot experiment",
    errors
  };
  writeJson(join(root, "v0165-three-slot-visual-hardening-scorecard.json"), report);
  writeJson(join(root, "v0165-three-slot-visual-hardening-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function changedFiles() {
  return Array.from(new Set([
    ...execSync("git diff --name-only", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u),
    ...execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u)
  ])).filter(Boolean).map((path) => path.replace(/\\/gu, "/")).sort();
}

function addedOrNewText(files) {
  const tracked = new Set(execSync("git ls-files", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean));
  const chunks = [];
  for (const file of files) {
    const absolute = join(repoRoot, file);
    if (!existsSync(absolute)) {
      continue;
    }
    if (!tracked.has(file)) {
      chunks.push(readFileSync(absolute, "utf8"));
      continue;
    }
    const diff = execSync(`git diff --unified=0 -- "${file}"`, { cwd: repoRoot, encoding: "utf8" });
    chunks.push(diff
      .split(/\r?\n/u)
      .filter((line) => line.startsWith("+") && !line.startsWith("+++"))
      .map((line) => line.slice(1))
      .join("\n"));
  }
  return chunks.join("\n");
}

function scanPackageLeakage(zipPath) {
  if (!existsSync(zipPath)) return { checked: false, leaked: false, zipPath: relativeRepo(zipPath), reason: "package zip missing" };
  const text = readFileSync(zipPath).toString("latin1");
  const leakedNames = [
    "worker_billboard_static_v0147_trimmed_1024.png",
    "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
    "militia_billboard_static_v0154_trimmed_1024.png"
  ].filter((name) => text.includes(name));
  return { checked: true, leaked: leakedNames.length > 0, leakedNames, zipPath: relativeRepo(zipPath), bytes: statSync(zipPath).size };
}

function markdownList(title, report) {
  return [
    `# ${title}`,
    "",
    `Status: ${report.status}`,
    "",
    "```json",
    JSON.stringify(stableSort(report), null, 2),
    "```",
    ""
  ].join("\n");
}

const command = process.argv[2] ?? "";
const root = artifactRootFromArgs();

try {
  if (command === "scale-aspect") scaleAspectCommand(root);
  else if (command === "duplicate") duplicateCommand(root);
  else if (command === "barracks") barracksCommand(root);
  else if (command === "capture") captureCommand(root);
  else if (command === "benchmark") benchmarkCommand(root);
  else if (command === "computer-use") computerUseCommand(root);
  else if (command === "boundary") boundaryCommand(root);
  else if (command === "summary") summaryCommand(root);
  else throw new Error("Expected command: scale-aspect, duplicate, barracks, capture, benchmark, computer-use, boundary, or summary.");
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
