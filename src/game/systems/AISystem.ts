import { EnemyAIController } from "../ai/EnemyAIController";

export class AISystem {
  constructor(private readonly controller: EnemyAIController) {}

  update(deltaSeconds: number): void {
    this.controller.update(deltaSeconds);
  }

  adjustNextAttackTiming(seconds: number): void {
    this.controller.adjustNextAttackTiming(seconds);
  }

  get state(): string {
    return this.controller.state.current;
  }
}
