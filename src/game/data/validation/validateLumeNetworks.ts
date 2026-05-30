import type { LumeNetworkDefinition } from "../../core/GameTypes";
import { CAMPAIGN_NODES } from "../campaignNodes";
import { LUME_NETWORKS } from "../lumeNetworks";
import { MAPS } from "../maps";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

const RECOGNIZED_ACTIVATION_MODES = new Set(["capture_only"]);
const RECOGNIZED_BENEFITS = new Set(["linked_ward"]);

export function validateLumeNetworks(errors: string[], context: ValidationContext): void {
  assertUniqueIds(LUME_NETWORKS, "Lume network", errors);
  LUME_NETWORKS.forEach((network) => validateLumeNetwork(network, errors, context));
}

function validateLumeNetwork(network: LumeNetworkDefinition, errors: string[], context: ValidationContext): void {
  if (!context.campaignNodeIds.has(network.campaignNodeId)) {
    errors.push(`Lume network ${network.id} references missing campaign node ${network.campaignNodeId}.`);
  }
  const node = CAMPAIGN_NODES.find((entry) => entry.id === network.campaignNodeId);
  if (node && node.nodeType !== "battle") {
    errors.push(`Lume network ${network.id} is attached to non-battle node ${network.campaignNodeId}.`);
  }
  if (node && node.mapId !== network.mapId) {
    errors.push(`Lume network ${network.id} map ${network.mapId} does not match node ${network.campaignNodeId} map ${node.mapId}.`);
  }
  if (network.mode !== "campaign_node") {
    errors.push(`Lume network ${network.id} must be campaign_node only.`);
  }
  if (!network.rewardsDisabledExcluded || !network.tutorialExcluded) {
    errors.push(`Lume network ${network.id} must explicitly exclude Tutorial and rewards-disabled launches.`);
  }
  if (!RECOGNIZED_ACTIVATION_MODES.has(network.activationMode)) {
    errors.push(`Lume network ${network.id} uses unknown activation mode ${network.activationMode}.`);
  }
  if (!RECOGNIZED_BENEFITS.has(network.benefit.id)) {
    errors.push(`Lume network ${network.id} uses unknown benefit ${network.benefit.id}.`);
  }
  if (network.benefit.id === "linked_ward") {
    if (network.benefit.damageTakenMultiplier < 0.9 || network.benefit.damageTakenMultiplier > 0.98) {
      errors.push(`Lume network ${network.id} Linked Ward damage multiplier must stay modest.`);
    }
    if (!network.benefit.nonStacking) {
      errors.push(`Lume network ${network.id} Linked Ward must be non-stacking.`);
    }
  }
  if (network.eligibleSiteIds.length > network.maxEligibleSites || network.maxEligibleSites !== 3) {
    errors.push(`Lume network ${network.id} must use at most three eligible sites for v0.82.`);
  }
  if (network.links.length > network.maxActiveLinks || network.maxActiveLinks !== 2) {
    errors.push(`Lume network ${network.id} must use at most two links for v0.82.`);
  }
  assertUniqueIds(network.links, `Lume network ${network.id} link`, errors);
  validateUniqueStrings(network.eligibleSiteIds, `Lume network ${network.id} eligible site`, errors);

  const map = MAPS.find((entry) => entry.id === network.mapId);
  if (!map) {
    errors.push(`Lume network ${network.id} references missing map ${network.mapId}.`);
    return;
  }
  const mapSiteIds = new Set(map.captureSites.map((site) => site.id));
  const eligibleSiteIds = new Set(network.eligibleSiteIds);
  network.eligibleSiteIds.forEach((siteId) => {
    if (!mapSiteIds.has(siteId)) {
      errors.push(`Lume network ${network.id} eligible site ${siteId} is not on map ${network.mapId}.`);
    }
  });
  network.links.forEach((link) => {
    if (link.fromSiteId === link.toSiteId) {
      errors.push(`Lume network ${network.id} link ${link.id} cannot link a site to itself.`);
    }
    if (!eligibleSiteIds.has(link.fromSiteId) || !eligibleSiteIds.has(link.toSiteId)) {
      errors.push(`Lume network ${network.id} link ${link.id} uses an endpoint outside the eligible site set.`);
    }
    if (!mapSiteIds.has(link.fromSiteId) || !mapSiteIds.has(link.toSiteId)) {
      errors.push(`Lume network ${network.id} link ${link.id} references a missing map capture site.`);
    }
    if (!link.displayName.trim()) {
      errors.push(`Lume network ${network.id} link ${link.id} needs display copy.`);
    }
  });
  validateUndirectedLinkUniqueness(network, errors);
  if (!network.briefingCopy.trim() || !network.hudObjective.trim() || !network.counterplay.trim()) {
    errors.push(`Lume network ${network.id} needs briefing, HUD, and counterplay copy.`);
  }
}

function validateUniqueStrings(values: string[], label: string, errors: string[]): void {
  const seen = new Set<string>();
  values.forEach((value) => {
    if (!value.trim()) {
      errors.push(`${label} has an empty id.`);
    }
    if (seen.has(value)) {
      errors.push(`Duplicate ${label} id: ${value}.`);
    }
    seen.add(value);
  });
}

function validateUndirectedLinkUniqueness(network: LumeNetworkDefinition, errors: string[]): void {
  const seen = new Set<string>();
  network.links.forEach((link) => {
    const key = [link.fromSiteId, link.toSiteId].sort().join("<->");
    if (seen.has(key)) {
      errors.push(`Lume network ${network.id} duplicates link endpoints ${key}.`);
    }
    seen.add(key);
  });
}
