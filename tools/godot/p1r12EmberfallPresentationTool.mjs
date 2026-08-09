import { existsSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const evidenceRoot = process.env.P1R12_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-b\\p1r12";
mkdirSync(evidenceRoot, { recursive: true });
const sourceSha = execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
function validate() {
  const failures = [];
  const script = readFileSync(path.join(project, "scripts/world/map_defs.gd"), "utf8");
  for (const snippet of ["Color(0.68, 0.52, 0.50)", "Color(0.44, 0.34, 0.34)", '"fog_density": 0.0017', '"ambient_energy": 0.55']) if (!script.includes(snippet)) failures.push(`missing Emberfall contrast contract: ${snippet}`);
  const p1r9 = "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-b\\p1r9\\p1r9-capture-manifest.json";
  if (!existsSync(p1r9)) failures.push("missing refreshed Emberfall capture manifest");
  else { const m = JSON.parse(readFileSync(p1r9, "utf8")); if (m.source_sha !== sourceSha) failures.push("p1r9 source sha mismatch"); if (!m.pass) failures.push(...(m.failures || ["p1r9 capture failed"])); if (!(m.captures || []).some((f) => f.map === "emberfall_rift")) failures.push("missing Emberfall capture"); }
  const report = { schema: "ascendant-realms-p1r12-validator-v1", source_sha: sourceSha, evidence_root: evidenceRoot, emberfall_only: true, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r12-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
validate();
