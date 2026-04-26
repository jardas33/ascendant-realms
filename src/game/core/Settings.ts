import type { FogEnabledOverride, SaveSettingsData } from "../save/SaveTypes";

export const DEFAULT_SETTINGS: SaveSettingsData = {
  masterVolume: 0.8,
  musicVolume: 0.55,
  sfxVolume: 0.75,
  screenShakeEnabled: true,
  floatingTextEnabled: true,
  fogEnabledOverride: "default",
  reducedMotionEnabled: false,
  uiScale: 1,
  colorblindMinimapPalette: false
};

const FOG_OVERRIDES: FogEnabledOverride[] = ["default", "enabled", "disabled"];

export function normalizeSettingsData(value: unknown): SaveSettingsData {
  const source = isRecord(value) ? value : {};
  return {
    masterVolume: clampUnit(source.masterVolume, DEFAULT_SETTINGS.masterVolume),
    musicVolume: clampUnit(source.musicVolume, DEFAULT_SETTINGS.musicVolume),
    sfxVolume: clampUnit(source.sfxVolume, DEFAULT_SETTINGS.sfxVolume),
    screenShakeEnabled: booleanOrDefault(source.screenShakeEnabled, DEFAULT_SETTINGS.screenShakeEnabled),
    floatingTextEnabled: booleanOrDefault(source.floatingTextEnabled, DEFAULT_SETTINGS.floatingTextEnabled),
    fogEnabledOverride: isFogOverride(source.fogEnabledOverride)
      ? source.fogEnabledOverride
      : DEFAULT_SETTINGS.fogEnabledOverride,
    reducedMotionEnabled: booleanOrDefault(source.reducedMotionEnabled, DEFAULT_SETTINGS.reducedMotionEnabled),
    uiScale: clampRange(source.uiScale, 0.85, 1.25, DEFAULT_SETTINGS.uiScale),
    colorblindMinimapPalette: booleanOrDefault(
      source.colorblindMinimapPalette,
      DEFAULT_SETTINGS.colorblindMinimapPalette
    )
  };
}

export function applySettingsToDocument(settings: SaveSettingsData): void {
  const root = globalThis.document?.documentElement;
  if (!root) {
    return;
  }
  root.style.setProperty("--ui-scale", settings.uiScale.toFixed(2));
  root.dataset.reducedMotion = settings.reducedMotionEnabled ? "true" : "false";
  root.dataset.colorblindMinimap = settings.colorblindMinimapPalette ? "true" : "false";
}

export function shouldShowFloatingText(settings: SaveSettingsData): boolean {
  return settings.floatingTextEnabled;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function booleanOrDefault(value: unknown, fallback: boolean): boolean {
  return typeof value === "boolean" ? value : fallback;
}

function isFogOverride(value: unknown): value is FogEnabledOverride {
  return typeof value === "string" && FOG_OVERRIDES.includes(value as FogEnabledOverride);
}

function clampUnit(value: unknown, fallback: number): number {
  return clampRange(value, 0, 1, fallback);
}

function clampRange(value: unknown, min: number, max: number, fallback: number): number {
  const numeric = typeof value === "number" && Number.isFinite(value) ? value : fallback;
  return Math.min(max, Math.max(min, Number(numeric.toFixed(3))));
}
