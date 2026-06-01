import { createHash } from "node:crypto";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { ABILITIES } from "../data/abilities";
import { ACT1_CAMPAIGN_SPINE } from "../data/act1CampaignSpine";
import {
  ACT1_FINALE_COMMANDER_ID,
  ACT1_FINALE_MAP_ID,
  ACT1_FINALE_NODE_ID,
  ACT1_FINALE_PHASES
} from "../data/act1Finale";
import { BATTLEFIELD_EVENTS } from "../data/battlefieldEvents";
import { BUILDINGS } from "../data/buildings";
import { CAMPAIGN_CHAPTERS } from "../data/campaignChapters";
import { CAMPAIGN_MODIFIERS } from "../data/campaignModifiers";
import { CAMPAIGN_NODES } from "../data/campaignNodes";
import { ENEMY_DOCTRINES, ENEMY_ELITE_SQUADS } from "../data/enemyDoctrines";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES } from "../data/enemyHeroes";
import { ENEMY_PRESSURE_PLANS } from "../data/enemyPressurePlans";
import { FACTIONS } from "../data/factions";
import { HERO_CLASSES } from "../data/heroClasses";
import { AI_PERSONALITIES as ENEMY_PERSONALITIES_EXPORT } from "../data/aiPersonalities";
import { ITEM_AFFIXES } from "../data/itemAffixes";
import { ITEMS } from "../data/items";
import { LUME_NETWORKS } from "../data/lumeNetworks";
import { MAPS } from "../data/maps";
import { CAMPAIGN_MISSION_TYPES } from "../data/missionTypes";
import { ORIGINS } from "../data/origins";
import { RELIC_REWARD_DEFINITIONS } from "../data/relicRewards";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { REWARD_TABLES } from "../data/rewards";
import { RIVAL_REWARDS } from "../data/rivalRewards";
import { SKILL_NODES, SKILL_TREES } from "../data/skillTrees";
import { STRONGHOLD_UPGRADES } from "../data/strongholdUpgrades";
import { TACTICAL_PLANS } from "../data/tacticalPlans";
import { UNIT_ROLE_IDENTITIES } from "../data/unitRoles";
import { UNIT_VETERANCY_RANKS, UNIT_VETERANCY_XP_RULES } from "../data/unitVeterancy";
import { UNITS } from "../data/units";
import { UPGRADES } from "../data/upgrades";
import { validateContent } from "../data/contentValidation";
import {
  RETINUE_BASE_DEPLOYMENT_CAPACITY,
  RETINUE_ELIGIBLE_UNIT_TYPE_IDS,
  RETINUE_RECOVERY_HP_RATIO_THRESHOLD,
  RETINUE_RECOVERY_MISSION_STEPS,
  RETINUE_ROSTER_CAPACITY,
  RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS
} from "../core/RetinueRules";

export const PORTABLE_CONTENT_SCHEMA_VERSION = 1;
export const PORTABLE_CONTENT_CHECKPOINT = "v0.101";
export const DEFAULT_PORTABLE_CONTENT_OUT_DIR = "artifacts/portable-content/latest";
export const DEFAULT_STABLE_ID_SNAPSHOT_PATH = "src/game/portable/stable-id-snapshot.json";

export const PORTABLE_CONTENT_CATEGORY_IDS = [
  "factions",
  "resources",
  "heroClasses",
  "origins",
  "abilities",
  "skills",
  "relics",
  "equipment",
  "units",
  "unitRoles",
  "buildings",
  "upgrades",
  "strongholdUpgrades",
  "maps",
  "captureSites",
  "chapters",
  "nodes",
  "missionTypes",
  "rewards",
  "optionalObjectives",
  "modifiers",
  "enemyPersonalities",
  "enemyPressurePlans",
  "enemyHeroes",
  "enemyHeroAbilities",
  "enemyDoctrines",
  "eliteSquads",
  "tacticalPlans",
  "battlefieldEvents",
  "act1CampaignSpine",
  "act1FinaleDefinitions",
  "lumeNetworks",
  "retinueRuleReferences"
] as const;

