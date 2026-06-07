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
const checkpoint = "v0.156";
const slotId = "ashen_raider_billboard_static_v0156";
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0156");
const localSlotRoot = join(artifactRoot, "local-ashen-raider-slot");
const evidenceRootDefault = join(artifactRoot, "evidence");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const fallbackRoot = join(comparatorRoot, "fallback");
const fallbackPng = join(fallbackRoot, `${slotId}_fallback.png`);
const fallbackContract = join(fallbackRoot, `${slotId}_fallback.contract.json`);
const localSource = join(localSlotRoot, `${slotId}_source.png`);
const localCutout = join(localSlotRoot, `${slotId}_cutout.png`);
const localSourceMetadata = join(localSlotRoot, `${slotId}_source.metadata.json`);
const localCutoutMetadata = join(localSlotRoot, `${slotId}_cutout.metadata.json`);
const runtimeReportName = "ashen-raider-billboard-single-slot-runtime.json";
const selectedAsterHash = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a";
const selectedWorkerHash = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const selectedBarracksHash = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const selectedMilitiaHash = "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb";
const approaches = [
  "HYBRID_ASHEN_RAIDER_DIAGNOSTIC_FALLBACK_BASELINE",
  "HYBRID_ASHEN_RAIDER_LOCAL_STATIC_BILLBOARD",
  "ORTHO_ASHEN_RAIDER_PROCEDURAL_FALLBACK"
];

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
  return relative(repoRoot, path).replaceAll("\\", "/");
}

function evidenceRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : evidenceRootDefault;
}

function crc32(buffers) {
  let c = 0xffffffff;
  for (const buffer of buffers) {
    for (const byte of buffer) {
      c ^= byte;
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
  const stride = width * 4;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y += 1) {
    const row = y * (stride + 1);
    raw[row] = 0;
    rgba.copy(raw, row + 1, y * stride, (y + 1) * stride);
  }
  return Buffer.concat([signature, pngChunk("IHDR", ihdr), pngChunk("IDAT", deflateSync(raw, { level: 9 })), pngChunk("IEND")]);
}

function decodePng(buffer) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  if (!buffer.subarray(0, 8).equals(signature)) {
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
    const type = buffer.subarray(offset + 4, offset + 8).toString("ascii");
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
    throw new Error(`Unsupported PNG format bitDepth=${bitDepth} colorType=${colorType}.`);
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

function blendPixel(rgba, width, height, x, y, color) {
  if (x < 0 || y < 0 || x >= width || y >= height) {
    return;
  }
  const index = (y * width + x) * 4;
  const srcA = color[3] / 255;
  const dstA = rgba[index + 3] / 255;
  const outA = srcA + dstA * (1 - srcA);
  if (outA <= 0) {
    return;
  }
  rgba[index] = Math.round((color[0] * srcA + rgba[index] * dstA * (1 - srcA)) / outA);
  rgba[index + 1] = Math.round((color[1] * srcA + rgba[index + 1] * dstA * (1 - srcA)) / outA);
  rgba[index + 2] = Math.round((color[2] * srcA + rgba[index + 2] * dstA * (1 - srcA)) / outA);
  rgba[index + 3] = Math.round(outA * 255);
}

function drawRect(rgba, width, height, x0, y0, x1, y1, color) {
  for (let y = Math.max(0, Math.floor(y0)); y <= Math.min(height - 1, Math.ceil(y1)); y += 1) {
    for (let x = Math.max(0, Math.floor(x0)); x <= Math.min(width - 1, Math.ceil(x1)); x += 1) {
      blendPixel(rgba, width, height, x, y, color);
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
      const dx = (x - cx) / rx;
      const dy = (y - cy) / ry;
      if (dx * dx + dy * dy <= 1) {
        blendPixel(rgba, width, height, x, y, color);
      }
    }
  }
}

function createFallbackPng() {
  const width = 1024;
  const height = 1536;
  const rgba = Buffer.alloc(width * height * 4);
  const iron = [86, 78, 69, 255];
  const leather = [65, 42, 34, 255];
  const cloth = [122, 35, 23, 255];
  const shadow = [34, 29, 28, 255];
  const blade = [76, 70, 63, 255];
  const ember = [210, 83, 33, 230];
  const ring = [205, 54, 42, 190];
  drawEllipse(rgba, width, height, 512, 1412, 245, 30, ring);
  drawRect(rgba, width, height, 276, 310, 318, 1210, blade);
  drawEllipse(rgba, width, height, 296, 245, 50, 96, blade);
  drawEllipse(rgba, width, height, 502, 255, 118, 76, iron);
  drawEllipse(rgba, width, height, 505, 338, 82, 72, [126, 82, 60, 255]);
  drawRect(rgba, width, height, 390, 405, 610, 790, leather);
  drawRect(rgba, width, height, 425, 455, 585, 890, cloth);
  drawEllipse(rgba, width, height, 668, 642, 145, 238, [78, 48, 42, 255]);
  drawEllipse(rgba, width, height, 668, 642, 112, 202, [110, 52, 39, 255]);
  drawEllipse(rgba, width, height, 668, 642, 56, 74, iron);
  drawRect(rgba, width, height, 486, 452, 528, 772, ember);
  drawRect(rgba, width, height, 406, 840, 480, 1260, shadow);
  drawRect(rgba, width, height, 528, 840, 602, 1260, shadow);
  drawEllipse(rgba, width, height, 440, 1295, 82, 34, leather);
  drawEllipse(rgba, width, height, 565, 1295, 82, 34, leather);
  drawRect(rgba, width, height, 370, 472, 420, 780, [72, 59, 45, 255]);
  drawRect(rgba, width, height, 602, 470, 650, 760, [72, 59, 45, 255]);
  return encodePng(width, height, rgba);
}

function analyzePng(path) {
  const decoded = decodePng(readFileSync(path));
  const { width, height, rgba } = decoded;
  let transparent = 0;
  let partial = 0;
  let opaque = 0;
  let left = width;
  let right = -1;
  let top = height;
  let bottom = -1;
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const a = rgba[(y * width + x) * 4 + 3];
      if (a === 0) {
        transparent += 1;
      } else if (a === 255) {
        opaque += 1;
      } else {
        partial += 1;
      }
      if (a > 8) {
        left = Math.min(left, x);
        right = Math.max(right, x);
        top = Math.min(top, y);
        bottom = Math.max(bottom, y);
      }
    }
  }
  const trimBounds = right >= left
    ? { left, top, right, bottom, width: right - left + 1, height: bottom - top + 1 }
    : { left: 0, top: 0, right: 0, bottom: 0, width: 0, height: 0 };
  return {
    width,
    height,
    transparent,
    partial,
    opaque,
    hasAlpha: transparent > 0 || partial > 0,
    transparentCorners: [
      rgba[3],
      rgba[(width - 1) * 4 + 3],
      rgba[((height - 1) * width) * 4 + 3],
      rgba[((height - 1) * width + (width - 1)) * 4 + 3]
    ].every((value) => value === 0),
    trimBounds,
    pivot: {
      normalizedX: Number(((trimBounds.left + trimBounds.width / 2) / width).toFixed(4)),
      normalizedY: Number(((trimBounds.bottom + 1) / height).toFixed(4)),
      posture: "bottom-center-foot-pivot"
    }
  };
}

