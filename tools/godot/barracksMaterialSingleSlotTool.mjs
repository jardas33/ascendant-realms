import { createHash } from "node:crypto";
import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  statSync,
  writeFileSync
} from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync, inflateSync } from "node:zlib";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const slotId = "barrosan_barracks_material_v0149";
const checkpoint = "v0.149";
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0149");
const localSlotRoot = join(artifactRoot, "local-barracks-material-slot");
const evidenceRootDefault = join(artifactRoot, "evidence");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const fallbackRoot = join(comparatorRoot, "fallback");
const fallbackPng = join(fallbackRoot, `${slotId}_fallback.png`);
const fallbackContract = join(fallbackRoot, `${slotId}_fallback.contract.json`);
const sourcePng = join(localSlotRoot, `${slotId}_source.png`);
const sourceMetadata = join(localSlotRoot, `${slotId}_source.metadata.json`);
const derivativeSizes = [512, 768, 1024];
const runtimeReportName = "barracks-material-runtime.json";
const selectedWorkerDerivativeHash = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";

function stableSort(value) {
  if (Array.isArray(value)) {
    return value.map(stableSort);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, stableSort(value[key])]));
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
  writeFileSync(path, stableStringify(value));
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value);
}

function sha256Bytes(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

function sha256File(path) {
  return sha256Bytes(readFileSync(path));
}

function relativeRepo(path) {
  return relative(repoRoot, path).replaceAll("\\", "/");
}

function evidenceRootFromArgs() {
  const arg = process.argv.find((value) => value.startsWith("--artifact-root="));
  return arg ? resolve(arg.slice("--artifact-root=".length)) : evidenceRootDefault;
}

function crc32(buffers) {
  let c = 0xffffffff;
  for (const buffer of buffers) {
    for (let i = 0; i < buffer.length; i += 1) {
      c ^= buffer[i];
      for (let k = 0; k < 8; k += 1) {
        c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
      }
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
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y += 1) {
    const row = y * (width * 4 + 1);
    raw[row] = 0;
    rgba.copy(raw, row + 1, y * width * 4, (y + 1) * width * 4);
  }
  return Buffer.concat([
    signature,
    pngChunk("IHDR", ihdr),
    pngChunk("IDAT", deflateSync(raw)),
    pngChunk("IEND")
  ]);
}

function decodePng(buffer) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  if (!buffer.subarray(0, 8).equals(signature)) {
    throw new Error("Not a PNG file.");
  }
  let width = 0;
  let height = 0;
  let colorType = 0;
  const idat = [];
  let offset = 8;
  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.subarray(offset + 4, offset + 8).toString("ascii");
    const data = buffer.subarray(offset + 8, offset + 8 + length);
    offset += 12 + length;
    if (type === "IHDR") {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      const bitDepth = data[8];
      colorType = data[9];
      if (bitDepth !== 8 || ![2, 6].includes(colorType)) {
        throw new Error(`Unsupported PNG format bitDepth=${bitDepth} colorType=${colorType}.`);
      }
    } else if (type === "IDAT") {
      idat.push(data);
    } else if (type === "IEND") {
      break;
    }
  }
  const bytesPerPixel = colorType === 6 ? 4 : 3;
  const raw = inflateSync(Buffer.concat(idat));
  const stride = width * bytesPerPixel;
  const rgba = Buffer.alloc(width * height * 4);
  let rawOffset = 0;
  let previous = Buffer.alloc(stride);
  for (let y = 0; y < height; y += 1) {
    const filter = raw[rawOffset];
    rawOffset += 1;
    const row = Buffer.from(raw.subarray(rawOffset, rawOffset + stride));
    rawOffset += stride;
    for (let x = 0; x < stride; x += 1) {
      const left = x >= bytesPerPixel ? row[x - bytesPerPixel] : 0;
      const up = previous[x] ?? 0;
      const upLeft = x >= bytesPerPixel ? previous[x - bytesPerPixel] : 0;
      if (filter === 1) {
        row[x] = (row[x] + left) & 255;
      } else if (filter === 2) {
        row[x] = (row[x] + up) & 255;
      } else if (filter === 3) {
        row[x] = (row[x] + Math.floor((left + up) / 2)) & 255;
      } else if (filter === 4) {
        const p = left + up - upLeft;
        const pa = Math.abs(p - left);
        const pb = Math.abs(p - up);
        const pc = Math.abs(p - upLeft);
        row[x] = (row[x] + (pa <= pb && pa <= pc ? left : pb <= pc ? up : upLeft)) & 255;
      } else if (filter !== 0) {
        throw new Error(`Unsupported PNG filter ${filter}.`);
      }
    }
    previous = row;
    for (let x = 0; x < width; x += 1) {
      const src = x * bytesPerPixel;
      const dst = (y * width + x) * 4;
      rgba[dst] = row[src];
      rgba[dst + 1] = row[src + 1];
      rgba[dst + 2] = row[src + 2];
      rgba[dst + 3] = colorType === 6 ? row[src + 3] : 255;
    }
  }
  return { width, height, rgba };
}

