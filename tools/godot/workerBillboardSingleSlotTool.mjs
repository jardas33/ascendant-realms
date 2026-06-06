import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync, inflateSync } from "node:zlib";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const slotId = "worker_billboard_static_v0147";
const checkpoint = "v0.147";
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0147");
const localSlotRoot = join(artifactRoot, "local-worker-slot");
const evidenceRootDefault = join(artifactRoot, "evidence");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const fallbackRoot = join(comparatorRoot, "fallback");
const fallbackPng = join(fallbackRoot, `${slotId}_fallback.png`);
const fallbackContract = join(fallbackRoot, `${slotId}_fallback.contract.json`);
const localCutout = join(localSlotRoot, `${slotId}.png`);
const localSource = join(localSlotRoot, `${slotId}_source_chromakey.png`);
const localMetadata = join(localSlotRoot, `${slotId}.metadata.json`);
const runtimeReportName = "worker-billboard-single-slot-runtime.json";
const approaches = [
  "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE",
  "HYBRID_LOCAL_WORKER_SLOT",
  "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
];
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

function sha256Bytes(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

function sha256File(path) {
  return sha256Bytes(readFileSync(path));
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function evidenceRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : evidenceRootDefault;
}

const crcTable = Array.from({ length: 256 }, (_, index) => {
  let c = index;
  for (let k = 0; k < 8; k += 1) {
    c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  }
  return c >>> 0;
});

function crc32(buffers) {
  let c = 0xffffffff;
  for (const buffer of buffers) {
    for (const byte of buffer) {
      c = crcTable[(c ^ byte) & 0xff] ^ (c >>> 8);
    }
  }
  return (c ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data = Buffer.alloc(0)) {
  const typeBuffer = Buffer.from(type, "ascii");
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length, 0);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32([typeBuffer, data]), 0);
  return Buffer.concat([length, typeBuffer, data, crc]);
}

function encodePng(width, height, rgba) {
  const header = Buffer.from("89504e470d0a1a0a", "hex");
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;
  const stride = width * 4;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y += 1) {
    const rawOffset = y * (stride + 1);
    raw[rawOffset] = 0;
    Buffer.from(rgba.buffer, rgba.byteOffset + y * stride, stride).copy(raw, rawOffset + 1);
  }
  return Buffer.concat([header, pngChunk("IHDR", ihdr), pngChunk("IDAT", deflateSync(raw, { level: 9 })), pngChunk("IEND")]);
}

function decodePng(buffer) {
  if (buffer.toString("hex", 0, 8) !== "89504e470d0a1a0a") {
    throw new Error("Unsupported PNG signature.");
  }
  let offset = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  const idat = [];
  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString("ascii", offset + 4, offset + 8);
    const data = buffer.subarray(offset + 8, offset + 8 + length);
    offset += 12 + length;
    if (type === "IHDR") {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
    } else if (type === "IDAT") {
      idat.push(data);
    } else if (type === "IEND") {
      break;
    }
  }
  if (bitDepth !== 8 || ![2, 6].includes(colorType)) {
    throw new Error(`Unsupported PNG format. Expected 8-bit RGB/RGBA, got bitDepth=${bitDepth} colorType=${colorType}.`);
  }
  const inflated = inflateSync(Buffer.concat(idat));
  const channels = colorType === 6 ? 4 : 3;
  const sourceStride = width * channels;
  const rgbaStride = width * 4;
  const rgba = Buffer.alloc(rgbaStride * height);
  let source = 0;
  let previous = Buffer.alloc(sourceStride);
  for (let y = 0; y < height; y += 1) {
    const filter = inflated[source];
    source += 1;
    const row = Buffer.alloc(sourceStride);
    for (let x = 0; x < sourceStride; x += 1) {
      const value = inflated[source];
      source += 1;
      const left = x >= channels ? row[x - channels] : 0;
      const up = previous[x] ?? 0;
      const upLeft = x >= channels ? previous[x - channels] : 0;
      let recon = value;
      if (filter === 1) {
        recon = value + left;
      } else if (filter === 2) {
        recon = value + up;
      } else if (filter === 3) {
        recon = value + Math.floor((left + up) / 2);
      } else if (filter === 4) {
        const p = left + up - upLeft;
        const pa = Math.abs(p - left);
        const pb = Math.abs(p - up);
        const pc = Math.abs(p - upLeft);
        recon = value + (pa <= pb && pa <= pc ? left : pb <= pc ? up : upLeft);
      } else if (filter !== 0) {
        throw new Error(`Unsupported PNG filter ${filter}.`);
      }
      row[x] = recon & 0xff;
    }
    for (let x = 0; x < width; x += 1) {
      const sourceIndex = x * channels;
      const rgbaIndex = y * rgbaStride + x * 4;
      rgba[rgbaIndex] = row[sourceIndex];
      rgba[rgbaIndex + 1] = row[sourceIndex + 1];
      rgba[rgbaIndex + 2] = row[sourceIndex + 2];
      rgba[rgbaIndex + 3] = channels === 4 ? row[sourceIndex + 3] : 255;
    }
    previous = row;
  }
  return { width, height, rgba };
}

