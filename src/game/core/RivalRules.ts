import type { BattleLaunchModifier } from "../battle/BattleLaunchRequest";
import { RIVAL_REWARD_BY_ENEMY_HERO_ID, type RivalFirstDefeatRewardDefinition } from "../data/rivalRewards";
import { createItemInstance } from "./progression/AffixRules";
import { calculateRewardLevelProgress } from "./progression/LevelingRules";
import { heroOwnsRelic } from "./progression/RelicInventoryRules";
import {
  createEligibleRelicRewardChoice,
  selectEligibleRelicRewardDefinition,
  type RelicRewardAcquisition,
  type RelicRewardChoice
} from "./RelicRewardRules";
import type { CampaignNodeDefinition, CombatStats, ResourceBag, ResourceKey } from "./GameTypes";
import { CAMPAIGN_NODE_BY_ID, ENEMY_HERO_BY_ID, FACTION_BY_ID, ITEM_BY_ID } from "../data/contentIndex";
import type {
  CampaignRivalSaveData,
  CampaignSaveData,
  HeroSaveData,
  RivalDisposition,
  RivalLastOutcome,
  RivalModifierId,
  RivalTrophySaveData
} from "../save/SaveTypes";

export interface RivalBattleOutcomeSummary {
  enemyHeroId: string;
  name: string;
  title: string;
  lastOutcome: RivalLastOutcome;
  outcomeLabel: string;
  previousDisposition: RivalDisposition;
  disposition: RivalDisposition;
  dispositionLabel: string;
  encounters: number;
  defeats: number;
  victoriesAgainstPlayer: number;
  consequenceText: string;
  rewardText?: string;
  firstDefeatRewardEarned: boolean;
  duplicateFirstDefeatRewardPrevented: boolean;
  trophyEarned?: RivalTrophySaveData;
  relicReward?: RelicRewardAcquisition;
  relicRewardChoice?: RelicRewardChoice;
  relicRewardText?: string;
  rewardXp: number;
  activeModifiers: RivalModifierId[];
}

export interface RivalNodePreview {
  enemyHeroId: string;
  name: string;
  title: string;
  isKnownToPlayer: boolean;
  lastOutcome: RivalLastOutcome;
  disposition: RivalDisposition;
  summaryText: string;
  effectText: string;
  activeModifiers: RivalModifierId[];
}

export interface RivalIntelEntry {
  enemyHeroId: string;
  name: string;
  title: string;
  encounters: number;
  defeats: number;
  victoriesAgainstPlayer: number;
  lastSeen: string;
  lastOutcomeLabel: string;
  dispositionLabel: string;
  effectText: string;
  trophyLabel?: string;
  firstDefeatRewardClaimed: boolean;
}

export interface RivalTrophyIntelEntry {
  trophyId: string;
  enemyHeroId: string;
  enemyHeroName: string;
  label: string;
  description: string;
  effect?: string;
  earnedAt: string;
  sourceNodeName: string;
}

export function createInitialRivalState(enemyHeroId: string): CampaignRivalSaveData {
  return {
    enemyHeroId,
    encounters: 0,
    defeats: 0,
    victoriesAgainstPlayer: 0,
    lastOutcome: "unseen",
    disposition: "wary",
    activeModifiers: [],
    isKnownToPlayer: false
  };
}

export function getRivalState(campaign: CampaignSaveData, enemyHeroId: string): CampaignRivalSaveData | undefined {
  return campaign.rivals.find((rival) => rival.enemyHeroId === enemyHeroId);
}

export function getKnownRivalIntel(campaign: CampaignSaveData): RivalIntelEntry[] {
  return campaign.rivals
    .filter((rival) => rival.isKnownToPlayer && ENEMY_HERO_BY_ID[rival.enemyHeroId])
    .map((rival) => {
      const hero = ENEMY_HERO_BY_ID[rival.enemyHeroId];
      const trophy = campaign.rivalTrophies.find((entry) => entry.enemyHeroId === rival.enemyHeroId);
      return {
        enemyHeroId: rival.enemyHeroId,
        name: hero.name,
        title: hero.title,
        encounters: rival.encounters,
        defeats: rival.defeats,
        victoriesAgainstPlayer: rival.victoriesAgainstPlayer,
        lastSeen: rival.lastEncounterNodeId ? CAMPAIGN_NODE_BY_ID[rival.lastEncounterNodeId]?.name ?? rival.lastEncounterNodeId : "Not yet",
        lastOutcomeLabel: formatRivalOutcome(rival.lastOutcome),
        dispositionLabel: formatRivalDisposition(rival.disposition),
        effectText: formatRivalModifierSummary(rival.activeModifiers),
        trophyLabel: trophy?.label,
        firstDefeatRewardClaimed: Boolean(trophy)
      };
    })
    .sort((left, right) => left.name.localeCompare(right.name));
}

