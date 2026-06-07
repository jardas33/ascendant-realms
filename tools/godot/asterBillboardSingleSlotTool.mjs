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
const checkpoint = "v0.151";
const slotId = "aster_billboard_static_v0151";
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0151");
const localSlotRoot = join(artifactRoot, "local-aster-slot");
const evidenceRootDefault = join(artifactRoot, "evidence");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const fallbackRoot = join(comparatorRoot, "fallback");
const fallbackPng = join(fallbackRoot, `${slotId}_fallback.png`);
const fallbackContract = join(fallbackRoot, `${slotId}_fallback.contract.json`);
const localSource = join(localSlotRoot, `${slotId}_source.png`);
const localCutout = join(localSlotRoot, `${slotId}.png`);
const localMetadata = join(localSlotRoot, `${slotId}.metadata.json`);
const runtimeReportName = "aster-billboard-single-slot-runtime.json";
const repairCheckpoint = "v0.152";
const repairArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0152");
const repairLocalSlotRoot = join(repairArtifactRoot, "local-aster-billboard-repair");
const repairEvidenceRootDefault = join(repairArtifactRoot, "evidence");
const repairRuntimeReportName = "aster-billboard-repair-runtime.json";
const compositionCheckpoint = "v0.153";
const compositionArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0153");
const compositionEvidenceRootDefault = join(compositionArtifactRoot, "evidence");
const compositionRuntimeReportName = "hybrid-three-slot-composition-runtime.json";
const selectedWorkerHash = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc";
const selectedBarracksHash = "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f";
const selectedAsterRepairHash = "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a";
const approaches = [
  "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE",
  "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD",
  "HYBRID_WORKER_CONTEXT_BASELINE",
  "HYBRID_BARRACKS_CONTEXT_BASELINE",
  "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
];
const tiers = ["S", "M", "L"];
const repairApproaches = [
  "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE",
  "HYBRID_ASTER_FULL_RES",
  "HYBRID_ASTER_TRIMMED_512",
  "HYBRID_ASTER_TRIMMED_768",
  "HYBRID_ASTER_TRIMMED_1024"
];
const compositionApproaches = [
  "HYBRID_THREE_SLOT_FALLBACK_ONLY",
  "HYBRID_THREE_SLOT_SELECTED_LOCAL",
  "ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK"
];
const repairDerivativeSizes = [512, 768, 1024];

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

function repairEvidenceRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : repairEvidenceRootDefault;
}

function compositionEvidenceRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : compositionEvidenceRootDefault;
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
      const nx = (x - cx) / rx;
      const ny = (y - cy) / ry;
      if (nx * nx + ny * ny <= 1) {
        blendPixel(rgba, width, height, x, y, color);
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
      if ((x - px) * (x - px) + (y - py) * (y - py) <= thickness * thickness) {
        blendPixel(rgba, width, height, x, y, color);
      }
    }
  }
}

function fallbackImageBuffer() {
  const width = 1024;
  const height = 1536;
  const rgba = Buffer.alloc(width * height * 4);
  const cloak = [70, 60, 58, 255];
  const cloakShadow = [46, 41, 42, 255];
  const tunic = [96, 93, 76, 255];
  const leather = [91, 65, 43, 255];
  const skin = [151, 103, 75, 255];
  const dark = [39, 34, 30, 255];
  const steel = [137, 132, 111, 255];
  const lume = [114, 172, 145, 210];
  drawEllipse(rgba, width, height, 518, 1452, 200, 20, [0, 0, 0, 55]);
  drawRect(rgba, width, height, 390, 500, 626, 930, tunic);
  drawRect(rgba, width, height, 362, 430, 650, 620, cloak);
  drawRect(rgba, width, height, 625, 540, 725, 1260, cloakShadow);
  drawRect(rgba, width, height, 330, 565, 410, 1195, cloak);
  drawRect(rgba, width, height, 430, 920, 500, 1340, dark);
  drawRect(rgba, width, height, 548, 920, 620, 1340, dark);
  drawRect(rgba, width, height, 400, 1320, 500, 1388, leather);
  drawRect(rgba, width, height, 542, 1320, 642, 1388, leather);
  drawEllipse(rgba, width, height, 516, 330, 92, 112, skin);
  drawRect(rgba, width, height, 350, 620, 428, 860, [118, 106, 84, 255]);
  drawRect(rgba, width, height, 630, 620, 706, 860, [118, 106, 84, 255]);
  drawRect(rgba, width, height, 446, 780, 628, 842, leather);
  drawLine(rgba, width, height, 400, 520, 625, 860, 18, leather);
  drawEllipse(rgba, width, height, 618, 522, 28, 28, steel);
  drawEllipse(rgba, width, height, 612, 840, 26, 36, lume);
  drawRect(rgba, width, height, 438, 1380, 505, 1430, leather);
  drawRect(rgba, width, height, 552, 1380, 620, 1430, leather);
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
  let greenFringePixels = 0;
  for (let y = 0; y < decoded.height; y += 1) {
    for (let x = 0; x < decoded.width; x += 1) {
      const index = (y * decoded.width + x) * 4;
      const alpha = decoded.rgba[index + 3];
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
      if (alpha > 0 && alpha < 245 && decoded.rgba[index + 1] > decoded.rgba[index] + 48 && decoded.rgba[index + 1] > decoded.rgba[index + 2] + 48) {
        greenFringePixels += 1;
      }
    }
  }
  const trimBounds = right >= left
    ? { left, top, right, bottom, width: right - left + 1, height: bottom - top + 1 }
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
      decoded.rgba[(decoded.height - 1) * decoded.width * 4 + 3],
      decoded.rgba[((decoded.height - 1) * decoded.width + decoded.width - 1) * 4 + 3]
    ].filter((alpha) => alpha === 0).length,
    greenFringePixels,
    greenFringeRatio: partiallyTransparentPixels > 0 ? Number((greenFringePixels / partiallyTransparentPixels).toFixed(4)) : 0,
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

function samplePremultipliedBilinear(decoded, x, y) {
  const clampedX = Math.max(0, Math.min(decoded.width - 1, x));
  const clampedY = Math.max(0, Math.min(decoded.height - 1, y));
  const x0 = Math.floor(clampedX);
  const y0 = Math.floor(clampedY);
  const x1 = Math.min(decoded.width - 1, x0 + 1);
  const y1 = Math.min(decoded.height - 1, y0 + 1);
  const fx = clampedX - x0;
  const fy = clampedY - y0;
  const samples = [
    { x: x0, y: y0, weight: (1 - fx) * (1 - fy) },
    { x: x1, y: y0, weight: fx * (1 - fy) },
    { x: x0, y: y1, weight: (1 - fx) * fy },
    { x: x1, y: y1, weight: fx * fy }
  ];
  let alpha = 0;
  let red = 0;
  let green = 0;
  let blue = 0;
  for (const sample of samples) {
    const index = (sample.y * decoded.width + sample.x) * 4;
    const sampleAlpha = decoded.rgba[index + 3] / 255;
    const weightedAlpha = sampleAlpha * sample.weight;
    alpha += weightedAlpha;
    red += decoded.rgba[index] * weightedAlpha;
    green += decoded.rgba[index + 1] * weightedAlpha;
    blue += decoded.rgba[index + 2] * weightedAlpha;
  }
  if (alpha <= 0.0001) {
    return [0, 0, 0, 0];
  }
  return [
    Math.max(0, Math.min(255, Math.round(red / alpha))),
    Math.max(0, Math.min(255, Math.round(green / alpha))),
    Math.max(0, Math.min(255, Math.round(blue / alpha))),
    Math.max(0, Math.min(255, Math.round(alpha * 255)))
  ];
}

function applyTransparentColorBleed(rgba, width, height, iterations = 3) {
  for (let iteration = 0; iteration < iterations; iteration += 1) {
    const copy = Buffer.from(rgba);
    for (let y = 0; y < height; y += 1) {
      for (let x = 0; x < width; x += 1) {
        const index = (y * width + x) * 4;
        if (copy[index + 3] !== 0) {
          continue;
        }
        let count = 0;
        let red = 0;
        let green = 0;
        let blue = 0;
        for (let dy = -1; dy <= 1; dy += 1) {
          for (let dx = -1; dx <= 1; dx += 1) {
            if (dx === 0 && dy === 0) {
              continue;
            }
            const nx = x + dx;
            const ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= width || ny >= height) {
              continue;
            }
            const neighbor = (ny * width + nx) * 4;
            if (copy[neighbor + 3] > 0) {
              count += 1;
              red += copy[neighbor];
              green += copy[neighbor + 1];
              blue += copy[neighbor + 2];
            }
          }
        }
        if (count > 0) {
          rgba[index] = Math.round(red / count);
          rgba[index + 1] = Math.round(green / count);
          rgba[index + 2] = Math.round(blue / count);
        }
      }
    }
  }
}

function alphaEdgeStats(decoded) {
  let partialEdgePixels = 0;
  let greenFringePixels = 0;
  for (let y = 0; y < decoded.height; y += 1) {
    for (let x = 0; x < decoded.width; x += 1) {
      const index = (y * decoded.width + x) * 4;
      const alpha = decoded.rgba[index + 3];
      if (alpha <= 0 || alpha >= 245) {
        continue;
      }
      partialEdgePixels += 1;
      if (decoded.rgba[index + 1] > decoded.rgba[index] + 48 && decoded.rgba[index + 1] > decoded.rgba[index + 2] + 48) {
        greenFringePixels += 1;
      }
    }
  }
  return {
    partialEdgePixels,
    greenFringePixels,
    greenFringeRatio: partialEdgePixels > 0 ? Number((greenFringePixels / partialEdgePixels).toFixed(4)) : 0
  };
}

function repairFullresPath() {
  return join(repairLocalSlotRoot, `${slotId}_fullres.png`);
}

function repairFullresMetadataPath() {
  return join(repairLocalSlotRoot, `${slotId}_fullres.metadata.json`);
}

function repairDerivativePath(size) {
  return join(repairLocalSlotRoot, `${slotId}_trimmed_${size}.png`);
}

