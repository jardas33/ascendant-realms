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
const repairCheckpoint = "v0.148";
const repairArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0148");
const repairLocalSlotRoot = join(repairArtifactRoot, "local-worker-slot");
const repairEvidenceRootDefault = join(repairArtifactRoot, "evidence");
const comparatorRoot = join(repoRoot, "desktop-spikes", "godot-salto", "comparators", "runtime_art_pipeline");
const fallbackRoot = join(comparatorRoot, "fallback");
const fallbackPng = join(fallbackRoot, `${slotId}_fallback.png`);
const fallbackContract = join(fallbackRoot, `${slotId}_fallback.contract.json`);
const localCutout = join(localSlotRoot, `${slotId}.png`);
const localSource = join(localSlotRoot, `${slotId}_source_chromakey.png`);
const localMetadata = join(localSlotRoot, `${slotId}.metadata.json`);
const runtimeReportName = "worker-billboard-single-slot-runtime.json";
const repairRuntimeReportName = "worker-billboard-repair-runtime.json";
const approaches = [
  "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE",
  "HYBRID_LOCAL_WORKER_SLOT",
  "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
];
const repairApproaches = [
  "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE",
  "HYBRID_WORKER_FULL_RES",
  "HYBRID_WORKER_TRIMMED_512",
  "HYBRID_WORKER_TRIMMED_768",
  "HYBRID_WORKER_TRIMMED_1024",
  "ORTHO_3D_MESH_FALLBACK_COMPARATOR"
];
const repairDerivativeSizes = [512, 768, 1024];
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

function repairEvidenceRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : repairEvidenceRootDefault;
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

function repairDerivativePath(size) {
  return join(repairLocalSlotRoot, `${slotId}_trimmed_${size}.png`);
}

function repairDerivativeMetadataPath(size) {
  return join(repairLocalSlotRoot, `${slotId}_trimmed_${size}.metadata.json`);
}

