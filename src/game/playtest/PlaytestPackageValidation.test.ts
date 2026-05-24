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
          checkpoint: "v0.18.3 worker assignment and construction pathing fix",
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
      { path: "RELEASE_CANDIDATE_NOTES.md", sizeBytes: 20, textContent: "Release candidate" },
      { path: "EMMANUEL_MANUAL_RETEST_CHECKLIST.md", sizeBytes: 20, textContent: "Manual retest" },
      { path: "FIRST_TESTER_MESSAGE.md", sizeBytes: 20, textContent: "Tester message" },
      { path: "TESTER_FEEDBACK_FORM_SHORT.md", sizeBytes: 20, textContent: "Feedback short" },
      { path: "ROUTE_ASSIGNMENTS_SMALL_BATCH.md", sizeBytes: 20, textContent: "Routes short" },
      { path: "TESTER_LAUNCH_PACKET_INDEX.md", sizeBytes: 20, textContent: "Launch index" },
      { path: "V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Retest intake" },
      { path: "V01613_BD26DE3_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Retest intake" },
      { path: "V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md", sizeBytes: 20, textContent: "Fix note" },
      { path: "V017_SOLO_PLAYTEST_INTAKE.md", sizeBytes: 20, textContent: "Solo intake" },
      { path: "V017_WORKER_ECONOMY_DESIGN_SPEC.md", sizeBytes: 20, textContent: "Worker economy spec" },
      { path: "V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial retest intake" },
      { path: "V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial follow-up intake" },
      { path: "V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial v0.17.3 intake" },
      { path: "V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial v0.17.4 intake" },
      { path: "V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Tutorial v0.17.5 intake" },
      { path: "V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md", sizeBytes: 20, textContent: "Worker construction spec" },
      { path: "V018_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Worker construction report" },
      { path: "V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md", sizeBytes: 20, textContent: "Worker construction expansion spec" },
      { path: "V0182_IMPLEMENTATION_REPORT.md", sizeBytes: 20, textContent: "Worker construction expansion report" },
      { path: "V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md", sizeBytes: 20, textContent: "Worker retest intake" },
      { path: "V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md", sizeBytes: 20, textContent: "Worker pathing fix report" },
      { path: "start-playtest-server.mjs", sizeBytes: 20, textContent: "server" },
      { path: "START_GAME_WINDOWS.bat", sizeBytes: 20, textContent: "node start-playtest-server.mjs" },
      { path: "START_GAME_MAC_LINUX.sh", sizeBytes: 20, textContent: "node start-playtest-server.mjs" }
    ]
  };
}
