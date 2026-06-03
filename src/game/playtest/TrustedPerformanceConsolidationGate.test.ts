import { describe, expect, it } from "vitest";
import {
  classifyBrowserPerformanceGate,
  V0115_GATE_RESULT,
  V0115_REQUIRED_DOCS,
  V0115_REQUIRED_VERIFICATION_COMMANDS,
  validateV0115TrustedPerformanceConsolidation
} from "./TrustedPerformanceConsolidationGate";
import {
  EXPECTED_PLAYTEST_PACKAGE_CHECKPOINT,
  REQUIRED_PLAYTEST_PACKAGE_FILES
} from "./PlaytestPackageValidation";

describe("TrustedPerformanceConsolidationGate", () => {
  it("classifies GREEN, AMBER, and RED by the v0.115 gate schema", () => {
    expect(classifyBrowserPerformanceGate({ fpsAverage: 30, p95Ms: 50, maxMs: 80, longTasks: 1 })).toBe("GREEN");
    expect(classifyBrowserPerformanceGate({ fpsAverage: 18, p95Ms: 120, maxMs: 500, longTasks: 20 })).toBe("AMBER");
    expect(classifyBrowserPerformanceGate({ fpsAverage: 2.5, p95Ms: 533.2, maxMs: 650, longTasks: 53 })).toBe("RED");
  });

  it("locks the v0.115 gate to one RED result with valid docs, links, and artifacts", () => {
    expect(V0115_GATE_RESULT).toBe("RED");
    expect(validateV0115TrustedPerformanceConsolidation()).toEqual([]);
  });

  it("keeps the package validator pointed at the v0.115 docs", () => {
    expect(EXPECTED_PLAYTEST_PACKAGE_CHECKPOINT).toBe(
      "v0.115 Trusted Performance Consolidation, Clean-Restart Retest Packet, and Browser Gate"
    );
    expect(REQUIRED_PLAYTEST_PACKAGE_FILES).toEqual(
      expect.arrayContaining(V0115_REQUIRED_DOCS.map((docPath) => docPath.replace(/^docs\//u, "")))
    );
  });

  it("records the required benchmark and package verification commands", () => {
    expect(V0115_REQUIRED_VERIFICATION_COMMANDS).toEqual(
      expect.arrayContaining([
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
        "npm run verify:playtest-package"
      ])
    );
  });
});