function blendPixel(rgba, width, x, y, color) {
  if (x < 0 || y < 0 || x >= width) {
    return;
  }
  const index = (y * width + x) * 4;
  if (index < 0 || index + 3 >= rgba.length) {
    return;
  }
  const sourceAlpha = color[3] / 255;
  const destAlpha = rgba[index + 3] / 255;
  const outAlpha = sourceAlpha + destAlpha * (1 - sourceAlpha);
  if (outAlpha <= 0) {
    return;
  }
  rgba[index] = Math.round((color[0] * sourceAlpha + rgba[index] * destAlpha * (1 - sourceAlpha)) / outAlpha);
  rgba[index + 1] = Math.round((color[1] * sourceAlpha + rgba[index + 1] * destAlpha * (1 - sourceAlpha)) / outAlpha);
  rgba[index + 2] = Math.round((color[2] * sourceAlpha + rgba[index + 2] * destAlpha * (1 - sourceAlpha)) / outAlpha);
  rgba[index + 3] = Math.round(outAlpha * 255);
}

function drawRect(rgba, width, height, x0, y0, x1, y1, color) {
  const left = Math.max(0, Math.floor(x0));
  const top = Math.max(0, Math.floor(y0));
  const right = Math.min(width - 1, Math.ceil(x1));
  const bottom = Math.min(height - 1, Math.ceil(y1));
  for (let y = top; y <= bottom; y += 1) {
    for (let x = left; x <= right; x += 1) {
      blendPixel(rgba, width, x, y, color);
    }
  }
}

function drawEllipse(rgba, width, height, cx, cy, rx, ry, color) {
  const left = Math.max(0, Math.floor(cx - rx));
  const top = Math.max(0, Math.floor(cy - ry));
  const right = Math.min(width - 1, Math.ceil(cx + rx));
  const bottom = Math.min(height - 1, Math.ceil(cy + ry));
  for (let y = top; y <= bottom; y += 1) {
    for (let x = left; x <= right; x += 1) {
      const nx = (x - cx) / rx;
      const ny = (y - cy) / ry;
      if (nx * nx + ny * ny <= 1) {
        blendPixel(rgba, width, x, y, color);
      }
    }
  }
}