function repairDerivativeMetadataPath(size) {
  return join(repairLocalSlotRoot, `${slotId}_trimmed_${size}.metadata.json`);
}

function repairSourcePreflight() {
  const errors = [];
  if (!existsSync(localSource)) {
    errors.push(`Missing original v0.151 Aster source ${relativeRepo(localSource)}.`);
  }
  if (!existsSync(localCutout)) {
    errors.push(`Missing v0.151 Aster cutout ${relativeRepo(localCutout)}.`);
  }
  if (!existsSync(localMetadata)) {
    errors.push(`Missing v0.151 Aster metadata ${relativeRepo(localMetadata)}.`);
  }
  if (localSourceCount() !== 1) {
    errors.push(`Expected exactly one v0.151 Aster source image, found ${localSourceCount()}.`);
  }
  if (!errors.length) {
    const metadata = readJson(localMetadata);
    const cutoutHash = sha256File(localCutout);
    if (metadata.sha256 !== cutoutHash || metadata.slotId !== slotId) {
      errors.push("v0.151 Aster cutout metadata hash or slot mismatch.");
    }
    if (metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
      errors.push("v0.151 Aster metadata boundary flags are invalid.");
    }
  }
  return errors;
}

function createRepairDerivativeBuffer(targetSize) {
  const decoded = decodePng(readFileSync(localCutout));
  const sourceAnalysis = analyzePngFile(localCutout);
  const trim = sourceAnalysis.trimBounds;
  if (!trim) {
    throw new Error("Cannot create Aster derivative because source alpha trim bounds are empty.");
  }
  const rgba = Buffer.alloc(targetSize * targetSize * 4);
  const maxContentWidth = targetSize * 0.62;
  const maxContentHeight = targetSize * 0.92;
  const scale = Math.min(maxContentWidth / trim.width, maxContentHeight / trim.height);
  const scaledWidth = Math.max(1, Math.round(trim.width * scale));
  const scaledHeight = Math.max(1, Math.round(trim.height * scale));
  const destX = Math.round((targetSize - scaledWidth) / 2);
  const bottomPad = Math.max(8, Math.round(targetSize * 0.035));
  const destY = Math.max(0, targetSize - bottomPad - scaledHeight);
  for (let y = 0; y < scaledHeight; y += 1) {
    for (let x = 0; x < scaledWidth; x += 1) {
      const sourceX = trim.left + (x + 0.5) / scale - 0.5;
      const sourceY = trim.top + (y + 0.5) / scale - 0.5;
      const pixel = samplePremultipliedBilinear(decoded, sourceX, sourceY);
      const targetX = destX + x;
      const targetY = destY + y;
      const index = (targetY * targetSize + targetX) * 4;
      rgba[index] = pixel[0];
      rgba[index + 1] = pixel[1];
      rgba[index + 2] = pixel[2];
      rgba[index + 3] = pixel[3];
    }
  }
  applyTransparentColorBleed(rgba, targetSize, targetSize, 3);
  return encodePng(targetSize, targetSize, rgba);
}

function repairMetadata(kind, imagePath, sourceAnalysis, extra = {}, write = true) {
  const analysis = analyzePngFile(imagePath);
  const metadata = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    sourceCheckpoint: checkpoint,
    slotId,
    derivativeKind: kind,
    sourcePath: relativeRepo(localCutout),
    sourceSha256: sourceAnalysis.sha256,
    sourceDimensions: { width: sourceAnalysis.width, height: sourceAnalysis.height },
    path: relativeRepo(imagePath),
    sha256: analysis.sha256,
    byteLength: analysis.byteLength,
    dimensions: { width: analysis.width, height: analysis.height },
    alphaPosture: "same-source deterministic trim-pad-premultiplied-resize-transparent-rgb-bleed",
    alphaStats: {
      transparentPixels: analysis.transparentPixels,
      partiallyTransparentPixels: analysis.partiallyTransparentPixels,
      opaquePixels: analysis.opaquePixels,
      transparentCornerCount: analysis.transparentCornerCount,
      greenFringePixels: analysis.greenFringePixels,
      greenFringeRatio: analysis.greenFringeRatio
    },
    alphaEdgeStats: alphaEdgeStats(decodePng(readFileSync(imagePath))),
    trimBounds: analysis.trimBounds,
    pivot: analysis.pivot,
    deterministicOperations: [
      "same v0.151 Aster cutout only",
      "alpha bounds trim",
      "transparent square padding",
      "premultiplied-alpha-equivalent bilinear resize",
      "transparent RGB edge bleed",
      "metadata and hash regeneration"
    ],
    role: {
      defaultHeroName: "Aster",
      workerDistinction: "hero cloak and upright command posture; not Worker utility silhouette"
    },
    selectedWorkerContextHash: selectedWorkerHash,
    selectedBarracksMaterialContextHash: selectedBarracksHash,
    zeroNewAiImagesForV0152: true,
    sameAsterSourceOnly: true,
    noNewRuntimeArtSlot: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    normalSaltoPlayerSliceModified: false,
    humanReviewStatus: "pending-review",
    ...extra
  };
  if (write) {
    writeJson(imagePath.replace(/\.png$/u, ".metadata.json"), metadata);
  }
  return metadata;
}

function repairDerivativeRecords(write) {
  const errors = repairSourcePreflight();
  const records = [];
  if (errors.length) {
    return {
      schemaVersion: 1,
      checkpoint: repairCheckpoint,
      status: "FAIL_V0152_ASTER_BILLBOARD_REPAIR_DERIVATIVES",
      errors,
      records
    };
  }
  mkdirSync(repairLocalSlotRoot, { recursive: true });
  const sourceAnalysis = analyzePngFile(localCutout);
  if (write) {
    writeFileSync(repairFullresPath(), readFileSync(localCutout));
  }
  if (existsSync(repairFullresPath())) {
    records.push({
      key: "fullres",
      approach: "HYBRID_ASTER_FULL_RES",
      ...repairMetadata("source-quality-full-resolution-comparator", repairFullresPath(), sourceAnalysis, {
        alphaPosture: "same-source full-resolution comparator copy"
      }, write)
    });
  } else {
    errors.push(`Missing full-res Aster comparator ${relativeRepo(repairFullresPath())}.`);
  }
  for (const size of repairDerivativeSizes) {
    const path = repairDerivativePath(size);
    if (write) {
      writeFileSync(path, createRepairDerivativeBuffer(size));
    }
    if (!existsSync(path)) {
      errors.push(`Missing Aster repair derivative ${relativeRepo(path)}.`);
      continue;
    }
    records.push({
      key: `trimmed_${size}`,
      approach: `HYBRID_ASTER_TRIMMED_${size}`,
      ...repairMetadata(`trimmed-padded-alpha-treated-${size}`, path, sourceAnalysis, {
        targetSize: size
      }, write)
    });
  }
  const matrix = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0152_ASTER_BILLBOARD_REPAIR_DERIVATIVES" : "PASS_V0152_ASTER_BILLBOARD_REPAIR_DERIVATIVES",
    slotId,
    sourceImageCount: localSourceCount(),
    zeroNewAiImagesForV0152: true,
    sameAsterSourceOnly: true,
    noNewRuntimeArtSlot: true,
    records,
    errors
  };
  if (write) {
    writeJson(join(repairLocalSlotRoot, `${slotId}_derivative-matrix.json`), matrix);
  }
  writeJson(join(repairEvidenceRootFromArgs(), "aster-billboard-repair-derivatives.json"), matrix);
  return matrix;
}

function repairDerivativesCheck() {
  const expected = repairDerivativeRecords(false);
  const errors = [...expected.errors];
  for (const record of expected.records) {
    const imagePath = join(repoRoot, record.path);
    const metadataPath = imagePath.replace(/\.png$/u, ".metadata.json");
    if (!existsSync(imagePath)) {
      errors.push(`Missing derivative image ${record.path}.`);
      continue;
    }
    if (!existsSync(metadataPath)) {
      errors.push(`Missing derivative metadata ${relativeRepo(metadataPath)}.`);
      continue;
    }
    const metadata = readJson(metadataPath);
    const hash = sha256File(imagePath);
    if (metadata.sha256 !== hash || record.sha256 !== hash) {
      errors.push(`Derivative hash mismatch for ${record.path}.`);
    }
    if (metadata.slotId !== slotId || metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
      errors.push(`Derivative boundary mismatch for ${record.path}.`);
    }
  }
  const report = {
    ...expected,
    status: errors.length ? "FAIL_V0152_ASTER_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY" : "PASS_V0152_ASTER_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY",
    errors
  };
  writeJson(join(repairEvidenceRootFromArgs(), "aster-billboard-repair-derivatives-reproducibility.json"), report);
  return report;
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
    generatedBy: "tools/godot/asterBillboardSingleSlotTool.mjs fallback",
    originalGeometricDiagnosticOnly: true,
    productionApproval: "forbidden",
    privateComparatorOnly: true,
    browserIntegration: "forbidden",
    playerSliceIntegration: "forbidden",
    fourthRuntimeArtSlotAdded: false,
    sha256,
    byteLength: buffer.length,
    dimensions: { width: analysis.width, height: analysis.height },
    alphaPosture: "tracked-transparent-aster-diagnostic-fallback",
    trimBounds: analysis.trimBounds,
    pivot: analysis.pivot
  };
  if (write) {
    mkdirSync(fallbackRoot, { recursive: true });
    writeFileSync(fallbackPng, buffer);
    writeJson(fallbackContract, contract);
  }
  return {
    status: "PASS_V0151_ASTER_BILLBOARD_FALLBACK_GENERATED",
    path: relativeRepo(fallbackPng),
    contractPath: relativeRepo(fallbackContract),
    ...contract
  };
}

