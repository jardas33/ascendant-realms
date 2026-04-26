import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createSkirmishBattleLaunchRequest, type BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import type { BattleDifficulty, EnemyAIPersonalityId } from "../core/GameTypes";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { AI_PERSONALITIES, DEFAULT_AI_PERSONALITY_ID } from "../data/aiPersonalities";
import { BATTLE_DIFFICULTIES, DEFAULT_BATTLE_DIFFICULTY } from "../data/battlePacing";
import { FACTIONS } from "../data/factions";
import { HERO_CLASS_BY_ID, ORIGIN_BY_ID } from "../data/contentIndex";
import { DEFAULT_MAP_ID, MAPS } from "../data/maps";
import type { HeroSaveData } from "../save/SaveTypes";

interface SkirmishSetupData {
  heroSave?: HeroSaveData;
  launchRequest?: BattleLaunchRequest;
}

const DEFAULT_ENEMY_FACTION_ID = "ashen_covenant";
const SELECTABLE_ENEMY_FACTION_IDS = new Set(["ashen_covenant"]);

export class SkirmishSetupScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private heroSave?: HeroSaveData;
  private selectedMapId = DEFAULT_MAP_ID;
  private selectedDifficulty: BattleDifficulty = DEFAULT_BATTLE_DIFFICULTY;
  private selectedEnemyFactionId = DEFAULT_ENEMY_FACTION_ID;
  private selectedAiPersonalityId: EnemyAIPersonalityId = DEFAULT_AI_PERSONALITY_ID;

  constructor() {
    super(SCENE_KEYS.skirmishSetup);
  }

  init(data: SkirmishSetupData): void {
    this.heroSave = data.heroSave ?? data.launchRequest?.heroSave ?? SaveSystem.load()?.hero;
    this.selectedMapId = data.launchRequest?.mapId ?? DEFAULT_MAP_ID;
    this.selectedDifficulty = data.launchRequest?.difficulty ?? DEFAULT_BATTLE_DIFFICULTY;
    this.selectedEnemyFactionId = data.launchRequest?.enemyProfileId ?? DEFAULT_ENEMY_FACTION_ID;
    this.selectedAiPersonalityId = data.launchRequest?.aiPersonalityId ?? DEFAULT_AI_PERSONALITY_ID;
  }

  create(): void {
    if (!this.heroSave) {
      this.scene.start(SCENE_KEYS.heroCreation);
      return;
    }

    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    this.handler = (event) => {
      const target = event.target as HTMLElement;
      const option = target.closest<HTMLButtonElement>("button[data-setup-kind]");
      if (option) {
        const id = option.dataset.id ?? "";
        if (option.dataset.setupKind === "map" && MAPS.some((map) => map.id === id)) {
          this.selectedMapId = id;
        }
        if (option.dataset.setupKind === "difficulty" && BATTLE_DIFFICULTIES.some((difficulty) => difficulty.id === id)) {
          this.selectedDifficulty = id as BattleDifficulty;
        }
        if (option.dataset.setupKind === "enemy" && SELECTABLE_ENEMY_FACTION_IDS.has(id)) {
          this.selectedEnemyFactionId = id;
        }
        if (option.dataset.setupKind === "personality" && AI_PERSONALITIES.some((personality) => personality.id === id)) {
          this.selectedAiPersonalityId = id as EnemyAIPersonalityId;
        }
        this.render();
        return;
      }

      const action = target.closest<HTMLButtonElement>("button[data-setup-action]")?.dataset.setupAction;
      if (action === "start" && this.heroSave) {
        this.scene.start(SCENE_KEYS.battle, {
          launchRequest: createSkirmishBattleLaunchRequest(this.heroSave, {
            mapId: this.selectedMapId,
            difficulty: this.selectedDifficulty,
            enemyProfileId: this.selectedEnemyFactionId,
            aiPersonalityId: this.selectedAiPersonalityId,
            sourceId: "skirmish_setup"
          })
        });
      }
      if (action === "back") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
    };

    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(): void {
    if (!this.root || !this.heroSave) {
      return;
    }

    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell setup-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel extra-wide">
          <p class="eyebrow">Skirmish Setup</p>
          <h1>Choose The Battlefield</h1>
          <div class="setup-grid">
            <section class="setup-section">
              <h2>Hero</h2>
              ${this.renderHeroSummary()}
              <h2>Enemy Faction</h2>
              <div class="enemy-grid">${this.renderEnemyChoices()}</div>
            </section>
            <section class="setup-section">
              <h2>Map</h2>
              <div class="map-grid">${this.renderMapChoices()}</div>
              <h2>Difficulty</h2>
              <div class="difficulty-grid">${this.renderDifficultyChoices()}</div>
              <h2>AI Personality</h2>
              <div class="difficulty-grid">${this.renderPersonalityChoices()}</div>
            </section>
          </div>
          <div class="menu-actions row">
            <button data-setup-action="start">Start Battle</button>
            <button data-setup-action="back">Back</button>
          </div>
        </section>
      </main>
    `;
  }

  private renderHeroSummary(): string {
    if (!this.heroSave) {
      return "";
    }
    const heroClass = HERO_CLASS_BY_ID[this.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[this.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    const portraitId = heroPortraitAssetId(heroClass.id);
    const hasPortrait = AssetLoader.hasAsset(portraitId);
    return `
      <div class="hero-summary-card">
        <div class="portrait large ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, this.toCssColor(heroClass.color))}></div>
        <div>
          <strong>${escapeHtml(this.heroSave.heroName)} L${this.heroSave.level}</strong>
          <span>${escapeHtml(heroClass.name)} - ${escapeHtml(origin.name)}</span>
          <small>${this.heroSave.completedBattles} battles completed - ${this.heroSave.skillPoints} skill points</small>
        </div>
      </div>
    `;
  }

  private renderEnemyChoices(): string {
    return FACTIONS.filter((faction) => faction.id === "ashen_covenant" || faction.id === "sylvan_concord")
      .map((faction) => {
        const locked = !SELECTABLE_ENEMY_FACTION_IDS.has(faction.id);
        return `
          <button class="choice compact-choice ${faction.id === this.selectedEnemyFactionId ? "selected" : ""}" data-setup-kind="enemy" data-id="${faction.id}" ${locked ? "disabled" : ""}>
            <strong>${escapeHtml(faction.name)}</strong>
            <span>${escapeHtml(locked ? `${faction.fantasy} Future AI profile.` : faction.mechanics.militaryStyle)}</span>
            <small>${escapeHtml(locked ? "Locked for now" : faction.mechanics.magicStyle)}</small>
          </button>
        `;
      })
      .join("");
  }

  private renderMapChoices(): string {
    return MAPS.map(
      (map) => `
        <button class="choice map-choice ${map.id === this.selectedMapId ? "selected" : ""}" data-setup-kind="map" data-id="${map.id}">
          <strong>${escapeHtml(map.name)}</strong>
          <span>${escapeHtml(map.role)}</span>
          <small>${map.width}x${map.height} - ${map.captureSites.length} sites - ${map.neutralCamps.length} camps</small>
          <p>${escapeHtml(map.description)}</p>
        </button>
      `
    ).join("");
  }

  private renderDifficultyChoices(): string {
    return BATTLE_DIFFICULTIES.map(
      (difficulty) => `
        <button class="choice compact-choice ${difficulty.id === this.selectedDifficulty ? "selected" : ""}" data-setup-kind="difficulty" data-id="${difficulty.id}">
          <strong>${difficulty.name}</strong>
          <span>${difficulty.description}</span>
        </button>
      `
    ).join("");
  }

  private renderPersonalityChoices(): string {
    return AI_PERSONALITIES.map(
      (personality) => `
        <button class="choice compact-choice ${personality.id === this.selectedAiPersonalityId ? "selected" : ""}" data-setup-kind="personality" data-id="${personality.id}">
          <strong>${escapeHtml(personality.name)}</strong>
          <span>${escapeHtml(personality.shortDescription)}</span>
        </button>
      `
    ).join("");
  }

  private toCssColor(value: number): string {
    return `#${value.toString(16).padStart(6, "0")}`;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
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