function analyzePngFile(path) {
  const buffer = readFileSync(path);
  const decoded = decodePng(buffer);
  const analysis = analyzePng(path);
  let magentaFringePixels = 0;
  for (let index = 0; index < decoded.rgba.length; index += 4) {
    const r = decoded.rgba[index];
    const g = decoded.rgba[index + 1];
    const b = decoded.rgba[index + 2];
    const a = decoded.rgba[index + 3];
    if (a > 0 && r > 180 && g < 90 && b > 180) {
      magentaFringePixels += 1;
    }
  }
  return {
    ...analysis,
    sha256: sha256Bytes(buffer),
    byteLength: buffer.length,
    transparentPixels: analysis.transparent,
    partiallyTransparentPixels: analysis.partial,
    opaquePixels: analysis.opaque,
    transparentCornerCount: analysis.transparentCorners ? 4 : 0,
    magentaFringePixels,
    magentaFringeRatio: Number((magentaFringePixels / Math.max(1, decoded.width * decoded.height)).toFixed(6))
  };
}

function alphaEdgeStats(decoded) {
  let alphaEdgePixels = 0;
  let partialEdgePixels = 0;
  let haloCandidatePixels = 0;
  const { width, height, rgba } = decoded;
  const alphaAt = (x, y) => rgba[(y * width + x) * 4 + 3];
  for (let y = 1; y < height - 1; y += 1) {
    for (let x = 1; x < width - 1; x += 1) {
      const a = alphaAt(x, y);
      if (a === 0) continue;
      const touchesTransparent =
        alphaAt(x - 1, y) === 0 ||
        alphaAt(x + 1, y) === 0 ||
        alphaAt(x, y - 1) === 0 ||
        alphaAt(x, y + 1) === 0;
      if (!touchesTransparent) continue;
      alphaEdgePixels += 1;
      if (a < 255) {
        partialEdgePixels += 1;
      }
      const index = (y * width + x) * 4;
      if (rgba[index] > 180 && rgba[index + 1] < 90 && rgba[index + 2] > 180) {
        haloCandidatePixels += 1;
      }
    }
  }
  return {
    alphaEdgePixels,
    partialEdgePixels,
    haloCandidatePixels,
    haloCandidateRatio: Number((haloCandidatePixels / Math.max(1, alphaEdgePixels)).toFixed(6))
  };
}

function samplePremultipliedBilinear(decoded, x, y) {
  const { width, height, rgba } = decoded;
  const x0 = Math.max(0, Math.min(width - 1, Math.floor(x)));
  const y0 = Math.max(0, Math.min(height - 1, Math.floor(y)));
  const x1 = Math.max(0, Math.min(width - 1, x0 + 1));
  const y1 = Math.max(0, Math.min(height - 1, y0 + 1));
  const tx = Math.max(0, Math.min(1, x - x0));
  const ty = Math.max(0, Math.min(1, y - y0));
  const samples = [
    [x0, y0, (1 - tx) * (1 - ty)],
    [x1, y0, tx * (1 - ty)],
    [x0, y1, (1 - tx) * ty],
    [x1, y1, tx * ty]
  ];
  let alpha = 0;
  let red = 0;
  let green = 0;
  let blue = 0;
  for (const [sx, sy, weight] of samples) {
    const index = (sy * width + sx) * 4;
    const a = rgba[index + 3] / 255;
    alpha += a * weight;
    red += rgba[index] * a * weight;
    green += rgba[index + 1] * a * weight;
    blue += rgba[index + 2] * a * weight;
  }
  if (alpha <= 0.0001) {
    return [0, 0, 0, 0];
  }
  return [
    Math.round(red / alpha),
    Math.round(green / alpha),
    Math.round(blue / alpha),
    Math.round(alpha * 255)
  ];
}

