import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-first-complete-conquest-victory');
const baseSha = '73f01bdd76b35c1b7c43886d9fb48ffd9d936803';
const branchName = 'codex/v0436-first-complete-conquest-victory';
const exists = async p => { try { await fs.access(p); return true; } catch { return false; } };
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
function run(args) { execFileSync(godot(), args, { cwd: repo, stdio: 'inherit', env: process.env }); }
function focused() { run(['--headless', '--path', project, '--script', 'res://tests/v0436_navigation_repair.gd', '--quit-after', '20']); }
function smoke() { run(['--headless', '--path', project, '--quit-after', '30', '--log-file', path.join(pack, 'v0436-r1-navigation-smoke.log')]); }
async function validate() {
  const failures = [];
  const branch = git(['branch', '--show-current']);
  const head = git(['rev-parse', 'HEAD']);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, 'HEAD'], { cwd: repo, stdio: 'ignore' }); } catch { failures.push('expected v0.436 base is not an ancestor'); }
  const world = await fs.readFile(path.join(project, 'scripts/world/game_world.gd'), 'utf8');
  const unit = await fs.readFile(path.join(project, 'scripts/units/unit.gd'), 'utf8');
  const capture = await fs.readFile(path.join(project, 'tests/v0436_capture.gd'), 'utf8');
  for (const [label, ok] of [
    ['world readiness', world.includes('func is_navigation_ready()') && world.includes('map_get_iteration_id')],
    ['target projection', world.includes('navigation_target_snapshot') && world.includes('map_get_closest_point')],
    ['mesh-before-region assignment', world.indexOf('_build_flat_navmesh(nav') < world.indexOf('nav_region.navigation_mesh = nav')],
    ['deferred target', unit.includes('_navigation_target_pending') && unit.includes('navigation_target_deferred')],
    ['bounded retries', unit.includes('NAVIGATION_RETRY_BUDGET') && unit.includes('NAVIGATION_REPATH_INTERVAL')],
    ['terminal command contract', unit.includes('navigation_terminal_failure') && unit.includes('command_preserved_during_retry')],
    ['long waypoint accepted', !unit.includes('implausible_next_path_jump')],
    ['runtime probe wiring', capture.includes('v0436-navigation-runtime-probe.json')],
  ]) if (!ok) failures.push(`${label} missing`);
  const probePath = path.join(pack, 'v0436-navigation-runtime-probe.json');
  if (!(await exists(probePath))) failures.push('missing v0436-navigation-runtime-probe.json');
  else {
    const probe = JSON.parse(await fs.readFile(probePath, 'utf8'));
    if (probe.ready !== true || Number(probe.iteration) <= 0 || Number(probe.regions) < 1) failures.push('navigation map was not ready in headed probe');
    for (const unitAudit of probe.units || []) if (Number(unitAudit.direct_path_size) < 2) failures.push(`empty direct path for ${unitAudit.unit_id}`);
  }
  const result = { schema: 'v0436-r1-production-navigation-system-repair-validator-v1', baseSha, validationInputSha: head, branch, failures, passed: failures.length === 0, evidence: ['v0436-navigation-runtime-probe.json', '01_V0436_REAL_SKIRMISH_INITIAL_STATE.png', '02_V0436_PLAYER_WAR_HALL_BUILT.png', '03_V0436_PLAYER_ASSAULT_FORCE_READY.png', '04_V0436_ENEMY_COMMANDER_TARGET.png'] };
  await fs.mkdir(pack, { recursive: true });
  await fs.writeFile(path.join(pack, 'v0436-r1-navigation-validation.json'), JSON.stringify(result, null, 2) + '\n');
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}
const command = process.argv[2] || 'validate';
if (command === 'focused-tests') focused(); else if (command === 'smoke') smoke(); else await validate();
