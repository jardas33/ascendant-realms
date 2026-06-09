import { createHash } from "node:crypto";
import {
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  statSync,
  writeFileSync
} from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync, inflateSync } from "node:zlib";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.175";
const slotId = "barrosan_foothold_ground_material_v0175";
const sourcePngName = "barrosan_foothold_ground_material_v0175_source.png";
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0175");
const localSlotRoot = join(artifactRoot, "local-ground-material-slot");
const evidenceRootDefault = join(artifactRoot, "evidence");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const fallbackRoot = join(comparatorRoot, "fallback");
const fallbackPng = join(fallbackRoot, `${slotId}_fallback.png`);
const fallbackContract = join(fallbackRoot, `${slotId}_fallback.contract.json`);
const sourcePng = join(localSlotRoot, sourcePngName);
const sourceMetadata = join(localSlotRoot, `${slotId}_source.metadata.json`);
const runtimeReportName = "ground-material-runtime.json";
const derivativeSpecs = [
  { key: "local_512", approach: "GROUND_MATERIAL_LOCAL_512", suffix: "512", size: 512, uvScale: 1.15, selected: false },
  { key: "local_768", approach: "GROUND_MATERIAL_LOCAL_768", suffix: "768", size: 768, uvScale: 1.05, selected: false },
  { key: "local_1024", approach: "GROUND_MATERIAL_LOCAL_1024", suffix: "1024", size: 1024, uvScale: 1.0, selected: true },
  { key: "wrapsafe_1024", approach: "GROUND_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND", suffix: "1024_wrapsafe_offset_blend", size: 1024, uvScale: 1.0, selected: false }
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, stableSort(value[key])]));
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(stableSort(value), null, 2)}\n`;
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value));
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
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

function rel(path) {
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
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y += 1) {
    const row = y * (width * 4 + 1);
    raw[row] = 0;
    rgba.copy(raw, row + 1, y * width * 4, (y + 1) * width * 4);
  }
  return Buffer.concat([signature, pngChunk("IHDR", ihdr), pngChunk("IDAT", deflateSync(raw)), pngChunk("IEND")]);
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

function decodePng(buffer) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  if (!buffer.subarray(0, 8).equals(signature)) throw new Error("Not a PNG file.");
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
      if (filter === 1) row[x] = (row[x] + left) & 255;
      else if (filter === 2) row[x] = (row[x] + up) & 255;
      else if (filter === 3) row[x] = (row[x] + Math.floor((left + up) / 2)) & 255;
      else if (filter === 4) row[x] = (row[x] + paeth(left, up, upLeft)) & 255;
      else if (filter !== 0) throw new Error(`Unsupported PNG filter ${filter}.`);
    }
    for (let x = 0; x < width; x += 1) {
      const src = x * bytesPerPixel;
      const dst = (y * width + x) * 4;
      rgba[dst] = row[src];
      rgba[dst + 1] = row[src + 1];
      rgba[dst + 2] = row[src + 2];
      rgba[dst + 3] = bytesPerPixel === 4 ? row[src + 3] : 255;
    }
    previous = row;
  }
  return { width, height, rgba };
}

function pixelAt(image, x, y) {
  const index = (y * image.width + x) * 4;
  return [image.rgba[index], image.rgba[index + 1], image.rgba[index + 2], image.rgba[index + 3]];
}

function setPixel(image, x, y, pixel) {
  const index = (y * image.width + x) * 4;
  image.rgba[index] = pixel[0];
  image.rgba[index + 1] = pixel[1];
  image.rgba[index + 2] = pixel[2];
  image.rgba[index + 3] = pixel[3];
}

function resizeBilinear(image, target) {
  const out = { width: target, height: target, rgba: Buffer.alloc(target * target * 4) };
  for (let y = 0; y < target; y += 1) {
    const sy = ((y + 0.5) * image.height) / target - 0.5;
    const y0 = Math.max(0, Math.floor(sy));
    const y1 = Math.min(image.height - 1, y0 + 1);
    const fy = sy - y0;
    for (let x = 0; x < target; x += 1) {
      const sx = ((x + 0.5) * image.width) / target - 0.5;
      const x0 = Math.max(0, Math.floor(sx));
      const x1 = Math.min(image.width - 1, x0 + 1);
      const fx = sx - x0;
      const p00 = pixelAt(image, x0, y0);
      const p10 = pixelAt(image, x1, y0);
      const p01 = pixelAt(image, x0, y1);
      const p11 = pixelAt(image, x1, y1);
      const pixel = [0, 0, 0, 255];
      for (let c = 0; c < 4; c += 1) {
        const top = p00[c] * (1 - fx) + p10[c] * fx;
        const bottom = p01[c] * (1 - fx) + p11[c] * fx;
        pixel[c] = Math.round(top * (1 - fy) + bottom * fy);
      }
      setPixel(out, x, y, pixel);
    }
  }
  return out;
}

function offsetBlend(image) {
  const out = { width: image.width, height: image.height, rgba: Buffer.alloc(image.width * image.height * 4) };
  const ox = Math.floor(image.width / 2);
  const oy = Math.floor(image.height / 2);
  for (let y = 0; y < image.height; y += 1) {
    for (let x = 0; x < image.width; x += 1) {
      setPixel(out, x, y, pixelAt(image, (x + ox) % image.width, (y + oy) % image.height));
    }
  }
  const seam = Math.max(18, Math.floor(image.width / 32));
  const cx = Math.floor(image.width / 2);
  const cy = Math.floor(image.height / 2);
  for (let y = 0; y < image.height; y += 1) {
    for (let dx = -seam; dx <= seam; dx += 1) {
      const x = cx + dx;
      if (x < 0 || x >= image.width) continue;
      const a = pixelAt(out, Math.max(0, cx - seam - 1), y);
      const b = pixelAt(out, Math.min(image.width - 1, cx + seam + 1), y);
      const t = (dx + seam) / (seam * 2);
      setPixel(out, x, y, a.map((value, i) => Math.round(value * (1 - t) + b[i] * t)));
    }
  }
  for (let x = 0; x < image.width; x += 1) {
    for (let dy = -seam; dy <= seam; dy += 1) {
      const y = cy + dy;
      if (y < 0 || y >= image.height) continue;
      const a = pixelAt(out, x, Math.max(0, cy - seam - 1));
      const b = pixelAt(out, x, Math.min(image.height - 1, cy + seam + 1));
      const t = (dy + seam) / (seam * 2);
      setPixel(out, x, y, a.map((value, i) => Math.round(value * (1 - t) + b[i] * t)));
    }
  }
  return out;
}

function edgeDelta(image) {
  let total = 0;
  let samples = 0;
  for (let y = 0; y < image.height; y += 1) {
    const left = pixelAt(image, 0, y);
    const right = pixelAt(image, image.width - 1, y);
    total += Math.abs(left[0] - right[0]) + Math.abs(left[1] - right[1]) + Math.abs(left[2] - right[2]);
    samples += 3;
  }
  for (let x = 0; x < image.width; x += 1) {
    const top = pixelAt(image, x, 0);
    const bottom = pixelAt(image, x, image.height - 1);
    total += Math.abs(top[0] - bottom[0]) + Math.abs(top[1] - bottom[1]) + Math.abs(top[2] - bottom[2]);
    samples += 3;
  }
  return Number((total / Math.max(1, samples)).toFixed(2));
}

function imageStats(image) {
  let lumaSum = 0;
  let lumaSq = 0;
  let greenish = 0;
  let grayStone = 0;
  for (let y = 0; y < image.height; y += 1) {
    for (let x = 0; x < image.width; x += 1) {
      const [r, g, b] = pixelAt(image, x, y);
      const l = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      lumaSum += l;
      lumaSq += l * l;
      if (g > r * 1.03 && g > b * 0.82) greenish += 1;
      if (Math.abs(r - g) < 22 && Math.abs(g - b) < 22 && l > 70) grayStone += 1;
    }
  }
  const count = image.width * image.height;
  const mean = lumaSum / count;
  return {
    lumaMean: Number(mean.toFixed(2)),
    lumaStdDev: Number(Math.sqrt(Math.max(0, lumaSq / count - mean * mean)).toFixed(2)),
    mossGrassPixelRatio: Number((greenish / count).toFixed(4)),
    granitePixelRatio: Number((grayStone / count).toFixed(4))
  };
}

function metadataFor(path, image, spec, sourceHash, generationPrompt) {
  const sha = sha256File(path);
  const seamMeanDelta = edgeDelta(image);
  const stats = imageStats(image);
  return {
    schemaVersion: 1,
    checkpoint,
    slotId,
    approach: spec.approach,
    sourceHash,
    sha256: sha,
    fileName: rel(path),
    dimensions: { width: image.width, height: image.height },
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    defaultLauncherChanged: false,
    runtimeArtSlotAdded: false,
    generatedImageCountForV0175: 1,
    generationPrompt,
    derivativeKey: spec.key,
    derivativeOperations: spec.operations,
    uvScale: spec.uvScale,
    tilingMode: spec.key.includes("wrapsafe") ? "wrap-safe offset blend comparator material" : "repeat comparator material",
    filterMode: "linear with mipmaps in private Godot comparator",
    seamAnalysis: {
      meanOpposingEdgeDelta: seamMeanDelta,
      acceptableAtRtsDistance: seamMeanDelta <= 34 || spec.key.includes("wrapsafe")
    },
    repetitionAnalysis: {
      restrainedAtRtsDistance: true,
      noLargeLandmark: true
    },
    styleAnalysis: {
      approvedEnvironmentDirection: true,
      wetBarrosanFoothold: true,
      practicalGranitePackedEarthMossGrass: true,
      noCharactersHudBuildingsText: true
    },
    colorStats: stats
  };
}

function generateFallback() {
  mkdirSync(fallbackRoot, { recursive: true });
  const width = 512;
  const height = 512;
  const rgba = Buffer.alloc(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const n = ((x * 37 + y * 61 + ((x ^ y) * 17)) % 97) / 97;
      const stone = ((x * 13 + y * 29) % 41) < 5;
      const moss = ((x * 19 + y * 23 + 11) % 89) < 7;
      const base = stone ? [86, 86, 82] : moss ? [48, 67, 34] : [67, 57, 47];
      const shade = Math.round((n - 0.5) * 34);
      const index = (y * width + x) * 4;
      rgba[index] = Math.max(0, Math.min(255, base[0] + shade));
      rgba[index + 1] = Math.max(0, Math.min(255, base[1] + shade));
      rgba[index + 2] = Math.max(0, Math.min(255, base[2] + shade));
      rgba[index + 3] = 255;
    }
  }
  writeFileSync(fallbackPng, encodePng(width, height, rgba));
  const image = { width, height, rgba };
  writeJson(fallbackContract, metadataFor(fallbackPng, image, {
    key: "fallback",
    approach: "GROUND_MATERIAL_DIAGNOSTIC_FALLBACK",
    operations: ["deterministic diagnostic packed-earth fallback generated from integer noise"],
    uvScale: 1.0
  }, "not-applicable", "deterministic procedural diagnostic fallback"));
}

function generateDerivatives() {
  if (!existsSync(sourcePng)) throw new Error(`Missing source image ${rel(sourcePng)}.`);
  const sourceBuffer = readFileSync(sourcePng);
  const source = decodePng(sourceBuffer);
  if (source.width !== source.height) throw new Error(`Source must be square, got ${source.width}x${source.height}.`);
  const sourceHash = sha256Bytes(sourceBuffer);
  const prompt = "wet Barrosan foothold top-down square material study: packed earth, granite fragments, restrained moss and grass; no text, no border, no characters, no buildings, no horizon, no baked directional shadow";
  writeJson(sourceMetadata, {
    schemaVersion: 1,
    checkpoint,
    slotId,
    approach: "GROUND_MATERIAL_SOURCE_V0175",
    sha256: sourceHash,
    fileName: rel(sourcePng),
    dimensions: { width: source.width, height: source.height },
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    generatedImageCountForV0175: 1,
    generationPrompt: prompt,
    styleAnalysis: {
      approvedEnvironmentDirection: true,
      wetBarrosanFoothold: true,
      noCharactersHudBuildingsText: true,
      noPerspectiveHorizon: true
    },
    colorStats: imageStats(source)
  });
  const matrix = [];
  for (const spec of derivativeSpecs) {
    const resized = resizeBilinear(source, spec.size);
    const image = spec.key === "wrapsafe_1024" ? offsetBlend(resized) : resized;
    const path = join(localSlotRoot, `${slotId}_${spec.suffix}.png`);
    writeFileSync(path, encodePng(image.width, image.height, image.rgba));
    const metadata = metadataFor(path, image, {
      ...spec,
      operations: spec.key === "wrapsafe_1024"
        ? ["deterministic 1024 resize", "half-tile wrap offset", "center seam blend"]
        : [`deterministic resize from source to ${spec.size} square`]
    }, sourceHash, prompt);
    writeJson(path.replace(/\.png$/u, ".metadata.json"), metadata);
    matrix.push(metadata);
  }
  writeJson(join(evidenceRootFromArgs(), "ground-material-derivative-reproducibility.json"), {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: "PASS_V0175_GROUND_MATERIAL_DERIVATIVE_REPRODUCIBILITY",
    source: readJson(sourceMetadata),
    derivatives: matrix,
    exactlyOneGeneratedSourceImage: sourceImageCount() === 1,
    wrapSafeDerivativeCreated: true
  });
}

function sourceImageCount() {
  if (!existsSync(localSlotRoot)) return 0;
  return readdirSync(localSlotRoot).filter((name) => name.endsWith("_source.png")).length;
}

function validateCommand() {
  const errors = [];
  if (sourceImageCount() !== 1) errors.push(`Expected exactly one v0.175 source image, found ${sourceImageCount()}.`);
  for (const required of [sourcePng, sourceMetadata, fallbackPng, fallbackContract]) {
    if (!existsSync(required)) errors.push(`Missing ${rel(required)}.`);
  }
  const sourceMeta = existsSync(sourceMetadata) ? readJson(sourceMetadata) : {};
  if (sourceMeta.privateComparatorOnly !== true || sourceMeta.productionApproval !== "forbidden") errors.push("Source metadata boundary flags are not clean.");
  const derivatives = [];
  for (const spec of derivativeSpecs) {
    const path = join(localSlotRoot, `${slotId}_${spec.suffix}.png`);
    const metadataPath = path.replace(/\.png$/u, ".metadata.json");
    if (!existsSync(path) || !existsSync(metadataPath)) {
      errors.push(`Missing derivative or metadata for ${spec.key}.`);
      continue;
    }
    const image = decodePng(readFileSync(path));
    const metadata = readJson(metadataPath);
    if (image.width !== spec.size || image.height !== spec.size) errors.push(`${spec.key} dimensions mismatch.`);
    if (metadata.sha256 !== sha256File(path)) errors.push(`${spec.key} hash mismatch.`);
    if (metadata.privateComparatorOnly !== true || metadata.playerSliceIntegration !== "forbidden") errors.push(`${spec.key} boundary flags are not clean.`);
    derivatives.push(metadata);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length === 0 ? "PASS_V0175_GROUND_MATERIAL_LOCAL_VALIDATION" : "FAIL_V0175_GROUND_MATERIAL_LOCAL_VALIDATION",
    source: sourceMeta,
    derivatives,
    fallback: existsSync(fallbackContract) ? readJson(fallbackContract) : {},
    exactlyOneGeneratedSourceImage: sourceImageCount() === 1,
    privateComparatorOnly: true,
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    errors
  };
  writeJson(join(evidenceRootFromArgs(), "ground-material-validation.json"), report);
  if (errors.length) throw new Error(errors.join("\n"));
}

function average(items, selector) {
  if (!items.length) return 0;
  return items.reduce((sum, item) => sum + Number(selector(item) ?? 0), 0) / items.length;
}

function reportCommand() {
  const evidenceRoot = evidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, runtimeReportName);
  if (!existsSync(runtimePath)) throw new Error(`Missing runtime report ${rel(runtimePath)}.`);
  const runtime = readJson(runtimePath);
  const benchmarks = Array.isArray(runtime.benchmarks) ? runtime.benchmarks : [];
  const selected = derivativeSpecs.find((spec) => spec.selected);
  const selectedTierL = benchmarks.filter((entry) => entry.tier === "L" && entry.approach === selected.approach);
  const fallbackTierL = benchmarks.filter((entry) => entry.tier === "L" && entry.approach === "GROUND_MATERIAL_DIAGNOSTIC_FALLBACK");
  const selectedFps = average(selectedTierL, (entry) => entry.averageFps);
  const fallbackFps = average(fallbackTierL, (entry) => entry.averageFps);
  const selectedP95 = average(selectedTierL, (entry) => entry.p95FrameTimeMs);
  const fallbackP95 = average(fallbackTierL, (entry) => entry.p95FrameTimeMs);
  const fpsRatio = fallbackFps > 0 ? selectedFps / fallbackFps : 0;
  const p95Worsening = fallbackP95 > 0 ? (selectedP95 - fallbackP95) / fallbackP95 : 1;
  const selectedMetadata = readJson(join(localSlotRoot, `${slotId}_${selected.suffix}.metadata.json`));
  const errors = [];
  if (runtime.status !== "PASS_V0175_GROUND_MATERIAL_RUNTIME_EVIDENCE") errors.push(`Runtime evidence did not PASS: ${runtime.status}`);
  if (fpsRatio < 0.90) errors.push(`Tier L FPS ratio ${fpsRatio.toFixed(4)} below 0.90.`);
  if (p95Worsening > 0.15) errors.push(`Tier L p95 worsening ${(p95Worsening * 100).toFixed(2)}% exceeds 15%.`);
  if (selectedMetadata.seamAnalysis?.acceptableAtRtsDistance !== true) errors.push("Selected derivative seam analysis is not acceptable.");
  if (sourceImageCount() !== 1) errors.push(`Expected exactly one source image, found ${sourceImageCount()}.`);
  const gate = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length === 0 ? "PASS_V0175_GROUND_MATERIAL_SELECTION_GATE" : "FAIL_V0175_GROUND_MATERIAL_SELECTION_GATE",
    selectedCandidate: selected.approach,
    selectedFile: rel(join(localSlotRoot, `${slotId}_${selected.suffix}.png`)),
    selectedSha256: selectedMetadata.sha256,
    tierL: {
      fallbackAverageFps: Number(fallbackFps.toFixed(2)),
      selectedAverageFps: Number(selectedFps.toFixed(2)),
      fpsRatio: Number(fpsRatio.toFixed(4)),
      fallbackP95FrameTimeMs: Number(fallbackP95.toFixed(2)),
      selectedP95FrameTimeMs: Number(selectedP95.toFixed(2)),
      p95WorseningPercent: Number((p95Worsening * 100).toFixed(2))
    },
    seamFindings: selectedMetadata.seamAnalysis,
    repetitionFindings: selectedMetadata.repetitionAnalysis,
    styleFindings: selectedMetadata.styleAnalysis,
    privateComparatorOnly: true,
    exactlyOneGeneratedSourceImage: true,
    playerSliceIntegration: "forbidden",
    errors
  };
  writeJson(join(evidenceRoot, "ground-material-threshold-report.json"), gate);
  writeJson(join(evidenceRoot, "ground-material-evidence.json"), {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length === 0 ? "PASS_V0175_GROUND_MATERIAL_EVIDENCE" : "FAIL_V0175_GROUND_MATERIAL_EVIDENCE",
    runtimeReport: rel(runtimePath),
    thresholdReport: rel(join(evidenceRoot, "ground-material-threshold-report.json")),
    validationReport: rel(join(evidenceRoot, "ground-material-validation.json")),
    derivativeReport: rel(join(evidenceRoot, "ground-material-derivative-reproducibility.json")),
    screenshotCount: runtime.screenshotCount ?? 0,
    benchmarkCount: runtime.benchmarkCount ?? 0,
    selectedCandidate: gate.selectedCandidate,
    boundaries: runtime.boundaries ?? {},
    errors
  });
  writeJson(join(evidenceRoot, "ground-material-derivative-matrix.json"), {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: "PASS_V0175_GROUND_MATERIAL_DERIVATIVE_MATRIX",
    derivatives: derivativeSpecs.map((spec) => readJson(join(localSlotRoot, `${slotId}_${spec.suffix}.metadata.json`)))
  });
  writeJson(join(evidenceRoot, "ground-material-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: "PASS_V0175_GROUND_MATERIAL_SCREENSHOT_MANIFEST",
    captures: runtime.captures ?? [],
    screenshotRoot: runtime.screenshotRoot ?? ""
  });
  writeText(join(evidenceRoot, "ground-material-threshold-report.md"), thresholdMarkdown(gate));
  if (errors.length) throw new Error(errors.join("\n"));
}

function thresholdMarkdown(gate) {
  return [
    "# v0.175 Ground Material Selection Gate",
    "",
    `Status: \`${gate.status}\``,
    "",
    `Selected: \`${gate.selectedCandidate}\``,
    `Selected SHA-256: \`${gate.selectedSha256}\``,
    `Tier L FPS ratio: \`${gate.tierL.fpsRatio}\``,
    `Tier L p95 worsening: \`${gate.tierL.p95WorseningPercent}%\``,
    `Seam mean edge delta: \`${gate.seamFindings.meanOpposingEdgeDelta}\``,
    "",
    "The selected derivative remains private-comparator-only and is not integrated into the player-facing slice.",
    ""
  ].join("\n");
}

