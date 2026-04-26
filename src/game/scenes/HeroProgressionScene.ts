import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import type { BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { LEVEL_XP_THRESHOLDS } from "../core/Constants";
import { getHeroProgressionGuidance } from "../core/FirstExperienceGuidance";
import type { BattleRewardResult, BattleStats, ItemDefinition, RewardLevelUpSummary } from "../core/GameTypes";
import { allocateSkillPoint, equipItem, saveWithRecalculatedStats, unequipItem } from "../core/HeroProgressionRules";
import { formatTime } from "../core/MathUtils";
import { xpProgressForLevel } from "../core/Progression";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { getBattleDifficulty } from "../data/battlePacing";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, MAP_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { SKILL_NODES, SKILL_TREES } from "../data/skillTrees";
import { createEquipmentViewModel, renderEquipmentPanel } from "../progression/EquipmentPanel";
import { renderHeroAbilitiesPanel, renderHeroStatsPanel } from "../progression/HeroStatsPanel";
import { createHeroProgressionViewModel, resolveHeroClass, resolveOrigin } from "../progression/HeroProgressionViewModel";
import { createInventoryViewModel, renderInventoryPanel } from "../progression/InventoryPanel";
import { escapeHtml, formatResourceRewards, renderItemName, titleCase, toCssColor } from "../progression/ItemComparison";
import { createSkillTreeViewModel, renderSkillTreesPanel } from "../progression/SkillTreePanel";
import type { HeroSaveData } from "../save/SaveTypes";

interface HeroProgressionData {
  stats?: BattleStats;
  heroSave?: HeroSaveData;
  rewardItemIds?: string[];
  reward?: BattleRewardResult;
  rewardLevelUp?: RewardLevelUpSummary;
  launchRequest?: BattleLaunchRequest;
  returnMode?: "campaign" | "skirmish";
}

const PROGRESSION_CATALOGS = {
  heroClassById: HERO_CLASS_BY_ID,
  originById: ORIGIN_BY_ID,
  skillNodeById: SKILL_NODE_BY_ID,
  itemById: ITEM_BY_ID
};

export class HeroProgressionScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private heroSave: HeroSaveData = createFallbackHeroSave();
  private stats?: BattleStats;
  private rewardItemIds: string[] = [];
  private reward?: BattleRewardResult;
  private rewardLevelUp?: RewardLevelUpSummary;
  private launchRequest?: BattleLaunchRequest;
  private returnMode: "campaign" | "skirmish" = "skirmish";
  private status = "Spend skill points, equip rewards, or continue into another skirmish.";

  constructor() {
    super(SCENE_KEYS.heroProgression);
  }

  init(data: HeroProgressionData): void {
    this.heroSave = data.heroSave ?? SaveSystem.load()?.hero ?? createFallbackHeroSave();
    this.stats = data.stats;
    this.rewardItemIds = data.rewardItemIds ?? [];
    this.reward = data.reward ?? (data.rewardItemIds ? { itemIds: data.rewardItemIds, resources: {}, xp: 0 } : undefined);
    this.rewardLevelUp = data.rewardLevelUp;
    this.launchRequest = data.launchRequest;
    this.returnMode = data.returnMode ?? (data.launchRequest?.mode === "campaign_node" ? "campaign" : "skirmish");
    this.heroSave = this.finalizeHeroSave(this.heroSave);
    this.status = this.initialStatus();
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    this.handler = (event) => {
      const button = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-progression-action]");
      if (!button) {
        return;
      }

      const action = button.dataset.progressionAction;
      const id = button.dataset.id ?? "";
      if (action === "skill") {
        const result = allocateSkillPoint(this.heroSave, id, SKILL_NODE_BY_ID);
        this.applyProgressionResult(result.hero, result.message, result.ok);
      }
      if (action === "equip") {
        const result = equipItem(this.heroSave, id, ITEM_BY_ID);
        this.applyProgressionResult(result.hero, result.message, result.ok);
      }
      if (action === "unequip") {
        const slot = button.dataset.slot;
        if (slot === "weapon" || slot === "armor" || slot === "trinket") {
          const result = unequipItem(this.heroSave, slot);
          this.applyProgressionResult(result.hero, result.message, result.ok);
        }
      }
      if (action === "skirmish") {
        this.scene.start(SCENE_KEYS.skirmishSetup, {
          heroSave: this.heroSave,
          launchRequest: this.launchRequest
        });
      }
      if (action === "campaign") {
        const save = SaveSystem.load();
        if (save) {
          this.scene.start(SCENE_KEYS.campaignMap, {
            heroSave: save.hero,
            campaignSave: save.campaign,
            stats: this.stats
          });
        }
      }
      if (action === "menu") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
    };

    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private applyProgressionResult(hero: HeroSaveData, message: string, changed: boolean): void {
    this.heroSave = this.finalizeHeroSave(hero);
    this.status = message;
    if (changed) {
      SaveSystem.saveHero(this.heroSave);
    }
    this.render();
  }

  private finalizeHeroSave(save: HeroSaveData): HeroSaveData {
    return saveWithRecalculatedStats(save, resolveHeroClass(save, PROGRESSION_CATALOGS), resolveOrigin(save, PROGRESSION_CATALOGS), SKILL_NODE_BY_ID, ITEM_BY_ID);
  }

  private render(): void {
    if (!this.root) {
      return;
    }

    // Boundary: this scene owns Phaser lifecycle, DOM root wiring, save calls, and scene transitions.
    // Progression helpers own pure view-model creation and panel markup for inventory/equipment/skills/stats.
    const viewModel = createHeroProgressionViewModel(this.heroSave, PROGRESSION_CATALOGS);
    const inventory = createInventoryViewModel({
      heroSave: this.heroSave,
      rewardItemIds: this.rewardItemIds,
      reward: this.reward,
      catalogs: PROGRESSION_CATALOGS
    });
    const equipment = createEquipmentViewModel(this.heroSave, PROGRESSION_CATALOGS);
    const skillTrees = createSkillTreeViewModel({
      heroSave: this.heroSave,
      skillTrees: SKILL_TREES,
      skillNodes: SKILL_NODES,
      catalogs: PROGRESSION_CATALOGS
    });
    const hasPortrait = AssetLoader.hasAsset(viewModel.portraitId);
    const backgroundId = this.stats?.outcome === "victory" ? ASSET_IDS.ui.victoryScreenBackground : undefined;

    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell progression-shell asset-screen-bg" data-testid="hero-inventory" ${AssetLoader.screenStyle({ backgroundAssetId: backgroundId })}>
        <section class="menu-panel extra-wide progression-panel ${this.stats?.outcome === "victory" ? "results-panel victory" : ""}">
          <div class="progression-header">
            <div class="progression-title-row">
              <div class="portrait large ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(viewModel.portraitId, toCssColor(viewModel.heroClass.color))}></div>
              <div>
              <p class="eyebrow">${this.stats ? "Victory Progression" : "Hero Inventory"}</p>
              <h1>${escapeHtml(viewModel.heroName)}</h1>
              <p class="menu-copy">${escapeHtml(viewModel.heroClass.name)} - ${escapeHtml(viewModel.origin.name)} - Level ${viewModel.level}</p>
              </div>
            </div>
            <div class="skill-points">
              <span>Skill Points</span>
              <strong>${viewModel.skillPoints}</strong>
            </div>
          </div>
          ${this.renderBattleResults()}
          ${this.renderGuidancePanel()}
          <div class="status-box">${escapeHtml(this.status)}</div>
          <div class="progression-grid">
            <section>
              <h2>Hero Stats</h2>
              <div data-testid="hero-stats">${renderHeroStatsPanel(viewModel.stats)}</div>
              <h2>Abilities</h2>
              ${renderHeroAbilitiesPanel(viewModel.unlockedAbilities)}
            </section>
            <section>
              <h2>Equipment</h2>
              <div data-testid="equipment-panel">${renderEquipmentPanel(equipment)}</div>
              <h2>Inventory</h2>
              <div data-testid="inventory-list">${renderInventoryPanel(inventory)}</div>
            </section>
          </div>
          <h2>Skill Trees</h2>
          <div class="skill-tree-grid">
            ${renderSkillTreesPanel(skillTrees)}
          </div>
          <div class="menu-actions row">
            <button data-progression-action="${this.returnMode === "campaign" ? "campaign" : "skirmish"}">
              ${this.returnMode === "campaign" ? "Campaign Map" : "Continue Skirmish"}
            </button>
            <button data-progression-action="menu">Main Menu</button>
          </div>
        </section>
      </main>
    `;
  }

  private renderGuidancePanel(): string {
    const guidance = getHeroProgressionGuidance({
      hero: this.heroSave,
      recentRewardItemCount: this.rewardItemIds.length,
      skillPointsGained: this.rewardLevelUp?.skillPointsGained,
      inCampaign: this.returnMode === "campaign"
    });
    return `
      <div class="guidance-card">
        <strong>${escapeHtml(guidance.title)}</strong>
        <p>${escapeHtml(guidance.body)}</p>
        <div class="tag-row">
          ${guidance.actions.map((action) => `<span class="tag">${escapeHtml(action)}</span>`).join("")}
        </div>
      </div>
    `;
  }

  private renderBattleResults(): string {
    if (!this.stats) {
      return "";
    }
    const reward = this.reward ?? { itemIds: this.rewardItemIds, resources: {}, xp: 0 };
    const rewards = reward.itemIds
      .map((itemId) => ITEM_BY_ID[itemId])
      .filter((item): item is ItemDefinition => item !== undefined);
    const map = this.launchRequest ? MAP_BY_ID[this.launchRequest.mapId] : undefined;
    const difficulty = this.launchRequest ? getBattleDifficulty(this.launchRequest.difficulty) : undefined;
    const progress = xpProgressForLevel(this.heroSave.xp, this.heroSave.level, LEVEL_XP_THRESHOLDS);
    const xpProgressText =
      progress.nextLevelXp > progress.currentLevelXp
        ? `${Math.max(0, this.heroSave.xp - progress.currentLevelXp)} / ${progress.nextLevelXp - progress.currentLevelXp}`
        : "Level cap reached";
    const skillPointsGained = this.rewardLevelUp?.skillPointsGained ?? 0;
    return `
      <div class="results-grid compact">
        <span>Map</span><strong>${escapeHtml(map?.name ?? "Unknown")}</strong>
        <span>Difficulty</span><strong>${escapeHtml(difficulty?.name ?? "Unknown")}</strong>
        <span>XP gained</span><strong>${this.stats.xpGained}${reward.xp > 0 ? ` (${reward.xp} victory bonus)` : ""}</strong>
        <span>XP progress</span><strong>${escapeHtml(xpProgressText)} - ${Math.round(progress.percent)}%</strong>
        <span>Skill points gained</span><strong>${skillPointsGained}</strong>
        <span>Survival time</span><strong>${formatTime(this.stats.timeSeconds)}</strong>
        <span>First site captured</span><strong>${this.stats.firstSiteCaptured ? titleCase(this.stats.firstSiteCaptured) : "None"}</strong>
        <span>Buildings built</span><strong>${this.stats.buildingsBuilt}</strong>
        <span>Units trained</span><strong>${this.stats.unitsTrained}</strong>
        <span>Enemy waves survived</span><strong>${this.stats.enemyWavesSurvived}</strong>
        <span>Units killed</span><strong>${this.stats.unitsKilled}</strong>
        <span>Buildings destroyed</span><strong>${this.stats.buildingsDestroyed}</strong>
        <span>Sites captured</span><strong>${this.stats.resourcesCaptured}</strong>
        <span>Item rewards</span><strong>${rewards.length > 0 ? rewards.map(renderItemName).join(", ") : "No new item"}</strong>
        <span>Resource rewards</span><strong>${escapeHtml(formatResourceRewards(reward.resources))}</strong>
      </div>
    `;
  }

  private initialStatus(): string {
    if (this.heroSave.skillPoints > 0 && this.rewardItemIds.length > 0) {
      return "You received an item and have a skill point waiting. Equip the item, then spend the point before your next node.";
    }
    if (this.heroSave.skillPoints > 0) {
      return "You gained a skill point. Spend it in a skill tree to unlock abilities or improve stats.";
    }
    if (this.rewardItemIds.length > 0) {
      return "You received an item. Equip it to improve your hero before the next battle.";
    }
    return this.returnMode === "campaign"
      ? "Review your hero, then return to the campaign map."
      : "Spend skill points, equip rewards, or continue into another skirmish.";
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}
