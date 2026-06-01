import { CURRENT_SAVE_VERSION } from "./SaveDefaults";
import { migrateSaveToCurrent } from "./SaveMigrations";
import type { CurrentStoredGameSave } from "./SaveTypes";
import {
  PORTABLE_CONTENT_CHECKPOINT,
  sha256,
  stableStringify,
  type StableIdSnapshot
} from "../portable/PortableContentExport";

export const SAVE_TRANSLATION_CONTRACT_SCHEMA_VERSION = 1;
export const SAVE_TRANSLATION_CONTRACT_CHECKPOINT = "v0.102";
export const SAVE_TRANSLATION_CONTRACT_SOURCE_RUNTIME = "browser-localStorage-prototype";
export const SAVE_TRANSLATION_CONTRACT_ENGINE_BUILD = "browser-prototype-v0.102-contract";

export type SaveTranslationStatus = "translated" | "translated_with_quarantine" | "rejected";
export type SaveTranslationRejectionReason =
  | "corrupt_json"
  | "unsupported_future_version"
  | "normalization_failed";

export interface SaveTranslationFixtureInput {
  id: string;
  raw: string;
}

export interface SaveUnknownContentId {
  path: string;
  id: string;
  expectedCategories: string[];
}

export interface SaveUnsafeField {
  path: string;
  action: "dropped_by_browser_normalization" | "not_desktop_portable";
  note: string;
}

export interface SaveTranslationQuarantine {
  unknownContentIds: SaveUnknownContentId[];
  unsafeFields: SaveUnsafeField[];
  rejectionReasons: SaveTranslationRejectionReason[];
}

export interface SaveMigrationHistoryEntry {
  fromVersion: number | "unknown";
  toVersion: number;
  action: "normalized_current_version" | "migrated_v1_to_v2";
}

export interface DesktopSaveEnvelopeProof {
  schemaVersion: number;
  profileSlot: string;
  createdAt: string;
  updatedAt: string;
  engineBuildVersion: string;
  contentVersion: string;
  saveVersion: number;
  checksum: string;
  sourceRuntime: typeof SAVE_TRANSLATION_CONTRACT_SOURCE_RUNTIME;
  migrationHistory: SaveMigrationHistoryEntry[];
  payload: CurrentStoredGameSave;
  quarantine: SaveTranslationQuarantine;
}

export interface SaveTranslationResult {
  fixtureId: string;
  status: SaveTranslationStatus;
  originalVersion: number | "unknown";
  saveVersion?: number;
  envelopeChecksum?: string;
  migrationHistory: SaveMigrationHistoryEntry[];
  quarantine: SaveTranslationQuarantine;
}

export interface SaveTranslationContractReport {
  schemaVersion: number;
  checkpoint: string;
  sourceRuntime: typeof SAVE_TRANSLATION_CONTRACT_SOURCE_RUNTIME;
  contentVersion: string;
  fixtureCount: number;
  translatedCount: number;
  translatedWithQuarantineCount: number;
  rejectedCount: number;
  unknownContentIdCount: number;
  unsafeFieldCount: number;
  results: SaveTranslationResult[];
}

type JsonRecord = Record<string, unknown>;
type SnapshotIdSets = Record<string, Set<string>>;