function sourceQualityComparatorRecord() {
  if (!existsSync(localCutout) || !existsSync(localMetadata)) {
    return {
      status: "FAIL_V0148_WORKER_BILLBOARD_SOURCE_QUALITY_COMPARATOR",
      errors: [`Missing v0.147 local source-quality comparator at ${relativeRepo(localCutout)}.`]
    };
  }
  const metadata = readJson(localMetadata);
  const analysis = analyzePngFile(localCutout);
  return {
    status: metadata.sha256 === analysis.sha256 ? "PASS_V0148_WORKER_BILLBOARD_SOURCE_QUALITY_COMPARATOR" : "FAIL_V0148_WORKER_BILLBOARD_SOURCE_QUALITY_COMPARATOR",
    errors: metadata.sha256 === analysis.sha256 ? [] : ["v0.147 local full-resolution metadata hash does not match current cutout."],
    derivativeKind: "source-quality-full-resolution",
    sourceKind: "local-worker-fullres",
    path: relativeRepo(localCutout),
    metadataPath: relativeRepo(localMetadata),
    sha256: analysis.sha256,
    dimensions: { width: analysis.width, height: analysis.height },
    alphaPosture: metadata.alphaPosture ?? "matte-to-alpha-transparent-png; original chroma source preserved",
    trimBounds: analysis.trimBounds,
    pivot: analysis.pivot,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
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

function applyTransparentColorBleed(rgba, width, height, iterations = 2) {
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
  let greenFringePixels = 0;
  let partialEdgePixels = 0;
  let opaqueEdgePixels = 0;
  for (let y = 0; y < decoded.height; y += 1) {
    for (let x = 0; x < decoded.width; x += 1) {
      const index = (y * decoded.width + x) * 4;
      const alpha = decoded.rgba[index + 3];
      if (alpha > 0 && alpha < 245) {
        partialEdgePixels += 1;
        const red = decoded.rgba[index];
        const green = decoded.rgba[index + 1];
        const blue = decoded.rgba[index + 2];
        if (green > red + 48 && green > blue + 48) {
          greenFringePixels += 1;
        }
      } else if (alpha >= 245) {
        opaqueEdgePixels += 1;
      }
    }
  }
  return {
    partialEdgePixels,
    opaqueEdgePixels,
    greenFringePixels,
    greenFringeRatio: partialEdgePixels > 0 ? Number((greenFringePixels / partialEdgePixels).toFixed(4)) : 0
  };
}

function createRepairDerivativeBuffer(targetSize) {
  const source = decodePng(readFileSync(localCutout));
  const sourceAnalysis = analyzePngBuffer(readFileSync(localCutout));
  const trim = sourceAnalysis.trimBounds;
  if (!trim) {
    throw new Error("Cannot create Worker derivative because source alpha trim bounds are empty.");
  }
  const rgba = Buffer.alloc(targetSize * targetSize * 4);
  const maxContentWidth = targetSize * 0.78;
  const maxContentHeight = targetSize * 0.92;
  const scale = Math.min(maxContentWidth / trim.width, maxContentHeight / trim.height);
  const drawWidth = trim.width * scale;
  const drawHeight = trim.height * scale;
  const destLeft = (targetSize - drawWidth) / 2;
  const destTop = targetSize * 0.965 - drawHeight;
  for (let y = 0; y < targetSize; y += 1) {
    for (let x = 0; x < targetSize; x += 1) {
      const sourceX = trim.left + (x - destLeft + 0.5) / scale - 0.5;
      const sourceY = trim.top + (y - destTop + 0.5) / scale - 0.5;
      if (sourceX < trim.left || sourceX > trim.right || sourceY < trim.top || sourceY > trim.bottom) {
        continue;
      }
      const pixel = samplePremultipliedBilinear(source, sourceX, sourceY);
      const index = (y * targetSize + x) * 4;
      rgba[index] = pixel[0];
      rgba[index + 1] = pixel[1];
      rgba[index + 2] = pixel[2];
      rgba[index + 3] = pixel[3];
    }
  }
  applyTransparentColorBleed(rgba, targetSize, targetSize, 2);
  return encodePng(targetSize, targetSize, rgba);
}

function repairDerivativeRecord(size, write) {
  const buffer = createRepairDerivativeBuffer(size);
  const analysis = analyzePngBuffer(buffer);
  const decoded = decodePng(buffer);
  const sourceAnalysis = analyzePngFile(localCutout);
  const sha256 = sha256Bytes(buffer);
  const imagePath = repairDerivativePath(size);
  const metadataPath = repairDerivativeMetadataPath(size);
  const metadata = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    slotId,
    derivativeKind: `trimmed-${size}`,
    sourcePath: relativeRepo(localCutout),
    sourceSha256: sourceAnalysis.sha256,
    generatedBy: "tools/godot/workerBillboardSingleSlotTool.mjs repair:derivatives",
    generationScriptVersion: "v0148-worker-billboard-repair-derivative-v1",
    deterministicOperations: [
      "alpha-bounds trim",
      "premultiplied-alpha deterministic resize",
      "transparent padding for bottom-center pivot stability",
      "transparent RGB alpha-edge bleed"
    ],
    sha256,
    dimensions: { width: analysis.width, height: analysis.height },
    alphaPosture: "trimmed-resized-transparent-png-with-deterministic-alpha-edge-bleed",
    alphaEdgeStats: alphaEdgeStats(decoded),
    trimBounds: analysis.trimBounds,
    pivot: analysis.pivot,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden",
    humanReviewStatus: "pending-review"
  };
  if (write) {
    mkdirSync(repairLocalSlotRoot, { recursive: true });
    writeFileSync(imagePath, buffer);
    writeJson(metadataPath, metadata);
  }
  return {
    status: "PASS_V0148_WORKER_BILLBOARD_DERIVATIVE_GENERATED",
    path: relativeRepo(imagePath),
    metadataPath: relativeRepo(metadataPath),
    byteLength: buffer.length,
    ...metadata
  };
}

function repairDerivativeRecords(write) {
  const errors = [];
  if (!existsSync(localSource)) {
    errors.push(`Missing original generated source: ${relativeRepo(localSource)}`);
  }
  if (!existsSync(localCutout)) {
    errors.push(`Missing existing matte-to-alpha Worker cutout: ${relativeRepo(localCutout)}`);
  }
  if (!existsSync(localMetadata)) {
    errors.push(`Missing existing Worker metadata: ${relativeRepo(localMetadata)}`);
  }
  if (errors.length) {
    return {
      schemaVersion: 1,
      checkpoint: repairCheckpoint,
      status: "FAIL_V0148_WORKER_BILLBOARD_DERIVATIVE_GENERATION",
      errors
    };
  }
  const sourceQuality = sourceQualityComparatorRecord();
  const derivatives = repairDerivativeSizes.map((size) => repairDerivativeRecord(size, write));
  const report = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: "PASS_V0148_WORKER_BILLBOARD_DERIVATIVE_GENERATION",
    errors: sourceQuality.errors ?? [],
    sourceQualityComparator: sourceQuality,
    derivatives,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  if (write) {
    writeJson(join(repairLocalSlotRoot, `${slotId}_derivative-matrix.json`), report);
  }
  return report;
}

function repairDerivativesCheck() {
  const generated = repairDerivativeRecords(false);
  const errors = [...(generated.errors ?? [])];
  for (const derivative of generated.derivatives ?? []) {
    const imagePath = join(repoRoot, derivative.path);
    const metadataPath = join(repoRoot, derivative.metadataPath);
    if (!existsSync(imagePath)) {
      errors.push(`Missing derivative image: ${derivative.path}`);
      continue;
    }
    const actualHash = sha256File(imagePath);
    if (actualHash !== derivative.sha256) {
      errors.push(`Derivative hash mismatch for ${derivative.path}.`);
    }
    if (!existsSync(metadataPath)) {
      errors.push(`Missing derivative metadata: ${derivative.metadataPath}`);
      continue;
    }
    const metadata = readJson(metadataPath);
    if (metadata.sha256 !== actualHash) {
      errors.push(`Derivative metadata hash mismatch for ${derivative.metadataPath}.`);
    }
    if (metadata.privateComparatorOnly !== true || metadata.productionApproval !== "forbidden") {
      errors.push(`Derivative metadata boundary flags are invalid for ${derivative.metadataPath}.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0148_WORKER_BILLBOARD_DERIVATIVE_REPRODUCIBILITY" : "PASS_V0148_WORKER_BILLBOARD_DERIVATIVE_REPRODUCIBILITY",
    errors,
    derivatives: generated.derivatives ?? [],
    sourceQualityComparator: generated.sourceQualityComparator
  };
  writeJson(join(repairEvidenceRootFromArgs(), "worker-billboard-repair-derivative-reproducibility.json"), report);
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

function repairValidate() {
  const errors = [];
  const requiredFiles = [
    "GODOT_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png",
    "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json",
    "tools/godot/workerBillboardSingleSlotTool.mjs",
    "tools/godot/runGodotWorkerBillboardRepairValidation.ps1",
    "tools/godot/runGodotWorkerBillboardRepairAudit.ps1",
    "tools/godot/runGodotWorkerBillboardRepairDerivatives.ps1",
    "tools/godot/runGodotWorkerBillboardRepairBenchmarkWindows.ps1",
    "tools/godot/captureGodotWorkerBillboardRepairWindows.ps1",
    "docs/V0148_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_SPEC.md",
    "docs/V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT.md",
    "docs/V0148_WORKER_BILLBOARD_DERIVATIVE_MATRIX.md",
    "docs/V0148_WORKER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md",
    "docs/V0148_WORKER_BILLBOARD_ALPHA_PIVOT_REVIEW_GUIDE.md",
    "docs/V0148_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
    "docs/V0148_IMPLEMENTATION_REPORT.md"
  ];
  for (const file of requiredFiles) {
    if (!existsSync(join(repoRoot, file))) {
      errors.push(`Missing required v0.148 file: ${file}`);
    }
  }
  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const script of [
    "godot:worker-billboard-repair:validate",
    "godot:worker-billboard-repair:audit",
    "godot:worker-billboard-repair:derivatives:reproduce",
    "godot:worker-billboard-repair:benchmark:headed",
    "godot:worker-billboard-repair:capture"
  ]) {
    if (typeof packageJson.scripts?.[script] !== "string") {
      errors.push(`Missing package script: ${script}`);
    }
  }
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--worker-billboard-single-slot-repair")) {
    errors.push("Root script does not expose private --worker-billboard-single-slot-repair dispatch.");
  }
  for (const launcher of ["GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat"]) {
    const text = readFileSync(join(repoRoot, launcher), "utf8");
    if (text.includes("worker-billboard-single-slot-repair") || text.includes("WORKER_BILLBOARD_SINGLE_SLOT_REPAIR")) {
      errors.push(`${launcher} references the private v0.148 Worker repair experiment.`);
    }
  }
  const fallback = fallbackCheck();
  errors.push(...fallback.errors);
  const derivatives = repairDerivativesCheck();
  errors.push(...derivatives.errors);
  const report = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0148_WORKER_BILLBOARD_REPAIR_VALIDATION" : "PASS_V0148_WORKER_BILLBOARD_REPAIR_VALIDATION",
    errors,
    fallback,
    derivatives,
    zeroNewAiImages: true,
    existingWorkerSourceOnly: true,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  writeJson(join(repairEvidenceRootFromArgs(), "worker-billboard-repair-validation.json"), report);
  return report;
}

function numberSummary(values) {
  const sorted = values.filter((value) => Number.isFinite(value)).sort((left, right) => left - right);
  if (!sorted.length) {
    return { mean: 0, median: 0, min: 0, max: 0, spread: 0 };
  }
  const sum = sorted.reduce((total, value) => total + value, 0);
  const middle = Math.floor(sorted.length / 2);
  const median = sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
  return {
    mean: Number((sum / sorted.length).toFixed(2)),
    median: Number(median.toFixed(2)),
    min: Number(sorted[0].toFixed(2)),
    max: Number(sorted[sorted.length - 1].toFixed(2)),
    spread: Number((sorted[sorted.length - 1] - sorted[0]).toFixed(2))
  };
}

function aggregateRepairBenchmarks(rows) {
  const groups = new Map();
  for (const row of rows) {
    const key = `${row.approach}|${row.tier}`;
    const existing = groups.get(key) ?? [];
    existing.push(row);
    groups.set(key, existing);
  }
  return Array.from(groups.entries()).map(([key, groupRows]) => {
    const [approach, tier] = key.split("|");
    const fps = numberSummary(groupRows.map((row) => row.averageFps));
    const p95 = numberSummary(groupRows.map((row) => row.p95FrameTimeMs));
    const p99 = numberSummary(groupRows.map((row) => row.p99FrameTimeMs));
    const duration = numberSummary(groupRows.map((row) => row.benchmarkDurationMs));
    return {
      approach,
      tier,
      trialCount: groupRows.length,
      averageFps: fps,
      p95FrameTimeMs: p95,
      p99FrameTimeMs: p99,
      benchmarkDurationMs: duration,
      frameCount: groupRows[0]?.frameCount ?? 0,
      entityCount: groupRows[0]?.entityCount ?? 0,
      billboardInstanceCount: groupRows[0]?.billboardInstanceCount ?? 0,
      renderedObjectProxy: groupRows[0]?.renderedObjectProxy ?? 0,
      animationUpdateProxy: groupRows[0]?.animationUpdateProxy ?? 0,
      assetSourceLoaded: groupRows[0]?.assetSourceLoaded ?? "unknown",
      assetHash: groupRows[0]?.assetHash ?? "unknown",
      derivativeDimensions: groupRows[0]?.derivativeDimensions ?? {},
      initializationDurationMs: numberSummary(groupRows.map((row) => row.initializationDurationMs ?? 0)),
      steadyStateWarmupFrames: groupRows[0]?.steadyStateWarmupFrames ?? 0
    };
  });
}

function sourceRank(approach) {
  return {
    HYBRID_WORKER_TRIMMED_1024: 4,
    HYBRID_WORKER_TRIMMED_768: 3,
    HYBRID_WORKER_TRIMMED_512: 2,
    HYBRID_WORKER_FULL_RES: 1
  }[approach] ?? 0;
}

function repairThreshold(aggregates, trialRows) {
  const baseline = aggregates.find((row) => row.approach === "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE" && row.tier === "L");
  const candidateApproaches = [
    "HYBRID_WORKER_FULL_RES",
    "HYBRID_WORKER_TRIMMED_512",
    "HYBRID_WORKER_TRIMMED_768",
    "HYBRID_WORKER_TRIMMED_1024"
  ];
  const candidates = candidateApproaches
    .map((approach) => {
      const aggregate = aggregates.find((row) => row.approach === approach && row.tier === "L");
      if (!baseline || !aggregate) {
        return null;
      }
      const averageFpsRatio = Number((aggregate.averageFps.mean / baseline.averageFps.mean).toFixed(4));
      const p95FrameTimeRatio = Number((aggregate.p95FrameTimeMs.mean / baseline.p95FrameTimeMs.mean).toFixed(4));
      return {
        approach,
        assetSourceLoaded: aggregate.assetSourceLoaded,
        assetHash: aggregate.assetHash,
        derivativeDimensions: aggregate.derivativeDimensions,
        averageFpsRatio,
        p95FrameTimeRatio,
        averageFpsPass: averageFpsRatio >= 0.9,
        p95FrameTimePass: p95FrameTimeRatio <= 1.15,
        baselineAverageFpsMean: baseline.averageFps.mean,
        candidateAverageFpsMean: aggregate.averageFps.mean,
        baselineP95FrameTimeMeanMs: baseline.p95FrameTimeMs.mean,
        candidateP95FrameTimeMeanMs: aggregate.p95FrameTimeMs.mean,
        p95FrameTimeAbsoluteDeltaMs: Number((aggregate.p95FrameTimeMs.mean - baseline.p95FrameTimeMs.mean).toFixed(4)),
        tierLTrials: trialRows.filter((row) => row.tier === "L" && row.approach === approach)
      };
    })
    .filter(Boolean);
  const passing = candidates
    .filter((candidate) => candidate.averageFpsPass && candidate.p95FrameTimePass)
    .sort((left, right) => sourceRank(right.approach) - sourceRank(left.approach) || right.averageFpsRatio - left.averageFpsRatio);
  const selected = passing[0] ?? null;
  return {
    status: selected ? "PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE" : "FAIL_V0148_WORKER_BILLBOARD_ORIGINAL_GATE",
    gate: {
      averageFpsRatioMinimum: 0.9,
      p95FrameTimeWorseningMaximumRatio: 1.15,
      p95AbsoluteDeltaIsContextOnly: true
    },
    baseline,
    candidates: candidates.map(({ tierLTrials, ...candidate }) => candidate),
    selectedRecommendedDerivative: selected ? selected.approach : null,
    selectedRecommendedSource: selected ? selected.assetSourceLoaded : null,
    selectedRecommendedHash: selected ? selected.assetHash : null,
    selectedRecommendedDimensions: selected ? selected.derivativeDimensions : null
  };
}

function repairReport() {
  const evidenceRoot = repairEvidenceRootFromArgs();
  const rawPath = join(evidenceRoot, repairRuntimeReportName);
  if (!existsSync(rawPath)) {
    throw new Error(`Missing Godot Worker billboard repair runtime report: ${relativeRepo(rawPath)}`);
  }
  const raw = readJson(rawPath);
  const errors = [];
  const benchmarkRows = raw.benchmarks ?? [];
  for (const approach of repairApproaches) {
    for (const tier of tiers) {
      if (!benchmarkRows.some((row) => row.approach === approach && row.tier === tier)) {
        errors.push(`Missing paired benchmark row ${approach} ${tier}.`);
      }
    }
  }
  const tierLTrialRows = benchmarkRows.filter((row) => row.tier === "L");
  for (const approach of repairApproaches.filter((approach) => approach !== "ORTHO_3D_MESH_FALLBACK_COMPARATOR")) {
    const count = tierLTrialRows.filter((row) => row.approach === approach).length;
    if (count < 5) {
      errors.push(`Expected at least 5 Tier L trials for ${approach}, found ${count}.`);
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
      sha256: sha256File(path),
      width: capture.width,
      height: capture.height,
      approach: capture.approach,
      tier: capture.tier ?? null,
      view: capture.view ?? "benchmark",
      scaleMultiplier: capture.scaleMultiplier ?? null,
      assetSourceLoaded: capture.assetSourceLoaded ?? null,
      assetHash: capture.assetHash ?? null
    });
  }
  const aggregates = aggregateRepairBenchmarks(benchmarkRows);
  const threshold = repairThreshold(aggregates, benchmarkRows);
  const derivatives = existsSync(join(repairLocalSlotRoot, `${slotId}_derivative-matrix.json`))
    ? readJson(join(repairLocalSlotRoot, `${slotId}_derivative-matrix.json`))
    : repairDerivativeRecords(false);
  const summary = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0148_WORKER_BILLBOARD_REPAIR_EVIDENCE_RECORDED" : "PASS_V0148_WORKER_BILLBOARD_REPAIR_EVIDENCE_RECORDED",
    errors,
    slotId,
    sourceRuntimeReport: relativeRepo(rawPath),
    fairPathAudit: raw.fairPathAudit ?? {},
    derivatives,
    benchmarkRows,
    aggregateRows: aggregates,
    threshold,
    selectedRecommendedDerivative: threshold.selectedRecommendedDerivative,
    selectedRecommendedSource: threshold.selectedRecommendedSource,
    screenshots,
    alphaPivotReview: raw.alphaPivotReview ?? {},
    preferredScalePosture: raw.preferredScalePosture ?? {},
    boundaries: raw.boundaries ?? {},
    limitations: raw.limitations ?? []
  };
  writeJson(join(evidenceRoot, "worker-billboard-repair-evidence.json"), summary);
  writeJson(join(evidenceRoot, "worker-billboard-repair-threshold-report.json"), threshold);
  writeJson(join(evidenceRoot, "worker-billboard-repair-derivative-matrix.json"), derivatives);
  writeJson(join(evidenceRoot, "worker-billboard-repair-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    screenshotCount: screenshots.length,
    screenshots
  });
  writeText(join(evidenceRoot, "paired-benchmark-summary.md"), repairBenchmarkMarkdown(summary));
  writeText(join(evidenceRoot, "alpha-pivot-review-guide.md"), repairVisualReviewMarkdown(summary));
  writeText(join(evidenceRoot, "contact-sheet.svg"), repairContactSheetSvg(screenshots));
  return summary;
}

function repairAudit() {
  const evidenceRoot = repairEvidenceRootFromArgs();
  const runtimePath = join(evidenceRoot, repairRuntimeReportName);
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const audit = runtime?.fairPathAudit ?? {
    runtimeEvidencePresent: false,
    note: "Run the headed paired benchmark before collecting runtime audit counters."
  };
  const errors = [];
  if (runtime && audit.repeatedTextureCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove texture creation was absent during steady-state frames.");
  }
  if (runtime && audit.repeatedMaterialCreateDuringSteadyState !== false) {
    errors.push("Runtime audit did not prove material creation was absent during steady-state frames.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: repairCheckpoint,
    status: errors.length ? "FAIL_V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT" : "PASS_V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT",
    errors,
    audit,
    privateComparatorOnly: true,
    productionApproval: "forbidden",
    playerSliceIntegration: "forbidden",
    browserIntegration: "forbidden"
  };
  writeJson(join(evidenceRoot, "worker-billboard-repair-fair-path-audit.json"), report);
  return report;
}

function repairBenchmarkMarkdown(summary) {
  const lines = [
    "# v0.148 Worker Billboard Repair Paired Benchmark Summary",
    "",
    `Status: ${summary.status}`,
    `Original gate: ${summary.threshold.status}`,
    `Selected recommended derivative: ${summary.selectedRecommendedDerivative ?? "none"}`,
    "",
    "| Approach | Tier | Trials | Mean FPS | Median FPS | Min FPS | Max FPS | FPS spread | Mean p95 ms | Mean p99 ms | Source |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  for (const row of summary.aggregateRows) {
    lines.push(`| ${row.approach} | ${row.tier} | ${row.trialCount} | ${row.averageFps.mean} | ${row.averageFps.median} | ${row.averageFps.min} | ${row.averageFps.max} | ${row.averageFps.spread} | ${row.p95FrameTimeMs.mean} | ${row.p99FrameTimeMs.mean} | ${row.assetSourceLoaded} |`);
  }
  lines.push("", "Tier L trials:", "");
  lines.push("| Approach | Trial | Avg FPS | p95 ms | p99 ms | Init ms | Duration ms | Source |");
  lines.push("| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |");
  for (const row of summary.benchmarkRows.filter((entry) => entry.tier === "L")) {
    lines.push(`| ${row.approach} | ${row.trialIndex} | ${row.averageFps} | ${row.p95FrameTimeMs} | ${row.p99FrameTimeMs} | ${row.initializationDurationMs} | ${row.benchmarkDurationMs} | ${row.assetSourceLoaded} |`);
  }
  return `${lines.join("\n")}\n`;
}

function repairVisualReviewMarkdown(summary) {
  const lines = [
    "# v0.148 Worker Billboard Repair Alpha / Pivot Review Packet",
    "",
    `Selected recommended derivative: ${summary.selectedRecommendedDerivative ?? "none"}.`,
    `Original gate result: ${summary.threshold.status}.`,
    "",
    "Review questions:",
    "",
    "- Did a repeated-load, material, or benchmark-method issue exist?",
    "- Which derivative is recommended and why?",
    "- Does the Worker read clearly at gameplay distance?",
    "- Does the Builder / camp-hand / repair-support role come through?",
    "- Is any matte halo visible?",
    "- Is the foot pivot stable?",
    "- Is selection-ring room adequate?",
    "- Does repeated-worker overlap remain readable?",
    "- Is 0.90x, 1.00x, or 1.10x the best runtime scale posture?",
    "- Did the selected derivative pass the original Tier L gate?",
    "- Should the next milestone test Aster static billboard, one environment / structure slot, one further Worker repair, or ORTHO_3D_MESH fallback?",
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

function repairContactSheetSvg(screenshots) {
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
      const href = shot.path.replace("artifacts/desktop-spikes/godot-salto/v0148/evidence/", "");
      return `<g>
  <image href="${href}" x="${x}" y="${y}" width="${cellWidth - 20}" height="${cellHeight - 44}" preserveAspectRatio="xMidYMid meet"/>
  <text x="${x}" y="${y + cellHeight - 24}" fill="#e8eadf" font-family="Arial" font-size="12">${shot.id}</text>
  <text x="${x}" y="${y + cellHeight - 8}" fill="#aab7aa" font-family="Arial" font-size="11">${shot.assetSourceLoaded ?? "source n/a"}</text>
</g>`;
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#111611"/>
<text x="${margin}" y="18" fill="#dce8d8" font-family="Arial" font-size="14">v0.148 Worker billboard repair private comparator captures</text>
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
  } else if (command === "repair:derivatives") {
    printReportAndSetExitCode(repairDerivativeRecords(true));
  } else if (command === "repair:derivatives:check") {
    printReportAndSetExitCode(repairDerivativesCheck());
  } else if (command === "repair:validate") {
    printReportAndSetExitCode(repairValidate());
  } else if (command === "repair:audit") {
    printReportAndSetExitCode(repairAudit());
  } else if (command === "repair:report") {
    printReportAndSetExitCode(repairReport());
  } else {
    console.log("Usage: node tools/godot/workerBillboardSingleSlotTool.mjs <fallback|fallback:check|local-metadata|validate|report|repair:derivatives|repair:derivatives:check|repair:validate|repair:audit|repair:report> [--artifact-root=<path>]");
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
