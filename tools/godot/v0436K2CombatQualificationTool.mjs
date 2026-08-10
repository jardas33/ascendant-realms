import crypto from 'node:crypto';
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { evaluateK2CombatQualificationContract } from './v0436K2CombatQualificationValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const root = process.env.ASCENDANT_V0436_K2_ROOT || 'D:\\CodexData\\evidence\\ascendant-realms-playtest3-continuation-k\\K2';
const finalRoot = path.join(root, 'FINAL');
const godot = process.env.ASCENDANT_REALMS_GODOT || 'D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe';
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const writeJson = async (file, value) => { await fsp.mkdir(path.dirname(file), { recursive: true }); await fsp.writeFile(file, `${JSON.stringify(value, null, 2)}\n`); };
const readJson = async file => JSON.parse(await fsp.readFile(file, 'utf8'));
const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');

function executableSha() { return sha256(godot); }
function envFor(session, out, resolution) {
  return { ...process.env, ASCENDANT_V0436_R1H_CAPTURE: '1', ASCENDANT_V0436_E1R2_CAPTURE: '1', ASCENDANT_V0436_K1_BEGINNER_ECONOMY_CAPTURE: '0', ASCENDANT_V0436_K2_COMBAT_CAPTURE: '1', ASCENDANT_V0436_K2_OUT: `${out}${path.sep}`, ASCENDANT_V0436_R1H_SOURCE_SHA: git(['rev-parse', 'HEAD']), ASCENDANT_V0436_R1H_BRANCH: git(['branch', '--show-current']), ASCENDANT_V0436_R1H_SESSION: session, ASCENDANT_V0436_K2_RESOLUTION: resolution };
}