const ROOT_KEYS = new Set(["version", "createdAt", "updatedAt", "hero", "campaign", "settings", "statistics"]);
const HERO_KEYS = new Set([
  "heroName",
  "classId",
  "originId",
  "level",
  "xp",
  "skillPoints",
  "unlockedAbilities",
  "completedBattles",
  "clearedMapIds",
  "inventory",
  "equipment",
  "allocatedSkills",
  "items",
  "factionReputation",
  "stats"
]);
const CAMPAIGN_KEYS = new Set([
  "started",
  "difficulty",
  "resources",
  "resourcesSpent",
  "completedNodeIds",
  "unlockedNodeIds",
  "lockedNodeIds",
  "nodeRewardsClaimedIds",
  "optionalObjectiveCompletionIds",
  "choiceIdsClaimed",
  "townServiceClaimedIds",
  "townServiceUseCounts",
  "activeModifierIds",
  "strongholdUpgradeRanks",
  "strongholdUpgradeIds",
  "retinueUnits",
  "retinueDeploymentIds",
  "rivals",
  "rivalTrophies",
  "selectedChapterId",
  "selectedNodeId"
]);
const SETTINGS_KEYS = new Set([
  "masterVolume",
  "musicVolume",
  "sfxVolume",
  "screenShakeEnabled",
  "floatingTextEnabled",
  "fogEnabledOverride",
  "reducedMotionEnabled",
  "uiScale",
  "colorblindMinimapPalette"
]);
const RESOURCE_KEYS = new Set(["crowns", "stone", "iron", "aether"]);
const EQUIPMENT_SLOTS = new Set(["weapon", "armor", "trinket", "relic"]);

export function translateBrowserSaveFixture(
  fixture: SaveTranslationFixtureInput,
  snapshot: StableIdSnapshot
): { result: SaveTranslationResult; envelope?: DesktopSaveEnvelopeProof } {
  const parsed = parseFixtureJson(fixture.raw);
  if (!parsed.ok) {
    return rejectedResult(fixture.id, "unknown", ["corrupt_json"], {
      unknownContentIds: [],
      unsafeFields: [],
      rejectionReasons: ["corrupt_json"]
    });
  }

  const originalVersion = getOriginalVersion(parsed.value);
  if (typeof originalVersion === "number" && originalVersion > CURRENT_SAVE_VERSION) {
    return rejectedResult(fixture.id, originalVersion, ["unsupported_future_version"], {
      unknownContentIds: [],
      unsafeFields: detectUnsafeFields(parsed.value),
      rejectionReasons: ["unsupported_future_version"]
    });
  }

  const idSets = createSnapshotIdSets(snapshot);
  const quarantine: SaveTranslationQuarantine = {
    unknownContentIds: detectUnknownContentIds(parsed.value, idSets),
    unsafeFields: detectUnsafeFields(parsed.value),
    rejectionReasons: []
  };
  const normalized = migrateSaveToCurrent(parsed.value);

  if (!normalized) {
    quarantine.rejectionReasons.push("normalization_failed");
    return rejectedResult(fixture.id, originalVersion, quarantine.rejectionReasons, quarantine);
  }

  const migrationHistory = migrationHistoryFor(originalVersion);
  const envelopeWithoutChecksum: Omit<DesktopSaveEnvelopeProof, "checksum"> = {
    schemaVersion: SAVE_TRANSLATION_CONTRACT_SCHEMA_VERSION,
    profileSlot: `contract-fixture:${fixture.id}`,
    createdAt: normalized.createdAt,
    updatedAt: normalized.updatedAt,
    engineBuildVersion: SAVE_TRANSLATION_CONTRACT_ENGINE_BUILD,
    contentVersion: PORTABLE_CONTENT_CHECKPOINT,
    saveVersion: normalized.version,
    sourceRuntime: SAVE_TRANSLATION_CONTRACT_SOURCE_RUNTIME,
    migrationHistory,
    payload: normalized,
    quarantine
  };
  const checksum = sha256(stableStringify(envelopeWithoutChecksum));
  const envelope: DesktopSaveEnvelopeProof = {
    ...envelopeWithoutChecksum,
    checksum
  };
  const status: SaveTranslationStatus =
    quarantine.unknownContentIds.length > 0 || quarantine.unsafeFields.length > 0
      ? "translated_with_quarantine"
      : "translated";

  return {
    envelope,
    result: {
      fixtureId: fixture.id,
      status,
      originalVersion,
      saveVersion: normalized.version,
      envelopeChecksum: checksum,
      migrationHistory,
      quarantine
    }
  };
}

