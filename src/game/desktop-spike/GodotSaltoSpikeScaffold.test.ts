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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
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
    expect(scene3d).not.toContain("ImageTexture");
    expect(toolScript).not.toContain("ImageTexture");
  });
});
