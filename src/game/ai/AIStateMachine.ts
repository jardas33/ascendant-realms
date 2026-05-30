export type AIState =
  | "EXPAND"
  | "BUILD_ARMY"
  | "ATTACK"
  | "DEFEND"
  | "RETREAT"
  | "CONTEST_SITE"
  | "RAID_SITE"
  | "HUNTER_PRESSURE"
  | "UPGRADE_SITE"
  | "FORTIFY_BASE"
  | "TECH_UP"
  | "ESCALATE";

export class AIStateMachine {
  current: AIState = "EXPAND";

  set(state: AIState): void {
    this.current = state;
  }
}
