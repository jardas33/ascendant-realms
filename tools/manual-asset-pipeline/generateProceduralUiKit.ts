import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { deflateSync } from "node:zlib";

type Rgba = [number, number, number, number];

interface Canvas {
  width: number;
  height: number;
  data: Uint8Array;
}

interface UiKitAssetSpec {
  filename: string;
  width: number;
  height: number;
  kind:
    | "panel"
    | "button-idle"
    | "button-hover"
    | "button-pressed"
    | "resource"
    | "divider"
    | "tooltip"
    | "minimap"
    | "ability-slot"
    | "inventory-slot"
    | "victory"
    | "defeat";
}

const outDir = path.join(process.cwd(), "public", "assets", "manual", "ui");

const colors = {
  transparent: [0, 0, 0, 0] as Rgba,
  iron: [18, 21, 21, 235] as Rgba,
  ironDark: [5, 7, 7, 245] as Rgba,
  silver: [170, 174, 164, 220] as Rgba,
  silverDim: [86, 91, 88, 210] as Rgba,
  gold: [220, 184, 86, 230] as Rgba,
  goldDim: [118, 91, 42, 190] as Rgba,
  leather: [25, 21, 17, 175] as Rgba,
  blueAether: [94, 174, 218, 210] as Rgba,
  blueDim: [35, 76, 101, 170] as Rgba,
  ember: [209, 82, 45, 220] as Rgba,
  emberDim: [97, 29, 23, 190] as Rgba
};

const specs: UiKitAssetSpec[] = [
  { filename: "ui_panel_frame.png", width: 1024, height: 1024, kind: "panel" },
  { filename: "ui_button_idle.png", width: 512, height: 192, kind: "button-idle" },
  { filename: "ui_button_hover.png", width: 512, height: 192, kind: "button-hover" },
  { filename: "ui_button_pressed.png", width: 512, height: 192, kind: "button-pressed" },
  { filename: "ui_resource_frame.png", width: 512, height: 192, kind: "resource" },
  { filename: "ui_divider_ornament.png", width: 1024, height: 96, kind: "divider" },
  { filename: "ui_tooltip_frame.png", width: 768, height: 512, kind: "tooltip" },
  { filename: "ui_minimap_frame.png", width: 512, height: 384, kind: "minimap" },
  { filename: "ui_ability_slot_frame.png", width: 256, height: 256, kind: "ability-slot" },
  { filename: "ui_inventory_slot_frame.png", width: 256, height: 256, kind: "inventory-slot" },
  { filename: "ui_victory_panel_frame.png", width: 1024, height: 1024, kind: "victory" },
  { filename: "ui_defeat_panel_frame.png", width: 1024, height: 1024, kind: "defeat" }
];

async function main(): Promise<void> {
  await mkdir(outDir, { recursive: true });

  for (const spec of specs) {
    const canvas = createCanvas(spec.width, spec.height);
    renderAsset(canvas, spec);
    const filePath = path.join(outDir, spec.filename);
    await writeFile(filePath, encodePng(canvas));
    console.log(`Wrote ${relative(filePath)}`);
  }
}

function renderAsset(canvas: Canvas, spec: UiKitAssetSpec): void {
  switch (spec.kind) {
    case "panel":
      renderPanelFrame(canvas, { accent: colors.gold, secondary: colors.blueAether });
      return;
    case "button-idle":
      renderButtonFrame(canvas, colors.goldDim, colors.silverDim, 0);
      return;
    case "button-hover":
      renderButtonFrame(canvas, colors.gold, colors.blueAether, 1);
      return;
    case "button-pressed":
      renderButtonFrame(canvas, colors.goldDim, colors.ironDark, -1);
      return;
    case "resource":
      renderResourceFrame(canvas);
      return;
    case "divider":
      renderDivider(canvas);
      return;
    case "tooltip":
      renderTooltipFrame(canvas);
      return;
    case "minimap":
      renderMinimapFrame(canvas);
      return;
    case "ability-slot":
      renderSquareSlot(canvas, colors.blueAether, colors.gold, true);
      return;
    case "inventory-slot":
      renderSquareSlot(canvas, colors.silverDim, colors.goldDim, false);
      return;
    case "victory":
      renderPanelFrame(canvas, { accent: colors.gold, secondary: colors.blueAether, banner: [20, 42, 78, 205] });
      renderVictoryCorners(canvas);
      return;
    case "defeat":
      renderPanelFrame(canvas, { accent: colors.ember, secondary: colors.goldDim, banner: [38, 17, 14, 200] });
      renderDefeatCracks(canvas);
      return;
  }
}

