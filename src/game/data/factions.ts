import type { FactionDefinition } from "../core/GameTypes";

export const FACTIONS: FactionDefinition[] = [
  {
    id: "free_marches",
    name: "The Free Marches",
    fantasy: "Border-town militias, scouts, and oathbound mystics fighting for self-rule.",
    color: 0x4f8f68
  },
  {
    id: "ashen_covenant",
    name: "Ashen Covenant",
    fantasy: "A ruthless warband culture built around raiders, hex-magic, and brutal champions.",
    color: 0xb64b42
  },
  {
    id: "sylvan_concord",
    name: "Sylvan Concord",
    fantasy: "Future faction: forest spirits, wardens, beasts, and living sanctuaries.",
    color: 0x6ab06e
  },
  {
    id: "wilds",
    name: "Untamed Wilds",
    fantasy: "Neutral beasts and wandering monsters that guard old places of power.",
    color: 0x8b6f43
  }
];