export function getRivalTrophyIntel(campaign: CampaignSaveData): RivalTrophyIntelEntry[] {
  return campaign.rivalTrophies
    .filter((trophy) => ENEMY_HERO_BY_ID[trophy.enemyHeroId])
    .map((trophy) => ({
      trophyId: trophy.trophyId,
      enemyHeroId: trophy.enemyHeroId,
      enemyHeroName: ENEMY_HERO_BY_ID[trophy.enemyHeroId].name,
      label: trophy.label,
      description: trophy.description,
      effect: trophy.effect,
      earnedAt: trophy.earnedAt,
      sourceNodeName: CAMPAIGN_NODE_BY_ID[trophy.sourceNodeId]?.name ?? trophy.sourceNodeId
    }))
    .sort((left, right) => left.earnedAt.localeCompare(right.earnedAt));
}

export function getRivalNodePreview(campaign: CampaignSaveData, node: CampaignNodeDefinition): RivalNodePreview | undefined {
  if (!node.enemyHeroId) {
    return undefined;
  }
  const hero = ENEMY_HERO_BY_ID[node.enemyHeroId];
  if (!hero) {
    return undefined;
  }
  const state = getRivalState(campaign, hero.id) ?? createInitialRivalState(hero.id);
  const effectText =
    state.activeModifiers.length > 0
      ? formatRivalModifierSummary(state.activeModifiers)
      : state.isKnownToPlayer
        ? "No active rival modifier for this encounter."
        : "First encounter: no rival modifier is active.";
  return {
    enemyHeroId: hero.id,
    name: hero.name,
    title: hero.title,
    isKnownToPlayer: state.isKnownToPlayer,
    lastOutcome: state.lastOutcome,
    disposition: state.disposition,
    summaryText: state.isKnownToPlayer
      ? `${formatRivalOutcome(state.lastOutcome)} - ${formatRivalDisposition(state.disposition)}`
      : "Unseen rival - first encounter",
    effectText,
    activeModifiers: [...state.activeModifiers]
  };
}

export function getRivalBattleLaunchModifiers(campaign: CampaignSaveData, node: CampaignNodeDefinition): BattleLaunchModifier[] {
  if (!node.enemyHeroId) {
    return [];
  }
  const state = getRivalState(campaign, node.enemyHeroId);
  if (!state?.isKnownToPlayer) {
    return [];
  }
  return state.activeModifiers.map((modifierId) => ({
    id: modifierId,
    value: node.enemyHeroId
  }));
}

export function applyRivalModifiersToEnemyHeroStats(
  stats: CombatStats,
  modifiers: BattleLaunchModifier[] = []
): CombatStats {
  const modifierIds = new Set(modifiers.map((modifier) => modifier.id));
  const hpMultiplier = modifierIds.has("rival_wary_hp_5") ? 1.05 : 1;
  const damageMultiplier = modifierIds.has("rival_emboldened_damage_5") ? 1.05 : 1;
  return {
    ...stats,
    maxHp: Math.round(stats.maxHp * hpMultiplier),
    damage: Math.round(stats.damage * damageMultiplier)
  };
}

