import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { cloneBattleLaunchRequestWithHero, createSkirmishBattleLaunchRequest, type BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { formatTime } from "../core/MathUtils";
import type { BattleStats } from "../core/GameTypes";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { getBattleDifficulty } from "../data/battlePacing";
import { MAP_BY_ID } from "../data/contentIndex";
import type { HeroSaveData } from "../save/SaveTypes";

interface ResultsData {
  stats: BattleStats;
  heroSave: HeroSaveData;
  launchRequest?: BattleLaunchRequest;
}

export class ResultsScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private dataSnapshot?: ResultsData;

  constructor() {
    super(SCENE_KEYS.results);
  }

  init(data: ResultsData): void {
    this.dataSnapshot = data;
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root || !this.dataSnapshot) {
      this.scene.start(SCENE_KEYS.mainMenu);
      return;
    }

    this.handler = (event) => {
      const action = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-results-action]")?.dataset.resultsAction;
      if (action === "retry") {
        const heroSave = this.dataSnapshot?.heroSave ?? SaveSystem.load()?.hero;
        if (heroSave) {
          this.scene.start(SCENE_KEYS.battle, {
            launchRequest: this.dataSnapshot?.launchRequest
              ? cloneBattleLaunchRequestWithHero(this.dataSnapshot.launchRequest, heroSave, { sourceId: "results_retry" })
              : createSkirmishBattleLaunchRequest(heroSave, { sourceId: "results_retry" })
          });
        }
      }
      if (action === "menu") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
      if (action === "campaign") {
        const save = SaveSystem.load();
        if (save) {
          this.scene.start(SCENE_KEYS.campaignMap, {
            heroSave: save.hero,
            campaignSave: save.campaign,
            stats: this.dataSnapshot?.stats
          });
        }
      }
    };
    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(): void {
    if (!this.root || !this.dataSnapshot) {
      return;
    }
    const { stats, heroSave } = this.dataSnapshot;
    const map = this.dataSnapshot.launchRequest ? MAP_BY_ID[this.dataSnapshot.launchRequest.mapId] : undefined;
    const difficulty = this.dataSnapshot.launchRequest ? getBattleDifficulty(this.dataSnapshot.launchRequest.difficulty) : undefined;
    const isCampaign = this.dataSnapshot.launchRequest?.mode === "campaign_node";
    const title = stats.outcome === "victory" ? "Victory" : "Defeat";
    const backgroundId = stats.outcome === "victory" ? ASSET_IDS.ui.victoryScreenBackground : ASSET_IDS.ui.defeatScreenBackground;
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: backgroundId })}>
        <section class="menu-panel results-panel ${stats.outcome}">
          <p class="eyebrow">Battle Results</p>
          <h1>${title}</h1>
          <div class="results-grid">
            <span>Hero</span><strong>${escapeHtml(heroSave.heroName)} - Level ${heroSave.level}</strong>
            <span>Map</span><strong>${escapeHtml(map?.name ?? "Unknown")}</strong>
            <span>Difficulty</span><strong>${escapeHtml(difficulty?.name ?? "Unknown")}</strong>
            <span>XP gained</span><strong>${stats.xpGained}</strong>
            <span>Survival time</span><strong>${formatTime(stats.timeSeconds)}</strong>
            <span>First site captured</span><strong>${stats.firstSiteCaptured ? titleCase(stats.firstSiteCaptured) : "None"}</strong>
            <span>Buildings built</span><strong>${stats.buildingsBuilt}</strong>
            <span>Units trained</span><strong>${stats.unitsTrained}</strong>
            <span>Enemy waves survived</span><strong>${stats.enemyWavesSurvived}</strong>
            <span>Units killed</span><strong>${stats.unitsKilled}</strong>
            <span>Buildings destroyed</span><strong>${stats.buildingsDestroyed}</strong>
            <span>Sites captured</span><strong>${stats.resourcesCaptured}</strong>
          </div>
          ${stats.outcome === "defeat" ? `<div class="info-box">${escapeHtml(defeatTip(stats))}</div>` : ""}
          <div class="menu-actions row">
            <button data-results-action="retry">${stats.outcome === "victory" ? "Continue Hero" : "Retry"}</button>
            <button data-results-action="${isCampaign ? "campaign" : "menu"}">${isCampaign ? "Campaign Map" : "Main Menu"}</button>
          </div>
        </section>
      </main>
    `;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}

function titleCase(value: string): string {
  return value.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function defeatTip(stats: BattleStats): string {
  if (stats.resourcesCaptured === 0) {
    return "Tip: send your hero and starting troops to the Crown Shrine early. Captured sites fund the army that survives later waves.";
  }
  if (stats.buildingsBuilt === 0) {
    return "Tip: select the Command Hall and build a Barracks before the first attack arrives.";
  }
  if (stats.unitsTrained === 0) {
    return "Tip: train Militia as soon as the Barracks finishes, then defend near your Command Hall.";
  }
  return "Tip: keep damaged units near the Command Hall, use hero abilities during the first wave, then counterattack after rebuilding.";
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
