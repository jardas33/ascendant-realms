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
    expect(packageScript).toContain("AscendantRealmsGodotSalto-v0124-windows.zip");
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

  it("defines the v0.123 Godot continuation decision packet and reference-art prompt library", async () => {
    [
      "docs/V0123_GODOT_CONTINUATION_GATE.md",
      "docs/V0123_GODOT_SCORECARD_UPDATE.md",
      "docs/V0123_UNITY_COMPARATOR_BOUNDARY.md",
      "docs/V0123_EMMANUEL_GODOT_REVIEW_GUIDE.md",
      "docs/V0123_REFERENCE_ART_REVIEW_BOUNDARY.md",
      "docs/V0123_IMPLEMENTATION_REPORT.md",
      "docs/art-prompts/V0123_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md",
      "docs/art-prompts/V0123_02_BARROSAN_HERO_SILHOUETTE_SHEET.md",
      "docs/art-prompts/V0123_03_BARROSAN_WORKER_SILHOUETTE_SHEET.md",
      "docs/art-prompts/V0123_04_BARROSAN_MILITIA_RANGER_SILHOUETTE_SHEET.md",
      "docs/art-prompts/V0123_05_COMMAND_HALL_BARRACKS_STYLE_SHEET.md",
      "docs/art-prompts/V0123_06_LUME_VFX_STYLE_FRAME.md",
      "docs/art-prompts/V0123_07_CAMPAIGN_MAP_STYLE_FRAME.md",
      "docs/art-prompts/V0123_08_HUD_STYLE_FRAME.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const gate = await readFile("docs/V0123_GODOT_CONTINUATION_GATE.md", "utf8");
    const unity = await readFile("docs/V0123_UNITY_COMPARATOR_BOUNDARY.md", "utf8");
    const boundary = await readFile("docs/V0123_REFERENCE_ART_REVIEW_BOUNDARY.md", "utf8");
    const prompt = await readFile("docs/art-prompts/V0123_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md", "utf8");

    expect(gate).toContain("GODOT_SPIKE_GREEN");
    expect(gate).toContain("not green as a final engine decision");
    expect(unity).toContain("No Unity project is authorized by v0.123");
    expect(boundary).toContain("v0.123 does not generate images");
    expect(boundary).toContain("Runtime integration is explicitly forbidden");
    expect(prompt).toContain("Original IP only");
    expect(prompt).toContain("Runtime integration is explicitly forbidden");
    expect(prompt).toContain("Human Review Checklist");
  });

  it("defines the v0.124 player-facing Salto review slice and private harness separation", async () => {
    [
      "GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat",
      "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
      "GODOT_CAPTURE_PLAYER_SLICE_WINDOWS.bat",
      "GODOT_PLAYER_SLICE_VALIDATE_WINDOWS.bat",
      "tools/godot/launchGodotPrivateHarnessWindows.ps1",
      "tools/godot/launchGodotPlayerSliceWindows.ps1",
      "tools/godot/captureGodotPlayerSliceWindows.ps1",
      "tools/godot/validateGodotPlayerSlice.ps1",
      "docs/V0124_PLAYER_FACING_SLICE_SPEC.md",
      "docs/V0124_PRIVATE_HARNESS_SEPARATION_REPORT.md",
      "docs/V0124_PROCEDURAL_SALTO_BLOCKOUT_SPEC.md",
      "docs/V0124_PROCEDURAL_SILHOUETTE_SPEC.md",
      "docs/V0124_HUD_MINIMAP_PLACEHOLDER_SPEC.md",
      "docs/V0124_LUME_PRESENTATION_SPEC.md",
      "docs/V0124_ART_READY_SLOT_REPORT.md",
      "docs/V0124_PERFORMANCE_SMOKE_REPORT.md",
      "docs/V0124_VISUAL_CAPTURE_REPORT.md",
      "docs/V0124_IMPLEMENTATION_REPORT.md",
      "docs/V0124_EMMANUEL_PLAYER_SLICE_REVIEW_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    [
      "godot:launch:private-harness",
      "godot:launch:player-slice",
      "godot:capture:player-slice",
      "godot:validate:player-slice"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const reviewLaunch = await readFile("tools/godot/launchGodotReviewWindows.ps1", "utf8");
    const playerLaunch = await readFile("tools/godot/launchGodotPlayerSliceWindows.ps1", "utf8");
    const privateLaunch = await readFile("tools/godot/launchGodotPrivateHarnessWindows.ps1", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotPlayerSliceWindows.ps1", "utf8");
    const validateScript = await readFile("tools/godot/validateGodotPlayerSlice.ps1", "utf8");

    ["--private-harness", "--player-slice", "--player-slice-validate", "--player-slice-capture"].forEach((flag) =>
      expect(rootScript).toContain(flag)
    );
    ["JARDAS: Salto Foothold", "Start Salto Review", "Salto Foothold Briefing", "Salto Review Complete"].forEach((text) =>
      expect(rootScript).toContain(text)
    );
    expect(rootScript).toContain("PASS_PLAYER_SLICE_VALIDATION");
    expect(rootScript).toContain("PASS_PLAYER_SLICE_CAPTURE");
    expect(rootScript).toContain("generatedOrImportedArtIncluded");
    expect(rootScript).toContain("saveWritesAllowed");
    expect(rootScript).toContain("stableIdsChanged");

    expect(scene3d).toContain("set_player_facing_mode");
    expect(scene3d).toContain("commandButtonsRendered");
    expect(scene3d).toContain("playerFacingHudCompact");
    expect(scene3d).toContain("cameraPanBounds");
    expect(scene3d).toContain("CapsuleMesh");
    expect(scene3d).toContain("CommandButtonMove");
    expect(scene3d).toContain("MinimapOrientationPlaceholder");

    expect(reviewLaunch).toContain("--private-harness");
    expect(privateLaunch).toContain("--private-harness");
    expect(playerLaunch).toContain("--player-slice");
    expect(captureScript).toContain("--player-slice-capture");
    expect(validateScript).toContain("--player-slice-validate");

    [
      "v0124ArtifactRoot",
      "PASS_PLAYER_FACING_SLICE_VALIDATION",
      "PASS_PLAYER_SLICE_SCREENSHOT_CAPTURE",
      "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE",
      "PASS_ART_SLOT_REPORT",
      "terrain_materials",
      "title_background",
      "manualDragDropRequired",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("ImageTexture");
  });

  it("defines the v0.125 player-slice visual QA gate without broadening runtime scope", async () => {
    [
      "tools/godot/auditGodotPlayerSliceWindows.ps1",
      "docs/V0125_PLAYER_SLICE_VISUAL_QA_SPEC.md",
      "docs/V0125_PLAYER_SLICE_ISSUE_LEDGER.md",
      "docs/V0125_PLAYER_SLICE_REVIEW_READINESS_GATE.md",
      "docs/V0125_IMPLEMENTATION_REPORT.md",
      "docs/V0125_EMMANUEL_REVIEW_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    expect(packageJson.scripts["godot:audit:player-slice"]).toBeTypeOf("string");
    expect(packageJson.scripts["godot:fresh-checkout:validate"]).toBeTypeOf("string");
    expect(packageJson.scripts["godot:package:windows"]).toBeTypeOf("string");

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const auditScript = await readFile("tools/godot/auditGodotPlayerSliceWindows.ps1", "utf8");
    const readinessGate = await readFile("docs/V0125_PLAYER_SLICE_REVIEW_READINESS_GATE.md", "utf8");
    const implementationReport = await readFile("docs/V0125_IMPLEMENTATION_REPORT.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");

    expect(rootScript).toContain("Salto foothold review");
    expect(rootScript).not.toContain("Private visual-review slice");
    expect(rootScript).toContain("set_player_shell_screen");
    expect(rootScript).toContain("\"status\": status");
    expect(rootScript).toContain("PASS_PLAYER_SLICE_VALIDATION");
    expect(rootScript).toContain("PASS_PLAYER_SLICE_CAPTURE");
    expect(rootScript).toContain("linkedWardDamageTakenMultiplier");

    [
      "set_player_shell_screen",
      "playerFacingNonBattleChromeHidden",
      "playerFacingSelectionUsesFixtureIds",
      "terrainViewportCoveragePass",
      "hudVisible",
      "Vector2(26.0, 22.0)",
      "_player_entity_label"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0125ArtifactRoot",
      "player-slice-audit",
      "PASS_PLAYER_SLICE_SCREENSHOT_AUDIT",
      "PLAYER_SLICE_REVIEW_READY",
      "screenshot-audit.json",
      "issue-ledger.json",
      "before-after-manifest.json",
      "V0125_TITLE_NO_DEBUG_JARGON",
      "V0125_BRIEFING_CHROME_HIDDEN",
      "V0125_BATTLE_TERRAIN_COVERAGE",
      "V0125_BATTLE_NO_DEBUG_OR_IDS",
      "V0125_RESULTS_CHROME_HIDDEN",
      "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE",
      "saveWritesAllowed",
      "stableIdsChanged",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(auditScript).toContain("captureGodotPlayerSliceWindows.ps1");
    expect(auditScript).toContain("player-slice-audit");
    expect(readinessGate).toContain("PLAYER_SLICE_REVIEW_READY");
    expect(implementationReport).toContain("No save or localStorage changes");
    expect(handoff).toContain("v0.125 Godot Player-Slice Automated Visual QA");
    expect(handoff).toContain("linked_ward` remains exactly `0.92");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.126 procedural Salto environment authorship and camera readability pass", async () => {
    [
      "docs/V0126_SALTO_ENVIRONMENT_AUTHORSHIP_SPEC.md",
      "docs/V0126_CAMERA_FRAMING_SPEC.md",
      "docs/V0126_TACTICAL_LANE_READABILITY_REPORT.md",
      "docs/V0126_PERFORMANCE_SAFETY_REPORT.md",
      "docs/V0126_VISUAL_CAPTURE_REPORT.md",
      "docs/V0126_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotPlayerSliceWindows.ps1", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    [
      "title_backdrop",
      "briefing_backdrop",
      "battle_default",
      "road",
      "ford",
      "quarry",
      "shrine",
      "ruin",
      "buildable_ground",
      "minimap",
      "objective_focus",
      "camera_min_zoom",
      "camera_max_zoom",
      "clean_preset",
      "atmospheric_preset_private"
    ].forEach((id) => {
      expect(rootScript).toContain(id);
      expect(toolScript).toContain(id);
    });

    [
      "focus_layout_feature",
      "set_camera_zoom_posture",
      "recenter_camera",
      "highland_foothold_shape_core",
      "wet_granite_main_road_bed",
      "shallow_ford_cobble_crossing",
      "quarry_cut_worked_stone_step_lower",
      "shrine_clearing_ground",
      "ruin_pocket_floor",
      "buildable_ground_patch_friendly",
      "blocked_terrain_cue_north_rocks",
      "moss_material_posture_patch",
      "warm_hearth_accent_command_hall",
      "restrained_teal_lume_accent_a",
      "minimapMatchesAuthoredLayout",
      "roadDistinctFromBuildableGround",
      "fordDistinctFromWater",
      "quarryDistinctFromRuin",
      "shrineDistinctFromMine",
      "noGiantMarginRegression",
      "cameraBoundsSafe",
      "zoomBoundsSafe",
      "objectiveFocusHelperAvailable",
      "optionalRecenterButtonAvailable"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0126ArtifactRoot",
      "v0126ScreenshotRoot",
      "PASS_V0126_SALTO_ENVIRONMENT_CAPTURE",
      "PASS_V0126_SALTO_ENVIRONMENT_AUTHORSHIP",
      "PASS_V0126_CAMERA_FRAMING",
      "PASS_V0126_TACTICAL_LANE_READABILITY",
      "PASS_V0126_PERFORMANCE_SAFETY",
      "environment-authorship-report.json",
      "camera-framing-report.json",
      "tactical-lane-readability-report.json",
      "performance-safety-report.json",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated",
      "routineEditorUseRequired",
      "finalEngineDecisionMade",
      "fullPortStarted"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(captureScript).toContain("godot-salto\\v0126");
    expect(captureScript).toContain("15 PNG captures");
    expect(captureScript).toContain("player-slice-capture-v0126");

    expect(rootScript).toContain("PASS_PLAYER_SLICE_VALIDATION");
    expect(rootScript).toContain("linkedWardDamageTakenMultiplier");
    expect(rootScript).toContain("saveWritesAllowed");
    expect(scene3d).toContain("proceduralPrimitiveOnly");
    expect(scene3d).toContain("ATMOSPHERIC_BALANCED");
    expect(scene3d).toContain("VFX_STRESS_PRIVATE");
    expect(handoff).toContain("v0.126 Godot Procedural Salto Environment Authorship");
    expect(roadmap).toContain("v0.126 Godot Procedural Salto Environment Authorship");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("ImageTexture");
    expect(toolScript).not.toContain("ImageTexture");
  });
});