export type PortableContentCategoryId = (typeof PORTABLE_CONTENT_CATEGORY_IDS)[number];
type SerializablePrimitive = string | number | boolean | null;
type SerializableValue = SerializablePrimitive | SerializableValue[] | { [key: string]: SerializableValue };

export interface PortableContentEntry {
  id: string;
  displayName: string;
  sourceFile: string;
  serializedPosture: "stable-id" | "derived-reference" | "rules-reference";
  data: SerializableValue;
}

export interface PortableContentExport {
  schemaVersion: number;
  checkpoint: string;
  authority: "typescript-source";
  runtimeBehavior: "unchanged-downstream-export";
  ordering: "deterministic-by-category-and-id";
  categories: Record<PortableContentCategoryId, PortableContentEntry[]>;
}

export interface StableIdManifestEntry {
  id: string;
  category: PortableContentCategoryId;
  sourceFile: string;
  displayName: string;
  serializedPosture: PortableContentEntry["serializedPosture"];
  referenceCount: number;
  exportHash: string;
}

export interface StableIdManifest {
  schemaVersion: number;
  checkpoint: string;
  authority: "typescript-source";
  entries: StableIdManifestEntry[];
}

export interface ContentExportHashes {
  schemaVersion: number;
  checkpoint: string;
  algorithm: "sha256";
  files: Record<string, string>;
  categories: Record<PortableContentCategoryId, string>;
}

export interface StableIdSnapshot {
  schemaVersion: number;
  checkpoint: string;
  policy: "stable-id-freeze";
  categories: Record<string, string[]>;
}

export interface PortableContentWriteResult {
  outputDir: string;
  contentExport: PortableContentExport;
  stableIdManifest: StableIdManifest;
  hashes: ContentExportHashes;
  fileHashes: Record<string, string>;
  filePaths: Record<string, string>;
}

export interface PortableContentValidationResult {
  ok: boolean;
  errors: string[];
  outputDir?: string;
  snapshotPath?: string;
  manifestEntryCount?: number;
}

const GUARDED_STABLE_ID_CATEGORIES = new Set<PortableContentCategoryId>([
  "factions",
  "heroClasses",
  "abilities",
  "skills",
  "relics",
  "equipment",
  "units",
  "buildings",
  "upgrades",
  "strongholdUpgrades",
  "maps",
  "captureSites",
  "nodes",
  "modifiers",
  "enemyDoctrines",
  "eliteSquads",
  "tacticalPlans",
  "battlefieldEvents",
  "lumeNetworks"
]);