function applyTransparentColorBleed(rgba, width, height, passes = 3) {
  for (let pass = 0; pass < passes; pass += 1) {
    const previous = Buffer.from(rgba);
    for (let y = 0; y < height; y += 1) {
      for (let x = 0; x < width; x += 1) {
        const index = (y * width + x) * 4;
        if (previous[index + 3] !== 0) continue;
        let count = 0;
        let red = 0;
        let green = 0;
        let blue = 0;
        for (let oy = -1; oy <= 1; oy += 1) {
          for (let ox = -1; ox <= 1; ox += 1) {
            if (ox === 0 && oy === 0) continue;
            const nx = x + ox;
            const ny = y + oy;
            if (nx < 0 || ny < 0 || nx >= width || ny >= height) continue;
            const ni = (ny * width + nx) * 4;
            if (previous[ni + 3] === 0) continue;
            red += previous[ni];
            green += previous[ni + 1];
            blue += previous[ni + 2];
            count += 1;
          }
        }
        if (count > 0) {
          rgba[index] = Math.round(red / count);
          rgba[index + 1] = Math.round(green / count);
          rgba[index + 2] = Math.round(blue / count);
          rgba[index + 3] = 0;
        }
      }
    }
  }
}

function createCutoutFromSource() {
  const decoded = decodePng(readFileSync(localSource));
  const { width, height, rgba } = decoded;
  let removedMattePixels = 0;
  let softenedEdgePixels = 0;
  for (let index = 0; index < rgba.length; index += 4) {
    const r = rgba[index];
    const g = rgba[index + 1];
    const b = rgba[index + 2];
    const isHardMagenta = r > 210 && g < 84 && b > 210 && r - g > 120 && b - g > 120;
    const isSoftMagenta = r > 160 && g < 132 && b > 160 && r - g > 78 && b - g > 78;
    if (isHardMagenta || isSoftMagenta) {
      rgba[index + 3] = 0;
      removedMattePixels += 1;
      if (!isHardMagenta) {
        softenedEdgePixels += 1;
      }
    }
  }
  applyTransparentColorBleed(rgba, width, height, 4);
  const buffer = encodePng(width, height, rgba);
  writeFileSync(localCutout, buffer);
  return { removedMattePixels, softenedEdgePixels, dimensions: { width, height } };
}

function localSourceCount() {
  return existsSync(localSlotRoot)
    ? readdirSync(localSlotRoot).filter((entry) => entry.endsWith("_source.png")).length
    : 0;
}

function fallbackRecord(write = true) {
  const png = createFallbackPng();
  const sha256 = sha256Bytes(png);
  const analysis = {
    width: 1024,
    height: 1536,
    trimBounds: { left: 263, top: 162, right: 813, bottom: 1329, width: 551, height: 1168 },
    pivot: { normalizedX: 0.5, normalizedY: 0.8659, posture: "bottom-center-foot-pivot" }
  };
  const contract = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    sourceKind: "tracked-ashen-raider-diagnostic-fallback",
    fallbackType: "procedural-geometric-transparent-png",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    sha256,
    dimensions: { width: analysis.width, height: analysis.height },
    trimBounds: analysis.trimBounds,
    pivot: analysis.pivot,
    alphaPosture: "transparent-procedural-geometric-fallback",
    hasAlpha: true,
    generatedAiImage: false,
    noAnimations: true,
    singleHostilePrivateComparatorRuntimeArtSlotOnly: true,
    noSixthRuntimeArtSlot: true
  };
  if (write) {
    mkdirSync(fallbackRoot, { recursive: true });
    writeFileSync(fallbackPng, png);
    writeJson(fallbackContract, contract);
  }
  return {
    status: "PASS_V0156_ASHEN_RAIDER_BILLBOARD_FALLBACK_REPRODUCED",
    path: relativeRepo(fallbackPng),
    contractPath: relativeRepo(fallbackContract),
    contract
  };
}

function fallbackCheck() {
  const errors = [];
  if (!existsSync(fallbackPng)) {
    errors.push(`Missing fallback PNG ${relativeRepo(fallbackPng)}.`);
  }
  if (!existsSync(fallbackContract)) {
    errors.push(`Missing fallback contract ${relativeRepo(fallbackContract)}.`);
  }
  const expected = fallbackRecord(false).contract;
  if (existsSync(fallbackPng) && sha256File(fallbackPng) !== expected.sha256) {
    errors.push("Tracked Ashen Raider fallback PNG is not reproducible.");
  }
  if (existsSync(fallbackContract)) {
    const contract = readJson(fallbackContract);
    if (contract.sha256 !== expected.sha256 || contract.slotId !== slotId || contract.privateComparatorOnly !== true) {
      errors.push("Tracked Ashen Raider fallback contract boundary/hash mismatch.");
    }
  }
  return {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_FALLBACK_REPRODUCIBILITY" : "PASS_V0156_ASHEN_RAIDER_BILLBOARD_FALLBACK_REPRODUCIBILITY",
    errors,
    expected
  };
}

