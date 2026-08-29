import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync, copyFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1R1_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\p1-task605-r1";
const logsRoot = process.env.P1R1_LOG_ROOT || "D:\\CodexData\\logs\\p1-task605-r1";
mkdirSync(evidenceRoot, { recursive: true });
mkdirSync(logsRoot, { recursive: true });

const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const parentSha = () => execFileSync("git", ["rev-parse", "HEAD^"], { cwd: repo, encoding: "utf8" }).trim();
const refSha = name => execFileSync("git", ["rev-parse", name], { cwd: repo, encoding: "utf8" }).trim();
const sha256 = file => createHash("sha256").update(readFileSync(file)).digest("hex");

function withAutoload(fn) {
  const file = path.join(project, "project.godot");
  const original = readFileSync(file, "utf8");
  const entry = 'P1R22Capture="*res://tests/p1r22_command_card.gd"';
  let armed = original;
  if (!original.includes(entry)) {
    const anchor = "[autoload]\n";
    if (!original.includes(anchor)) throw new Error("project.godot has no [autoload] section");
    armed = original.replace(anchor, `${anchor}${entry}\n`);
  }
  writeFileSync(file, armed);
  try { return fn(); } finally { writeFileSync(file, original); }
}

function run(name, view, width, height, out) {
  mkdirSync(out, { recursive: true });
  const log = path.join(logsRoot, `task605-r1-${name}.log`);
  const result = spawnSync(godot, ["--path", project, "--resolution", `${width}x${height}`, "--windowed", "--position", "20,20", "--log-file", log], {
    cwd: repo,
    env: {
      ...process.env,
      TEMP: "D:\\CodexData\\temp",
      TMP: "D:\\CodexData\\temp",
      ASCENDANT_P1R22_SOURCE_SHA: sourceSha(),
      ASCENDANT_P1R22_NAME: name,
      ASCENDANT_P1R22_VIEW: view,
      ASCENDANT_P1R22_WIDTH: String(width),
      ASCENDANT_P1R22_HEIGHT: String(height),
      ASCENDANT_P1R22_OUTPUT: out,
    },
    encoding: "utf8",
    timeout: 300000,
    windowsHide: false,
  });
  const manifest = path.join(out, "command-card-manifest.json");
  console.log(JSON.stringify({ capture: name, exit: result.status, signal: result.signal, stdout: result.stdout?.slice(-600), stderr: result.stderr?.slice(-600), log }));
  if (!existsSync(manifest)) throw new Error(`R1 ${name} produced no manifest; exit=${result.status}`);
  return JSON.parse(readFileSync(manifest, "utf8"));
}

function copyReference(source, destination) {
  if (!existsSync(source)) return { source, destination, copied: false };
  copyFileSync(source, destination);
  return { source, destination, copied: true, sha256: sha256(destination) };
}

