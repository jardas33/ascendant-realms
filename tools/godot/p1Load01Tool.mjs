import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import path from "node:path";
import { runBounded } from "../codex/runBounded.mjs";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const evidenceRoot = process.env.P1_LOAD01_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-load-01";
const logsRoot = process.env.P1_LOAD01_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-load-01";
const baselineRoot = process.env.P1_LOAD01_BASELINE_ROOT || path.join(evidenceRoot, "ordinary-run-1");
const afterRoot = process.env.P1_LOAD01_AFTER_ROOT || path.join(evidenceRoot, "final-after-runs");
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const branch = () => execFileSync("git", ["branch", "--show-current"], { cwd: repo, encoding: "utf8" }).trim();
const json = (file) => JSON.parse(readFileSync(file, "utf8"));
const safeName = (value) => value.replace(/[^a-zA-Z0-9_.-]/g, "-");

async function capture() {
  mkdirSync(afterRoot, { recursive: true });
  mkdirSync(logsRoot, { recursive: true });
  const runs = Number(process.env.P1_LOAD01_RUNS || 3);
  const records = [];
  for (let index = 1; index <= runs; index += 1) {
    const runRoot = path.join(afterRoot, `run-${index}`);
    mkdirSync(runRoot, { recursive: true });
    const log = path.join(logsRoot, `p1-load-01-final-${index}.log`);
    const timing = path.join(runRoot, "resource-timings.json");
    const bounded = await runBounded({
      command: godot,
      args: ["--path", project, "--resolution", "1920x1080", "--windowed", "--position", "20,20", "--log-file", log],
      cwd: repo,
      env: {
        ...process.env,
        TEMP: "D:\\CodexData\\temp",
        TMP: "D:\\CodexData\\temp",
        ASCENDANT_REALMS_GODOT: godot,
        ASCENDANT_P1_LOAD01: "1",
        ASCENDANT_P1_LOAD01_MODE: "A",
        ASCENDANT_P1_LOAD01_OUT: runRoot,
        ASCENDANT_P1_LOAD01_SOURCE_SHA: sourceSha(),
        ASCENDANT_P1_LOAD01_BRANCH: branch(),
        ASCENDANT_P1_LOAD01_TIMINGS: timing,
      },
      hardTimeoutMs: 600_000,
      label: `p1-load-01-final-${index}`,
    });
    const manifestPath = path.join(runRoot, "load-manifest.json");
    if (!existsSync(manifestPath)) throw new Error(`LOAD-01 run ${index} produced no load-manifest.json (exit ${bounded.exit_code})`);
    const manifest = json(manifestPath);
    records.push({
      index,
      root: runRoot,
      status: bounded.status,
      exit_code: bounded.exit_code,
      manifest,
      screenshot: path.join(runRoot, "01_LOAD01_PLAYABLE.png"),
      timings: timing,
      log,
    });
  }
  const playable = records.filter((record) => record.manifest.status === "PASSED_P1_LOAD01_REACHED_PLAYABLE_BATTLEFIELD");
  const elapsed = playable.map((record) => record.manifest.phases?.T9_BATTLEFIELD_PLAYABLE?.elapsed_s).filter(Number.isFinite);
  const summary = {
    schema: "ascendant-realms-p1-load-01-capture-v1",
    branch: branch(),
    source_sha: sourceSha(),
    godot,
    evidence_root: evidenceRoot,
    baseline_root: baselineRoot,
    after_root: afterRoot,
    runs: records,
    t1_to_t9_seconds: elapsed,
    median_t1_to_t9_seconds: median(elapsed),
    pass: records.length === runs && playable.length === runs && records.every((record) => record.manifest.source_sha === sourceSha() && record.manifest.branch === branch()),
    failures: [],
  };
  if (!summary.pass) summary.failures.push("one or more exact-head runs did not reach the playable battlefield or has provenance mismatch");
  writeFileSync(path.join(afterRoot, "p1-load-01-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(JSON.stringify(summary, null, 2));
  if (!summary.pass) process.exitCode = 1;
}

function median(values) {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
}

function validate() {
  const failures = [];
  const current = sourceSha();
  const currentBranch = branch();
  const capturePath = path.join(afterRoot, "p1-load-01-capture-manifest.json");
  if (!existsSync(capturePath)) failures.push("missing exact-head capture manifest");
  let capture = null;
  if (!failures.length) {
    capture = json(capturePath);
    if (capture.pass !== true) failures.push(...(capture.failures || ["capture manifest failed"]));
    if (capture.source_sha !== current) failures.push("capture source SHA mismatch");
    if (capture.branch !== currentBranch) failures.push("capture branch mismatch");
    if ((capture.runs || []).length < 3) failures.push("fewer than three exact-head after runs");
    for (const run of capture.runs || []) {
      const manifest = run.manifest;
      if (manifest.status !== "PASSED_P1_LOAD01_REACHED_PLAYABLE_BATTLEFIELD") failures.push(`run ${run.index} did not pass T9`);
      if (manifest.source_sha !== current) failures.push(`run ${run.index} source SHA mismatch`);
      if (manifest.branch !== currentBranch) failures.push(`run ${run.index} branch mismatch`);
      if (manifest.prototype_runtime !== false) failures.push(`run ${run.index} prototype runtime flag changed`);
      if (!existsSync(run.screenshot) || readFileSync(run.screenshot).length < 100 * 1024) failures.push(`run ${run.index} missing/blank playable screenshot`);
      const timings = run.timings;
      if (!existsSync(timings)) failures.push(`run ${run.index} missing resource timing ledger`);
      else if (json(timings).entries?.some((entry) => !["loaded_threaded", "loaded_fallback", "cached", "missing"].includes(entry.status))) failures.push(`run ${run.index} contains failed preload status`);
    }
  }
  const baselineFiles = ["ordinary-run-1", "ordinary-run-2", "ordinary-run-3"].map((name) => path.join(evidenceRoot, name, "load-manifest.json"));
  const baseline = [];
  for (const file of baselineFiles) {
    if (!existsSync(file)) failures.push(`missing measured baseline ${file}`);
    else baseline.push(json(file));
  }
  for (const manifest of baseline) {
    if (manifest.status !== "PASSED_P1_LOAD01_REACHED_PLAYABLE_BATTLEFIELD") failures.push("baseline run did not pass T9");
    if (manifest.configuration?.map !== "hollowspan" || manifest.configuration?.player_race !== "barrosan") failures.push("baseline configuration is not ordinary Hollowspan Barrosan setup");
  }
  const loading = readFileSync(path.join(project, "scripts/autoloads/loading_screen.gd"), "utf8");
  const observer = readFileSync(path.join(project, "tests/p1_load_01_observer.gd"), "utf8");
  for (const token of ["_run_preload_sequence_threaded", "ResourceLoader.load_threaded_request", "OS.has_feature(\"web\")", "P1Load01Observer"]) {
    if (!loading.includes(token) && !observer.includes(token)) failures.push(`missing LOAD-01 contract token ${token}`);
  }
  const config = readFileSync(path.join(project, "project.godot"), "utf8");
  if (!config.includes("P1Load01Observer=\"*res://tests/p1_load_01_observer.gd\"")) failures.push("capture observer autoload missing");
  const report = {
    schema: "ascendant-realms-p1-load-01-validator-v1",
    source_sha: current,
    branch: currentBranch,
    godot,
    baseline: baseline.map((manifest) => manifest.phases?.T9_BATTLEFIELD_PLAYABLE?.elapsed_s),
    after: capture?.t1_to_t9_seconds || [],
    capture_manifest: capturePath,
    failures,
    pass: failures.length === 0,
  };
  mkdirSync(evidenceRoot, { recursive: true });
  writeFileSync(path.join(evidenceRoot, "p1-load-01-validator-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (process.argv[2] === "capture") await capture();
else if (process.argv[2] === "validate") validate();
else throw new Error("Usage: node tools/godot/p1Load01Tool.mjs <capture|validate>");
