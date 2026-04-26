import Phaser from "phaser";
import type { FactionModifierDefinition } from "../core/GameTypes";
import { FACTION_BY_ID } from "../data/contentIndex";
import type { BaseEntity } from "../entities/BaseEntity";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";
import type { BattleRuntime } from "./BattleRuntime";
import type { MinimapPing } from "../ui/MinimapView";

export interface TrackedEnemyWave {
  id: number;
  unitIds: string[];
}

export function updateMinimapPings(pings: MinimapPing[], deltaSeconds: number): MinimapPing[] {
  return pings
    .map((ping) => ({ ...ping, ageSeconds: ping.ageSeconds + deltaSeconds }))
    .filter((ping) => ping.ageSeconds < ping.durationSeconds);
}

export function appendMinimapPing(
  pings: MinimapPing[],
  nextId: number,
  x: number,
  y: number,
  color: string,
  label: string
): { pings: MinimapPing[]; nextId: number } {
  return {
    pings: [
      ...pings,
      {
        id: nextId,
        x,
        y,
        color,
        label,
        ageSeconds: 0,
        durationSeconds: 2.8
      }
    ].slice(-12),
    nextId: nextId + 1
  };
}

export function updateResourceSiteWarnings(options: {
  cooldowns: Map<string, number>;
  deltaSeconds: number;
  captureSites: CaptureSite[];
  units: Unit[];
  addMinimapPing: (x: number, y: number, color: string, label: string) => void;
  showMessage: (message: string, x?: number, y?: number, color?: string) => void;
}): Map<string, number> {
  const cooldowns = new Map(options.cooldowns);
  cooldowns.forEach((remaining, siteId) => {
    const nextRemaining = remaining - options.deltaSeconds;
    if (nextRemaining <= 0) {
      cooldowns.delete(siteId);
      return;
    }
    cooldowns.set(siteId, nextRemaining);
  });

  options.captureSites.forEach((site) => {
    if (site.owner !== "player" || (cooldowns.get(site.definition.id) ?? 0) > 0) {
      return;
    }

    const enemyThreateningSite = options.units.some(
      (unit) =>
        unit.alive &&
        unit.team === "enemy" &&
        Phaser.Math.Distance.Between(unit.position.x, unit.position.y, site.position.x, site.position.y) <=
          site.definition.radius + 24
    );
    if (!enemyThreateningSite) {
      return;
    }

    cooldowns.set(site.definition.id, 10);
    options.addMinimapPing(site.position.x, site.position.y, "#f0d978", `${site.definition.name} under attack`);
    options.showMessage(`${site.definition.name} is under attack.`, site.position.x, site.position.y - 70, "#f0d978");
  });
  return cooldowns;
}

export function trackEnemyWave(options: {
  waveUnits: Unit[];
  waves: TrackedEnemyWave[];
  nextWaveId: number;
  addMinimapPing: (x: number, y: number, color: string, label: string) => void;
}): { waves: TrackedEnemyWave[]; nextWaveId: number } {
  if (options.waveUnits.length === 0) {
    return { waves: options.waves, nextWaveId: options.nextWaveId };
  }
  applyFactionWaveModifiers(options.waveUnits);
  const waveId = options.nextWaveId;
  const center = options.waveUnits.reduce(
    (sum, unit) => ({
      x: sum.x + unit.position.x,
      y: sum.y + unit.position.y
    }),
    { x: 0, y: 0 }
  );
  options.addMinimapPing(center.x / options.waveUnits.length, center.y / options.waveUnits.length, "#ff7268", `Enemy wave ${waveId} incoming`);
  return {
    waves: [
      ...options.waves,
      {
        id: waveId,
        unitIds: options.waveUnits.map((unit) => unit.id)
      }
    ],
    nextWaveId: waveId + 1
  };
}

