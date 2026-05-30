import type { Act1FinalePhaseId, BattlefieldEventId, TacticalPlanId } from "../core/GameTypes";

export const ACT1_FINALE_NODE_ID = "ashen_outpost";
export const ACT1_FINALE_MAP_ID = "ashen_outpost";
export const ACT1_FINALE_COMMANDER_ID = "captain_malrec";

export interface Act1FinalePhaseDefinition {
  id: Act1FinalePhaseId;
  order: number;
  title: string;
  objective: string;
  completionHint: string;
  recommendedPlanId: TacticalPlanId;
  preferredEventIds: BattlefieldEventId[];
}

export const ACT1_FINALE_PHASES: Act1FinalePhaseDefinition[] = [
  {
    id: "secure_foothold",
    order: 1,
    title: "Phase 1: Secure the Foothold",
    objective: "Capture the Burned Shrine or another resource site before the outpost counter-pressure builds.",
    completionHint: "Foothold secured",
    recommendedPlanId: "resource_push",
    preferredEventIds: ["site_under_threat", "hold_the_line"]
  },
  {
    id: "break_fortified_line",
    order: 2,
    title: "Phase 2: Break the Fortified Line",
    objective: "Destroy the enemy Barracks and weather the elite counter-pressure.",
    completionHint: "Fortified line broken",
    recommendedPlanId: "guarded_advance",
    preferredEventIds: ["elite_strike", "hold_the_line"]
  },
  {
    id: "defeat_rival_commander",
    order: 3,
    title: "Phase 3: Defeat Captain Malrec",
    objective: "Captain Malrec commits to the final defense. Defeat him and destroy the Stronghold.",
    completionHint: "Commander defeated",
    recommendedPlanId: "champion_hunt",
    preferredEventIds: ["reinforcement_window", "aether_surge"]
  }
];

export const ACT1_FINALE_PHASE_BY_ID: Record<Act1FinalePhaseId, Act1FinalePhaseDefinition> =
  ACT1_FINALE_PHASES.reduce(
    (index, phase) => {
      index[phase.id] = phase;
      return index;
    },
    {} as Record<Act1FinalePhaseId, Act1FinalePhaseDefinition>
  );

export function isAct1FinaleBattle(options: {
  mode?: string;
  campaignNodeId?: string;
  mapId?: string;
  rewardsDisabled?: boolean;
}): boolean {
  return (
    options.mode === "campaign_node" &&
    options.campaignNodeId === ACT1_FINALE_NODE_ID &&
    options.mapId === ACT1_FINALE_MAP_ID &&
    options.rewardsDisabled !== true
  );
}

export function formatAct1FinalePhaseNames(phaseIds: readonly string[] | undefined): string {
  if (!phaseIds || phaseIds.length === 0) {
    return "None";
  }
  return phaseIds
    .map((phaseId) => ACT1_FINALE_PHASE_BY_ID[phaseId as Act1FinalePhaseId]?.title.replace(/^Phase \d+: /u, "") ?? phaseId)
    .join(", ");
}
