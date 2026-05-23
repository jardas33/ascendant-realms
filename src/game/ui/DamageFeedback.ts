import Phaser from "phaser";
import type { Team } from "../core/GameTypes";
import type { BaseEntity } from "../entities/BaseEntity";
import { FloatingText } from "./FloatingText";

export interface DamageFeedbackView {
  text: string;
  color: string;
  yOffset: number;
}

const DEFAULT_DAMAGE_THRESHOLD = 5;
const PLAYER_DAMAGE_THRESHOLD = 1;

export function createDamageFeedbackView(
  targetTeam: Team,
  amount: number,
  options: { threshold?: number } = {}
): DamageFeedbackView | undefined {
  const roundedAmount = Math.round(amount);
  const threshold = options.threshold ?? (targetTeam === "player" ? PLAYER_DAMAGE_THRESHOLD : DEFAULT_DAMAGE_THRESHOLD);
  if (roundedAmount < threshold) {
    return undefined;
  }

  if (targetTeam === "player") {
    return {
      text: `-${roundedAmount}`,
      color: "#ff5f67",
      yOffset: -12
    };
  }

  return {
    text: `-${roundedAmount}`,
    color: "#ffb1a9",
    yOffset: 0
  };
}

export function showDamageFeedback(
  scene: Phaser.Scene,
  target: BaseEntity,
  amount: number,
  options: { threshold?: number } = {}
): void {
  const feedback = createDamageFeedbackView(target.team, amount, options);
  if (!feedback) {
    return;
  }

  FloatingText.show(scene, feedback.text, target.position.x, target.position.y - target.radius + feedback.yOffset, feedback.color);
}