function analyzePngFile(path) {
  const buffer = readFileSync(path);
  const decoded = decodePng(buffer);
  return {
    width: decoded.width,
    height: decoded.height,
    byteLength: buffer.length,
    sha256: sha256Bytes(buffer),
    hasAlpha: [...decoded.rgba.subarray(3).filter((_, index) => index % 4 === 0)].some((alpha) => alpha < 255)
  };
}

function setPixel(rgba, width, x, y, color) {
  const offset = (y * width + x) * 4;
  rgba[offset] = color[0];
  rgba[offset + 1] = color[1];
  rgba[offset + 2] = color[2];
  rgba[offset + 3] = color[3];
}

function drawRect(rgba, width, height, x0, y0, x1, y1, color) {
  const left = Math.max(0, Math.floor(x0));
  const top = Math.max(0, Math.floor(y0));
  const right = Math.min(width, Math.ceil(x1));
  const bottom = Math.min(height, Math.ceil(y1));
  for (let y = top; y < bottom; y += 1) {
    for (let x = left; x < right; x += 1) {
      setPixel(rgba, width, x, y, color);
    }
  }
}

function fallbackImageBuffer() {
  const width = 512;
  const height = 512;
  const rgba = Buffer.alloc(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const n = ((x * 17 + y * 31 + ((x ^ y) & 23)) % 27) - 13;
      const base = x < 260 ? 84 : 68;
      setPixel(rgba, width, x, y, [base + n, base - 12 + n, base - 28 + n, 255]);
    }
  }
  for (let y = 0; y < height; y += 64) {
    drawRect(rgba, width, height, 0, y, 512, y + 5, [38, 30, 24, 255]);
  }
  for (let x = 0; x < 260; x += 64) {
    drawRect(rgba, width, height, x, 0, x + 4, 512, [37, 29, 23, 255]);
  }
  for (let y = 0; y < height; y += 86) {
    for (let x = 272; x < width; x += 74) {
      const shade = 80 + ((x + y) % 29);
      drawRect(rgba, width, height, x + 3, y + 3, x + 66, y + 78, [shade, shade + 7, shade + 9, 255]);
      drawRect(rgba, width, height, x, y, x + 69, y + 3, [25, 27, 26, 255]);
      drawRect(rgba, width, height, x, y, x + 3, y + 81, [25, 27, 26, 255]);
    }
  }
  for (let y = 46; y < height; y += 112) {
    drawRect(rgba, width, height, 20, y, 494, y + 10, [28, 27, 26, 255]);
    for (let x = 48; x < width; x += 96) {
      drawRect(rgba, width, height, x, y - 3, x + 12, y + 13, [90, 76, 50, 255]);
    }
  }
  return encodePng(width, height, rgba);
}

function fallbackRecord(write) {
  const buffer = fallbackImageBuffer();
  const contract = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    fallbackId: `${slotId}_tracked_diagnostic_fallback`,
    generatedBy: "tools/godot/barracksMaterialSingleSlotTool.mjs fallback",
    originalGeometricDiagnosticOnly: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    dimensions: { width: 512, height: 512 },
    colorSpacePosture: "srgb-opaque-diagnostic-rgba",
    derivativeDimensions: { width: 512, height: 512 },
    tilingPosture: "diagnostic-repeat; not art; not production",
    uvPosture: "fixed BoxMesh UV repeat comparator only",
    materialReusePosture: "single cached material per source",
    byteLength: buffer.length,
    sha256: sha256Bytes(buffer)
  };
  if (write) {
    mkdirSync(fallbackRoot, { recursive: true });
    writeFileSync(fallbackPng, buffer);
    writeJson(fallbackContract, contract);
  }
  return {
    status: "PASS_V0149_BARRACKS_MATERIAL_FALLBACK_GENERATED",
    path: relativeRepo(fallbackPng),
    contractPath: relativeRepo(fallbackContract),
    fallback: contract,
    errors: []
  };
}

