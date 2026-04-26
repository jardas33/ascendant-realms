import { LEVEL_XP_THRESHOLDS } from "../core/Constants";
import type { AbilityDefinition, ResourceBag } from "../core/GameTypes";
import { canAfford } from "../core/MathUtils";
import { xpProgressForLevel } from "../core/Progression";
import { abilityIconAssetId, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { ABILITY_BY_ID, BUILDING_BY_ID, UNIT_BY_ID, UPGRADE_BY_ID } from "../data/contentIndex";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { Building } from "../entities/Building";
import { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";
import { checkPrerequisites, type TechState } from "../systems/PrerequisiteSystem";
import { abilityLabel } from "./AbilityBar";
import { formatCost } from "./BuildMenu";
import { healthPercent } from "./HealthBar";
import { renderMinimap, type MinimapSnapshot } from "./MinimapView";
import { selectionTitle } from "./SelectionPanel";

interface HUDCallbacks {
  onBuild: (buildingId: string) => void;
  onTrain: (unitId: string, sourceBuildingId: string) => void;
  onCancelTrain: (sourceBuildingId: string, queueIndex: number) => void;
  onUpgrade: (upgradeId: string, sourceBuildingId: string) => void;
  onCancelUpgrade: (sourceBuildingId: string, queueIndex: number) => void;
  onAbility: (abilityId: string) => void;
  onMinimapMove: (normalizedX: number, normalizedY: number) => void;
  onMenu: () => void;
}

interface HUDSnapshot {
  resources: ResourceBag;
  hero: Hero;
  selected: Array<Unit | Building>;
  elapsedSeconds: number;
  isPlacing: boolean;
  status: string;
  hint?: string;
  techState: TechState;
  minimap: MinimapSnapshot;
}

export class HUD {
  private readonly root: HTMLElement;
  private readonly clickHandler: (event: MouseEvent) => void;
  private lastMarkup = "";

  constructor(callbacks: HUDCallbacks) {
    const root = document.getElementById("ui-root");
    if (!root) {
      throw new Error("Missing #ui-root element");
    }
    this.root = root;
    this.clickHandler = (event) => {
      const target = event.target as Element | null;
      const minimap = target?.closest<HTMLElement>("[data-minimap]");
      if (minimap) {
        const bounds = minimap.getBoundingClientRect();
        if (bounds.width > 0 && bounds.height > 0) {
          callbacks.onMinimapMove(
            clamp((event.clientX - bounds.left) / bounds.width, 0, 1),
            clamp((event.clientY - bounds.top) / bounds.height, 0, 1)
          );
        }
        return;
      }

      const button = target?.closest<HTMLButtonElement>("button[data-action]");
      if (!button) {
        return;
      }
      const action = button.dataset.action;
      const id = button.dataset.id ?? "";
      if (action === "build") {
        callbacks.onBuild(id);
      }
      if (action === "train") {
        callbacks.onTrain(id, button.dataset.sourceId ?? "");
      }
      if (action === "cancel-train") {
        callbacks.onCancelTrain(button.dataset.sourceId ?? "", Number(button.dataset.index ?? 0));
      }
      if (action === "upgrade") {
        callbacks.onUpgrade(id, button.dataset.sourceId ?? "");
      }
      if (action === "cancel-upgrade") {
        callbacks.onCancelUpgrade(button.dataset.sourceId ?? "", Number(button.dataset.index ?? 0));
      }
      if (action === "ability") {
        callbacks.onAbility(id);
      }
      if (action === "menu") {
        callbacks.onMenu();
      }
    };
    this.root.addEventListener("click", this.clickHandler);
  }

  update(snapshot: HUDSnapshot): void {
    const selected = snapshot.selected.filter((entity) => entity.alive);
    const selectedOne = selected.length === 1 ? selected[0] : undefined;
    const abilities = snapshot.hero.unlockedAbilities
      .map((abilityId) => ABILITY_BY_ID[abilityId])
      .filter((ability): ability is AbilityDefinition => ability !== undefined)
      .slice(0, 3);
    const portraitId = heroPortraitAssetId(snapshot.hero.classId);
    const hasPortrait = AssetLoader.hasAsset(portraitId);
    const markup = `
      <div class="top-bar">
        <div class="resource-row">${this.renderResources(snapshot.resources)}</div>
        <button class="hud-button compact" data-action="menu">Menu</button>
      </div>
      <div class="hero-panel">
        <div class="portrait ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, this.toCssColor(snapshot.hero.definition.color))}></div>
        <div class="hero-lines">
          <strong>${escapeHtml(snapshot.hero.heroName)} L${snapshot.hero.level}</strong>
          <span>HP ${Math.ceil(snapshot.hero.hp)}/${snapshot.hero.maxHp} - Mana ${Math.floor(snapshot.hero.mana)}/${snapshot.hero.maxMana}</span>
          <div class="meter"><span style="width:${healthPercent({ current: snapshot.hero.hp, max: snapshot.hero.maxHp })}%"></span></div>
          <div class="xp-meter"><span style="width:${this.heroXpPercent(snapshot.hero)}%"></span></div>
          <small>XP ${snapshot.hero.xp} - Skill ${snapshot.hero.skillPoints}</small>
        </div>
      </div>
      <div class="side-panel">
        <div class="panel-title">${escapeHtml(selectionTitle(selected))}</div>
        ${this.renderSelection(selectedOne, selected)}
        ${this.renderActions(selectedOne, snapshot)}
        ${this.renderAbilities(abilities, snapshot.hero)}
      </div>
      <div class="minimap-shell">
        ${renderMinimap(snapshot.minimap)}
      </div>
      <div class="status-line ${snapshot.isPlacing ? "active" : ""}">${escapeHtml(snapshot.status)}</div>
      ${snapshot.hint ? `<div class="hint-line">${escapeHtml(snapshot.hint)}</div>` : ""}
    `;

    if (markup !== this.lastMarkup) {
      this.root.className = "ui-root battle-ui";
      this.root.innerHTML = markup;
      this.lastMarkup = markup;
    }
  }

  destroy(): void {
    this.root.removeEventListener("click", this.clickHandler);
    this.root.className = "ui-root";
    this.root.innerHTML = "";
    this.lastMarkup = "";
  }

  private renderResources(resources: ResourceBag): string {
    return RESOURCE_DEFINITIONS.map(
      (resource) =>
        `<span class="resource-pill" style="--resource-color:${this.toCssColor(resource.color)}"><span>${escapeHtml(resource.name)}</span><strong>${Math.floor(resources[resource.id])}</strong></span>`
    ).join("");
  }

  private renderSelection(selectedOne: Unit | Building | undefined, selected: Array<Unit | Building>): string {
    if (!selectedOne) {
      if (selected.length > 1) {
        const productionBuildings = selected.filter(
          (entity): entity is Building => entity instanceof Building && entity.isCompleted() && entity.definition.trainOptions.length > 0
        );
        return `<div class="selection-grid">${selected
          .slice(0, 12)
          .map((entity) => `<span>${escapeHtml(entity.definition.name)}</span>`)
          .join("")}</div>${
          productionBuildings.length > 0
            ? `<p class="quiet">Rally Point: ${productionBuildings.some((building) => building.rallyPoint) ? "Set" : "None"}. Right-click ground to set rally point.</p>`
            : ""
        }`;
      }
      return `<p class="quiet">Select your hero, troops, or buildings.</p>`;
    }

    if (selectedOne instanceof Unit) {
      return `
        <div class="stat-list">
          <span>HP ${Math.ceil(selectedOne.hp)}/${selectedOne.maxHp}</span>
          <span>Damage ${Math.round(selectedOne.damage)}</span>
          <span>Range ${selectedOne.range}</span>
          <span>Armor ${selectedOne.armor}</span>
        </div>
      `;
    }

    const training = selectedOne.trainingQueue[0];
    const showRally = selectedOne.isCompleted() && selectedOne.definition.trainOptions.length > 0;
    return `
      <div class="stat-list">
        <span>HP ${Math.ceil(selectedOne.hp)}/${selectedOne.maxHp}</span>
        <span>Armor ${selectedOne.armor}</span>
        ${
          selectedOne.isUnderConstruction()
            ? `<span>Construction ${Math.round(selectedOne.constructionProgress * 100)}%</span>`
            : training
              ? `<span>Training ${escapeHtml(this.unitName(training.unitId))} ${Math.ceil(training.remaining)}s</span>`
              : "<span>Queue idle</span>"
        }
        ${
          selectedOne.upgradeQueue[0]
            ? `<span>Research ${escapeHtml(this.upgradeName(selectedOne.upgradeQueue[0].upgradeId))}</span>`
            : "<span>Research idle</span>"
        }
        ${showRally ? `<span>Rally Point: ${selectedOne.rallyPoint ? "Set" : "None"}</span>` : ""}
      </div>
      ${showRally ? `<p class="quiet">Right-click ground to set rally point.</p>` : ""}
      ${selectedOne.isUnderConstruction() ? this.renderProgress("Construction", selectedOne.constructionProgress) : ""}
      ${this.renderProductionQueue(selectedOne)}
      ${this.renderUpgradeQueue(selectedOne)}
    `;
  }

  private renderActions(selectedOne: Unit | Building | undefined, snapshot: HUDSnapshot): string {
    if (!(selectedOne instanceof Building)) {
      return "";
    }

    if (!selectedOne.isCompleted()) {
      return `<div class="action-group"><strong>Construction</strong><p class="quiet">Production unlocks when this building is complete.</p></div>`;
    }

    const buildButtons = selectedOne.definition.buildOptions
      .map((buildingId) => BUILDING_BY_ID[buildingId])
      .filter((definition) => definition !== undefined)
      .map((definition) => {
        const prerequisite = checkPrerequisites(definition.prerequisites, snapshot.techState);
        const lockReason = !prerequisite.ok
          ? prerequisite.reason
          : canAfford(snapshot.resources, definition.cost)
            ? undefined
            : "Insufficient resources";
        return `<button class="hud-button ${lockReason ? "locked" : ""}" data-action="build" data-id="${definition.id}" ${lockReason ? "disabled" : ""}>Build ${escapeHtml(definition.name)}<small>${escapeHtml(lockReason ?? formatCost(definition.cost))}</small></button>`;
      })
      .join("");

    const trainButtons = selectedOne.definition.trainOptions
      .map((unitId) => UNIT_BY_ID[unitId])
      .filter((definition) => definition !== undefined)
      .map((definition) => {
        const prerequisite = checkPrerequisites(definition.prerequisites, snapshot.techState);
        const lockReason = !prerequisite.ok
          ? prerequisite.reason
          : canAfford(snapshot.resources, definition.cost)
            ? undefined
            : "Insufficient resources";
        return `<button class="hud-button ${lockReason ? "locked" : ""}" data-action="train" data-id="${definition.id}" data-source-id="${selectedOne.id}" ${lockReason ? "disabled" : ""}>Train ${escapeHtml(definition.name)}<small>${escapeHtml(lockReason ?? formatCost(definition.cost))}</small></button>`;
      })
      .join("");

    const upgradeButtons = selectedOne.definition.upgradeOptions
      .map((upgradeId) => UPGRADE_BY_ID[upgradeId])
      .filter((definition) => definition !== undefined)
      .map((definition) => {
        const researched = snapshot.techState.researchedUpgradeIds.has(definition.id);
        const queued = selectedOne.upgradeQueue.some((entry) => entry.upgradeId === definition.id);
        const prerequisite = checkPrerequisites(definition.prerequisites, snapshot.techState);
        const lockReason = researched
          ? "Researched"
          : queued
            ? "Researching"
            : !prerequisite.ok
              ? prerequisite.reason
              : canAfford(snapshot.resources, definition.cost)
                ? undefined
                : "Insufficient resources";
        return `<button class="hud-button ${lockReason ? "locked" : ""}" data-action="upgrade" data-id="${definition.id}" data-source-id="${selectedOne.id}" ${lockReason ? "disabled" : ""}>Research ${escapeHtml(definition.name)}<small>${escapeHtml(lockReason ?? formatCost(definition.cost))}</small></button>`;
      })
      .join("");

    const sections = [];
    if (buildButtons) {
      sections.push(`<div class="action-group"><strong>Build</strong>${buildButtons}</div>`);
    }
    if (trainButtons) {
      sections.push(`<div class="action-group"><strong>Train</strong>${trainButtons}</div>`);
    }
    if (upgradeButtons) {
      sections.push(`<div class="action-group"><strong>Upgrades</strong>${upgradeButtons}</div>`);
    }
    return sections.join("");
  }

  private renderProductionQueue(building: Building): string {
    if (building.trainingQueue.length === 0) {
      return "";
    }
    return `
      <div class="queue-list">
        <strong>Training Queue</strong>
        ${building.trainingQueue
          .map((item, index) => {
            const progress = item.total > 0 ? 1 - item.remaining / item.total : 1;
            return `
              <div class="queue-row">
                <div>
                  <span>${escapeHtml(this.unitName(item.unitId))}</span>
                  ${this.renderProgress("", progress)}
                </div>
                <button class="hud-button compact mini" data-action="cancel-train" data-source-id="${building.id}" data-index="${index}">Cancel</button>
              </div>
            `;
          })
          .join("")}
      </div>
    `;
  }

  private renderUpgradeQueue(building: Building): string {
    if (building.upgradeQueue.length === 0) {
      return "";
    }
    return `
      <div class="queue-list">
        <strong>Research Queue</strong>
        ${building.upgradeQueue
          .map((item, index) => {
            const progress = item.total > 0 ? 1 - item.remaining / item.total : 1;
            return `
              <div class="queue-row">
                <div>
                  <span>${escapeHtml(this.upgradeName(item.upgradeId))}</span>
                  ${this.renderProgress("", progress)}
                </div>
                <button class="hud-button compact mini" data-action="cancel-upgrade" data-source-id="${building.id}" data-index="${index}">Cancel</button>
              </div>
            `;
          })
          .join("")}
      </div>
    `;
  }

  private renderProgress(label: string, progress: number): string {
    return `
      <div class="progress-line">
        ${label ? `<span>${escapeHtml(label)}</span>` : ""}
        <div class="progress-strip"><i style="width:${Math.max(0, Math.min(100, progress * 100))}%"></i></div>
      </div>
    `;
  }

  private renderAbilities(abilities: AbilityDefinition[], hero: Hero): string {
    if (abilities.length === 0) {
      return "";
    }
    return `
      <div class="action-group ability-group">
        <strong>Hero</strong>
        ${abilities
          .map((ability) => {
            const cooldownRemaining = hero.abilityCooldowns[ability.id] ?? 0;
            return `
              <button class="hud-button ability" data-action="ability" data-id="${ability.id}">
                <span class="ability-button-content">
                  ${AssetLoader.imageHtml(abilityIconAssetId(ability.id), `${ability.name} icon`, "ability-icon")}
                  <span>${escapeHtml(abilityLabel(ability, cooldownRemaining))}</span>
                </span>
                <small>${ability.manaCost} Mana</small>
              </button>
            `;
          })
          .join("")}
      </div>
    `;
  }

  private heroXpPercent(hero: Hero): number {
    return xpProgressForLevel(hero.xp, hero.level, LEVEL_XP_THRESHOLDS).percent;
  }

  private unitName(unitId: string): string {
    return UNIT_BY_ID[unitId]?.name ?? unitId;
  }

  private upgradeName(upgradeId: string): string {
    return UPGRADE_BY_ID[upgradeId]?.name ?? upgradeId;
  }

  private toCssColor(value: number): string {
    return `#${value.toString(16).padStart(6, "0")}`;
  }
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}
