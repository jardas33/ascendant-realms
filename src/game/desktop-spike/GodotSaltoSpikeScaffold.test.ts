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
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.127 procedural silhouette selection and combat readability pass", async () => {
    [
      "docs/V0127_PROCEDURAL_SILHOUETTE_LIBRARY.md",
      "docs/V0127_SELECTION_FEEDBACK_SPEC.md",
      "docs/V0127_COMBAT_READABILITY_REPORT.md",
      "docs/V0127_VISUAL_CAPTURE_REPORT.md",
      "docs/V0127_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotPlayerSliceWindows.ps1", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    [
      "hero",
      "worker",
      "militia",
      "ranger",
      "ashen_raider",
      "command_hall",
      "barracks",
      "mine",
      "shrine",
      "quarry",
      "ruin",
      "site",
      "lume_endpoint",
      "hero_selected",
      "worker_selected",
      "squad_selected",
      "move_order",
      "attack_order",
      "combat",
      "death",
      "results"
    ].forEach((id) => {
      expect(rootScript).toContain(id);
      expect(toolScript).toContain(id);
    });

    [
      "focus_visual_subject",
      "show_combat_readability_sample",
      "show_death_readability_sample",
      "hero_command_banner",
      "worker_pack_crate",
      "militia_spear_profile",
      "ranger_bow_profile",
      "ashen_raider_forward_blade",
      "ashen_brute_shoulder_left",
      "command_door_readability",
      "weapon_rack_silhouette",
      "mine_mouth_shadow",
      "shrine_beacon_slot",
      "claim_post",
      "lumeEndpointSilhouetteRendered",
      "hoverFeedbackRendered",
      "selectedHeroMarkerRendered",
      "selectedWorkerMarkerRendered",
      "squadSelectionMarkerRendered",
      "moveOrderMarkerRendered",
      "attackOrderMarkerRendered",
      "restrainedHealthBarsRendered",
      "damageFlashRendered",
      "deathFadeRendered",
      "meleeContactReadable",
      "rangedShotPlaceholderRendered",
      "pressureWaveArrivalReadable",
      "siteContestReadable",
      "resultsReadinessReadable",
      "silhouetteDistinctnessMetadata",
      "artSlotFallbackRemains"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0127ArtifactRoot",
      "v0127ScreenshotRoot",
      "PASS_V0127_SILHOUETTE_SELECTION_COMBAT_CAPTURE",
      "PASS_V0127_PROCEDURAL_SILHOUETTE_LIBRARY",
      "PASS_V0127_SELECTION_FEEDBACK",
      "PASS_V0127_COMBAT_READABILITY",
      "silhouette-library-report.json",
      "selection-feedback-report.json",
      "combat-readability-report.json",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated",
      "routineEditorUseRequired",
      "stableIdsChanged",
      "saveWritesAllowed",
      "fullPortStarted"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(captureScript).toContain("--player-slice-capture");

    expect(rootScript).toContain("PASS_PLAYER_SLICE_VALIDATION");
    expect(scene3d).toContain("linkedWardDamageTakenMultiplier");
    expect(scene3d).toContain("saveWritesAllowed");
    expect(handoff).toContain("v0.127 Godot Procedural Silhouette Library");
    expect(roadmap).toContain("v0.127 Godot Procedural Silhouette Library");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.128 player-facing HUD minimap feedback and micro-onboarding pass", async () => {
    [
      "docs/V0128_HUD_SPEC.md",
      "docs/V0128_MINIMAP_SPEC.md",
      "docs/V0128_MICRO_ONBOARDING_SPEC.md",
      "docs/V0128_OBJECTIVE_FEEDBACK_REPORT.md",
      "docs/V0128_VISUAL_CAPTURE_REPORT.md",
      "docs/V0128_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotPlayerSliceWindows.ps1", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    [
      "hud_default",
      "hero_selected",
      "worker_selected",
      "squad_selected",
      "minimap",
      "objective_1",
      "quarry",
      "pressure_wave",
      "lume_restore",
      "results",
      "onboarding_skip_private"
    ].forEach((id) => expect(rootScript).toContain(id));

    [
      "HudResourceCornerRow",
      "HudCurrentObjectiveStrip",
      "SelectedContextCard",
      "MicroOnboardingPrompt",
      "ObjectiveFeedbackAlert",
      "MoreDetailsDisclosure",
      "set_onboarding_step",
      "skip_onboarding_private",
      "show_objective_feedback",
      "v0128HudPass",
      "hudHierarchyPass",
      "compactResourceCornerRendered",
      "heroHealthAndAbilityPostureRendered",
      "workerContextRendered",
      "squadContextRendered",
      "currentObjectiveStripRendered",
      "pauseAffordanceRendered",
      "moreDetailsDisclosureRendered",
      "v0128MinimapPass",
      "minimap_salto_terrain_outline",
      "minimap_main_road",
      "minimap_water_strip",
      "minimap_friendly_cluster",
      "minimap_hostile_marker",
      "minimap_hero_marker",
      "minimap_objective_marker",
      "minimap_quarry",
      "minimap_shrine",
      "minimap_mine_marker",
      "minimap_lume_endpoint_a",
      "minimap_lume_link",
      "minimap_camera_viewport_indicator",
      "v0128MicroOnboardingPass",
      "oneInstructionAtATime",
      "onboardingNoSpam",
      "privateSkipOptionAvailable",
      "v0128ObjectiveFeedbackPass",
      "objectiveCompletePulseRendered",
      "pressureWaveNoticeRendered",
      "lumeActivationNoticeRendered",
      "notificationFloodPrevented",
      "restartActionRendered",
      "returnTitleActionRendered"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0128ArtifactRoot",
      "v0128ScreenshotRoot",
      "PASS_V0128_HUD_MINIMAP_ONBOARDING_CAPTURE",
      "PASS_V0128_PLAYER_FACING_HUD",
      "PASS_V0128_MINIMAP_READABILITY",
      "PASS_V0128_MICRO_ONBOARDING",
      "PASS_V0128_OBJECTIVE_FEEDBACK",
      "hud-report.json",
      "minimap-report.json",
      "micro-onboarding-report.json",
      "objective-feedback-report.json",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated",
      "routineEditorUseRequired",
      "stableIdsChanged",
      "saveWritesAllowed",
      "fullPortStarted"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(handoff).toContain("v0.128 Godot Player-Facing HUD Minimap Objective Feedback");
    expect(roadmap).toContain("v0.128 Godot Player-Facing HUD Minimap Objective Feedback");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.129 bounded hero-worker-mine-build-recruit microloop proof", async () => {
    [
      "docs/V0129_VERTICAL_SLICE_MICROLOOP_SPEC.md",
      "docs/V0129_HERO_WORKER_MINE_BUILD_RECRUIT_REPORT.md",
      "docs/V0129_DATA_ADAPTER_REPORT.md",
      "docs/V0129_PERFORMANCE_SMOKE_REPORT.md",
      "docs/V0129_VISUAL_CAPTURE_REPORT.md",
      "docs/V0129_IMPLEMENTATION_REPORT.md",
      "docs/V0129_EMMANUEL_REVIEW_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene2d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_2d.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const runtime = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotPlayerSliceWindows.ps1", "utf8");
    const validateScript = await readFile("tools/godot/validateGodotPlayerSlice.ps1", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    [
      "mine_uncaptured",
      "mine_converted",
      "worker_assigned_mine",
      "build_placement",
      "construction_progress",
      "barracks_complete",
      "recruit_queue",
      "militia_spawned",
      "ashen_pressure_wave",
      "lume_restore",
      "run_v0129_microloop_fixture"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "capture_mine_site",
      "assign_worker_to_mine",
      "advance_resource_production",
      "place_barracks_placeholder",
      "advance_construction",
      "queue_militia_recruit",
      "complete_recruit_queue",
      "queue_ranger_recruit",
      "trigger_pressure_wave",
      "defeat_pressure_wave",
      "restore_lume_microloop",
      "PASS_V0129_MICROLOOP_FIXTURE",
      "saveWritesAllowed",
      "stableIdsChanged",
      "browserRuntimeChanged",
      "generatedOrImportedArtIncluded",
      "routineEditorUseRequired"
    ].forEach((text) => expect(runtime).toContain(text));

    [
      "v0129MicroloopPass",
      "v0129HeroMovementSelectionAbilityPass",
      "v0129MineWorkerProductionPass",
      "v0129BuildRecruitPass",
      "v0129PressureWaveResultsPass",
      "mineConversionFeedbackRendered",
      "workerMineAssignmentFeedbackRendered",
      "boostedResourceFeedbackRendered",
      "barracksBuildPlacementRendered",
      "constructionProgressRendered",
      "recruitQueueRendered",
      "militiaSpawnedRendered",
      "pressureWaveDefeatedRendered",
      "lumeRestoreMicroloopRendered"
    ].forEach((text) => expect(scene3d).toContain(text));

    expect(scene2d).toContain("run_v0129_microloop_fixture");
    expect(scene2d).toContain("v0129MicroloopPass");

    [
      "v0129ArtifactRoot",
      "v0129ScreenshotRoot",
      "PASS_V0129_PLAYER_SLICE_MICROLOOP_VALIDATION",
      "PASS_V0129_VERTICAL_SLICE_MICROLOOP_CAPTURE",
      "PASS_V0129_HERO_WORKER_MINE_BUILD_RECRUIT_MICROLOOP",
      "PASS_V0129_DATA_ADAPTER_POSTURE",
      "PASS_V0129_PERFORMANCE_SMOKE",
      "player-slice-validate-v0129",
      "player-slice-capture-v0129",
      "data-adapter-report.json",
      "performance-smoke-report.json",
      "microloop-report.json",
      "saveWritesAllowed",
      "stableIdsChanged",
      "browserRuntimeChanged",
      "fullPortStarted"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(captureScript).toContain("godot-salto\\v0129");
    expect(captureScript).toContain("11 PNG captures");
    expect(captureScript).toContain("player-slice-capture-v0129");
    expect(validateScript).toContain("godot-salto\\v0129");
    expect(validateScript).toContain("player-slice-validate-v0129");
    expect(handoff).toContain("v0.129 Godot bounded hero-worker-mine-build-recruit microloop");
    expect(roadmap).toContain("v0.129 Godot Bounded Hero-Worker-Mine-Build-Recruit Microloop");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.130 vertical-slice acceptance pack and reference-art review boundary", async () => {
    [
      "docs/V0130_SALTO_VERTICAL_SLICE_ACCEPTANCE_GATE.md",
      "docs/V0130_FINAL_HUMAN_REVIEW_BUILD_REPORT.md",
      "docs/V0130_FIRST_REFERENCE_ART_GENERATION_SESSION.md",
      "docs/V0130_REFERENCE_ART_REVIEW_WORKFLOW.md",
      "docs/V0130_EMMANUEL_DECISION_PACKET.md",
      "docs/V0130_IMPLEMENTATION_REPORT.md",
      "GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat",
      "GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat",
      "GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat",
      "tools/godot/captureGodotSaltoVerticalSliceWindows.ps1",
      "tools/godot/validateGodotSaltoVerticalSliceWindows.ps1"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotSaltoVerticalSliceWindows.ps1", "utf8");
    const validateScript = await readFile("tools/godot/validateGodotSaltoVerticalSliceWindows.ps1", "utf8");
    const launchBat = await readFile("GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat", "utf8");
    const acceptanceGate = await readFile("docs/V0130_SALTO_VERTICAL_SLICE_ACCEPTANCE_GATE.md", "utf8");
    const referenceSession = await readFile("docs/V0130_FIRST_REFERENCE_ART_GENERATION_SESSION.md", "utf8");
    const reviewWorkflow = await readFile("docs/V0130_REFERENCE_ART_REVIEW_WORKFLOW.md", "utf8");
    const decisionPacket = await readFile("docs/V0130_EMMANUEL_DECISION_PACKET.md", "utf8");

    [
      "v0.130",
      "_is_bounded_microloop_checkpoint",
      "private_harness_preserved",
      "battle_default",
      "pressure_wave",
      "lume",
      "minimap"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "v0130ArtifactRoot",
      "v0130ScreenshotRoot",
      "SALTO_VERTICAL_SLICE_REVIEW_READY",
      "SALTO_VERTICAL_SLICE_REVIEW_AMBER",
      "SALTO_VERTICAL_SLICE_BLOCKED",
      "PASS_V0130_VERTICAL_SLICE_VALIDATION",
      "PASS_V0130_VERTICAL_SLICE_CAPTURE",
      "PASS_V0130_PERFORMANCE_SMOKE",
      "PASS_V0130_OBJECTIVE_FLOW",
      "PASS_V0130_PACKAGE_REPORT",
      "PASS_V0130_SCORECARD_UPDATE",
      "player-slice-validate-v0130",
      "player-slice-capture-v0130",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated",
      "saveWritesAllowed",
      "stableIdsChanged",
      "finalEngineDecisionMade",
      "fullPortStarted"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(captureScript).toContain("godot-salto\\v0130");
    expect(captureScript).toContain("15 PNG captures");
    expect(captureScript).toContain("player-slice-capture-v0130");
    expect(validateScript).toContain("godot-salto\\v0130");
    expect(validateScript).toContain("player-slice-validate-v0130");
    expect(launchBat).toContain("launchGodotPlayerSliceWindows.ps1");

    expect(acceptanceGate).toContain("Classification: `SALTO_VERTICAL_SLICE_REVIEW_READY`");
    expect(acceptanceGate).toContain("Private harness");
    expect(referenceSession).toContain("Generate only these four reference-only assets first");
    expect(referenceSession).toContain("docs/art-prompts/V0123_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md");
    expect(referenceSession).toContain("docs/art-prompts/V0123_08_HUD_STYLE_FRAME.md");
    expect(referenceSession).toContain("docs/art-prompts/V0123_02_BARROSAN_HERO_SILHOUETTE_SHEET.md");
    expect(referenceSession).toContain("docs/art-prompts/V0123_03_BARROSAN_WORKER_SILHOUETTE_SHEET.md");
    expect(reviewWorkflow).toContain("style-approved");
    expect(reviewWorkflow).toContain("runtime-integrated");
    expect(decisionPacket).toContain("Does the player-facing slice finally feel like a game foundation rather than a test harness?");
    expect(decisionPacket).toContain("Should the first four reference-art frames be generated?");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.131 real packaged-input human-playability gate", async () => {
    [
      "GODOT_REAL_INPUT_SMOKE_WINDOWS.bat",
      "GODOT_LAUNCH_PLAYABILITY_REVIEW_WINDOWS.bat",
      "tools/godot/runGodotRealInputSmokeWindows.ps1",
      "docs/V0131_REAL_INPUT_CONTRACT_AUDIT.md",
      "docs/V0131_FIRST_MINUTE_ONBOARDING_SPEC.md",
      "docs/V0131_HEADED_REAL_INPUT_PROOF.md",
      "docs/V0131_HUMAN_PLAYABILITY_GATE.md",
      "docs/V0131_IMPLEMENTATION_REPORT.md",
      "docs/V0131_EMMANUEL_RETEST_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const runtime = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotRealInputSmokeWindows.ps1", "utf8");
    const audit = await readFile("docs/V0131_REAL_INPUT_CONTRACT_AUDIT.md", "utf8");
    const gate = await readFile("docs/V0131_HUMAN_PLAYABILITY_GATE.md", "utf8");
    const proof = await readFile("docs/V0131_HEADED_REAL_INPUT_PROOF.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    ["godot:validate:real-input", "godot:headed:real-input-smoke"].forEach((script) =>
      expect(packageJson.scripts[script], script).toBeTypeOf("string")
    );

    [
      "--real-input-smoke",
      "run_real_input_smoke",
      "get_viewport().push_input",
      "PASS_HEADED_REAL_INPUT_SMOKE",
      "PASS_SELECTION_PROOF",
      "PASS_MOVEMENT_PROOF",
      "PASS_V0131_REAL_INPUT_SCREENSHOTS",
      "real-input-trace.json",
      "selection-proof.json",
      "movement-proof.json",
      "screenshot-manifest.json",
      "MOUSE_FILTER_PASS"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "_unhandled_input",
      "_handle_real_mouse_motion",
      "_handle_real_mouse_button",
      "_pick_unit_from_screen",
      "_screen_to_ground",
      "_finish_real_box_select",
      "_issue_real_order",
      "real_input_aster_selected",
      "real_input_worker_selected",
      "real_input_squad_box_selected",
      "real_input_move_order_accepted",
      "real_input_objective_advanced",
      "aster_focus_pulse",
      "aster_objective_arrow",
      "move_destination_pulse",
      "linkedWardDamageTakenMultiplier",
      "saveWritesAllowed"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "clear_selection",
      "select_units_by_ids",
      "advance_live_frame",
      "has_active_movement",
      "unit_has_destination",
      "apply_player_facing_staging"
    ].forEach((text) => expect(runtime).toContain(text));

    [
      "v0131ArtifactRoot",
      "v0131ScreenshotRoot",
      "validateV0131RealInputArtifacts",
      "PASS_V0131_REAL_INPUT_VALIDATION",
      "PASS_HEADED_REAL_INPUT_SMOKE",
      "PASS_SELECTION_PROOF",
      "PASS_MOVEMENT_PROOF",
      "PASS_V0131_REAL_INPUT_SCREENSHOTS",
      "real-input-v0131",
      "debugShortcutUsed",
      "stateInjectionUsed",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--real-input-smoke");
    expect(smokeScript).toContain("real-input-v0131");
    expect(smokeScript).toContain("launchGodotReviewWindows.ps1");
    expect(smokeScript).toContain("v0131");

    expect(audit).toContain("Control node consuming mouse events");
    expect(audit).toContain("unit movement not updating");
    expect(audit).toContain("private harness");
    expect(gate).toContain("Classification: `HUMAN_PLAYABILITY_GREEN`");
    expect(gate).toContain("No debug shortcut");
    expect(gate).toContain("Zero-editor");
    expect(proof).toContain("PASS_HEADED_REAL_INPUT_SMOKE");
    expect(proof).toContain("real-input-trace.json");
    expect(handoff).toContain("v0.131 Godot Player-Control Emergency Repair");
    expect(roadmap).toContain("v0.131 Godot Player-Control Emergency Repair");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.132 West Stone Cut Mine site-semantics and Worker guidance repair", async () => {
    [
      "GODOT_SITE_SEMANTICS_SMOKE_WINDOWS.bat",
      "GODOT_LAUNCH_SITE_GUIDANCE_REVIEW_WINDOWS.bat",
      "tools/godot/runGodotSiteSemanticsSmokeWindows.ps1",
      "docs/V0132_SITE_SEMANTICS_AUDIT.md",
      "docs/V0132_CANONICAL_SITE_COPY_LEDGER.md",
      "docs/V0132_OBJECTIVE_STATE_MONOTONICITY_AUDIT.md",
      "docs/V0132_MINE_CONVERSION_GUIDANCE_SPEC.md",
      "docs/V0132_WORKER_ASSIGNMENT_GUIDANCE_SPEC.md",
      "docs/V0132_MINIMAP_SITE_SEMANTICS_SPEC.md",
      "docs/V0132_HEADED_SITE_SEMANTICS_PROOF.md",
      "docs/V0132_SITE_GUIDANCE_GATE.md",
      "docs/V0132_IMPLEMENTATION_REPORT.md",
      "docs/V0132_EMMANUEL_RETEST_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotSiteSemanticsSmokeWindows.ps1", "utf8");
    const copyLedger = await readFile("docs/V0132_CANONICAL_SITE_COPY_LEDGER.md", "utf8");
    const monotonicity = await readFile("docs/V0132_OBJECTIVE_STATE_MONOTONICITY_AUDIT.md", "utf8");
    const gate = await readFile("docs/V0132_SITE_GUIDANCE_GATE.md", "utf8");
    const proof = await readFile("docs/V0132_HEADED_SITE_SEMANTICS_PROOF.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    ["godot:validate:site-semantics", "godot:headed:site-semantics-smoke"].forEach((script) =>
      expect(packageJson.scripts[script], script).toBeTypeOf("string")
    );

    [
      "--site-semantics-smoke",
      "run_site_semantics_smoke",
      "PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE",
      "PASS_V0132_SITE_SEMANTICS_SCREENSHOTS",
      "site-semantics-trace.json",
      "mine-conversion-proof.json",
      "worker-assignment-proof.json",
      "objective-monotonicity.json"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "WEST_STONE_CUT_MINE_LABEL",
      "West Stone Cut Mine",
      "SITE_STATE_NEUTRAL",
      "SITE_STATE_OBJECTIVE_TARGET",
      "SITE_STATE_CONVERTING",
      "SITE_STATE_CONTROLLED",
      "SITE_STATE_WORKER_ASSIGNED",
      "site_semantics_status",
      "_advance_v0132_site_semantics",
      "_destination_is_mine",
      "_complete_v0132_worker_assignment",
      "west_stone_cut_mine_objective_ring",
      "west_stone_cut_conversion_bar",
      "west_stone_cut_control_banner",
      "Right-click the controlled mine.",
      "objectiveRegressionBlockedCount",
      "actualObjectiveRegressionDetected"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0132ArtifactRoot",
      "v0132ScreenshotRoot",
      "validateV0132SiteSemanticsArtifacts",
      "PASS_V0132_SITE_SEMANTICS_VALIDATION",
      "PASS_MINE_CONVERSION_PROOF",
      "PASS_WORKER_ASSIGNMENT_PROOF",
      "PASS_OBJECTIVE_MONOTONICITY_PROOF",
      "site-semantics-v0132",
      "West Stone Cut Mine",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--site-semantics-smoke");
    expect(smokeScript).toContain("site-semantics-v0132");
    expect(smokeScript).toContain("v0132");

    expect(copyLedger).toContain("Canonical player-facing target: `West Stone Cut Mine`");
    expect(monotonicity).toContain("Actual objective regression: `false`");
    expect(gate).toContain("Classification: `SITE_GUIDANCE_GREEN`");
    expect(proof).toContain("PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE");
    expect(handoff).toContain("v0.132 Godot Site Semantics");
    expect(roadmap).toContain("v0.132 Godot Site Semantics");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.133 post-mine Barracks, recruit, Ashen wave, and Lume proof gate", async () => {
    [
      "GODOT_POST_MINE_FLOW_SMOKE_WINDOWS.bat",
      "GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat",
      "tools/godot/runGodotPostMineFlowSmokeWindows.ps1",
      "docs/V0133_POST_MINE_OBJECTIVE_STATE_MACHINE_AUDIT.md",
      "docs/V0133_OBJECTIVE_PREREQUISITE_LEDGER.md",
      "docs/V0133_BARRACKS_RESTORATION_GUIDANCE_SPEC.md",
      "docs/V0133_MILITIA_RECRUIT_GUIDANCE_SPEC.md",
      "docs/V0133_ASHEN_PRESSURE_COUNTDOWN_SPEC.md",
      "docs/V0133_COMBAT_ONSET_SPEC.md",
      "docs/V0133_LUME_RESTORE_GUIDANCE_SPEC.md",
      "docs/V0133_HEADED_POST_MINE_FLOW_PROOF.md",
      "docs/V0133_POST_MINE_FLOW_GATE.md",
      "docs/V0133_IMPLEMENTATION_REPORT.md",
      "docs/V0133_EMMANUEL_RETEST_GUIDE.md",
      "docs/V0133_TEST11_RECORDING_COMBAT_READABILITY_REPAIR.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const runtime = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotPostMineFlowSmokeWindows.ps1", "utf8");
    const gate = await readFile("docs/V0133_POST_MINE_FLOW_GATE.md", "utf8");
    const proof = await readFile("docs/V0133_HEADED_POST_MINE_FLOW_PROOF.md", "utf8");
    const test11Repair = await readFile("docs/V0133_TEST11_RECORDING_COMBAT_READABILITY_REPAIR.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    ["godot:validate:post-mine-flow", "godot:headed:post-mine-flow-smoke"].forEach((script) =>
      expect(packageJson.scripts[script], script).toBeTypeOf("string")
    );

    [
      "--post-mine-flow-smoke",
      "run_post_mine_flow_smoke",
      "PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE",
      "PASS_V0133_POST_MINE_FLOW_SCREENSHOTS",
      "headed-post-mine-flow-smoke.json",
      "post-mine-trace.json",
      "objective-prerequisite-report.json",
      "barracks-restoration-proof.json",
      "militia-recruit-proof.json",
      "pressure-countdown-proof.json",
      "wave-launch-proof.json",
      "combat-onset-proof.json",
      "wave-defeat-proof.json",
      "lume-restore-proof.json"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "post_mine_flow_status",
      "_advance_v0133_post_mine_flow",
      "_v0133_objective_prerequisites_met",
      "_start_v0133_barracks_restoration",
      "_queue_v0133_militia_from_input",
      "_restore_v0133_lume_from_input",
      "_try_handle_v0133_hud_attack_mouse",
      "_prepare_v0133_combat_handoff",
      "issue_player_facing_wave_defense_order",
      "_screen_hits_v0133_attack_button",
      "combat_defender_handoff",
      "box_select_empty_preserved_defenders",
      "hud_attack_scaled_click",
      "waveDefenseOrder",
      "hud_attack_raw_click",
      "visible_unit",
      "reviewHidden",
      "v0133_box_select_no_skip_proven",
      "Wave: %s left",
      "waveTriggerSource",
      "fixtureOnlyHelperProofUsed"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "advance_pressure_wave_frame",
      "restore_lume_from_player_input",
      "stage_player_facing_pressure_wave_lane",
      "player_wave_defense_order_active",
      "player_wave_defense_wave_ids",
      "player_wave_defense_defender_ids",
      "_seed_player_wave_defense_pressure",
      "Vector2(-10000",
      "reviewHidden",
      "unit_alive",
      "LINKED_WARD_DAMAGE_TAKEN_MULTIPLIER"
    ].forEach((text) => expect(runtime).toContain(text));

    [
      "v0133ArtifactRoot",
      "v0133ScreenshotRoot",
      "validateV0133PostMineFlowArtifacts",
      "PASS_V0133_POST_MINE_FLOW_VALIDATION",
      "post-mine-flow-v0133",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--post-mine-flow-smoke");
    expect(smokeScript).toContain("post-mine-flow-v0133");
    expect(smokeScript).toContain("v0133");

    expect(gate).toContain("Classification: `POST_MINE_FLOW_GREEN`");
    expect(proof).toContain("PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE");
    expect(proof).toContain("post-mine-trace.json");
    expect(proof).toContain("Salto Review Complete");
    expect(proof).toContain("combat handoff");
    expect(test11Repair).toContain("Recording 2026-06-05 test11.mp4");
    expect(test11Repair).toContain("combat_defender_handoff");
    expect(test11Repair).toContain("box_select_empty_preserved_defenders");
    expect(handoff).toContain("v0.133 Godot Post-Mine Sequence Repair");
    expect(roadmap).toContain("v0.133.1 Godot Test11 Combat Readability Repair");
    expect(rootScript).not.toContain("Convert Mine | Assign Worker | Restore Barracks | Train Militia | Restore Lume");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.134 repeatable natural playthrough and soft-lock resilience gate", async () => {
    [
      "GODOT_TRIPLE_NATURAL_PLAYTHROUGH_WINDOWS.bat",
      "tools/godot/runGodotTripleNaturalPlaythroughWindows.ps1",
      "docs/V0134_REPEATABLE_NATURAL_PLAYTHROUGH_SPEC.md",
      "docs/V0134_RECOVERY_CASE_LEDGER.md",
      "docs/V0134_RESTART_INTEGRITY_REPORT.md",
      "docs/V0134_REPEATABLE_PLAYTHROUGH_GATE.md",
      "docs/V0134_IMPLEMENTATION_REPORT.md",
      "docs/V0134_EMMANUEL_RETEST_GUIDE.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const runtime = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotTripleNaturalPlaythroughWindows.ps1", "utf8");
    const gate = await readFile("docs/V0134_REPEATABLE_PLAYTHROUGH_GATE.md", "utf8");
    const recovery = await readFile("docs/V0134_RECOVERY_CASE_LEDGER.md", "utf8");
    const restart = await readFile("docs/V0134_RESTART_INTEGRITY_REPORT.md", "utf8");
    const guide = await readFile("docs/V0134_EMMANUEL_RETEST_GUIDE.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    expect(packageJson.scripts["godot:headed:triple-natural-playthrough"]).toBeTypeOf("string");

    [
      "--triple-natural-playthrough",
      "run_triple_natural_playthrough_smoke",
      "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH",
      "PASS_V0134_RECOVERY_CASES",
      "PASS_V0134_RESTART_INTEGRITY",
      "PASS_V0134_NO_SOFTLOCK_PROOF",
      "PASS_V0134_NO_SHORTCUT_PROOF",
      "triple-playthrough-report.json",
      "recovery-case-report.json",
      "restart-integrity-report.json",
      "no-softlock-proof.json",
      "no-shortcut-proof.json",
      "scriptedObjectiveSkippingUsed",
      "fixtureOnlyHelperProofUsed"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "v0134_recovery_feedback_ids",
      "empty_terrain_before_aster",
      "no_selection_move_rejected",
      "friendly_right_click_ignored",
      "select_worker_before_barracks",
      "attack_no_selection_auto_recover",
      "attack_button",
      "v0134RecoveryFeedbackIds",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(scene3d).toContain(text));

    expect(runtime).toContain("if militia_spawned or militia_recruit_queued or not recruit_queue.is_empty()");
    expect(runtime).toContain("if pressure_wave_state == \"active\" or pressure_wave_defeated");

    [
      "v0134ArtifactRoot",
      "v0134ScreenshotRoot",
      "validateV0134TripleNaturalPlaythroughArtifacts",
      "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH_VALIDATION",
      "triple-natural-playthrough-v0134",
      "scriptedObjectiveSkippingUsed",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--triple-natural-playthrough");
    expect(smokeScript).toContain("triple-natural-playthrough-v0134");
    expect(smokeScript).toContain("v0134");

    expect(gate).toContain("Classification: `GREEN`");
    expect(gate).toContain("Gate: `REPEATABLE_PLAYTHROUGH_GREEN`");
    expect(gate).toContain("Three natural packaged-window playthroughs");
    expect(recovery).toContain("empty terrain before Aster");
    expect(recovery).toContain("Attack with no valid selection");
    expect(restart).toContain("No duplicate wave or Militia spawn");
    expect(guide).toContain("GODOT_TRIPLE_NATURAL_PLAYTHROUGH_WINDOWS.bat");
    expect(handoff).toContain("v0.134 Godot Repeatable Natural Playthrough");
    expect(roadmap).toContain("v0.134 Godot Repeatable Natural Playthrough");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.135 RTS input ergonomics, recoverable feedback, and camera-control pass", async () => {
    [
      "GODOT_RTS_ERGONOMICS_SMOKE_WINDOWS.bat",
      "tools/godot/runGodotRtsErgonomicsSmokeWindows.ps1",
      "docs/V0135_RTS_INPUT_CONTRACT.md",
      "docs/V0135_ORDER_FEEDBACK_SPEC.md",
      "docs/V0135_CAMERA_CONTROL_SPEC.md",
      "docs/V0135_COMPACT_HELP_SPEC.md",
      "docs/V0135_RTS_ERGONOMICS_GATE.md",
      "docs/V0135_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotRtsErgonomicsSmokeWindows.ps1", "utf8");
    const v0134Gate = await readFile("docs/V0134_REPEATABLE_PLAYTHROUGH_GATE.md", "utf8");
    const v0135Gate = await readFile("docs/V0135_RTS_ERGONOMICS_GATE.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    expect(v0134Gate).toContain("Gate: `REPEATABLE_PLAYTHROUGH_GREEN`");
    expect(packageJson.scripts["godot:headed:rts-ergonomics-smoke"]).toBeTypeOf("string");

    [
      "--rts-ergonomics-smoke",
      "run_rts_ergonomics_smoke",
      "PASS_V0135_HEADED_RTS_ERGONOMICS_SMOKE",
      "PASS_V0135_RTS_INPUT_CONTRACT",
      "PASS_V0135_ORDER_FEEDBACK",
      "PASS_V0135_CAMERA_CONTROL",
      "PASS_V0135_COMPACT_HELP",
      "PASS_V0135_SCREENSHOT_MANIFEST",
      "headed-rts-ergonomics-smoke.json",
      "rts-input-contract.json",
      "order-feedback-report.json",
      "camera-control-report.json",
      "compact-help-report.json",
      "rts-ergonomics-trace.json",
      "screenshot-manifest.json"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "_handle_real_keyboard",
      "set_controls_help_visible",
      "toggle_controls_help",
      "focus_aster_from_input",
      "rts_ergonomics_status",
      "CompactControlsHelpButton",
      "mouseWheelZoom",
      "keyboardCameraPan",
      "spaceFocusAster",
      "escapeRecoverable",
      "invalidOrderMarker",
      "selectedSquadCount",
      "minimapViewportIndicator",
      "linkedWardDamageTakenMultiplier",
      "saveWritesAllowed"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0135ArtifactRoot",
      "v0135ScreenshotRoot",
      "validateV0135RtsErgonomicsArtifacts",
      "PASS_V0135_RTS_ERGONOMICS_VALIDATION",
      "rts-ergonomics-v0135",
      "PASS_V0135_HEADED_RTS_ERGONOMICS_SMOKE",
      "PASS_V0135_RTS_INPUT_CONTRACT",
      "PASS_V0135_ORDER_FEEDBACK",
      "PASS_V0135_CAMERA_CONTROL",
      "PASS_V0135_COMPACT_HELP",
      "PASS_V0135_SCREENSHOT_MANIFEST",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--rts-ergonomics-smoke");
    expect(smokeScript).toContain("rts-ergonomics-v0135");
    expect(smokeScript).toContain("v0135");

    expect(v0135Gate).toContain("Classification: `RTS_ERGONOMICS_GREEN`");
    expect(v0135Gate).toContain("RTS_ERGONOMICS_AMBER");
    expect(v0135Gate).toContain("RTS_ERGONOMICS_RED");
    expect(v0135Gate).toContain("PASS_V0135_HEADED_RTS_ERGONOMICS_SMOKE");
    expect(handoff).toContain("v0.135 Godot RTS Input Ergonomics");
    expect(roadmap).toContain("v0.135 Godot RTS Input Ergonomics");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.136 HUD, minimap, onboarding, and microloop-pacing cleanup", async () => {
    [
      "GODOT_USABILITY_PRESENTATION_WINDOWS.bat",
      "tools/godot/runGodotUsabilityPresentationWindows.ps1",
      "docs/V0136_HUD_HIERARCHY_SPEC.md",
      "docs/V0136_MINIMAP_REFINEMENT_SPEC.md",
      "docs/V0136_ONBOARDING_COPY_LEDGER.md",
      "docs/V0136_MICROLOOP_PACING_REPORT.md",
      "docs/V0136_USABILITY_PRESENTATION_GATE.md",
      "docs/V0136_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotUsabilityPresentationWindows.ps1", "utf8");
    const v0135Gate = await readFile("docs/V0135_RTS_ERGONOMICS_GATE.md", "utf8");
    const v0136Gate = await readFile("docs/V0136_USABILITY_PRESENTATION_GATE.md", "utf8");
    const hudSpec = await readFile("docs/V0136_HUD_HIERARCHY_SPEC.md", "utf8");
    const minimapSpec = await readFile("docs/V0136_MINIMAP_REFINEMENT_SPEC.md", "utf8");
    const onboardingLedger = await readFile("docs/V0136_ONBOARDING_COPY_LEDGER.md", "utf8");
    const pacingReport = await readFile("docs/V0136_MICROLOOP_PACING_REPORT.md", "utf8");
    const implementation = await readFile("docs/V0136_IMPLEMENTATION_REPORT.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    expect(v0135Gate).toContain("RTS_ERGONOMICS_GREEN");
    expect(packageJson.scripts["godot:headed:usability-presentation"]).toBeTypeOf("string");

    [
      "--usability-presentation-smoke",
      "run_usability_presentation_smoke",
      "PASS_V0136_HEADED_USABILITY_PRESENTATION_SMOKE",
      "PASS_V0136_HUD_HIERARCHY",
      "PASS_V0136_MINIMAP_REFINEMENT",
      "PASS_V0136_ONBOARDING_COPY",
      "PASS_V0136_MICROLOOP_PACING",
      "PASS_V0136_SCREENSHOT_MANIFEST",
      "headed-usability-presentation-smoke.json",
      "hud-hierarchy-report.json",
      "minimap-refinement-report.json",
      "onboarding-copy-report.json",
      "microloop-pacing-report.json",
      "usability-presentation-trace.json",
      "screenshot-manifest.json",
      "minimap_click_to_orient",
      "fixtureOnlyHelperProofUsed"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "usability_presentation_status",
      "V0132_CONVERSION_PROGRESS_PER_SECOND := 24.0",
      "V0133_CONSTRUCTION_FRAMES_PER_SECOND := 24",
      "V0133_RECRUIT_FRAMES_PER_SECOND := 24",
      "V0133_PRESSURE_COUNTDOWN_SECONDS := 7.0",
      "HudCurrentObjectiveStrip",
      "ObjectiveSummaryCompact",
      "MicroOnboardingPrompt",
      "minimap_worker_marker",
      "minimap_barracks_marker",
      "minimap_active_ashen_attackers",
      "minimap_west_stone_cut_mine_control",
      "minimap_camera_viewport_indicator",
      "minimapClickToOrient",
      "canonicalOnboardingCopy",
      "noTopPauseChrome",
      "pacingTuned",
      "resultsRecap",
      "Right-click West Stone Cut Mine.",
      "Select defenders and attack marked Ashen units.",
      "saveWritesAllowed",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0136ArtifactRoot",
      "v0136ScreenshotRoot",
      "validateV0136UsabilityPresentationArtifacts",
      "PASS_V0136_USABILITY_PRESENTATION_VALIDATION",
      "usability-presentation-v0136",
      "PASS_V0136_HEADED_USABILITY_PRESENTATION_SMOKE",
      "PASS_V0136_HUD_HIERARCHY",
      "PASS_V0136_MINIMAP_REFINEMENT",
      "PASS_V0136_ONBOARDING_COPY",
      "PASS_V0136_MICROLOOP_PACING",
      "PASS_V0136_SCREENSHOT_MANIFEST",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--usability-presentation-smoke");
    expect(smokeScript).toContain("usability-presentation-v0136");
    expect(smokeScript).toContain("v0136");

    expect(v0136Gate).toContain("Classification: `USABILITY_PRESENTATION_GREEN`");
    expect(v0136Gate).toContain("Gate: `USABILITY_PRESENTATION_GREEN`");
    expect(v0136Gate).toContain("USABILITY_PRESENTATION_AMBER");
    expect(v0136Gate).toContain("USABILITY_PRESENTATION_RED");
    expect(v0136Gate).toContain("PASS_V0136_HEADED_USABILITY_PRESENTATION_SMOKE");
    expect(hudSpec).toContain("one primary objective line");
    expect(minimapSpec).toContain("click-to-orient");
    expect(onboardingLedger).toContain("Right-click West Stone Cut Mine.");
    expect(pacingReport).toContain("3-5 minute");
    expect(implementation).toContain("No art import");
    expect(handoff).toContain("v0.136 Godot HUD, Minimap, Onboarding");
    expect(roadmap).toContain("v0.136 Godot HUD, Minimap, Onboarding");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.137 procedural visual blockout quality upgrade", async () => {
    [
      "GODOT_BLOCKOUT_QUALITY_WINDOWS.bat",
      "tools/godot/runGodotBlockoutQualityWindows.ps1",
      "docs/V0137_PROCEDURAL_COMPOSITION_SPEC.md",
      "docs/V0137_SILHOUETTE_REFINEMENT_SPEC.md",
      "docs/V0137_LIGHTING_VFX_SPEC.md",
      "docs/V0137_PERFORMANCE_SAFETY_REPORT.md",
      "docs/V0137_BLOCKOUT_QUALITY_GATE.md",
      "docs/V0137_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const scene3d = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const toolScript = await readFile("desktop-spikes/godot-salto/tools/godotSpikeTool.mjs", "utf8");
    const smokeScript = await readFile("tools/godot/runGodotBlockoutQualityWindows.ps1", "utf8");
    const v0136Gate = await readFile("docs/V0136_USABILITY_PRESENTATION_GATE.md", "utf8");
    const v0137Gate = await readFile("docs/V0137_BLOCKOUT_QUALITY_GATE.md", "utf8");
    const compositionSpec = await readFile("docs/V0137_PROCEDURAL_COMPOSITION_SPEC.md", "utf8");
    const silhouetteSpec = await readFile("docs/V0137_SILHOUETTE_REFINEMENT_SPEC.md", "utf8");
    const lightingSpec = await readFile("docs/V0137_LIGHTING_VFX_SPEC.md", "utf8");
    const performanceReport = await readFile("docs/V0137_PERFORMANCE_SAFETY_REPORT.md", "utf8");
    const implementation = await readFile("docs/V0137_IMPLEMENTATION_REPORT.md", "utf8");
    const handoff = await readFile("LLM_GAME_HANDOFF.md", "utf8");
    const roadmap = await readFile("ROADMAP.md", "utf8");

    expect(v0136Gate).toContain("USABILITY_PRESENTATION_GREEN");
    expect(packageJson.scripts["godot:headed:blockout-quality"]).toBeTypeOf("string");

    [
      "--blockout-quality-smoke",
      "run_blockout_quality_smoke",
      "PASS_V0137_HEADED_BLOCKOUT_QUALITY_SMOKE",
      "PASS_V0137_COMPOSITION_READABILITY",
      "PASS_V0137_SILHOUETTE_READABILITY",
      "PASS_V0137_LIGHTING_VFX",
      "PASS_V0137_PERFORMANCE_SMOKE",
      "PASS_V0137_SCREENSHOT_MANIFEST",
      "blockout-quality-trace.json",
      "blockout-comparison.md",
      "performance-smoke.json",
      "screenshot-manifest.json",
      "fixtureOnlyHelperProofUsed",
      "screenshotOnlyProofUsed"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "blockout_quality_status",
      "v0137_salto_foothold_silhouette_ridge_face",
      "v0137_wet_granite_road_slab_01",
      "v0137_side_path_to_barracks",
      "v0137_ford_stepping_stone_a",
      "v0137_cool_water_edge_west_bank",
      "v0137_quarry_mine_cut_shadow_depth",
      "v0137_shrine_clearing_ring_north",
      "v0137_ruin_pocket_broken_arch",
      "v0137_barracks_footprint_chalk",
      "v0137_friendly_staging_banner_line",
      "v0137_ashen_approach_lane_char",
      "v0137_lume_path_severed_segment_a",
      "v0137_aster_back_cloak_profile",
      "v0137_worker_low_pick_silhouette",
      "v0137_militia_square_tabard",
      "v0137_ranger_hood_peak",
      "v0137_ashen_raider_leaning_crest",
      "v0137_subtle_terrain_fog_default",
      "PASS_V0137_BLOCKOUT_QUALITY_SCENE_STATUS",
      "linkedWardDamageTakenMultiplier"
    ].forEach((text) => expect(scene3d).toContain(text));

    [
      "v0137ArtifactRoot",
      "v0137ScreenshotRoot",
      "validateV0137BlockoutQualityArtifacts",
      "PASS_V0137_BLOCKOUT_QUALITY_VALIDATION",
      "blockout-quality-v0137",
      "PASS_V0137_HEADED_BLOCKOUT_QUALITY_SMOKE",
      "PASS_V0137_SCREENSHOT_HASHES",
      "screenshot-hashes.json",
      "blockout-comparison.md"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(smokeScript).toContain("--blockout-quality-smoke");
    expect(smokeScript).toContain("blockout-quality-v0137");
    expect(smokeScript).toContain("v0137");

    expect(v0137Gate).toContain("Classification: `BLOCKOUT_QUALITY_GREEN`");
    expect(v0137Gate).toContain("Gate: `BLOCKOUT_QUALITY_GREEN`");
    expect(v0137Gate).toContain("BLOCKOUT_QUALITY_AMBER");
    expect(v0137Gate).toContain("BLOCKOUT_QUALITY_RED");
    expect(compositionSpec).toContain("wet-granite road");
    expect(silhouetteSpec).toContain("geometry differentiation");
    expect(lightingSpec).toContain("no particle spaghetti");
    expect(performanceReport).toContain("screenshot capture excluded");
    expect(implementation).toContain("No art import");
    expect(handoff).toContain("v0.137 Godot Procedural Visual Composition");
    expect(roadmap).toContain("v0.137 Godot Procedural Visual Composition");

    expect(rootScript).not.toContain("load(\"res://assets");
    expect(scene3d).not.toContain("load(\"res://assets");
    expect(toolScript).not.toContain("ImageTexture");
  });

  it("defines the v0.146 isolated runtime-art pipeline comparator spike and review stop", async () => {
    [
      "GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat",
      "tools/godot/runtimeArtComparatorTool.mjs",
      "tools/godot/runGodotRuntimeArtComparatorValidation.ps1",
      "tools/godot/runGodotRuntimeArtComparatorBenchmarkWindows.ps1",
      "tools/godot/captureGodotRuntimeArtComparatorWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.tscn",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd",
      "docs/V0146_RUNTIME_ART_PIPELINE_COMPARATOR_SPEC.md",
      "docs/V0146_RUNTIME_ART_PIPELINE_BENCHMARK_REPORT.md",
      "docs/V0146_RUNTIME_ART_PIPELINE_SCORECARD.md",
      "docs/V0146_RUNTIME_ART_PIPELINE_RECOMMENDATION.md",
      "docs/V0146_EMMANUEL_RUNTIME_ART_PIPELINE_REVIEW_GUIDE.md",
      "docs/V0146_REFERENCE_ONLY_AND_COMPARATOR_BOUNDARY.md",
      "docs/V0146_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const project = await readFile("desktop-spikes/godot-salto/project.godot", "utf8");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/runtimeArtComparatorTool.mjs", "utf8");
    const comparatorLauncher = await readFile("GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const scorecard = await readFile("docs/V0146_RUNTIME_ART_PIPELINE_SCORECARD.md", "utf8");
    const recommendation = await readFile("docs/V0146_RUNTIME_ART_PIPELINE_RECOMMENDATION.md", "utf8");
    const boundary = await readFile("docs/V0146_REFERENCE_ONLY_AND_COMPARATOR_BOUNDARY.md", "utf8");
    const guide = await readFile("docs/V0146_EMMANUEL_RUNTIME_ART_PIPELINE_REVIEW_GUIDE.md", "utf8");
    const implementation = await readFile("docs/V0146_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:runtime-art-comparator:validate",
      "godot:runtime-art-comparator:benchmark:headed",
      "godot:runtime-art-comparator:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(project).toContain('run/main_scene="res://scenes/salto_spike_root.tscn"');
    expect(rootScript).toContain("--runtime-art-comparator");
    expect(rootScript).toContain("runtime_art_pipeline_comparator.gd");
    expect(rootScript).toContain("PASS_V0146_PRIVATE_COMPARATOR_DISPATCH");
    expect(rootScript).toContain("show_player_title");

    [
      "ORTHO_3D_MESH",
      "BILLBOARD_2D_ATLAS",
      "HYBRID_3D_WORLD_BILLBOARD_UNITS",
      "generatedReferenceImagesImported",
      "downloadedAssetsUsed",
      "normalPlayerSliceWired",
      "browserRuntimeWired",
      "finalEngineSelection"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "recommendedNextSingleSlotExperiment",
      "HYBRID_3D_WORLD_BILLBOARD_UNITS",
      "BILLBOARD_2D_ATLAS",
      "scorecard.md",
      "benchmark-summary.md",
      "contact-sheet.svg"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(comparatorLauncher).toContain("runGodotRuntimeArtComparatorBenchmarkWindows.ps1");
    expect(stabilizedLauncher).not.toContain("runtime-art-comparator");
    expect(stabilizedLauncher).not.toContain("runtime_art_pipeline");
    expect(playerLauncher).not.toContain("runtime-art-comparator");
    expect(playerLauncher).not.toContain("runtime_art_pipeline");

    expect(scorecard).toContain("HYBRID_3D_WORLD_BILLBOARD_UNITS");
    expect(recommendation).toContain("Recommend `HYBRID_3D_WORLD_BILLBOARD_UNITS`");
    expect(boundary).toContain("Generated reference image import");
    expect(boundary).toContain("Downloaded assets");
    expect(boundary).toContain("Normal Salto player-facing slice mutation");
    expect(guide).toContain("GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat");
    expect(implementation).toContain("No v0.147 work");
    expect(implementation).toContain("No final engine choice");
  });

  it("defines the v0.147 private Worker billboard single-slot experiment and review stop", async () => {
    [
      "GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
      "tools/godot/workerBillboardSingleSlotTool.mjs",
      "tools/godot/runGodotWorkerBillboardValidation.ps1",
      "tools/godot/runGodotWorkerBillboardFallbackReproducibility.ps1",
      "tools/godot/runGodotWorkerBillboardBenchmarkWindows.ps1",
      "tools/godot/captureGodotWorkerBillboardWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json",
      "docs/V0147_WORKER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
      "docs/V0147_WORKER_BILLBOARD_SLOT_CONTRACT.md",
      "docs/V0147_WORKER_BILLBOARD_VALIDATION_REPORT.md",
      "docs/V0147_WORKER_BILLBOARD_BENCHMARK_REPORT.md",
      "docs/V0147_WORKER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
      "docs/V0147_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0147_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const project = await readFile("desktop-spikes/godot-salto/project.godot", "utf8");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/workerBillboardSingleSlotTool.mjs", "utf8");
    const fallbackContract = await readJson<{
      browserIntegration: string;
      playerSliceIntegration: string;
      privateComparatorOnly: boolean;
      productionApproval: string;
      sha256: string;
      slotId: string;
    }>(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json"
    );
    const workerLauncher = await readFile("GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const benchmark = await readFile("docs/V0147_WORKER_BILLBOARD_BENCHMARK_REPORT.md", "utf8");
    const boundary = await readFile("docs/V0147_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const guide = await readFile("docs/V0147_WORKER_BILLBOARD_VISUAL_REVIEW_GUIDE.md", "utf8");
    const implementation = await readFile("docs/V0147_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:worker-billboard:validate",
      "godot:worker-billboard:fallback:reproduce",
      "godot:worker-billboard:benchmark:headed",
      "godot:worker-billboard:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(project).toContain('run/main_scene="res://scenes/salto_spike_root.tscn"');
    expect(rootScript).toContain("--worker-billboard-single-slot");
    expect(rootScript).toContain("worker_billboard_single_slot_comparator.gd");
    expect(rootScript).toContain("PASS_V0147_PRIVATE_WORKER_BILLBOARD_DISPATCH");
    expect(rootScript).toContain("show_player_title");

    [
      "worker_billboard_static_v0147",
      "HYBRID_DIAGNOSTIC_FALLBACK_BASELINE",
      "HYBRID_LOCAL_WORKER_SLOT",
      "ORTHO_3D_MESH_FALLBACK_COMPARATOR",
      "normalPlayerSliceWired",
      "existingReferenceCandidateImported",
      "downloadedAssetsUsed"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0147_WORKER_BILLBOARD_SLOT_VALIDATION",
      "PASS_V0147_WORKER_BILLBOARD_FALLBACK_REPRODUCIBILITY",
      "PASS_V0147_WORKER_BILLBOARD_EVIDENCE",
      "PASS_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD",
      "benchmark-summary.md",
      "threshold-report.json",
      "contact-sheet.svg",
      "exactlyOneGeneratedImageForV0147"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(fallbackContract.slotId).toBe("worker_billboard_static_v0147");
    expect(fallbackContract.sha256).toBe("fa60b6e6a86b41cb449c3a16a0401cf44fbab8b5faefd7f19147b3a8c6161419");
    expect(fallbackContract.privateComparatorOnly).toBe(true);
    expect(fallbackContract.productionApproval).toBe("forbidden");
    expect(fallbackContract.playerSliceIntegration).toBe("forbidden");
    expect(fallbackContract.browserIntegration).toBe("forbidden");

    expect(workerLauncher).toContain("runGodotWorkerBillboardBenchmarkWindows.ps1");
    expect(stabilizedLauncher).not.toContain("worker-billboard-single-slot");
    expect(stabilizedLauncher).not.toContain("worker_billboard_single_slot");
    expect(playerLauncher).not.toContain("worker-billboard-single-slot");
    expect(playerLauncher).not.toContain("worker_billboard_single_slot");

    expect(benchmark).toContain("FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD");
    expect(benchmark).toContain("single bounded repair pass");
    expect(boundary).toContain("No existing reference candidate import");
    expect(boundary).toContain("No browser runtime wiring");
    expect(guide).toContain("GODOT_WORKER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat");
    expect(implementation).toContain("Exactly one AI-generated image");
    expect(implementation).toContain("No v0.148 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.148 private Worker billboard repair benchmark and review stop", async () => {
    [
      "GODOT_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat",
      "tools/godot/workerBillboardSingleSlotTool.mjs",
      "tools/godot/runGodotWorkerBillboardRepairValidation.ps1",
      "tools/godot/runGodotWorkerBillboardRepairAudit.ps1",
      "tools/godot/runGodotWorkerBillboardRepairDerivatives.ps1",
      "tools/godot/runGodotWorkerBillboardRepairBenchmarkWindows.ps1",
      "tools/godot/captureGodotWorkerBillboardRepairWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json",
      "docs/V0148_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_SPEC.md",
      "docs/V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT.md",
      "docs/V0148_WORKER_BILLBOARD_DERIVATIVE_MATRIX.md",
      "docs/V0148_WORKER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md",
      "docs/V0148_WORKER_BILLBOARD_ALPHA_PIVOT_REVIEW_GUIDE.md",
      "docs/V0148_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0148_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/workerBillboardSingleSlotTool.mjs", "utf8");
    const repairLauncher = await readFile("GODOT_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const repairSpec = await readFile("docs/V0148_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_SPEC.md", "utf8");
    const fairPathAudit = await readFile("docs/V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT.md", "utf8");
    const derivativeMatrix = await readFile("docs/V0148_WORKER_BILLBOARD_DERIVATIVE_MATRIX.md", "utf8");
    const boundary = await readFile("docs/V0148_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0148_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:worker-billboard-repair:validate",
      "godot:worker-billboard-repair:audit",
      "godot:worker-billboard-repair:derivatives:reproduce",
      "godot:worker-billboard-repair:benchmark:headed",
      "godot:worker-billboard-repair:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(rootScript).toContain("--worker-billboard-single-slot-repair");
    expect(rootScript).toContain("worker_billboard_single_slot_comparator.gd");
    expect(rootScript).toContain("PASS_V0148_PRIVATE_WORKER_BILLBOARD_REPAIR_DISPATCH");
    expect(rootScript).toContain("show_player_title");

    [
      "HYBRID_WORKER_FULL_RES",
      "HYBRID_WORKER_TRIMMED_512",
      "HYBRID_WORKER_TRIMMED_768",
      "HYBRID_WORKER_TRIMMED_1024",
      "repair_sources",
      "texture_cache",
      "material_cache",
      "source_load_counts",
      "texture_create_counts",
      "material_create_counts",
      "steadyStateWarmupFrames",
      "initializationDurationMs",
      "normalPlayerSliceWired",
      "browserRuntimeWired"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "repair:derivatives",
      "repair:derivatives:check",
      "repair:validate",
      "repair:audit",
      "repair:report",
      "PASS_V0148_WORKER_BILLBOARD_DERIVATIVE_REPRODUCIBILITY",
      "PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE",
      "worker-billboard-repair-threshold-report.json",
      "worker-billboard-repair-fair-path-audit.json",
      "paired-benchmark-summary.md",
      "zeroNewAiImages"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(repairLauncher).toContain("godot:worker-billboard-repair:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("worker-billboard-single-slot-repair");
    expect(stabilizedLauncher).not.toContain("WORKER_BILLBOARD_SINGLE_SLOT_REPAIR");
    expect(playerLauncher).not.toContain("worker-billboard-single-slot-repair");
    expect(playerLauncher).not.toContain("WORKER_BILLBOARD_SINGLE_SLOT_REPAIR");

    expect(repairSpec).toContain("Generate zero new AI-generated images");
    expect(repairSpec).toContain("original acceptance gate");
    expect(fairPathAudit).toContain("No gate relaxation");
    expect(derivativeMatrix).toContain("worker_billboard_static_v0147_trimmed_1024.png");
    expect(boundary).toContain("No second runtime-art slot");
    expect(boundary).toContain("No existing reference candidate import");
    expect(boundary).toContain("No browser runtime wiring");
    expect(implementation).toContain("No v0.149 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.149 private Barrosan Barracks material single-slot intake and review stop", async () => {
    [
      "GODOT_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
      "tools/godot/barracksMaterialSingleSlotTool.mjs",
      "tools/godot/runGodotBarracksMaterialValidation.ps1",
      "tools/godot/runGodotBarracksMaterialFallbackReproducibility.ps1",
      "tools/godot/runGodotBarracksMaterialDerivatives.ps1",
      "tools/godot/runGodotBarracksMaterialAudit.ps1",
      "tools/godot/runGodotBarracksMaterialBenchmarkWindows.ps1",
      "tools/godot/captureGodotBarracksMaterialWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.contract.json",
      "docs/V0149_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_INTAKE_SPEC.md",
      "docs/V0149_BARROSAN_BARRACKS_MATERIAL_SLOT_CONTRACT.md",
      "docs/V0149_BARROSAN_BARRACKS_MATERIAL_FAIR_PATH_AUDIT.md",
      "docs/V0149_BARROSAN_BARRACKS_MATERIAL_DERIVATIVE_MATRIX.md",
      "docs/V0149_BARROSAN_BARRACKS_MATERIAL_PAIRED_BENCHMARK_REPORT.md",
      "docs/V0149_BARROSAN_BARRACKS_MATERIAL_VISUAL_REVIEW_GUIDE.md",
      "docs/V0149_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0149_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/barracksMaterialSingleSlotTool.mjs", "utf8");
    const launcher = await readFile(
      "GODOT_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
      "utf8"
    );
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const intakeSpec = await readFile("docs/V0149_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_INTAKE_SPEC.md", "utf8");
    const slotContract = await readFile("docs/V0149_BARROSAN_BARRACKS_MATERIAL_SLOT_CONTRACT.md", "utf8");
    const fairPathAudit = await readFile("docs/V0149_BARROSAN_BARRACKS_MATERIAL_FAIR_PATH_AUDIT.md", "utf8");
    const boundary = await readFile("docs/V0149_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0149_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:barracks-material:validate",
      "godot:barracks-material:fallback:reproduce",
      "godot:barracks-material:derivatives:reproduce",
      "godot:barracks-material:audit",
      "godot:barracks-material:benchmark:headed",
      "godot:barracks-material:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(rootScript).toContain("--barrosan-barracks-material-single-slot");
    expect(rootScript).toContain("barracks_material_single_slot_comparator.gd");
    expect(rootScript).toContain("PASS_V0149_PRIVATE_BARRACKS_MATERIAL_DISPATCH");
    expect(rootScript).toContain("show_player_title");

    [
      "barrosan_barracks_material_v0149",
      "HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK",
      "HYBRID_BARRACKS_LOCAL_512",
      "HYBRID_BARRACKS_LOCAL_768",
      "HYBRID_BARRACKS_LOCAL_1024",
      "HYBRID_WORKER_CONTEXT_BASELINE",
      "texture_cache",
      "material_cache",
      "source_load_counts",
      "texture_create_counts",
      "material_create_counts",
      "barracksShellCount",
      "benchmarkExcludesInitializationAndWarmup",
      "thirdRuntimeArtSlotAdded",
      "browserIntegration"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "fallback:check",
      "derivatives:check",
      "PASS_V0149_BARRACKS_MATERIAL_FALLBACK_REPRODUCIBILITY",
      "PASS_V0149_BARRACKS_MATERIAL_DERIVATIVE_REPRODUCIBILITY",
      "PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE",
      "barracks-material-threshold-report.json",
      "barracks-material-fair-path-audit.json",
      "exactlyOneGeneratedImage",
      "noThirdRuntimeArtSlot"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:barracks-material:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("barrosan-barracks-material-single-slot");
    expect(stabilizedLauncher).not.toContain("BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT");
    expect(playerLauncher).not.toContain("barrosan-barracks-material-single-slot");
    expect(playerLauncher).not.toContain("BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT");

    expect(intakeSpec).toContain("Generate exactly one new local experimental material source");
    expect(intakeSpec).toContain("barrosan_barracks_material_v0149");
    expect(slotContract).toContain("tracked deterministic diagnostic fallback");
    expect(fairPathAudit).toContain("No texture decode, texture creation, material creation");
    expect(boundary).toContain("No third runtime-art slot");
    expect(boundary).toContain("No browser runtime mutation");
    expect(implementation).toContain("No v0.150 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.150 private Barracks material seam repair review stop", async () => {
    [
      "GODOT_BARROSAN_BARRACKS_MATERIAL_SEAM_REPAIR_WINDOWS.bat",
      "tools/godot/barracksMaterialSingleSlotTool.mjs",
      "tools/godot/runGodotBarracksMaterialSeamRepairValidation.ps1",
      "tools/godot/runGodotBarracksMaterialSeamRepairDerivatives.ps1",
      "tools/godot/runGodotBarracksMaterialSeamRepairAudit.ps1",
      "tools/godot/runGodotBarracksMaterialSeamRepairBenchmarkWindows.ps1",
      "tools/godot/captureGodotBarracksMaterialSeamRepairWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.contract.json",
      "docs/V0150_BARRACKS_MATERIAL_UV_SEAM_REPAIR_SPEC.md",
      "docs/V0150_BARRACKS_MATERIAL_SEAM_DERIVATIVE_MATRIX.md",
      "docs/V0150_BARRACKS_MATERIAL_FAIR_PATH_AUDIT.md",
      "docs/V0150_BARRACKS_MATERIAL_PAIRED_BENCHMARK_REPORT.md",
      "docs/V0150_BARRACKS_MATERIAL_VISUAL_REVIEW_GUIDE.md",
      "docs/V0150_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0150_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/barracksMaterialSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_BARROSAN_BARRACKS_MATERIAL_SEAM_REPAIR_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const spec = await readFile("docs/V0150_BARRACKS_MATERIAL_UV_SEAM_REPAIR_SPEC.md", "utf8");
    const boundary = await readFile("docs/V0150_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0150_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:barracks-material-seam-repair:validate",
      "godot:barracks-material-seam-repair:derivatives:reproduce",
      "godot:barracks-material-seam-repair:audit",
      "godot:barracks-material-seam-repair:benchmark:headed",
      "godot:barracks-material-seam-repair:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(rootScript).toContain("--barrosan-barracks-material-seam-repair");
    expect(rootScript).toContain("barracks_material_seam_repair_comparator.gd");
    expect(rootScript).toContain("PASS_V0150_PRIVATE_BARRACKS_MATERIAL_SEAM_REPAIR_DISPATCH");

    [
      "barrosan_barracks_material_v0149",
      "HYBRID_BARRACKS_768_ORIGINAL",
      "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND",
      "HYBRID_BARRACKS_768_WRAPSAFE_QUADRANT",
      "HYBRID_BARRACKS_768_WRAPSAFE_SOFTSEAM",
      "HYBRID_WORKER_CONTEXT_BASELINE",
      "zeroAiImagesGeneratedForV0150",
      "sameV0149SourceOnly",
      "noNewRuntimeArtSlot",
      "benchmarkExcludesInitializationAndWarmup",
      "browserIntegration"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "seam-repair:derivatives:check",
      "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_DERIVATIVE_REPRODUCIBILITY",
      "PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE",
      "barracks-material-seam-repair-threshold-report.json",
      "barracks-material-seam-repair-fair-path-audit.json",
      "zeroAiImagesGeneratedForV0150",
      "sameV0149SourceOnly",
      "noNewRuntimeArtSlot"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:barracks-material-seam-repair:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("barrosan-barracks-material-seam-repair");
    expect(stabilizedLauncher).not.toContain("BARRACKS_MATERIAL_SEAM_REPAIR");
    expect(playerLauncher).not.toContain("barrosan-barracks-material-seam-repair");
    expect(playerLauncher).not.toContain("BARRACKS_MATERIAL_SEAM_REPAIR");

    expect(spec).toContain("zero new AI images");
    expect(spec).toContain("2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3");
    expect(boundary).toContain("No new runtime-art slot");
    expect(boundary).toContain("No browser runtime wiring");
    expect(implementation).toContain("No v0.151 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.151 private Aster billboard single-slot experiment and review stop", async () => {
    [
      "GODOT_ASTER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
      "tools/godot/asterBillboardSingleSlotTool.mjs",
      "tools/godot/runGodotAsterBillboardValidation.ps1",
      "tools/godot/runGodotAsterBillboardFallbackReproducibility.ps1",
      "tools/godot/runGodotAsterBillboardAudit.ps1",
      "tools/godot/runGodotAsterBillboardBenchmarkWindows.ps1",
      "tools/godot/captureGodotAsterBillboardWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.contract.json",
      "docs/V0151_ASTER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
      "docs/V0151_ASTER_BILLBOARD_SLOT_CONTRACT.md",
      "docs/V0151_ASTER_BILLBOARD_VALIDATION_REPORT.md",
      "docs/V0151_ASTER_BILLBOARD_SCORECARD.md",
      "docs/V0151_ASTER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
      "docs/V0151_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0151_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/asterBillboardSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_ASTER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const spec = await readFile("docs/V0151_ASTER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md", "utf8");
    const boundary = await readFile("docs/V0151_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0151_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:aster-billboard:metadata",
      "godot:aster-billboard:validate",
      "godot:aster-billboard:fallback:reproduce",
      "godot:aster-billboard:audit",
      "godot:aster-billboard:benchmark:headed",
      "godot:aster-billboard:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(rootScript).toContain("--aster-billboard-single-slot");
    expect(rootScript).toContain("aster_billboard_single_slot_comparator.gd");
    expect(rootScript).toContain("PASS_V0151_PRIVATE_ASTER_BILLBOARD_DISPATCH");

    [
      "aster_billboard_static_v0151",
      "HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE",
      "HYBRID_ASTER_LOCAL_STATIC_BILLBOARD",
      "HYBRID_WORKER_CONTEXT_BASELINE",
      "HYBRID_BARRACKS_CONTEXT_BASELINE",
      "exactlyOneAiImageForV0151",
      "noFourthRuntimeArtSlot",
      "localAndFallbackShareAsterBillboardRenderPath",
      "benchmarkExcludesInitializationAndWarmup",
      "browserIntegration"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0151_ASTER_BILLBOARD_LOCAL_METADATA",
      "PASS_V0151_ASTER_BILLBOARD_FALLBACK_REPRODUCIBILITY",
      "PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE",
      "aster-billboard-single-slot-scorecard.json",
      "aster-billboard-single-slot-fair-path-audit.json",
      "exactlyOneAiImageForV0151",
      "noFourthRuntimeArtSlot"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:aster-billboard:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("aster-billboard-single-slot");
    expect(stabilizedLauncher).not.toContain("ASTER_BILLBOARD_SINGLE_SLOT");
    expect(playerLauncher).not.toContain("aster-billboard-single-slot");
    expect(playerLauncher).not.toContain("ASTER_BILLBOARD_SINGLE_SLOT");

    expect(spec).toContain("exactly one AI image");
    expect(spec).toContain("HYBRID_WORKER_TRIMMED_1024");
    expect(spec).toContain("HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND");
    expect(boundary).toContain("No fourth runtime-art slot");
    expect(boundary).toContain("No browser runtime wiring");
    expect(implementation).toContain("No v0.152 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.152 private Aster billboard repair path and review stop", async () => {
    [
      "GODOT_ASTER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat",
      "tools/godot/runGodotAsterBillboardRepairDerivatives.ps1",
      "tools/godot/runGodotAsterBillboardRepairValidation.ps1",
      "tools/godot/runGodotAsterBillboardRepairAudit.ps1",
      "tools/godot/runGodotAsterBillboardRepairBenchmarkWindows.ps1",
      "tools/godot/captureGodotAsterBillboardRepairWindows.ps1",
      "docs/V0152_ASTER_BILLBOARD_REPAIR_SPEC.md",
      "docs/V0152_ASTER_BILLBOARD_DERIVATIVE_MATRIX.md",
      "docs/V0152_ASTER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md",
      "docs/V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT.md",
      "docs/V0152_ASTER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
      "docs/V0152_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0152_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/asterBillboardSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_ASTER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const benchmarkReport = await readFile("docs/V0152_ASTER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md", "utf8");
    const boundary = await readFile("docs/V0152_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0152_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:aster-billboard-repair:derivatives:reproduce",
      "godot:aster-billboard-repair:validate",
      "godot:aster-billboard-repair:audit",
      "godot:aster-billboard-repair:benchmark:headed",
      "godot:aster-billboard-repair:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(rootScript).toContain("--aster-billboard-single-slot-repair");
    expect(rootScript).toContain("PASS_V0152_PRIVATE_ASTER_BILLBOARD_REPAIR_DISPATCH");
    expect(rootScript).toContain("aster_billboard_single_slot_comparator.gd");

    [
      "REPAIR_CHECKPOINT := \"v0.152\"",
      "HYBRID_ASTER_FULL_RES",
      "HYBRID_ASTER_TRIMMED_512",
      "HYBRID_ASTER_TRIMMED_768",
      "HYBRID_ASTER_TRIMMED_1024",
      "zeroNewAiImagesForV0152",
      "sameAsterSourceOnly",
      "noNewRuntimeArtSlot",
      "localAndFallbackShareAsterBillboardRenderPath",
      "benchmarkExcludesInitializationAndWarmup",
      "browserIntegration"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0152_ASTER_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY",
      "PASS_V0152_ASTER_BILLBOARD_REPAIR_VALIDATION",
      "PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE",
      "PASS_V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT",
      "aster-billboard-repair-scorecard.json",
      "aster-billboard-repair-fair-path-audit.json",
      "zeroNewAiImagesForV0152",
      "sameAsterSourceOnly",
      "noNewRuntimeArtSlot"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:aster-billboard-repair:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("aster-billboard-single-slot-repair");
    expect(stabilizedLauncher).not.toContain("ASTER_BILLBOARD_SINGLE_SLOT_REPAIR");
    expect(playerLauncher).not.toContain("aster-billboard-single-slot-repair");
    expect(playerLauncher).not.toContain("ASTER_BILLBOARD_SINGLE_SLOT_REPAIR");

    expect(benchmarkReport).toContain("PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE");
    expect(benchmarkReport).toContain("HYBRID_ASTER_TRIMMED_1024");
    expect(boundary).toContain("No new runtime-art slot");
    expect(boundary).toContain("No browser runtime wiring");
    expect(implementation).toContain("No v0.153 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.153 private hybrid three-slot composition stress gate", async () => {
    [
      "GODOT_HYBRID_THREE_SLOT_COMPOSITION_STRESS_WINDOWS.bat",
      "tools/godot/runGodotHybridThreeSlotCompositionValidation.ps1",
      "tools/godot/runGodotHybridThreeSlotCompositionAudit.ps1",
      "tools/godot/runGodotHybridThreeSlotCompositionBenchmarkWindows.ps1",
      "tools/godot/captureGodotHybridThreeSlotCompositionWindows.ps1",
      "docs/V0153_HYBRID_THREE_SLOT_COMPOSITION_STRESS_SPEC.md",
      "docs/V0153_HYBRID_THREE_SLOT_SCORECARD.md",
      "docs/V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT.md",
      "docs/V0153_HYBRID_THREE_SLOT_VISUAL_REVIEW_GUIDE.md",
      "docs/V0153_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0153_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/asterBillboardSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_HYBRID_THREE_SLOT_COMPOSITION_STRESS_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const spec = await readFile("docs/V0153_HYBRID_THREE_SLOT_COMPOSITION_STRESS_SPEC.md", "utf8");
    const scorecard = await readFile("docs/V0153_HYBRID_THREE_SLOT_SCORECARD.md", "utf8");
    const boundary = await readFile("docs/V0153_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0153_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "godot:hybrid-three-slot-composition:validate",
      "godot:hybrid-three-slot-composition:audit",
      "godot:hybrid-three-slot-composition:benchmark:headed",
      "godot:hybrid-three-slot-composition:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    expect(rootScript).toContain("--hybrid-three-slot-composition-stress");
    expect(rootScript).toContain("PASS_V0153_PRIVATE_HYBRID_THREE_SLOT_COMPOSITION_DISPATCH");
    expect(rootScript).toContain("aster_billboard_single_slot_comparator.gd");

    [
      "COMPOSITION_CHECKPOINT := \"v0.153\"",
      "HYBRID_THREE_SLOT_FALLBACK_ONLY",
      "HYBRID_THREE_SLOT_SELECTED_LOCAL",
      "ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK",
      "PASS_V0153_HYBRID_THREE_SLOT_RUNTIME_EVIDENCE",
      "zeroNewAiImagesForV0153",
      "zeroNewRuntimeArtSlotsForV0153",
      "selectedAndFallbackShareWorkerBillboardRenderPath",
      "selectedAndFallbackShareBarracksMaterialRenderPath",
      "minimapUnaffected"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "composition:validate",
      "composition:report",
      "composition:audit",
      "PASS_V0153_HYBRID_THREE_SLOT_VALIDATION",
      "PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE",
      "PASS_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT",
      "hybrid-three-slot-composition-scorecard.json",
      "hybrid-three-slot-composition-threshold-report.json",
      "zeroNewRuntimeArtSlotsForV0153"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:hybrid-three-slot-composition:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("hybrid-three-slot-composition-stress");
    expect(stabilizedLauncher).not.toContain("HYBRID_THREE_SLOT_COMPOSITION");
    expect(playerLauncher).not.toContain("hybrid-three-slot-composition-stress");
    expect(playerLauncher).not.toContain("HYBRID_THREE_SLOT_COMPOSITION");

    expect(spec).toContain("Use zero new AI images");
    expect(spec).toContain("Add zero new runtime-art slots");
    expect(scorecard).toContain("PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE");
    expect(boundary).toContain("New runtime-art slots");
    expect(boundary).toContain("No browser runtime wiring");
    expect(implementation).toContain("No v0.154 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.154 private Militia static billboard single-slot intake gate", async () => {
    [
      "GODOT_MILITIA_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.png",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.contract.json",
      "tools/godot/militiaBillboardSingleSlotTool.mjs",
      "tools/godot/runGodotMilitiaBillboardValidation.ps1",
      "tools/godot/runGodotMilitiaBillboardBenchmarkWindows.ps1",
      "tools/godot/captureGodotMilitiaBillboardWindows.ps1",
      "docs/V0154_MILITIA_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
      "docs/V0154_MILITIA_BILLBOARD_SLOT_CONTRACT.md",
      "docs/V0154_MILITIA_BILLBOARD_VALIDATION_REPORT.md",
      "docs/V0154_MILITIA_BILLBOARD_SCORECARD.md",
      "docs/V0154_MILITIA_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
      "docs/V0154_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0154_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    [
      "godot:militia-billboard:metadata",
      "godot:militia-billboard:fallback:reproduce",
      "godot:militia-billboard:validate",
      "godot:militia-billboard:audit",
      "godot:militia-billboard:benchmark:headed",
      "godot:militia-billboard:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/militiaBillboardSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_MILITIA_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const spec = await readFile("docs/V0154_MILITIA_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md", "utf8");
    const boundary = await readFile("docs/V0154_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0154_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "--militia-billboard-single-slot",
      "PASS_V0154_PRIVATE_MILITIA_BILLBOARD_DISPATCH",
      "militia_billboard_single_slot_comparator.gd"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "HYBRID_MILITIA_DIAGNOSTIC_FALLBACK_BASELINE",
      "HYBRID_MILITIA_LOCAL_STATIC_BILLBOARD",
      "ORTHO_MILITIA_PROCEDURAL_FALLBACK",
      "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_EVIDENCE",
      "militiaBelowAsterHierarchy",
      "groupsReadable",
      "staticFormationReadable"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0154_MILITIA_BILLBOARD_METADATA",
      "PASS_V0154_MILITIA_BILLBOARD_VALIDATION",
      "PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_GATE",
      "PASS_V0154_MILITIA_BILLBOARD_FAIR_PATH_AUDIT",
      "exactlyOneAiImageForV0154",
      "militia-billboard-single-slot-scorecard.json"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:militia-billboard:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("militia-billboard-single-slot");
    expect(stabilizedLauncher).not.toContain("MILITIA_BILLBOARD");
    expect(playerLauncher).not.toContain("militia-billboard-single-slot");
    expect(playerLauncher).not.toContain("MILITIA_BILLBOARD");

    expect(spec).toContain("Generate exactly one AI image");
    expect(spec).toContain("No normal Salto player-slice mutation");
    expect(boundary).toContain("No browser runtime wiring");
    expect(boundary).toContain("Additional AI images");
    expect(implementation).toContain("No v0.155 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.155 private Militia billboard repair mass-overlap benchmark gate", async () => {
    [
      "GODOT_MILITIA_BILLBOARD_MASS_OVERLAP_REPAIR_WINDOWS.bat",
      "tools/godot/runGodotMilitiaBillboardRepairDerivatives.ps1",
      "tools/godot/runGodotMilitiaBillboardRepairValidation.ps1",
      "tools/godot/runGodotMilitiaBillboardRepairAudit.ps1",
      "tools/godot/runGodotMilitiaBillboardRepairBenchmarkWindows.ps1",
      "tools/godot/captureGodotMilitiaBillboardRepairWindows.ps1",
      "docs/V0155_MILITIA_BILLBOARD_REPAIR_SPEC.md",
      "docs/V0155_MILITIA_BILLBOARD_DERIVATIVE_MATRIX.md",
      "docs/V0155_MILITIA_BILLBOARD_SCORECARD.md",
      "docs/V0155_MILITIA_BILLBOARD_FAIR_PATH_AUDIT.md",
      "docs/V0155_MILITIA_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
      "docs/V0155_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0155_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    [
      "godot:militia-billboard-repair:derivatives:reproduce",
      "godot:militia-billboard-repair:validate",
      "godot:militia-billboard-repair:audit",
      "godot:militia-billboard-repair:benchmark:headed",
      "godot:militia-billboard-repair:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/militiaBillboardSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_MILITIA_BILLBOARD_MASS_OVERLAP_REPAIR_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const spec = await readFile("docs/V0155_MILITIA_BILLBOARD_REPAIR_SPEC.md", "utf8");
    const boundary = await readFile("docs/V0155_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0155_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "--militia-billboard-mass-overlap-repair",
      "PASS_V0155_PRIVATE_MILITIA_BILLBOARD_REPAIR_DISPATCH",
      "militia_billboard_single_slot_comparator.gd"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "REPAIR_CHECKPOINT := \"v0.155\"",
      "HYBRID_MILITIA_REPAIR_FALLBACK_BASELINE",
      "HYBRID_MILITIA_FULL_RES",
      "HYBRID_MILITIA_TRIMMED_512",
      "HYBRID_MILITIA_TRIMMED_768",
      "HYBRID_MILITIA_TRIMMED_1024",
      "STRESS_32",
      "PASS_V0155_MILITIA_BILLBOARD_REPAIR_RUNTIME_EVIDENCE",
      "zeroNewAiImagesForV0155",
      "sameMilitiaSourceOnly",
      "noNewRuntimeArtSlot",
      "noFifthRuntimeArtSlot"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0155_MILITIA_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY",
      "PASS_V0155_MILITIA_BILLBOARD_REPAIR_VALIDATION",
      "PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE",
      "PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT",
      "militia-billboard-repair-scorecard.json",
      "militia-billboard-repair-fair-path-audit.json",
      "zeroNewAiImagesForV0155",
      "sameMilitiaSourceOnly",
      "noNewRuntimeArtSlot",
      "noFifthRuntimeArtSlot"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:militia-billboard-repair:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("militia-billboard-mass-overlap-repair");
    expect(stabilizedLauncher).not.toContain("MILITIA_BILLBOARD_REPAIR");
    expect(playerLauncher).not.toContain("militia-billboard-mass-overlap-repair");
    expect(playerLauncher).not.toContain("MILITIA_BILLBOARD_REPAIR");

    expect(spec).toContain("generates zero new AI images");
    expect(spec).toContain("same-source Militia PNG variants");
    expect(boundary).toContain("No browser runtime wiring");
    expect(boundary).toContain("No v0.156 work");
    expect(implementation).toContain("No v0.156 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.156 private Ashen Raider billboard single hostile-slot intake gate", async () => {
    [
      "GODOT_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat",
      "tools/godot/ashenRaiderBillboardSingleSlotTool.mjs",
      "tools/godot/runGodotAshenRaiderBillboardValidation.ps1",
      "tools/godot/runGodotAshenRaiderBillboardBenchmarkWindows.ps1",
      "tools/godot/captureGodotAshenRaiderBillboardWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd",
      "docs/V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md",
      "docs/V0156_ASHEN_RAIDER_BILLBOARD_SLOT_CONTRACT.md",
      "docs/V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION_REPORT.md",
      "docs/V0156_ASHEN_RAIDER_BILLBOARD_BENCHMARK_REPORT.md",
      "docs/V0156_ASHEN_RAIDER_BILLBOARD_SCORECARD.md",
      "docs/V0156_ASHEN_RAIDER_BILLBOARD_VISUAL_REVIEW_GUIDE.md",
      "docs/V0156_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0156_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    [
      "godot:ashen-raider-billboard:metadata",
      "godot:ashen-raider-billboard:fallback:reproduce",
      "godot:ashen-raider-billboard:validate",
      "godot:ashen-raider-billboard:audit",
      "godot:ashen-raider-billboard:benchmark:headed",
      "godot:ashen-raider-billboard:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/ashenRaiderBillboardSingleSlotTool.mjs", "utf8");
    const launcher = await readFile("GODOT_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const boundary = await readFile("docs/V0156_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0156_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "--ashen-raider-billboard-single-slot",
      "PASS_V0156_PRIVATE_ASHEN_RAIDER_BILLBOARD_DISPATCH",
      "ashen_raider_billboard_single_slot_comparator.gd"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "CHECKPOINT := \"v0.156\"",
      "ashen_raider_billboard_static_v0156",
      "HYBRID_ASHEN_RAIDER_LOCAL_STATIC_BILLBOARD",
      "SELECTED_MILITIA_HASH := \"c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb\"",
      "PASS_V0156_ASHEN_RAIDER_BILLBOARD_RUNTIME_EVIDENCE",
      "singleHostilePrivateComparatorRuntimeArtSlotOnly",
      "noSixthRuntimeArtSlot"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION",
      "PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE",
      "PASS_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT",
      "exactlyOneAiImageForV0156",
      "selectedMilitiaHash",
      "ashen-raider-billboard-single-slot-scorecard.json"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:ashen-raider-billboard:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("ashen-raider-billboard-single-slot");
    expect(stabilizedLauncher).not.toContain("ASHEN_RAIDER_BILLBOARD");
    expect(playerLauncher).not.toContain("ashen-raider-billboard-single-slot");
    expect(playerLauncher).not.toContain("ASHEN_RAIDER_BILLBOARD");

    expect(boundary).toContain("No browser runtime wiring");
    expect(boundary).toContain("No second hostile slot");
    expect(implementation).toContain("No v0.157 work");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
  });

  it("defines the v0.157 private Ashen Raider visual-restraint replacement gate", async () => {
    [
      "GODOT_ASHEN_RAIDER_VISUAL_RESTRAINT_REPLACEMENT_WINDOWS.bat",
      "tools/godot/ashenRaiderVisualRestraintReplacementTool.mjs",
      "tools/godot/runGodotAshenRaiderVisualRestraintReplacementDerivatives.ps1",
      "tools/godot/runGodotAshenRaiderVisualRestraintReplacementValidation.ps1",
      "tools/godot/runGodotAshenRaiderVisualRestraintReplacementAudit.ps1",
      "tools/godot/runGodotAshenRaiderVisualRestraintReplacementBenchmarkWindows.ps1",
      "tools/godot/captureGodotAshenRaiderVisualRestraintReplacementWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd",
      "docs/V0157_ASHEN_RAIDER_VISUAL_RESTRAINT_REPLACEMENT_SPEC.md",
      "docs/V0157_ASHEN_RAIDER_REPLACEMENT_SLOT_CONTRACT.md",
      "docs/V0157_ASHEN_RAIDER_DERIVATIVE_MATRIX.md",
      "docs/V0157_ASHEN_RAIDER_FAIR_PATH_AUDIT.md",
      "docs/V0157_ASHEN_RAIDER_PAIRED_BENCHMARK_REPORT.md",
      "docs/V0157_ASHEN_RAIDER_VISUAL_REVIEW_GUIDE.md",
      "docs/V0157_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0157_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    [
      "godot:ashen-raider-replacement:derivatives:reproduce",
      "godot:ashen-raider-replacement:validate",
      "godot:ashen-raider-replacement:audit",
      "godot:ashen-raider-replacement:benchmark:headed",
      "godot:ashen-raider-replacement:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/ashenRaiderVisualRestraintReplacementTool.mjs", "utf8");
    const launcher = await readFile("GODOT_ASHEN_RAIDER_VISUAL_RESTRAINT_REPLACEMENT_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const boundary = await readFile("docs/V0157_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");
    const implementation = await readFile("docs/V0157_IMPLEMENTATION_REPORT.md", "utf8");

    [
      "--ashen-raider-visual-restraint-replacement",
      "PASS_V0157_PRIVATE_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_DISPATCH",
      "ashen_raider_visual_restraint_replacement_comparator.gd"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "CHECKPOINT := \"v0.157\"",
      "SOURCE_CHECKPOINT := \"v0.156\"",
      "HYBRID_ASHEN_RAIDER_ARCHIVED_V0156_COMPARISON",
      "HYBRID_ASHEN_RAIDER_V0157_FULL_RES",
      "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_512",
      "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_768",
      "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024",
      "PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_EVIDENCE",
      "weaponSilhouetteRestrained",
      "sameHostileSlotOnly",
      "noSixthRuntimeArtSlot"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_DERIVATIVES_REPRODUCIBILITY",
      "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_VALIDATION",
      "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE",
      "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_FAIR_PATH_AUDIT",
      "exactlyOneAiImageForV0157",
      "preservesArchivedV0156ComparisonEvidence",
      "ashen-raider-visual-restraint-replacement-scorecard.json"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:ashen-raider-replacement:benchmark:headed");
    expect(stabilizedLauncher).not.toContain("ashen-raider-visual-restraint-replacement");
    expect(stabilizedLauncher).not.toContain("ASHEN_RAIDER_RESTRAINT_REPLACEMENT");
    expect(playerLauncher).not.toContain("ashen-raider-visual-restraint-replacement");
    expect(playerLauncher).not.toContain("ASHEN_RAIDER_RESTRAINT_REPLACEMENT");

    expect(boundary).toContain("No browser runtime wiring");
    expect(boundary).toContain("No sixth runtime-art slot");
    expect(implementation).toContain("Do not begin v0.158");

    expect(rootScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(toolScript).not.toContain("artifacts/art-review/v0138/candidates");
    expect(comparatorScript).not.toContain("v0.158");
    expect(toolScript).not.toContain("v0.158");
  });

  it("defines the v0.158 private hybrid mixed-combat readability stress gate", async () => {
    [
      "GODOT_HYBRID_MIXED_COMBAT_READABILITY_STRESS_WINDOWS.bat",
      "tools/godot/hybridMixedCombatReadabilityStressTool.mjs",
      "tools/godot/runGodotHybridMixedCombatReadabilityStressValidation.ps1",
      "tools/godot/runGodotHybridMixedCombatReadabilityStressAudit.ps1",
      "tools/godot/runGodotHybridMixedCombatReadabilityStressBenchmarkWindows.ps1",
      "tools/godot/captureGodotHybridMixedCombatReadabilityStressWindows.ps1",
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd",
      "docs/V0158_HYBRID_MIXED_COMBAT_STRESS_SPEC.md",
      "docs/V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT.md",
      "docs/V0158_HYBRID_MIXED_COMBAT_BENCHMARK_REPORT.md",
      "docs/V0158_HYBRID_MIXED_COMBAT_VISUAL_REVIEW_GUIDE.md",
      "docs/V0158_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md",
      "docs/V0158_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = await readJson<{ scripts: Record<string, string> }>("package.json");
    [
      "godot:hybrid-mixed-combat:validate",
      "godot:hybrid-mixed-combat:audit",
      "godot:hybrid-mixed-combat:benchmark:headed",
      "godot:hybrid-mixed-combat:capture"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const comparatorScript = await readFile(
      "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd",
      "utf8"
    );
    const toolScript = await readFile("tools/godot/hybridMixedCombatReadabilityStressTool.mjs", "utf8");
    const launcher = await readFile("GODOT_HYBRID_MIXED_COMBAT_READABILITY_STRESS_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const boundary = await readFile("docs/V0158_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md", "utf8");

    [
      "--hybrid-mixed-combat-readability-stress",
      "PASS_V0158_PRIVATE_HYBRID_MIXED_COMBAT_STRESS_DISPATCH",
      "hybrid_mixed_combat_readability_stress_comparator.gd"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "CHECKPOINT := \"v0.158\"",
      "HYBRID_MIXED_COMBAT_SELECTED_LOCAL",
      "HYBRID_MIXED_COMBAT_FALLBACK_ONLY",
      "ORTHO_MIXED_COMBAT_PROCEDURAL_FALLBACK",
      "C1_FOUR_ASHEN_WAVE",
      "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC",
      "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_EVIDENCE",
      "zeroNewImages",
      "zeroNewRuntimeArtSlots"
    ].forEach((text) => expect(comparatorScript).toContain(text));

    [
      "PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION",
      "PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT",
      "PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE",
      "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024",
      "0.9853",
      "1.0159",
      "hybrid-mixed-combat-scorecard.json"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(launcher).toContain("godot:hybrid-mixed-combat:benchmark:headed");
    expect(playerLauncher).not.toContain("hybrid-mixed-combat-readability-stress");
    expect(playerLauncher).not.toContain("V0158_HYBRID_MIXED_COMBAT");
    expect(boundary).toContain("Zero new AI images");
    expect(boundary).toContain("No v0.159 work");
  });

  it("defines the v0.159 readiness packet without starting the Worker opt-in experiment", async () => {
    [
      "docs/V0159_FIRST_PLAYER_FACING_HYBRID_ART_INTEGRATION_READINESS.md",
      "docs/V0159_FIRST_SLOT_DECISION_SCORECARD.md",
      "docs/V0159_V0160_WORKER_OPT_IN_INTEGRATION_CONTRACT.md",
      "docs/V0159_PLAYER_SLICE_INTEGRATION_RISK_REGISTER.md",
      "docs/V0159_PLAYER_SLICE_INTEGRATION_ROLLBACK_PLAN.md",
      "docs/V0159_EMMANUEL_INTEGRATION_READINESS_REVIEW_GUIDE.md",
      "docs/V0159_PRIVATE_COMPARATOR_TO_PLAYER_SLICE_BOUNDARY.md",
      "docs/V0159_IMPLEMENTATION_REPORT.md",
      "docs/art-prompts/V0160_01_GODOT_PLAYER_SLICE_WORKER_BILLBOARD_OPT_IN_INTEGRATION.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const readiness = await readFile("docs/V0159_FIRST_PLAYER_FACING_HYBRID_ART_INTEGRATION_READINESS.md", "utf8");
    const scorecard = await readFile("docs/V0159_FIRST_SLOT_DECISION_SCORECARD.md", "utf8");
    const contract = await readFile("docs/V0159_V0160_WORKER_OPT_IN_INTEGRATION_CONTRACT.md", "utf8");
    const boundary = await readFile("docs/V0159_PRIVATE_COMPARATOR_TO_PLAYER_SLICE_BOUNDARY.md", "utf8");
    const futurePrompt = await readFile(
      "docs/art-prompts/V0160_01_GODOT_PLAYER_SLICE_WORKER_BILLBOARD_OPT_IN_INTEGRATION.md",
      "utf8"
    );
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");

    [
      "worker_billboard_static_v0147",
      "HYBRID_WORKER_TRIMMED_1024",
      "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc",
      "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat"
    ].forEach((text) => {
      expect(contract).toContain(text);
      expect(futurePrompt).toContain(text);
    });

    expect(readiness).toContain("No image generation");
    expect(readiness).toContain("No new runtime-art slot");
    expect(scorecard).toContain("Selected future v0.160 first slot");
    expect(boundary).toContain("Forbidden In v0.159");
    expect(boundary).toContain("Start v0.160");
    expect(futurePrompt).toContain("Do not execute v0.160 in v0.159");

    [
      "worker_billboard_static_v0147",
      "HYBRID_WORKER_TRIMMED_1024",
      "WORKER_ART_EXPERIMENT",
      "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT"
    ].forEach((text) => {
      expect(playerLauncher).not.toContain(text);
      expect(stabilizedLauncher).not.toContain(text);
    });
  });

  it("defines the v0.160 Worker billboard opt-in player-slice integration gate", async () => {
    [
      "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
      "GODOT_VALIDATE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
      "GODOT_CAPTURE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
      "tools/godot/launchGodotSaltoWorkerArtExperimentWindows.ps1",
      "tools/godot/validateGodotSaltoWorkerArtExperimentWindows.ps1",
      "tools/godot/captureGodotSaltoWorkerArtExperimentWindows.ps1",
      "tools/godot/runGodotSaltoWorkerArtExperimentBenchmarkWindows.ps1",
      "tools/godot/saltoWorkerArtOptInTool.mjs",
      "docs/V0160_GODOT_PLAYER_SLICE_WORKER_ART_OPT_IN_SPEC.md",
      "docs/V0160_WORKER_ART_OPT_IN_SLOT_CONTRACT.md",
      "docs/V0160_WORKER_ART_OPT_IN_FUNCTIONAL_REPORT.md",
      "docs/V0160_WORKER_ART_OPT_IN_VISUAL_REVIEW_GUIDE.md",
      "docs/V0160_WORKER_ART_OPT_IN_BENCHMARK_REPORT.md",
      "docs/V0160_WORKER_ART_OPT_IN_ROLLBACK_REPORT.md",
      "docs/V0160_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY.md",
      "docs/V0160_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = JSON.parse(await readFile("package.json", "utf8")) as { scripts: Record<string, string> };
    const rootScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_root.gd", "utf8");
    const sceneScript = await readFile("desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd", "utf8");
    const launchScript = await readFile("tools/godot/launchGodotSaltoWorkerArtExperimentWindows.ps1", "utf8");
    const validateScript = await readFile("tools/godot/validateGodotSaltoWorkerArtExperimentWindows.ps1", "utf8");
    const captureScript = await readFile("tools/godot/captureGodotSaltoWorkerArtExperimentWindows.ps1", "utf8");
    const benchmarkScript = await readFile("tools/godot/runGodotSaltoWorkerArtExperimentBenchmarkWindows.ps1", "utf8");
    const toolScript = await readFile("tools/godot/saltoWorkerArtOptInTool.mjs", "utf8");
    const boundary = await readFile("docs/V0160_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY.md", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");

    [
      "godot:launch:salto-worker-art-experiment",
      "godot:validate:salto-worker-art-experiment",
      "godot:capture:salto-worker-art-experiment",
      "godot:benchmark:salto-worker-art-experiment"
    ].forEach((script) => expect(packageJson.scripts[script]).toBeTypeOf("string"));

    [
      "--worker-art-opt-in",
      "--worker-art-opt-in-benchmark",
      "--worker-art-source=",
      "--worker-art-metadata=",
      "--worker-art-expected-sha256=",
      "run_worker_art_opt_in_benchmark",
      "v0.160"
    ].forEach((text) => expect(rootScript).toContain(text));

    [
      "WORKER_ART_SLOT_ID := \"worker_billboard_static_v0147\"",
      "HYBRID_WORKER_TRIMMED_1024",
      "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc",
      "configure_worker_art_experiment",
      "source hash mismatch",
      "missing source file",
      "ImageTexture.create_from_image",
      "BaseMaterial3D.BILLBOARD_ENABLED"
    ].forEach((text) => expect(sceneScript).toContain(text));

    [
      "worker_billboard_static_v0147_trimmed_1024.png",
      "--player-slice",
      "--worker-art-opt-in",
      "--worker-art-scale=1.00"
    ].forEach((text) => expect(launchScript).toContain(text));

    [
      "default-procedural",
      "worker-opt-in",
      "missing-art-fallback",
      "hash-mismatch-fallback",
      "saltoWorkerArtOptInTool.mjs"
    ].forEach((text) => expect(validateScript).toContain(text));

    [
      "procedural-baseline",
      "worker-opt-in",
      "missing-art-fallback",
      "hash-mismatch-fallback",
      "saltoWorkerArtOptInTool.mjs"
    ].forEach((text) => expect(benchmarkScript).toContain(text));

    expect(captureScript).toContain("worker-opt-in-scale-090");
    expect(toolScript).toContain("PASS_V0160_WORKER_ART_OPT_IN_VALIDATION");
    expect(toolScript).toContain("PASS_V0160_WORKER_ART_OPT_IN_BENCHMARK");
    expect(toolScript).toContain("PASS_V0160_WORKER_ART_OPT_IN_BOUNDARY");
    expect(boundary).toContain("No second player-facing art slot");
    expect(boundary).toContain("Default stabilized launcher hash");

    [
      "WORKER_ART",
      "worker-art-opt-in",
      "worker_billboard_static_v0147"
    ].forEach((text) => {
      expect(stabilizedLauncher).not.toContain(text);
      expect(playerLauncher).not.toContain(text);
    });
  });

  it("defines the v0.161 Worker art opt-in visual QA hardening gate", async () => {
    [
      "GODOT_REVIEW_SALTO_WORKER_ART_OPT_IN_WINDOWS.bat",
      "GODOT_VALIDATE_SALTO_WORKER_ART_OPT_IN_HARDENING_WINDOWS.bat",
      "tools/godot/reviewGodotSaltoWorkerArtOptInWindows.ps1",
      "tools/godot/validateGodotSaltoWorkerArtOptInHardeningWindows.ps1",
      "tools/godot/saltoWorkerArtOptInHardeningTool.mjs",
      "docs/V0161_WORKER_ART_OPT_IN_PLAYER_SLICE_VISUAL_QA_SPEC.md",
      "docs/V0161_WORKER_ART_OPT_IN_COMPUTER_USE_REVIEW.md",
      "docs/V0161_WORKER_ART_OPT_IN_REAL_INPUT_REPORT.md",
      "docs/V0161_WORKER_ART_OPT_IN_HARDENING_REPORT.md",
      "docs/V0161_WORKER_ART_OPT_IN_VISUAL_REVIEW_GUIDE.md",
      "docs/V0161_WORKER_ART_OPT_IN_ROLLBACK_CONFIRMATION.md",
      "docs/V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY.md",
      "docs/V0161_IMPLEMENTATION_REPORT.md"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const packageJson = JSON.parse(await readFile("package.json", "utf8")) as { scripts: Record<string, string> };
    const hardeningScript = await readFile("tools/godot/validateGodotSaltoWorkerArtOptInHardeningWindows.ps1", "utf8");
    const toolScript = await readFile("tools/godot/saltoWorkerArtOptInHardeningTool.mjs", "utf8");
    const reviewScript = await readFile("tools/godot/reviewGodotSaltoWorkerArtOptInWindows.ps1", "utf8");
    const stabilizedLauncher = await readFile("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat", "utf8");
    const playerLauncher = await readFile("GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat", "utf8");

    [
      "godot:review:salto-worker-art-opt-in",
      "godot:validate:salto-worker-art-opt-in-hardening"
    ].forEach((script) => expect(packageJson.scripts[script]).toBeTypeOf("string"));

    [
      "default-procedural",
      "worker-opt-in",
      "missing-art-fallback",
      "hash-mismatch-fallback",
      "worker-opt-in-scale-090",
      "opt-in-real-input",
      "opt-in-site-semantics",
      "opt-in-post-mine-flow",
      "opt-in-restart-replay",
      "PASS_V0161_WORKER_ART_OPT_IN_HARDENING_AUTOMATION_READY"
    ].forEach((text) => expect(hardeningScript).toContain(text));

    [
      "PASS_V0161_WORKER_ART_OPT_IN_QA_VALIDATION",
      "PASS_V0161_WORKER_ART_OPT_IN_CAPTURE",
      "PASS_V0161_WORKER_ART_OPT_IN_BENCHMARK",
      "PASS_V0161_WORKER_ART_OPT_IN_REAL_INPUT",
      "PASS_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY",
      "PASS_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY",
      "minOptInFpsRatioVsProcedural: 0.9",
      "maxOptInP95FrameTimeRatioVsProcedural: 1.15",
      "pause for Emmanuel manual review"
    ].forEach((text) => expect(toolScript).toContain(text));

    expect(reviewScript).toContain("launchGodotSaltoWorkerArtExperimentWindows.ps1");
    expect(reviewScript).toContain("GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat");
    expect(toolScript).toContain("v0.162 work appears to have started");

    [
      "WORKER_ART",
      "worker-art-opt-in",
      "worker_billboard_static_v0147"
    ].forEach((text) => {
      expect(stabilizedLauncher).not.toContain(text);
      expect(playerLauncher).not.toContain(text);
    });
  });
});