export function createPortableContentExport(): PortableContentExport {
  const equipmentItems = ITEMS.filter((item) => item.slot !== "relic");
  const relicItems = ITEMS.filter((item) => item.slot === "relic");
  const relicRewardsByItemId = new Map(RELIC_REWARD_DEFINITIONS.map((reward) => [reward.itemId, reward]));

  const categories: Record<PortableContentCategoryId, PortableContentEntry[]> = {
    factions: entries("factions", "src/game/data/factions.ts", FACTIONS),
    resources: entries("resources", "src/game/data/resources.ts", RESOURCE_DEFINITIONS),
    heroClasses: entries("heroClasses", "src/game/data/heroClasses.ts", HERO_CLASSES),
    origins: entries("origins", "src/game/data/origins.ts", ORIGINS),
    abilities: entries("abilities", "src/game/data/abilities.ts", ABILITIES),
    skills: entries("skills", "src/game/data/skillTrees.ts", [...SKILL_TREES, ...SKILL_NODES]),
    relics: entries(
      "relics",
      "src/game/data/items.ts",
      relicItems.map((item) => ({
        ...item,
        relicReward: relicRewardsByItemId.get(item.id) ?? null
      }))
    ),
    equipment: entries("equipment", "src/game/data/items.ts", [
      ...equipmentItems,
      ...ITEM_AFFIXES.map((affix) => ({
        ...affix,
        id: `affix:${affix.id}`,
        portableSourceId: affix.id,
        portableKind: "item_affix"
      }))
    ]),
    units: entries("units", "src/game/data/units.ts", UNITS),
    unitRoles: entries(
      "unitRoles",
      "src/game/data/unitRoles.ts",
      UNIT_ROLE_IDENTITIES.map((role) => ({
        ...role,
        id: role.unitId
      }))
    ),
    buildings: entries("buildings", "src/game/data/buildings.ts", BUILDINGS),
    upgrades: entries("upgrades", "src/game/data/upgrades.ts", UPGRADES),
    strongholdUpgrades: entries("strongholdUpgrades", "src/game/data/strongholdUpgrades.ts", STRONGHOLD_UPGRADES),
    maps: entries("maps", "src/game/data/maps/index.ts", MAPS),
    captureSites: entries(
      "captureSites",
      "src/game/data/maps/index.ts",
      MAPS.flatMap((map) =>
        map.captureSites.map((site) => ({
          ...site,
          mapId: map.id
        }))
      )
    ),
    chapters: entries("chapters", "src/game/data/campaignChapters.ts", CAMPAIGN_CHAPTERS),
    nodes: entries("nodes", "src/game/data/campaignNodes.ts", CAMPAIGN_NODES),
    missionTypes: entries("missionTypes", "src/game/data/missionTypes.ts", CAMPAIGN_MISSION_TYPES),
    rewards: entries("rewards", "src/game/data/rewards.ts", [
      ...REWARD_TABLES,
      ...RELIC_REWARD_DEFINITIONS.map((reward) => ({
        ...reward,
        id: `relic_reward:${reward.id}`,
        portableSourceId: reward.id,
        portableKind: "relic_reward"
      })),
      ...RIVAL_REWARDS.map((reward) => ({
        ...reward,
        id: `rival_reward:${reward.enemyHeroId}`,
        portableSourceId: reward.enemyHeroId,
        portableKind: "rival_reward"
      }))
    ]),
    optionalObjectives: entries(
      "optionalObjectives",
      "src/game/data/maps/index.ts",
      MAPS.flatMap((map) =>
        (map.scenario.objectives.secondaryObjectives ?? []).map((objective) => ({
          ...objective,
          mapId: map.id
        }))
      )
    ),
    modifiers: entries("modifiers", "src/game/data/campaignModifiers.ts", CAMPAIGN_MODIFIERS),
    enemyPersonalities: entries("enemyPersonalities", "src/game/data/aiPersonalities.ts", ENEMY_PERSONALITIES_EXPORT),
    enemyPressurePlans: entries("enemyPressurePlans", "src/game/data/enemyPressurePlans.ts", ENEMY_PRESSURE_PLANS),
    enemyHeroes: entries("enemyHeroes", "src/game/data/enemyHeroes.ts", ENEMY_HEROES),
    enemyHeroAbilities: entries("enemyHeroAbilities", "src/game/data/enemyHeroes.ts", ENEMY_HERO_ABILITIES),
    enemyDoctrines: entries("enemyDoctrines", "src/game/data/enemyDoctrines.ts", ENEMY_DOCTRINES),
    eliteSquads: entries("eliteSquads", "src/game/data/enemyDoctrines.ts", ENEMY_ELITE_SQUADS),
    tacticalPlans: entries("tacticalPlans", "src/game/data/tacticalPlans.ts", TACTICAL_PLANS),
    battlefieldEvents: entries("battlefieldEvents", "src/game/data/battlefieldEvents.ts", BATTLEFIELD_EVENTS),
    act1CampaignSpine: entries("act1CampaignSpine", "src/game/data/act1CampaignSpine.ts", ACT1_CAMPAIGN_SPINE),
    act1FinaleDefinitions: entries("act1FinaleDefinitions", "src/game/data/act1Finale.ts", [
      {
        id: "act1_finale",
        name: "Act 1 Finale",
        nodeId: ACT1_FINALE_NODE_ID,
        mapId: ACT1_FINALE_MAP_ID,
        commanderId: ACT1_FINALE_COMMANDER_ID,
        phases: ACT1_FINALE_PHASES
      },
      ...ACT1_FINALE_PHASES.map((phase) => ({
        ...phase,
        id: `act1_finale_phase:${phase.id}`,
        portableSourceId: phase.id,
        portableKind: "act1_finale_phase"
      }))
    ]),
    lumeNetworks: entries("lumeNetworks", "src/game/data/lumeNetworks.ts", LUME_NETWORKS),
    retinueRuleReferences: entries("retinueRuleReferences", "src/game/core/RetinueRules.ts", [
      {
        id: "retinue_rules",
        name: "Retinue Rules",
        eligibleUnitTypeIds: [...RETINUE_ELIGIBLE_UNIT_TYPE_IDS],
        rosterCapacity: RETINUE_ROSTER_CAPACITY,
        baseDeploymentCapacity: RETINUE_BASE_DEPLOYMENT_CAPACITY,
        trainingYardIiDeploymentBonus: RETINUE_TRAINING_YARD_II_DEPLOYMENT_BONUS,
        recoveryHpRatioThreshold: RETINUE_RECOVERY_HP_RATIO_THRESHOLD,
        recoveryMissionSteps: RETINUE_RECOVERY_MISSION_STEPS,
        unitVeterancyRanks: UNIT_VETERANCY_RANKS,
        unitVeterancyXpRules: UNIT_VETERANCY_XP_RULES
      }
    ])
  };

  return stableObject({
    schemaVersion: PORTABLE_CONTENT_SCHEMA_VERSION,
    checkpoint: PORTABLE_CONTENT_CHECKPOINT,
    authority: "typescript-source",
    runtimeBehavior: "unchanged-downstream-export",
    ordering: "deterministic-by-category-and-id",
    categories: stableCategoryRecord(categories)
  }) as PortableContentExport;
}

