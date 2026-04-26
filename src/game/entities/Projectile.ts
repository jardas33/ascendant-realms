import Phaser from "phaser";
import type { Position, Team } from "../core/GameTypes";
import { BaseEntity } from "./BaseEntity";

export class Projectile extends BaseEntity {
  readonly sourceId: string;
  readonly targetId: string;
  readonly damage: number;
  readonly speed: number;
  readonly color: number;

  constructor(scene: Phaser.Scene, options: {
    sourceId: string;
    targetId: string;
    team: Team;
    x: number;
    y: number;
    damage: number;
    speed: number;
    color: number;
  }) {
    super({
      kind: "projectile",
      team: options.team,
      x: options.x,
      y: options.y,
      radius: 5,
      maxHp: 1,
      armor: 0
    });
    this.sourceId = options.sourceId;
    this.targetId = options.targetId;
    this.damage = options.damage;
    this.speed = options.speed;
    this.color = options.color;
    this.createCommonView(scene, "", options.color, false);
    this.view?.addAt(scene.add.circle(0, 0, 5, options.color, 1), 0);
    this.view?.setDepth(20);
  }

  moveToward(target: Position, deltaSeconds: number): boolean {
    const dx = target.x - this.position.x;
    const dy = target.y - this.position.y;
    const dist = Math.hypot(dx, dy);
    if (dist < 12) {
      return true;
    }
    const step = Math.min(dist, this.speed * deltaSeconds);
    this.setPosition(this.position.x + (dx / dist) * step, this.position.y + (dy / dist) * step);
    return false;
  }
}
