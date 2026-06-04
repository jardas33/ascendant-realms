import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";

async function readJson<T>(path: string): Promise<T> {
  return JSON.parse(await readFile(path, "utf8")) as T;
}

describe("v0.117 Godot Salto spike scaffold", () => {
  it("keeps the Godot project text-driven and repository-local", async () => {
    [
      "desktop-spikes/godot-salto/project.godot",
      "desktop-spikes/godot-salto/export_presets.cfg",
      "desktop-spikes/godot-salto/scenes/salto_spike_root.tscn",
      "desktop-spikes/godot-salto/scenes/salto_2d_placeholder.tscn",
      "desktop-spikes/godot-salto/scenes/salto_2_5d_orthographic_placeholder.tscn",
      "desktop-spikes/godot-salto/scripts/fixture_importer.gd",
      "desktop-spikes/godot-salto/scripts/salto_spike_root.gd",
      "desktop-spikes/godot-salto/tests/salto_spike_test_runner.gd",
      "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs"
    ].forEach((path) => expect(existsSync(path), path).toBe(true));

    const project = await readFile("desktop-spikes/godot-salto/project.godot", "utf8");
    const exportPreset = await readFile("desktop-spikes/godot-salto/export_presets.cfg", "utf8");

    expect(project).toContain('config/name="Ascendant Realms Godot Salto Spike"');
    expect(project).toContain("run/main_scene=\"res://scenes/salto_spike_root.tscn\"");
    expect(exportPreset).toContain('name="Windows Desktop"');
    expect(exportPreset).toContain('platform="Windows Desktop"');
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
      "tools/godot/doctorGodotWindows.ps1",
      "tools/godot/bootstrapGodotWindows.ps1",
      "tools/godot/runGodotAll.ps1"
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
      "godot:all"
    ].forEach((script) => expect(packageJson.scripts[script], script).toBeTypeOf("string"));

    const dependencies = {
      ...(packageJson.dependencies ?? {}),
      ...(packageJson.devDependencies ?? {})
    };
    ["godot", "electron", "unity", "unreal", "three"].forEach((name) => expect(dependencies[name]).toBeUndefined());
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
});
