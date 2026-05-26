import { HERO_CAPTURE_SITE_XP, HERO_XP_SHARE_RADIUS } from "../core/Constants";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import { Hero } from "../entities/Hero";
import { Projectile } from "../entities/Projectile";
import { Unit } from "../entities/Unit";

export class XPSystem {
  private readonly capturedSiteXpIds = new Set<string>();

  constructor(
    private readonly hero: Hero,
    private readonly onXp: (amount: number, leveledUp: boolean) => void
  ) {}

  awardForKill(killer: Unit | Building | Projectile, target: BaseEntity): void {
    if (target.team === "player") {
      return;
    }
    if (distance(this.hero.position, target.position) > HERO_XP_SHARE_RADIUS && killer.id !== this.hero.id) {
      return;
    }

    const xp = this.getXpValue(target);
    if (xp <= 0) {
      return;
    }
    const result = this.hero.addXp(xp);
    this.onXp(xp, result.leveledUp);
  }

  awardForCaptureSite(site: CaptureSite): void {
    if (!site.alive || site.owner !== this.hero.team || this.capturedSiteXpIds.has(site.definition.id)) {
      return;
    }
    this.capturedSiteXpIds.add(site.definition.id);
    const result = this.hero.addXp(HERO_CAPTURE_SITE_XP);
    this.onXp(HERO_CAPTURE_SITE_XP, result.leveledUp);
  }

  private getXpValue(target: BaseEntity): number {
    if (target instanceof Unit) {
      return target.definition.xpValue;
    }
    if (target instanceof Building) {
      return target.definition.xpValue;
    }
    return 0;
  }
}