export function createStableIdManifest(contentExport: PortableContentExport): StableIdManifest {
  const referenceCounts = getReferenceCounts(contentExport);
  const entries = PORTABLE_CONTENT_CATEGORY_IDS.flatMap((category) =>
    contentExport.categories[category].map((entry) => ({
      id: entry.id,
      category,
      sourceFile: entry.sourceFile,
      displayName: entry.displayName,
      serializedPosture: entry.serializedPosture,
      referenceCount: referenceCounts.get(entry.id) ?? 0,
      exportHash: sha256(stableStringify(entry.data))
    }))
  ).sort(compareManifestEntries);

  return stableObject({
    schemaVersion: PORTABLE_CONTENT_SCHEMA_VERSION,
    checkpoint: PORTABLE_CONTENT_CHECKPOINT,
    authority: "typescript-source",
    entries
  }) as StableIdManifest;
}

export function createStableIdSnapshot(contentExport: PortableContentExport): StableIdSnapshot {
  return stableObject({
    schemaVersion: PORTABLE_CONTENT_SCHEMA_VERSION,
    checkpoint: PORTABLE_CONTENT_CHECKPOINT,
    policy: "stable-id-freeze",
    categories: Object.fromEntries(
      PORTABLE_CONTENT_CATEGORY_IDS.map((category) => [
        category,
        contentExport.categories[category].map((entry) => entry.id)
      ])
    )
  }) as StableIdSnapshot;
}

export function validatePortableContentExport(
  contentExport: PortableContentExport,
  snapshot?: StableIdSnapshot
): string[] {
  const errors: string[] = [];
  errors.push(...validateContent());
  validateExportShape(contentExport, errors);
  validateReferences(contentExport, errors);
  if (snapshot) {
    validateStableIdSnapshot(contentExport, snapshot, errors);
  }
  return errors;
}

