import type { ControlBehaviourDashboard, ControlBehaviourScenarioReport } from "./ControlBehaviourScenarioTypes";

export function renderControlBehaviourScenarioMarkdownReport(report: ControlBehaviourScenarioReport): string {
  return `# Playtest Control Behaviour Lab

Generated: ${report.generatedAt}
Build commit: ${report.buildCommit}
Run mode: ${report.runMode}
Iterations: ${report.iterationCount}
Scenarios: ${report.scenarioCount}

## What This Is

This is deterministic automated evidence for v0.15/v0.16 RTS controls. It checks behaviour-mode semantics, explicit order precedence, retreat suppression, melee contact reacquisition, and the contracts covered by browser-level attack cursor and HUD/minimap tests.

## What This Is Not

${report.limitations.map((limitation) => `- ${limitation}`).join("\n")}

## Scenario Results

| Scenario | Mode | Order | Verdict | Confidence | Key Evidence |
| --- | --- | --- | --- | --- | --- |
${report.results
  .map(
    (entry) =>
      `| ${entry.scenarioName} | ${entry.mode} | ${entry.explicitOrderType} | ${entry.result} | ${entry.confidence} | ${entry.evidence.join("; ")} |`
  )
  .join("\n")}

## Determinism Notes

${report.determinismNotes.map((note) => `- ${note}`).join("\n")}
`;
}

export function renderControlBehaviourDashboardMarkdown(dashboard: ControlBehaviourDashboard): string {
  return `# Playtest Control Behaviour Dashboard

Generated: ${dashboard.generatedAt}
Build commit: ${dashboard.buildCommit}
Iterations: ${dashboard.iterationCount}
Scenarios: ${dashboard.scenarioCount}

## Summary

- Pass rows: ${dashboard.passCount}
- Monitor rows: ${dashboard.monitorCount}
- Fail rows: ${dashboard.failCount}
- Not-measured rows: ${dashboard.notMeasuredCount}
- Manual retest still needed: ${dashboard.manualRetestNeeded ? "yes" : "no"}

## Scenario Ranking

| Rank | Scenario | Verdict | Confidence | Pass Rate | Monitor Rate | Fail Rate |
| --- | --- | --- | --- | --- | --- | --- |
${dashboard.ranking
  .map(
    (entry, index) =>
      `| ${index + 1} | ${entry.scenarioName} | ${entry.verdict} | ${entry.confidence} | ${formatRate(entry.passRate)} | ${formatRate(entry.monitorRate)} | ${formatRate(entry.failRate)} |`
  )
  .join("\n")}

## Limitations

${dashboard.limitations.map((limitation) => `- ${limitation}`).join("\n")}
`;
}

function formatRate(value: number): string {
  return `${Math.round(value * 100)}%`;
}
