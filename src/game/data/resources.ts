import type { ResourceDefinition } from "../core/GameTypes";

export const RESOURCE_DEFINITIONS: ResourceDefinition[] = [
  {
    id: "crowns",
    name: "Crowns",
    color: 0xf2c14e,
    description: "Currency used for units, buildings, and campaign payments."
  },
  {
    id: "stone",
    name: "Stone",
    color: 0x9da3a4,
    description: "Building material used for halls, towers, and lodges."
  },
  {
    id: "iron",
    name: "Iron",
    color: 0xc96f53,
    description: "Military material used for weapons and armored troops."
  },
  {
    id: "aether",
    name: "Aether",
    color: 0x74d3f2,
    description: "Magic resource used for spells, rituals, and arcane units."
  }
];