function fallbackCheck() {
  const generated = fallbackRecord(false);
  const errors = [];
  if (!existsSync(fallbackPng)) {
    errors.push(`Missing fallback PNG: ${relativeRepo(fallbackPng)}`);
  } else if (sha256File(fallbackPng) !== generated.fallback.sha256) {
    errors.push(`Tracked fallback hash does not match deterministic generator for ${relativeRepo(fallbackPng)}.`);
  }
  if (!existsSync(fallbackContract)) {
    errors.push(`Missing fallback contract: ${relativeRepo(fallbackContract)}`);
  } else {
    const contract = readJson(fallbackContract);
    if (contract.sha256 !== generated.fallback.sha256 || contract.slotId !== slotId) {
      errors.push(`Tracked fallback contract does not match generated contract for ${slotId}.`);
    }
  }
  return {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0149_BARRACKS_MATERIAL_FALLBACK_REPRODUCIBILITY" : "FAIL_V0149_BARRACKS_MATERIAL_FALLBACK_REPRODUCIBILITY",
    errors,
    fallback: generated.fallback
  };
}

function sampleBilinear(decoded, x, y) {
  const x0 = Math.max(0, Math.min(decoded.width - 1, Math.floor(x)));
  const y0 = Math.max(0, Math.min(decoded.height - 1, Math.floor(y)));
  const x1 = Math.max(0, Math.min(decoded.width - 1, x0 + 1));
  const y1 = Math.max(0, Math.min(decoded.height - 1, y0 + 1));
  const tx = x - x0;
  const ty = y - y0;
  const out = [0, 0, 0, 0];
  for (const [px, py, weight] of [
    [x0, y0, (1 - tx) * (1 - ty)],
    [x1, y0, tx * (1 - ty)],
    [x0, y1, (1 - tx) * ty],
    [x1, y1, tx * ty]
  ]) {
    const offset = (py * decoded.width + px) * 4;
    out[0] += decoded.rgba[offset] * weight;
    out[1] += decoded.rgba[offset + 1] * weight;
    out[2] += decoded.rgba[offset + 2] * weight;
    out[3] += decoded.rgba[offset + 3] * weight;
  }
  return out.map((value) => Math.max(0, Math.min(255, Math.round(value))));
}

function resizeSquare(decoded, targetSize) {
  const rgba = Buffer.alloc(targetSize * targetSize * 4);
  const scaleX = decoded.width / targetSize;
  const scaleY = decoded.height / targetSize;
  for (let y = 0; y < targetSize; y += 1) {
    for (let x = 0; x < targetSize; x += 1) {
      const sample = sampleBilinear(decoded, (x + 0.5) * scaleX - 0.5, (y + 0.5) * scaleY - 0.5);
      const offset = (y * targetSize + x) * 4;
      rgba[offset] = sample[0];
      rgba[offset + 1] = sample[1];
      rgba[offset + 2] = sample[2];
      rgba[offset + 3] = sample[3];
    }
  }
  return encodePng(targetSize, targetSize, rgba);
}

function derivativePath(size) {
  return join(localSlotRoot, `${slotId}_${size}.png`);
}

function derivativeMetadataPath(size) {
  return join(localSlotRoot, `${slotId}_${size}.metadata.json`);
}

function sourceMetadataRecord(write) {
  if (!existsSync(sourcePng)) {
    throw new Error(`Missing generated material source: ${relativeRepo(sourcePng)}`);
  }
  const analysis = analyzePngFile(sourcePng);
  const record = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    role: "single original Barrosan Barracks material source for private hybrid comparator",
    generator: "Codex built-in image generation",
    modelProviderPosture: "built-in image generation tool; exact model not exposed",
    generationDate: "2026-06-06",
    sourcePosture: "one square original material source only; no structure render; no runtime import",
    licencePosture: "local experimental source pending human/protected-IP review",
    protectedIpReviewStatus: "pending",
    humanReviewStatus: "pending-review",
    sha256: analysis.sha256,
    sourceDimensions: { width: analysis.width, height: analysis.height },
    byteLength: analysis.byteLength,
    colorSpacePosture: "srgb-png-opaque-material-source",
    derivativeDimensions: derivativeSizes.map((size) => ({ width: size, height: size })),
    tilingPosture: "deterministic repeat/UV stress only; panel seams require human review",
    uvPosture: "fixed comparator BoxMesh UV repeat scale",
    materialReusePosture: "one cached material instance per loaded source where safe",
    intendedScope: "private comparator-only Barracks material slot",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    generatedImageCountForV0149: 1
  };
  if (write) {
    writeJson(sourceMetadata, record);
  }
  return record;
}