export function updateTrackedEnemyWaves(options: {
  waves: TrackedEnemyWave[];
  units: Unit[];
  runtime: BattleRuntime;
  hero: Hero;
  showMessage: (message: string, x?: number, y?: number, color?: string) => void;
}): TrackedEnemyWave[] {
  return options.waves.filter((wave) => {
    const aliveWaveUnits = options.units.filter((unit) => wave.unitIds.includes(unit.id) && unit.alive);
    if (aliveWaveUnits.length > 0) {
      return true;
    }
    options.runtime.recordEnemyWaveSurvived();
    options.showMessage(`Enemy wave ${wave.id} defeated`, options.hero.position.x, options.hero.position.y - 80, "#aef7b7");
    return false;
  });
}

export function firstBattleTutorialHint(options: {
  isFirstBattle: boolean;
  selected: BaseEntity[];
  commandHall?: Building;
  crownShrine?: CaptureSite;
  hero: Hero;
  buildings: Building[];
  elapsedSeconds: number;
  unitsTrained: number;
  enemyWavesSurvived: number;
}): string {
  if (!options.isFirstBattle) {
    return "";
  }

  const heroSelected = options.selected.includes(options.hero);
  const commandHallSelected = options.commandHall ? options.selected.includes(options.commandHall) : false;
  const barracks = options.buildings.find((building) => building.alive && building.team === "player" && building.definition.id === "barracks");
  const hasBarracks = Boolean(barracks?.isCompleted());

  if (!heroSelected && options.elapsedSeconds < 20) {
    return "Select your hero.";
  }
  if (options.crownShrine?.owner !== "player") {
    return options.crownShrine &&
      options.hero.alive &&
      Phaser.Math.Distance.Between(options.hero.position.x, options.hero.position.y, options.crownShrine.position.x, options.crownShrine.position.y) <= options.crownShrine.radius
      ? "Hold the Crown Shrine circle until it turns green."
      : "Right-click the Crown Shrine with your hero and troops.";
  }
  if (!hasBarracks && !commandHallSelected) {
    return "Select your Command Hall.";
  }
  if (!hasBarracks) {
    return barracks?.isUnderConstruction()
      ? "Barracks is under construction. Hold near your base until it completes."
      : "Build a Barracks to train troops.";
  }
  if (options.unitsTrained === 0) {
    return "Train Militia from your Barracks.";
  }
  if (options.enemyWavesSurvived === 0) {
    return "Defend against the first attack near your Command Hall.";
  }
  return "Gather your army and destroy the enemy Stronghold.";
}

export function warnIfCommandHallUnderAttack(options: {
  target: BaseEntity;
  cooldown: number;
  playerBaseBuildingId: string;
  addMinimapPing: (x: number, y: number, color: string, label: string) => void;
  showMessage: (message: string, x?: number, y?: number, color?: string) => void;
}): number {
  const { target, cooldown, playerBaseBuildingId, addMinimapPing, showMessage } = options;
  if (cooldown > 0 || !(target instanceof Building) || target.team !== "player" || target.definition.id !== playerBaseBuildingId) {
    return cooldown;
  }
  addMinimapPing(target.position.x, target.position.y, "#ff7268", "Command Hall under attack");
  showMessage("Your Command Hall is under attack.", target.position.x, target.position.y - 74, "#ffb1a9");
  return 8;
}

function applyFactionWaveModifiers(units: Unit[]): void {
  units.forEach((unit) => {
    factionModifiersFor(unit)
      .filter((modifier) => modifier.type === "wave-speed" && modifierAppliesToUnit(modifier, unit))
      .forEach((modifier) => {
        unit.factionSpeedMultiplier = Math.max(unit.factionSpeedMultiplier, modifier.speedMultiplier ?? 1);
      });
  });
}

function factionModifiersFor(unit: Unit): FactionModifierDefinition[] {
  return FACTION_BY_ID[unit.definition.factionId]?.mechanics.factionModifiers ?? [];
}

function modifierAppliesToUnit(modifier: FactionModifierDefinition, unit: Unit): boolean {
  return !modifier.unitIds || modifier.unitIds.includes(unit.definition.id);
}