function fallbackCheck() {
  const generated = fallbackRecord(false);
  const errors = [];
  if (!existsSync(fallbackPng)) {
    errors.push(`Missing fallback PNG ${relativeRepo(fallbackPng)}.`);
  } else if (sha256File(fallbackPng) !== generated.sha256) {
    errors.push("Tracked Aster fallback hash does not match deterministic generator.");
  }
  if (!existsSync(fallbackContract)) {
    errors.push(`Missing fallback contract ${relativeRepo(fallbackContract)}.`);
  } else {
    const contract = readJson(fallbackContract);
    if (contract.sha256 !== generated.sha256 || contract.privateComparatorOnly !== true || contract.productionApproval !== "forbidden") {
      errors.push("Tracked Aster fallback contract boundary/hash mismatch.");
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0151_ASTER_BILLBOARD_FALLBACK_REPRODUCIBILITY" : "PASS_V0151_ASTER_BILLBOARD_FALLBACK_REPRODUCIBILITY",
    fallback: generated,
    errors
  };
  writeJson(join(evidenceRootFromArgs(), "aster-billboard-fallback-reproducibility.json"), report);
  return report;
}

function localSourceCount() {
  return existsSync(localSlotRoot)
    ? readdirSync(localSlotRoot).filter((name) => name.endsWith("_source.png")).length
    : 0;
}

function localMetadataRecord(write) {
  const errors = [];
  if (!existsSync(localSource)) {
    errors.push(`Missing one generated Aster source ${relativeRepo(localSource)}.`);
  }
  if (!existsSync(localCutout)) {
    errors.push(`Missing Aster matte-to-alpha cutout ${relativeRepo(localCutout)}.`);
  }
  if (localSourceCount() !== 1) {
    errors.push(`Expected exactly one v0.151 Aster source image, found ${localSourceCount()}.`);
  }
  if (errors.length) {
    return {
      schemaVersion: 1,
      checkpoint,
      status: "FAIL_V0151_ASTER_BILLBOARD_LOCAL_METADATA",
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
      defaultHeroName: "Aster",
      narrativeRole: "persistent central Barrosan foothold Commander / Champion",
      runtimeRole: "hero selection anchor, fight anchor, skill spender, relic-build identity",
      workerDistinction: "hero cloak and upright command posture; not Worker utility silhouette"
    },
    referencePosture: {
      v0144T1PrimaryReferenceUsedAsBriefOnly: true,
      v0144T3LimitedPresenceCueUsedAsBriefOnly: true,
      importedReferenceImage: false,
      tracedReferenceImage: false,
      croppedReferenceImage: false
    },
    generation: {
      exactlyOneAiImageForV0151: true,
      generator: "Codex built-in image generation",
      modelProviderPosture: "built-in image_gen; exact model/provider not exposed by tool",
      generatedSourceTimestamp: new Date(statSync(localSource).mtimeMs).toISOString(),
      sourcePosture: "one original generated flat-matte source, deterministic matte-to-alpha conversion, source preserved"
    },
    sourcePath: relativeRepo(localSource),
    sourceSha256: sourceAnalysis.sha256,
    sourceDimensions: { width: sourceAnalysis.width, height: sourceAnalysis.height },
    sha256: cutoutAnalysis.sha256,
    byteLength: cutoutAnalysis.byteLength,
    dimensions: { width: cutoutAnalysis.width, height: cutoutAnalysis.height },
    alphaPosture: cutoutAnalysis.hasAlpha
      ? "flat-matte-source-deterministic-chroma-to-alpha-transparent-png"
      : "opaque-or-unexpected-alpha",
    alphaStats: {
      transparentPixels: cutoutAnalysis.transparentPixels,
      partiallyTransparentPixels: cutoutAnalysis.partiallyTransparentPixels,
      opaquePixels: cutoutAnalysis.opaquePixels,
      transparentCornerCount: cutoutAnalysis.transparentCornerCount,
      greenFringePixels: cutoutAnalysis.greenFringePixels,
      greenFringeRatio: cutoutAnalysis.greenFringeRatio
    },
    trimBounds: cutoutAnalysis.trimBounds,
    pivot: cutoutAnalysis.pivot,
    selectedWorkerContextHash: selectedWorkerHash,
    selectedBarracksMaterialContextHash: selectedBarracksHash,
    intendedScope: "private isolated Godot hybrid comparator only",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    noFourthRuntimeArtSlot: true,
    normalSaltoPlayerSliceModified: false,
    humanReviewStatus: "pending-review"
  };
  if (write) {
    writeJson(localMetadata, metadata);
  }
  const validAlpha = cutoutAnalysis.hasAlpha && cutoutAnalysis.transparentCornerCount === 4 && cutoutAnalysis.trimBounds;
  return {
    schemaVersion: 1,
    checkpoint,
    status: validAlpha ? "PASS_V0151_ASTER_BILLBOARD_LOCAL_METADATA" : "FAIL_V0151_ASTER_BILLBOARD_LOCAL_METADATA",
    errors: validAlpha ? [] : ["Local Aster cutout alpha or trim posture is invalid."],
    metadataPath: relativeRepo(localMetadata),
    metadata
  };
}

function validateLocalSlot() {
  const errors = [];
  if (!existsSync(localMetadata)) {
    errors.push(`Missing Aster local metadata ${relativeRepo(localMetadata)}.`);
  }
  const local = localMetadataRecord(false);
  errors.push(...(local.errors ?? []));
  if (existsSync(localMetadata) && local.metadata) {
    const metadata = readJson(localMetadata);
    if (metadata.slotId !== slotId || metadata.sha256 !== local.metadata.sha256) {
      errors.push("Aster local metadata slot or hash mismatch.");
    }
    if (metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
      errors.push("Aster local metadata boundary flags are invalid.");
    }
    if (metadata.generation?.exactlyOneAiImageForV0151 !== true || metadata.noFourthRuntimeArtSlot !== true) {
      errors.push("Aster metadata does not preserve one-image/third-slot boundary.");
    }
  }
  return {
    status: errors.length ? "FAIL_V0151_ASTER_BILLBOARD_LOCAL_SLOT" : "PASS_V0151_ASTER_BILLBOARD_LOCAL_SLOT",
    errors,
    local
  };
}

function verifyContextArtifacts() {
  const errors = [];
  const workerPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148", "local-worker-slot", "worker_billboard_static_v0147_trimmed_1024.png");
  const barracksPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0150", "local-barracks-material-seam-repair", "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png");
  const v0150Threshold = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0150", "evidence", "barracks-material-seam-repair-threshold-report.json");
  if (!existsSync(workerPath) || sha256File(workerPath) !== selectedWorkerHash) {
    errors.push("Selected v0.148 Worker context derivative is missing or hash-mismatched.");
  }
  if (!existsSync(barracksPath) || sha256File(barracksPath) !== selectedBarracksHash) {
    errors.push("Selected v0.150 Barracks material context derivative is missing or hash-mismatched.");
  }
  if (!existsSync(v0150Threshold)) {
    errors.push("Missing v0.150 threshold report proving the prerequisite seam-repair gate.");
  } else {
    const threshold = readJson(v0150Threshold);
    if (threshold.status !== "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE") {
      errors.push("v0.150 prerequisite threshold report is not PASS.");
    }
  }
  return {
    status: errors.length ? "FAIL_V0151_CONTEXT_ARTIFACT_AUDIT" : "PASS_V0151_CONTEXT_ARTIFACT_AUDIT",
    selectedWorkerHash,
    selectedBarracksHash,
    errors
  };
}

function validate() {
  const errors = [];
  const requiredFiles = [
    "GODOT_ASTER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.contract.json",
    "tools/godot/asterBillboardSingleSlotTool.mjs",
    "tools/godot/runGodotAsterBillboardValidation.ps1",
    "tools/godot/runGodotAsterBillboardFallbackReproducibility.ps1",
    "tools/godot/runGodotAsterBillboardAudit.ps1",
    "tools/godot/runGodotAsterBillboardBenchmarkWindows.ps1",
    "tools/godot/captureGodotAsterBillboardWindows.ps1",
    "docs/V0151_ASTER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
    "docs/V0151_ASTER_BILLBOARD_SLOT_CONTRACT.md",
    "docs/V0151_ASTER_BILLBOARD_VALIDATION_REPORT.md",
    "docs/V0151_ASTER_BILLBOARD_SCORECARD.md",
    "docs/V0151_ASTER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
    "docs/V0151_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0151_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.151 file: ${file}`);
    }
  }
  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const script of [
    "godot:aster-billboard:metadata",
    "godot:aster-billboard:validate",
    "godot:aster-billboard:fallback:reproduce",
    "godot:aster-billboard:audit",
    "godot:aster-billboard:benchmark:headed",
    "godot:aster-billboard:capture"
  ]) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script ${script}.`);
    }
  }
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--aster-billboard-single-slot") || !rootScript.includes("PASS_V0151_PRIVATE_ASTER_BILLBOARD_DISPATCH")) {
    errors.push("Root script does not expose the private Aster billboard dispatch.");
  }
  const project = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "project.godot"), "utf8");
  if (!project.includes('run/main_scene="res://scenes/salto_spike_root.tscn"')) {
    errors.push("Godot default main scene changed; Aster slot must stay private.");
  }
  for (const launcher of ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("aster-billboard-single-slot") || text.includes("ASTER_BILLBOARD_SINGLE_SLOT")) {
      errors.push(`${launcher} references the private Aster billboard experiment.`);
    }
  }
  const comparatorScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline", "aster_billboard_single_slot_comparator.gd"), "utf8");
  if (comparatorScript.includes("artifacts/art-review") || comparatorScript.includes("reference_candidates")) {
    errors.push("Aster comparator must not import reference-art candidates.");
  }
  const fallback = fallbackCheck();
  const local = validateLocalSlot();
  const context = verifyContextArtifacts();
  errors.push(...fallback.errors, ...local.errors, ...context.errors);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0151_ASTER_BILLBOARD_VALIDATION" : "PASS_V0151_ASTER_BILLBOARD_VALIDATION",
    slotId,
    exactlyOneAiImageForV0151: true,
    sourceImageCount: localSourceCount(),
    selectedWorkerHash,
    selectedBarracksHash,
    noFourthRuntimeArtSlot: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    fallback,
    local,
    context,
    errors
  };
  writeJson(join(evidenceRootFromArgs(), "aster-billboard-validation.json"), report);
  return report;
}

function numberSummary(values) {
  const sorted = values.filter((value) => Number.isFinite(value)).sort((left, right) => left - right);
  if (!sorted.length) {
    return { min: 0, max: 0, mean: 0, median: 0, spread: 0 };
  }
  const sum = sorted.reduce((total, value) => total + value, 0);
  const middle = Math.floor(sorted.length / 2);
  const median = sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
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
    const group = groups.get(key) ?? [];
    group.push(row);
    groups.set(key, group);
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
      initializationDurationMs: numberSummary(group.map((row) => Number(row.initializationDurationMs ?? 0))),
      frameCount: group[0]?.frameCount ?? 0,
      entityCount: group[0]?.entityCount ?? 0,
      asterCount: group[0]?.asterCount ?? 0,
      workerContextCount: group[0]?.workerContextCount ?? 0,
      barracksShellCount: group[0]?.barracksShellCount ?? 0,
      billboardInstanceCount: group[0]?.billboardInstanceCount ?? 0,
      renderedObjectProxy: group[0]?.renderedObjectProxy ?? 0,
      sourceLoaded: group[0]?.sourceLoaded ?? group[0]?.assetSourceLoaded ?? "unknown",
      assetHash: group[0]?.assetHash ?? "not-applicable",
      derivativeDimensions: group[0]?.derivativeDimensions ?? {},
      alphaTreatmentReviewable: group.every((row) => row.alphaTreatmentReviewable !== false),
      footPivotStable: group.every((row) => row.footPivotStable !== false),
      selectionRingVisible: group.every((row) => row.selectionRingVisible !== false),
      asterReadsHeroNotWorker: group.every((row) => row.asterReadsHeroNotWorker !== false),
      workerDistinct: group.every((row) => row.workerDistinct !== false),
      confidence: group[0]?.confidence ?? "local-headed-private-comparator"
    };
  });
}

function threshold(aggregates, trialRows) {
  const baseline = aggregates.find((row) => row.approach === "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE" && row.tier === "L");
  const local = aggregates.find((row) => row.approach === "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD" && row.tier === "L");
  const localTrials = trialRows.filter((row) => row.approach === "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD" && row.tier === "L");
  const averageFpsRatio = baseline && local && baseline.averageFps.mean > 0
    ? Number((local.averageFps.mean / baseline.averageFps.mean).toFixed(4))
    : 0;
  const p95FrameTimeRatio = baseline && local && baseline.p95FrameTimeMs.mean > 0
    ? Number((local.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean).toFixed(4))
    : 999;
  const recognitionPass = localTrials.length > 0 && localTrials.every((row) =>
    row.asterReadsHeroNotWorker === true &&
    row.workerDistinct === true &&
    row.footPivotStable === true &&
    row.selectionRingVisible === true &&
    row.alphaTreatmentReviewable === true
  );
  const pass = Boolean(baseline && local && averageFpsRatio >= 0.9 && p95FrameTimeRatio <= 1.15 && recognitionPass);
  return {
    status: pass ? "PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE" : "FAIL_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE",
    gate: {
      averageFpsRatioMinimum: 0.9,
      p95FrameTimeWorseningMaximumRatio: 1.15,
      asterReadsHeroNotWorkerRequired: true,
      workerDistinctRequired: true,
      pivotStableRequired: true,
      alphaReviewableRequired: true,
      selectionRingVisibleRequired: true,
      visualGateRequiresHumanReview: true
    },
    baseline,
    local,
    averageFpsRatio,
    averageFpsPass: averageFpsRatio >= 0.9,
    p95FrameTimeRatio,
    p95FrameTimePass: p95FrameTimeRatio <= 1.15,
    recognitionPass,
    localTierLTrials: localTrials,
    selectedRecommendedApproach: pass ? "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD" : "none",
    selectedRecommendedSource: pass ? local.sourceLoaded : "none",
    selectedRecommendedHash: pass ? local.assetHash : "",
    selectedRecommendedDimensions: pass ? local.derivativeDimensions : { width: 0, height: 0 },
    visualAutomatedStatus: "CAPTURED_FOR_HUMAN_REVIEW",
    reason: pass
      ? "Local Aster cutout passes the preserved Tier L performance gate and required automated readability posture."
      : "Local Aster cutout did not satisfy the preserved Tier L performance/readability gate."
  };
}

function report() {
  const validation = validate();
  const evidenceRoot = evidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, runtimeReportName);
  const errors = [...validation.errors];
  if (!existsSync(runtimePath)) {
    throw new Error(`Missing Godot Aster billboard runtime report: ${relativeRepo(runtimePath)}`);
  }
  const runtime = readJson(runtimePath);
  const benchmarkRows = runtime.benchmarks ?? [];
  errors.push(...(runtime.errors ?? []));
  for (const approach of approaches) {
    for (const tier of tiers) {
      if (!benchmarkRows.some((row) => row.approach === approach && row.tier === tier)) {
        errors.push(`Missing benchmark row ${approach} ${tier}.`);
      }
    }
  }
  for (const approach of ["HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE", "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD"]) {
    const tierLCount = benchmarkRows.filter((row) => row.approach === approach && row.tier === "L").length;
    if (tierLCount < 5) {
      errors.push(`Expected at least five Tier L trials for ${approach}, found ${tierLCount}.`);
    }
  }
  const screenshotRoot = join(evidenceRoot, "screenshots");
  const screenshots = [];
  for (const capture of runtime.captures ?? []) {
    const path = join(screenshotRoot, capture.fileName);
    if (!existsSync(path)) {
      errors.push(`Missing Aster screenshot ${relativeRepo(path)}.`);
      continue;
    }
    screenshots.push({
      ...capture,
      path: relativeRepo(path),
      sha256: sha256File(path),
      width: capture.width ?? 1600,
      height: capture.height ?? 900
    });
  }
  const aggregateRows = aggregateBenchmarks(benchmarkRows);
  const gate = threshold(aggregateRows, benchmarkRows);
  if (!gate.status.startsWith("PASS")) {
    errors.push(gate.reason);
  }
  const summary = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0151_ASTER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED" : "PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED",
    slotId,
    sourceRuntimeReport: relativeRepo(runtimePath),
    exactlyOneAiImageForV0151: true,
    sourceImageCount: localSourceCount(),
    noFourthRuntimeArtSlot: true,
    selectedWorkerHash,
    selectedBarracksHash,
    aggregateRows,
    benchmarkRows,
    screenshots,
    threshold: gate,
    scorecard: {
      status: gate.status,
      tiers,
      approaches,
      aggregateRows
    },
    fairPathAudit: runtime.fairPathAudit,
    readabilityAudit: runtime.readabilityAudit,
    fallbackSource: runtime.fallbackSource,
    localSource: runtime.localSource,
    workerContextSource: runtime.workerContextSource,
    barracksContextSource: runtime.barracksContextSource,
    selectedRecommendedApproach: gate.selectedRecommendedApproach,
    selectedRecommendedSource: gate.selectedRecommendedSource,
    boundaries: runtime.boundaries,
    limitations: runtime.limitations,
    errors
  };
  writeJson(join(evidenceRoot, "aster-billboard-single-slot-evidence.json"), summary);
  writeJson(join(evidenceRoot, "aster-billboard-single-slot-threshold-report.json"), gate);
  writeJson(join(evidenceRoot, "aster-billboard-single-slot-scorecard.json"), summary.scorecard);
  writeJson(join(evidenceRoot, "aster-billboard-single-slot-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint,
    screenshotCount: screenshots.length,
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
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const auditRecord = runtime?.fairPathAudit ?? {
    runtimeEvidencePresent: false,
    note: "Run the v0.151 headed paired benchmark before collecting runtime audit counters."
  };
  const errors = [];
  if (runtime && auditRecord.localAndFallbackShareAsterBillboardRenderPath !== true) {
    errors.push("Runtime audit did not prove local/fallback Aster path sharing.");
  }
  if (runtime && auditRecord.repeatedTextureCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove texture creation was absent during steady-state frames.");
  }
  if (runtime && auditRecord.repeatedMaterialCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove material creation was absent during steady-state frames.");
  }
  if (runtime && auditRecord.benchmarkExcludesInitializationAndWarmup !== true) {
    errors.push("Runtime audit did not prove initialization/warmup were excluded from measured frames.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length ? "FAIL_V0151_ASTER_BILLBOARD_FAIR_PATH_AUDIT" : "PASS_V0151_ASTER_BILLBOARD_FAIR_PATH_AUDIT",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    noFourthRuntimeArtSlot: true,
    audit: auditRecord,
    errors
  };
  writeJson(join(evidenceRoot, "aster-billboard-single-slot-fair-path-audit.json"), report);
  return report;
}

function benchmarkMarkdown(summary) {
  const lines = [
    "# v0.151 Aster Billboard Single-Slot Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    `Gate: ${summary.threshold.status}`,
    `Selected approach: ${summary.threshold.selectedRecommendedApproach}`,
    "",
    "| Approach | Tier | Trials | Mean FPS | Median FPS | p95 ms | p99 ms | Source |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.aggregateRows) {
    lines.push(`| \`${row.approach}\` | \`${row.tier}\` | ${row.trialCount} | ${row.averageFps.mean} | ${row.averageFps.median} | ${row.p95FrameTimeMs.mean} | ${row.p99FrameTimeMs.mean} | ${row.sourceLoaded} |`);
  }
  lines.push("", "## Gate", "");
  lines.push(`- Average FPS ratio: ${summary.threshold.averageFpsRatio}`);
  lines.push(`- p95 frame-time ratio: ${summary.threshold.p95FrameTimeRatio}`);
  lines.push(`- Recognition posture: ${summary.threshold.recognitionPass}`);
  lines.push("", "Screenshots are private comparator evidence only and require human review.");
  return `${lines.join("\n")}\n`;
}

