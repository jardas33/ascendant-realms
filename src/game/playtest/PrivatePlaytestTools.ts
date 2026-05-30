import type { BattleLaunchRequest } from "../battle/BattleLaunchRequest";

declare global {
  interface Window {
    __ASCENDANT_PRIVATE_PLAYTEST_TOOLS__?: boolean;
  }
}

export const PRIVATE_LUME_DEMO_ID = "aether_well_lume_private_demo";
export const PRIVATE_LUME_DEMO_NOTICE =
  "Private playtest demo: rewards and campaign progress are disabled for this Aether Well Lume run.";

export function isPrivatePlaytestToolsEnabled(): boolean {
  return import.meta.env.DEV || globalThis.window?.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__ === true;
}

export function isPrivateLumeDemoLaunch(request: Pick<BattleLaunchRequest, "privatePlaytestDemoId"> | undefined): boolean {
  return request?.privatePlaytestDemoId === PRIVATE_LUME_DEMO_ID;
}
