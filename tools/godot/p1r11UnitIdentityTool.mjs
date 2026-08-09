import { existsSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const repo = path.resolve(import.meta.dirname, "../..");
const project = path.join(repo, "production/ascendant-realms-godot");
const evidenceRoot = process.env.P1R11_EVIDENCE_ROOT || "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-b\\p1r11";
mkdirSync(evidenceRoot, { recursive: true });
const sourceSha = execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const mode = process.argv[2] || "validate";
function validate() {
  const failures = [];
  const script = readFileSync(path.join(project, "scripts/units/unit.gd"), "utf8");
  for (const snippet of ["var _team_marker: MeshInstance3D", "_team_marker.name = \"TeamPip\"", "mat.albedo_color = commander.color", "selection, combat, hitboxes"]) if (!script.includes(snippet)) failures.push(`missing identity contract: ${snippet}`);
  const p1r7 = "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-b\\p1r7\\p1r7-capture-manifest.json";
  if (!existsSync(p1r7)) failures.push("missing refreshed p1r7 identity capture manifest");
  else { const m = JSON.parse(readFileSync(p1r7, "utf8")); if (m.source_sha !== sourceSha) failures.push("p1r7 source sha mismatch"); if (!m.pass) failures.push(...(m.failures || ["p1r7 capture failed"])); }
  const report = { schema: "ascendant-realms-p1r11-validator-v1", source_sha: sourceSha, evidence_root: evidenceRoot, required: true, pass: failures.length === 0, failures };
  writeFileSync(path.join(evidenceRoot, "p1r11-validator-report.json"), JSON.stringify(report, null, 2) + "\n"); console.log(JSON.stringify(report, null, 2)); if (failures.length) process.exitCode = 1;
}
if (mode === "validate") validate();