function renderPanelFrame(
  canvas: Canvas,
  options: { accent: Rgba; secondary: Rgba; banner?: Rgba }
): void {
  const { width, height } = canvas;
  const edge = Math.round(width * 0.075);
  const corner = Math.round(width * 0.18);

  strokeRect(canvas, 6, 6, width - 12, height - 12, edge, colors.ironDark);
  strokeRect(canvas, 14, 14, width - 28, height - 28, Math.max(8, edge * 0.52), colors.iron);
  strokeRect(canvas, 32, 32, width - 64, height - 64, 7, colors.silverDim);
  strokeRect(canvas, 46, 46, width - 92, height - 92, 3, options.accent);

  if (options.banner) {
    fillRect(canvas, corner * 0.5, 18, width - corner, 22, options.banner);
    fillRect(canvas, corner * 0.5, height - 40, width - corner, 22, options.banner);
  }

  drawPanelCorner(canvas, 18, 18, corner, corner, options.accent, options.secondary, "tl");
  drawPanelCorner(canvas, width - corner - 18, 18, corner, corner, options.accent, options.secondary, "tr");
  drawPanelCorner(canvas, 18, height - corner - 18, corner, corner, options.accent, options.secondary, "bl");
  drawPanelCorner(canvas, width - corner - 18, height - corner - 18, corner, corner, options.accent, options.secondary, "br");

  addMetalNoise(canvas, 0.14, 31);
}

function drawPanelCorner(
  canvas: Canvas,
  x: number,
  y: number,
  w: number,
  h: number,
  accent: Rgba,
  secondary: Rgba,
  corner: "tl" | "tr" | "bl" | "br"
): void {
  const flipX = corner === "tr" || corner === "br" ? -1 : 1;
  const flipY = corner === "bl" || corner === "br" ? -1 : 1;
  const ox = flipX === 1 ? x : x + w;
  const oy = flipY === 1 ? y : y + h;

  fillRect(canvas, ox, oy, flipX * Math.round(w * 0.82), flipY * Math.round(h * 0.2), colors.iron);
  fillRect(canvas, ox, oy, flipX * Math.round(w * 0.2), flipY * Math.round(h * 0.82), colors.iron);
  fillRect(canvas, ox + flipX * 15, oy + flipY * 15, flipX * Math.round(w * 0.5), flipY * 12, accent);
  fillRect(canvas, ox + flipX * 15, oy + flipY * 15, flipX * 12, flipY * Math.round(h * 0.5), accent);
  fillCircle(canvas, ox + flipX * Math.round(w * 0.34), oy + flipY * Math.round(h * 0.34), Math.max(5, Math.round(w * 0.035)), secondary);
}

function renderButtonFrame(canvas: Canvas, accent: Rgba, shine: Rgba, state: -1 | 0 | 1): void {
  const { width, height } = canvas;
  const edge = Math.round(height * 0.25);
  strokeRect(canvas, 4, 4, width - 8, height - 8, edge, state < 0 ? colors.ironDark : colors.iron);
  strokeRect(canvas, 10, 10, width - 20, height - 20, Math.max(8, edge * 0.5), state < 0 ? colors.silverDim : accent);
  strokeRect(canvas, 20, 20, width - 40, height - 40, 3, shine);
  fillRect(canvas, 28, 16, width - 56, state > 0 ? 5 : 3, shine);
  fillRect(canvas, 28, height - 21, width - 56, state < 0 ? 6 : 3, colors.ironDark);
  fillCircle(canvas, 31, 31, 6, accent);
  fillCircle(canvas, width - 31, 31, 6, accent);
  fillCircle(canvas, 31, height - 31, 6, accent);
  fillCircle(canvas, width - 31, height - 31, 6, accent);
  addMetalNoise(canvas, 0.11, state > 0 ? 53 : 47);
}