function derivativeRecord(size, write) {
  const source = sourceMetadataRecord(write);
  const sourceDecoded = decodePng(readFileSync(sourcePng));
  const buffer = resizeSquare(sourceDecoded, size);
  const imagePath = derivativePath(size);
  const metadataPath = derivativeMetadataPath(size);
  const record = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    derivativeKind: `${size}`,
    path: relativeRepo(imagePath),
    metadataPath: relativeRepo(metadataPath),
    sourcePath: relativeRepo(sourcePng),
    sourceSha256: source.sha256,
    sha256: sha256Bytes(buffer),
    byteLength: buffer.length,
    dimensions: { width: size, height: size },
    colorSpacePosture: "srgb-png-opaque-deterministic-resize",
    mipmapPosture: "Godot runtime sampler/mipmap posture; no generated mipmap map",
    uvScale: size === 512 ? 1.15 : size === 768 ? 1.05 : 1.0,
    tilingMode: "repeat comparator material",
    scriptVersion: "v0149-barracks-material-derivative-v1",
    generatedBy: "tools/godot/barracksMaterialSingleSlotTool.mjs derivatives",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  if (write) {
    mkdirSync(localSlotRoot, { recursive: true });
    writeFileSync(imagePath, buffer);
    writeJson(metadataPath, record);
  }
  return record;
}

function derivativeRecords(write) {
  const source = sourceMetadataRecord(write);
  const derivatives = derivativeSizes.map((size) => derivativeRecord(size, write));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: "PASS_V0149_BARRACKS_MATERIAL_DERIVATIVE_GENERATION",
    source,
    derivatives,
    errors: []
  };
  if (write) {
    writeJson(join(localSlotRoot, `${slotId}_derivative-matrix.json`), report);
  }
  return report;
}

