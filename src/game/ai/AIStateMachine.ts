export type AIState = "EXPAND" | "BUILD_ARMY" | "ATTACK" | "DEFEND" | "RETREAT" | "CONTEST_SITE" | "RAID_SITE" | "UPGRADE_SITE";

export class AIStateMachine {
  current: AIState = "EXPAND";

  set(state: AIState): void {
    this.current = state;
  }
}
