import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { DEFAULT_SETTINGS, applySettingsToDocument, normalizeSettingsData } from "../core/Settings";
import { AudioManager } from "../systems/AudioManager";
import { FloatingText } from "../ui/FloatingText";
import type { FogEnabledOverride, SaveSettingsData } from "../save/SaveTypes";

export class SettingsScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: Event) => void;
  private settings: SaveSettingsData = DEFAULT_SETTINGS;
  private status = "Adjust options, then save when ready.";

  constructor() {
    super(SCENE_KEYS.settings);
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }
    this.settings = normalizeSettingsData(SaveSystem.load()?.settings);
    this.applySettings();

    this.handler = (event) => this.handleEvent(event);
    this.root.addEventListener("click", this.handler);
    this.root.addEventListener("input", this.handler);
    this.root.addEventListener("change", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private handleEvent(event: Event): void {
    const target = event.target as HTMLElement;
    const input = target.closest<HTMLInputElement | HTMLSelectElement>("[data-setting]");
    if (input && (event.type === "input" || event.type === "change")) {
      this.updateSettingFromInput(input);
      this.applySettings();
      this.status = "Previewing settings. Save to keep them.";
      this.render();
      return;
    }

    if (event.type !== "click") {
      return;
    }
    const button = target.closest<HTMLButtonElement>("button[data-settings-action]");
    if (!button) {
      return;
    }
    AudioManager.play("ui_click");
    const action = button.dataset.settingsAction;
    if (action === "save") {
      SaveSystem.saveSettings(this.settings);
      this.status = "Settings saved.";
      this.render();
    }
    if (action === "reset") {
      this.settings = DEFAULT_SETTINGS;
      this.applySettings();
      this.status = "Defaults restored. Save to keep them.";
      this.render();
    }
    if (action === "back") {
      this.scene.start(SCENE_KEYS.mainMenu);
    }
  }

  private updateSettingFromInput(input: HTMLInputElement | HTMLSelectElement): void {
    const key = input.dataset.setting;
    if (!key) {
      return;
    }
    const checked = input instanceof HTMLInputElement ? input.checked : false;
    const value = input instanceof HTMLInputElement && input.type === "range" ? Number(input.value) : input.value;
    this.settings = normalizeSettingsData({
      ...this.settings,
      [key]: input instanceof HTMLInputElement && input.type === "checkbox" ? checked : value
    });
  }

  private applySettings(): void {
    applySettingsToDocument(this.settings);
    AudioManager.configure(this.settings);
    FloatingText.configure(this.settings);
  }

  private render(): void {
    if (!this.root) {
      return;
    }
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell settings-shell asset-screen-bg" data-testid="settings-screen" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel extra-wide settings-panel">
          <p class="eyebrow">Settings</p>
          <h1>Audio & Accessibility</h1>
          <p class="menu-copy">Tune volume, motion, visibility, interface scale, and battle controls for this local profile.</p>
          <div class="status-box" data-testid="settings-status">${escapeHtml(this.status)}</div>
          <div class="settings-layout">
            <section class="settings-section">
              <h2>Audio</h2>
              ${this.renderSlider("Master Volume", "masterVolume", this.settings.masterVolume, "settings-master-volume")}
              ${this.renderSlider("Music Volume", "musicVolume", this.settings.musicVolume, "settings-music-volume")}
              ${this.renderSlider("SFX Volume", "sfxVolume", this.settings.sfxVolume, "settings-sfx-volume")}
            </section>
            <section class="settings-section">
              <h2>Accessibility</h2>
              ${this.renderToggle(
                "Reduced Motion",
                "reducedMotionEnabled",
                this.settings.reducedMotionEnabled,
                "settings-reduced-motion",
                "Quiets non-essential motion and keeps battle feedback calmer."
              )}
              ${this.renderToggle(
                "Combat Floating Text",
                "floatingTextEnabled",
                this.settings.floatingTextEnabled,
                "settings-floating-text",
                "Shows damage and healing numbers above units."
              )}
              ${this.renderToggle(
                "Screen Shake Feedback",
                "screenShakeEnabled",
                this.settings.screenShakeEnabled,
                "settings-screen-shake",
                "Adds impact shake during battle hits and warnings."
              )}
              ${this.renderToggle(
                "Colorblind Minimap Palette",
                "colorblindMinimapPalette",
                this.settings.colorblindMinimapPalette,
                "settings-colorblind-minimap",
                "Uses stronger blue and orange unit markers on the minimap."
              )}
              ${this.renderScaleSlider()}
              ${this.renderFogOverride()}
            </section>
            <section class="settings-section controls-reference">
              <h2>Keyboard Reference</h2>
              <div class="control-grid">
                <span>Left click / drag</span><strong>Select units</strong>
                <span>Shift + left click</span><strong>Add to selection</strong>
                <span>Right click ground</span><strong>Move units or set rally point</strong>
                <span>Right click enemy</span><strong>Attack target</strong>
                <span>Shift+A then right click</span><strong>Attack-move</strong>
                <span>H / Space</span><strong>Select or center hero</strong>
                <span>1, 2, 3</span><strong>Cast hero abilities</strong>
                <span>F</span><strong>Toggle fog debug</strong>
                <span>Esc</span><strong>Cancel placement or clear selection</strong>
                <span>WASD / arrows</span><strong>Pan camera</strong>
              </div>
              <p class="settings-note">On small screens, use the command panel buttons first; these keys are the fastest fallback for battle control.</p>
            </section>
          </div>
          <div class="menu-actions row">
            <button data-testid="settings-save" data-settings-action="save">Save Settings</button>
            <button data-testid="settings-reset" data-settings-action="reset">Reset Defaults</button>
            <button data-testid="settings-back" data-settings-action="back">Back</button>
          </div>
        </section>
      </main>
    `;
  }

  private renderSlider(label: string, key: keyof SaveSettingsData, value: number, testId: string): string {
    return `
      <label class="settings-control">
        <span>${escapeHtml(label)}</span>
        <input data-testid="${testId}" data-setting="${String(key)}" type="range" min="0" max="1" step="0.05" value="${value}" />
        <strong>${Math.round(value * 100)}%</strong>
      </label>
    `;
  }

  private renderScaleSlider(): string {
    return `
      <label class="settings-control">
        <span>UI Scale</span>
        <input data-testid="settings-ui-scale" data-setting="uiScale" type="range" min="0.85" max="1.25" step="0.05" value="${this.settings.uiScale}" />
        <strong>${Math.round(this.settings.uiScale * 100)}%</strong>
        <small>Scales menus, route panels, and the battle HUD together.</small>
      </label>
    `;
  }

  private renderToggle(label: string, key: keyof SaveSettingsData, value: boolean, testId: string, hint?: string): string {
    return `
      <label class="settings-toggle">
        <span>${escapeHtml(label)}</span>
        <input data-testid="${testId}" data-setting="${String(key)}" type="checkbox" ${value ? "checked" : ""} />
        ${hint ? `<small>${escapeHtml(hint)}</small>` : ""}
      </label>
    `;
  }

  private renderFogOverride(): string {
    return `
      <label class="settings-control">
        <span>Fog of War Override</span>
        <select data-testid="settings-fog-override" data-setting="fogEnabledOverride">
          ${(["default", "enabled", "disabled"] as FogEnabledOverride[])
            .map(
              (value) =>
                `<option value="${value}" ${value === this.settings.fogEnabledOverride ? "selected" : ""}>${fogOverrideLabel(value)}</option>`
            )
            .join("")}
        </select>
        <strong>${fogOverrideLabel(this.settings.fogEnabledOverride)}</strong>
        <small>Use map default for normal play; override only for visibility or testing.</small>
      </label>
    `;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
      this.root.removeEventListener("input", this.handler);
      this.root.removeEventListener("change", this.handler);
    }
  }
}

function fogOverrideLabel(value: FogEnabledOverride): string {
  if (value === "default") {
    return "Use map default";
  }
  if (value === "enabled") {
    return "Always on";
  }
  return "Always off";
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
