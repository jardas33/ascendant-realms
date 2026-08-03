import type { ResourceKey, Team, VisibilityState } from "../core/GameTypes";
import { resolveFogCellPresentation } from "./FogPresentation";

export type MinimapMarkerKind = "unit" | "enemy-hero" | "building" | "capture-site" | "camp" | "rally";

export interface MinimapMarker {
  id: string;
  kind: MinimapMarkerKind;
  team: Team;
  x: number;
  y: number;
  size?: number;
  resource?: ResourceKey;
  resourceColor?: string;
  isObjective?: boolean;
}

export interface MinimapCameraRect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface MinimapPing {
  id: number;
  x: number;
  y: number;
  ageSeconds: number;
  durationSeconds: number;
  color: string;
  label: string;
}

export interface MinimapFogState {
  enabled: boolean;
  cells?: MinimapFogCell[];
}

export interface MinimapFogCell {
  x: number;
  y: number;
  width: number;
  height: number;
  state: VisibilityState;
}

export interface MinimapSnapshot {
  mapWidth: number;
  mapHeight: number;
  markers: MinimapMarker[];
  camera: MinimapCameraRect;
  pings: MinimapPing[];
  colorblindPalette?: boolean;
  fog: MinimapFogState;
}

const TEAM_COLORS: Record<Team, string> = {
  player: "#7de087",
  enemy: "#e15e55",
  neutral: "#d8b46a"
};

const TEAM_STROKES: Record<Team, string> = {
  player: "#74d3f2",
  enemy: "#ffaba4",
  neutral: "#7b5d34"
};

const COLORBLIND_TEAM_COLORS: Record<Team, string> = {
  player: "#56b4e9",
  enemy: "#d55e00",
  neutral: "#f0e442"
};

const COLORBLIND_TEAM_STROKES: Record<Team, string> = {
  player: "#cdefff",
  enemy: "#ffd2a6",
  neutral: "#5c4f00"
};

let lastRenderSignature = "";
let lastRenderMarkup = "";

export function renderMinimap(snapshot: MinimapSnapshot): string {
  const signature = createMinimapRenderSignature(snapshot);
  if (signature === lastRenderSignature) {
    return lastRenderMarkup;
  }
  const mapWidth = safeDimension(snapshot.mapWidth);
  const mapHeight = safeDimension(snapshot.mapHeight);
  const markers = [...snapshot.markers].sort((left, right) => markerSortOrder(left) - markerSortOrder(right));
  const markup = `
    <div class="mini-map" data-testid="minimap" data-minimap="true" data-map-width="${mapWidth}" data-map-height="${mapHeight}" role="button" aria-label="${escapeAttribute(
      minimapAriaLabel(snapshot)
    )}" style="--minimap-map-aspect: ${formatNumber(mapWidth / mapHeight)}">
      <svg class="minimap-svg" viewBox="0 0 ${mapWidth} ${mapHeight}" preserveAspectRatio="none" aria-hidden="true">
        <rect class="minimap-terrain" x="0" y="0" width="${mapWidth}" height="${mapHeight}"></rect>
        <rect class="minimap-bounds" x="0" y="0" width="${mapWidth}" height="${mapHeight}"></rect>
        ${renderFog(snapshot)}
        ${markers.map((marker) => renderMarker(snapshot, marker)).join("")}
        ${snapshot.pings.map((ping) => renderPing(snapshot, ping)).join("")}
        ${renderCamera(snapshot)}
      </svg>
    </div>
  `;
  lastRenderSignature = signature;
  lastRenderMarkup = markup;
  return markup;
}

export function createMinimapRenderSignature(snapshot: MinimapSnapshot): string {
  const markerSignature = [...snapshot.markers]
    .sort((left, right) => `${left.id}:${left.kind}`.localeCompare(`${right.id}:${right.kind}`))
    .map(
      (marker) =>
        `${marker.id}:${marker.kind}:${marker.team}:${formatNumber(marker.x)}:${formatNumber(marker.y)}:${marker.size ?? ""}:${marker.resource ?? ""}:${
          marker.resourceColor ?? ""
        }:${marker.isObjective ? "1" : "0"}`
    )
    .join("|");
  const pingSignature = snapshot.pings
    .map(
      (ping) =>
        `${ping.id}:${formatNumber(ping.x)}:${formatNumber(ping.y)}:${formatNumber(ping.ageSeconds)}:${formatNumber(ping.durationSeconds)}:${ping.color}:${ping.label}`
    )
    .join("|");
  const fogSignature = snapshot.fog.enabled
    ? (snapshot.fog.cells ?? [])
        .map((cell) => `${formatNumber(cell.x)}:${formatNumber(cell.y)}:${formatNumber(cell.width)}:${formatNumber(cell.height)}:${cell.state}`)
        .join("|")
    : "off";
  return [
    safeDimension(snapshot.mapWidth),
    safeDimension(snapshot.mapHeight),
    snapshot.colorblindPalette ? "colorblind" : "standard",
    `${formatNumber(snapshot.camera.x)}:${formatNumber(snapshot.camera.y)}:${formatNumber(snapshot.camera.width)}:${formatNumber(snapshot.camera.height)}`,
    markerSignature,
    pingSignature,
    fogSignature
  ].join(";");
}