function renderResourceFrame(canvas: Canvas): void {
  renderButtonFrame(canvas, colors.goldDim, colors.silverDim, 0);
  fillRect(canvas, 8, 16, 24, canvas.height - 32, [42, 95, 105, 190]);
  fillRect(canvas, 34, 24, 3, canvas.height - 48, colors.gold);
  fillCircle(canvas, 47, canvas.height / 2, 7, colors.blueAether);
}

function renderDivider(canvas: Canvas): void {
  const y = Math.floor(canvas.height / 2);
  drawLine(canvas, 64, y, canvas.width / 2 - 56, y, colors.silverDim, 3);
  drawLine(canvas, canvas.width / 2 + 56, y, canvas.width - 64, y, colors.silverDim, 3);
  drawLine(canvas, 160, y + 8, canvas.width / 2 - 86, y + 8, colors.goldDim, 2);
  drawLine(canvas, canvas.width / 2 + 86, y + 8, canvas.width - 160, y + 8, colors.goldDim, 2);
  fillDiamond(canvas, canvas.width / 2, y, 34, colors.gold);
  fillDiamond(canvas, canvas.width / 2, y, 18, colors.iron);
  fillCircle(canvas, canvas.width / 2 - 58, y, 5, colors.blueAether);
  fillCircle(canvas, canvas.width / 2 + 58, y, 5, colors.blueAether);
}

function renderTooltipFrame(canvas: Canvas): void {
  const edge = Math.round(Math.min(canvas.width, canvas.height) * 0.09);
  strokeRect(canvas, 5, 5, canvas.width - 10, canvas.height - 10, edge, [8, 10, 10, 215]);
  strokeRect(canvas, 13, 13, canvas.width - 26, canvas.height - 26, Math.max(5, edge * 0.45), colors.silverDim);
  strokeRect(canvas, 24, 24, canvas.width - 48, canvas.height - 48, 3, colors.blueDim);
  fillCircle(canvas, 38, 38, 5, colors.goldDim);
  fillCircle(canvas, canvas.width - 38, 38, 5, colors.goldDim);
  fillCircle(canvas, 38, canvas.height - 38, 5, colors.goldDim);
  fillCircle(canvas, canvas.width - 38, canvas.height - 38, 5, colors.goldDim);
  addMetalNoise(canvas, 0.1, 73);
}

function renderMinimapFrame(canvas: Canvas): void {
  const edge = 42;
  strokeRect(canvas, 4, 4, canvas.width - 8, canvas.height - 8, edge, colors.ironDark);
  strokeRect(canvas, 13, 13, canvas.width - 26, canvas.height - 26, 18, colors.silverDim);
  strokeRect(canvas, 29, 29, canvas.width - 58, canvas.height - 58, 4, colors.goldDim);
  fillCircle(canvas, 45, 45, 8, colors.blueAether);
  fillCircle(canvas, canvas.width - 45, 45, 8, colors.blueAether);
  fillCircle(canvas, 45, canvas.height - 45, 8, colors.blueAether);
  fillCircle(canvas, canvas.width - 45, canvas.height - 45, 8, colors.blueAether);
  addMetalNoise(canvas, 0.12, 89);
}

