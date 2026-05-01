export type Team = "player" | "enemy" | "neutral";

export type EntityKind = "unit" | "hero" | "building" | "projectile" | "capture-site";

export type VisibilityState = "unseen" | "explored" | "visible";

export interface Position {
  x: number;
  y: number;
}

export interface Size {
  width: number;
  height: number;
}