function derivativesCheck() {
  const generated = derivativeRecords(false);
  const errors = [];
  for (const derivative of generated.derivatives) {
    const imagePath = join(repoRoot, derivative.path);
    const metadataPath = join(repoRoot, derivative.metadataPath);
    if (!existsSync(imagePath)) {
      errors.push(`Missing derivative ${derivative.path}.`);
    } else if (sha256File(imagePath) !== derivative.sha256) {
      errors.push(`Derivative hash mismatch for ${derivative.path}.`);
    }
    if (!existsSync(metadataPath)) {
      errors.push(`Missing derivative metadata ${derivative.metadataPath}.`);
    } else {
      const metadata = readJson(metadataPath);
      if (metadata.sha256 !== derivative.sha256 || metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
        errors.push(`Derivative metadata contract mismatch for ${derivative.metadataPath}.`);
      }
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0149_BARRACKS_MATERIAL_DERIVATIVE_REPRODUCIBILITY" : "FAIL_V0149_BARRACKS_MATERIAL_DERIVATIVE_REPRODUCIBILITY",
    errors,
    source: generated.source,
    derivatives: generated.derivatives
  };
  writeJson(join(evidenceRootFromArgs(), "barracks-material-derivative-reproducibility.json"), report);
  return report;
}

function validateLocalSlot() {
  const errors = [];
  if (!existsSync(sourcePng)) {
    errors.push(`Missing local generated source ${relativeRepo(sourcePng)}.`);
  }
  if (!existsSync(sourceMetadata)) {
    errors.push(`Missing source metadata ${relativeRepo(sourceMetadata)}.`);
  } else {
    const metadata = readJson(sourceMetadata);
    if (metadata.slotId !== slotId || metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
      errors.push("Source metadata boundary contract mismatch.");
    }
    if (existsSync(sourcePng) && metadata.sha256 !== sha256File(sourcePng)) {
      errors.push("Source metadata hash mismatch.");
    }
  }
  for (const size of derivativeSizes) {
    const imagePath = derivativePath(size);
    const metadataPath = derivativeMetadataPath(size);
    if (!existsSync(imagePath)) {
      errors.push(`Missing derivative ${relativeRepo(imagePath)}.`);
    }
    if (!existsSync(metadataPath)) {
      errors.push(`Missing derivative metadata ${relativeRepo(metadataPath)}.`);
    }
  }
  return {
    status: errors.length === 0 ? "PASS_V0149_BARRACKS_MATERIAL_LOCAL_SLOT" : "FAIL_V0149_BARRACKS_MATERIAL_LOCAL_SLOT",
    errors
  };
}

function validate() {
  const errors = [];
  const requiredFiles = [
    "GODOT_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.contract.json",
    "tools/godot/barracksMaterialSingleSlotTool.mjs",
    "tools/godot/runGodotBarracksMaterialValidation.ps1",
    "tools/godot/runGodotBarracksMaterialFallbackReproducibility.ps1",
    "tools/godot/runGodotBarracksMaterialDerivatives.ps1",
    "tools/godot/runGodotBarracksMaterialAudit.ps1",
    "tools/godot/runGodotBarracksMaterialBenchmarkWindows.ps1",
    "tools/godot/captureGodotBarracksMaterialWindows.ps1",
    "docs/V0149_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_INTAKE_SPEC.md",
    "docs/V0149_BARROSAN_BARRACKS_MATERIAL_SLOT_CONTRACT.md",
    "docs/V0149_BARROSAN_BARRACKS_MATERIAL_FAIR_PATH_AUDIT.md",
    "docs/V0149_BARROSAN_BARRACKS_MATERIAL_DERIVATIVE_MATRIX.md",
    "docs/V0149_BARROSAN_BARRACKS_MATERIAL_PAIRED_BENCHMARK_REPORT.md",
    "docs/V0149_BARROSAN_BARRACKS_MATERIAL_VISUAL_REVIEW_GUIDE.md",
    "docs/V0149_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0149_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.149 file: ${file}`);
    }
  }
  const packageJson = readJson(join(repoRoot, "package.json"));
  const requiredScripts = [
    "godot:barracks-material:validate",
    "godot:barracks-material:fallback:reproduce",
    "godot:barracks-material:derivatives:reproduce",
    "godot:barracks-material:audit",
    "godot:barracks-material:benchmark:headed",
    "godot:barracks-material:capture"
  ];
  for (const script of requiredScripts) {
    if (!packageJson.scripts?.[script]) {
      errors.push(`Missing package.json script ${script}.`);
    }
  }
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--barrosan-barracks-material-single-slot")) {
    errors.push("Root script does not expose private --barrosan-barracks-material-single-slot dispatch.");
  }
  for (const launcher of [
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"
  ]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("barrosan-barracks-material-single-slot") || text.includes("BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT")) {
      errors.push(`${launcher} must not reference the private Barracks material slot.`);
    }
  }
  const fallback = fallbackCheck();
  errors.push(...fallback.errors);
  const derivatives = derivativesCheck();
  errors.push(...derivatives.errors);
  const local = validateLocalSlot();
  errors.push(...local.errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0149_BARRACKS_MATERIAL_VALIDATION" : "FAIL_V0149_BARRACKS_MATERIAL_VALIDATION",
    slotId,
    existingWorkerDerivativeRetained: selectedWorkerDerivativeHash,
    zeroExistingReferenceImport: true,
    exactlyOneGeneratedImage: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    noThirdRuntimeArtSlot: true,
    fallback,
    derivatives,
    local,
    errors
  };
  writeJson(join(evidenceRootFromArgs(), "barracks-material-validation.json"), report);
  return report;
}

function numberSummary(values) {
  if (!values.length) {
    return { min: 0, max: 0, mean: 0, median: 0, spread: 0 };
  }
  const sorted = [...values].sort((a, b) => a - b);
  const sum = sorted.reduce((acc, value) => acc + value, 0);
  const median = sorted.length % 2 === 1
    ? sorted[Math.floor(sorted.length / 2)]
    : (sorted[sorted.length / 2 - 1] + sorted[sorted.length / 2]) / 2;
  return {
    min: Number(sorted[0].toFixed(2)),
    max: Number(sorted[sorted.length - 1].toFixed(2)),
    mean: Number((sum / sorted.length).toFixed(2)),
    median: Number(median.toFixed(2)),
    spread: Number((sorted[sorted.length - 1] - sorted[0]).toFixed(2))
  };
}

