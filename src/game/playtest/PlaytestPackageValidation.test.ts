import { describe, expect, it } from "vitest";
import { validatePlaytestPackageSnapshot, type PlaytestPackageSnapshot } from "./PlaytestPackageValidation";

describe("PlaytestPackageValidation", () => {
  it("accepts a complete private playtest package snapshot", () => {
    const result = validatePlaytestPackageSnapshot(completeSnapshot());

    expect(result.errors).toEqual([]);
    expect(result.checks).toContain("game/index.html uses package-safe relative asset URLs");
    expect(result.checks).toContain("built game assets present");
  });

  it("rejects absolute asset paths that would break portable package serving", () => {
    const snapshot = completeSnapshot();
    snapshot.files = snapshot.files.map((file) =>
      file.path === "game/index.html" ? { ...file, textContent: '<script type="module" src="/assets/index.js"></script>' } : file
    );

    const result = validatePlaytestPackageSnapshot(snapshot);

    expect(result.ok).toBe(false);
    expect(result.errors).toContain("game/index.html uses absolute /assets/ URLs; playtest builds should use relative assets.");
  });

  it("rejects development folders, raw private feedback, and obvious secrets", () => {
    const snapshot = completeSnapshot();
    snapshot.files.push(
      { path: "node_modules/example/index.js", sizeBytes: 10 },
      { path: "playtest-feedback/raw/PT-PRIVATE.md", sizeBytes: 10, textContent: "private tester note" },
      { path: ".env", sizeBytes: 24, textContent: "OPENAI_API_KEY=secret" }
    );

    const result = validatePlaytestPackageSnapshot(snapshot);

    expect(result.ok).toBe(false);
    expect(result.errors).toEqual(
      expect.arrayContaining([
        "Forbidden package path included: node_modules/example/index.js.",
        "Forbidden package path included: playtest-feedback/raw/PT-PRIVATE.md.",
        "Forbidden secret-like file included: .env.",
        "Possible secret detected in .env: OpenAI API key assignment."
      ])
    );
  });
});

function completeSnapshot(): PlaytestPackageSnapshot {
  return {
    packageName: "ascendant-realms-private-playtest-afbb37f",
    files: [
      { path: "game/index.html", sizeBytes: 128, textContent: '<script type="module" src="./assets/index.js"></script>' },
      { path: "game/assets/index.js", sizeBytes: 1024, textContent: "console.log('game');" },
      { path: "README_FOR_TESTERS.md", sizeBytes: 20, textContent: "Read me" },
      { path: "PLAYTEST_BUILD_INFO.md", sizeBytes: 20, textContent: "Build info" },
      {
        path: "playtest-build-info.json",
        sizeBytes: 200,
        textContent: JSON.stringify({
          commit: "afbb37f000000000000000000000000000000000",
          shortCommit: "afbb37f",
          generatedAtUtc: "2026-05-18T13:00:00.000Z",
          checkpoint: "v0.16.9 autonomous manual-retest proxy and tester readiness",
          packagePurpose: "private human playtest distribution",
          requiresLocalServer: true
        })
      },
      { path: "FEEDBACK_SUBMISSION_PACKET.md", sizeBytes: 20, textContent: "Feedback form" },
      { path: "TESTER_QUICK_START.md", sizeBytes: 20, textContent: "Quick start" },
      { path: "ROUTE_ASSIGNMENT_PLAN.md", sizeBytes: 20, textContent: "Routes" },
      { path: "CONTROL_RETEST_SCRIPT.md", sizeBytes: 20, textContent: "Retest" },
      { path: "PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md", sizeBytes: 20, textContent: "Route card" },
      { path: "BEHAVIOUR_MODE_TESTER_CHECKLIST.md", sizeBytes: 20, textContent: "Checklist" },
      { path: "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md", sizeBytes: 20, textContent: "Feedback" },
      { path: "CONTROL_REGRESSION_TRIAGE_GUIDE.md", sizeBytes: 20, textContent: "Triage" },
      { path: "start-playtest-server.mjs", sizeBytes: 20, textContent: "server" },
      { path: "START_GAME_WINDOWS.bat", sizeBytes: 20, textContent: "node start-playtest-server.mjs" },
      { path: "START_GAME_MAC_LINUX.sh", sizeBytes: 20, textContent: "node start-playtest-server.mjs" }
    ]
  };
}
