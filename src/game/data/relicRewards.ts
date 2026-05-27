import type { ResourceBag } from "../core/GameTypes";

export type RelicRewardPersistenceStatus = "preview_only";

export interface RelicRewardDefinition {
  id: string;
  name: string;
  sourceEnemyHeroId: string;
  sourceLabel: string;
  description: string;
  effectLabel: string;
  persistenceStatus: RelicRewardPersistenceStatus;
  previewXp: number;
  previewResources: Partial<ResourceBag>;
  tags: string[];
}

export const RELIC_REWARD_DEFINITIONS: RelicRewardDefinition[] = [
  {
    id: "emberbrand_shard",
    name: "Emberbrand Shard",
    sourceEnemyHeroId: "gorak_emberhand",
    sourceLabel: "Gorak Emberhand first-defeat relic candidate",
    description: "A scorched command shard that marks the raider captain's broken charge.",
    effectLabel: "Preview effect: +15 hero XP and +10 Iron when relic persistence is added.",
    persistenceStatus: "preview_only",
    previewXp: 15,
    previewResources: { iron: 10 },
    tags: ["rival", "xp", "iron"]
  },
  {
    id: "cinderseer_focus",
    name: "Cinder-Seer Focus",
    sourceEnemyHeroId: "veyra_cinders",
    sourceLabel: "Veyra of the Cinders first-defeat relic candidate",
    description: "A cracked emberglass focus that still holds a disciplined hexfire pattern.",
    effectLabel: "Preview effect: +15 hero XP and +10 Aether when relic persistence is added.",
    persistenceStatus: "preview_only",
    previewXp: 15,
    previewResources: { aether: 10 },
    tags: ["rival", "xp", "aether"]
  },
  {
    id: "outpost_command_signet",
    name: "Outpost Command Signet",
    sourceEnemyHeroId: "captain_malrec",
    sourceLabel: "Captain Malrec first-defeat relic candidate",
    description: "A compact field signet used to hold an Ashen outpost line together.",
    effectLabel: "Preview effect: +20 hero XP and +15 Crowns when relic persistence is added.",
    persistenceStatus: "preview_only",
    previewXp: 20,
    previewResources: { crowns: 15 },
    tags: ["rival", "xp", "crowns"]
  }
];

export const RELIC_REWARD_BY_ENEMY_HERO_ID: Record<string, RelicRewardDefinition> = Object.fromEntries(
  RELIC_REWARD_DEFINITIONS.map((reward) => [reward.sourceEnemyHeroId, reward])
);