function drawLine(rgba, width, height, x0, y0, x1, y1, thickness, color) {
  const minX = Math.max(0, Math.floor(Math.min(x0, x1) - thickness));
  const maxX = Math.min(width - 1, Math.ceil(Math.max(x0, x1) + thickness));
  const minY = Math.max(0, Math.floor(Math.min(y0, y1) - thickness));
  const maxY = Math.min(height - 1, Math.ceil(Math.max(y0, y1) + thickness));
  const dx = x1 - x0;
  const dy = y1 - y0;
  const lengthSq = dx * dx + dy * dy;
  for (let y = minY; y <= maxY; y += 1) {
    for (let x = minX; x <= maxX; x += 1) {
      const t = lengthSq === 0 ? 0 : Math.max(0, Math.min(1, ((x - x0) * dx + (y - y0) * dy) / lengthSq));
      const px = x0 + t * dx;
      const py = y0 + t * dy;
      const distance = Math.hypot(x - px, y - py);
      if (distance <= thickness) {
        blendPixel(rgba, width, x, y, color);
      }
    }
  }
}

function fallbackImageBuffer() {
  const width = 512;
  const height = 512;
  const rgba = Buffer.alloc(width * height * 4);
  const leather = [112, 82, 51, 255];
  const cloth = [98, 96, 82, 255];
  const shadow = [45, 38, 29, 255];
  const wood = [126, 82, 43, 255];
  const metal = [134, 139, 132, 255];
  const lume = [85, 188, 170, 230];
  drawRect(rgba, width, height, 223, 188, 290, 332, cloth);
  drawRect(rgba, width, height, 238, 326, 259, 420, shadow);
  drawRect(rgba, width, height, 270, 326, 291, 420, shadow);
  drawRect(rgba, width, height, 222, 420, 263, 438, leather);
  drawRect(rgba, width, height, 262, 420, 304, 438, leather);
  drawEllipse(rgba, width, height, 255, 156, 34, 38, [148, 105, 78, 255]);
  drawRect(rgba, width, height, 219, 140, 291, 154, leather);
  drawRect(rgba, width, height, 211, 205, 232, 303, leather);
  drawRect(rgba, width, height, 288, 206, 310, 303, leather);
  drawRect(rgba, width, height, 302, 190, 358, 306, wood);
  drawRect(rgba, width, height, 316, 174, 342, 190, wood);
  drawLine(rgba, width, height, 205, 258, 142, 356, 8, wood);
  drawRect(rgba, width, height, 119, 350, 161, 379, metal);
  drawLine(rgba, width, height, 210, 191, 313, 330, 5, leather);
  drawEllipse(rgba, width, height, 298, 294, 14, 18, lume);
  drawRect(rgba, width, height, 292, 274, 305, 294, metal);
  drawLine(rgba, width, height, 313, 234, 367, 164, 5, metal);
  drawLine(rgba, width, height, 346, 164, 384, 160, 5, metal);
  drawEllipse(rgba, width, height, 255, 442, 122, 9, [0, 0, 0, 48]);
  return encodePng(width, height, rgba);
}

function analyzePngBuffer(buffer) {
  const decoded = decodePng(buffer);
  let transparentPixels = 0;
  let partiallyTransparentPixels = 0;
  let opaquePixels = 0;
  let left = decoded.width;
  let top = decoded.height;
  let right = -1;
  let bottom = -1;
  for (let y = 0; y < decoded.height; y += 1) {
    for (let x = 0; x < decoded.width; x += 1) {
      const alpha = decoded.rgba[(y * decoded.width + x) * 4 + 3];
      if (alpha === 0) {
        transparentPixels += 1;
      } else if (alpha < 255) {
        partiallyTransparentPixels += 1;
      } else {
        opaquePixels += 1;
      }
      if (alpha > 8) {
        left = Math.min(left, x);
        top = Math.min(top, y);
        right = Math.max(right, x);
        bottom = Math.max(bottom, y);
      }
    }
  }
  const trimBounds =
    right >= left
      ? {
          left,
          top,
          right,
          bottom,
          width: right - left + 1,
          height: bottom - top + 1
        }
      : null;
  return {
    width: decoded.width,
    height: decoded.height,
    transparentPixels,
    partiallyTransparentPixels,
    opaquePixels,
    hasAlpha: transparentPixels > 0 || partiallyTransparentPixels > 0,
    transparentCornerCount: [
      decoded.rgba[3],
      decoded.rgba[(decoded.width - 1) * 4 + 3],
      decoded.rgba[((decoded.height - 1) * decoded.width) * 4 + 3],
      decoded.rgba[((decoded.height - 1) * decoded.width + decoded.width - 1) * 4 + 3]
    ].filter((alpha) => alpha === 0).length,
    trimBounds,
    pivot: trimBounds
      ? {
          posture: "bottom-center-foot-pivot",
          normalizedX: Number(((trimBounds.left + trimBounds.width / 2) / decoded.width).toFixed(4)),
          normalizedY: Number((trimBounds.bottom / decoded.height).toFixed(4))
        }
      : null
  };
}

