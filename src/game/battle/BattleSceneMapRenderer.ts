import Phaser from "phaser";
import type { BattleMapDefinition, Position } from "../core/GameTypes";
import type { RenderLifecycleMetricsRecorder } from "../systems/RenderLifecycleMetrics";

interface TerrainEllipseCommand {
  x: number;
  y: number;
  width: number;
  height: number;
  color: number;
  alpha: number;
}

interface TerrainGrassCommand {
  points: [Position, Position][];
}

interface TerrainPebbleCommand {
  x: number;
  y: number;
  radius: number;
}

interface StaticTerrainGeometryCache {
  baseFlecks: TerrainEllipseCommand[];
  shadowPatches: TerrainEllipseCommand[];
  grassBlades: TerrainGrassCommand[];
  pebbles: TerrainPebbleCommand[];
}

const staticTerrainGeometryCache = new Map<string, StaticTerrainGeometryCache>();

export function drawBattleMap(
  scene: Phaser.Scene,
  activeMap: BattleMapDefinition,
  recordRenderLifecycleMetrics?: RenderLifecycleMetricsRecorder
): void {
  scene.cameras.main.setBounds(0, 0, activeMap.width, activeMap.height);
  const graphics = scene.add.graphics().setDepth(-20);
  recordRenderLifecycleMetrics?.({ graphicsCreated: 1, terrainRedraws: 1 });
  drawBaseTerrain(graphics, activeMap, recordRenderLifecycleMetrics);
  drawBattleRoads(graphics, activeMap);

  activeMap.terrainZones.forEach((zone) => {
    if (zone.type === "buildable") {
      drawBuildableGround(graphics, zone);
    }
    if (zone.type === "blocked") {
      drawBlockedGround(graphics, zone);
    }
    if (zone.type === "water") {
      drawWaterGround(graphics, zone);
    }
  });

  drawCaptureSiteGrounds(graphics, activeMap);
  drawTerrainDetails(graphics, activeMap, recordRenderLifecycleMetrics);
  drawMapBorder(graphics, activeMap);
}

function drawBaseTerrain(
  graphics: Phaser.GameObjects.Graphics,
  activeMap: BattleMapDefinition,
  recordRenderLifecycleMetrics?: RenderLifecycleMetricsRecorder
): void {
  const cached = cachedStaticTerrainGeometry(activeMap, recordRenderLifecycleMetrics);
  graphics.fillStyle(0x17261b, 1);
  graphics.fillRect(0, 0, activeMap.width, activeMap.height);

  graphics.fillStyle(0x0c130f, 0.18);
  graphics.fillRect(0, 0, activeMap.width, activeMap.height);
  graphics.fillStyle(0x213923, 0.6);
  graphics.fillEllipse(570, 780, 980, 720);
  graphics.fillStyle(0x243223, 0.54);
  graphics.fillEllipse(1650, 770, 1220, 760);
  graphics.fillStyle(0x1a2e27, 0.46);
  graphics.fillEllipse(1160, 230, 620, 300);
  graphics.fillStyle(0x263827, 0.42);
  graphics.fillEllipse(1250, 1370, 840, 280);

  cached.baseFlecks.forEach((fleck) => {
    graphics.fillStyle(fleck.color, fleck.alpha);
    graphics.fillEllipse(fleck.x, fleck.y, fleck.width, fleck.height);
  });

  cached.shadowPatches.forEach((patch) => {
    graphics.fillStyle(patch.color, patch.alpha);
    graphics.fillEllipse(patch.x, patch.y, patch.width, patch.height);
  });
}

function drawBattleRoads(graphics: Phaser.GameObjects.Graphics, activeMap: BattleMapDefinition): void {
  activeMap.visualPaths.forEach((path) => drawPath(graphics, path.points, path.width));
}

function drawBuildableGround(
  graphics: Phaser.GameObjects.Graphics,
  zone: { x: number; y: number; width: number; height: number }
): void {
  graphics.fillStyle(0x2c3f2b, 0.55);
  graphics.fillRect(zone.x, zone.y, zone.width, zone.height);
  graphics.fillStyle(0x6b5837, 0.16);
  graphics.fillRect(zone.x + 18, zone.y + 18, zone.width - 36, zone.height - 36);
  graphics.lineStyle(3, 0xd6c37d, 0.24);
  graphics.strokeRect(zone.x + 16, zone.y + 16, zone.width - 32, zone.height - 32);

  graphics.lineStyle(1, 0xf0d978, 0.08);
  for (let x = zone.x + 74; x < zone.x + zone.width - 40; x += 92) {
    strokePolyline(graphics, [
      { x, y: zone.y + 34 },
      { x: x - 18, y: zone.y + zone.height - 34 }
    ]);
  }
  for (let y = zone.y + 68; y < zone.y + zone.height - 40; y += 86) {
    strokePolyline(graphics, [
      { x: zone.x + 34, y },
      { x: zone.x + zone.width - 34, y: y + 12 }
    ]);
  }

  graphics.fillStyle(0x0f1710, 0.55);
  graphics.fillCircle(zone.x + 26, zone.y + 26, 6);
  graphics.fillCircle(zone.x + zone.width - 26, zone.y + 26, 6);
  graphics.fillCircle(zone.x + 26, zone.y + zone.height - 26, 6);
  graphics.fillCircle(zone.x + zone.width - 26, zone.y + zone.height - 26, 6);
}