function capture() {
  const runId = `run-${new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14)}-${sourceSha().slice(0, 8)}`;
  const runDir = path.join(evidenceRoot, runId);
  const jobs = [
    ["02_R1_WORKER", "worker", 1920, 1080],
    ["04_R1_MILITARY", "military", 1920, 1080],
    ["06_R1_HERO_READY", "hero", 1920, 1080],
    ["07_R1_HERO_COOLDOWN", "hero_cooldown", 1920, 1080],
    ["08_R1_WORKER_BUILD_MENU", "worker_build", 1920, 1080],
    ["09_R1_CLANHOLD", "clanhold", 1920, 1080],
    ["10_R1_WAR_HALL", "warhall", 1920, 1080],
    ["11_R1_DISABLED_STATE", "disabled", 1920, 1080],
    ["12_R1_TOOLTIP", "tooltip", 1920, 1080],
    ["13_R1_COMPACT", "hero", 1366, 768],
  ];
  const selectedJobs = process.env.P1R1_ONLY ? jobs.filter(job => job[0] === process.env.P1R1_ONLY) : jobs;
  const manifests = withAutoload(() => selectedJobs.map(([name, view, width, height]) => {
    try { return run(name, view, width, height, path.join(runDir, name)); }
    catch (error) { return { name, view, width, height, pass: false, failures: [String(error.message || error)] }; }
  }));
  const failures = [];
  for (const manifest of manifests) {
    const optionalWarHall = manifest.view === "warhall" && (manifest.failures || []).some(x => String(x).includes("missing_target"));
    if (!optionalWarHall && !manifest.pass) failures.push(...(manifest.failures || [`${manifest.view}:capture_failed`]));
    for (const frame of manifest.frames || []) {
      if (!existsSync(frame.png) || readFileSync(frame.png).length < 20000) failures.push(`${manifest.view}:image`);
    }
  }
  const referenceRoot = "D:\\CodexData\\evidence\\p1-task605-command-card-redesign\\before\\run-20260829122402-37c43076";
  const referenceCopies = [
    ["01_TASK605_WORKER_REFERENCE.png", path.join(referenceRoot, "01_BEFORE_WORKER_COMMAND_CARD", "01_BEFORE_WORKER_COMMAND_CARD.png")],
    ["03_TASK605_MILITARY_REFERENCE.png", path.join(referenceRoot, "02_BEFORE_MILITARY_COMMAND_CARD", "02_BEFORE_MILITARY_COMMAND_CARD.png")],
    ["05_TASK605_HERO_REFERENCE.png", path.join(referenceRoot, "03_BEFORE_HERO_COMMAND_CARD", "03_BEFORE_HERO_COMMAND_CARD.png")],
  ].map(([name, source]) => copyReference(source, path.join(evidenceRoot, name)));
  for (const reference of referenceCopies) if (!reference.copied) failures.push(`missing_reference:${reference.source}`);
  const captures = manifests.flatMap(manifest => (manifest.frames || []).map(frame => ({ ...frame, sha256: sha256(frame.png) })));
  const evidence = {
    schema: "ascendant-realms-task605-r1-command-card-v1",
    source_sha: sourceSha(),
    parent_sha: parentSha(),
    baseline_next: refSha("refs/heads/codex/current-godot-baseline-next"),
    canonical: refSha("refs/heads/codex/current-godot-baseline"),
    run_dir: runId,
    godot,
    jobs: selectedJobs,
    manifests,
    captures,
    reference_copies: referenceCopies,
    pass: failures.length === 0,
    failures,
  };
  writeFileSync(path.join(evidenceRoot, "task605-r1-capture-manifest.json"), JSON.stringify(evidence, null, 2) + "\n");
  console.log(JSON.stringify(evidence, null, 2));
  if (failures.length) process.exitCode = 1;
}

function validate() {
  const failures = [];
  const hud = readFileSync(path.join(project, "scripts", "ui", "hud.gd"), "utf8");
  for (const contract of ["_command_kind", "ABILITY", "command_status_label", "tooltip_text", "_ability_glyph_stylebox"]) {
    if (!hud.includes(contract)) failures.push(`missing R1 contract: ${contract}`);
  }
  const manifestFile = path.join(evidenceRoot, "task605-r1-capture-manifest.json");
  if (!existsSync(manifestFile)) failures.push("missing capture manifest");
  else {
    const manifest = JSON.parse(readFileSync(manifestFile, "utf8"));
    if (manifest.source_sha !== sourceSha()) failures.push("source_sha");
    if (manifest.parent_sha !== parentSha()) failures.push("parent_sha");
    if (manifest.baseline_next !== refSha("refs/heads/codex/current-godot-baseline-next")) failures.push("baseline_next");
    if (manifest.canonical !== refSha("refs/heads/codex/current-godot-baseline")) failures.push("canonical");
    if (!manifest.pass) failures.push(...(manifest.failures || ["capture_failed"]));
    for (const name of ["02_R1_WORKER", "04_R1_MILITARY", "06_R1_HERO_READY", "07_R1_HERO_COOLDOWN", "08_R1_WORKER_BUILD_MENU", "09_R1_CLANHOLD", "11_R1_DISABLED_STATE", "12_R1_TOOLTIP", "13_R1_COMPACT"]) {
      if (!(manifest.captures || []).some(frame => frame.name === name)) failures.push(`missing ${name}`);
    }
    for (const name of ["01_TASK605_WORKER_REFERENCE.png", "03_TASK605_MILITARY_REFERENCE.png", "05_TASK605_HERO_REFERENCE.png"]) {
      if (!existsSync(path.join(evidenceRoot, name))) failures.push(`missing ${name}`);
    }
  }
  const cfg = readFileSync(path.join(project, "project.godot"), "utf8");
  if (cfg.includes("P1R22Capture")) failures.push("capture autoload persisted");
  const report = { schema: "ascendant-realms-task605-r1-validator-v1", source_sha: sourceSha(), evidence_root: evidenceRoot, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "task605-r1-validator-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}

if ((process.argv[2] || "validate") === "capture") capture();
else validate();
