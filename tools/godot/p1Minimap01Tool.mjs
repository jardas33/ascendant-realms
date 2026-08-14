import { existsSync, readFileSync, mkdirSync, writeFileSync } from "node:fs";
import { spawnSync, execFileSync } from "node:child_process";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const evidenceRoot = process.env.P1_MINIMAP_01_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-minimap-01";
const logsRoot = process.env.P1_MINIMAP_01_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-minimap-01";
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const p1r3 = path.join(repo, "tools/godot/p1r3MinimapTerrainTool.mjs");

function runCapture() {
  mkdirSync(evidenceRoot, { recursive: true });
  mkdirSync(logsRoot, { recursive: true });
  const result = spawnSync(process.execPath, [p1r3, "capture"], {
    cwd: repo,
    env: { ...process.env, P1R3_EVIDENCE_ROOT: evidenceRoot, P1R3_LOG_ROOT: logsRoot, ASCENDANT_REALMS_GODOT: godot },
    stdio: "inherit",
    timeout: 360000,
    windowsHide: false,
  });
  process.exitCode = result.status ?? 1;
}

function validate() {
  const failures = [];
  const manifestPath = path.join(evidenceRoot, "p1r3-capture-manifest.json");
  if (!existsSync(manifestPath)) failures.push("missing minimap capture manifest");
  let manifest = null;
  if (!failures.length) {
    manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
    if (manifest.source_sha !== sourceSha()) failures.push("capture source SHA mismatch");
    if (manifest.pass !== true) failures.push(...(manifest.failures || ["capture failed"]));
    const captures = manifest.captures || [];
    for (const resolution of ["1920x1080", "1366x768"]) {
      const count = captures.filter((capture) => capture.png.includes(resolution)).length;
      if (count < 3) failures.push(`missing ${resolution} map captures`);
    }
  }
  const config = readFileSync(path.join(project, "project.godot"), "utf8");
  if (config.includes("P1R3Capture")) failures.push("capture autoload persisted");
  const hud = readFileSync(path.join(project, "scripts/ui/hud.gd"), "utf8");
  for (const token of ["MINIMAP_GRID_DIVISIONS", "_draw_minimap_frame", "_draw_minimap_building", "_draw_minimap_unit", "MINIMAP_VIEW_EDGE"]) {
    if (!hud.includes(token)) failures.push(`missing ${token}`);
  }
  const report = {
    schema: "ascendant-realms-p1-minimap-01-validator-v1",
    source_sha: sourceSha(),
    branch: execFileSync("git", ["branch", "--show-current"], { cwd: repo, encoding: "utf8" }).trim(),
    godot,
    manifest,
    failures,
    pass: failures.length === 0,
  };
  mkdirSync(evidenceRoot, { recursive: true });
  const reportPath = path.join(evidenceRoot, "p1-minimap-01-validator-report.json");
  writeFileSync(reportPath, JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (process.argv[2] === "capture") runCapture();
else if (process.argv[2] === "validate") validate();
else throw new Error("Usage: node tools/godot/p1Minimap01Tool.mjs <capture|validate>");