function drawBlockedGround(
  graphics: Phaser.GameObjects.Graphics,
  zone: { x: number; y: number; width: number; height: number }
): void {
  const centerX = zone.x + zone.width / 2;
  const centerY = zone.y + zone.height / 2;
  graphics.fillStyle(0x211f1b, 0.45);
  graphics.fillEllipse(centerX + 8, centerY + 12, zone.width * 1.2, zone.height * 1.08);
  graphics.fillStyle(0x514f43, 0.94);
  graphics.fillEllipse(centerX, centerY, zone.width * 1.03, zone.height * 0.86);
  graphics.fillStyle(0x77705c, 0.72);
  graphics.fillEllipse(centerX - zone.width * 0.22, centerY - zone.height * 0.1, zone.width * 0.32, zone.height * 0.46);
  graphics.fillEllipse(centerX + zone.width * 0.18, centerY + zone.height * 0.04, zone.width * 0.36, zone.height * 0.42);
  graphics.lineStyle(4, 0x191712, 0.42);
  graphics.strokeEllipse(centerX, centerY, zone.width * 1.03, zone.height * 0.86);
}

function drawWaterGround(
  graphics: Phaser.GameObjects.Graphics,
  zone: { x: number; y: number; width: number; height: number }
): void {
  const centerX = zone.x + zone.width / 2;
  const centerY = zone.y + zone.height / 2;
  graphics.fillStyle(0x10241f, 0.42);
  graphics.fillEllipse(centerX + 8, centerY + 10, zone.width * 1.16, zone.height * 1.22);
  graphics.fillStyle(0x1d5564, 0.92);
  graphics.fillEllipse(centerX, centerY, zone.width * 1.06, zone.height * 1.1);
  graphics.fillStyle(0x276c78, 0.5);
  graphics.fillEllipse(centerX - zone.width * 0.12, centerY - zone.height * 0.08, zone.width * 0.58, zone.height * 0.38);
  graphics.lineStyle(8, 0xa2b077, 0.18);
  graphics.strokeEllipse(centerX, centerY, zone.width * 1.1, zone.height * 1.15);
  graphics.lineStyle(2, 0xbfe9df, 0.22);
  for (let index = 0; index < 4; index += 1) {
    const y = centerY - zone.height * 0.23 + index * (zone.height * 0.15);
    strokePolyline(graphics, [
      { x: centerX - zone.width * 0.3, y },
      { x: centerX - zone.width * 0.08, y: y + 8 },
      { x: centerX + zone.width * 0.22, y: y - 2 }
    ]);
  }
  graphics.lineStyle(2, 0x05201f, 0.28);
  strokePolyline(graphics, [
    { x: centerX - zone.width * 0.46, y: centerY + zone.height * 0.34 },
    { x: centerX - zone.width * 0.16, y: centerY + zone.height * 0.48 },
    { x: centerX + zone.width * 0.42, y: centerY + zone.height * 0.36 }
  ]);
}

function drawCaptureSiteGrounds(graphics: Phaser.GameObjects.Graphics, activeMap: BattleMapDefinition): void {
  activeMap.captureSites.forEach((site, index) => {
    const accent = [0xd8c76f, 0x9fa079, 0xb08059, 0x74d3f2][index] ?? 0xd8c76f;
    graphics.fillStyle(0x0e1510, 0.28);
    graphics.fillCircle(site.x, site.y + 6, site.radius + 30);
    graphics.fillStyle(accent, 0.08);
    graphics.fillCircle(site.x, site.y, site.radius + 18);
    graphics.lineStyle(3, accent, 0.26);
    graphics.strokeCircle(site.x, site.y, site.radius + 16);
    graphics.lineStyle(2, 0xf0d978, 0.11);
    graphics.strokeCircle(site.x, site.y, site.radius + 4);
  });
}

function drawTerrainDetails(
  graphics: Phaser.GameObjects.Graphics,
  activeMap: BattleMapDefinition,
  recordRenderLifecycleMetrics?: RenderLifecycleMetricsRecorder
): void {
  const cached = cachedStaticTerrainGeometry(activeMap, recordRenderLifecycleMetrics);
  for (const blade of cached.grassBlades) {
    graphics.lineStyle(2, 0x54724a, 0.25);
    blade.points.forEach((points) => strokePolyline(graphics, points));
  }

  for (const pebble of cached.pebbles) {
    graphics.fillStyle(0x8b8265, 0.24);
    graphics.fillCircle(pebble.x, pebble.y, pebble.radius);
  }
}