function metadataRecord() {
  const errors = [];
  const sourceImages = existsSync(localSlotRoot)
    ? readdirSync(localSlotRoot).filter((entry) => entry.endsWith("_source.png"))
    : [];
  if (sourceImages.length !== 1 || sourceImages[0] !== `${slotId}_source.png`) {
    errors.push(`Expected exactly one v0.156 source image named ${slotId}_source.png; found ${sourceImages.length}.`);
  }
  if (!existsSync(localSource)) {
    errors.push(`Missing local Ashen Raider source image ${relativeRepo(localSource)}.`);
  } else {
    createCutoutFromSource();
  }
  if (!existsSync(localCutout)) {
    errors.push(`Missing local Ashen Raider cutout image ${relativeRepo(localCutout)}.`);
  }
  if (errors.length) {
    return { schemaVersion: 1, checkpoint, status: "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_METADATA", errors };
  }
  const sourceAnalysis = analyzePng(localSource);
  const cutoutAnalysis = analyzePng(localCutout);
  const sourceHash = sha256File(localSource);
  const cutoutHash = sha256File(localCutout);
  const sourceMetadata = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    fileRole: "single-authorized-ai-source",
    sourceKind: "local-ashen-raider-static-billboard-source",
    path: relativeRepo(localSource),
    sha256: sourceHash,
    dimensions: { width: sourceAnalysis.width, height: sourceAnalysis.height },
    generatedAiImage: true,
    exactlyOneAiImageForV0156: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    browserIntegration: "forbidden",
    playerSliceIntegration: "forbidden",
    noAnimations: true,
    noTextBorderEnvironmentGroundShadowInsignia: true,
    promptSummary: "One hostile Ashen Raider static billboard, full body, original IP, restrained scorched ember cues, readable weapon silhouette, flat #ff00ff chroma-key background."
  };
  const cutoutMetadata = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    fileRole: "deterministic-alpha-cutout",
    sourceKind: "local-ashen-raider-static-billboard",
    path: relativeRepo(localCutout),
    sourcePath: relativeRepo(localSource),
    sha256: cutoutHash,
    sourceSha256: sourceHash,
    dimensions: { width: cutoutAnalysis.width, height: cutoutAnalysis.height },
    sourceDimensions: { width: sourceAnalysis.width, height: sourceAnalysis.height },
    trimBounds: cutoutAnalysis.trimBounds,
    pivot: cutoutAnalysis.pivot,
    alphaPosture: "flat-chroma-key-removed-transparent-png",
    hasAlpha: cutoutAnalysis.hasAlpha,
    alphaStats: {
      transparentPixels: cutoutAnalysis.transparent,
      partiallyTransparentPixels: cutoutAnalysis.partial,
      opaquePixels: cutoutAnalysis.opaque,
      transparentCorners: cutoutAnalysis.transparentCorners
    },
    generatedAiImage: false,
    derivedFromExactlyOneAiImage: true,
    exactlyOneAiImageForV0156: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    browserIntegration: "forbidden",
    playerSliceIntegration: "forbidden",
    noAnimations: true,
    singleHostilePrivateComparatorRuntimeArtSlotOnly: true,
    noSixthRuntimeArtSlot: true,
    hostileContextOnly: true,
    hierarchyIntent: "hostile pressure unit below Aster hero scale and distinct from Worker utility posture",
    readabilityIntent: "small-group readable hostile raider silhouette with ember/scorched cues, weapon read, red marker contrast, and reviewable alpha edge",
    selectedAsterContextHash: selectedAsterHash,
    selectedWorkerContextHash: selectedWorkerHash,
    selectedBarracksMaterialContextHash: selectedBarracksHash,
    selectedMilitiaContextHash: selectedMilitiaHash
  };
  writeJson(localSourceMetadata, sourceMetadata);
  writeJson(localCutoutMetadata, cutoutMetadata);
  return {
    schemaVersion: 1,
    checkpoint,
    status: cutoutAnalysis.hasAlpha && cutoutAnalysis.transparentCorners
      ? "PASS_V0156_ASHEN_RAIDER_BILLBOARD_METADATA"
      : "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_METADATA",
    source: sourceMetadata,
    cutout: cutoutMetadata,
    errors: cutoutAnalysis.hasAlpha && cutoutAnalysis.transparentCorners ? [] : ["Ashen Raider cutout alpha validation failed."]
  };
}

function selectedContextCheck() {
  const workerPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148", "local-worker-slot", "worker_billboard_static_v0147_trimmed_1024.png");
  const barracksPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0150", "local-barracks-material-seam-repair", "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png");
  const asterPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0152", "local-aster-billboard-repair", "aster_billboard_static_v0151_trimmed_1024.png");
  const militiaPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "local-militia-billboard-repair", "militia_billboard_static_v0154_trimmed_1024.png");
  const errors = [];
  if (!existsSync(asterPath) || sha256File(asterPath) !== selectedAsterHash) {
    errors.push("Missing or hash-mismatched v0.152 selected Aster derivative.");
  }
  if (!existsSync(workerPath) || sha256File(workerPath) !== selectedWorkerHash) {
    errors.push("Missing or hash-mismatched v0.148 selected Worker derivative.");
  }
  if (!existsSync(barracksPath) || sha256File(barracksPath) !== selectedBarracksHash) {
    errors.push("Missing or hash-mismatched v0.150 selected Barracks material repair.");
  }
  if (!existsSync(militiaPath) || sha256File(militiaPath) !== selectedMilitiaHash) {
    errors.push("Missing or hash-mismatched v0.155 selected Militia derivative.");
  }
  return { errors, asterPath, workerPath, barracksPath, militiaPath };
}