function renderFog(snapshot: MinimapSnapshot): string {
  if (!snapshot.fog.enabled || !snapshot.fog.cells) {
    return "";
  }
  return snapshot.fog.cells
    .filter((cell) => cell.state !== "visible")
    .map((cell) => {
      const x = worldToMinimapX(snapshot, cell.x);
      const y = worldToMinimapY(snapshot, cell.y);
      const width = formatNumber(clamp(finiteNumber(cell.width, 0), 0, safeDimension(snapshot.mapWidth) - Number(x)));
      const height = formatNumber(clamp(finiteNumber(cell.height, 0), 0, safeDimension(snapshot.mapHeight) - Number(y)));
      const presentation = resolveFogCellPresentation(cell.state === "unseen" ? "unseen" : "explored");
      return `<rect class="minimap-fog ${cell.state}" x="${x}" y="${y}" width="${width}" height="${height}" rx="0.8" fill="${presentation.fillColorCss}" opacity="${formatNumber(presentation.fillAlpha)}"></rect>`;
    })
    .join("");
}

function renderMarker(snapshot: MinimapSnapshot, marker: MinimapMarker): string {
  const x = worldToMinimapX(snapshot, marker.x);
  const y = worldToMinimapY(snapshot, marker.y);
  const scale = minimapUnitScale(snapshot);
  if (marker.kind === "capture-site") {
    const color = marker.resourceColor ?? "#f5efc2";
    const fill = marker.team === "neutral" ? "#18251e" : teamColor(marker.team, snapshot);
    const stroke = marker.isObjective ? "#b8efff" : color;
    const innerStroke = marker.team === "neutral" ? color : teamStroke(marker.team, snapshot);
    return `
      <g class="minimap-site-marker ${marker.team}${marker.isObjective ? " objective" : ""}" aria-label="${escapeAttribute(marker.isObjective ? "Objective resource site" : "Resource site")}">
        <circle cx="${x}" cy="${y}" r="${formatNumber((marker.isObjective ? 4.8 : 4) * scale)}" fill="${fill}" fill-opacity="${marker.team === "neutral" ? "0.52" : "0.4"}" stroke="${stroke}" stroke-width="${formatNumber(1.05 * scale)}"></circle>
        <circle cx="${x}" cy="${y}" r="${formatNumber(1.55 * scale)}" fill="${color}" stroke="${innerStroke}" stroke-width="${formatNumber(0.55 * scale)}"></circle>
      </g>
    `;
  }

  if (marker.kind === "building") {
    const size = finiteNumber(marker.size, 3.6) * scale;
    const half = size / 2;
    return `<rect class="minimap-building" x="${formatNumber(Number(x) - half)}" y="${formatNumber(Number(y) - half)}" width="${formatNumber(size)}" height="${formatNumber(size)}" rx="${formatNumber(0.55 * scale)}" fill="${teamColor(marker.team, snapshot)}" stroke="${teamStroke(marker.team, snapshot)}" stroke-width="${formatNumber(0.75 * scale)}"></rect>`;
  }

  if (marker.kind === "camp") {
    const radius = finiteNumber(marker.size, 2.4) * scale;
    const points = [
      `${x},${formatNumber(Number(y) - radius)}`,
      `${formatNumber(Number(x) + radius)},${y}`,
      `${x},${formatNumber(Number(y) + radius)}`,
      `${formatNumber(Number(x) - radius)},${y}`
    ].join(" ");
    return `<polygon class="minimap-camp" points="${points}" fill="#a8733b" stroke="#f0d978" stroke-width="0.55"></polygon>`;
  }

  if (marker.kind === "rally") {
    return `
      <g class="minimap-rally">
        <circle cx="${x}" cy="${y}" r="${formatNumber(2.2 * scale)}" fill="#11351f" stroke="#9cf7b1" stroke-width="${formatNumber(0.65 * scale)}"></circle>
        <path d="M ${x} ${formatNumber(Number(y) + 2.8 * scale)} L ${x} ${formatNumber(Number(y) - 4 * scale)} L ${formatNumber(Number(x) + 4.2 * scale)} ${formatNumber(Number(y) - 2.5 * scale)} L ${x} ${formatNumber(Number(y) - 1 * scale)} Z" fill="#78dc7b" stroke="#f5efc2" stroke-width="${formatNumber(0.45 * scale)}"></path>
      </g>
    `;
  }

  if (marker.kind === "enemy-hero") {
    const radius = finiteNumber(marker.size, 2.6) * scale;
    const points = [
      `${x},${formatNumber(Number(y) - radius)}`,
      `${formatNumber(Number(x) + radius)},${y}`,
      `${x},${formatNumber(Number(y) + radius)}`,
      `${formatNumber(Number(x) - radius)},${y}`
    ].join(" ");
    return `<polygon class="minimap-enemy-hero" points="${points}" fill="${teamColor(marker.team, snapshot)}" stroke="#ffd28a" stroke-width="0.8" aria-label="Enemy commander marker"></polygon>`;
  }

  return `<circle class="minimap-unit" cx="${x}" cy="${y}" r="${formatNumber(finiteNumber(marker.size, 1.55) * scale)}" fill="${teamColor(marker.team, snapshot)}" stroke="${teamStroke(marker.team, snapshot)}" stroke-width="${formatNumber(0.5 * scale)}"></circle>`;
}