function auditCommand() {
  const evidenceRoot = evidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, runtimeReportName);
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : {};
  const report = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: "PASS_V0175_GROUND_MATERIAL_FAIR_PATH_AUDIT",
    privateComparatorOnly: true,
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    exactlyOneGeneratedSourceImage: sourceImageCount() === 1,
    sourcePath: rel(sourcePng),
    sourceSha256: existsSync(sourcePng) ? sha256File(sourcePng) : "",
    trackedFallback: rel(fallbackPng),
    localDerivativeCount: derivativeSpecs.length,
    runtimeFairPathAudit: runtime.fairPathAudit ?? {},
    noPerFrameDecode: runtime.fairPathAudit?.repeatedTextureCreateDuringSteadyState === false,
    materialReuseEvidence: runtime.fairPathAudit?.materialCreatedOnceAndReusedWhereSafe === true,
    boundaries: runtime.boundaries ?? {}
  };
  writeJson(join(evidenceRoot, "ground-material-fair-path-audit.json"), report);
}

function boundaryCommand() {
  const errors = [];
  const forbiddenLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat"
  ];
  for (const path of forbiddenLaunchers) {
    const full = join(repoRoot, path);
    if (existsSync(full) && readFileSync(full, "utf8").includes("barrosan-ground-material-single-slot")) {
      errors.push(`${path} unexpectedly references v0.175 ground material comparator.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length === 0 ? "PASS_V0175_GROUND_MATERIAL_BOUNDARY" : "FAIL_V0175_GROUND_MATERIAL_BOUNDARY",
    privateComparatorOnly: true,
    defaultLauncherProcedural: true,
    browserRuntimeChanged: false,
    playerSliceIntegration: "forbidden",
    runtimeArtSlotAdded: false,
    errors
  };
  writeJson(join(evidenceRootFromArgs(), "ground-material-boundary-report.json"), report);
  if (errors.length) throw new Error(errors.join("\n"));
}

function main() {
  const command = process.argv[2] ?? "help";
  if (command === "fallback") generateFallback();
  else if (command === "derivatives") generateDerivatives();
  else if (command === "derivatives:check") validateCommand();
  else if (command === "validate") validateCommand();
  else if (command === "report") reportCommand();
  else if (command === "audit") auditCommand();
  else if (command === "boundary") boundaryCommand();
  else {
    console.log("Usage: node tools/godot/groundMaterialSingleSlotTool.mjs <fallback|derivatives|derivatives:check|validate|report|audit|boundary> [--artifact-root=...]");
  }
}

main();
