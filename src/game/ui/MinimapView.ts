import type { ResourceKey, Team, VisibilityState } from "../core/GameTypes";

export type MinimapMarkerKind = "unit" | "building" | "capture-site" | "camp" | "rally";

export interface MinimapMarker {
  id: string;
  kind: MinimapMarkerKind;
  team: Team;
  x: number;
  y: number;
  size?: number;
  resource?: ResourceKey;
  resourceColor?: string;
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

export function renderMinimap(snapshot: MinimapSnapshot): string {
  const markers = [...snapshot.markers].sort((left, right) => markerSortOrder(left) - markerSortOrder(right));
  return `
    <div class="mini-map" data-minimap="true" role="button" aria-label="Minimap">
      <svg class="minimap-svg" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
        <rect class="minimap-terrain" x="0" y="0" width="100" height="100"></rect>
        <rect class="minimap-bounds" x="0.5" y="0.5" width="99" height="99"></rect>
        ${renderFog(snapshot)}
        ${markers.map((marker) => renderMarker(snapshot, marker)).join("")}
        ${snapshot.pings.map((ping) => renderPing(snapshot, ping)).join("")}
        ${renderCamera(snapshot)}
      </svg>
    </div>
  `;
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
      const width = formatNumber(clamp((cell.width / snapshot.mapWidth) * 100, 0, 100));
      const height = formatNumber(clamp((cell.height / snapshot.mapHeight) * 100, 0, 100));
      const opacity = cell.state === "unseen" ? 0.78 : 0.34;
      return `<rect class="minimap-fog ${cell.state}" x="${x}" y="${y}" width="${width}" height="${height}" fill="#020503" opacity="${formatNumber(opacity)}"></rect>`;
    })
    .join("");
}

function renderMarker(snapshot: MinimapSnapshot, marker: MinimapMarker): string {
  const x = worldToMinimapX(snapshot, marker.x);
  const y = worldToMinimapY(snapshot, marker.y);
  if (marker.kind === "capture-site") {
    const color = marker.resourceColor ?? "#f5efc2";
    const fill = marker.team === "neutral" ? "transparent" : teamColor(marker.team);
    const opacity = marker.team === "neutral" ? 0 : 0.26;
    return `<circle class="minimap-site" cx="${x}" cy="${y}" r="3.2" fill="${fill}" fill-opacity="${opacity}" stroke="${color}" stroke-width="1.25"></circle>`;
  }

  if (marker.kind === "building") {
    const size = formatNumber(marker.size ?? 3.6);
    const half = formatNumber((marker.size ?? 3.6) / 2);
    return `<rect class="minimap-building" x="${formatNumber(Number(x) - Number(half))}" y="${formatNumber(Number(y) - Number(half))}" width="${size}" height="${size}" rx="0.5" fill="${teamColor(marker.team)}" stroke="${teamStroke(marker.team)}" stroke-width="0.6"></rect>`;
  }

  if (marker.kind === "camp") {
    const radius = marker.size ?? 2.4;
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
        <circle cx="${x}" cy="${y}" r="2.2" fill="#11351f" stroke="#9cf7b1" stroke-width="0.65"></circle>
        <path d="M ${x} ${formatNumber(Number(y) + 2.8)} L ${x} ${formatNumber(Number(y) - 4)} L ${formatNumber(Number(x) + 4.2)} ${formatNumber(Number(y) - 2.5)} L ${x} ${formatNumber(Number(y) - 1)} Z" fill="#78dc7b" stroke="#f5efc2" stroke-width="0.45"></path>
      </g>
    `;
  }

  return `<circle class="minimap-unit" cx="${x}" cy="${y}" r="${formatNumber(marker.size ?? 1.35)}" fill="${teamColor(marker.team)}" stroke="${teamStroke(marker.team)}" stroke-width="0.45"></circle>`;
}

function renderPing(snapshot: MinimapSnapshot, ping: MinimapPing): string {
  const progress = clamp(ping.ageSeconds / Math.max(0.01, ping.durationSeconds), 0, 1);
  const opacity = formatNumber(0.9 * (1 - progress));
  const radius = formatNumber(2.2 + progress * 9);
  return `
    <g class="minimap-ping" aria-label="${escapeAttribute(ping.label)}">
      <circle cx="${worldToMinimapX(snapshot, ping.x)}" cy="${worldToMinimapY(snapshot, ping.y)}" r="${radius}" fill="none" stroke="${escapeAttribute(ping.color)}" stroke-width="1.25" opacity="${opacity}"></circle>
      <circle cx="${worldToMinimapX(snapshot, ping.x)}" cy="${worldToMinimapY(snapshot, ping.y)}" r="1.25" fill="${escapeAttribute(ping.color)}" opacity="${opacity}"></circle>
    </g>
  `;
}

function renderCamera(snapshot: MinimapSnapshot): string {
  const x = worldToMinimapX(snapshot, snapshot.camera.x);
  const y = worldToMinimapY(snapshot, snapshot.camera.y);
  const width = formatNumber(clamp((snapshot.camera.width / snapshot.mapWidth) * 100, 0, 100));
  const height = formatNumber(clamp((snapshot.camera.height / snapshot.mapHeight) * 100, 0, 100));
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
  return 4;
}

function worldToMinimapX(snapshot: MinimapSnapshot, x: number): string {
  return formatNumber(clamp((x / snapshot.mapWidth) * 100, 0, 100));
}

function worldToMinimapY(snapshot: MinimapSnapshot, y: number): string {
  return formatNumber(clamp((y / snapshot.mapHeight) * 100, 0, 100));
}

function teamColor(team: Team): string {
  return TEAM_COLORS[team];
}

function teamStroke(team: Team): string {
  return TEAM_STROKES[team];
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function formatNumber(value: number): string {
  return Number(value.toFixed(2)).toString();
}

function escapeAttribute(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