export async function writePortableContentExport(
  outputDir = DEFAULT_PORTABLE_CONTENT_OUT_DIR
): Promise<PortableContentWriteResult> {
  const contentExport = createPortableContentExport();
  const stableIdManifest = createStableIdManifest(contentExport);
  const summary = createSummaryMarkdown(contentExport, stableIdManifest);
  const categoryHashes = Object.fromEntries(
    PORTABLE_CONTENT_CATEGORY_IDS.map((category) => [
      category,
      sha256(stableStringify(contentExport.categories[category]))
    ])
  ) as Record<PortableContentCategoryId, string>;

  const files: Record<string, string> = {
    "content-export.json": stableStringify(contentExport),
    "stable-id-manifest.json": stableStringify(stableIdManifest),
    "content-export-summary.md": summary
  };
  const fileHashes = Object.fromEntries(Object.entries(files).map(([fileName, contents]) => [fileName, sha256(contents)]));
  const hashes: ContentExportHashes = stableObject({
    schemaVersion: PORTABLE_CONTENT_SCHEMA_VERSION,
    checkpoint: PORTABLE_CONTENT_CHECKPOINT,
    algorithm: "sha256",
    files: fileHashes,
    categories: categoryHashes
  }) as ContentExportHashes;
  files["content-export-hashes.json"] = stableStringify(hashes);
  fileHashes["content-export-hashes.json"] = sha256(files["content-export-hashes.json"]);

  await mkdir(outputDir, { recursive: true });
  await Promise.all(Object.entries(files).map(([fileName, contents]) => writeFile(join(outputDir, fileName), contents, "utf8")));

  return {
    outputDir,
    contentExport,
    stableIdManifest,
    hashes,
    fileHashes,
    filePaths: Object.fromEntries(Object.keys(files).map((fileName) => [fileName, join(outputDir, fileName)]))
  };
}

export async function validatePortableContentArtifacts(options: {
  outputDir?: string;
  snapshotPath?: string;
} = {}): Promise<PortableContentValidationResult> {
  const outputDir = options.outputDir ?? DEFAULT_PORTABLE_CONTENT_OUT_DIR;
  const snapshotPath = options.snapshotPath ?? DEFAULT_STABLE_ID_SNAPSHOT_PATH;
  const snapshot = await readStableIdSnapshot(snapshotPath);
  const first = await writePortableContentExport(outputDir);
  const errors = validatePortableContentExport(first.contentExport, snapshot);
  const secondDir = join(tmpdir(), `ascendant-realms-portable-content-${process.pid}`);
  await rm(secondDir, { force: true, recursive: true });
  const second = await writePortableContentExport(secondDir);
  const names = ["content-export.json", "stable-id-manifest.json", "content-export-summary.md", "content-export-hashes.json"];

  await Promise.all(
    names.map(async (fileName) => {
      const left = await readFile(join(outputDir, fileName), "utf8");
      const right = await readFile(join(secondDir, fileName), "utf8");
      if (left !== right) {
        errors.push(`Portable content export is nondeterministic for ${fileName}.`);
      }
    })
  );
  await rm(secondDir, { force: true, recursive: true });

  return {
    ok: errors.length === 0,
    errors,
    outputDir,
    snapshotPath,
    manifestEntryCount: second.stableIdManifest.entries.length
  };
}

export async function writeStableIdSnapshot(path = DEFAULT_STABLE_ID_SNAPSHOT_PATH): Promise<StableIdSnapshot> {
  const snapshot = createStableIdSnapshot(createPortableContentExport());
  await writeFile(path, stableStringify(snapshot), "utf8");
  return snapshot;
}

export async function readStableIdSnapshot(path = DEFAULT_STABLE_ID_SNAPSHOT_PATH): Promise<StableIdSnapshot> {
  const raw = await readFile(path, "utf8");
  return JSON.parse(raw) as StableIdSnapshot;
}

export function stableStringify(value: unknown): string {
  return `${JSON.stringify(stableObject(value), null, 2)}\n`;
}