function drawMapBorder(graphics: Phaser.GameObjects.Graphics, activeMap: BattleMapDefinition): void {
  graphics.lineStyle(28, 0x070a08, 0.34);
  graphics.strokeRect(0, 0, activeMap.width, activeMap.height);
  graphics.lineStyle(6, 0x101712, 1);
  graphics.strokeRect(0, 0, activeMap.width, activeMap.height);
}

function drawPath(graphics: Phaser.GameObjects.Graphics, points: Position[], width: number): void {
  graphics.lineStyle(width + 28, 0x080b08, 0.28);
  strokePolyline(graphics, points);
  graphics.lineStyle(width + 18, 0x10140f, 0.34);
  strokePolyline(graphics, points);
  graphics.lineStyle(width + 8, 0x5b462d, 0.38);
  strokePolyline(graphics, points);
  graphics.lineStyle(width, 0x8a6a3f, 0.46);
  strokePolyline(graphics, points);
  graphics.lineStyle(Math.max(4, width * 0.16), 0xc09a5f, 0.16);
  strokePolyline(graphics, points);
  graphics.lineStyle(2, 0xf0d978, 0.18);
  strokePolyline(graphics, points);
}

function strokePolyline(graphics: Phaser.GameObjects.Graphics, points: Position[]): void {
  if (points.length === 0) {
    return;
  }
  graphics.beginPath();
  graphics.moveTo(points[0].x, points[0].y);
  for (let index = 1; index < points.length; index += 1) {
    graphics.lineTo(points[index].x, points[index].y);
  }
  graphics.strokePath();
}

function cachedStaticTerrainGeometry(
  activeMap: BattleMapDefinition,
  recordRenderLifecycleMetrics?: RenderLifecycleMetricsRecorder
): StaticTerrainGeometryCache {
  const signature = createStaticTerrainGeometrySignature(activeMap);
  const cached = staticTerrainGeometryCache.get(signature);
  if (cached) {
    return cached;
  }

  const next: StaticTerrainGeometryCache = {
    baseFlecks: [],
    shadowPatches: [],
    grassBlades: [],
    pebbles: []
  };
  for (let index = 0; index < 260; index += 1) {
    const colorRoll = noise01(index + 409);
    next.baseFlecks.push({
      x: noise01(index + 11) * activeMap.width,
      y: noise01(index + 97) * activeMap.height,
      width: 10 + noise01(index + 211) * 34,
      height: 4 + noise01(index + 307) * 13,
      color: colorRoll > 0.72 ? 0x385036 : colorRoll > 0.38 ? 0x203922 : 0x293f2c,
      alpha: 0.13 + noise01(index + 503) * 0.17
    });
  }
  for (let index = 0; index < 46; index += 1) {
    const radius = 44 + noise01(index + 1613) * 98;
    next.shadowPatches.push({
      x: noise01(index + 1447) * activeMap.width,
      y: noise01(index + 1531) * activeMap.height,
      width: radius * 1.7,
      height: radius * 0.62,
      color: index % 2 === 0 ? 0x101b15 : 0x31422d,
      alpha: 0.1 + noise01(index + 1709) * 0.08
    });
  }
  for (let index = 0; index < 110; index += 1) {
    const x = noise01(index + 701) * activeMap.width;
    const y = noise01(index + 809) * activeMap.height;
    const height = 12 + noise01(index + 877) * 18;
    next.grassBlades.push({
      points: [
        [
          { x, y },
          { x: x + 4, y: y - height }
        ],
        [
          { x: x + 5, y: y + 1 },
          { x: x + 11, y: y - height * 0.72 }
        ]
      ]
    });
  }
  for (let index = 0; index < 72; index += 1) {
    next.pebbles.push({
      x: noise01(index + 1013) * activeMap.width,
      y: noise01(index + 1117) * activeMap.height,
      radius: 2 + noise01(index + 1223) * 5
    });
  }

  staticTerrainGeometryCache.set(signature, next);
  recordRenderLifecycleMetrics?.({ geometryRebuilds: 1 });
  return next;
}

function createStaticTerrainGeometrySignature(activeMap: BattleMapDefinition): string {
  return [
    activeMap.id,
    activeMap.width,
    activeMap.height,
    activeMap.terrainZones.length,
    activeMap.visualPaths.length,
    activeMap.captureSites.length
  ].join(":");
}

function noise01(seed: number): number {
  const value = Math.sin(seed * 12.9898) * 43758.5453;
  return value - Math.floor(value);
}
