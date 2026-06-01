import type { BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { SAVE_KEY } from "../core/Constants";

declare global {
  interface Window {
    __ASCENDANT_PRIVATE_PLAYTEST_TOOLS__?: boolean;
  }
}

export const PRIVATE_LUME_DEMO_ID = "aether_well_lume_private_demo";
export const PRIVATE_PLAYTEST_HUB_DEMO_ID = "private_playtest_hub_demo";
export const PRIVATE_LUME_DEMO_NOTICE =
  "Private playtest demo: rewards and campaign progress are disabled for this Aether Well Lume run.";
export const PRIVATE_PLAYTEST_HUB_NOTICE =
  "Private testing only: rewards, XP, campaign progress, Retinue state, and reputation are not saved.";

let privatePlaytestHubSaveSnapshot: string | null | undefined;

export function isPrivatePlaytestToolsEnabledForPosture(dev: boolean, privateFlag?: boolean): boolean {
  return dev || privateFlag === true;
}

export function isPrivatePlaytestToolsEnabled(): boolean {
  return isPrivatePlaytestToolsEnabledForPosture(import.meta.env.DEV, globalThis.window?.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__);
}

export function isPrivateLumeDemoLaunch(request: Pick<BattleLaunchRequest, "privatePlaytestDemoId"> | undefined): boolean {
  return request?.privatePlaytestDemoId === PRIVATE_LUME_DEMO_ID;
}

export function isPrivatePlaytestHubLaunch(
  request: Pick<BattleLaunchRequest, "privatePlaytestHubScenarioId"> | undefined
): boolean {
  return Boolean(request?.privatePlaytestHubScenarioId);
}

export function beginPrivatePlaytestHubSession(): void {
  if (privatePlaytestHubSaveSnapshot !== undefined) {
    return;
  }
  privatePlaytestHubSaveSnapshot = readRawSave();
}

export function restorePrivatePlaytestHubSave(): void {
  if (privatePlaytestHubSaveSnapshot === undefined) {
    return;
  }
  writeRawSave(privatePlaytestHubSaveSnapshot);
}

export function resetPrivatePlaytestHubSession(): void {
  restorePrivatePlaytestHubSave();
  privatePlaytestHubSaveSnapshot = undefined;
}

function readRawSave(): string | null {
  try {
    return globalThis.localStorage?.getItem(SAVE_KEY) ?? null;
  } catch {
    return null;
  }
}

function writeRawSave(value: string | null): void {
  try {
    if (value === null) {
      globalThis.localStorage?.removeItem(SAVE_KEY);
      return;
    }
    globalThis.localStorage?.setItem(SAVE_KEY, value);
  } catch {
    // Private playtest preview isolation should never block launching a scenario.
  }
}