function renderPing(snapshot: MinimapSnapshot, ping: MinimapPing): string {
  const progress = clamp(finiteNumber(ping.ageSeconds, 0) / Math.max(0.01, finiteNumber(ping.durationSeconds, 0)), 0, 1);
  const opacity = formatNumber(0.9 * (1 - progress));
  const radius = formatNumber((2.2 + progress * 9) * minimapUnitScale(snapshot));
  return `
    <g class="minimap-ping" aria-label="${escapeAttribute(ping.label)}">
      <circle cx="${worldToMinimapX(snapshot, ping.x)}" cy="${worldToMinimapY(snapshot, ping.y)}" r="${radius}" fill="none" stroke="${escapeAttribute(ping.color)}" stroke-width="1.25" opacity="${opacity}"></circle>
      <circle cx="${worldToMinimapX(snapshot, ping.x)}" cy="${worldToMinimapY(snapshot, ping.y)}" r="${formatNumber(1.25 * minimapUnitScale(snapshot))}" fill="${escapeAttribute(ping.color)}" opacity="${opacity}"></circle>
    </g>
  `;
}

function renderCamera(snapshot: MinimapSnapshot): string {
  const x = worldToMinimapX(snapshot, snapshot.camera.x);
  const y = worldToMinimapY(snapshot, snapshot.camera.y);
  const width = formatNumber(clamp(finiteNumber(snapshot.camera.width, 0), 0, safeDimension(snapshot.mapWidth) - Number(x)));
  const height = formatNumber(clamp(finiteNumber(snapshot.camera.height, 0), 0, safeDimension(snapshot.mapHeight) - Number(y)));
  return `<rect class="minimap-camera" x="${x}" y="${y}" width="${width}" height="${height}"></rect>`;
}

function markerSortOrder(marker: MinimapMarker): number {
  if (marker.kind === "capture-site") {
    return 0;
  }
  if (marker.kind === "camp") {
    return 1;
  }
  if (marker.kind === "building") {
    return 2;
  }
  if (marker.kind === "rally") {
    return 3;
  }
  if (marker.kind === "enemy-hero") {
    return 5;
  }
  return 4;
}

function worldToMinimapX(snapshot: MinimapSnapshot, x: number): string {
  return formatNumber(clamp(finiteNumber(x, 0), 0, safeDimension(snapshot.mapWidth)));
}

function worldToMinimapY(snapshot: MinimapSnapshot, y: number): string {
  return formatNumber(clamp(finiteNumber(y, 0), 0, safeDimension(snapshot.mapHeight)));
}

function minimapUnitScale(snapshot: MinimapSnapshot): number {
  return Math.min(safeDimension(snapshot.mapWidth), safeDimension(snapshot.mapHeight)) / 100;
}

function minimapAriaLabel(snapshot: MinimapSnapshot): string {
  const kinds = new Set(snapshot.markers.map((marker) => marker.kind));
  const categories = [
    kinds.has("unit") || kinds.has("enemy-hero") ? "units" : "",
    kinds.has("building") ? "buildings" : "",
    kinds.has("capture-site") || kinds.has("camp") ? "sites" : ""
  ].filter(Boolean);
  const summary = categories.length > 0 ? ` showing ${categories.join(", ")}` : "";
  return `Battlefield minimap${summary}. Click to move camera.`;
}

function teamColor(team: Team, snapshot: MinimapSnapshot): string {
  return (snapshot.colorblindPalette ? COLORBLIND_TEAM_COLORS : TEAM_COLORS)[team];
}

function teamStroke(team: Team, snapshot: MinimapSnapshot): string {
  return (snapshot.colorblindPalette ? COLORBLIND_TEAM_STROKES : TEAM_STROKES)[team];
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function formatNumber(value: number): string {
  return finiteNumber(value, 0).toFixed(2).replace(/\.00$/, "").replace(/(\.\d)0$/, "$1");
}

function finiteNumber(value: number | undefined, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function safeDimension(value: number): number {
  return Math.max(1, finiteNumber(value, 1));
}

function escapeAttribute(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