function analyzePngFile(path) {
  const buffer = readFileSync(path);
  return {
    path: relativeRepo(path),
    sha256: sha256Bytes(buffer),
    byteLength: buffer.length,
    ...analyzePngBuffer(buffer)
  };
}

function fallbackRecord(write) {
  const buffer = fallbackImageBuffer();
  const analysis = analyzePngBuffer(buffer);
  const sha256 = sha256Bytes(buffer);
  const contract = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    fallbackId: `${slotId}_tracked_diagnostic_fallback`,
    generatedBy: "tools/godot/workerBillboardSingleSlotTool.mjs fallback",
    originalGeometricDiagnosticOnly: true,
    productionApproval: "forbidden",
    privateComparatorOnly: true,
    browserIntegration: "forbidden",
    playerSliceIntegration: "forbidden",
    sha256,
    byteLength: buffer.length,
    dimensions: {
      width: analysis.width,
      height: analysis.height
    },
    alphaPosture: "tracked-transparent-diagnostic-fallback",
    trimBounds: analysis.trimBounds,
    pivot: analysis.pivot
  };
  if (write) {
    mkdirSync(fallbackRoot, { recursive: true });
    writeFileSync(fallbackPng, buffer);
    writeJson(fallbackContract, contract);
  }
  return {
    status: "PASS_V0147_WORKER_BILLBOARD_FALLBACK_GENERATED",
    path: relativeRepo(fallbackPng),
    contractPath: relativeRepo(fallbackContract),
    ...contract
  };
}

function fallbackCheck() {
  const generated = fallbackRecord(false);
  const errors = [];
  if (!existsSync(fallbackPng)) {
    errors.push(`Missing fallback PNG: ${relativeRepo(fallbackPng)}`);
  } else if (sha256File(fallbackPng) !== generated.sha256) {
    errors.push(`Tracked fallback hash does not match deterministic generator for ${relativeRepo(fallbackPng)}.`);
  }
  if (!existsSync(fallbackContract)) {
    errors.push(`Missing fallback contract: ${relativeRepo(fallbackContract)}`);
  } else {
    const contract = readJson(fallbackContract);
    if (contract.sha256 !== generated.sha256) {
      errors.push("Fallback contract hash does not match deterministic generator.");
    }
  }
  return {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0147_WORKER_BILLBOARD_FALLBACK_REPRODUCIBILITY" : "PASS_V0147_WORKER_BILLBOARD_FALLBACK_REPRODUCIBILITY",
    errors,
    fallback: generated
  };
}

