import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import path from "node:path";
import { runBounded } from "../codex/runBounded.mjs";

const repo = path.resolve(import.meta.dirname, "../..");
const evidenceRoot = process.env.P1_UNITS_01_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-units-01";
const logsRoot = process.env.P1_UNITS_01_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-units-01";
const baselineRoot = process.env.P1_UNITS_01_BASELINE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-units-01\\baseline-p1r1";
const p1r1 = path.join(repo, "tools/godot/p1r1UnitReadabilityTool.mjs");
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const productionSourceSha = () => process.env.P1_UNITS_01_PRODUCTION_SOURCE_SHA || sourceSha();
const branchName = () => execFileSync("git", ["branch", "--show-current"], { cwd: repo, encoding: "utf8" }).trim();
const readJson = (file) => JSON.parse(readFileSync(file, "utf8"));

async function capture() {
  mkdirSync(evidenceRoot, { recursive: true });
  mkdirSync(logsRoot, { recursive: true });
  const result = await runBounded({
    command: process.execPath,
    args: [p1r1, "capture"],
    cwd: repo,
    env: {
      ...process.env,
      P1R1_EVIDENCE_ROOT: evidenceRoot,
      P1R1_LOG_ROOT: logsRoot,
      P1R1_CAPTURE_TIMESTAMP: process.env.P1_UNITS_01_CAPTURE_TIMESTAMP || "p1units01",
      ASCENDANT_REALMS_GODOT: process.env.ASCENDANT_REALMS_GODOT,
      P1R1_SOURCE_SHA_OVERRIDE: productionSourceSha(),
    },
    hardTimeoutMs: 600_000,
    label: "p1-units-01-capture",
  });
  const p1r1Manifest = path.join(evidenceRoot, "p1r1-capture-manifest.json");
  if (!existsSync(p1r1Manifest)) throw new Error("P1R1 capture did not produce a manifest");
  const manifest = readJson(p1r1Manifest);
  const review = {
    schema: "ascendant-realms-p1-units-01-capture-v1",
    branch: branchName(),
    source_sha: productionSourceSha(),
    validation_input_sha: sourceSha(),
    baseline_root: baselineRoot,
    after_root: evidenceRoot,
    capture_tool: "p1r1UnitReadabilityTool.mjs",
    manifest,
    pass: result.exit_code === 0 && manifest.source_sha === productionSourceSha() && manifest.pass === true,
    failures: result.exit_code === 0 && manifest.source_sha === productionSourceSha() && manifest.pass === true ? [] : ["underlying P1R1 capture failed or provenance mismatched"],
  };
  writeFileSync(path.join(evidenceRoot, "p1-units-01-capture-manifest.json"), JSON.stringify(review, null, 2) + "\n");
  console.log(JSON.stringify(review, null, 2));
  if (!review.pass) process.exitCode = 1;
}

function validate() {
  const failures = [];
  const unitPath = path.join(repo, "production/ascendant-realms-godot/scripts/units/unit.gd");
  const unit = readFileSync(unitPath, "utf8");
  for (const token of ["P1R22_WORKER_TEAM_TINT", "P1R22_MILITARY_TEAM_TINT", "P1R22_HERO_TEAM_TINT", "UnitContactShadow", "_build_p1r22_contact_shadow", "_debug_review_presentation"]) {
    if (!unit.includes(token)) failures.push(`missing P1-UNITS-01 contract: ${token}`);
  }
  const capturePath = path.join(evidenceRoot, "p1-units-01-capture-manifest.json");
  if (!existsSync(capturePath)) failures.push("missing p1-units-01 capture manifest");
  else {
    const capture = readJson(capturePath);
    if (capture.branch !== branchName()) failures.push("capture branch mismatch");
    if (capture.source_sha !== productionSourceSha()) failures.push("capture source SHA mismatch");
    if (capture.validation_input_sha !== sourceSha()) failures.push("validation input SHA mismatch");
    if (capture.pass !== true) failures.push(...(capture.failures || ["capture failed"]));
    if ((capture.manifest?.captures || []).length < 9) failures.push("insufficient dual-resolution unit captures");
  }
  const config = readFileSync(path.join(repo, "production/ascendant-realms-godot/project.godot"), "utf8");
  if (config.includes("P1R1Capture")) failures.push("capture autoload persisted");
  const report = { schema: "ascendant-realms-p1-units-01-validator-v1", source_sha: sourceSha(), evidence_root: evidenceRoot, baseline_root: baselineRoot, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1-units-01-validator-report.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  if (failures.length) process.exitCode = 1;
}

if (process.argv[2] === "capture") await capture();
else if (process.argv[2] === "validate") validate();
else throw new Error("Usage: node tools/godot/p1Units01Tool.mjs <capture|validate>");