export function updateRivalAfterBattle(options: {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  enemyHeroId?: string;
  nodeId?: string;
  playerWon: boolean;
  enemyHeroDefeated: boolean;
  acquiredAt?: string;
}): { campaign: CampaignSaveData; hero: HeroSaveData; rivalResult?: RivalBattleOutcomeSummary } {
  const enemyHeroId = options.enemyHeroId;
  if (!enemyHeroId || !ENEMY_HERO_BY_ID[enemyHeroId]) {
    return { campaign: options.campaign, hero: options.hero };
  }

  const heroDefinition = ENEMY_HERO_BY_ID[enemyHeroId];
  const previous = getRivalState(options.campaign, enemyHeroId) ?? createInitialRivalState(enemyHeroId);
  const previousDisposition = previous.disposition;
  let campaign = options.campaign;
  let hero = options.hero;
  let rewardText: string | undefined;
  let rewardXp = 0;
  let firstDefeatRewardEarned = false;
  let duplicateFirstDefeatRewardPrevented = false;
  let trophyEarned: RivalTrophySaveData | undefined;
  let relicReward: RelicRewardAcquisition | undefined;
  let relicRewardChoice: RelicRewardChoice | undefined;
  let relicRewardText: string | undefined;
  let consequenceText = "";
  const next: CampaignRivalSaveData = {
    ...previous,
    encounters: previous.encounters + 1,
    lastEncounterNodeId: options.nodeId ?? previous.lastEncounterNodeId,
    isKnownToPlayer: true
  };

  if (options.playerWon && options.enemyHeroDefeated) {
    const firstDefeat = previous.defeats === 0;
    next.defeats = previous.defeats + 1;
    next.lastOutcome = "defeated";
    next.disposition = firstDefeat ? "humiliated" : "enraged";
    next.activeModifiers = [];
    const reward = RIVAL_REWARD_BY_ENEMY_HERO_ID[enemyHeroId]?.firstDefeat;
    const rewardAlreadyClaimed = reward ? hasRivalTrophy(campaign, reward.trophy.trophyId) : false;
    consequenceText = firstDefeat
      ? `${heroDefinition.name} is humiliated, and the Barrosan Marches celebrate the victory.`
      : `${heroDefinition.name} withdraws with wounded pride. Their first-defeat reward was already claimed.`;
    if (firstDefeat && reward && !rewardAlreadyClaimed) {
      const rewardGrant = grantRivalFirstDefeatReward({
        campaign,
        hero,
        enemyHeroId,
        nodeId: options.nodeId,
        acquiredAt: options.acquiredAt ?? new Date().toISOString(),
        reward
      });
      campaign = rewardGrant.campaign;
      hero = rewardGrant.hero;
      rewardText = rewardGrant.rewardText;
      rewardXp = reward.xp;
      firstDefeatRewardEarned = true;
      trophyEarned = rewardGrant.trophy;
    } else if (reward && (!firstDefeat || rewardAlreadyClaimed)) {
      duplicateFirstDefeatRewardPrevented = true;
    }
    const relicDefinition = selectEligibleRelicRewardDefinition({
      outcome: "victory",
      mode: "campaign_node",
      rewardsDisabled: false,
      enemyHeroId,
      enemyHeroDefeated: true
    });
    const relicItem = relicDefinition ? ITEM_BY_ID[relicDefinition.itemId] : undefined;
    const shouldAttemptRelicGrant = Boolean(
      relicDefinition && relicItem && (firstDefeat || !heroOwnsRelic(hero, relicItem.id, ITEM_BY_ID))
    );
    if (shouldAttemptRelicGrant) {
      const relicChoice = createEligibleRelicRewardChoice({
        hero,
        itemById: ITEM_BY_ID,
        outcome: "victory",
        mode: "campaign_node",
        rewardsDisabled: false,
        enemyHeroId,
        enemyHeroDefeated: true
      });
      relicRewardChoice = relicChoice.choice;
      relicReward = relicChoice.duplicateReward;
      if (relicReward?.duplicateConversion) {
        campaign = addCampaignResourcesLocal(campaign, relicReward.duplicateConversion.resources);
      }
      relicRewardText = relicReward
        ? formatRelicRewardText(relicReward)
        : relicRewardChoice
          ? formatRelicChoiceText(relicRewardChoice)
          : undefined;
    }
  } else if (options.playerWon) {
    next.lastOutcome = "escaped";
    next.disposition = "wary";
    next.activeModifiers = ["rival_wary_hp_5"];
    consequenceText = `${heroDefinition.name} escaped and will brace for the next encounter.`;
  } else {
    next.victoriesAgainstPlayer = previous.victoriesAgainstPlayer + 1;
    next.lastOutcome = "triumphant";
    next.disposition = "emboldened";
    next.activeModifiers = ["rival_emboldened_damage_5"];
    consequenceText = `${heroDefinition.name} is emboldened after driving you back.`;
  }

  const savedCampaign = upsertRivalState(campaign, next);
  return {
    campaign: savedCampaign,
    hero,
    rivalResult: {
      enemyHeroId,
      name: heroDefinition.name,
      title: heroDefinition.title,
      lastOutcome: next.lastOutcome,
      outcomeLabel: formatRivalOutcome(next.lastOutcome),
      previousDisposition,
      disposition: next.disposition,
      dispositionLabel: formatRivalDisposition(next.disposition),
      encounters: next.encounters,
      defeats: next.defeats,
      victoriesAgainstPlayer: next.victoriesAgainstPlayer,
      consequenceText,
      rewardText,
      firstDefeatRewardEarned,
      duplicateFirstDefeatRewardPrevented,
      trophyEarned,
      relicReward,
      relicRewardChoice,
      relicRewardText,
      rewardXp,
      activeModifiers: [...next.activeModifiers]
    }
  };
}