function localMetadataRecord(write) {
  const errors = [];
  if (!existsSync(localSource)) {
    errors.push(`Missing local generated chroma source: ${relativeRepo(localSource)}`);
  }
  if (!existsSync(localCutout)) {
    errors.push(`Missing local alpha cutout: ${relativeRepo(localCutout)}`);
  }
  if (errors.length) {
    return {
      schemaVersion: 1,
      checkpoint,
      status: "FAIL_V0147_WORKER_BILLBOARD_LOCAL_METADATA",
      errors
    };
  }
  const sourceAnalysis = analyzePngFile(localSource);
  const cutoutAnalysis = analyzePngFile(localCutout);
  const metadata = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    role: {
      faction: "free_marches",
      unit: "Worker",
      function: "Builder / camp hand / utility site support",
      notes: "Builds, repairs, and boosts sites. Command Hall trains Workers only."
    },
    generator: "Codex built-in image generation",
    modelProviderPosture: "built-in image_gen; exact model/provider not exposed by tool",
    generationDate: new Date().toISOString(),
    sourcePosture: "one original generated chroma-key source, deterministic matte-to-alpha conversion, source preserved",
    sourcePath: relativeRepo(localSource),
    sourceSha256: sourceAnalysis.sha256,
    licencePosture: {
      originalIpIntent: true,
      runtimeUse: "forbidden unless future explicit approval",
      productionUse: "forbidden"
    },
    protectedIpReview: {
      status: "pending"
    },
    humanReviewStatus: "pending-review",
    sha256: cutoutAnalysis.sha256,
    dimensions: {
      width: cutoutAnalysis.width,
      height: cutoutAnalysis.height
    },
    alphaPosture: cutoutAnalysis.hasAlpha
      ? "matte-to-alpha-transparent-png; original chroma source preserved"
      : "opaque-or-unexpected-alpha",
    alphaStats: {
      transparentPixels: cutoutAnalysis.transparentPixels,
      partiallyTransparentPixels: cutoutAnalysis.partiallyTransparentPixels,
      opaquePixels: cutoutAnalysis.opaquePixels,
      transparentCornerCount: cutoutAnalysis.transparentCornerCount
    },
    trimBounds: cutoutAnalysis.trimBounds,
    pivot: cutoutAnalysis.pivot,
    intendedScope: "private isolated Godot hybrid comparator only",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    exactlyOneGeneratedImageForV0147: true
  };
  if (write) {
    writeJson(localMetadata, metadata);
  }
  return {
    schemaVersion: 1,
    checkpoint,
    status: cutoutAnalysis.hasAlpha && cutoutAnalysis.transparentCornerCount === 4 ? "PASS_V0147_WORKER_BILLBOARD_LOCAL_METADATA" : "FAIL_V0147_WORKER_BILLBOARD_LOCAL_METADATA",
    errors: cutoutAnalysis.hasAlpha ? [] : ["Local cutout is missing alpha."],
    metadataPath: relativeRepo(localMetadata),
    metadata
  };
}

function validateLocalSlot() {
  if (!existsSync(localCutout)) {
    return {
      present: false,
      sourceLoaded: "tracked-diagnostic-fallback",
      reason: "Ignored local experimental Worker cutout is absent; fallback is valid for clean-checkout reproducibility."
    };
  }
  const errors = [];
  if (!existsSync(localMetadata)) {
    errors.push(`Missing local metadata: ${relativeRepo(localMetadata)}`);
  }
  const analysis = analyzePngFile(localCutout);
  let metadata = null;
  if (existsSync(localMetadata)) {
    metadata = readJson(localMetadata);
    if (metadata.slotId !== slotId) {
      errors.push(`Local metadata slotId mismatch: ${metadata.slotId}`);
    }
    if (metadata.sha256 !== analysis.sha256) {
      errors.push("Local metadata hash does not match local cutout hash.");
    }
    if (metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
      errors.push("Local metadata boundary flags are invalid.");
    }
  }
  if (!analysis.hasAlpha || analysis.transparentCornerCount !== 4) {
    errors.push("Local cutout alpha posture is not valid enough for comparator intake.");
  }
  return {
    present: true,
    sourceLoaded: errors.length ? "invalid-local-source-refused" : "local-experimental-cutout",
    errors,
    analysis,
    metadata
  };
}

