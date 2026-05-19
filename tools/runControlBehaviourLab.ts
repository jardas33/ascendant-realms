import { execFileSync } from "node:child_process";
import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import {
  renderControlBehaviourDashboardMarkdown,
  renderControlBehaviourScenarioMarkdownReport,
  runControlBehaviourScenarioLab
} from "../src/game/playtest/ScriptedBattlePlaytest";

interface ControlLabCliOptions {
  extended: boolean;
  runs?: number;
  output?: string;
  writeJson: boolean;
  writeMarkdown: boolean;
}

const options = parseArgs(process.argv.slice(2));
const report = runControlBehaviourScenarioLab({
  iterations: options.extended ? options.runs ?? 5 : 1,
  runMode: options.extended ? "extended" : "normal",
  buildCommit: readGitCommit()
});

const paths = outputPaths(options.output, options.extended);

if (options.writeJson) {
  await writeFile(paths.reportJson, `${JSON.stringify(report, null, 2)}\n`, "utf-8");
  await writeFile(paths.dashboardJson, `${JSON.stringify(report.dashboard, null, 2)}\n`, "utf-8");
  console.log(`Wrote ${paths.reportJson}`);
  console.log(`Wrote ${paths.dashboardJson}`);
}

if (options.writeMarkdown) {
  await writeFile(paths.reportMarkdown, renderControlBehaviourScenarioMarkdownReport(report), "utf-8");
  await writeFile(paths.dashboardMarkdown, renderControlBehaviourDashboardMarkdown(report.dashboard), "utf-8");
  console.log(`Wrote ${paths.reportMarkdown}`);
  console.log(`Wrote ${paths.dashboardMarkdown}`);
}

console.log(`Control behaviour scenarios: ${report.scenarioCount}`);
console.log(`Iterations: ${report.iterationCount}`);
console.log(`Result rows: ${report.results.length}`);
console.log(`Pass rows: ${report.dashboard.passCount}`);
console.log(`Fail rows: ${report.dashboard.failCount}`);

function outputPaths(outputPrefix: string | undefined, extended: boolean) {
  const prefix = outputPrefix?.trim();
  if (prefix) {
    return {
      reportJson: resolve(`${prefix}.json`),
      reportMarkdown: resolve(`${prefix}.md`),
      dashboardJson: resolve(`${prefix}_DASHBOARD.json`),
      dashboardMarkdown: resolve(`${prefix}_DASHBOARD.md`)
    };
  }
  return {
    reportJson: resolve(extended ? "PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json" : "PLAYTEST_CONTROL_BEHAVIOUR_LAB.json"),
    reportMarkdown: resolve(extended ? "PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md" : "PLAYTEST_CONTROL_BEHAVIOUR_LAB.md"),
    dashboardJson: resolve("PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json"),
    dashboardMarkdown: resolve("PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md")
  };
}

function parseArgs(args: string[]): ControlLabCliOptions {
  return {
    extended: args.includes("--extended"),
    runs: numericOption(args, "--runs"),
    output: stringOption(args, "--output"),
    writeJson: !hasFalseFlag(args, "--json"),
    writeMarkdown: !hasFalseFlag(args, "--markdown")
  };
}

function numericOption(args: string[], name: string): number | undefined {
  const value = stringOption(args, name);
  if (!value) {
    return undefined;
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed < 1 || parsed > 25) {
    throw new Error(`${name} must be a number from 1 to 25.`);
  }
  return Math.floor(parsed);
}

function stringOption(args: string[], name: string): string | undefined {
  const equalPrefix = `${name}=`;
  const equalValue = args.find((arg) => arg.startsWith(equalPrefix));
  if (equalValue) {
    return equalValue.slice(equalPrefix.length);
  }
  const index = args.indexOf(name);
  if (index >= 0) {
    return args[index + 1];
  }
  return undefined;
}

function hasFalseFlag(args: string[], name: string): boolean {
  return args.includes(`${name}=false`) || args.includes(`--no-${name.replace(/^--/u, "")}`);
}

function readGitCommit(): string {
  try {
    return execFileSync("git", ["rev-parse", "--short", "HEAD"], { encoding: "utf-8" }).trim();
  } catch {
    return "unavailable";
  }
}