export function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function entries<T extends { id: string }>(
  category: PortableContentCategoryId,
  sourceFile: string,
  definitions: readonly T[]
): PortableContentEntry[] {
  return definitions
    .map((definition) => {
      const data = stableObject(definition) as SerializableValue;
      const displayName = getDisplayName(definition);
      const serializedPosture: PortableContentEntry["serializedPosture"] = GUARDED_STABLE_ID_CATEGORIES.has(category)
        ? "stable-id"
        : "derived-reference";
      return {
        id: definition.id,
        displayName,
        sourceFile,
        serializedPosture,
        data
      };
    })
    .sort((left, right) => left.id.localeCompare(right.id));
}

function getDisplayName(value: Record<string, unknown>): string {
  const display = value.name ?? value.title ?? value.label ?? value.shortLabel ?? value.displayName ?? value.id;
  return String(display);
}

function stableCategoryRecord(
  categories: Record<PortableContentCategoryId, PortableContentEntry[]>
): Record<PortableContentCategoryId, PortableContentEntry[]> {
  return Object.fromEntries(PORTABLE_CONTENT_CATEGORY_IDS.map((category) => [category, categories[category]])) as Record<
    PortableContentCategoryId,
    PortableContentEntry[]
  >;
}

function stableObject(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(stableObject);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .filter(([, entryValue]) => entryValue !== undefined)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, entryValue]) => [key, stableObject(entryValue)])
    );
  }
  return value;
}

function getReferenceCounts(contentExport: PortableContentExport): Map<string, number> {
  const ids = new Set(
    PORTABLE_CONTENT_CATEGORY_IDS.flatMap((category) => contentExport.categories[category].map((entry) => entry.id))
  );
  const counts = new Map<string, number>();
  walk(contentExport.categories, (_path, value) => {
    if (typeof value === "string" && ids.has(value)) {
      counts.set(value, (counts.get(value) ?? 0) + 1);
    }
  });
  return counts;
}

function validateExportShape(contentExport: PortableContentExport, errors: string[]): void {
  if (contentExport.schemaVersion !== PORTABLE_CONTENT_SCHEMA_VERSION) {
    errors.push(`Portable content schema version mismatch: ${contentExport.schemaVersion}.`);
  }
  PORTABLE_CONTENT_CATEGORY_IDS.forEach((category) => {
    const entriesForCategory = contentExport.categories[category];
    if (!Array.isArray(entriesForCategory)) {
      errors.push(`Portable content export is missing category ${category}.`);
      return;
    }
    if (entriesForCategory.length === 0) {
      errors.push(`Portable content export category ${category} is empty.`);
      return;
    }
    const ids = new Set<string>();
    const sortedIds = [...entriesForCategory.map((entry) => entry.id)].sort();
    if (entriesForCategory.map((entry) => entry.id).join("\n") !== sortedIds.join("\n")) {
      errors.push(`Portable content export category ${category} is not sorted by id.`);
    }
    entriesForCategory.forEach((entry) => {
      if (ids.has(entry.id)) {
        errors.push(`Duplicate portable content id in ${category}: ${entry.id}`);
      }
      ids.add(entry.id);
      validatePortableId(entry.id, `${category}:${entry.id}`, errors);
      if (entry.displayName === entry.id && entry.displayName.includes(" ")) {
        errors.push(`Portable content ${category}:${entry.id} appears to use display copy as an id.`);
      }
      if (!entry.sourceFile.startsWith("src/game/")) {
        errors.push(`Portable content ${category}:${entry.id} has non-source file path ${entry.sourceFile}.`);
      }
      if (stableStringify(entry.data) !== stableStringify(JSON.parse(stableStringify(entry.data)))) {
        errors.push(`Portable content ${category}:${entry.id} is not serializable.`);
      }
    });
  });
}

