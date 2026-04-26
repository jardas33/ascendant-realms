export type AIState = "EXPAND" | "BUILD_ARMY" | "ATTACK" | "DEFEND" | "RETREAT";

export class AIStateMachine {
  current: AIState = "EXPAND";

  set(state: AIState): void {
    this.current = state;
  }
}
