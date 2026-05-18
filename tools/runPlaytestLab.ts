import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import {
  renderBalanceRegressionDashboardMarkdown,
  renderExtendedScenarioLabMarkdownReport,
  renderExtendedWatchpointsMarkdown,
  renderProfileComparisonCsv,
  renderProfileComparisonMarkdown,
  renderScenarioLabMarkdownReport,
  renderWatchpointSummaryMarkdown,
  runExtendedScenarioLab,
  runScenarioLab
} from "../src/game/playtest/ScriptedBattlePlaytest";

interface LabCliOptions {
  extended: boolean;
  watchpointsOnly: boolean;
  runs?: number;
  seed?: string;
  output?: string;
  writeJson: boolean;
  writeMarkdown: boolean;
}

const options = parseArgs(process.argv.slice(2));

if (options.extended) {
  const report = runExtendedScenarioLab({
    iterations: options.runs,
    seed: options.seed,
    buildCommit: readGitCommit()
  });
  const paths = extendedPaths(options.output);
  if (!options.watchpointsOnly) {
    if (options.writeJson) {
      await writeFile(paths.json, `${JSON.stringify(report, null, 2)}\n`, "utf-8");
      await writeFile(paths.dashboardJson, `${JSON.stringify(report.dashboard, null, 2)}\n`, "utf-8");
      console.log(`Wrote ${paths.json}`);
      console.log(`Wrote ${paths.dashboardJson}`);
    }
    if (options.writeMarkdown) {
      await writeFile(paths.markdown, renderExtendedScenarioLabMarkdownReport(report), "utf-8");
      await writeFile(paths.profileComparisonMarkdown, renderProfileComparisonMarkdown(report), "utf-8");
      await writeFile(paths.profileComparisonCsv, renderProfileComparisonCsv(report), "utf-8");
      await writeFile(paths.dashboardMarkdown, renderBalanceRegressionDashboardMarkdown(report), "utf-8");
      console.log(`Wrote ${paths.markdown}`);
      console.log(`Wrote ${paths.profileComparisonMarkdown}`);
      console.log(`Wrote ${paths.profileComparisonCsv}`);
      console.log(`Wrote ${paths.dashboardMarkdown}`);
    }
  }
  if (options.writeMarkdown) {
    await writeFile(paths.watchpointsMarkdown, renderExtendedWatchpointsMarkdown(report), "utf-8");
    console.log(`Wrote ${paths.watchpointsMarkdown}`);
  }
  console.log(`Extended scenario lab iterations: ${report.iterationCount}`);
  console.log(`Source simulator runs: ${report.totalSourceRuns}`);
  console.log(`Derived profile-run metrics: ${report.totalDerivedMetrics}`);
  console.log(`Watchpoints classified: ${report.watchpointRegressions.length}`);
} else {
  const report = runScenarioLab();

  const jsonPath = resolve(options.output ? `${options.output}.json` : "PLAYTEST_SCENARIO_LAB.json");
  const markdownPath = resolve(options.output ? `${options.output}.md` : "PLAYTEST_SCENARIO_LAB.md");
  const watchpointPath = resolve(options.output ? `${options.output}_WATCHPOINTS.md` : "PLAYTEST_WATCHPOINT_SUMMARY.md");

  if (options.writeJson && !options.watchpointsOnly) {
    await writeFile(jsonPath, `${JSON.stringify(report, null, 2)}\n`, "utf-8");
    console.log(`Wrote ${jsonPath}`);
  }
  if (options.writeMarkdown && !options.watchpointsOnly) {
    await writeFile(markdownPath, renderScenarioLabMarkdownReport(report), "utf-8");
    console.log(`Wrote ${markdownPath}`);
  }
  if (options.writeMarkdown) {
    await writeFile(watchpointPath, renderWatchpointSummaryMarkdown(report), "utf-8");
    console.log(`Wrote ${watchpointPath}`);
  }

  console.log(`Scenario lab profiles: ${report.profiles.length}`);
  console.log(`Derived profile-run metrics: ${report.runMetrics.length}`);
  console.log(`Watchpoints classified: ${report.watchpoints.length}`);
}

function parseArgs(args: string[]): LabCliOptions {
  return {
    extended: args.includes("--extended"),
    watchpointsOnly: args.includes("--watchpoints-only"),
    runs: numericOption(args, "--runs"),
    seed: stringOption(args, "--seed"),
    output: stringOption(args, "--output"),
    writeJson: !hasFalseFlag(args, "--json"),
    writeMarkdown: !hasFalseFlag(args, "--markdown")
  };
}

function extendedPaths(outputPrefix: string | undefined) {
  const prefix = outputPrefix?.trim();
  return {
    json: resolve(prefix ? `${prefix}.json` : "PLAYTEST_SCENARIO_LAB_EXTENDED.json"),
    markdown: resolve(prefix ? `${prefix}.md` : "PLAYTEST_SCENARIO_LAB_EXTENDED.md"),
    watchpointsMarkdown: resolve(prefix ? `${prefix}_WATCHPOINTS.md` : "PLAYTEST_WATCHPOINTS_EXTENDED.md"),
    profileComparisonMarkdown: resolve(prefix ? `${prefix}_PROFILE_COMPARISON.md` : "PLAYTEST_PROFILE_COMPARISON.md"),
    profileComparisonCsv: resolve(prefix ? `${prefix}_PROFILE_COMPARISON.csv` : "PLAYTEST_PROFILE_COMPARISON.csv"),
    dashboardMarkdown: resolve(prefix ? `${prefix}_DASHBOARD.md` : "PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md"),
    dashboardJson: resolve(prefix ? `${prefix}_DASHBOARD.json` : "PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json")
  };
}

function numericOption(args: string[], name: string): number | undefined {
  const value = stringOption(args, name);
  if (!value) {
    return undefined;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
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
