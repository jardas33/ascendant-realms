export type ResourceKey = "crowns" | "stone" | "iron" | "aether";

export type ResourceBag = Record<ResourceKey, number>;

export interface Cost {
  crowns?: number;
  stone?: number;
  iron?: number;
  aether?: number;
}

export interface ResourceDefinition {
  id: ResourceKey;
  name: string;
  color: number;
  description: string;
}
