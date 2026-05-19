import { CONTROL_BEHAVIOUR_SCENARIO_PROFILES } from "./ControlBehaviourScenarioProfiles";
import {
  CONTROL_BEHAVIOUR_CONFIDENCE_LEVELS,
  CONTROL_BEHAVIOUR_VERDICTS,
  type ControlBehaviourDashboard,
  type ControlBehaviourMetricKey,
  type ControlBehaviourScenarioMetrics,
  type ControlBehaviourScenarioReport
} from "./ControlBehaviourScenarioTypes";

export interface ControlBehaviourLabOutputArtifacts {
  normalJson: string;
  normalMarkdown: string;
  extendedJson: string;
  extendedMarkdown: string;
  dashboardJson: string;
  dashboardMarkdown: string;
}

export interface ControlBehaviourLabOutputValidationOptions {
  expectedExtendedIterationCount?: number;
}

export interface ControlBehaviourLabOutputValidationResult {
  ok: boolean;
  checks: string[];
  errors: string[];
}

const FORBIDDEN_HUMAN_CLAIMS = [
  "tester said",
  "human feedback confirmed",
  "human feedback was used",
  "human feedback used: yes",
  "players confirmed"
];

export function validateControlBehaviourLabOutputs(
  artifacts: ControlBehaviourLabOutputArtifacts,
  options: ControlBehaviourLabOutputValidationOptions = {}
): ControlBehaviourLabOutputValidationResult {
  const checks: string[] = [];
  const errors: string[] = [];
  const expectedExtendedIterationCount = options.expectedExtendedIterationCount ?? 5;
  const normal = parseJson<ControlBehaviourScenarioReport>(artifacts.normalJson, "PLAYTEST_CONTROL_BEHAVIOUR_LAB.json", errors);
  const extended = parseJson<ControlBehaviourScenarioReport>(
    artifacts.extendedJson,
    "PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json",
    errors
  );
  const dashboard = parseJson<ControlBehaviourDashboard>(
    artifacts.dashboardJson,
    "PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json",
    errors
  );

  if (!normal || !extended || !dashboard) {
    return { ok: false, checks, errors };
  }

  expectEqual(normal.schemaVersion, 1, "normal schema version", checks, errors);
  expectEqual(extended.schemaVersion, 1, "extended schema version", checks, errors);
  expectEqual(dashboard.schemaVersion, 1, "dashboard schema version", checks, errors);
  expectEqual(normal.runMode, "normal", "normal run mode", checks, errors);
  expectEqual(extended.runMode, "extended", "extended run mode", checks, errors);
  expectEqual(normal.iterationCount, 1, "normal iteration count", checks, errors);
  expectEqual(extended.iterationCount, expectedExtendedIterationCount, "extended iteration count", checks, errors);
  expectEqual(normal.scenarioCount, CONTROL_BEHAVIOUR_SCENARIO_PROFILES.length, "normal scenario count", checks, errors);
  expectEqual(extended.scenarioCount, CONTROL_BEHAVIOUR_SCENARIO_PROFILES.length, "extended scenario count", checks, errors);
  expectEqual(
    extended.results.length,
    extended.scenarioCount * extended.iterationCount,
    "extended result row count",
    checks,
    errors
  );

  expectUnique(normal.results.map((entry) => entry.scenarioId), "normal scenario ids", checks, errors);
  for (let iteration = 1; iteration <= extended.iterationCount; iteration += 1) {
    expectUnique(
      extended.results.filter((entry) => entry.iteration === iteration).map((entry) => entry.scenarioId),
      `extended scenario ids iteration ${iteration}`,
      checks,
      errors
    );
  }

  CONTROL_BEHAVIOUR_SCENARIO_PROFILES.forEach((profile) => {
    const normalResult = normal.results.find((entry) => entry.scenarioId === profile.id);
    if (!normalResult) {
      errors.push(`Missing normal scenario ${profile.id}.`);
      return;
    }
    expectEqual(normalResult.scenarioName, profile.name, `profile name stable: ${profile.id}`, checks, errors);
  });

  [...normal.results, ...extended.results].forEach((entry) => {
    if (CONTROL_BEHAVIOUR_VERDICTS.includes(entry.result)) {
      checks.push(`verdict allowed: ${entry.scenarioId} ${entry.result}`);
    } else {
      errors.push(`Invalid verdict for ${entry.scenarioId}: ${entry.result}.`);
    }
    if (CONTROL_BEHAVIOUR_CONFIDENCE_LEVELS.includes(entry.confidence)) {
      checks.push(`confidence allowed: ${entry.scenarioId} ${entry.confidence}`);
    } else {
      errors.push(`Invalid confidence for ${entry.scenarioId}: ${entry.confidence}.`);
    }
    validateMetrics(entry.scenarioId, entry.metrics, entry.unavailableMetrics, checks, errors);
  });

  const expectedRanking = dashboard.ranking.map((entry) => entry.scenarioName);
  expectArrayEqual(parseDashboardMarkdownRanking(artifacts.dashboardMarkdown), expectedRanking, "dashboard markdown ranking order", checks, errors);
  expectMarkdownContains(artifacts.normalMarkdown, `Iterations: ${normal.iterationCount}`, "normal markdown iteration count", checks, errors);
  expectMarkdownContains(
    artifacts.extendedMarkdown,
    `Iterations: ${extended.iterationCount}`,
    "extended markdown iteration count",
    checks,
    errors
  );

  Object.entries(artifacts).forEach(([name, content]) => {
    const lower = content.toLowerCase();
    FORBIDDEN_HUMAN_CLAIMS.forEach((phrase) => {
      if (lower.includes(phrase)) {
        errors.push(`${name} contains forbidden human-feedback claim phrase: ${phrase}.`);
      }
    });
  });
  checks.push("generated control outputs avoid forbidden human-feedback claims");

  return { ok: errors.length === 0, checks, errors };
}