function renderSquareSlot(canvas: Canvas, accent: Rgba, corner: Rgba, innerGlow: boolean): void {
  const edge = Math.round(canvas.width * 0.18);
  strokeRect(canvas, 4, 4, canvas.width - 8, canvas.height - 8, edge, colors.ironDark);
  strokeRect(canvas, 12, 12, canvas.width - 24, canvas.height - 24, Math.round(edge * 0.5), colors.iron);
  strokeRect(canvas, 24, 24, canvas.width - 48, canvas.height - 48, 4, accent);
  if (innerGlow) {
    strokeRect(canvas, 40, 40, canvas.width - 80, canvas.height - 80, 2, [94, 174, 218, 95]);
  } else {
    fillRect(canvas, 50, 50, canvas.width - 100, canvas.height - 100, [12, 10, 9, 42]);
  }
  fillCircle(canvas, 36, 36, 6, corner);
  fillCircle(canvas, canvas.width - 36, 36, 6, corner);
  fillCircle(canvas, 36, canvas.height - 36, 6, corner);
  fillCircle(canvas, canvas.width - 36, canvas.height - 36, 6, corner);
  addMetalNoise(canvas, 0.08, innerGlow ? 107 : 113);
}

function renderVictoryCorners(canvas: Canvas): void {
  drawLine(canvas, 84, 74, 180, 74, colors.gold, 5);
  drawLine(canvas, canvas.width - 84, 74, canvas.width - 180, 74, colors.gold, 5);
  drawLine(canvas, 84, canvas.height - 74, 180, canvas.height - 74, colors.gold, 5);
  drawLine(canvas, canvas.width - 84, canvas.height - 74, canvas.width - 180, canvas.height - 74, colors.gold, 5);
}

function renderDefeatCracks(canvas: Canvas): void {
  drawLine(canvas, 82, 78, 138, 120, colors.ember, 3);
  drawLine(canvas, 138, 120, 118, 166, colors.emberDim, 2);
  drawLine(canvas, canvas.width - 82, 78, canvas.width - 138, 120, colors.ember, 3);
  drawLine(canvas, canvas.width - 138, 120, canvas.width - 118, 166, colors.emberDim, 2);
}

function createCanvas(width: number, height: number): Canvas {
  return {
    width,
    height,
    data: new Uint8Array(width * height * 4)
  };
}

function strokeRect(canvas: Canvas, x: number, y: number, w: number, h: number, thickness: number, color: Rgba): void {
  fillRect(canvas, x, y, w, thickness, color);
  fillRect(canvas, x, y + h - thickness, w, thickness, color);
  fillRect(canvas, x, y, thickness, h, color);
  fillRect(canvas, x + w - thickness, y, thickness, h, color);
}

function fillRect(canvas: Canvas, x: number, y: number, w: number, h: number, color: Rgba): void {
  const x1 = Math.min(x, x + w);
  const x2 = Math.max(x, x + w);
  const y1 = Math.min(y, y + h);
  const y2 = Math.max(y, y + h);
  for (let yy = Math.max(0, Math.floor(y1)); yy < Math.min(canvas.height, Math.ceil(y2)); yy += 1) {
    for (let xx = Math.max(0, Math.floor(x1)); xx < Math.min(canvas.width, Math.ceil(x2)); xx += 1) {
      blendPixel(canvas, xx, yy, color);
    }
  }
}

function fillCircle(canvas: Canvas, cx: number, cy: number, radius: number, color: Rgba): void {
  const r2 = radius * radius;
  for (let y = Math.floor(cy - radius); y <= Math.ceil(cy + radius); y += 1) {
    for (let x = Math.floor(cx - radius); x <= Math.ceil(cx + radius); x += 1) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) {
        blendPixel(canvas, x, y, color);
      }
    }
  }
}

function fillDiamond(canvas: Canvas, cx: number, cy: number, radius: number, color: Rgba): void {
  for (let y = Math.floor(cy - radius); y <= Math.ceil(cy + radius); y += 1) {
    for (let x = Math.floor(cx - radius); x <= Math.ceil(cx + radius); x += 1) {
      if (Math.abs(x - cx) + Math.abs(y - cy) <= radius) {
        blendPixel(canvas, x, y, color);
      }
    }
  }
}

