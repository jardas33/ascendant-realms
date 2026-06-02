import type { HUDDensityControl, HudDensityMode } from "./HudTypes";

export const PUBLIC_HUD_DENSITY_MODE: HudDensityMode = "minimal";
export const PRIVATE_HUD_DENSITY_MODE: HudDensityMode = "standard";
export const HUD_DENSITY_MODES = ["minimal", "standard", "debug"] as const;

const HUD_DENSITY_LABELS: Record<HudDensityMode, { label: string; description: string }> = {
  minimal: {
    label: "Minimal",
    description: "Public battle HUD: resources, primary status, minimap, and essential selected controls."
  },
  standard: {
    label: "Standard",
    description: "Private review HUD with the full detail surfaces used by regression and visual QA."
  },
  debug: {
    label: "Debug",
    description: "Private profiler HUD with extra rendering and counter diagnostics."
  }
};

export function isHudDensityMode(value: string): value is HudDensityMode {
  return HUD_DENSITY_MODES.includes(value as HudDensityMode);
}

export function normalizeHudDensityMode(value: string | undefined, privateToolsEnabled: boolean): HudDensityMode {
  if (!privateToolsEnabled) {
    return PUBLIC_HUD_DENSITY_MODE;
  }
  return value && isHudDensityMode(value) ? value : PRIVATE_HUD_DENSITY_MODE;
}

export function createHudDensityControls(activeMode: HudDensityMode, privateToolsEnabled: boolean): HUDDensityControl[] {
  if (!privateToolsEnabled) {
    return [];
  }
  return HUD_DENSITY_MODES.map((mode) => ({
    mode,
    label: HUD_DENSITY_LABELS[mode].label,
    description: HUD_DENSITY_LABELS[mode].description,
    active: mode === activeMode
  }));
}

export function shouldRenderHudDebugCounters(mode: HudDensityMode, privateToolsEnabled: boolean): boolean {
  return privateToolsEnabled && mode === "debug";
}