export function assertControlBehaviourLabOutputs(
  artifacts: ControlBehaviourLabOutputArtifacts,
  options: ControlBehaviourLabOutputValidationOptions = {}
): ControlBehaviourLabOutputValidationResult {
  const result = validateControlBehaviourLabOutputs(artifacts, options);
  if (!result.ok) {
    throw new Error(`Control behaviour lab output validation failed:\n${result.errors.map((error) => `- ${error}`).join("\n")}`);
  }
  return result;
}

function validateMetrics(
  scenarioId: string,
  metrics: ControlBehaviourScenarioMetrics,
  unavailableMetrics: ControlBehaviourMetricKey[],
  checks: string[],
  errors: string[]
): void {
  (Object.keys(metrics) as ControlBehaviourMetricKey[]).forEach((key) => {
    const value = metrics[key];
    if (value === null) {
      if (unavailableMetrics.includes(key)) {
        checks.push(`metric explicitly unavailable: ${scenarioId} ${key}`);
      } else {
        errors.push(`Metric ${key} is null for ${scenarioId} but is not marked unavailable.`);
      }
      return;
    }
    if (typeof value === "number" && Number.isNaN(value)) {
      errors.push(`Metric ${key} is NaN for ${scenarioId}.`);
      return;
    }
    checks.push(`metric present: ${scenarioId} ${key}`);
  });
}

function parseJson<T>(content: string, label: string, errors: string[]): T | null {
  try {
    return JSON.parse(content) as T;
  } catch (error) {
    errors.push(`${label} is not valid JSON: ${String(error)}.`);
    return null;
  }
}

function expectEqual<T>(actual: T, expected: T, label: string, checks: string[], errors: string[]): void {
  if (Object.is(actual, expected)) {
    checks.push(`${label}: ${String(actual)}`);
  } else {
    errors.push(`${label} mismatch: expected ${String(expected)}, got ${String(actual)}.`);
  }
}

function expectUnique(values: string[], label: string, checks: string[], errors: string[]): void {
  const unique = new Set(values);
  if (unique.size === values.length) {
    checks.push(`${label} unique`);
  } else {
    errors.push(`${label} contains duplicates.`);
  }
}

function expectArrayEqual(actual: string[], expected: string[], label: string, checks: string[], errors: string[]): void {
  const same = actual.length === expected.length && actual.every((value, index) => value === expected[index]);
  if (same) {
    checks.push(label);
  } else {
    errors.push(`${label} mismatch: expected [${expected.join(", ")}], got [${actual.join(", ")}].`);
  }
}

function expectMarkdownContains(markdown: string, text: string, label: string, checks: string[], errors: string[]): void {
  if (markdown.includes(text)) {
    checks.push(label);
  } else {
    errors.push(`${label} missing expected text: ${text}`);
  }
}

function parseDashboardMarkdownRanking(markdown: string): string[] {
  const lines = markdown.split(/\r?\n/u);
  const start = lines.findIndex((line) => line.trim() === "## Scenario Ranking");
  if (start < 0) {
    return [];
  }
  const rows: string[] = [];
  for (let index = start + 1; index < lines.length; index += 1) {
    const line = lines[index].trim();
    if (!line) {
      if (rows.length > 0) {
        break;
      }
      continue;
    }
    if (!line.startsWith("|") || line.includes("---") || line.includes("| Rank |")) {
      continue;
    }
    const cells = line
      .slice(1, -1)
      .split("|")
      .map((cell) => cell.trim());
    rows.push(cells[1]);
  }
  return rows;
}
