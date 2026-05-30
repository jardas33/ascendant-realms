import type { BattleLaunchModifier } from "../battle/BattleLaunchRequest";
import type { EnemyDoctrineId, ResourceBag, TacticalPlanDefinition, TacticalPlanId } from "../core/GameTypes";

export const DEFAULT_TACTICAL_PLAN_ID: TacticalPlanId = "guarded_advance";

export const TACTICAL_PLAN_MODIFIER_IDS = {
  guardedAdvance: "tactical_guarded_advance",
  resourcePush: "tactical_resource_push",
  championHunt: "tactical_champion_hunt"
} as const;

export interface TacticalPlanBattleEffects {
  startingResources: Partial<ResourceBag>;
  heroMaxManaMultiplier: number;
  retinueReinforcementCostMultiplier: number;
}

export const TACTICAL_PLANS: TacticalPlanDefinition[] = [
  {
    id: "guarded_advance",
    name: "Guarded Advance",
    shortLabel: "Guarded",
    description: "Default safe plan: protect Workers, sites, hero, and Retinue before committing.",
    effectSummary: "Call Retinue costs 60 Crowns instead of 75 in eligible campaign battles.",
    hudSummary: "Guarded Advance active: Retinue call costs less.",
    afterActionSummary: "Defensive plan used; Retinue reinforcement support was available for the fight.",
    recommendedDoctrineIds: ["raider", "hunter", "warband"],
    recommendedCounterplay: "Use this when raids, hero probes, or late pushes threaten exposed units.",
    tags: ["defensive", "retinue", "safe default"],
    launchModifierId: TACTICAL_PLAN_MODIFIER_IDS.guardedAdvance
  },
  {
    id: "resource_push",
    name: "Resource Push",
    shortLabel: "Economy",
    description: "Economy opener: capture and upgrade sites earlier, then convert resources into army.",
    effectSummary: "Start with +35 Crowns and +20 Stone in eligible campaign battles.",
    hudSummary: "Resource Push active: extra Crowns and Stone at start.",
    afterActionSummary: "Economy plan used; early resource support helped the opening build.",
    recommendedDoctrineIds: ["raider", "fortress"],
    recommendedCounterplay: "Use this into Fortress defenses or when you want more site-control tempo.",
    tags: ["economy", "site control", "production"],
    launchModifierId: TACTICAL_PLAN_MODIFIER_IDS.resourcePush
  },
  {
    id: "champion_hunt",
    name: "Champion Hunt",
    shortLabel: "Champion",
    description: "Commander-target plan: keep the army near the hero and commit when the commander is exposed.",
    effectSummary: "Hero starts with +6% maximum Mana in eligible campaign battles.",
    hudSummary: "Champion Hunt active: hero starts with extra Mana.",
    afterActionSummary: "Champion plan used; hero ability readiness was improved for commander pressure.",
    recommendedDoctrineIds: ["hunter", "warband"],
    recommendedCounterplay: "Use this when a commander, Hunter probe, or late Warband push is the main threat.",
    tags: ["hero", "commander", "ability readiness"],
    launchModifierId: TACTICAL_PLAN_MODIFIER_IDS.championHunt
  }
];

export const TACTICAL_PLAN_BY_ID = Object.fromEntries(TACTICAL_PLANS.map((plan) => [plan.id, plan])) as Record<
  TacticalPlanId,
  TacticalPlanDefinition
>;

const TACTICAL_PLAN_BY_MODIFIER_ID = Object.fromEntries(TACTICAL_PLANS.map((plan) => [plan.launchModifierId, plan])) as Record<
  string,
  TacticalPlanDefinition | undefined
>;

const DOCTRINE_RECOMMENDATIONS: Record<EnemyDoctrineId, TacticalPlanId[]> = {
  raider: ["guarded_advance", "resource_push"],
  fortress: ["resource_push", "guarded_advance"],
  hunter: ["guarded_advance", "champion_hunt"],
  warband: ["guarded_advance", "champion_hunt"]
};

export function isTacticalPlanId(value: string | undefined): value is TacticalPlanId {
  return Boolean(value && value in TACTICAL_PLAN_BY_ID);
}

export function normalizeTacticalPlanId(value: string | undefined): TacticalPlanId {
  return isTacticalPlanId(value) ? value : DEFAULT_TACTICAL_PLAN_ID;
}

export function getTacticalPlan(value: string | undefined): TacticalPlanDefinition {
  return TACTICAL_PLAN_BY_ID[normalizeTacticalPlanId(value)];
}

export function getTacticalPlanRecommendations(doctrineId?: EnemyDoctrineId): TacticalPlanDefinition[] {
  const ids = doctrineId ? DOCTRINE_RECOMMENDATIONS[doctrineId] : [DEFAULT_TACTICAL_PLAN_ID];
  return ids.map((id) => TACTICAL_PLAN_BY_ID[id]);
}

export function formatTacticalPlanRecommendation(doctrineId?: EnemyDoctrineId): string {
  return getTacticalPlanRecommendations(doctrineId)
    .map((plan) => plan.name)
    .join(" or ");
}

export function tacticalPlanMatchesDoctrine(planId: string | undefined, doctrineId?: EnemyDoctrineId): boolean {
  if (!doctrineId) {
    return normalizeTacticalPlanId(planId) === DEFAULT_TACTICAL_PLAN_ID;
  }
  return DOCTRINE_RECOMMENDATIONS[doctrineId].includes(normalizeTacticalPlanId(planId));
}

export function getTacticalPlanLaunchModifiers(planId: string | undefined): BattleLaunchModifier[] {
  return [{ id: getTacticalPlan(planId).launchModifierId }];
}

export function addTacticalPlanLaunchModifier(
  modifiers: readonly BattleLaunchModifier[] = [],
  planId: string | undefined
): BattleLaunchModifier[] {
  const plan = getTacticalPlan(planId);
  const withoutPlans = modifiers.filter((modifier) => !TACTICAL_PLAN_BY_MODIFIER_ID[modifier.id]);
  return [...withoutPlans, { id: plan.launchModifierId }];
}

export function tacticalPlanFromLaunchModifiers(
  modifiers: readonly BattleLaunchModifier[] = []
): TacticalPlanDefinition | undefined {
  return modifiers.map((modifier) => TACTICAL_PLAN_BY_MODIFIER_ID[modifier.id]).find(Boolean);
}

export function getTacticalPlanBattleEffects(
  modifiers: readonly BattleLaunchModifier[] = []
): TacticalPlanBattleEffects {
  const plan = tacticalPlanFromLaunchModifiers(modifiers);
  return {
    startingResources: plan?.id === "resource_push" ? { crowns: 35, stone: 20 } : {},
    heroMaxManaMultiplier: plan?.id === "champion_hunt" ? 1.06 : 1,
    retinueReinforcementCostMultiplier: plan?.id === "guarded_advance" ? 0.8 : 1
  };
}
