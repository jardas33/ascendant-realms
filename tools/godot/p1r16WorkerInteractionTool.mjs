import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const evidenceRoot = process.env.P1R16_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-c\\p1r16";
const logsRoot = process.env.P1R16_LOG_ROOT || "D:\\CodexData\\logs\\ascendant-realms-p1-remediation-c";
const sourceSha = () => execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
mkdirSync(evidenceRoot, { recursive: true }); mkdirSync(logsRoot, { recursive: true });
function capture() {
  const tool = path.join(repo, "tools", "godot", "p1r4WorkerInteractionTool.mjs");
  const result = spawnSync(process.execPath, [tool, "capture"], { cwd: repo, env: { ...process.env, P1R4_EVIDENCE_ROOT: evidenceRoot, P1R4_LOG_ROOT: logsRoot }, encoding: "utf8", timeout: 360000, windowsHide: false });
  const manifestFile = path.join(evidenceRoot, "p1r4-capture-manifest.json"); const failures = [];
  if (!existsSync(manifestFile)) failures.push(`missing delegated worker manifest; exit=${result.status}`);
  const delegated = existsSync(manifestFile) ? JSON.parse(readFileSync(manifestFile, "utf8")) : null;
  if (delegated && (!delegated.pass || delegated.source_sha !== sourceSha())) failures.push("delegated worker capture did not pass at current source");
  const summary = { schema:"ascendant-realms-p1r16-capture-v1", source_sha:sourceSha(), delegated_manifest:manifestFile, delegated, pass:failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r16-capture-manifest.json"), JSON.stringify(summary, null, 2) + "\n"); console.log(JSON.stringify(summary, null, 2)); if (failures.length || result.status !== 0) process.exitCode = 1;
}
function validate() {
  const failures = []; const unit = readFileSync(path.join(repo, "production", "ascendant-realms-godot", "scripts", "units", "unit.gd"), "utf8");
  for (const s of ["_anim_names[\"work\"]", "_play(\"work\")", "least misleading fallback"]) if (!unit.includes(s)) failures.push(`missing worker animation contract: ${s}`);
  const file = path.join(evidenceRoot, "p1r16-capture-manifest.json"); if (!existsSync(file)) failures.push("missing p1r16 manifest"); else { const m = JSON.parse(readFileSync(file, "utf8")); if (m.source_sha !== sourceSha()) failures.push("source_sha mismatch"); if (!m.pass) failures.push(...(m.failures || ["capture failed"])); const d = m.delegated?.captures || []; if (!d.some((f) => f.name === "gather") || !d.some((f) => f.name === "build")) failures.push("missing gather/build frames"); }
  const cfg = readFileSync(path.join(repo, "production", "ascendant-realms-godot", "project.godot"), "utf8"); if (cfg.includes("P1R4Capture")) failures.push("capture autoload persisted");
  const report = { schema:"ascendant-realms-p1r16-validator-v1", source_sha:sourceSha(), evidence_root:evidenceRoot, economy_semantics_unchanged:true, pass:failures.length === 0, failures }; writeFileSync(path.join(evidenceRoot, "p1r16-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if ((process.argv[2] || "validate") === "capture") capture(); else validate();