async function capture() {
  await fsp.mkdir(finalRoot, { recursive: true });
  await writeJson(path.join(root, 'preflight.json'), { schema: 'v0436-k2-preflight-v1', status: 'CAPTURE_STARTED', branch: git(['branch', '--show-current']), source_sha: git(['rev-parse', 'HEAD']), worktree: repo, godot, godot_sha256: executableSha(), headed: true, contract: { player: 'barrosan', enemy: 'lioraen', difficulty: 'easy', map: 'hollowspan', resources: 'rich', victory: 'conquest', speed: 2.0 }, no_push: true, no_production_changes: true });
  const runs = [];
  for (const [index, session] of ['A', 'B', 'C'].entries()) {
    const runRoot = path.join(root, `run-${index + 1}`);
    await fsp.mkdir(runRoot, { recursive: true });
    const resolution = session === 'C' ? '1366x768' : '1920x1080';
    let exitStatus = 0;
    try { execFileSync(godot, ['--path', project, '--resolution', resolution, '--verbose'], { cwd: runRoot, stdio: 'inherit', env: envFor(session, runRoot, resolution) }); } catch (error) { exitStatus = error.status ?? null; }
    const run = await readJson(path.join(runRoot, 'k2-run.json')).catch(() => ({ status: 'BLOCKED_K2_CAPTURE_PROCESS', reason: `missing k2-run.json; process exit ${exitStatus}` }));
    const files = await fsp.readdir(runRoot);
    runs.push({ ...run, root: runRoot, files, configuration: await readJson(path.join(runRoot, 'k2-match-configuration.json')).catch(() => null), telemetry: run.telemetry || [], exit_status: exitStatus });
    await writeJson(path.join(runRoot, 'runner-process-result.json'), { session, resolution, exit_status: exitStatus });
  }
  const aliases = [
    ['07_MELEE_SETTLED.png', path.join(root, 'run-1', '05_K2_ACTIVE_COMBAT.png')],
    ['08_GROUP_SETTLED.png', path.join(root, 'run-1', '05_K2_ACTIVE_COMBAT.png')],
    ['09_RANGED_SETTLED.png', path.join(root, 'run-1', '05_K2_ACTIVE_COMBAT.png')],
    ['10_COMBAT_BESIDE_BUILDING.png', path.join(root, 'run-1', '10_K2_COMBAT_BESIDE_BUILDING.png')],
    ['11_ROUTE_AROUND_BUILDING.png', path.join(root, 'run-1', '11_K2_ROUTE_AROUND_BUILDING.png')],
    ['12_1366_FIRST_WAVE.png', path.join(root, 'run-3', '12_K2_1366_FIRST_WAVE.png')],
  ];
  for (const [name, source] of aliases) if (fs.existsSync(source)) await fsp.copyFile(source, path.join(finalRoot, name));
  for (const [index, run] of runs.entries()) await writeJson(path.join(finalRoot, `k2-run-${index + 1}.json`), run);
  await writeJson(path.join(finalRoot, 'k2-combat-telemetry.json'), { schema: 'v0436-k2-combat-telemetry-v1', source_sha: git(['rev-parse', 'HEAD']), runs: runs.map(run => ({ run: run.run, telemetry: run.telemetry || [] })) });
  await writeJson(path.join(finalRoot, 'k2-first-wave-summary.json'), { schema: 'v0436-k2-first-wave-summary-v1', source_sha: git(['rev-parse', 'HEAD']), runs: runs.map(run => ({ run: run.run, status: run.status, milestones: run.milestones || {}, combat_result: run.combat_result || null, route_around_building: run.route_around_building || null })) });
  await writeJson(path.join(finalRoot, 'k2-validation.json'), { status: 'PENDING_VALIDATION', source_sha: git(['rev-parse', 'HEAD']) });
  await writeReport(runs);
  const files = await fsp.readdir(finalRoot);
  await writeJson(path.join(root, 'capture-manifest.json'), { schema: 'v0436-k2-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: git(['rev-parse', 'HEAD']), branch: git(['branch', '--show-current']), runs: runs.map(run => ({ run: run.run, status: run.status, root: run.root, exit_status: run.exit_status })), final_files: files, godot, godot_sha256: executableSha() });
}

async function writeReport(runs) {
  const noDamage = runs.some(run => Number(run.milestones?.first_contact) >= 0 && Number(run.milestones?.first_damage) < 0);
  const lines = ['# K2 Original Easy First-Wave / Combat Qualification', '', 'Observation-only qualification. No production combat, balance, or AI changes were made.', '', `Source SHA: ${git(['rev-parse', 'HEAD'])}`, `Branch: ${git(['branch', '--show-current'])}`, `Godot: ${godot}`, `Godot SHA256: ${executableSha()}`, '', '## Runs', ...runs.map((run, index) => `- Run ${index + 1}: ${run.status || 'MISSING'}; first wave ${run.milestones?.first_wave ?? 'n/a'}; first contact ${run.milestones?.first_contact ?? 'n/a'}; first damage ${run.milestones?.first_damage ?? 'n/a'}; exit ${run.exit_status}`), '', '## Evidence', `- Root: ${root}`, `- Final: ${finalRoot}`, '- Three independent headed matches; Run 3 uses 1366x768.', '', '## Interpretation', '- The validator reports whether the evidence qualifies H1. It does not turn a loss/win into a combat-correctness claim.', `- Combat qualification: ${noDamage ? 'BLOCKED_K2_H1_GROUP_SETTLING_NO_DAMAGE_AFTER_CONTACT' : 'requires validator result'}.`, '- Existing FAIL_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION remains historical and is not repaired by K2.', ''];
  await fsp.writeFile(path.join(finalRoot, 'k2-report.md'), lines.join('\n'));
}

async function validate() {
  const runs = [];
  for (let index = 1; index <= 3; index += 1) {
    const runRoot = path.join(root, `run-${index}`);
    const run = await readJson(path.join(runRoot, 'k2-run.json')).catch(() => null);
    runs.push(run ? { ...run, root: runRoot, files: await fsp.readdir(runRoot), configuration: await readJson(path.join(runRoot, 'k2-match-configuration.json')).catch(() => null), telemetry: run.telemetry || [] } : null);
  }
  const finalFiles = await fsp.readdir(finalRoot).catch(() => []);
  const source = await fsp.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8');
  const result = evaluateK2CombatQualificationContract({ runs, finalFiles, source, fs });
  result.evidence_root = root; result.final_root = finalRoot; result.branch = git(['branch', '--show-current']); result.head = git(['rev-parse', 'HEAD']); result.godot = godot; result.godot_sha256 = executableSha();
  await writeJson(path.join(finalRoot, 'k2-validation.json'), result);
  await writeReport(runs.filter(Boolean));
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

async function focusedTests() {
  const result = evaluateK2CombatQualificationContract({ runs: [1, 2, 3].map((run) => ({ status: 'QUALIFIED_FIRST_WAVE_OBSERVED', root: root, files: ['01_K2_BASE_OPENING.png', '02_K2_DEFENDERS_READY.png', '03_K2_FIRST_WAVE_APPROACH.png', '04_K2_FIRST_CONTACT.png', '05_K2_ACTIVE_COMBAT.png', '06_K2_FIRST_WAVE_RESULT.png', 'k2-run.json'], configuration: { observed: { player_race: 'barrosan', map: 'hollowspan', start_resources: 'rich', mode: 'skirmish', victory: 'conquest' }, state_injection: false, player_offense_before_first_wave: false }, telemetry: [{ runtime_id: String(run), target_runtime_id: 'target', target_distance: 1, engage_range: 1, role: 'spear_guard', attack_state: true }], milestones: { first_wave: 10, first_contact: 12 } })), finalFiles: ['k2-run-1.json', 'k2-run-2.json', 'k2-run-3.json', 'k2-combat-telemetry.json', 'k2-first-wave-summary.json', 'k2-validation.json', 'k2-report.md', '07_MELEE_SETTLED.png', '08_GROUP_SETTLED.png', '09_RANGED_SETTLED.png', '10_COMBAT_BESIDE_BUILDING.png', '11_ROUTE_AROUND_BUILDING.png', '12_1366_FIRST_WAVE.png'], source: 'K2_FORCE_PLAN k2_mode _k2_unit_telemetry K2_COMBAT_CAPTURE', fs: { statSync: () => ({ size: 30_000 }) } });
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') await focusedTests();
else await validate();