function validate() {
  const errors = [];
  const requiredFiles = [
    "GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json",
    "tools/godot/workerBillboardSingleSlotTool.mjs",
    "tools/godot/runGodotWorkerBillboardValidation.ps1",
    "tools/godot/runGodotWorkerBillboardFallbackReproducibility.ps1",
    "tools/godot/runGodotWorkerBillboardBenchmarkWindows.ps1",
    "tools/godot/captureGodotWorkerBillboardWindows.ps1",
    "docs/V0147_WORKER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
    "docs/V0147_WORKER_BILLBOARD_SLOT_CONTRACT.md",
    "docs/V0147_WORKER_BILLBOARD_VALIDATION_REPORT.md",
    "docs/V0147_WORKER_BILLBOARD_BENCHMARK_REPORT.md",
    "docs/V0147_WORKER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
    "docs/V0147_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0147_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.147 file: ${file}`);
    }
  }

  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const script of [
    "godot:worker-billboard:validate",
    "godot:worker-billboard:fallback:reproduce",
    "godot:worker-billboard:benchmark:headed",
    "godot:worker-billboard:capture"
  ]) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script: ${script}`);
    }
  }

  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--worker-billboard-single-slot")) {
    errors.push("Root script does not expose private --worker-billboard-single-slot dispatch.");
  }
  const project = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "project.godot"), "utf8");
  if (!project.includes('run/main_scene="res://scenes/salto_spike_root.tscn"')) {
    errors.push("Godot default main scene changed; worker slot must stay private.");
  }
  for (const launcher of ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("worker-billboard-single-slot") || text.includes("WORKER_BILLBOARD_SINGLE_SLOT")) {
      errors.push(`${launcher} references the private Worker billboard experiment.`);
    }
  }

  const fallback = fallbackCheck();
  errors.push(...fallback.errors);
  const local = validateLocalSlot();
  if (local.present) {
    errors.push(...local.errors);
  }

  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0147_WORKER_BILLBOARD_SLOT_VALIDATION" : "PASS_V0147_WORKER_BILLBOARD_SLOT_VALIDATION",
    errors,
    slotId,
    fallback,
    localExperimentalCutout: local,
    comparatorHarnessOnly: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    approaches,
    tiers
  };
  writeJson(join(evidenceRootFromArgs(), "worker-billboard-slot-validation.json"), report);
  return report;
}

function report() {
  validate();
  const evidenceRoot = evidenceRootFromArgs();
  const rawPath = join(evidenceRoot, runtimeReportName);
  if (!existsSync(rawPath)) {
    throw new Error(`Missing Godot Worker billboard runtime report: ${relativeRepo(rawPath)}`);
  }
  const raw = readJson(rawPath);
  const errors = [];
  const benchmarkRows = raw.benchmarks ?? [];
  for (const approach of approaches) {
    for (const tier of tiers) {
      if (!benchmarkRows.some((row) => row.approach === approach && row.tier === tier)) {
        errors.push(`Missing benchmark row ${approach} ${tier}.`);
      }
    }
  }
  const screenshotRoot = join(evidenceRoot, "screenshots");
  const screenshots = [];
  for (const capture of raw.captures ?? []) {
    const path = join(screenshotRoot, capture.fileName);
    if (!existsSync(path)) {
      errors.push(`Missing screenshot ${relativeRepo(path)}.`);
      continue;
    }
    screenshots.push({
      id: capture.id,
      fileName: capture.fileName,
      path: relativeRepo(path),
      absolutePath: path,
      sha256: sha256File(path),
      width: capture.width,
      height: capture.height,
      approach: capture.approach,
      tier: capture.tier ?? null,
      view: capture.view ?? "benchmark",
      scaleMultiplier: capture.scaleMultiplier ?? null,
      assetSourceLoaded: capture.assetSourceLoaded ?? null
    });
  }
  const baselineL = benchmarkRows.find((row) => row.approach === "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE" && row.tier === "L");
  const localL = benchmarkRows.find((row) => row.approach === "HYBRID_LOCAL_WORKER_SLOT" && row.tier === "L");
  const p95AbsoluteJitterAllowanceMs = 0.5;
  const p95AbsoluteDeltaMs = baselineL && localL
    ? Number((localL.p95FrameTimeMs - baselineL.p95FrameTimeMs).toFixed(4))
    : null;
  const averageFpsPass = baselineL && localL ? localL.averageFps >= baselineL.averageFps * 0.9 : false;
  const p95RatioPass = baselineL && localL ? localL.p95FrameTimeMs <= baselineL.p95FrameTimeMs * 1.15 : false;
  const p95AbsoluteJitterPass = p95AbsoluteDeltaMs !== null ? p95AbsoluteDeltaMs <= p95AbsoluteJitterAllowanceMs : false;
  const p95FrameTimePass = p95RatioPass || p95AbsoluteJitterPass;
  const threshold = baselineL && localL
    ? {
        baselineAverageFps: baselineL.averageFps,
        localAverageFps: localL.averageFps,
        averageFpsRatio: Number((localL.averageFps / baselineL.averageFps).toFixed(4)),
        baselineP95FrameTimeMs: baselineL.p95FrameTimeMs,
        localP95FrameTimeMs: localL.p95FrameTimeMs,
        p95FrameTimeRatio: Number((localL.p95FrameTimeMs / baselineL.p95FrameTimeMs).toFixed(4)),
        p95FrameTimeAbsoluteDeltaMs: p95AbsoluteDeltaMs,
        p95FrameTimeAbsoluteJitterAllowanceMs: p95AbsoluteJitterAllowanceMs,
        averageFpsPass,
        p95FrameTimeRatioPass: p95RatioPass,
        p95FrameTimeAbsoluteJitterPass: p95AbsoluteJitterPass,
        p95FrameTimePass,
        assetSourceLoaded: localL.assetSourceLoaded,
        status: averageFpsPass && p95FrameTimePass
          ? "PASS_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD"
          : "FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD"
      }
    : {
        status: "FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD",
        reason: "Missing Tier L baseline or local Worker-slot row."
      };
  if (!threshold.status.startsWith("PASS")) {
    errors.push(threshold.reason ?? "Tier L local Worker slot threshold failed.");
  }
  const preferredScale = raw.preferredScalePosture ?? {
    scaleMultiplier: 1.0,
    reason: "Defaulted to 1.00x because no scale posture was reported."
  };
  const summary = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0147_WORKER_BILLBOARD_EVIDENCE" : "PASS_V0147_WORKER_BILLBOARD_EVIDENCE",
    errors,
    slotId,
    sourceRuntimeReport: relativeRepo(rawPath),
    assetSourceLoaded: raw.assetSourceLoaded,
    fallbackSource: raw.fallbackSource,
    localSource: raw.localSource,
    benchmarkRows,
    threshold,
    screenshots: screenshots.map(({ absolutePath, ...entry }) => entry),
    preferredScalePosture: preferredScale,
    boundaries: raw.boundaries,
    limitations: raw.limitations
  };
  writeJson(join(evidenceRoot, "worker-billboard-evidence.json"), summary);
  writeJson(join(evidenceRoot, "threshold-report.json"), threshold);
  writeJson(join(evidenceRoot, "screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint,
    screenshotCount: screenshots.length,
    screenshots: screenshots.map(({ absolutePath, ...entry }) => entry)
  });
  writeText(join(evidenceRoot, "benchmark-summary.md"), benchmarkMarkdown(summary));
  writeText(join(evidenceRoot, "visual-review-guide.md"), visualReviewMarkdown(summary));
  writeText(join(evidenceRoot, "contact-sheet.svg"), contactSheetSvg(screenshots));
  return summary;
}

function benchmarkMarkdown(summary) {
  const lines = [
    "# v0.147 Worker Billboard Single-Slot Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    "",
    "| Approach | Tier | Avg FPS | p95 ms | p99 ms | Frames | Duration ms | Entities | Billboards | Objects | Animation updates | Source |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.benchmarkRows) {
    lines.push(
      `| ${row.approach} | ${row.tier} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.p99FrameTimeMs} | ${row.frameCount} | ${row.benchmarkDurationMs} | ${row.entityCount} | ${row.billboardInstanceCount} | ${row.renderedObjectProxy} | ${row.animationUpdateProxy} | ${row.assetSourceLoaded} |`
    );
  }
  lines.push("", `Threshold: ${summary.threshold.status}`);
  lines.push(`Preferred scale posture: ${summary.preferredScalePosture.scaleMultiplier}x - ${summary.preferredScalePosture.reason}`);
  lines.push("");
  lines.push("Screenshots are private comparator evidence only and are not production runtime art.");
  return `${lines.join("\n")}\n`;
}

function visualReviewMarkdown(summary) {
  const lines = [
    "# v0.147 Worker Billboard Visual Review Packet",
    "",
    "Review questions:",
    "",
    "- Does the Worker read clearly at gameplay distance?",
    "- Does the Builder / camp-hand / repair-support role come through?",
    "- Does the alpha edge look acceptable?",
    "- Is the foot pivot stable?",
    "- Is selection-ring room adequate?",
    "- Does repeated-worker overlap remain readable?",
    "- Is 0.90x, 1.00x, or 1.10x the best runtime scale posture?",
    "- Does the hybrid posture deserve one more single-slot experiment?",
    "- Should the next slot be Aster static billboard, one environment material / structure slot, or a repair pass?",
    "",
    `Current preferred scale posture: ${summary.preferredScalePosture.scaleMultiplier}x.`,
    "",
    "Capture paths:",
    ""
  ];
  for (const shot of summary.screenshots) {
    lines.push(`- ${shot.id}: ${shot.path}`);
  }
  lines.push("");
  lines.push("This is private comparator-only intake, not production approval, not player-facing Salto integration, not final Worker design approval, and not final Godot selection.");
  return `${lines.join("\n")}\n`;
}

function contactSheetSvg(screenshots) {
  const cellWidth = 360;
  const cellHeight = 250;
  const margin = 24;
  const columns = 3;
  const rows = Math.ceil(screenshots.length / columns);
  const width = margin * 2 + cellWidth * columns;
  const height = margin * 2 + cellHeight * rows + 20;
  const cells = screenshots
    .map((shot, index) => {
      const x = margin + (index % columns) * cellWidth;
      const y = margin + Math.floor(index / columns) * cellHeight + 20;
      const href = shot.path.replace("artifacts/desktop-spikes/godot-salto/v0147/evidence/", "");
      return `<g>
  <image href="${href}" x="${x}" y="${y}" width="${cellWidth - 20}" height="${cellHeight - 44}" preserveAspectRatio="xMidYMid meet"/>
  <text x="${x}" y="${y + cellHeight - 24}" fill="#e8eadf" font-family="Arial" font-size="12">${shot.id}</text>
  <text x="${x}" y="${y + cellHeight - 8}" fill="#aab7aa" font-family="Arial" font-size="11">${shot.assetSourceLoaded ?? "source n/a"}</text>
</g>`;
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#111611"/>
<text x="${margin}" y="18" fill="#dce8d8" font-family="Arial" font-size="14">v0.147 Worker billboard single-slot private comparator captures</text>
${cells}
</svg>
`;
}

const command = process.argv[2] ?? "help";
function printReportAndSetExitCode(result) {
  console.log(stableStringify(result));
  if (typeof result.status === "string" && result.status.startsWith("FAIL")) {
    process.exitCode = 1;
  }
}

try {
  if (command === "fallback") {
    printReportAndSetExitCode(fallbackRecord(true));
  } else if (command === "fallback:check") {
    printReportAndSetExitCode(fallbackCheck());
  } else if (command === "local-metadata") {
    printReportAndSetExitCode(localMetadataRecord(true));
  } else if (command === "validate") {
    printReportAndSetExitCode(validate());
  } else if (command === "report") {
    printReportAndSetExitCode(report());
  } else {
    console.log("Usage: node tools/godot/workerBillboardSingleSlotTool.mjs <fallback|fallback:check|local-metadata|validate|report> [--artifact-root=<path>]");
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
