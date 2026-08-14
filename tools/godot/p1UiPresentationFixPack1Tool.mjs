import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {execFileSync} from "node:child_process";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const project = path.join(repo, "production", "ascendant-realms-godot");
const pack = path.join(repo, "artifacts", "manual-review", "p1-ui-presentation-fix-pack-1");
const godot = process.env.ASCENDANT_REALMS_GODOT || "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe";
const phase = process.env.ASCENDANT_P1_UI_PHASE || process.argv[3] || "final";

function git(args) { return execFileSync("git", args, {cwd: repo, encoding: "utf8"}).trim(); }
function runCapture() {
  execFileSync(godot, ["--path", project, "--resolution", "1920x1080", "--verbose", "--log-file", path.join(pack, `p1-${phase}-headed-runtime.log`)], {
    cwd: repo, stdio: "inherit", env: {...process.env, ASCENDANT_P1_UI_CAPTURE: "1", ASCENDANT_P1_UI_PHASE: phase}
  });
}
async function capture() {
  await fs.mkdir(pack, {recursive: true});
  runCapture();
  await fs.writeFile(path.join(pack, `p1-${phase}-capture-command.json`), JSON.stringify({
    schema: "ascendant-realms-p1-ui-presentation-fix-pack-1-command-v1",
    phase, headed: true, renderer: "Forward Plus", viewport: "1920x1080", godot,
    source_sha: git(["rev-parse", "HEAD"]), branch: git(["branch", "--show-current"]),
    project: "production/ascendant-realms-godot", no_direct_state_writes: true
  }, null, 2) + "\n");
}
async function validate() {
  const failures = [];
  const head = git(["rev-parse", "HEAD"]);
  const branch = git(["branch", "--show-current"]);
  if (branch !== "codex/p1-ui-presentation-fix-pack-1") failures.push(`branch=${branch}`);
  if (!(await fs.stat(project).catch(() => null))) failures.push("production project missing");
  const hud = await fs.readFile(path.join(project, "scripts/ui/hud.gd"), "utf8");
  const unit = await fs.readFile(path.join(project, "scripts/units/unit.gd"), "utf8");
  const portrait = await fs.readFile(path.join(project, "scripts/ui/entity_portrait_view.gd"), "utf8");
  if (!hud.includes("configure_definition") || !hud.includes("preview_definition")) failures.push("building preview plumbing missing");
	if (!unit.includes("_debug_review_presentation") || !unit.includes("team_tint")) failures.push("normal unit marker separation missing");
  if (!portrait.includes("configure_definition") || !portrait.includes("ambient_light_energy = 1.05")) failures.push("portrait readability treatment missing");
	for (const file of ["11_FINAL_OVERVIEW.png", "12_FINAL_BUILD_MENU_WORKER_SELECTED.png", "13_FINAL_WORKER_PORTRAIT.png", "15_FINAL_COMBINED_RTS_VIEW.png", "p1-final-capture-command.json", "p1-ui-capture-audit.json"]) {
		const p = path.join(pack, file);
		const stat = await fs.stat(p).catch(() => null);
		const minimum = file.endsWith(".png") ? 1024 : 128;
		if (!stat || stat.size < minimum) failures.push(`missing_or_small=${file}`);
	}
  const audit = JSON.parse(await fs.readFile(path.join(pack, "p1-ui-capture-audit.json"), "utf8").catch(() => "{}"));
  if (audit.phase !== "final" || audit.passed === false || audit.no_direct_state_writes !== true) failures.push("final capture audit not valid");
  const result = {schema: "ascendant-realms-p1-ui-presentation-fix-pack-1-validator-v1", head, branch, failures, passed: failures.length === 0};
  await fs.writeFile(path.join(pack, "p1-ui-validation.json"), JSON.stringify(result, null, 2) + "\n");
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; }
  else console.log(JSON.stringify(result, null, 2));
}
const command = process.argv[2] || "validate";
if (command === "capture") await capture(); else await validate();