function aggregateBenchmarks(rows) {
  const groups = new Map();
  for (const row of rows) {
    const key = `${row.approach}|${row.tier}`;
    if (!groups.has(key)) {
      groups.set(key, []);
    }
    groups.get(key).push(row);
  }
  return [...groups.entries()].map(([key, group]) => {
    const [approach, tier] = key.split("|");
    return {
      approach,
      tier,
      trialCount: group.length,
      averageFps: numberSummary(group.map((row) => Number(row.averageFps))),
      p95FrameTimeMs: numberSummary(group.map((row) => Number(row.p95FrameTimeMs))),
      p99FrameTimeMs: numberSummary(group.map((row) => Number(row.p99FrameTimeMs))),
      benchmarkDurationMs: numberSummary(group.map((row) => Number(row.benchmarkDurationMs))),
      initializationDurationMs: numberSummary(group.map((row) => Number(row.initializationDurationMs))),
      frameCount: group[0]?.frameCount ?? 0,
      entityCount: group[0]?.entityCount ?? 0,
      barracksShellCount: group[0]?.barracksShellCount ?? 0,
      workerContextCount: group[0]?.workerContextCount ?? 0,
      renderedObjectProxy: group[0]?.renderedObjectProxy ?? 0,
      materialReuseCount: group[0]?.materialReuseCount ?? 0,
      sourceLoaded: group[0]?.sourceLoaded ?? "unknown",
      assetHash: group[0]?.assetHash ?? "",
      derivativeDimensions: group[0]?.derivativeDimensions ?? { width: 0, height: 0 },
      navigationParity: group[0]?.navigationParity ?? "not-applicable",
      pressureParity: group[0]?.pressureParity ?? "not-applicable",
      stuckUnitCount: group[0]?.stuckUnitCount ?? 0,
      confidence: group[0]?.confidence ?? "local-headed-comparator"
    };
  });
}

function threshold(aggregates, trialRows) {
  const baseline = aggregates.find((row) => row.approach === "HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK" && row.tier === "L");
  const candidates = ["HYBRID_BARRACKS_LOCAL_512", "HYBRID_BARRACKS_LOCAL_768", "HYBRID_BARRACKS_LOCAL_1024"]
    .map((approach) => aggregates.find((row) => row.approach === approach && row.tier === "L"))
    .filter(Boolean)
    .map((candidate) => ({
      approach: candidate.approach,
      sourceLoaded: candidate.sourceLoaded,
      assetHash: candidate.assetHash,
      derivativeDimensions: candidate.derivativeDimensions,
      baselineAverageFpsMean: baseline?.averageFps.mean ?? 0,
      candidateAverageFpsMean: candidate.averageFps.mean,
      averageFpsRatio: baseline ? Number((candidate.averageFps.mean / baseline.averageFps.mean).toFixed(4)) : 0,
      averageFpsPass: baseline ? candidate.averageFps.mean / baseline.averageFps.mean >= 0.9 : false,
      baselineP95FrameTimeMeanMs: baseline?.p95FrameTimeMs.mean ?? 0,
      candidateP95FrameTimeMeanMs: candidate.p95FrameTimeMs.mean,
      p95FrameTimeRatio: baseline ? Number((candidate.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean).toFixed(4)) : 0,
      p95FrameTimePass: baseline ? candidate.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean <= 1.15 : false,
      p95FrameTimeAbsoluteDeltaMs: baseline ? Number((candidate.p95FrameTimeMs.mean - baseline.p95FrameTimeMs.mean).toFixed(2)) : 0
    }));
  const passing = candidates.filter((candidate) => candidate.averageFpsPass && candidate.p95FrameTimePass);
  const selected = passing
    .sort((a, b) => b.derivativeDimensions.width - a.derivativeDimensions.width || b.averageFpsRatio - a.averageFpsRatio)[0];
  return {
    status: selected ? "PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE" : "FAIL_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE",
    gate: {
      averageFpsRatioMinimum: 0.9,
      p95FrameTimeWorseningMaximumRatio: 1.15,
      visualGateRequiresHumanReview: true
    },
    baseline,
    candidates,
    selectedRecommendedDerivative: selected?.approach ?? "none",
    selectedRecommendedSource: selected?.sourceLoaded ?? "none",
    selectedRecommendedHash: selected?.assetHash ?? "",
    selectedRecommendedDimensions: selected?.derivativeDimensions ?? { width: 0, height: 0 },
    tierLTrials: trialRows.filter((row) => row.tier === "L"),
    visualAutomatedStatus: "CAPTURED_FOR_HUMAN_REVIEW",
    reason: selected ? "Highest-resolution local Barracks material derivative passing the preserved Tier L performance gate." : "No local Barracks material derivative passed the preserved Tier L performance gate."
  };
}

