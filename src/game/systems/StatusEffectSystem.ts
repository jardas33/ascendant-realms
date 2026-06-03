import type { ActiveStatusEffect, Team } from "../core/GameTypes";

export interface StatusEffectCarrier {
  statusEffects: ActiveStatusEffect[];
  applyStatusEffect?: (effect: ActiveStatusEffect) => void;
  updateStatusVisual?: () => void;
}

export interface StatusDamageTick {
  effectId: string;
  effectName: string;
  damage: number;
  sourceId?: string;
  sourceTeam?: Team;
}

const EMPTY_STATUS_DAMAGE_TICKS: StatusDamageTick[] = [];

export function createBurnStatus(options: {
  id?: string;
  name?: string;
  damagePerSecond: number;
  durationSeconds: number;
  tickInterval: number;
  sourceId?: string;
  sourceTeam?: Team;
}): ActiveStatusEffect {
  return {
    id: options.id ?? "burn",
    name: options.name ?? "Burn",
    type: "burn",
    damagePerSecond: Math.max(0, options.damagePerSecond),
    durationSeconds: Math.max(0, options.durationSeconds),
    remainingSeconds: Math.max(0, options.durationSeconds),
    tickInterval: Math.max(0.1, options.tickInterval),
    tickTimer: 0,
    sourceId: options.sourceId,
    sourceTeam: options.sourceTeam
  };
}

export function applyStatusEffect(target: StatusEffectCarrier, effect: ActiveStatusEffect): void {
  if (target.applyStatusEffect) {
    target.applyStatusEffect(effect);
    return;
  }
  const existing = target.statusEffects.find((entry) => entry.id === effect.id && entry.sourceId === effect.sourceId);
  if (existing) {
    existing.remainingSeconds = Math.max(existing.remainingSeconds, effect.remainingSeconds);
    existing.durationSeconds = Math.max(existing.durationSeconds, effect.durationSeconds);
    existing.damagePerSecond = Math.max(existing.damagePerSecond, effect.damagePerSecond);
    existing.tickInterval = effect.tickInterval;
    return;
  }
  target.statusEffects.push({ ...effect });
}

export function tickStatusEffects(target: StatusEffectCarrier, deltaSeconds: number): StatusDamageTick[] {
  if (target.statusEffects.length === 0) {
    return EMPTY_STATUS_DAMAGE_TICKS;
  }
  const ticks: StatusDamageTick[] = [];
  let hasExpiredEffect = false;
  target.statusEffects.forEach((effect) => {
    if (effect.remainingSeconds <= 0) {
      hasExpiredEffect = true;
      return;
    }
    const elapsed = Math.min(Math.max(0, deltaSeconds), effect.remainingSeconds);
    effect.remainingSeconds = Math.max(0, effect.remainingSeconds - elapsed);
    if (effect.remainingSeconds <= 0) {
      hasExpiredEffect = true;
    }
    effect.tickTimer += elapsed;
    const tickCount = Math.floor(effect.tickTimer / effect.tickInterval);
    effect.tickTimer -= tickCount * effect.tickInterval;
    for (let tickIndex = 0; tickIndex < tickCount; tickIndex += 1) {
      const damage = Math.max(0, effect.damagePerSecond * effect.tickInterval);
      if (damage > 0) {
        ticks.push({
          effectId: effect.id,
          effectName: effect.name,
          damage,
          sourceId: effect.sourceId,
          sourceTeam: effect.sourceTeam
        });
      }
    }
  });
  if (hasExpiredEffect) {
    target.statusEffects = target.statusEffects.filter((effect) => effect.remainingSeconds > 0);
  }
  target.updateStatusVisual?.();
  return ticks.length > 0 ? ticks : EMPTY_STATUS_DAMAGE_TICKS;
}