function prerequisiteGateCheck() {
  const required = [
    { path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "evidence", "militia-billboard-repair-validation.json"), status: "PASS_V0155_MILITIA_BILLBOARD_REPAIR_VALIDATION" },
    { path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "evidence", "militia-billboard-repair-threshold-report.json"), status: "PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE" },
    { path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "evidence", "militia-billboard-repair-evidence.json"), status: "PASS_V0155_MILITIA_BILLBOARD_REPAIR_EVIDENCE_RECORDED" },
    { path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0155", "evidence", "militia-billboard-repair-fair-path-audit.json"), status: "PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT" }
  ];
  const errors = [];
  for (const gate of required) {
    if (!existsSync(gate.path)) {
      errors.push(`Missing prerequisite gate file ${relativeRepo(gate.path)}.`);
      continue;
    }
    const json = readJson(gate.path);
    if (json.status !== gate.status) {
      errors.push(`Prerequisite gate ${relativeRepo(gate.path)} was ${json.status}, expected ${gate.status}.`);
    }
  }
  return { errors, gates: required.map((gate) => gate.status) };
}

function validateRecord() {
  const errors = [];
  const metadata = metadataRecord();
  const fallback = fallbackCheck();
  const context = selectedContextCheck();
  const prereqs = prerequisiteGateCheck();
  errors.push(...(metadata.errors ?? []), ...fallback.errors, ...context.errors, ...prereqs.errors);
  const requiredFiles = [
    "GODOT_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.png",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.contract.json",
    "tools/godot/ashenRaiderBillboardSingleSlotTool.mjs",
    "tools/godot/runGodotAshenRaiderBillboardValidation.ps1",
    "tools/godot/runGodotAshenRaiderBillboardBenchmarkWindows.ps1",
    "tools/godot/captureGodotAshenRaiderBillboardWindows.ps1",
    "docs/V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
    "docs/V0156_ASHEN_RAIDER_BILLBOARD_SLOT_CONTRACT.md",
    "docs/V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION_REPORT.md",
    "docs/V0156_ASHEN_RAIDER_BILLBOARD_BENCHMARK_REPORT.md",
    "docs/V0156_ASHEN_RAIDER_BILLBOARD_SCORECARD.md",
    "docs/V0156_ASHEN_RAIDER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
    "docs/V0156_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0156_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.156 file: ${file}`);
    }
  }
  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const script of [
    "godot:ashen-raider-billboard:metadata",
    "godot:ashen-raider-billboard:fallback:reproduce",
    "godot:ashen-raider-billboard:validate",
    "godot:ashen-raider-billboard:audit",
    "godot:ashen-raider-billboard:benchmark:headed",
    "godot:ashen-raider-billboard:capture"
  ]) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script ${script}.`);
    }
  }
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--ashen-raider-billboard-single-slot") || !rootScript.includes("PASS_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD_DISPATCH")) {
    errors.push("Root script does not expose the private v0.156 Ashen Raider billboard dispatch.");
  }
  for (const launcher of ["GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("ashen-raider-billboard-single-slot") || text.includes("ASHEN_RAIDER_BILLBOARD")) {
      errors.push(`${launcher} references the private v0.156 Ashen Raider billboard path.`);
    }
  }
  const runtimeLeakTargets = [
    "src",
    "public",
    "index.html",
    "desktop-spikes/godot-salto/scenes",
    "desktop-spikes/godot-salto/project.godot"
  ];
  let markerLeak = false;
  for (const target of runtimeLeakTargets) {
    const absolute = join(repoRoot, target);
    if (!existsSync(absolute)) continue;
    const entries = statSync(absolute).isDirectory()
      ? readdirSync(absolute, { recursive: true }).map((entry) => join(absolute, entry))
      : [absolute];
    for (const entry of entries) {
      if (!statSync(entry).isFile()) continue;
      const rel = relativeRepo(entry);
      if (rel === "src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts") continue;
      const text = readFileSync(entry, "utf8");
      if (text.includes("ashen-raider-billboard-single-slot") || text.includes("PASS_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD")) {
        markerLeak = true;
      }
    }
  }
  if (markerLeak) {
    errors.push("Private v0.156 Ashen Raider marker leaked into normal runtime/player-slice targets.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length ? "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION" : "PASS_V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION",
    errors,
    prerequisiteGates: prereqs.gates,
    metadata,
    fallback,
    selectedAsterHash,
    selectedWorkerHash,
    selectedBarracksHash,
    selectedMilitiaHash,
    exactlyOneAiImageForV0156: true,
    noAnimations: true,
    singleHostilePrivateComparatorRuntimeArtSlotOnly: true,
    noSixthRuntimeArtSlot: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  writeJson(join(evidenceRootFromArgs(), "ashen-raider-billboard-single-slot-validation.json"), report);
  return report;
}

function aggregateBenchmarks(rows) {
  const aggregates = [];
  for (const approach of approaches) {
    for (const tier of ["S", "M", "L"]) {
      const group = rows.filter((row) => row.approach === approach && row.tier === tier);
      if (!group.length) continue;
      const values = (key) => group.map((row) => Number(row[key])).sort((a, b) => a - b);
      const summary = (key) => {
        const list = values(key);
        const sum = list.reduce((total, value) => total + value, 0);
        return {
          min: Number(list[0].toFixed(2)),
          max: Number(list.at(-1).toFixed(2)),
          mean: Number((sum / list.length).toFixed(2)),
          median: Number(list[Math.floor((list.length - 1) / 2)].toFixed(2)),
          spread: Number((list.at(-1) - list[0]).toFixed(2))
        };
      };
      aggregates.push({
        approach,
        tier,
        trialCount: group.length,
        averageFps: summary("averageFps"),
        p95FrameTimeMs: summary("p95FrameTimeMs"),
        p99FrameTimeMs: summary("p99FrameTimeMs"),
        benchmarkDurationMs: summary("benchmarkDurationMs"),
        initializationDurationMs: summary("initializationDurationMs"),
        ashenRaiderCount: group[0].ashenRaiderCount,
        militiaContextCount: group[0].militiaContextCount,
        asterContextCount: group[0].asterContextCount,
        workerContextCount: group[0].workerContextCount,
        barracksShellCount: group[0].barracksShellCount,
        billboardInstanceCount: group[0].billboardInstanceCount,
        renderedObjectProxy: group[0].renderedObjectProxy,
        assetHash: group[0].assetHash,
        sourceLoaded: group[0].sourceLoaded,
        confidence: "local-headed-private-comparator",
        ashenRaiderBelowAsterHierarchy: group.every((row) => row.ashenRaiderBelowAsterHierarchy === true),
        ashenRaiderDistinctFromWorker: group.every((row) => row.ashenRaiderDistinctFromWorker === true),
        ashenRaiderDistinctFromMilitia: group.every((row) => row.ashenRaiderDistinctFromMilitia === true),
        hostileFriendlyDistinction: group.every((row) => row.hostileFriendlyDistinction === true),
        groupsReadable: group.every((row) => row.groupsReadable === true),
        ringsReadable: group.every((row) => row.ringsReadable === true),
        noObviousHalo: group.every((row) => row.noObviousHalo === true),
        noSevereSeamOrShimmer: group.every((row) => row.noSevereSeamOrShimmer === true),
        pivotStable: group.every((row) => row.footPivotStable === true),
        staticFormationReadable: group.every((row) => row.staticFormationReadable === true),
        depthSortingStable: group.every((row) => row.depthSortingStable === true),
        alphaTreatmentReviewable: group.every((row) => row.alphaTreatmentReviewable === true)
      });
    }
  }
  return aggregates;
}

function thresholdReport(runtime) {
  const rows = runtime.benchmarks ?? [];
  const aggregates = aggregateBenchmarks(rows);
  const baseline = aggregates.find((row) => row.approach === "HYBRID_ASHEN_RAIDER_DIAGNOSTIC_FALLBACK_BASELINE" && row.tier === "L");
  const local = aggregates.find((row) => row.approach === "HYBRID_ASHEN_RAIDER_LOCAL_STATIC_BILLBOARD" && row.tier === "L");
  const ortho = aggregates.find((row) => row.approach === "ORTHO_ASHEN_RAIDER_PROCEDURAL_FALLBACK" && row.tier === "L");
  const localTrials = rows.filter((row) => row.approach === "HYBRID_ASHEN_RAIDER_LOCAL_STATIC_BILLBOARD" && row.tier === "L");
  const averageFpsRatio = baseline && local && baseline.averageFps.mean > 0
    ? Number((local.averageFps.mean / baseline.averageFps.mean).toFixed(4))
    : 0;
  const p95FrameTimeRatio = baseline && local && baseline.p95FrameTimeMs.mean > 0
    ? Number((local.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean).toFixed(4))
    : 999;
  const visualPass = localTrials.length >= 5 && localTrials.every((row) =>
    row.ashenRaiderReadsHostile === true &&
    row.ashenRaiderBelowAsterHierarchy === true &&
    row.ashenRaiderDistinctFromWorker === true &&
    row.ashenRaiderDistinctFromMilitia === true &&
    row.hostileFriendlyDistinction === true &&
    row.groupsReadable === true &&
    row.ringsReadable === true &&
    row.alphaTreatmentReviewable === true &&
    row.footPivotStable === true &&
    row.noObviousHalo === true &&
    row.depthSortingStable === true &&
    row.staticFormationReadable === true
  );
  const pass = Boolean(baseline && local && averageFpsRatio >= 0.9 && p95FrameTimeRatio <= 1.15 && visualPass);
  return {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: pass ? "PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE" : "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE",
    gate: {
      averageFpsRatioMinimum: 0.9,
      p95FrameTimeWorseningMaximumRatio: 1.15,
      hostileReadRequired: true,
      ashenRaiderBelowAsterHierarchyRequired: true,
      workerDistinctRequired: true,
      militiaFriendlyHostileDistinctRequired: true,
      groupsReadableRequired: true,
      ringsReadableRequired: true,
      alphaAndPivotReviewableRequired: true,
      noPlayerFacingMutationRequired: true,
      visualGateRequiresHumanReview: true
    },
    averageFpsRatio,
    p95FrameTimeRatio,
    averageFpsPass: averageFpsRatio >= 0.9,
    p95FrameTimePass: p95FrameTimeRatio <= 1.15,
    visualPass,
    baseline,
    selected: local,
    ortho,
    selectedTierLTrials: localTrials,
    reason: pass
      ? "Local Ashen Raider static billboard passed the private Tier L performance and automated readability gate versus diagnostic fallback."
      : "Local Ashen Raider static billboard did not satisfy the private gate; stop for human review."
  };
}

function evidenceRecord() {
  const root = evidenceRootFromArgs();
  const runtimePath = join(root, runtimeReportName);
  const errors = [];
  if (!existsSync(runtimePath)) {
    errors.push(`Missing runtime report ${relativeRepo(runtimePath)}.`);
  }
  const runtime = errors.length ? null : readJson(runtimePath);
  const threshold = runtime ? thresholdReport(runtime) : null;
  if (runtime && runtime.status !== "PASS_V0156_ASHEN_RAIDER_BILLBOARD_RUNTIME_EVIDENCE") {
    errors.push(`Runtime report status was ${runtime.status}.`);
  }
  if (threshold && threshold.status !== "PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE") {
    errors.push(`Threshold gate status was ${threshold.status}.`);
  }
  const screenshots = runtime?.captures ?? [];
  const report = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length ? "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED" : "PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED",
    errors,
    artifactRoot: relativeRepo(root),
    sourceRuntimeReport: relativeRepo(runtimePath),
    benchmarkRows: runtime?.benchmarks ?? [],
    aggregateRows: runtime ? aggregateBenchmarks(runtime.benchmarks ?? []) : [],
    screenshotCount: screenshots.length,
    benchmarkCount: runtime?.benchmarks?.length ?? 0,
    screenshots,
    threshold,
    localSource: runtime?.localSource,
    fallbackSource: runtime?.fallbackSource,
    selectedAsterHash,
    selectedWorkerHash,
    selectedBarracksHash,
    selectedMilitiaHash,
    fairPathAudit: runtime?.fairPathAudit,
    readabilityAudit: runtime?.readabilityAudit,
    boundaries: runtime?.boundaries,
    exactlyOneAiImageForV0156: true,
    noAnimations: true,
    singleHostilePrivateComparatorRuntimeArtSlotOnly: true,
    noSixthRuntimeArtSlot: true
  };
  writeJson(join(root, "ashen-raider-billboard-single-slot-threshold-report.json"), threshold ?? {});
  writeJson(join(root, "ashen-raider-billboard-single-slot-evidence.json"), report);
  writeJson(join(root, "ashen-raider-billboard-single-slot-scorecard.json"), {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: threshold?.status ?? "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE",
    aggregateRows: report.aggregateRows,
    threshold
  });
  writeJson(join(root, "ashen-raider-billboard-single-slot-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: report.status,
    screenshots
  });
  writeText(join(root, "paired-benchmark-summary.md"), benchmarkSummaryMarkdown(report));
  writeText(join(root, "visual-review-guide.md"), visualReviewMarkdown(report));
  writeText(join(root, "contact-sheet.svg"), contactSheetSvg(screenshots));
  return report;
}

function auditRecord() {
  const root = evidenceRootFromArgs();
  const runtimePath = join(root, runtimeReportName);
  const errors = [];
  if (!existsSync(runtimePath)) {
    errors.push(`Missing runtime report ${relativeRepo(runtimePath)}.`);
  }
  const runtime = errors.length ? null : readJson(runtimePath);
  const audit = runtime?.fairPathAudit ?? {};
  if (runtime && audit.localAndFallbackShareAshenRaiderBillboardRenderPath !== true) {
    errors.push("Runtime audit did not prove local/fallback Ashen Raider render-path sharing.");
  }
  if (runtime && audit.textureLoadedOnceAndReused !== true) {
    errors.push("Runtime audit did not prove texture load reuse.");
  }
  if (runtime && audit.materialCreatedOnceAndReusedWhereSafe !== true) {
    errors.push("Runtime audit did not prove material reuse.");
  }
  if (runtime && audit.metadataParsingDuringSteadyState !== false) {
    errors.push("Runtime audit found metadata parsing during steady state.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    slotId,
    status: errors.length ? "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT" : "PASS_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT",
    errors,
    audit,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    exactlyOneAiImageForV0156: true,
    noAnimations: true,
    singleHostilePrivateComparatorRuntimeArtSlotOnly: true,
    noSixthRuntimeArtSlot: true
  };
  writeJson(join(root, "ashen-raider-billboard-single-slot-fair-path-audit.json"), report);
  return report;
}

function v0156AshenRaiderGateCheck() {
  const required = [
    { path: join(evidenceRootDefault, "ashen-raider-billboard-single-slot-validation.json"), status: "PASS_V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION" },
    { path: join(evidenceRootDefault, "ashen-raider-billboard-single-slot-threshold-report.json"), status: "PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE" },
    { path: join(evidenceRootDefault, "ashen-raider-billboard-single-slot-evidence.json"), status: "PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED" },
    { path: join(evidenceRootDefault, "ashen-raider-billboard-single-slot-fair-path-audit.json"), status: "PASS_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT" }
  ];
  const errors = [];
  for (const gate of required) {
    if (!existsSync(gate.path)) {
      errors.push(`Missing v0.156 Ashen Raider gate file ${relativeRepo(gate.path)}.`);
      continue;
    }
    const json = readJson(gate.path);
    if (json.status !== gate.status) {
      errors.push(`v0.156 Ashen Raider gate ${relativeRepo(gate.path)} was ${json.status}, expected ${gate.status}.`);
    }
  }
  return { errors, gates: required.map((gate) => gate.status) };
}

function numberSummary(values) {
  const sorted = values.map(Number).filter((value) => Number.isFinite(value)).sort((a, b) => a - b);
  if (!sorted.length) {
    return { min: 0, max: 0, mean: 0, median: 0, spread: 0 };
  }
  const sum = sorted.reduce((total, value) => total + value, 0);
  const mid = Math.floor((sorted.length - 1) / 2);
  return {
    min: Number(sorted[0].toFixed(2)),
    max: Number(sorted.at(-1).toFixed(2)),
    mean: Number((sum / sorted.length).toFixed(2)),
    median: Number(sorted[mid].toFixed(2)),
    spread: Number((sorted.at(-1) - sorted[0]).toFixed(2))
  };
}

function benchmarkSummaryMarkdown(report) {
  const rows = report.aggregateRows ?? [];
  return [
    "# v0.156 Ashen Raider Billboard Single-Slot Benchmark Summary",
    "",
    `Gate: ${report.threshold?.status ?? "missing"}`,
    `Evidence: ${report.status}`,
    "",
    "| Approach | Tier | Trials | Mean FPS | p95 ms | p99 ms | Ashen Raider | Militia ctx | Aster | Worker | Barracks |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...rows.map((row) => `| ${row.approach} | ${row.tier} | ${row.trialCount} | ${row.averageFps.mean} | ${row.p95FrameTimeMs.mean} | ${row.p99FrameTimeMs.mean} | ${row.ashenRaiderCount} | ${row.militiaContextCount} | ${row.asterContextCount} | ${row.workerContextCount} | ${row.barracksShellCount} |`),
    ""
  ].join("\n");
}

function visualReviewMarkdown(report) {
  return [
    "# v0.156 Ashen Raider Billboard Visual Review Guide",
    "",
    `Gate result: \`${report.threshold?.status ?? "missing"}\`.`,
    `Evidence root: \`${report.artifactRoot}\`.`,
    "",
    "Review questions:",
    "",
    "- Does Ashen Raider read as a hostile pressure unit rather than a friendly defender?",
    "- Is the weapon silhouette readable in one-unit, four-unit, and repeated-group views?",
    "- Is the red hostile marker distinct from selected Militia friendly/context markers?",
    "- Are markers visible and pivot stable at RTS zoom?",
    "- Are alpha edges reviewable without obvious halo?",
    "- Does the static formation remain visually distinct from Worker, Aster, Barracks, and selected Militia context?",
    "",
    "No final runtime-art approval is implied."
  ].join("\n");
}

