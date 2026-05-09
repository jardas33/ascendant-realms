export type BattleStatusPriority = "normal" | "pressure" | "objective";

export interface BattleStatusOptions {
  durationSeconds?: number;
  priority?: BattleStatusPriority;
}

const BATTLE_STATUS_PRIORITY_RANK: Record<BattleStatusPriority, number> = {
  normal: 0,
  pressure: 1,
  objective: 2
};

export function shouldReplaceBattleStatus(options: {
  currentPriority: BattleStatusPriority;
  currentTimerSeconds: number;
  incomingPriority: BattleStatusPriority;
}): boolean {
  if (options.currentTimerSeconds <= 0) {
    return true;
  }
  return BATTLE_STATUS_PRIORITY_RANK[options.incomingPriority] >= BATTLE_STATUS_PRIORITY_RANK[options.currentPriority];
}

export function battleStatusDurationSeconds(priority: BattleStatusPriority): number {
  if (priority === "objective") {
    return 4;
  }
  return priority === "pressure" ? 4.5 : 2.5;
}