function visualReviewMarkdown(summary) {
  const lines = [
    "# v0.151 Aster Billboard Visual Review Guide",
    "",
    `Gate result: \`${summary.threshold.status}\``,
    "",
    "Review questions:",
    "",
    "- Does Aster read as the central Commander / Champion, not as a Worker?",
    "- Does the cloak edge hold up on checkerboard, dark, and light backgrounds?",
    "- Is the foot pivot stable during pan and zoom?",
    "- Does the selection ring stay visible?",
    "- Do Aster, the selected Worker derivative, and the repaired Barracks material remain distinct together?",
    "- Is 0.90x, 1.00x, or 1.10x the safest scale posture for a future production-directed test?",
    "",
    "Non-approval boundary:",
    "",
    "- Private comparator only.",
    "- Exactly one v0.151 AI image.",
    "- No fourth runtime-art slot.",
    "- No normal Salto player-slice mutation.",
    "- No browser runtime wiring.",
    "- Not final Aster art approval, production integration, or final Godot selection.",
    "",
    "Captures:",
    ""
  ];
  for (const shot of summary.screenshots) {
    lines.push(`- \`${shot.id}\`: \`${shot.path}\``);
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
    `<text x="18" y="30" fill="#e7eadc" font-family="Arial" font-size="18">v0.151 Aster billboard private comparator contact sheet</text>`
  ];
  screenshots.forEach((shot, index) => {
    const col = index % cols;
    const row = Math.floor(index / cols);
    const x = col * cellWidth + 14;
    const y = row * cellHeight + 52;
    const href = shot.path.replace("artifacts/desktop-spikes/godot-salto/v0151/evidence/", "").replaceAll("&", "&amp;");
    parts.push(`<rect x="${x - 4}" y="${y - 4}" width="336" height="226" fill="#202820" stroke="#465446"/>`);
    parts.push(`<image href="${href}" x="${x}" y="${y}" width="328" height="185" preserveAspectRatio="xMidYMid meet"/>`);
    parts.push(`<text x="${x}" y="${y + 205}" fill="#d8ddce" font-family="Arial" font-size="11">${shot.id}</text>`);
  });
  parts.push("</svg>");
  return `${parts.join("\n")}\n`;
}