function contactSheetSvg(screenshots) {
  const cellW = 320;
  const cellH = 210;
  const cols = 3;
  const rows = Math.max(1, Math.ceil(screenshots.length / cols));
  const body = screenshots.map((shot, index) => {
    const x = (index % cols) * cellW;
    const y = Math.floor(index / cols) * cellH + 44;
    const href = `screenshots/${shot.fileName}`;
    return `<g transform="translate(${x},${y})"><rect x="8" y="8" width="304" height="172" fill="#141a16" stroke="#56685d"/><image href="${href}" x="12" y="12" width="296" height="150" preserveAspectRatio="xMidYMid meet"/><text x="14" y="190" fill="#e7eadc" font-family="Arial" font-size="12">${shot.id}</text></g>`;
  }).join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${cols * cellW}" height="${rows * cellH + 58}" viewBox="0 0 ${cols * cellW} ${rows * cellH + 58}">
<rect width="100%" height="100%" fill="#0b0f0c"/>
<text x="18" y="30" fill="#e7eadc" font-family="Arial" font-size="18">v0.156 Ashen Raider static billboard private contact sheet</text>
${body}
</svg>
`;
}

function printReportAndSetExitCode(report) {
  console.log(JSON.stringify(report, null, 2));
  if (String(report.status ?? "").startsWith("FAIL")) {
    process.exitCode = 1;
  }
}

const command = process.argv[2] ?? "validate";
if (command === "metadata") {
  printReportAndSetExitCode(metadataRecord());
} else if (command === "fallback") {
  printReportAndSetExitCode(fallbackRecord(true));
} else if (command === "fallback:check") {
  printReportAndSetExitCode(fallbackCheck());
} else if (command === "validate") {
  printReportAndSetExitCode(validateRecord());
} else if (command === "report") {
  printReportAndSetExitCode(evidenceRecord());
} else if (command === "audit") {
  printReportAndSetExitCode(auditRecord());
} else {
  printReportAndSetExitCode({
    schemaVersion: 1,
    checkpoint,
    status: "FAIL_V0156_ASHEN_RAIDER_BILLBOARD_UNKNOWN_COMMAND",
    command,
    knownCommands: [
      "metadata",
      "fallback",
      "fallback:check",
      "validate",
      "report",
      "audit"
    ]
  });
}