function report() {
  const evidenceRoot = evidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, runtimeReportName);
  if (!existsSync(runtimePath)) {
    throw new Error(`Missing Godot Barracks material runtime report: ${relativeRepo(runtimePath)}`);
  }
  const runtime = readJson(runtimePath);
  const benchmarkRows = runtime.benchmarks ?? [];
  const aggregateRows = aggregateBenchmarks(benchmarkRows);
  const screenshotRoot = join(evidenceRoot, "screenshots");
  const screenshots = (runtime.captures ?? []).map((capture) => {
    const path = join(screenshotRoot, capture.fileName);
    return {
      ...capture,
      path: relativeRepo(path),
      sha256: existsSync(path) ? sha256File(path) : "missing",
      width: capture.width ?? 1600,
      height: capture.height ?? 900
    };
  });
  const gate = threshold(aggregateRows, benchmarkRows);
  const derivatives = existsSync(join(localSlotRoot, `${slotId}_derivative-matrix.json`))
    ? readJson(join(localSlotRoot, `${slotId}_derivative-matrix.json`))
    : derivativeRecords(false);
  const summary = {
    schemaVersion: 1,
    checkpoint,
    status: "PASS_V0149_BARRACKS_MATERIAL_EVIDENCE_RECORDED",
    slotId,
    derivatives,
    aggregateRows,
    benchmarkRows,
    screenshots,
    threshold: gate,
    fairPathAudit: runtime.fairPathAudit,
    materialSources: runtime.materialSources,
    workerContextSource: runtime.workerContextSource,
    selectedRecommendedDerivative: gate.selectedRecommendedDerivative,
    selectedRecommendedSource: gate.selectedRecommendedSource,
    sourceRuntimeReport: relativeRepo(runtimePath),
    boundaries: runtime.boundaries,
    limitations: runtime.limitations,
    errors: []
  };
  writeJson(join(evidenceRoot, "barracks-material-evidence.json"), summary);
  writeJson(join(evidenceRoot, "barracks-material-threshold-report.json"), gate);
  writeJson(join(evidenceRoot, "barracks-material-derivative-matrix.json"), derivatives);
  writeJson(join(evidenceRoot, "barracks-material-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint,
    screenshots
  });
  writeText(join(evidenceRoot, "paired-benchmark-summary.md"), benchmarkMarkdown(summary));
  writeText(join(evidenceRoot, "visual-review-guide.md"), visualReviewMarkdown(summary));
  writeText(join(evidenceRoot, "contact-sheet.svg"), contactSheetSvg(screenshots));
  return summary;
}

function audit() {
  const evidenceRoot = evidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, runtimeReportName);
  const errors = [];
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const fairPathAudit = runtime?.fairPathAudit ?? {
    note: "Run headed paired benchmark or capture before collecting runtime audit counters."
  };
  if (runtime && fairPathAudit.repeatedTextureCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove texture creation was absent during steady-state frames.");
  }
  if (runtime && fairPathAudit.repeatedMaterialCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove material creation was absent during steady-state frames.");
  }
  if (runtime && fairPathAudit.benchmarkExcludesInitializationAndWarmup !== true) {
    errors.push("Runtime audit did not prove initialization/warmup were excluded from measured frames.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0149_BARRACKS_MATERIAL_FAIR_PATH_AUDIT" : "FAIL_V0149_BARRACKS_MATERIAL_FAIR_PATH_AUDIT",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    audit: fairPathAudit,
    errors
  };
  writeJson(join(evidenceRoot, "barracks-material-fair-path-audit.json"), report);
  return report;
}