function repairValidate() {
  const errors = [];
  const requiredFiles = [
    "GODOT_ASTER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.contract.json",
    "tools/godot/asterBillboardSingleSlotTool.mjs",
    "tools/godot/runGodotAsterBillboardRepairDerivatives.ps1",
    "tools/godot/runGodotAsterBillboardRepairValidation.ps1",
    "tools/godot/runGodotAsterBillboardRepairAudit.ps1",
    "tools/godot/runGodotAsterBillboardRepairBenchmarkWindows.ps1",
    "tools/godot/captureGodotAsterBillboardRepairWindows.ps1",
    "docs/V0152_ASTER_BILLBOARD_REPAIR_SPEC.md",
    "docs/V0152_ASTER_BILLBOARD_DERIVATIVE_MATRIX.md",
    "docs/V0152_ASTER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md",
    "docs/V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT.md",
    "docs/V0152_ASTER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
    "docs/V0152_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0152_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.152 file: ${file}`);
    }
  }
  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const script of [
    "godot:aster-billboard-repair:derivatives:reproduce",
    "godot:aster-billboard-repair:validate",
    "godot:aster-billboard-repair:audit",
    "godot:aster-billboard-repair:benchmark:headed",
    "godot:aster-billboard-repair:capture"
  ]) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script ${script}.`);
    }
  }
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--aster-billboard-single-slot-repair") || !rootScript.includes("PASS_V0152_PRIVATE_ASTER_BILLBOARD_REPAIR_DISPATCH")) {
    errors.push("Root script does not expose the private Aster repair dispatch.");
  }
  for (const launcher of ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("aster-billboard-single-slot-repair") || text.includes("ASTER_BILLBOARD_SINGLE_SLOT_REPAIR")) {
      errors.push(`${launcher} references the private v0.152 Aster repair experiment.`);
    }
  }
  const v0151Validation = validate();
  errors.push(...v0151Validation.errors);
  const derivatives = repairDerivativesCheck();
  errors.push(...derivatives.errors);
  const report = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0152_ASTER_BILLBOARD_REPAIR_VALIDATION" : "PASS_V0152_ASTER_BILLBOARD_REPAIR_VALIDATION",
    errors,
    v0151ValidationStatus: v0151Validation.status,
    derivatives,
    sourceImageCount: localSourceCount(),
    zeroNewAiImagesForV0152: true,
    sameAsterSourceOnly: true,
    noNewRuntimeArtSlot: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  writeJson(join(repairEvidenceRootFromArgs(), "aster-billboard-repair-validation.json"), report);
  return report;
}

function aggregateRepairBenchmarks(rows) {
  const groups = new Map();
  for (const row of rows) {
    const key = `${row.approach}|${row.tier}`;
    const group = groups.get(key) ?? [];
    group.push(row);
    groups.set(key, group);
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
      initializationDurationMs: numberSummary(group.map((row) => Number(row.initializationDurationMs ?? 0))),
      frameCount: group[0]?.frameCount ?? 0,
      entityCount: group[0]?.entityCount ?? 0,
      asterCount: group[0]?.asterCount ?? 0,
      workerContextCount: group[0]?.workerContextCount ?? 0,
      barracksShellCount: group[0]?.barracksShellCount ?? 0,
      billboardInstanceCount: group[0]?.billboardInstanceCount ?? 0,
      renderedObjectProxy: group[0]?.renderedObjectProxy ?? 0,
      sourceLoaded: group[0]?.sourceLoaded ?? group[0]?.assetSourceLoaded ?? "unknown",
      assetHash: group[0]?.assetHash ?? "not-applicable",
      derivativeDimensions: group[0]?.derivativeDimensions ?? {},
      alphaTreatmentReviewable: group.every((row) => row.alphaTreatmentReviewable !== false),
      footPivotStable: group.every((row) => row.footPivotStable !== false),
      selectionRingVisible: group.every((row) => row.selectionRingVisible !== false),
      heroReadability: group.every((row) => row.heroReadability !== false && row.asterReadsHeroNotWorker !== false),
      workerDistinct: group.every((row) => row.workerDistinct !== false),
      noObviousHalo: group.every((row) => row.noObviousHalo !== false),
      confidence: group[0]?.confidence ?? "local-headed-private-comparator"
    };
  });
}

function repairSourceRank(approach) {
  return {
    HYBRID_ASTER_TRIMMED_1024: 4,
    HYBRID_ASTER_TRIMMED_768: 3,
    HYBRID_ASTER_TRIMMED_512: 2,
    HYBRID_ASTER_FULL_RES: 1
  }[approach] ?? 0;
}

function repairThreshold(aggregates, trialRows) {
  const baseline = aggregates.find((row) => row.approach === "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE" && row.tier === "L");
  const candidateApproaches = repairApproaches.filter((approach) => approach !== "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE");
  const candidates = candidateApproaches
    .map((approach) => {
      const aggregate = aggregates.find((row) => row.approach === approach && row.tier === "L");
      if (!baseline || !aggregate) {
        return null;
      }
      const trials = trialRows.filter((row) => row.approach === approach && row.tier === "L");
      const averageFpsRatio = Number((aggregate.averageFps.mean / baseline.averageFps.mean).toFixed(4));
      const p95FrameTimeRatio = Number((aggregate.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean).toFixed(4));
      const visualPass = trials.length > 0 && trials.every((row) =>
        row.asterReadsHeroNotWorker === true &&
        row.heroReadability !== false &&
        row.workerDistinct === true &&
        row.noObviousHalo !== false &&
        row.footPivotStable === true &&
        row.selectionRingVisible === true &&
        row.alphaTreatmentReviewable === true
      );
      return {
        approach,
        assetSourceLoaded: aggregate.sourceLoaded,
        assetHash: aggregate.assetHash,
        derivativeDimensions: aggregate.derivativeDimensions,
        averageFpsRatio,
        p95FrameTimeRatio,
        averageFpsPass: averageFpsRatio >= 0.9,
        p95FrameTimePass: p95FrameTimeRatio <= 1.15,
        visualPass,
        baselineAverageFpsMean: baseline.averageFps.mean,
        candidateAverageFpsMean: aggregate.averageFps.mean,
        baselineP95FrameTimeMeanMs: baseline.p95FrameTimeMs.mean,
        candidateP95FrameTimeMeanMs: aggregate.p95FrameTimeMs.mean,
        tierLTrialCount: trials.length
      };
    })
    .filter(Boolean);
  const passing = candidates
    .filter((candidate) => candidate.averageFpsPass && candidate.p95FrameTimePass && candidate.visualPass)
    .sort((left, right) => repairSourceRank(right.approach) - repairSourceRank(left.approach) || right.averageFpsRatio - left.averageFpsRatio);
  const selected = passing[0] ?? null;
  return {
    status: selected ? "PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE" : "FAIL_V0152_ASTER_BILLBOARD_REPAIR_GATE",
    gate: {
      averageFpsRatioMinimum: 0.9,
      p95FrameTimeWorseningMaximumRatio: 1.15,
      heroReadabilityRequired: true,
      workerDistinctRequired: true,
      noObviousHaloRequired: true,
      stablePivotRequired: true,
      selectionRingVisibleRequired: true,
      visualGateRequiresHumanReview: true
    },
    baseline,
    candidates,
    selectedRecommendedDerivative: selected?.approach ?? null,
    selectedRecommendedSource: selected?.assetSourceLoaded ?? null,
    selectedRecommendedHash: selected?.assetHash ?? null,
    selectedRecommendedDimensions: selected?.derivativeDimensions ?? null,
    reason: selected
      ? "At least one same-source deterministic Aster repair derivative passed the preserved Tier L gate and automated readability posture."
      : "No same-source deterministic Aster repair candidate passed the preserved performance/readability gate."
  };
}

function repairReport() {
  const validation = repairValidate();
  const evidenceRoot = repairEvidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, repairRuntimeReportName);
  const errors = [...validation.errors];
  if (!existsSync(runtimePath)) {
    throw new Error(`Missing Godot Aster billboard repair runtime report: ${relativeRepo(runtimePath)}`);
  }
  const runtime = readJson(runtimePath);
  const benchmarkRows = runtime.benchmarks ?? [];
  errors.push(...(runtime.errors ?? []));
  for (const approach of repairApproaches) {
    for (const tier of tiers) {
      if (!benchmarkRows.some((row) => row.approach === approach && row.tier === tier)) {
        errors.push(`Missing repair benchmark row ${approach} ${tier}.`);
      }
    }
  }
  for (const approach of repairApproaches) {
    const tierLCount = benchmarkRows.filter((row) => row.approach === approach && row.tier === "L").length;
    if (tierLCount < 5) {
      errors.push(`Expected at least five Tier L trials for ${approach}, found ${tierLCount}.`);
    }
  }
  const screenshotRoot = join(evidenceRoot, "screenshots");
  const screenshots = [];
  for (const capture of runtime.captures ?? []) {
    const path = join(screenshotRoot, capture.fileName);
    if (!existsSync(path)) {
      errors.push(`Missing Aster repair screenshot ${relativeRepo(path)}.`);
      continue;
    }
    screenshots.push({
      ...capture,
      path: relativeRepo(path),
      sha256: sha256File(path),
      width: capture.width ?? 1600,
      height: capture.height ?? 900
    });
  }
  const aggregateRows = aggregateRepairBenchmarks(benchmarkRows);
  const gate = repairThreshold(aggregateRows, benchmarkRows);
  if (!gate.status.startsWith("PASS")) {
    errors.push(gate.reason);
  }
  const derivatives = existsSync(join(repairLocalSlotRoot, `${slotId}_derivative-matrix.json`))
    ? readJson(join(repairLocalSlotRoot, `${slotId}_derivative-matrix.json`))
    : repairDerivativeRecords(false);
  const summary = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0152_ASTER_BILLBOARD_REPAIR_EVIDENCE_RECORDED" : "PASS_V0152_ASTER_BILLBOARD_REPAIR_EVIDENCE_RECORDED",
    errors,
    slotId,
    sourceRuntimeReport: relativeRepo(runtimePath),
    zeroNewAiImagesForV0152: true,
    sameAsterSourceOnly: true,
    sourceImageCount: localSourceCount(),
    noNewRuntimeArtSlot: true,
    derivativeMatrix: derivatives,
    aggregateRows,
    benchmarkRows,
    screenshots,
    threshold: gate,
    scorecard: {
      status: gate.status,
      approaches: repairApproaches,
      tiers,
      aggregateRows
    },
    fairPathAudit: runtime.fairPathAudit,
    readabilityAudit: runtime.readabilityAudit,
    repairSources: runtime.repairSources,
    fallbackSource: runtime.fallbackSource,
    workerContextSource: runtime.workerContextSource,
    barracksContextSource: runtime.barracksContextSource,
    selectedRecommendedDerivative: gate.selectedRecommendedDerivative,
    selectedRecommendedSource: gate.selectedRecommendedSource,
    selectedRecommendedHash: gate.selectedRecommendedHash,
    boundaries: runtime.boundaries,
    limitations: runtime.limitations
  };
  writeJson(join(evidenceRoot, "aster-billboard-repair-evidence.json"), summary);
  writeJson(join(evidenceRoot, "aster-billboard-repair-threshold-report.json"), gate);
  writeJson(join(evidenceRoot, "aster-billboard-repair-scorecard.json"), summary.scorecard);
  writeJson(join(evidenceRoot, "aster-billboard-repair-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    screenshotCount: screenshots.length,
    screenshots
  });
  writeText(join(evidenceRoot, "paired-benchmark-summary.md"), repairBenchmarkMarkdown(summary));
  writeText(join(evidenceRoot, "visual-review-guide.md"), repairVisualReviewMarkdown(summary));
  writeText(join(evidenceRoot, "contact-sheet.svg"), repairContactSheetSvg(screenshots));
  return summary;
}

function repairAudit() {
  const evidenceRoot = repairEvidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, repairRuntimeReportName);
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const auditRecord = runtime?.fairPathAudit ?? {
    runtimeEvidencePresent: false,
    note: "Run the v0.152 headed paired benchmark before collecting runtime audit counters."
  };
  const errors = [];
  if (runtime && auditRecord.localAndFallbackShareAsterBillboardRenderPath !== true) {
    errors.push("Runtime audit did not prove local/fallback Aster path sharing.");
  }
  if (runtime && auditRecord.repeatedTextureCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove texture creation was absent during steady-state frames.");
  }
  if (runtime && auditRecord.repeatedMaterialCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove material creation was absent during steady-state frames.");
  }
  if (runtime && auditRecord.benchmarkExcludesInitializationAndWarmup !== true) {
    errors.push("Runtime audit did not prove initialization/warmup were excluded from measured frames.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT" : "PASS_V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    zeroNewAiImagesForV0152: true,
    sameAsterSourceOnly: true,
    noNewRuntimeArtSlot: true,
    audit: auditRecord,
    errors
  };
  writeJson(join(evidenceRoot, "aster-billboard-repair-fair-path-audit.json"), report);
  return report;
}

function repairBenchmarkMarkdown(summary) {
  const lines = [
    "# v0.152 Aster Billboard Repair Paired Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    `Gate: ${summary.threshold.status}`,
    `Selected recommended derivative: ${summary.selectedRecommendedDerivative ?? "none"}`,
    "",
    "| Approach | Tier | Trials | Mean FPS | Median FPS | p95 ms | p99 ms | Source |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.aggregateRows) {
    lines.push(`| \`${row.approach}\` | \`${row.tier}\` | ${row.trialCount} | ${row.averageFps.mean} | ${row.averageFps.median} | ${row.p95FrameTimeMs.mean} | ${row.p99FrameTimeMs.mean} | ${row.sourceLoaded} |`);
  }
  lines.push("", "Tier L trials:", "");
  lines.push("| Approach | Trial | Avg FPS | p95 ms | p99 ms | Init ms | Source |");
  lines.push("| --- | ---: | ---: | ---: | ---: | ---: | --- |");
  for (const row of summary.benchmarkRows.filter((entry) => entry.tier === "L")) {
    lines.push(`| \`${row.approach}\` | ${row.trialIndex} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.p99FrameTimeMs} | ${row.initializationDurationMs} | ${row.sourceLoaded ?? row.assetSourceLoaded} |`);
  }
  return `${lines.join("\n")}\n`;
}

