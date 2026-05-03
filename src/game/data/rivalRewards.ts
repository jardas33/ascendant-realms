import type { ResourceBag } from "../core/GameTypes";

export interface RivalTrophyDefinition {
  trophyId: string;
  label: string;
  description: string;
  effect?: string;
}

export interface RivalReputationReward {
  factionId: string;
  amount: number;
}

export interface RivalFirstDefeatRewardDefinition {
  xp: number;
  resources: Partial<ResourceBag>;
  itemId?: string;
  reputation?: RivalReputationReward;
  trophy: RivalTrophyDefinition;
}

export interface RivalRewardDefinition {
  enemyHeroId: string;
  firstDefeat: RivalFirstDefeatRewardDefinition;
}

export const RIVAL_REWARDS: RivalRewardDefinition[] = [
  {
    enemyHeroId: "gorak_emberhand",
    firstDefeat: {
      xp: 80,
      resources: {
        crowns: 25,
        iron: 15
      },
      itemId: "ember_raider_blade",
      reputation: {
        factionId: "free_marches",
        amount: 2
      },
      trophy: {
        trophyId: "trophy_gorak_emberbrand",
        label: "Gorak's Emberbrand",
        description: "A scorched raider brand taken from Gorak Emberhand's warband.",
        effect: "One-time first-defeat reward claimed: +25 Crowns, +15 Iron, +80 XP, and +2 Free Marches reputation."
      }
    }
  },
  {
    enemyHeroId: "veyra_cinders",
    firstDefeat: {
      xp: 90,
      resources: {
        aether: 20
      },
      itemId: "cinderseer_lens",
      reputation: {
        factionId: "old_faith",
        amount: 1
      },
      trophy: {
        trophyId: "trophy_veyra_cinder_lens",
        label: "Cinder-Seer's Cracked Lens",
        description: "A cracked aether lens recovered after Veyra of the Cinders was driven from the ruins.",
        effect: "One-time first-defeat reward claimed: +20 Aether, +90 XP, and +1 Old Faith reputation."
      }
    }
  },
  {
    enemyHeroId: "captain_malrec",
    firstDefeat: {
      xp: 140,
      resources: {
        crowns: 60,
        iron: 25
      },
      itemId: "malrecs_bastion_sigil",
      reputation: {
        factionId: "free_marches",
        amount: 4
      },
      trophy: {
        trophyId: "trophy_malrec_outpost_standard",
        label: "Malrec's Outpost Standard",
        description: "The torn fortress standard of Captain Malrec's Ashen Outpost command.",
        effect: "Milestone one-time first-defeat reward claimed: +60 Crowns, +25 Iron, +140 XP, and +4 Free Marches reputation."
      }
    }
  }
];

export const RIVAL_REWARD_BY_ENEMY_HERO_ID: Record<string, RivalRewardDefinition> = Object.fromEntries(
  RIVAL_REWARDS.map((reward) => [reward.enemyHeroId, reward])
);