export function createSaveTranslationContractReport(
  fixtures: SaveTranslationFixtureInput[],
  snapshot: StableIdSnapshot
): SaveTranslationContractReport {
  const results = fixtures.map((fixture) => translateBrowserSaveFixture(fixture, snapshot).result);
  return {
    schemaVersion: SAVE_TRANSLATION_CONTRACT_SCHEMA_VERSION,
    checkpoint: SAVE_TRANSLATION_CONTRACT_CHECKPOINT,
    sourceRuntime: SAVE_TRANSLATION_CONTRACT_SOURCE_RUNTIME,
    contentVersion: PORTABLE_CONTENT_CHECKPOINT,
    fixtureCount: fixtures.length,
    translatedCount: results.filter((result) => result.status === "translated").length,
    translatedWithQuarantineCount: results.filter((result) => result.status === "translated_with_quarantine").length,
    rejectedCount: results.filter((result) => result.status === "rejected").length,
    unknownContentIdCount: results.reduce((total, result) => total + result.quarantine.unknownContentIds.length, 0),
    unsafeFieldCount: results.reduce((total, result) => total + result.quarantine.unsafeFields.length, 0),
    results: results.sort((left, right) => left.fixtureId.localeCompare(right.fixtureId))
  };
}

export function createSaveTranslationContractMarkdown(report: SaveTranslationContractReport): string {
  const lines = [
    "# Save Translation Contract Summary",
    "",
    `Checkpoint: ${report.checkpoint}`,
    `Source runtime: ${report.sourceRuntime}`,
    `Content version: ${report.contentVersion}`,
    "",
    "| Metric | Count |",
    "| --- | ---: |",
    `| Fixtures | ${report.fixtureCount} |`,
    `| Translated | ${report.translatedCount} |`,
    `| Translated with quarantine | ${report.translatedWithQuarantineCount} |`,
    `| Rejected | ${report.rejectedCount} |`,
    `| Unknown content ids | ${report.unknownContentIdCount} |`,
    `| Unsafe fields | ${report.unsafeFieldCount} |`,
    "",
    "| Fixture | Status | Save version | Unknown ids | Unsafe fields | Rejections |",
    "| --- | --- | ---: | ---: | ---: | --- |"
  ];
  report.results.forEach((result) => {
    lines.push(
      `| ${result.fixtureId} | ${result.status} | ${result.saveVersion ?? "-"} | ${result.quarantine.unknownContentIds.length} | ${result.quarantine.unsafeFields.length} | ${result.quarantine.rejectionReasons.join(", ") || "-"} |`
    );
  });
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function parseFixtureJson(raw: string): { ok: true; value: unknown } | { ok: false } {
  try {
    return { ok: true, value: JSON.parse(raw) };
  } catch {
    return { ok: false };
  }
}

function rejectedResult(
  fixtureId: string,
  originalVersion: number | "unknown",
  reasons: SaveTranslationRejectionReason[],
  quarantine: SaveTranslationQuarantine
): { result: SaveTranslationResult } {
  return {
    result: {
      fixtureId,
      status: "rejected",
      originalVersion,
      migrationHistory: [],
      quarantine: {
        ...quarantine,
        rejectionReasons: [...new Set(reasons)]
      }
    }
  };
}

function getOriginalVersion(value: unknown): number | "unknown" {
  if (!isRecord(value) || typeof value.version !== "number" || !Number.isFinite(value.version)) {
    return "unknown";
  }
  return Math.floor(value.version);
}

function migrationHistoryFor(originalVersion: number | "unknown"): SaveMigrationHistoryEntry[] {
  if (originalVersion === 1) {
    return [{ fromVersion: 1, toVersion: CURRENT_SAVE_VERSION, action: "migrated_v1_to_v2" }];
  }
  return [{ fromVersion: originalVersion, toVersion: CURRENT_SAVE_VERSION, action: "normalized_current_version" }];
}

function createSnapshotIdSets(snapshot: StableIdSnapshot): SnapshotIdSets {
  return Object.fromEntries(
    Object.entries(snapshot.categories).map(([category, ids]) => [category, new Set(ids)])
  ) as SnapshotIdSets;
}

function detectUnsafeFields(value: unknown): SaveUnsafeField[] {
  if (!isRecord(value)) {
    return [];
  }
  const fields: SaveUnsafeField[] = [];
  detectUnknownKeys(value, ROOT_KEYS, "", fields);
  if (isRecord(value.hero)) {
    detectUnknownKeys(value.hero, HERO_KEYS, "hero", fields);
  }
  if (isRecord(value.campaign)) {
    detectUnknownKeys(value.campaign, CAMPAIGN_KEYS, "campaign", fields);
    if (isRecord(value.campaign.resources)) {
      detectUnknownKeys(value.campaign.resources, RESOURCE_KEYS, "campaign.resources", fields);
    }
    if (isRecord(value.campaign.resourcesSpent)) {
      detectUnknownKeys(value.campaign.resourcesSpent, RESOURCE_KEYS, "campaign.resourcesSpent", fields);
    }
  }
  if (isRecord(value.settings)) {
    detectUnknownKeys(value.settings, SETTINGS_KEYS, "settings", fields);
  }
  return fields.sort(compareByPathThenId);
}

function detectUnknownKeys(
  value: JsonRecord,
  knownKeys: Set<string>,
  prefix: string,
  fields: SaveUnsafeField[]
): void {
  Object.keys(value).forEach((key) => {
    if (knownKeys.has(key)) {
      return;
    }
    const path = prefix ? `${prefix}.${key}` : key;
    fields.push({
      path,
      action: "dropped_by_browser_normalization",
      note: "Field is not part of the current browser save contract and is quarantined for desktop translation review."
    });
  });
}

function detectUnknownContentIds(value: unknown, idSets: SnapshotIdSets): SaveUnknownContentId[] {
  if (!isRecord(value)) {
    return [];
  }
  const unknown: SaveUnknownContentId[] = [];
  if (isRecord(value.hero)) {
    validateStringId(unknown, idSets, "hero.classId", value.hero.classId, ["heroClasses"]);
    validateStringId(unknown, idSets, "hero.originId", value.hero.originId, ["origins"]);
    validateStringArray(unknown, idSets, "hero.unlockedAbilities", value.hero.unlockedAbilities, ["abilities"]);
    validateStringArray(unknown, idSets, "hero.clearedMapIds", value.hero.clearedMapIds, ["maps"]);
    validateInventoryIds(unknown, idSets, value.hero.inventory);
    validateLegacyItemIds(unknown, idSets, value.hero.items);
    validateEquipmentIds(unknown, idSets, value.hero.equipment, value.hero.inventory);
    validateRecordKeys(unknown, idSets, "hero.allocatedSkills", value.hero.allocatedSkills, ["skills"]);
    validateRecordKeys(unknown, idSets, "hero.factionReputation", value.hero.factionReputation, ["factions"]);
  }
  if (isRecord(value.campaign)) {
    validateRecordKeys(unknown, idSets, "campaign.resources", value.campaign.resources, ["resources"]);
    validateRecordKeys(unknown, idSets, "campaign.resourcesSpent", value.campaign.resourcesSpent, ["resources"]);
    validateStringArray(unknown, idSets, "campaign.completedNodeIds", value.campaign.completedNodeIds, ["nodes"]);
    validateStringArray(unknown, idSets, "campaign.unlockedNodeIds", value.campaign.unlockedNodeIds, ["nodes"]);
    validateStringArray(unknown, idSets, "campaign.lockedNodeIds", value.campaign.lockedNodeIds, ["nodes"]);
    validateStringArray(unknown, idSets, "campaign.nodeRewardsClaimedIds", value.campaign.nodeRewardsClaimedIds, ["nodes"]);
    validateCompositeNodeIds(unknown, idSets, "campaign.optionalObjectiveCompletionIds", value.campaign.optionalObjectiveCompletionIds, ["optionalObjectives"]);
    validateCompositeNodeIds(unknown, idSets, "campaign.choiceIdsClaimed", value.campaign.choiceIdsClaimed);
    validateCompositeNodeIds(unknown, idSets, "campaign.townServiceClaimedIds", value.campaign.townServiceClaimedIds);
    validateCompositeRecordKeys(unknown, idSets, "campaign.townServiceUseCounts", value.campaign.townServiceUseCounts);
    validateStringArray(unknown, idSets, "campaign.activeModifierIds", value.campaign.activeModifierIds, ["modifiers"]);
    validateRecordKeys(unknown, idSets, "campaign.strongholdUpgradeRanks", value.campaign.strongholdUpgradeRanks, ["strongholdUpgrades"]);
    validateRetinueIds(unknown, idSets, value.campaign.retinueUnits, value.campaign.retinueDeploymentIds);
    validateRivalIds(unknown, idSets, value.campaign.rivals);
    validateRivalTrophyIds(unknown, idSets, value.campaign.rivalTrophies);
    validateStringId(unknown, idSets, "campaign.selectedChapterId", value.campaign.selectedChapterId, ["chapters"]);
    validateStringId(unknown, idSets, "campaign.selectedNodeId", value.campaign.selectedNodeId, ["nodes"]);
  }
  return dedupeUnknownContentIds(unknown).sort(compareByPathThenId);
}

function validateInventoryIds(unknown: SaveUnknownContentId[], idSets: SnapshotIdSets, value: unknown): void {
  if (!Array.isArray(value)) {
    return;
  }
  value.forEach((entry, index) => {
    if (typeof entry === "string") {
      validateStringId(unknown, idSets, `hero.inventory[${index}]`, entry, ["equipment", "relics"]);
      return;
    }
    if (!isRecord(entry)) {
      return;
    }
    validateStringId(unknown, idSets, `hero.inventory[${index}].itemId`, entry.itemId, ["equipment", "relics"]);
    if (Array.isArray(entry.affixes)) {
      entry.affixes.forEach((affix, affixIndex) => {
        if (typeof affix === "string") {
          validateStringId(unknown, idSets, `hero.inventory[${index}].affixes[${affixIndex}]`, `affix:${affix}`, ["equipment"]);
        }
      });
    }
  });
}

function validateLegacyItemIds(unknown: SaveUnknownContentId[], idSets: SnapshotIdSets, value: unknown): void {
  validateStringArray(unknown, idSets, "hero.items", value, ["equipment", "relics"]);
}

function validateEquipmentIds(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  equipment: unknown,
  inventory: unknown
): void {
  if (!isRecord(equipment)) {
    return;
  }
  const instanceIds = new Set<string>();
  if (Array.isArray(inventory)) {
    inventory.forEach((entry) => {
      if (isRecord(entry) && typeof entry.instanceId === "string") {
        instanceIds.add(entry.instanceId);
      }
    });
  }
  Object.entries(equipment).forEach(([slot, itemOrInstanceId]) => {
    if (!EQUIPMENT_SLOTS.has(slot) || typeof itemOrInstanceId !== "string") {
      return;
    }
    if (instanceIds.has(itemOrInstanceId)) {
      return;
    }
    validateStringId(unknown, idSets, `hero.equipment.${slot}`, itemOrInstanceId, ["equipment", "relics"]);
  });
}

function validateCompositeNodeIds(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  path: string,
  value: unknown,
  secondaryCategories?: string[]
): void {
  if (!Array.isArray(value)) {
    return;
  }
  value.forEach((entry, index) => {
    if (typeof entry !== "string") {
      return;
    }
    const [nodeId, secondaryId] = entry.split(":");
    validateStringId(unknown, idSets, `${path}[${index}].nodeId`, nodeId, ["nodes"]);
    if (secondaryCategories && secondaryId) {
      validateStringId(unknown, idSets, `${path}[${index}].targetId`, secondaryId, secondaryCategories);
    }
  });
}

function validateCompositeRecordKeys(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  path: string,
  value: unknown
): void {
  if (!isRecord(value)) {
    return;
  }
  validateCompositeNodeIds(unknown, idSets, path, Object.keys(value));
}

function validateRetinueIds(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  retinueUnits: unknown,
  deploymentIds: unknown
): void {
  const retinueUnitIds = new Set<string>();
  if (Array.isArray(retinueUnits)) {
    retinueUnits.forEach((unit, index) => {
      if (!isRecord(unit)) {
        return;
      }
      if (typeof unit.retinueUnitId === "string") {
        retinueUnitIds.add(unit.retinueUnitId);
      }
      validateStringId(unknown, idSets, `campaign.retinueUnits[${index}].unitTypeId`, unit.unitTypeId, ["units"]);
      validateStringId(unknown, idSets, `campaign.retinueUnits[${index}].sourceBattleId`, unit.sourceBattleId, ["nodes"]);
    });
  }
  if (Array.isArray(deploymentIds)) {
    deploymentIds.forEach((id, index) => {
      if (typeof id === "string" && !retinueUnitIds.has(id)) {
        unknown.push({
          path: `campaign.retinueDeploymentIds[${index}]`,
          id,
          expectedCategories: ["retinueUnits"]
        });
      }
    });
  }
}

function validateRivalIds(unknown: SaveUnknownContentId[], idSets: SnapshotIdSets, rivals: unknown): void {
  if (!Array.isArray(rivals)) {
    return;
  }
  rivals.forEach((rival, index) => {
    if (!isRecord(rival)) {
      return;
    }
    validateStringId(unknown, idSets, `campaign.rivals[${index}].enemyHeroId`, rival.enemyHeroId, ["enemyHeroes"]);
    validateStringId(unknown, idSets, `campaign.rivals[${index}].lastEncounterNodeId`, rival.lastEncounterNodeId, ["nodes"]);
  });
}

function validateRivalTrophyIds(unknown: SaveUnknownContentId[], idSets: SnapshotIdSets, trophies: unknown): void {
  if (!Array.isArray(trophies)) {
    return;
  }
  trophies.forEach((trophy, index) => {
    if (!isRecord(trophy)) {
      return;
    }
    validateStringId(unknown, idSets, `campaign.rivalTrophies[${index}].enemyHeroId`, trophy.enemyHeroId, ["enemyHeroes"]);
    validateStringId(unknown, idSets, `campaign.rivalTrophies[${index}].sourceNodeId`, trophy.sourceNodeId, ["nodes"]);
  });
}

function validateRecordKeys(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  path: string,
  value: unknown,
  categories: string[]
): void {
  if (!isRecord(value)) {
    return;
  }
  Object.keys(value).forEach((id) => validateStringId(unknown, idSets, `${path}.${id}`, id, categories));
}

function validateStringArray(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  path: string,
  value: unknown,
  categories: string[]
): void {
  if (!Array.isArray(value)) {
    return;
  }
  value.forEach((id, index) => validateStringId(unknown, idSets, `${path}[${index}]`, id, categories));
}

function validateStringId(
  unknown: SaveUnknownContentId[],
  idSets: SnapshotIdSets,
  path: string,
  value: unknown,
  categories: string[]
): void {
  if (typeof value !== "string" || !value.trim()) {
    return;
  }
  if (value === "unknown") {
    return;
  }
  const known = categories.some((category) => idSets[category]?.has(value));
  if (known) {
    return;
  }
  unknown.push({ path, id: value, expectedCategories: categories });
}

function dedupeUnknownContentIds(ids: SaveUnknownContentId[]): SaveUnknownContentId[] {
  const seen = new Set<string>();
  return ids.filter((entry) => {
    const key = `${entry.path}\n${entry.id}\n${entry.expectedCategories.join("|")}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}

function compareByPathThenId(
  left: { path: string; id?: string },
  right: { path: string; id?: string }
): number {
  return left.path.localeCompare(right.path) || (left.id ?? "").localeCompare(right.id ?? "");
}

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null;
}