function repairVisualReviewMarkdown(summary) {
  const lines = [
    "# v0.152 Aster Billboard Repair Visual Review Guide",
    "",
    `Selected recommended derivative: \`${summary.selectedRecommendedDerivative ?? "none"}\`.`,
    `Gate result: \`${summary.threshold.status}\`.`,
    "",
    "Review questions:",
    "",
    "- Does Aster read as the central Commander / Champion, not as a Worker?",
    "- Do checkerboard, dark, and light backgrounds show no obvious halo?",
    "- Do hair, cloak, shoulders, boots, hands, and gear edges hold up?",
    "- Is the foot pivot stable during pan and zoom?",
    "- Does the selection ring remain visible at 0.90x, 1.00x, and 1.10x?",
    "- Do Aster and Worker remain distinct in overlap and normal RTS contexts?",
    "",
    "Capture paths:",
    ""
  ];
  for (const shot of summary.screenshots) {
    lines.push(`- \`${shot.id}\`: \`${shot.path}\``);
  }
  lines.push("", "This is private comparator-only evidence, not production approval, not browser runtime wiring, not normal Salto player-slice integration, and not final Godot selection.");
  return `${lines.join("\n")}\n`;
}

function repairContactSheetSvg(screenshots) {
  const cellWidth = 360;
  const cellHeight = 252;
  const cols = 3;
  const rows = Math.max(1, Math.ceil(screenshots.length / cols));
  const width = cols * cellWidth;
  const height = rows * cellHeight + 48;
  const parts = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<rect width="100%" height="100%" fill="#111511"/>`,
    `<text x="18" y="30" fill="#e7eadc" font-family="Arial" font-size="18">v0.152 Aster billboard repair private comparator contact sheet</text>`
  ];
  screenshots.forEach((shot, index) => {
    const col = index % cols;
    const row = Math.floor(index / cols);
    const x = col * cellWidth + 14;
    const y = row * cellHeight + 52;
    const href = shot.path.replace("artifacts/desktop-spikes/godot-salto/v0152/evidence/", "").replaceAll("&", "&amp;");
    parts.push(`<rect x="${x - 4}" y="${y - 4}" width="336" height="226" fill="#202820" stroke="#465446"/>`);
    parts.push(`<image href="${href}" x="${x}" y="${y}" width="328" height="185" preserveAspectRatio="xMidYMid meet"/>`);
    parts.push(`<text x="${x}" y="${y + 205}" fill="#d8ddce" font-family="Arial" font-size="11">${shot.id}</text>`);
  });
  parts.push("</svg>");
  return `${parts.join("\n")}\n`;
}

function sourceCount(root, suffix = "_source.png") {
  return existsSync(root)
    ? readdirSync(root).filter((name) => name.endsWith(suffix)).length
    : 0;
}

function compositionValidate() {
  const errors = [];
  const requiredFiles = [
    "GODOT_HYBRID_THREE_SLOT_COMPOSITION_STRESS_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
    "tools/godot/asterBillboardSingleSlotTool.mjs",
    "tools/godot/runGodotHybridThreeSlotCompositionValidation.ps1",
    "tools/godot/runGodotHybridThreeSlotCompositionAudit.ps1",
    "tools/godot/runGodotHybridThreeSlotCompositionBenchmarkWindows.ps1",
    "tools/godot/captureGodotHybridThreeSlotCompositionWindows.ps1",
    "docs/V0153_HYBRID_THREE_SLOT_COMPOSITION_STRESS_SPEC.md",
    "docs/V0153_HYBRID_THREE_SLOT_SCORECARD.md",
    "docs/V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT.md",
    "docs/V0153_HYBRID_THREE_SLOT_VISUAL_REVIEW_GUIDE.md",
    "docs/V0153_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0153_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.153 file: ${file}`);
    }
  }
  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const script of [
    "godot:hybrid-three-slot-composition:validate",
    "godot:hybrid-three-slot-composition:audit",
    "godot:hybrid-three-slot-composition:benchmark:headed",
    "godot:hybrid-three-slot-composition:capture"
  ]) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script ${script}.`);
    }
  }
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--hybrid-three-slot-composition-stress") || !rootScript.includes("PASS_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION_DISPATCH")) {
    errors.push("Root script does not expose the private v0.153 composition dispatch.");
  }
  for (const launcher of ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("hybrid-three-slot-composition-stress") || text.includes("HYBRID_THREE_SLOT_COMPOSITION")) {
      errors.push(`${launcher} references the private v0.153 composition stress path.`);
    }
  }
  const selectedAsterPath = repairDerivativePath(1024);
  const workerPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148", "local-worker-slot", "worker_billboard_static_v0147_trimmed_1024.png");
  const barracksPath = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0150", "local-barracks-material-seam-repair", "barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png");
  if (!existsSync(selectedAsterPath) || sha256File(selectedAsterPath) !== selectedAsterRepairHash) {
    errors.push("Missing or hash-mismatched v0.152 selected Aster derivative.");
  }
  if (!existsSync(workerPath) || sha256File(workerPath) !== selectedWorkerHash) {
    errors.push("Missing or hash-mismatched v0.148 selected Worker derivative.");
  }
  if (!existsSync(barracksPath) || sha256File(barracksPath) !== selectedBarracksHash) {
    errors.push("Missing or hash-mismatched v0.150 selected Barracks material repair.");
  }
  const prerequisiteReports = [
    {
      path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148", "evidence", "worker-billboard-repair-threshold-report.json"),
      status: "PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE"
    },
    {
      path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0150", "evidence", "barracks-material-seam-repair-threshold-report.json"),
      status: "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE"
    },
    {
      path: join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0152", "evidence", "aster-billboard-repair-threshold-report.json"),
      status: "PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE"
    }
  ];
  for (const report of prerequisiteReports) {
    if (!existsSync(report.path)) {
      errors.push(`Missing prerequisite report ${relativeRepo(report.path)}.`);
      continue;
    }
    const parsed = readJson(report.path);
    if (parsed.status !== report.status) {
      errors.push(`Prerequisite report ${relativeRepo(report.path)} is ${parsed.status}, expected ${report.status}.`);
    }
  }
  const runtimeTargets = [
    "src",
    "public",
    "index.html",
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "desktop-spikes/godot-salto/scenes",
    "desktop-spikes/godot-salto/project.godot"
  ];
  const runtimeLeak = runtimeTargets.some((target) => {
    const absolute = join(repoRoot, target);
    if (!existsSync(absolute)) {
      return false;
    }
    const stack = [absolute];
    while (stack.length) {
      const current = stack.pop();
      const stats = statSync(current);
      if (stats.isDirectory()) {
        for (const name of readdirSync(current)) {
          stack.push(join(current, name));
        }
      } else if (/\.(ts|tsx|js|jsx|gd|json|html|bat)$/u.test(current)) {
        if (current.endsWith("GodotSaltoSpikeScaffold.test.ts")) {
          continue;
        }
        const text = readFileSync(current, "utf8");
        if (text.includes("hybrid-three-slot-composition-stress") || text.includes("PASS_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION")) {
          return true;
        }
      }
    }
    return false;
  });
  if (runtimeLeak) {
    errors.push("Private v0.153 composition marker leaked into normal runtime/player-slice targets.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: compositionCheckpoint,
    status: errors.length ? "FAIL_V0153_HYBRID_THREE_SLOT_VALIDATION" : "PASS_V0153_HYBRID_THREE_SLOT_VALIDATION",
    errors,
    prerequisiteGates: prerequisiteReports.map((entry) => entry.status),
    selectedAsterHash: selectedAsterRepairHash,
    selectedWorkerHash,
    selectedBarracksHash,
    asterSourceImageCount: localSourceCount(),
    workerV0147SourceImageCount: sourceCount(join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0147", "local-worker-slot")),
    barracksV0149SourceImageCount: sourceCount(join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0149", "local-barracks-material-slot")),
    zeroNewAiImagesForV0153: true,
    zeroNewRuntimeArtSlotsForV0153: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  writeJson(join(compositionEvidenceRootFromArgs(), "hybrid-three-slot-composition-validation.json"), report);
  return report;
}

function aggregateCompositionBenchmarks(rows) {
  const groups = new Map();
  for (const row of rows) {
    const key = `${row.approach}|${row.tier}`;
    const group = groups.get(key) ?? [];
    group.push(row);
    groups.set(key, group);
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
      initializationDurationMs: numberSummary(group.map((row) => Number(row.initializationDurationMs ?? 0))),
      frameCount: group[0]?.frameCount ?? 0,
      entityCount: group[0]?.entityCount ?? 0,
      asterCount: group[0]?.asterCount ?? 0,
      workerContextCount: group[0]?.workerContextCount ?? 0,
      barracksShellCount: group[0]?.barracksShellCount ?? 0,
      billboardInstanceCount: group[0]?.billboardInstanceCount ?? 0,
      renderedObjectProxy: group[0]?.renderedObjectProxy ?? 0,
      sourceLoaded: group[0]?.sourceLoaded ?? group[0]?.assetSourceLoaded ?? "unknown",
      assetHash: group[0]?.assetHash ?? "not-applicable",
      heroReadability: group.every((row) => row.heroReadability !== false && row.asterReadsHeroNotWorker !== false),
      workerDistinct: group.every((row) => row.workerDistinct !== false),
      barracksDistinct: group.every((row) => row.barracksDistinct !== false),
      ringsReadable: group.every((row) => row.ringsReadable !== false && row.selectionRingVisible !== false),
      noObviousHalo: group.every((row) => row.noObviousHalo !== false),
      noSevereSeamOrShimmer: group.every((row) => row.noSevereSeamOrShimmer !== false),
      depthSortingStable: group.every((row) => row.depthSortingStable !== false),
      pivotStable: group.every((row) => row.footPivotStable !== false),
      minimapUnaffected: group.every((row) => row.minimapUnaffected !== false),
      confidence: group[0]?.confidence ?? "local-headed-private-comparator"
    };
  });
}

function compositionThreshold(aggregates, trialRows) {
  const baseline = aggregates.find((row) => row.approach === "HYBRID_THREE_SLOT_FALLBACK_ONLY" && row.tier === "L");
  const selected = aggregates.find((row) => row.approach === "HYBRID_THREE_SLOT_SELECTED_LOCAL" && row.tier === "L");
  const selectedTrials = trialRows.filter((row) => row.approach === "HYBRID_THREE_SLOT_SELECTED_LOCAL" && row.tier === "L");
  const ortho = aggregates.find((row) => row.approach === "ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK" && row.tier === "L");
  const averageFpsRatio = baseline && selected && baseline.averageFps.mean > 0
    ? Number((selected.averageFps.mean / baseline.averageFps.mean).toFixed(4))
    : 0;
  const p95FrameTimeRatio = baseline && selected && baseline.p95FrameTimeMs.mean > 0
    ? Number((selected.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean).toFixed(4))
    : 999;
  const visualPass = selectedTrials.length >= 5 && selectedTrials.every((row) =>
    row.asterReadsHeroNotWorker === true &&
    row.heroReadability !== false &&
    row.workerDistinct === true &&
    row.barracksDistinct === true &&
    row.ringsReadable === true &&
    row.noObviousHalo !== false &&
    row.noSevereSeamOrShimmer === true &&
    row.depthSortingStable === true &&
    row.footPivotStable === true &&
    row.minimapUnaffected === true
  );
  const pass = Boolean(baseline && selected && averageFpsRatio >= 0.9 && p95FrameTimeRatio <= 1.15 && visualPass);
  return {
    status: pass ? "PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE" : "FAIL_V0153_HYBRID_THREE_SLOT_STRESS_GATE",
    gate: {
      averageFpsRatioMinimum: 0.9,
      p95FrameTimeWorseningMaximumRatio: 1.15,
      asterWorkerDistinctRequired: true,
      barracksDistinctRequired: true,
      ringsReadableRequired: true,
      noObviousHaloRequired: true,
      noSevereSeamOrShimmerRequired: true,
      stablePivotRequired: true,
      noPlayerFacingMutationRequired: true,
      visualGateRequiresHumanReview: true
    },
    baseline,
    selected,
    ortho,
    averageFpsRatio,
    averageFpsPass: averageFpsRatio >= 0.9,
    p95FrameTimeRatio,
    p95FrameTimePass: p95FrameTimeRatio <= 1.15,
    visualPass,
    selectedTierLTrials: selectedTrials,
    reason: pass
      ? "Selected local three-slot hybrid passed the private Tier L performance and automated readability gate versus fallback-only hybrid."
      : "Selected local three-slot hybrid did not satisfy the private Tier L performance/readability gate."
  };
}

function compositionReport() {
  const validation = compositionValidate();
  const evidenceRoot = compositionEvidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, compositionRuntimeReportName);
  const errors = [...validation.errors];
  if (!existsSync(runtimePath)) {
    throw new Error(`Missing Godot hybrid three-slot composition runtime report: ${relativeRepo(runtimePath)}`);
  }
  const runtime = readJson(runtimePath);
  const benchmarkRows = runtime.benchmarks ?? [];
  errors.push(...(runtime.errors ?? []));
  for (const approach of compositionApproaches) {
    for (const tier of tiers) {
      if (!benchmarkRows.some((row) => row.approach === approach && row.tier === tier)) {
        errors.push(`Missing composition benchmark row ${approach} ${tier}.`);
      }
    }
    const tierLCount = benchmarkRows.filter((row) => row.approach === approach && row.tier === "L").length;
    if (tierLCount < 5) {
      errors.push(`Expected at least five Tier L trials for ${approach}, found ${tierLCount}.`);
    }
  }
  const screenshotRoot = join(evidenceRoot, "screenshots");
  const screenshots = [];
  for (const capture of runtime.captures ?? []) {
    const path = join(screenshotRoot, capture.fileName);
    if (!existsSync(path)) {
      errors.push(`Missing hybrid three-slot screenshot ${relativeRepo(path)}.`);
      continue;
    }
    screenshots.push({
      ...capture,
      path: relativeRepo(path),
      sha256: sha256File(path),
      width: capture.width ?? 1600,
      height: capture.height ?? 900
    });
  }
  const aggregateRows = aggregateCompositionBenchmarks(benchmarkRows);
  const gate = compositionThreshold(aggregateRows, benchmarkRows);
  if (!gate.status.startsWith("PASS")) {
    errors.push(gate.reason);
  }
  const summary = {
    schemaVersion: 1,
    checkpoint: compositionCheckpoint,
    status: errors.length ? "FAIL_V0153_HYBRID_THREE_SLOT_EVIDENCE_RECORDED" : "PASS_V0153_HYBRID_THREE_SLOT_EVIDENCE_RECORDED",
    errors,
    slotId,
    sourceRuntimeReport: relativeRepo(runtimePath),
    zeroNewAiImagesForV0153: true,
    zeroNewRuntimeArtSlotsForV0153: true,
    privateComparatorOnly: true,
    selectedAsterHash: selectedAsterRepairHash,
    selectedWorkerHash,
    selectedBarracksHash,
    aggregateRows,
    benchmarkRows,
    screenshots,
    threshold: gate,
    scorecard: {
      status: gate.status,
      tiers,
      approaches: compositionApproaches,
      aggregateRows
    },
    fairPathAudit: runtime.fairPathAudit,
    readabilityAudit: runtime.readabilityAudit,
    selectedAsterSource: runtime.selectedAsterSource,
    selectedWorkerSource: runtime.selectedWorkerSource,
    selectedBarracksSource: runtime.selectedBarracksSource,
    fallbackAsterSource: runtime.fallbackAsterSource,
    fallbackWorkerSource: runtime.fallbackWorkerSource,
    fallbackBarracksSource: runtime.fallbackBarracksSource,
    boundaries: runtime.boundaries,
    limitations: runtime.limitations
  };
  writeJson(join(evidenceRoot, "hybrid-three-slot-composition-evidence.json"), summary);
  writeJson(join(evidenceRoot, "hybrid-three-slot-composition-threshold-report.json"), gate);
  writeJson(join(evidenceRoot, "hybrid-three-slot-composition-scorecard.json"), summary.scorecard);
  writeJson(join(evidenceRoot, "hybrid-three-slot-composition-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint: compositionCheckpoint,
    screenshotCount: screenshots.length,
    screenshots
  });
  writeText(join(evidenceRoot, "paired-benchmark-summary.md"), compositionBenchmarkMarkdown(summary));
  writeText(join(evidenceRoot, "visual-review-guide.md"), compositionVisualReviewMarkdown(summary));
  writeText(join(evidenceRoot, "contact-sheet.svg"), compositionContactSheetSvg(screenshots));
  return summary;
}

function compositionAudit() {
  const evidenceRoot = compositionEvidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, compositionRuntimeReportName);
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const auditRecord = runtime?.fairPathAudit ?? {
    runtimeEvidencePresent: false,
    note: "Run the v0.153 headed paired benchmark before collecting runtime audit counters."
  };
  const errors = [];
  if (runtime && auditRecord.localAndFallbackShareAsterBillboardRenderPath !== true) {
    errors.push("Runtime audit did not prove Aster selected/fallback render-path sharing.");
  }
  if (runtime && auditRecord.selectedAndFallbackShareWorkerBillboardRenderPath !== true) {
    errors.push("Runtime audit did not prove Worker selected/fallback render-path sharing.");
  }
  if (runtime && auditRecord.selectedAndFallbackShareBarracksMaterialRenderPath !== true) {
    errors.push("Runtime audit did not prove Barracks selected/fallback material-path sharing.");
  }
  if (runtime && auditRecord.repeatedTextureCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove texture creation was absent during steady-state frames.");
  }
  if (runtime && auditRecord.repeatedMaterialCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove material creation was absent during steady-state frames.");
  }
  if (runtime && auditRecord.metadataParsingDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove metadata parsing was absent during steady-state frames.");
  }
  if (runtime && auditRecord.benchmarkExcludesInitializationAndWarmup !== true) {
    errors.push("Runtime audit did not prove initialization/warmup were excluded from measured frames.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: compositionCheckpoint,
    status: errors.length ? "FAIL_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT" : "PASS_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT",
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    zeroNewAiImagesForV0153: true,
    zeroNewRuntimeArtSlotsForV0153: true,
    audit: auditRecord,
    errors
  };
  writeJson(join(evidenceRoot, "hybrid-three-slot-composition-fair-path-audit.json"), report);
  return report;
}

function compositionBenchmarkMarkdown(summary) {
  const lines = [
    "# v0.153 Hybrid Three-Slot Composition Stress Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    `Gate: ${summary.threshold.status}`,
    "",
    "| Approach | Tier | Trials | Mean FPS | Median FPS | p95 ms | p99 ms | Aster | Worker | Barracks |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"
  ];
  for (const row of summary.aggregateRows) {
    lines.push(`| \`${row.approach}\` | \`${row.tier}\` | ${row.trialCount} | ${row.averageFps.mean} | ${row.averageFps.median} | ${row.p95FrameTimeMs.mean} | ${row.p99FrameTimeMs.mean} | ${row.asterCount} | ${row.workerContextCount} | ${row.barracksShellCount} |`);
  }
  lines.push("", "Tier L trials:", "");
  lines.push("| Approach | Trial | Avg FPS | p95 ms | p99 ms | Init ms | Objects |");
  lines.push("| --- | ---: | ---: | ---: | ---: | ---: | ---: |");
  for (const row of summary.benchmarkRows.filter((entry) => entry.tier === "L")) {
    lines.push(`| \`${row.approach}\` | ${row.trialIndex} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.p99FrameTimeMs} | ${row.initializationDurationMs} | ${row.renderedObjectProxy} |`);
  }
  return `${lines.join("\n")}\n`;
}

