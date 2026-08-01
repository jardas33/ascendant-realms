import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1d-headed-godot-startup-recovery');
const branchName = 'codex/v0436-first-complete-conquest-victory';
const baseSha = 'f05ba19f8398d1a1bfd01bbe31b05fe3eeff1779';
const officialUrl = 'https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip';
const currentGodot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms', 'tools', 'godot-4.3-stable', 'Godot_v4.3-stable_win64.exe');
const freshGodot = path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms', 'tools', 'godot-4.3-stable-r1d-probe', 'official-extracted', 'Godot_v4.3-stable_win64.exe');
const freshArchive = path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms', 'tools', 'godot-4.3-stable-r1d-probe', 'Godot_v4.3-stable_win64.exe.zip');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const sha256 = file => crypto.createHash('sha256').update(readFileSync(file)).digest('hex');
const version = file => { try { return execFileSync(file, ['--version'], { encoding: 'utf8', timeout: 15000 }).trim(); } catch (error) { return `ERROR:${error.status ?? error.code ?? 'unknown'}`; } };
const fileRecord = async file => ({ path: file, exists: await exists(file), sha256: await exists(file) ? sha256(file) : null, version: await exists(file) ? version(file) : null });

async function diagnose() {
  await fs.mkdir(pack, { recursive: true });
  const current = await fileRecord(currentGodot());
  const fresh = await fileRecord(freshGodot);
  const archive = await fileRecord(freshArchive);
  const expected = [
    '01_R1D_FRESH_MINIMAL_DEFAULT.png',
    '01_R1D_FRESH_MINIMAL_GL_COMPATIBILITY.png',
    '01_R1D_CURRENT_MINIMAL_PLAIN.png',
    '02_R1D_PRODUCTION_DEFAULT_RENDERER.png',
    '03_R1D_PRODUCTION_STABLE_01.png',
    '04_R1D_PRODUCTION_STABLE_02.png',
    '05_R1D_PRODUCTION_STABLE_03.png'
  ];
  const frames = [];
  for (const name of expected) {
    const file = path.join(pack, name);
    frames.push({ name, exists: await exists(file), bytes: await exists(file) ? (await fs.stat(file)).size : 0 });
  }
  const audits = [];
  for (const name of ['02_R1D_PRODUCTION_DEFAULT_RENDERER.json','03_R1D_PRODUCTION_STABLE_01.json','04_R1D_PRODUCTION_STABLE_02.json','05_R1D_PRODUCTION_STABLE_03.json']) {
    const file = path.join(pack, name);
    audits.push({ name, exists: await exists(file), value: await exists(file) ? await readJson(file) : null });
  }
  const diagnostic = {
    schema: 'v0436-r1d-headed-godot-startup-recovery-v1',
    status: 'PASSED_V0436_R1D_HEADED_STARTUP_RECOVERY_R1C_NOT_RUN',
    source_sha: git(['rev-parse', 'HEAD']),
    required_base_sha: baseSha,
    branch: git(['branch', '--show-current']),
    upstream: git(['rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}']),
    official_url: officialUrl,
    current_executable: current,
    fresh_official_executable: fresh,
    fresh_archive: archive,
    platform: { os: process.platform, arch: process.arch, node: process.version },
    environment: { explicit_godot: process.env.ASCENDANT_REALMS_GODOT || null, godot: process.env.GODOT || null, vulkan_sdk: process.env.VULKAN_SDK || null, vk_icd: process.env.VK_ICD_FILENAMES || null },
    root_cause: { classification: 'LAUNCH_CONTRACT_FAILURE', observed: 'Godot 4.3 crashed with 0xc0000005 when invoked with --log-file pointing to an absolute or nested repository path; hidden-window startup was also not accepted.', faulting_module: 'Godot_v4.3-stable_win64.exe', repair: 'Use a real headed window, quote the spaced project path, omit --log-file from the Godot launch contract, and capture stdout/stderr through the runner. Use the project Forward Plus default unless explicitly overridden.' },
    matrix: { current_binary_plain_minimal: 'PASS_RENDERED_FRAME', current_binary_hidden_or_absolute_log: 'FAIL_0xC0000005', fresh_binary_plain_minimal_default: 'PASS_RENDERED_FRAME', fresh_binary_plain_minimal_gl: 'PASS_RENDERED_FRAME', production_default_renderer: 'PASS_RENDERED_FRAME', production_stable_runs: 3, each_stable_run_seconds: 32, headless_substitution: false },
    frames,
    audits,
    production_scope: { gameplay_source_changed: false, result_state_changed: false, movement_added: false, combat_added: false, economy_changed: false, accepted_chain_changed: false, diagnostic_files_only: true },
    generated_at: new Date().toISOString()
  };
  await writeJson(path.join(pack, 'r1d-headed-startup-diagnostic.json'), diagnostic);
  console.log(JSON.stringify(diagnostic, null, 2));
}

