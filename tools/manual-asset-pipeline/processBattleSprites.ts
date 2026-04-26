import { access, mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import zlib from "node:zlib";
import { ASSET_REGISTRY, type ManualAssetEntry } from "./assetRegistry.ts";

interface RgbaImage {
  width: number;
  height: number;
  data: Uint8Array;
}

const manualDir = path.join(process.cwd(), "public", "assets", "manual");
const finalDir = path.join(process.cwd(), "public", "assets", "final");
const processableCategories = new Set(["unit_sprite", "building_sprite", "unit_concept", "building_concept"]);
const supportedImageExtensions = new Set([".png"]);
const threshold = readThreshold();

async function main(): Promise<void> {
  let processed = 0;
  let skipped = 0;

  for (const asset of ASSET_REGISTRY.filter((entry) => processableCategories.has(entry.category))) {
    const source = await findManualAsset(asset);
    if (!source) {
      skipped += 1;
      continue;
    }

    const input = decodePng(await readFile(source.filePath));
    const removed = removeConnectedBackground(input, threshold);
    const fitted = fitToCanvas(removed.image, asset.preferredWidth, asset.preferredHeight);
    const targetDir = path.join(finalDir, asset.targetFolder);
    const targetPath = path.join(targetDir, asset.filename);

    await mkdir(targetDir, { recursive: true });
    await writeFile(targetPath, encodePng(fitted));

    processed += 1;
    console.log(
      `${asset.filename}: ${path.relative(process.cwd(), source.filePath)} -> ${path.relative(
        process.cwd(),
        targetPath
      )} (${input.width}x${input.height} to ${fitted.width}x${fitted.height}, removed ${removed.removedPixels} bg px)`
    );
  }

  console.log(`Processed ${processed} battle/concept assets. Skipped ${skipped} missing assets.`);
}

async function findManualAsset(
  asset: ManualAssetEntry
): Promise<{ filePath: string; filename: string } | null> {
  const sourceDir = path.join(manualDir, asset.targetFolder);
  const exactPath = path.join(sourceDir, asset.filename);
  if (await exists(exactPath)) {
    return { filePath: exactPath, filename: asset.filename };
  }

  const entries = await readdir(sourceDir, { withFileTypes: true }).catch(() => []);
  const files = entries
    .filter((entry) => entry.isFile() && supportedImageExtensions.has(path.extname(entry.name).toLowerCase()))
    .map((entry) => entry.name);

  const caseInsensitiveExact = files.find((filename) => filename.toLowerCase() === asset.filename.toLowerCase());
  if (caseInsensitiveExact) {
    return { filePath: path.join(sourceDir, caseInsensitiveExact), filename: caseInsensitiveExact };
  }

  const desiredNames = new Set([
    normalizeName(path.parse(asset.filename).name),
    normalizeName(asset.displayName),
    normalizeName(asset.id)
  ]);
  const friendlyFilename = files.find((filename) => desiredNames.has(normalizeName(path.parse(filename).name)));
  return friendlyFilename ? { filePath: path.join(sourceDir, friendlyFilename), filename: friendlyFilename } : null;
}

function removeConnectedBackground(image: RgbaImage, distanceThreshold: number): { image: RgbaImage; removedPixels: number } {
  const { width, height, data } = image;
  const output = new Uint8Array(data);
  const visited = new Uint8Array(width * height);
  const stack: number[] = [];
  const samples = sampleEdgeColors(image);
  const thresholdSquared = distanceThreshold * distanceThreshold;
  const relaxedThresholdSquared = (distanceThreshold + 24) * (distanceThreshold + 24);

  const seedIfBackground = (x: number, y: number): void => {
    const index = y * width + x;
    if (!visited[index] && isBackgroundLike(data, index, samples, thresholdSquared)) {
      visited[index] = 1;
      stack.push(index);
    }
  };

  for (let x = 0; x < width; x += 1) {
    seedIfBackground(x, 0);
    seedIfBackground(x, height - 1);
  }
  for (let y = 1; y < height - 1; y += 1) {
    seedIfBackground(0, y);
    seedIfBackground(width - 1, y);
  }

  while (stack.length > 0) {
    const index = stack.pop() as number;
    const x = index % width;
    const y = Math.floor(index / width);
    const neighbors = [
      x > 0 ? index - 1 : -1,
      x < width - 1 ? index + 1 : -1,
      y > 0 ? index - width : -1,
      y < height - 1 ? index + width : -1
    ];

    for (const next of neighbors) {
      if (next >= 0 && !visited[next] && isBackgroundLike(data, next, samples, thresholdSquared)) {
        visited[next] = 1;
        stack.push(next);
      }
    }
  }

  for (let pass = 0; pass < 2; pass += 1) {
    for (let index = 0; index < visited.length; index += 1) {
      if (visited[index] || !isBackgroundLike(data, index, samples, relaxedThresholdSquared)) {
        continue;
      }
      const x = index % width;
      const y = Math.floor(index / width);
      const touchesBackground =
        (x > 0 && visited[index - 1]) ||
        (x < width - 1 && visited[index + 1]) ||
        (y > 0 && visited[index - width]) ||
        (y < height - 1 && visited[index + width]);
      if (touchesBackground) {
        visited[index] = 1;
      }
    }
  }

  let removedPixels = 0;
  for (let index = 0; index < visited.length; index += 1) {
    if (!visited[index]) {
      continue;
    }
    const offset = index * 4;
    output[offset] = 0;
    output[offset + 1] = 0;
    output[offset + 2] = 0;
    output[offset + 3] = 0;
    removedPixels += 1;
  }

  return { image: { width, height, data: output }, removedPixels };
}

function fitToCanvas(image: RgbaImage, targetWidth: number, targetHeight: number): RgbaImage {
  const bounds = findAlphaBounds(image);
  if (!bounds) {
    return { width: targetWidth, height: targetHeight, data: new Uint8Array(targetWidth * targetHeight * 4) };
  }

  const output = new Uint8Array(targetWidth * targetHeight * 4);
  const sourceWidth = bounds.maxX - bounds.minX + 1;
  const sourceHeight = bounds.maxY - bounds.minY + 1;
  const scale = Math.min((targetWidth * 0.86) / sourceWidth, (targetHeight * 0.86) / sourceHeight);
  const drawWidth = sourceWidth * scale;
  const drawHeight = sourceHeight * scale;
  const offsetX = (targetWidth - drawWidth) / 2;
  const offsetY = (targetHeight - drawHeight) / 2;

  for (let y = 0; y < targetHeight; y += 1) {
    const sourceY = (y - offsetY) / scale + bounds.minY;
    if (sourceY < bounds.minY || sourceY > bounds.maxY) {
      continue;
    }
    for (let x = 0; x < targetWidth; x += 1) {
      const sourceX = (x - offsetX) / scale + bounds.minX;
      if (sourceX < bounds.minX || sourceX > bounds.maxX) {
        continue;
      }
      sampleBilinearPremultiplied(image, sourceX, sourceY, output, (y * targetWidth + x) * 4);
    }
  }

  return { width: targetWidth, height: targetHeight, data: output };
}

function findAlphaBounds(image: RgbaImage): { minX: number; minY: number; maxX: number; maxY: number } | null {
  let minX = image.width;
  let minY = image.height;
  let maxX = -1;
  let maxY = -1;

  for (let y = 0; y < image.height; y += 1) {
    for (let x = 0; x < image.width; x += 1) {
      const alpha = image.data[(y * image.width + x) * 4 + 3];
      if (alpha <= 8) {
        continue;
      }
      minX = Math.min(minX, x);
      minY = Math.min(minY, y);
      maxX = Math.max(maxX, x);
      maxY = Math.max(maxY, y);
    }
  }

  return maxX >= 0 ? { minX, minY, maxX, maxY } : null;
}

function sampleBilinearPremultiplied(image: RgbaImage, x: number, y: number, output: Uint8Array, outputOffset: number): void {
  const x0 = Math.max(0, Math.min(image.width - 1, Math.floor(x)));
  const y0 = Math.max(0, Math.min(image.height - 1, Math.floor(y)));
  const x1 = Math.max(0, Math.min(image.width - 1, x0 + 1));
  const y1 = Math.max(0, Math.min(image.height - 1, y0 + 1));
  const tx = x - x0;
  const ty = y - y0;
  const weights = [
    [x0, y0, (1 - tx) * (1 - ty)],
    [x1, y0, tx * (1 - ty)],
    [x0, y1, (1 - tx) * ty],
    [x1, y1, tx * ty]
  ] as const;

  let r = 0;
  let g = 0;
  let b = 0;
  let a = 0;

  for (const [sampleX, sampleY, weight] of weights) {
    const offset = (sampleY * image.width + sampleX) * 4;
    const alpha = image.data[offset + 3] / 255;
    r += image.data[offset] * alpha * weight;
    g += image.data[offset + 1] * alpha * weight;
    b += image.data[offset + 2] * alpha * weight;
    a += alpha * weight;
  }

  if (a <= 0.001) {
    return;
  }

  output[outputOffset] = clampByte(r / a);
  output[outputOffset + 1] = clampByte(g / a);
  output[outputOffset + 2] = clampByte(b / a);
  output[outputOffset + 3] = clampByte(a * 255);
}

function sampleEdgeColors(image: RgbaImage): Array<[number, number, number]> {
  const samples: Array<[number, number, number]> = [];
  const points: Array<[number, number]> = [
    [0, 0],
    [image.width - 1, 0],
    [0, image.height - 1],
    [image.width - 1, image.height - 1],
    [Math.floor(image.width / 2), 0],
    [Math.floor(image.width / 2), image.height - 1],
    [0, Math.floor(image.height / 2)],
    [image.width - 1, Math.floor(image.height / 2)]
  ];

  for (const [x, y] of points) {
    const offset = (y * image.width + x) * 4;
    samples.push([image.data[offset], image.data[offset + 1], image.data[offset + 2]]);
  }

  return samples;
}

function isBackgroundLike(
  data: Uint8Array,
  pixelIndex: number,
  samples: Array<[number, number, number]>,
  thresholdSquared: number
): boolean {
  const offset = pixelIndex * 4;
  if (data[offset + 3] <= 8) {
    return true;
  }
  return samples.some(([r, g, b]) => {
    const dr = data[offset] - r;
    const dg = data[offset + 1] - g;
    const db = data[offset + 2] - b;
    return dr * dr + dg * dg + db * db <= thresholdSquared;
  });
}

function decodePng(buffer: Buffer): RgbaImage {
  if (buffer.length < 33 || buffer.readUInt32BE(0) !== 0x89504e47) {
    throw new Error("Input is not a PNG file.");
  }

  let offset = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  let interlace = 0;
  const idatChunks: Buffer[] = [];

  while (offset + 12 <= buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString("ascii", offset + 4, offset + 8);
    const data = buffer.subarray(offset + 8, offset + 8 + length);

    if (type === "IHDR") {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
      interlace = data[12];
    } else if (type === "IDAT") {
      idatChunks.push(data);
    } else if (type === "IEND") {
      break;
    }

    offset += 12 + length;
  }

  if (bitDepth !== 8 || interlace !== 0) {
    throw new Error(`Unsupported PNG format: bitDepth=${bitDepth}, interlace=${interlace}.`);
  }

  const channels = channelsForColorType(colorType);
  const inflated = zlib.inflateSync(Buffer.concat(idatChunks));
  const unfiltered = unfilter(inflated, width, height, channels);
  return { width, height, data: convertToRgba(unfiltered, width, height, colorType) };
}

function unfilter(input: Buffer, width: number, height: number, channels: number): Uint8Array {
  const rowLength = width * channels;
  const output = new Uint8Array(rowLength * height);
  let inputOffset = 0;

  for (let y = 0; y < height; y += 1) {
    const filter = input[inputOffset++];
    const rowOffset = y * rowLength;

    for (let x = 0; x < rowLength; x += 1) {
      const raw = input[inputOffset++];
      const left = x >= channels ? output[rowOffset + x - channels] : 0;
      const up = y > 0 ? output[rowOffset - rowLength + x] : 0;
      const upLeft = y > 0 && x >= channels ? output[rowOffset - rowLength + x - channels] : 0;

      let value: number;
      if (filter === 0) {
        value = raw;
      } else if (filter === 1) {
        value = raw + left;
      } else if (filter === 2) {
        value = raw + up;
      } else if (filter === 3) {
        value = raw + Math.floor((left + up) / 2);
      } else if (filter === 4) {
        value = raw + paeth(left, up, upLeft);
      } else {
        throw new Error(`Unsupported PNG filter: ${filter}.`);
      }

      output[rowOffset + x] = value & 0xff;
    }
  }

  return output;
}

function convertToRgba(input: Uint8Array, width: number, height: number, colorType: number): Uint8Array {
  const channels = channelsForColorType(colorType);
  const output = new Uint8Array(width * height * 4);

  for (let pixel = 0; pixel < width * height; pixel += 1) {
    const inputOffset = pixel * channels;
    const outputOffset = pixel * 4;

    if (colorType === 0) {
      const gray = input[inputOffset];
      output[outputOffset] = gray;
      output[outputOffset + 1] = gray;
      output[outputOffset + 2] = gray;
      output[outputOffset + 3] = 255;
    } else if (colorType === 2) {
      output[outputOffset] = input[inputOffset];
      output[outputOffset + 1] = input[inputOffset + 1];
      output[outputOffset + 2] = input[inputOffset + 2];
      output[outputOffset + 3] = 255;
    } else if (colorType === 4) {
      const gray = input[inputOffset];
      output[outputOffset] = gray;
      output[outputOffset + 1] = gray;
      output[outputOffset + 2] = gray;
      output[outputOffset + 3] = input[inputOffset + 1];
    } else if (colorType === 6) {
      output[outputOffset] = input[inputOffset];
      output[outputOffset + 1] = input[inputOffset + 1];
      output[outputOffset + 2] = input[inputOffset + 2];
      output[outputOffset + 3] = input[inputOffset + 3];
    }
  }

  return output;
}

function encodePng(image: RgbaImage): Buffer {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(image.width, 0);
  ihdr.writeUInt32BE(image.height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;

  const rowLength = image.width * 4;
  const raw = Buffer.alloc((rowLength + 1) * image.height);
  for (let y = 0; y < image.height; y += 1) {
    const targetOffset = y * (rowLength + 1);
    raw[targetOffset] = 0;
    Buffer.from(image.data.buffer, image.data.byteOffset + y * rowLength, rowLength).copy(raw, targetOffset + 1);
  }

  return Buffer.concat([
    signature,
    pngChunk("IHDR", ihdr),
    pngChunk("IDAT", zlib.deflateSync(raw, { level: 9 })),
    pngChunk("IEND", Buffer.alloc(0))
  ]);
}

function pngChunk(type: string, data: Buffer): Buffer {
  const typeBuffer = Buffer.from(type, "ascii");
  const chunk = Buffer.alloc(12 + data.length);
  chunk.writeUInt32BE(data.length, 0);
  typeBuffer.copy(chunk, 4);
  data.copy(chunk, 8);
  chunk.writeUInt32BE(crc32(Buffer.concat([typeBuffer, data])), 8 + data.length);
  return chunk;
}

const crcTable = new Uint32Array(256).map((_, index) => {
  let value = index;
  for (let bit = 0; bit < 8; bit += 1) {
    value = value & 1 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
  }
  return value >>> 0;
});

function crc32(buffer: Buffer): number {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc = crcTable[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function channelsForColorType(colorType: number): number {
  if (colorType === 0) {
    return 1;
  }
  if (colorType === 2) {
    return 3;
  }
  if (colorType === 4) {
    return 2;
  }
  if (colorType === 6) {
    return 4;
  }
  throw new Error(`Unsupported PNG color type: ${colorType}.`);
}

function paeth(left: number, up: number, upLeft: number): number {
  const p = left + up - upLeft;
  const pa = Math.abs(p - left);
  const pb = Math.abs(p - up);
  const pc = Math.abs(p - upLeft);
  if (pa <= pb && pa <= pc) {
    return left;
  }
  return pb <= pc ? up : upLeft;
}

function normalizeName(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "");
}

async function exists(filePath: string): Promise<boolean> {
  try {
    await access(filePath);
    return true;
  } catch {
    return false;
  }
}

function clampByte(value: number): number {
  return Math.max(0, Math.min(255, Math.round(value)));
}

function readThreshold(): number {
  const thresholdArg = process.argv.find((arg) => arg.startsWith("--threshold="));
  if (!thresholdArg) {
    return 72;
  }
  const parsed = Number(thresholdArg.split("=")[1]);
  return Number.isFinite(parsed) ? Math.max(0, Math.min(160, parsed)) : 72;
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