function compositionVisualReviewMarkdown(summary) {
  const lines = [
    "# v0.153 Hybrid Three-Slot Composition Visual Review Guide",
    "",
    `Gate result: \`${summary.threshold.status}\`.`,
    "",
    "Review questions:",
    "",
    "- Does Aster stay distinct from repeated Workers?",
    "- Do Worker rings and Aster ring remain readable in crowding and overlap captures?",
    "- Do repeated Barracks shells avoid severe seam, shimmer, or visual mud?",
    "- Do dark, light, checkerboard, wet-overcast, and hearth lighting views avoid obvious halos?",
    "- Does the private minimap probe remain visually separate from the composition stress scene?",
    "",
    "Capture paths:",
    ""
  ];
  for (const shot of summary.screenshots) {
    lines.push(`- \`${shot.id}\`: \`${shot.path}\``);
  }
  lines.push("", "This is private comparator-only evidence, not production approval, not browser runtime wiring, not normal Salto player-slice integration, and not final Godot selection.");
  return `${lines.join("\n")}\n`;
}

function compositionContactSheetSvg(screenshots) {
  const cellWidth = 360;
  const cellHeight = 252;
  const cols = 3;
  const rows = Math.max(1, Math.ceil(screenshots.length / cols));
  const width = cols * cellWidth;
  const height = rows * cellHeight + 48;
  const parts = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<rect width="100%" height="100%" fill="#111511"/>`,
    `<text x="18" y="30" fill="#e7eadc" font-family="Arial" font-size="18">v0.153 hybrid three-slot private composition contact sheet</text>`
  ];
  screenshots.forEach((shot, index) => {
    const col = index % cols;
    const row = Math.floor(index / cols);
    const x = col * cellWidth + 14;
    const y = row * cellHeight + 52;
    const href = shot.path.replace("artifacts/desktop-spikes/godot-salto/v0153/evidence/", "").replaceAll("&", "&amp;");
    parts.push(`<rect x="${x - 4}" y="${y - 4}" width="336" height="226" fill="#202820" stroke="#465446"/>`);
    parts.push(`<image href="${href}" x="${x}" y="${y}" width="328" height="185" preserveAspectRatio="xMidYMid meet"/>`);
    parts.push(`<text x="${x}" y="${y + 205}" fill="#d8ddce" font-family="Arial" font-size="11">${shot.id}</text>`);
  });
  parts.push("</svg>");
  return `${parts.join("\n")}\n`;
}

function printReportAndSetExitCode(result) {
  console.log(stableStringify(result));
  if (String(result.status ?? "").startsWith("FAIL") || (result.errors && result.errors.length > 0)) {
    process.exitCode = 1;
  }
}

const command = process.argv[2] ?? "help";
try {
  if (command === "fallback") {
    printReportAndSetExitCode(fallbackRecord(true));
  } else if (command === "fallback:check") {
    printReportAndSetExitCode(fallbackCheck());
  } else if (command === "metadata") {
    printReportAndSetExitCode(localMetadataRecord(true));
  } else if (command === "validate") {
    printReportAndSetExitCode(validate());
  } else if (command === "report") {
    printReportAndSetExitCode(report());
  } else if (command === "audit") {
    printReportAndSetExitCode(audit());
  } else if (command === "repair:derivatives") {
    printReportAndSetExitCode(repairDerivativeRecords(true));
  } else if (command === "repair:derivatives:check") {
    printReportAndSetExitCode(repairDerivativesCheck());
  } else if (command === "repair:validate") {
    printReportAndSetExitCode(repairValidate());
  } else if (command === "repair:report") {
    printReportAndSetExitCode(repairReport());
  } else if (command === "repair:audit") {
    printReportAndSetExitCode(repairAudit());
  } else if (command === "composition:validate") {
    printReportAndSetExitCode(compositionValidate());
  } else if (command === "composition:report") {
    printReportAndSetExitCode(compositionReport());
  } else if (command === "composition:audit") {
    printReportAndSetExitCode(compositionAudit());
  } else {
    printReportAndSetExitCode({
      status: "FAIL_V0151_ASTER_BILLBOARD_UNKNOWN_COMMAND",
      command,
      knownCommands: ["fallback", "fallback:check", "metadata", "validate", "report", "audit", "repair:derivatives", "repair:derivatives:check", "repair:validate", "repair:report", "repair:audit", "composition:validate", "composition:report", "composition:audit"],
      errors: [`Unknown command: ${command}`]
    });
  }
} catch (error) {
  console.error(error instanceof Error ? error.stack : String(error));
  process.exitCode = 1;
}