function validatePortableId(id: string, label: string, errors: string[]): void {
  if (!id.trim()) {
    errors.push(`Portable content ${label} has an empty id.`);
  }
  if (!/^[a-z][a-z0-9_:-]*$/u.test(id)) {
    errors.push(`Portable content ${label} has a non-portable id.`);
  }
}

function validateReferences(contentExport: PortableContentExport, errors: string[]): void {
  const idSets = createIdSets(contentExport);
  PORTABLE_CONTENT_CATEGORY_IDS.forEach((category) => {
    contentExport.categories[category].forEach((entry) => {
      walk(entry.data, (path, value, parent) => {
        if (typeof value !== "string") {
          return;
        }
        const lastSegment = path[path.length - 1] ?? "";
        const key = /^\d+$/u.test(lastSegment) ? path[path.length - 2] ?? lastSegment : lastSegment;
        const allowedCategories = referenceCategoriesForKey(key, parent);
        if (!allowedCategories) {
          return;
        }
        if (key === "abilityIds" && value === "all") {
          return;
        }
        const known = allowedCategories.some((allowedCategory) => idSets[allowedCategory]?.has(value));
        if (!known) {
          errors.push(
            `Portable content ${category}:${entry.id} references unknown ${allowedCategories.join("|")} id ${value} at ${path.join(".")}.`
          );
        }
      });
    });
  });
}

function createIdSets(contentExport: PortableContentExport): Record<string, Set<string>> {
  return Object.fromEntries(
    PORTABLE_CONTENT_CATEGORY_IDS.map((category) => [category, new Set(contentExport.categories[category].map((entry) => entry.id))])
  );
}

function referenceCategoriesForKey(key: string, parent: unknown): PortableContentCategoryId[] | undefined {
  if (key === "unitId" || key === "sourceUnitId" || key === "unitTypeId") return ["units"];
  if (key === "unitIds" || key === "eligibleUnitIds" || key === "eligibleUnitTypeIds" || key === "availableUnitIds" || key === "extraPlayerUnitIds" || key === "extraEnemyUnitIds" || key === "preferredUnitIds" || key === "unitPlan" || key === "trainUnitIds" || key === "allowedAttackUnitIds" || key === "preferredAttackUnitIds") return ["units"];
  if (key === "buildingId" || key === "ownerBuildingId" || key === "playerBaseBuildingId" || key === "enemyBaseBuildingId" || key === "baseBuildingId" || key === "productionBuildingId" || key === "attackTargetBuildingId") return ["buildings"];
  if (key === "buildingIds" || key === "availableBuildingIds" || key === "buildOptions") return ["buildings"];
  if (key === "trainOptions") return ["units"];
  if (key === "abilityId" || key === "primaryAbilityId" || key === "unlockAbilityId") return ["abilities"];
  if (key === "abilityIds") return ["abilities"];
  if (key === "heroClassId" || key === "classId") return ["heroClasses"];
  if (key === "classAffinity") return ["heroClasses"];
  if (key === "itemId" || key === "stockItemId") return ["equipment", "relics"];
  if (key === "itemIds" || key === "guaranteedItemIds" || key === "deterministicItemIds") return ["equipment", "relics"];
  if (key === "upgradeId" || key === "upgradeIds" || key === "availableUpgradeIds" || key === "upgradeOptions") return ["upgrades", "strongholdUpgrades"];
  if (key === "chapterId" || key === "chapterIds") return ["chapters"];
  if (key === "nodeId" || key === "campaignNodeId" || key === "actNodeId") return ["nodes"];
  if (key === "nodeIds" || key === "supportNodeIds" || key === "unlockNodeIds" || key === "lockNodeIds" || key === "completedNodeIds" || key === "campaignNodeIds" || key === "unlockPrerequisiteNodeIds" || key === "prerequisites" || key === "unlocks") return ["nodes"];
  if (key === "mapId" || key === "mapIds") return ["maps"];
  if (key === "rewardTableId") return ["rewards"];
  if (key === "modifierId" || key === "modifierIds" || key === "removeModifierIds" || key === "preferredModifierIds") return ["modifiers"];
  if (key === "enemyHeroId" || key === "sourceEnemyHeroId" || key === "commanderId") return ["enemyHeroes"];
  if (key === "personalityId" || key === "aiPersonalityId") return ["enemyPersonalities"];
  if (key === "enemyPressurePlanId") return ["enemyPressurePlans"];
  if (key === "eligibleDoctrineIds" || key === "recommendedDoctrineIds") return ["enemyDoctrines"];
  if (key === "preferredEventIds" || key === "eventIds") return ["battlefieldEvents"];
  if (key === "recommendedPlanId" || key === "recommendedTacticalPlanIds") return ["tacticalPlans"];
  if (key === "fromSiteId" || key === "toSiteId" || key === "siteId" || key === "eligibleSiteIds") return ["captureSites"];
  if (key === "targetId" && isObjectiveParent(parent)) return objectiveTargetCategories(parent);
  if (key === "factionId" || key === "enemyFactionId" || key === "factionOrigin") return ["factions"];
  if (key === "resource") return ["resources"];
  return undefined;
}