export function formatRivalBattleStartCopy(enemyHeroId: string | undefined, modifiers: BattleLaunchModifier[] = []): string {
  if (!enemyHeroId || modifiers.length === 0) {
    return "";
  }
  const active = modifiers
    .map((modifier) => rivalLaunchModifierName(modifier.id))
    .filter((name): name is string => Boolean(name));
  if (active.length === 0) {
    return "";
  }
  const hero = ENEMY_HERO_BY_ID[enemyHeroId];
  const name = hero?.name ?? enemyHeroId;
  return `Rival warning: ${name} returns with ${active.join(", ")}.`;
}

export function rivalLaunchModifierName(modifierId: string): string | undefined {
  if (modifierId === "rival_wary_hp_5") {
    return "+5% HP";
  }
  if (modifierId === "rival_emboldened_damage_5") {
    return "+5% damage";
  }
  return undefined;
}

export function formatRivalModifierSummary(modifierIds: RivalModifierId[]): string {
  if (modifierIds.length === 0) {
    return "No active rival modifier.";
  }
  return modifierIds.map(formatRivalModifier).join(", ");
}

export function formatRivalModifier(modifierId: RivalModifierId): string {
  if (modifierId === "rival_wary_hp_5") {
    return "+5% HP next encounter";
  }
  return "+5% damage next encounter";
}

export function formatRivalOutcome(outcome: RivalLastOutcome): string {
  switch (outcome) {
    case "escaped":
      return "Escaped";
    case "defeated":
      return "Defeated";
    case "wounded":
      return "Wounded";
    case "triumphant":
      return "Triumphant";
    case "unseen":
    default:
      return "Unseen";
  }
}

export function formatRivalDisposition(disposition: RivalDisposition): string {
  switch (disposition) {
    case "enraged":
      return "Enraged";
    case "humiliated":
      return "Humiliated";
    case "emboldened":
      return "Emboldened";
    case "wary":
    default:
      return "Wary";
  }
}

export function isRivalLastOutcome(value: unknown): value is RivalLastOutcome {
  return value === "unseen" || value === "escaped" || value === "defeated" || value === "wounded" || value === "triumphant";
}

export function isRivalDisposition(value: unknown): value is RivalDisposition {
  return value === "wary" || value === "enraged" || value === "humiliated" || value === "emboldened";
}

export function isRivalModifierId(value: unknown): value is RivalModifierId {
  return value === "rival_wary_hp_5" || value === "rival_emboldened_damage_5";
}

export function formatRivalStateSnapshot(state: CampaignRivalSaveData | undefined): string | null {
  if (!state) {
    return null;
  }
  const modifiers = state.activeModifiers.length > 0 ? `, modifiers ${state.activeModifiers.join("+")}` : "";
  return `${formatRivalOutcome(state.lastOutcome)} / ${formatRivalDisposition(state.disposition)} (${state.encounters} encounters, ${state.defeats} defeats, ${state.victoriesAgainstPlayer} losses${modifiers})`;
}

export function hasRivalTrophy(campaign: CampaignSaveData, trophyId: string): boolean {
  return campaign.rivalTrophies.some((trophy) => trophy.trophyId === trophyId);
}

function upsertRivalState(campaign: CampaignSaveData, state: CampaignRivalSaveData): CampaignSaveData {
  const rivals = campaign.rivals.filter((rival) => rival.enemyHeroId !== state.enemyHeroId);
  return {
    ...campaign,
    rivals: [...rivals, state]
  };
}

