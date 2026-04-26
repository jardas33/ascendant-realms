import type { OriginDefinition } from "../core/GameTypes";

export const ORIGINS: OriginDefinition[] = [
  {
    id: "exiled_noble",
    name: "Exiled Noble",
    description: "Raised for command, stripped of title, and hungry for a second banner.",
    statMods: {
      command: 2,
      maxHp: 10
    }
  },
  {
    id: "temple_orphan",
    name: "Temple Orphan",
    description: "Sheltered by priests, trained to hear omens in the quiet between wars.",
    statMods: {
      faith: 2,
      maxMana: 15
    }
  },
  {
    id: "wildland_raider",
    name: "Wildland Raider",
    description: "A survivor of border raids who moves fast and strikes first.",
    statMods: {
      might: 1,
      speed: 8,
      damage: 2
    }
  }
];
