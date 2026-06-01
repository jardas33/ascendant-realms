import type { BattleMapDefinition, Position } from "../core/GameTypes";

export interface CameraViewportSize {
  width: number;
  height: number;
  zoom: number;
}

export function clampCameraCenterPosition(
  position: Position,
  map: Pick<BattleMapDefinition, "width" | "height">,
  viewport: CameraViewportSize
): Position {
  const zoom = Math.max(0.01, viewport.zoom);
  const visibleWidth = Math.min(map.width, viewport.width / zoom);
  const visibleHeight = Math.min(map.height, viewport.height / zoom);
  const halfWidth = visibleWidth / 2;
  const halfHeight = visibleHeight / 2;
  return {
    x: map.width <= visibleWidth ? map.width / 2 : clamp(position.x, halfWidth, map.width - halfWidth),
    y: map.height <= visibleHeight ? map.height / 2 : clamp(position.y, halfHeight, map.height - halfHeight)
  };
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}
