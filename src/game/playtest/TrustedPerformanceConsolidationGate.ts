import { existsSync, readFileSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";

export type BrowserPerformanceGateStatus = "GREEN" | "AMBER" | "RED";

export interface BrowserPerformanceGateMetrics {
  fpsAverage: number;
  p95Ms: number;
  maxMs: number;
  longTasks: number;
}

export const V0115_CHECKPOINT =
  "v0.115 Trusted Performance Consolidation, Clean-Restart Retest Packet, and Browser Gate";

export const V0115_GATE_RESULT: BrowserPerformanceGateStatus = "RED";

export const V0115_REQUIRED_DOCS = [
  "docs/V0115_BROWSER_PERFORMANCE_GATE.md",
  "docs/V0115_CONSOLIDATED_PERFORMANCE_REPORT.md",
  "docs/V0115_EMMANUEL_CLEAN_RESTART_RETEST.md",
  "docs/V0115_EMMANUEL_PERFORMANCE_DECISION_PACKET.md",
  "docs/V0115_IMPLEMENTATION_REPORT.md"
] as const;

export const V0115_REQUIRED_ARTIFACTS = [
  "artifacts/benchmarks/v0108/battle-benchmark-summary.json",
  "artifacts/benchmarks/v0108/scenario-results.json",
  "artifacts/performance/v0109/trusted-benchmark-summary.json",
  "artifacts/performance/v0109/root-cause-matrix.json",
  "artifacts/performance/v0109/execution-mode-comparison.json",
  "artifacts/performance/v0110/phase-profiler-summary.json",
  "artifacts/performance/v0110/density-scaling-report.json",
  "artifacts/performance/v0110/trusted-browser-gate.json",
  "artifacts/performance/v0111/browser-control-baselines.json",
  "artifacts/performance/v0111/clean-profile-benchmark.json",
  "artifacts/performance/v0111/environment-comparison.json",
  "artifacts/performance/host-snapshots/2026-06-03T22-26-46-316Z/host-snapshot.json",
  "artifacts/performance/v0112/allocation-audit.json",
  "artifacts/performance/v0112/idle-cost-matrix.json",
  "artifacts/performance/v0112/parity-summary.json",
  "artifacts/performance/v0113/query-profile.json",
  "artifacts/performance/v0113/old-new-comparison.json",
  "artifacts/performance/v0113/parity-summary.json",
  "artifacts/performance/v0114/lifecycle-audit.json",
  "artifacts/performance/v0114/before-after-delta.json",
  "artifacts/performance/v0114/visual-parity.json"
] as const;

export const V0115_REQUIRED_VERIFICATION_COMMANDS = [
  "npm test",
  "npm run build",
  "npm run validate:content",
  "npm run validate:art-intake",
  "npm run perf:host-snapshot",
  "npm run perf:controls:preview",
  "npm run perf:trusted:clean-profile",
  "npm run perf:trusted:preview",
  "npm run perf:phase-profile",
  "npm run perf:allocation-audit",
  "npm run perf:spatial-query-profile",
  "npm run perf:render-lifecycle-audit",
  "npm run perf:trusted:report",
  "npm run benchmark:battle:smoke",
  "npm run benchmark:battle:representative",
  "npm run benchmark:battle:stress",
  "npm run benchmark:battle:report",
  "npm run package:playtest",
  "npm run verify:playtest-package",
  "git diff --check"
] as const;

export const V0115_FORBIDDEN_SCOPE_TERMS = [
  "runtime gameplay",
  "combat",
  "balance",
  "AI",
  "pathing",
  "saves",
  "save-version",
  "localStorage keys",
  "stable IDs",
  "serialized IDs",
  "art",
  "runtime asset path",
  "engine posture",
  "desktop work",
  "multiplayer",
  "v0.116"
] as const;

export function classifyBrowserPerformanceGate(metrics: BrowserPerformanceGateMetrics): BrowserPerformanceGateStatus {
  if (metrics.fpsAverage >= 30 && metrics.p95Ms <= 50 && metrics.longTasks <= 1) {
    return "GREEN";
  }

  if (metrics.fpsAverage >= 18 && metrics.p95Ms <= 120 && metrics.maxMs <= 500) {
    return "AMBER";
  }

  return "RED";
}

export function validateV0115TrustedPerformanceConsolidation(repoRoot = process.cwd()): string[] {
  const errors: string[] = [];

  V0115_REQUIRED_DOCS.forEach((docPath) => {
    if (!existsSync(resolve(repoRoot, docPath))) {
      errors.push(`Missing v0.115 doc: ${docPath}`);
    }
  });

  if (errors.length > 0) {
    return errors;
  }

  V0115_REQUIRED_ARTIFACTS.forEach((artifactPath) => {
    if (!isExpectedArtifactPath(artifactPath)) {
      errors.push(`Invalid v0.115 artifact path catalog entry: ${artifactPath}`);
    }
  });

  const gateDoc = readRepoText(repoRoot, "docs/V0115_BROWSER_PERFORMANCE_GATE.md");
  const resultMatches = [...gateDoc.matchAll(/^## Result: (GREEN|AMBER|RED)$/gmu)].map((match) => match[1]);
  if (resultMatches.length !== 1) {
    errors.push(`Expected exactly one gate result, found ${resultMatches.length}.`);
  } else if (resultMatches[0] !== V0115_GATE_RESULT) {
    errors.push(`Expected v0.115 gate result ${V0115_GATE_RESULT}, found ${resultMatches[0]}.`);
  }

  [
    "Host-pressure contribution",
    "Browser-environment contribution",
    "Phaser-empty contribution",
    "Battle fixed cost",
    "Density cost",
    "Pathing/spatial cost",
    "Renderer cost",
    "DOM cost",
    "Remaining uncertainty",
    "Trusted execution modes",
    "Before/after evidence"
  ].forEach((requiredPhrase) => {
    if (!gateDoc.includes(requiredPhrase)) {
      errors.push(`Gate doc missing required section phrase: ${requiredPhrase}`);
    }
  });

  const consolidatedReport = readRepoText(repoRoot, "docs/V0115_CONSOLIDATED_PERFORMANCE_REPORT.md");
  V0115_REQUIRED_ARTIFACTS.forEach((artifactPath) => {
    if (!consolidatedReport.includes(artifactPath)) {
      errors.push(`Consolidated report does not reference artifact: ${artifactPath}`);
    }
  });

  const restartPacket = readRepoText(repoRoot, "docs/V0115_EMMANUEL_CLEAN_RESTART_RETEST.md");
  const numberedSteps = [...restartPacket.matchAll(/^(\d+)\. /gmu)].map((match) => Number(match[1]));
  if (numberedSteps.length !== 12 || numberedSteps.some((step, index) => step !== index + 1)) {
    errors.push(`Clean-restart retest must have exact steps 1-12; found ${numberedSteps.join(",")}.`);
  }

  const implementationReport = readRepoText(repoRoot, "docs/V0115_IMPLEMENTATION_REPORT.md");
  V0115_FORBIDDEN_SCOPE_TERMS.forEach((term) => {
    if (!implementationReport.includes(term)) {
      errors.push(`Implementation scope guard missing term: ${term}`);
    }
  });

  V0115_REQUIRED_DOCS.forEach((docPath) => {
    validateLocalMarkdownLinks(repoRoot, docPath, errors);
  });

  return errors;
}

function readRepoText(repoRoot: string, path: string): string {
  return readFileSync(resolve(repoRoot, path), "utf-8");
}

function validateLocalMarkdownLinks(repoRoot: string, docPath: string, errors: string[]): void {
  const absoluteDocPath = resolve(repoRoot, docPath);
  const docText = readFileSync(absoluteDocPath, "utf-8");
  const docDirectory = dirname(absoluteDocPath);
  const linkPattern = /\[[^\]]+\]\((?!https?:\/\/|mailto:|#)([^)]+)\)/giu;
  for (const match of docText.matchAll(linkPattern)) {
    const rawTarget = match[1].trim().replace(/^<|>$/gu, "").split("#")[0];
    if (rawTarget.length === 0) {
      continue;
    }
    const target = resolve(docDirectory, rawTarget);
    const repoRelativeTarget = relative(resolve(repoRoot), target).replaceAll("\\", "/");
    if (repoRelativeTarget.startsWith("artifacts/")) {
      if (!V0115_REQUIRED_ARTIFACTS.includes(repoRelativeTarget as (typeof V0115_REQUIRED_ARTIFACTS)[number])) {
        errors.push(`Unexpected artifact link in ${docPath}: ${repoRelativeTarget}`);
      }
      continue;
    }
    if (!existsSync(target)) {
      errors.push(`Broken local link in ${docPath}: ${rawTarget}`);
    }
  }
}

function isExpectedArtifactPath(path: string): boolean {
  return /^artifacts\/(?:benchmarks\/v0108|performance\/(?:v0109|v0110|v0111|v0112|v0113|v0114|host-snapshots\/2026-06-03T22-26-46-316Z))\/.+\.(?:json|md|png)$/u.test(
    path
  );
}