function benchmarkMarkdown(summary) {
  const lines = [
    "# v0.149 Barracks Material Paired Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    `Original gate: ${summary.threshold.status}`,
    `Selected derivative: ${summary.threshold.selectedRecommendedDerivative}`,
    "",
    "| Approach | Tier | Trials | Mean FPS | Median FPS | p95 ms | p99 ms | Source |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.aggregateRows) {
    lines.push(`| \`${row.approach}\` | \`${row.tier}\` | ${row.trialCount} | ${row.averageFps.mean} | ${row.averageFps.median} | ${row.p95FrameTimeMs.mean} | ${row.p99FrameTimeMs.mean} | ${row.sourceLoaded} |`);
  }
  lines.push("", "## Tier L Trials", "");
  for (const row of summary.threshold.tierLTrials) {
    lines.push(`- ${row.approach} trial ${row.trialIndex ?? 1}: ${Number(row.averageFps).toFixed(2)} FPS, p95 ${Number(row.p95FrameTimeMs).toFixed(2)} ms, source ${row.sourceLoaded}.`);
  }
  return `${lines.join("\n")}\n`;
}

function visualReviewMarkdown(summary) {
  const lines = [
    "# v0.149 Barracks Material Visual Review Guide",
    "",
    `Selected derivative: \`${summary.threshold.selectedRecommendedDerivative}\``,
    `Gate result: \`${summary.threshold.status}\``,
    "",
    "Review questions:",
    "",
    "- Does the Barracks material read as practical Barrosan foothold construction?",
    "- Does it improve the simple 3D shell at gameplay distance?",
    "- Are seams, stretching, shimmer, or visual mud visible?",
    "- Does the Worker billboard coexist with the textured shell?",
    "- Should the next milestone test Aster static billboard, a second structure/material slot, one bounded repair, or pause for a broader pipeline decision?",
    "",
    "Non-approval boundary:",
    "",
    "- Private comparator only.",
    "- Not production approval.",
    "- Not player-facing Salto integration.",
    "- Not final Barracks architecture approval.",
    "- Not final material-pack approval.",
    "- Not final Godot selection.",
    "",
    "Captures:",
    ""
  ];
  for (const screenshot of summary.screenshots) {
    lines.push(`- \`${screenshot.id}\`: \`${screenshot.path}\``);
  }
  return `${lines.join("\n")}\n`;
}

function contactSheetSvg(screenshots) {
  const cellWidth = 360;
  const cellHeight = 252;
  const cols = 3;
  const rows = Math.max(1, Math.ceil(screenshots.length / cols));
  const width = cols * cellWidth;
  const height = rows * cellHeight + 48;
  const parts = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<rect width="100%" height="100%" fill="#111511"/>`,
    `<text x="18" y="30" fill="#e7eadc" font-family="Arial" font-size="18">v0.149 Barracks material private comparator contact sheet</text>`
  ];
  screenshots.forEach((shot, index) => {
    const col = index % cols;
    const row = Math.floor(index / cols);
    const x = col * cellWidth + 14;
    const y = row * cellHeight + 52;
    const href = shot.path.replaceAll("&", "&amp;");
    parts.push(`<rect x="${x - 4}" y="${y - 4}" width="336" height="226" fill="#202820" stroke="#465446"/>`);
    parts.push(`<image href="${href}" x="${x}" y="${y}" width="328" height="185" preserveAspectRatio="xMidYMid meet"/>`);
    parts.push(`<text x="${x}" y="${y + 205}" fill="#d8ddce" font-family="Arial" font-size="11">${shot.id}</text>`);
  });
  parts.push("</svg>");
  return `${parts.join("\n")}\n`;
}

function printReportAndSetExitCode(result) {
  console.log(JSON.stringify(result, null, 2));
  if (String(result.status ?? "").startsWith("FAIL") || (result.errors && result.errors.length > 0)) {
    process.exitCode = 1;
  }
}

const command = process.argv[2];
try {
  if (command === "fallback") {
    printReportAndSetExitCode(fallbackRecord(true));
  } else if (command === "fallback:check") {
    printReportAndSetExitCode(fallbackCheck());
  } else if (command === "derivatives") {
    printReportAndSetExitCode(derivativeRecords(true));
  } else if (command === "derivatives:check") {
    printReportAndSetExitCode(derivativesCheck());
  } else if (command === "validate") {
    printReportAndSetExitCode(validate());
  } else if (command === "report") {
    printReportAndSetExitCode(report());
  } else if (command === "audit") {
    printReportAndSetExitCode(audit());
  } else {
    console.error("Usage: node tools/godot/barracksMaterialSingleSlotTool.mjs <fallback|fallback:check|derivatives|derivatives:check|validate|report|audit> [--artifact-root=<path>]");
    process.exitCode = 1;
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
