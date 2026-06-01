import { test, type Page } from "@playwright/test";

export type SemanticCommandAction =
  | "clickTestId"
  | "clickText"
  | "waitForStepText"
  | "selectHero"
  | "selectTroops"
  | "moveHeroToSemanticLocation"
  | "captureSite"
  | "selectBuilding"
  | "buildBarracks"
  | "assignWorkerToSite"
  | "trainMilitia"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "assertNoSavePollution";

export type SemanticCommandTargetType = "testId" | "text" | "tutorialStep" | "battleEntity" | "semanticLocation";

export interface SemanticCommand {
  id: string;
  action: SemanticCommandAction;
  target?: {
    type: SemanticCommandTargetType;
    id: string;
  };
  expected?: {
    title?: string;
    progress?: string;
    text?: string;
    state?: Record<string, unknown>;
  };
  timeoutMs?: number;
  debugLabel?: string;
}

export type SemanticCommandExecutor = (command: SemanticCommand, page: Page) => Promise<unknown>;

export async function runSemanticCommandLog(
  page: Page,
  commands: readonly SemanticCommand[],
  executor: SemanticCommandExecutor
): Promise<Map<string, unknown>> {
  validateSemanticCommands(commands);
  const results = new Map<string, unknown>();

  for (const command of commands) {
    const result = await test.step(command.debugLabel ?? `${command.id}: ${command.action}`, async () => executor(command, page));
    results.set(command.id, result);
  }

  return results;
}

function validateSemanticCommands(commands: readonly SemanticCommand[]): void {
  const ids = new Set<string>();

  for (const command of commands) {
    if (!command.id.trim()) {
      throw new Error("Semantic command is missing a stable id.");
    }
    if (ids.has(command.id)) {
      throw new Error(`Duplicate semantic command id: ${command.id}`);
    }
    ids.add(command.id);
    if (!command.action) {
      throw new Error(`Semantic command ${command.id} is missing an action.`);
    }
  }
}