function isObjectiveParent(parent: unknown): parent is { type?: string } {
  return Boolean(parent && typeof parent === "object" && "type" in parent);
}

function objectiveTargetCategories(parent: { type?: string }): PortableContentCategoryId[] {
  if (parent.type === "capture_site") return ["captureSites"];
  if (parent.type === "destroy_building") return ["buildings"];
  if (parent.type === "defeat_unit") return ["units"];
  return ["captureSites", "buildings", "units"];
}

function validateStableIdSnapshot(
  contentExport: PortableContentExport,
  snapshot: StableIdSnapshot,
  errors: string[]
): void {
  const current = createStableIdSnapshot(contentExport);
  PORTABLE_CONTENT_CATEGORY_IDS.forEach((category) => {
    const currentIds = current.categories[category] ?? [];
    const frozenIds = snapshot.categories[category] ?? [];
    if (currentIds.join("\n") !== frozenIds.join("\n")) {
      errors.push(
        `Stable ID snapshot mismatch for ${category}. Current ids: ${currentIds.join(", ")}. Frozen ids: ${frozenIds.join(", ")}.`
      );
    }
  });
}

function walk(value: unknown, visit: (path: string[], value: unknown, parent: unknown) => void, path: string[] = [], parent?: unknown): void {
  visit(path, value, parent);
  if (Array.isArray(value)) {
    value.forEach((entry, index) => walk(entry, visit, [...path, String(index)], value));
    return;
  }
  if (value && typeof value === "object") {
    Object.entries(value as Record<string, unknown>).forEach(([key, entryValue]) => {
      if (Array.isArray(entryValue)) {
        entryValue.forEach((arrayValue, index) => walk(arrayValue, visit, [...path, key, String(index)], value));
        return;
      }
      walk(entryValue, visit, [...path, key], value);
    });
  }
}

function createSummaryMarkdown(contentExport: PortableContentExport, manifest: StableIdManifest): string {
  const lines = [
    "# Portable Content Export Summary",
    "",
    `Checkpoint: ${PORTABLE_CONTENT_CHECKPOINT}`,
    "Authority: TypeScript source definitions remain authoritative.",
    "Runtime behavior: unchanged; this export is downstream-only for later engine experiments.",
    "",
    "| Category | Entries | Hash |",
    "| --- | ---: | --- |"
  ];
  PORTABLE_CONTENT_CATEGORY_IDS.forEach((category) => {
    lines.push(
      `| ${category} | ${contentExport.categories[category].length} | ${sha256(stableStringify(contentExport.categories[category]))} |`
    );
  });
  lines.push("", `Stable manifest entries: ${manifest.entries.length}.`, "");
  return `${lines.join("\n")}\n`;
}

function compareManifestEntries(left: StableIdManifestEntry, right: StableIdManifestEntry): number {
  const category = left.category.localeCompare(right.category);
  return category || left.id.localeCompare(right.id);
}