function grantRivalFirstDefeatReward(options: {
  campaign: CampaignSaveData;
  hero: HeroSaveData;
  enemyHeroId: string;
  nodeId?: string;
  acquiredAt: string;
  reward: RivalFirstDefeatRewardDefinition;
}): { campaign: CampaignSaveData; hero: HeroSaveData; trophy: RivalTrophySaveData; rewardText: string } {
  let campaign = addCampaignResourcesLocal(options.campaign, options.reward.resources);
  let hero = addHeroXpLocal(options.hero, options.reward.xp);
  if (options.reward.reputation) {
    hero = addHeroReputationLocal(hero, options.reward.reputation.factionId, options.reward.reputation.amount);
  }
  if (options.reward.itemId && !hero.inventory.some((instance) => instance.itemId === options.reward.itemId)) {
    hero = {
      ...hero,
      inventory: [
        ...hero.inventory,
        createItemInstance(options.reward.itemId, `rival_first_defeat:${options.enemyHeroId}`, options.acquiredAt, {
          itemById: ITEM_BY_ID,
          affixes: []
        })
      ]
    };
  }
  const trophy: RivalTrophySaveData = {
    trophyId: options.reward.trophy.trophyId,
    enemyHeroId: options.enemyHeroId,
    earnedAt: options.acquiredAt,
    sourceNodeId: options.nodeId ?? "unknown",
    label: options.reward.trophy.label,
    description: options.reward.trophy.description,
    effect: options.reward.trophy.effect
  };
  campaign = {
    ...campaign,
    rivalTrophies: [...campaign.rivalTrophies.filter((entry) => entry.trophyId !== trophy.trophyId), trophy]
  };
  return {
    campaign,
    hero,
    trophy,
    rewardText: formatRivalFirstDefeatRewardText(options.reward)
  };
}

function addCampaignResourcesLocal(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
  const nextResources = { ...campaign.resources };
  Object.entries(resources).forEach(([resource, amount]) => {
    nextResources[resource as ResourceKey] = nextResources[resource as ResourceKey] + Math.max(0, Math.floor(amount ?? 0));
  });
  return {
    ...campaign,
    resources: nextResources
  };
}

function addHeroXpLocal(hero: HeroSaveData, xp: number): HeroSaveData {
  const progress = calculateRewardLevelProgress(hero, Math.max(0, xp));
  return {
    ...hero,
    xp: progress.nextXp,
    level: progress.newLevel,
    skillPoints: hero.skillPoints + progress.levelsGained
  };
}

function addHeroReputationLocal(hero: HeroSaveData, factionId: string, amount: number): HeroSaveData {
  const current = hero.factionReputation[factionId] ?? 0;
  return {
    ...hero,
    factionReputation: {
      ...hero.factionReputation,
      [factionId]: Math.max(-100, Math.min(100, current + amount))
    }
  };
}

function formatRivalFirstDefeatRewardText(reward: RivalFirstDefeatRewardDefinition): string {
  const parts: string[] = [];
  if (reward.xp > 0) {
    parts.push(`+${reward.xp} XP`);
  }
  parts.push(...formatResourceRewardParts(reward.resources));
  if (reward.itemId) {
    parts.push(ITEM_BY_ID[reward.itemId]?.name ?? reward.itemId);
  }
  if (reward.reputation) {
    const factionName = FACTION_BY_ID[reward.reputation.factionId]?.name ?? reward.reputation.factionId;
    parts.push(`+${reward.reputation.amount} ${factionName} reputation`);
  }
  parts.push(`Trophy: ${reward.trophy.label}`);
  return parts.join(", ");
}

function formatRelicRewardText(reward: RelicRewardAcquisition): string {
  if (reward.status === "duplicate_converted" && reward.duplicateConversion) {
    return `${reward.item.name} already owned; duplicate converted to ${formatResourceRewardParts(
      reward.duplicateConversion.resources
    ).join(", ")}.`;
  }
  return `${reward.item.name} added to inventory. Relic effects are active when equipped.`;
}

function formatRelicChoiceText(choice: RelicRewardChoice): string {
  const optionNames = choice.options.map((option) => option.item.name).join(" or ");
  return `Relic choice available: ${optionNames}. Choose one relic on Results.`;
}

function formatResourceRewardParts(resources: Partial<ResourceBag>): string[] {
  return Object.entries(resources)
    .filter(([, amount]) => (amount ?? 0) > 0)
    .map(([resource, amount]) => `+${Math.floor(amount ?? 0)} ${formatResourceName(resource)}`);
}

function formatResourceName(resource: string): string {
  return resource.charAt(0).toUpperCase() + resource.slice(1);
}
