import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { expect } from "vitest";
import { migrateSaveToCurrent, parseSaveJson } from "../../../src/game/save/SaveSystem";
import type { CurrentStoredGameSave } from "../../../src/game/save/SaveTypes";

type ResourceExpectation = Partial<Record<"crowns" | "stone" | "iron" | "aether", number>>;

const fixtureDirectory = fileURLToPath(new URL(".", import.meta.url));

export function saveFixturePath(filename: string): string {
  if (path.isAbsolute(filename) || filename.includes("/") || filename.includes("\\") || filename.includes("..")) {
    throw new Error(`Save fixture filename must be a plain filename: ${filename}`);
  }
  return path.join(fixtureDirectory, filename);
}

export function loadSaveFixtureText(filename: string): string {
  return fs.readFileSync(saveFixturePath(filename), "utf8");
}

export function loadSaveFixtureJson<T = unknown>(filename: string): T {
  return JSON.parse(loadSaveFixtureText(filename)) as T;
}

export function cloneFixture<T>(fixture: T): T {
  return structuredClone(fixture);
}

export function parseSaveFixture(filename: string): CurrentStoredGameSave | null {
  return parseSaveJson(loadSaveFixtureText(filename));
}

export function migrateSaveFixtureToCurrent(filename: string): CurrentStoredGameSave | null {
  return migrateSaveObjectToCurrent(loadSaveFixtureJson(filename));
}

export function migrateSaveObjectToCurrent(input: unknown): CurrentStoredGameSave | null {
  return migrateSaveToCurrent(cloneFixture(input));
}

export function expectNoFixtureCrash<T>(label: string, action: () => T): T {
  try {
    return action();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`${label} crashed: ${message}`);
  }
}

export function expectHeroCore(
  save: CurrentStoredGameSave | null,
  expected: Partial<{
    heroName: string;
    classId: string;
    originId: string;
    level: number;
    xp: number;
    skillPoints: number;
  }>
): asserts save is CurrentStoredGameSave {
  expect(save).not.toBeNull();
  expect(save!.hero).toMatchObject(expected);
}

export function expectCampaignResources(save: CurrentStoredGameSave | null, expected: ResourceExpectation): void {
  expect(save).not.toBeNull();
  expect(save!.campaign.resources).toMatchObject(expected);
}

export function expectCampaignProgress(
  save: CurrentStoredGameSave | null,
  expected: Partial<{
    completedNodeIds: string[];
    unlockedNodeIds: string[];
    nodeRewardsClaimedIds: string[];
    choiceIdsClaimed: string[];
    townServiceClaimedIds: string[];
    selectedChapterId: string;
    selectedNodeId: string;
  }>
): void {
  expect(save).not.toBeNull();
  if (expected.completedNodeIds) {
    expect(save!.campaign.completedNodeIds).toEqual(expect.arrayContaining(expected.completedNodeIds));
  }
  if (expected.unlockedNodeIds) {
    expect(save!.campaign.unlockedNodeIds).toEqual(expect.arrayContaining(expected.unlockedNodeIds));
  }
  if (expected.nodeRewardsClaimedIds) {
    expect(save!.campaign.nodeRewardsClaimedIds).toEqual(expect.arrayContaining(expected.nodeRewardsClaimedIds));
  }
  if (expected.choiceIdsClaimed) {
    expect(save!.campaign.choiceIdsClaimed).toEqual(expect.arrayContaining(expected.choiceIdsClaimed));
  }
  if (expected.townServiceClaimedIds) {
    expect(save!.campaign.townServiceClaimedIds).toEqual(expect.arrayContaining(expected.townServiceClaimedIds));
  }
  if (expected.selectedChapterId) {
    expect(save!.campaign.selectedChapterId).toBe(expected.selectedChapterId);
  }
  if (expected.selectedNodeId) {
    expect(save!.campaign.selectedNodeId).toBe(expected.selectedNodeId);
  }
}

export function expectInventoryInstance(
  save: CurrentStoredGameSave | null,
  instanceId: string,
  expected: Partial<{
    itemId: string;
    source: string;
    affixes: string[];
    locked: boolean;
    favorite: boolean;
  }>
): void {
  expect(save).not.toBeNull();
  const instance = save!.hero.inventory.find((entry) => entry.instanceId === instanceId);
  expect(instance).toMatchObject(expected);
}

export function expectRetinueUnit(
  save: CurrentStoredGameSave | null,
  retinueUnitId: string,
  expected: Partial<{
    unitTypeId: string;
    rank: string;
    xp: number;
    kills: number;
    sourceBattleId: string;
    status: string;
  }>
): void {
  expect(save).not.toBeNull();
  const unit = save!.campaign.retinueUnits.find((entry) => entry.retinueUnitId === retinueUnitId);
  expect(unit).toMatchObject(expected);
}

export function expectRivalState(
  save: CurrentStoredGameSave | null,
  enemyHeroId: string,
  expected: Partial<{
    encounters: number;
    defeats: number;
    victoriesAgainstPlayer: number;
    lastOutcome: string;
    disposition: string;
    isKnownToPlayer: boolean;
  }>
): void {
  expect(save).not.toBeNull();
  const rival = save!.campaign.rivals.find((entry) => entry.enemyHeroId === enemyHeroId);
  expect(rival).toMatchObject(expected);
}

export function expectRivalTrophy(
  save: CurrentStoredGameSave | null,
  trophyId: string,
  expected: Partial<{
    enemyHeroId: string;
    sourceNodeId: string;
    label: string;
    description: string;
    effect: string;
  }>
): void {
  expect(save).not.toBeNull();
  const trophy = save!.campaign.rivalTrophies.find((entry) => entry.trophyId === trophyId);
  expect(trophy).toMatchObject(expected);
}

