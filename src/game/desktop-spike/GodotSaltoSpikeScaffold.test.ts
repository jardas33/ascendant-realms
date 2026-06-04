import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";

async function readJson<T>(path: string): Promise<T> {
  return JSON.parse(await readFile(path, "utf8")) as T;
}

describe("Godot Salto spike scaffold", () => {
  it("keeps the Godot project text-driven and repository-local", async () => {
    [
      "desktop-spikes/godot-salto/project.godot",
      "desktop-spikes/godot-salto/export_presets.cfg",
      "desktop-spikes/godot-salto/scenes/salto_spike_root.tscn",
      "desktop-spikes/godot-salto/scenes/salto_2d_placeholder.tscn",
      "desktop-spikes/godot-salto/scenes/salto_2_5d_orthographic_placeholder.tscn",
      "desktop-spikes/godot-salto/scripts/fixture_importer.gd",
      "desktop-spikes/godot-salto/scripts/adapters/content_registry_adapter.gd",
      "desktop-spikes/godot-salto/scripts/adapters/stable_id_validator.gd",
      "desktop-spikes/godot-salto/scripts/adapters/save_fixture_read_only_adapter.gd",
      "desktop-spikes/godot-salto/scripts/adapters/unit_definition_adapter.gd",
      "desktop-spikes/godot-salto/scripts/adapters/building_definition_adapter.gd",
      "desktop-spikes/godot-salto/scripts/adapters/site_definition_adapter.gd",
      "desktop-spikes/godot-salto/scripts/adapters/lume_definition_adapter.gd",
      "desktop-spikes/godot-salto/scripts/adapters/results_contract_adapter.gd",
      "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
      "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd",
      "desktop-spikes/godot-salto/tests/salto_spike_test_runner.gd",
      "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const project = await readFile("desktop-spikes/godot-salto/project.godot", "utf8");
    const exportPreset = await readFile("desktop-spikes/godot-salto/export_presets.cfg", "utf8");

    expect(project).toContain('config/name="Ascendant Realms Godot Salto Spike"');
    expect(project).toContain("run/main_scene=\"res://scenes/salto_spike_root.tscn\"");
    expect(exportPreset).toContain('name="Windows Desktop"');
    expect(exportPreset).toContain('platform="Windows Desktop"');
    expect(exportPreset).toContain('application/product_version="0.122.0"');
  });

  it("defines one-click Windows scripts without adding engine dependencies", async () => {
    [
      "GODOT_DOCTOR_WINDOWS.bat",
      "GODOT_BOOTSTRAP_WINDOWS.bat",
      "GODOT_VALIDATE_WINDOWS.bat",
      "GODOT_GENERATE_SALTO_WINDOWS.bat",
      "GODOT_TEST_WINDOWS.bat",
      "GODOT_BENCHMARK_WINDOWS.bat",
      "GODOT_EXPORT_WINDOWS.bat",
      "GODOT_PACKAGE_WINDOWS.bat",
      "GODOT_RUN_ALL_WINDOWS.bat",
      "GODOT_FRESH_CHECKOUT_VALIDATE_WINDOWS.bat",
      "tools/godot/doctorGodotWindows.ps1",
      "tools/godot/bootstrapGodotWindows.ps1",
      "tools/godot/runGodotAll.ps1",
      "tools/godot/validateGodotFreshCheckout.ps1",
      "tools/godot/runGodotCiStyleWindows.ps1"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{
      scripts: Record<string, string>;
      dependencies?: Record<string, string>;
      devDependencies?: Record<string, string>;
    }>("package.json");

    [
      "godot:doctor",
      "godot:bootstrap:windows",
      "godot:fixture:export",
      "godot:fixture:validate",
      "godot:scene:generate",
      "godot:validate",
      "godot:test",
      "godot:benchmark",
      "godot:export:windows",
      "godot:package:windows",
      "godot:scorecard",
      "godot:all",
      "godot:fresh-checkout:validate",
      "godot:ci-style:windows"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const dependencies = {
      ...(packageJson.dependencies ?? {}),
      ...(packageJson.devDependencies ?? {})
    };
    ["godot", "electron", "unity", "unreal", "three"].forEach((name) => expect(dependencies[name]).toBeUndefined());
  });

  it("defines the v0.118 packaged headed review and capture workflow", async () => {
    [
      "GODOT_LAUNCH_REVIEW_WINDOWS.bat",
      "GODOT_HEADED_SMOKE_WINDOWS.bat",
      "GODOT_CAPTURE_REVIEW_WINDOWS.bat",
      "tools/godot/launchGodotReviewWindows.ps1",
      "tools/godot/runGodotHeadedSmoke.ps1",
      "tools/godot/captureGodotReviewWindows.ps1",
      "docs/V0118_GODOT_HEADED_SMOKE_SPEC.md",
      "docs/V0118_GODOT_SCREENSHOT_CAPTURE_SPEC.md",
      "docs/V0118_GODOT_PACKAGE_VALIDATION_REPORT.md",
      "docs/V0118_GODOT_HEADED_BENCHMARK_REPORT.md",
      "docs/V0118_GODOT_VISUAL_CONTACT_SHEET_REPORT.md",
      "docs/V0118_EMMANUEL_HEADLESS_AND_HEADED_REVIEW_GUIDE.md",
      "docs/V0118_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    ["godot:launch:review", "godot:headed:smoke", "godot:capture:review"].forEach((script) =>
      expect(packageJson.scripts[script], script).toBeTypeOf("string")
    );

    const project = await readFile("desktop-spikes/godot-salto/project.godot", "utf8");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");

    expect(project).toContain("window/size/viewport_width=1600");
    expect(project).toContain("window/size/viewport_height=900");
    expect(rootScript).toContain("--review-smoke");
    expect(rootScript).toContain("--capture-review");
    expect(rootScript).toContain("--headed-benchmark");
    expect(rootScript).toContain("saveWritesAllowed");
    expect(toolScript).toContain("v0118ArtifactRoot");
    expect(toolScript).toContain("contact-sheet.svg");
  });

  it("commits deterministic generated fixture data with linked_ward and save safety intact", async () => {
    const manifest = await readJson<{
      browserRuntimePreserved: boolean;
      engineDecisionFinalized: boolean;
      generatedOrImportedArtIncluded: boolean;
      linkedWardDamageTakenMultiplier: number;
      localStorageMutationAllowed: boolean;
      modes: string[];
      runtimeArtIntegrated: boolean;
      stableIdValidation: {
        missing: string[];
        unknownProbeRejected: boolean;
      };
    }>("desktop-spikes/godot-salto/data/generated/fixture-manifest.json");

    expect(manifest.linkedWardDamageTakenMultiplier).toBe(0.92);
    expect(manifest.stableIdValidation.missing).toEqual([]);
    expect(manifest.stableIdValidation.unknownProbeRejected).toBe(true);
    expect(manifest.localStorageMutationAllowed).toBe(false);
    expect(manifest.runtimeArtIntegrated).toBe(false);
    expect(manifest.generatedOrImportedArtIncluded).toBe(false);
    expect(manifest.engineDecisionFinalized).toBe(false);
    expect(manifest.browserRuntimePreserved).toBe(true);
    expect(manifest.modes).toEqual(["2D_PLACEHOLDER", "2_5D_ORTHOGRAPHIC_PLACEHOLDER"]);
  });

  it("keeps generated Godot caches, local tools, builds, reports, and packages ignored", async () => {
    const gitignore = await readFile(".gitignore", "utf8");

    [
      "/.tools/godot/",
      "/artifacts/desktop-spikes/",
      "/desktop-spikes/godot-salto/.godot/",
      "/desktop-spikes/godot-salto/builds/*",
      "/desktop-spikes/godot-salto/reports/*",
      "!/desktop-spikes/godot-salto/builds/.gitkeep",
      "!/desktop-spikes/godot-salto/reports/.gitkeep"
    ].forEach((entry) => expect(gitignore).toContain(entry));
  });

  it("adds the required v0.117 report docs and Emmanuel one-click guide", () => {
    [
      "docs/V0117_GODOT_SPIKE_SCOPE.md",
      "docs/V0117_GODOT_SETUP_AND_BOOTSTRAP_SPEC.md",
      "docs/V0117_GODOT_FIXTURE_IMPORT_REPORT.md",
      "docs/V0117_GODOT_AI_FIRST_WORKFLOW_REPORT.md",
      "docs/V0117_GODOT_VISUAL_DIRECTION_COMPARISON.md",
      "docs/V0117_GODOT_BENCHMARK_REPORT.md",
      "docs/V0117_GODOT_WINDOWS_EXPORT_REPORT.md",
      "docs/V0117_EMMANUEL_ONE_CLICK_GUIDE.md",
      "docs/V0117_IMPLEMENTATION_REPORT.md",
      "docs/V0117_DEFERRED_GODOT_FINDINGS.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));
  });

  it("defines the v0.119 representative RTS load scalability spike", async () => {
    [
      "docs/V0119_GODOT_REPRESENTATIVE_RTS_LOAD_SPEC.md",
      "docs/V0119_GODOT_NAVIGATION_AND_AI_PRESSURE_SPEC.md",
      "docs/V0119_GODOT_SCALABILITY_BENCHMARK_REPORT.md",
      "docs/V0119_GODOT_PARITY_REPORT.md",
      "docs/V0119_GODOT_SCORECARD_UPDATE.md",
      "docs/V0119_IMPLEMENTATION_REPORT.md",
      "docs/V0119_EMMANUEL_REVIEW_GUIDE.md",
      "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd",
      "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd.uid"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const runtimeScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const packageScript = await readFile("tools/godot/packageGodotWindows.ps1", "utf8");

    expect(rootScript).toContain('const CHECKPOINT := "v0.122"');
    expect(rootScript).toContain("v0.119-workload-tier-L");
    expect(runtimeScript).toContain("const TIER_ORDER := [\"S\", \"M\", \"L\"]");
    expect(runtimeScript).toContain("LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER := 0.92");
    expect(runtimeScript).toContain("run_benchmark_suite");
    expect(toolScript).toContain("v0119ArtifactRoot");
    expect(toolScript).toContain("PASS_GODOT_REPRESENTATIVE_RTS_BENCHMARK");
    expect(toolScript).toContain("PASS_GODOT_REPRESENTATIVE_RTS_PARITY");
    expect(packageScript).toContain("AscendantRealmsGodotSalto-v0122-windows.zip");
  });

  it("defines the v0.120 fresh checkout and zero-editor automation proof", async () => {
    [
      "docs/V0120_GODOT_FRESH_CHECKOUT_SPEC.md",
      "docs/V0120_GODOT_CI_STYLE_WORKFLOW.md",
      "docs/V0120_ZERO_EDITOR_AUTOMATION_CONTRACT.md",
      "docs/V0120_GODOT_REPRODUCIBILITY_REPORT.md",
      "docs/V0120_EMMANUEL_ONE_CLICK_GUIDE.md",
      "docs/V0120_IMPLEMENTATION_REPORT.md",
      ".github/workflows/godot-fresh-checkout-windows.yml"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const freshScript = await readFile("tools/godot/validateGodotFreshCheckout.ps1", "utf8");
    const ciScript = await readFile("tools/godot/runGodotCiStyleWindows.ps1", "utf8");
    const workflow = await readFile(".github/workflows/godot-fresh-checkout-windows.yml", "utf8");
    const runAll = await readFile("GODOT_RUN_ALL_WINDOWS.bat", "utf8");

    expect(freshScript).toContain("git ls-files --cached --modified --others --exclude-standard");
    expect(freshScript).toContain("npm ci --no-audit --no-fund");
    expect(freshScript).toContain("godot:scene:generate");
    expect(freshScript).toContain("godot:test");
    expect(freshScript).toContain("godot:benchmark");
    expect(freshScript).toContain("godot:export:windows");
    expect(freshScript).toContain("godot:package:windows");
    expect(freshScript).toContain("packageSha256");
    expect(freshScript).toContain("routineEditorUseRequired");
    expect(freshScript).toContain("Test-SafeTempRoot");
    expect(freshScript).toContain("Remove-SafeTempRoot $TempRoot");
    expect(freshScript).toContain("Remove-Item -LiteralPath $Path -Recurse -Force");
    expect(freshScript).not.toContain("--editor");
    expect(ciScript).toContain("-DownloadOfficialInCi");
    expect(ciScript).toContain(".tools\\godot\\ci-appdata");
    expect(ciScript).toContain("CI=true");
    expect(workflow).toContain("workflow_dispatch");
    expect(workflow).toContain("windows-latest");
    expect(workflow).toContain("godot:ci-style:windows");
    expect(runAll).toContain("validateGodotFreshCheckout.ps1");
  });

  it("defines the v0.121 procedural 2.5D visual foundation spike", async () => {
    [
      "docs/V0121_GODOT_2_5D_VISUAL_FOUNDATION_SPEC.md",
      "docs/V0121_GODOT_2D_CONTROL_POSTURE.md",
      "docs/V0121_GODOT_PROCEDURAL_PRESET_SPEC.md",
      "docs/V0121_GODOT_VISUAL_CAPTURE_REPORT.md",
      "docs/V0121_GODOT_PERFORMANCE_COMPARISON.md",
      "docs/V0121_GODOT_IMPLEMENTATION_REPORT.md",
      "docs/V0121_EMMANUEL_VISUAL_REVIEW_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotReviewWindows.ps1", "utf8");
    const benchmarkScript = await readFile("tools/godot/runGodotBenchmark.ps1", "utf8");

    ["CLEAN_READABILITY", "ATMOSPHERIC_BALANCED", "VFX_STRESS_PRIVATE"].forEach((preset) => {
      expect(rootScript).toContain(preset);
      expect(scene3d).toContain(preset);
      expect(toolScript).toContain(preset);
    });
    expect(rootScript).toContain("--visual-preset=");
    expect(rootScript).toContain("CAPTURE_VIEWPORTS := [Vector2i(1600, 900), Vector2i(1920, 1080)]");
    expect(scene3d).toContain("proceduralPrimitiveOnly");
    expect(scene3d).toContain("MinimapOrientationPlaceholder");
    expect(scene3d).toContain("safeZoomBounds");
    expect(captureScript).toContain("godot-salto\\v0121");
    expect(captureScript).toContain("32 PNG captures");
    expect(benchmarkScript).toContain("godot-v0121-benchmark-2_5d-vfx-stress-private.json");
    expect(toolScript).toContain("PASS_GODOT_PROCEDURAL_VISUAL_FOUNDATION_PERFORMANCE_COMPARISON");
    expect(toolScript).toContain("PASS_GODOT_PROCEDURAL_VISUAL_CAPTURE");
  });

  it("defines the v0.122 content-subset adapters and bounded parity harness", async () => {
    [
      "docs/V0122_GODOT_CONTENT_SUBSET_ADAPTER_SPEC.md",
      "docs/V0122_GODOT_RULES_PARITY_HARNESS.md",
      "docs/V0122_GODOT_STABLE_ID_REPORT.md",
      "docs/V0122_GODOT_MIGRATION_READINESS_MATRIX.md",
      "docs/V0122_GODOT_PARITY_REPORT.md",
      "docs/V0122_IMPLEMENTATION_REPORT.md",
      "docs/V0122_EMMANUEL_REVIEW_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const importerScript = await readFile("desktop-spikes/godot-salto/scripts/fixture_importer.gd", "utf8");
    const runtimeScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd", "utf8");
    const scene2d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_2d.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");

    [
      "ContentRegistryAdapter",
      "StableIdValidator",
      "SaveFixtureReadOnlyAdapter",
      "UnitDefinitionAdapter",
      "BuildingDefinitionAdapter",
      "SiteDefinitionAdapter",
      "LumeDefinitionAdapter",
      "ResultsContractAdapter"
    ].forEach((adapterName) => expect(importerScript).toContain(adapterName));

    expect(rootScript).toContain("godot-v0122-adapter-validation.json");
    expect(rootScript).toContain("godot-v0122-parity-report.json");
    expect(importerScript).toContain("v0122_unknown_fixture_id_must_be_rejected");
    expect(importerScript).toContain("PASS_GODOT_CONTENT_ADAPTER_VALIDATION");
    expect(importerScript).toContain("linked_ward");
    expect(importerScript).toContain("0.92");
    expect(runtimeScript).toContain("run_v0122_parity_fixture");
    expect(runtimeScript).toContain("PASS_GODOT_RULES_PARITY_HARNESS");
    expect(runtimeScript).toContain("fullSimulationParityClaimed");
    expect(scene2d).toContain("run_v0122_parity_fixture");
    expect(scene3d).toContain("run_v0122_parity_fixture");
    expect(toolScript).toContain("v0122ArtifactRoot");
    expect(toolScript).toContain("content-subset.json");
    expect(toolScript).toContain("stable-id-report.json");
    expect(toolScript).toContain("adapter-validation.json");
    expect(toolScript).toContain("parity-report.json");
    expect(toolScript).toContain("migration-readiness.json");
  });
});