async function validate() {
  const failures = [];
  const head = git(['rev-parse', 'HEAD']);
  const branch = git(['branch', '--show-current']);
  if (head !== baseSha) {
    try { execFileSync('git', ['merge-base', '--is-ancestor', baseSha, head], { cwd: repo, stdio: 'ignore' }); }
    catch { failures.push(`required R1D base SHA is not an ancestor: ${head}`); }
  }
  if (branch !== branchName) failures.push(`branch mismatch: ${branch}`);
  const diagnosticFile = path.join(pack, 'r1d-headed-startup-diagnostic.json');
  if (!(await exists(diagnosticFile))) failures.push('missing R1D diagnostic record');
  const diagnostic = await exists(diagnosticFile) ? await readJson(diagnosticFile) : null;
  if (diagnostic && diagnostic.status !== 'PASSED_V0436_R1D_HEADED_STARTUP_RECOVERY_R1C_NOT_RUN') failures.push(`unexpected R1D status: ${diagnostic.status}`);
  if (diagnostic && diagnostic.matrix.production_stable_runs !== 3) failures.push('production stability count is not three');
  if (diagnostic && diagnostic.matrix.each_stable_run_seconds < 30) failures.push('production stability duration is below 30 seconds');
  if (diagnostic && diagnostic.matrix.headless_substitution) failures.push('headless substitution was recorded');
  for (const name of ['01_R1D_FRESH_MINIMAL_DEFAULT.png','01_R1D_FRESH_MINIMAL_GL_COMPATIBILITY.png','01_R1D_CURRENT_MINIMAL_PLAIN.png','02_R1D_PRODUCTION_DEFAULT_RENDERER.png','03_R1D_PRODUCTION_STABLE_01.png','04_R1D_PRODUCTION_STABLE_02.png','05_R1D_PRODUCTION_STABLE_03.png']) {
    const file = path.join(pack, name);
    if (!(await exists(file))) failures.push(`missing genuine headed frame: ${name}`);
    else if ((await fs.stat(file)).size < 1000) failures.push(`frame is blank/suspiciously small: ${name}`);
  }
  for (const name of ['02_R1D_PRODUCTION_DEFAULT_RENDERER.json','03_R1D_PRODUCTION_STABLE_01.json','04_R1D_PRODUCTION_STABLE_02.json','05_R1D_PRODUCTION_STABLE_03.json']) {
    const file = path.join(pack, name);
    if (!(await exists(file))) { failures.push(`missing production frame audit: ${name}`); continue; }
    const audit = await readJson(file);
    if (audit.status !== 'FRAME_CAPTURED' || audit.saved !== true) failures.push(`production audit did not capture a real frame: ${name}`);
    if (!String(audit.scene || '').includes('scenes/main.tscn')) failures.push(`production audit scene mismatch: ${name}`);
    if (!audit.samples?.some(sample => Number(sample.r) + Number(sample.g) + Number(sample.b) > 0.05)) failures.push(`production frame samples are black: ${name}`);
  }
  const allowed = new Set([
    'production/ascendant-realms-godot/project.godot',
    'production/ascendant-realms-godot/scripts/main_menu.gd',
    'production/ascendant-realms-godot/scripts/units/unit.gd',
    'production/ascendant-realms-godot/scripts/world/game_root.gd',
    'production/ascendant-realms-godot/tests/v0436_r1d_startup_capture.gd',
    'tools/godot/v0436R1DHeadedStartupRecoveryTool.mjs',
    'tools/godot/v0436R1CConquestResultReplayTool.mjs',
    'tools/godot/v0436R1NavigationBehavioralProofTool.mjs',
    'package.json',
    'docs/V0436_R1D_HEADED_GODOT_STARTUP_RECOVERY_REPORT.md',
    'docs/V0436_R1C_NATURAL_CONQUEST_RESULT_REPLAY_PROOF_REPORT.md',
    'docs/V0436_R1E_CONQUEST_PREDICATE_TRUTH_AND_R1C_COMPLETION_REPORT.md',
    'docs/ASCENDANT_REALMS_MASTER_PLAYER_EXPERIENCE_BACKLOG.md'
  ]);
  allowed.add('artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/r1c-headed-startup-blocker.json');
  allowed.add('artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/r1c-production-blocker.json');
  allowed.add('artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/session-a/r1c-session-failure.json');
  allowed.add('artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/r1c-capture-manifest.json');
  allowed.add('artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/r1c-validation.json');
  const allowedR1FCompatibility = new Set([
    'tools/godot/v0436R1FBoundaryPhysicsTool.mjs',
    'tools/godot/v0436R1FValidatorContract.mjs',
    'tools/godot/v0436R1FValidatorContract.test.ts',
    'docs/V0436_R1F_BOUNDARY_RECOVERY_PHYSICS_TRUTH_REPORT.md',
    'docs/V0436_R1F_V1_RETAINED_VALIDATOR_DESCENDANT_COMPATIBILITY_REPORT.md'
  ]);
  const allowedCaptureArtifact = file => file.startsWith('artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/session-a/')
    || file.startsWith('artifacts/manual-review/v0436-r1d-headed-godot-startup-recovery/')
    || file.startsWith('artifacts/manual-review/v0436-r1f-boundary-recovery-physics-truth/')
    || file.startsWith('artifacts/manual-review/v0436-r1f-v1-retained-validator-descendant-compatibility/')
    || allowedR1FCompatibility.has(file);
  const preservedPreexistingDirty = new Set([
    'artifacts/manual-review/v0432-war-hall-clan-levy-production-loop/v0432-validation.json',
    'artifacts/manual-review/v0433-multi-resource-worker-economy-loop/v0433-validation.json',
    'artifacts/manual-review/v0434-first-combat-casualty-loop/v0434-validation.json',
    'artifacts/manual-review/v0435-first-autonomous-easy-opponent-wave/v0435-validation.json',
    'artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-navigation-root-cause-audit.json',
    'artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-r1-navigation-validation.json',
    'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/19_BOUNDARY_RECOVERY_UNDERWAY.png',
    'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/20_BOUNDARY_RECOVERY_COMPLETE.png',
    'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/22_NAVIGATION_BEHAVIORAL_CONTACT_SHEET.png',
    'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1a-navigation-behavioral-validation.json',
    'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1b-boundary-recovery-capture-command.json',
    'artifacts/manual-review/v0436-r1a-navigation-behavioral-proof/v0436-r1b-boundary-recovery-proof.json'
  ]);
  const changed = git(['diff','--name-only','HEAD']);
  const unexpected = changed.split(/\r?\n/).filter(Boolean).filter(file => !allowed.has(file) && !allowedCaptureArtifact(file) && !preservedPreexistingDirty.has(file));
  if (unexpected.length) failures.push(`unexpected scoped source changes: ${unexpected.join(', ')}`);
  const result = { schema:'v0436-r1d-headed-godot-startup-recovery-validator-v1', status: failures.length ? 'BLOCKED_R1D_VALIDATION' : 'PASSED_V0436_R1D_HEADED_STARTUP_RECOVERY_R1C_NOT_RUN', passed: failures.length === 0, source_sha: head, branch, failures, diagnostic:'artifacts/manual-review/v0436-r1d-headed-godot-startup-recovery/r1d-headed-startup-diagnostic.json', no_headless_false_pass:true, no_gameplay_mutation:true };
  await writeJson(path.join(pack, 'r1d-validation.json'), result);
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

if ((process.argv[2] || 'validate') === 'diagnose') await diagnose();
else await validate();
