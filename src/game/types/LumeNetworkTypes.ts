import type { Position, Team } from "./UITypes";

export type LumeNetworkActivationMode = "capture_only";
export type LumeNetworkBenefitId = "linked_ward";
export type LumeNetworkCurrentLinkState = "inactive" | "active" | "contested" | "severed";

export interface LumeNetworkBenefitDefinition {
  id: LumeNetworkBenefitId;
  name: string;
  summary: string;
  damageTakenMultiplier: number;
  endpointRadiusBonus: number;
  nonStacking: true;
}

export interface LumeNetworkLinkDefinition {
  id: string;
  fromSiteId: string;
  toSiteId: string;
  displayName: string;
}

export interface LumeNetworkDefinition {
  id: string;
  campaignNodeId: string;
  mapId: string;
  mode: "campaign_node";
  rewardsDisabledExcluded: true;
  tutorialExcluded: true;
  activationMode: LumeNetworkActivationMode;
  eligibleSiteIds: string[];
  links: LumeNetworkLinkDefinition[];
  maxEligibleSites: number;
  maxActiveLinks: number;
  benefit: LumeNetworkBenefitDefinition;
  briefingCopy: string;
  hudObjective: string;
  counterplay: string;
  battleLocalCopy: string;
}

export interface LumeSiteSnapshot {
  id: string;
  name: string;
  owner: Team;
  alive: boolean;
  position: Position;
  radius: number;
  captureProgress?: number;
  capturingTeam?: Team;
}

export interface LumeTargetSnapshot {
  team: Team;
  alive: boolean;
  position: Position;
}

export interface LumeResolvedLinkState {
  id: string;
  displayName: string;
  fromSiteId: string;
  toSiteId: string;
  fromSiteName: string;
  toSiteName: string;
  state: LumeNetworkCurrentLinkState;
  active: boolean;
  contested: boolean;
}

export interface LumeNetworkResolvedState {
  networkId: string;
  activeLinkIds: string[];
  inactiveLinkIds: string[];
  contestedLinkIds: string[];
  currentSeveredLinkIds: string[];
  lifetimeActivatedLinkIds: string[];
  lifetimeSeveredLinkIds: string[];
  objectiveCompleted: boolean;
  links: LumeResolvedLinkState[];
}

export interface LumeNetworkHudSummary {
  title: string;
  objective: string;
  status: string;
  benefit: string;
  counterplay: string;
  activeLinkCount: number;
  maxActiveLinks: number;
}

export interface LumeNetworkSiteSummary {
  title: string;
  state: LumeNetworkCurrentLinkState;
  linkedSites: string;
  benefit: string;
  counterplay: string;
}
