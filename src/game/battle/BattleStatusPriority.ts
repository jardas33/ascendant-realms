export type BattleStatusCategory = "critical" | "important" | "routine" | "debug";
export type BattleStatusPriority =
  | "normal"
  | "command"
  | "pressure"
  | "objective"
  | "critical"
  | "important"
  | "routine"
  | "debug";

export interface BattleStatusOptions {
  durationSeconds?: number;
  priority?: BattleStatusPriority;
}

export interface BattleStatusPresentation {
  category: BattleStatusCategory;
  rank: number;
  durationSeconds: number;
  cssClass: string;
  visible: boolean;
}

const BATTLE_STATUS_PRIORITY_RANK: Record<BattleStatusPriority, number> = {
  debug: -1,
  normal: 0,
  routine: 1,
  command: 1,
  important: 2,
  objective: 2,
  critical: 3,
  pressure: 3
};

const BATTLE_STATUS_CATEGORY: Record<BattleStatusPriority, BattleStatusCategory> = {
  debug: "debug",
  normal: "routine",
  routine: "routine",
  command: "routine",
  important: "important",
  objective: "important",
  critical: "critical",
  pressure: "critical"
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
  if (battleStatusCategory(priority) === "important") {
    return 4;
  }
  if (priority === "command" || priority === "routine") {
    return 3.25;
  }
  if (battleStatusCategory(priority) === "critical") {
    return 4.5;
  }
  return 2.5;
}

export function battleStatusCategory(priority: BattleStatusPriority): BattleStatusCategory {
  return BATTLE_STATUS_CATEGORY[priority];
}

export function battleStatusPresentation(priority: BattleStatusPriority): BattleStatusPresentation {
  const category = battleStatusCategory(priority);
  return {
    category,
    rank: BATTLE_STATUS_PRIORITY_RANK[priority],
    durationSeconds: battleStatusDurationSeconds(priority),
    cssClass: `status-${category}`,
    visible: category !== "debug"
  };
}

export function shouldDisplayBattleStatus(priority: BattleStatusPriority, debugEnabled = false): boolean {
  return battleStatusCategory(priority) !== "debug" || debugEnabled;
}

export function battleStatusDedupeSeconds(priority: BattleStatusPriority): number {
  const category = battleStatusCategory(priority);
  if (category === "routine") {
    return 1.4;
  }
  if (category === "important") {
    return 0.65;
  }
  return 0;
}

export function formatBattleStatusMessage(message: string, priority: BattleStatusPriority): string {
  if (battleStatusCategory(priority) !== "routine") {
    return message;
  }
  return message
    .replace(/^Move order accepted: /, "Move: ")
    .replace(/^Group move accepted: /, "Group move: ")
    .replace(/^Attack order accepted: /, "Attack: ")
    .replace(/^Construction order accepted: /, "Build: ")
    .replace(/^Repair order accepted: /, "Repair: ")
    .replace(/^Worker assignment accepted: /, "Worker assigned: ")
    .replace(/^Training queued: /, "Queued: ")
    .replace(/^Research queued: /, "Research: ");
}