function drawLine(canvas: Canvas, x0: number, y0: number, x1: number, y1: number, color: Rgba, thickness: number): void {
  const steps = Math.max(Math.abs(x1 - x0), Math.abs(y1 - y0), 1);
  for (let i = 0; i <= steps; i += 1) {
    const t = i / steps;
    const x = x0 + (x1 - x0) * t;
    const y = y0 + (y1 - y0) * t;
    fillCircle(canvas, x, y, thickness / 2, color);
  }
}

function addMetalNoise(canvas: Canvas, opacity: number, seed: number): void {
  for (let y = 0; y < canvas.height; y += 7) {
    for (let x = 0; x < canvas.width; x += 7) {
      const n = pseudoRandom(x, y, seed);
      if (n > 0.72) {
        blendPixel(canvas, x, y, [255, 246, 200, Math.floor(255 * opacity * n)]);
      }
      if (n < 0.08) {
        blendPixel(canvas, x, y, [0, 0, 0, Math.floor(255 * opacity)]);
      }
    }
  }
}

function pseudoRandom(x: number, y: number, seed: number): number {
  const value = Math.sin(x * 12.9898 + y * 78.233 + seed * 37.719) * 43758.5453;
  return value - Math.floor(value);
}

function blendPixel(canvas: Canvas, x: number, y: number, color: Rgba): void {
  if (x < 0 || y < 0 || x >= canvas.width || y >= canvas.height) {
    return;
  }
  const index = (Math.floor(y) * canvas.width + Math.floor(x)) * 4;
  const sourceAlpha = color[3] / 255;
  const destAlpha = canvas.data[index + 3] / 255;
  const outAlpha = sourceAlpha + destAlpha * (1 - sourceAlpha);
  if (outAlpha <= 0) {
    return;
  }
  canvas.data[index] = Math.round((color[0] * sourceAlpha + canvas.data[index] * destAlpha * (1 - sourceAlpha)) / outAlpha);
  canvas.data[index + 1] = Math.round((color[1] * sourceAlpha + canvas.data[index + 1] * destAlpha * (1 - sourceAlpha)) / outAlpha);
  canvas.data[index + 2] = Math.round((color[2] * sourceAlpha + canvas.data[index + 2] * destAlpha * (1 - sourceAlpha)) / outAlpha);
  canvas.data[index + 3] = Math.round(outAlpha * 255);
}

function encodePng(canvas: Canvas): Buffer {
  const stride = canvas.width * 4 + 1;
  const raw = Buffer.alloc(stride * canvas.height);
  for (let y = 0; y < canvas.height; y += 1) {
    raw[y * stride] = 0;
    const sourceStart = y * canvas.width * 4;
    Buffer.from(canvas.data.buffer, sourceStart, canvas.width * 4).copy(raw, y * stride + 1);
  }

  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    pngChunk("IHDR", buildIhdr(canvas.width, canvas.height)),
    pngChunk("IDAT", deflateSync(raw, { level: 9 })),
    pngChunk("IEND", Buffer.alloc(0))
  ]);
}

function buildIhdr(width: number, height: number): Buffer {
  const buffer = Buffer.alloc(13);
  buffer.writeUInt32BE(width, 0);
  buffer.writeUInt32BE(height, 4);
  buffer[8] = 8;
  buffer[9] = 6;
  buffer[10] = 0;
  buffer[11] = 0;
  buffer[12] = 0;
  return buffer;
}

function pngChunk(type: string, data: Buffer): Buffer {
  const typeBuffer = Buffer.from(type, "ascii");
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length, 0);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuffer, data])), 0);
  return Buffer.concat([length, typeBuffer, data, crc]);
}

function crc32(buffer: Buffer): number {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc ^= byte;
    for (let k = 0; k < 8; k += 1) {
      crc = crc & 1 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function relative(filePath: string): string {
  return path.relative(process.cwd(), filePath).replaceAll(path.sep, "/");
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
