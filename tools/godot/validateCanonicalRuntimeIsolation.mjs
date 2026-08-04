import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const projectRoot = path.join(repo, 'production', 'ascendant-realms-godot');
const baseSha = 'ad4ef9f895a60748af3ac0be8def9028adaa9f6c';
const captureAutoloads = {
  V0431Capture: ['ASCENDANT_V0431_CAPTURE', 'tests/v0431_capture.gd'],
  V0432Capture: ['ASCENDANT_V0432_CAPTURE', 'tests/v0432_capture.gd'],
  V0433Capture: ['ASCENDANT_V0433_CAPTURE', 'tests/v0433_capture.gd'],
  V0434Capture: ['ASCENDANT_V0434_CAPTURE', 'tests/v0434_capture.gd'],
  V0435Capture: ['ASCENDANT_V0435_CAPTURE', 'tests/v0435_capture.gd'],
  V0436Capture: ['ASCENDANT_V0436_CAPTURE', 'tests/v0436_capture.gd'],
  V0436R1Capture: ['ASCENDANT_V0436_R1_CAPTURE', 'tests/v0436_r1_navigation_behavioral_proof.gd'],
  V0436R1FCapture: ['ASCENDANT_V0436_R1F_CAPTURE', 'tests/v0436_r1f_boundary_physics.gd'],
  V0436R1CCapture: ['ASCENDANT_V0436_R1C_CAPTURE', 'tests/v0436_r1c_capture.gd'],
  V0436R1DStartupCapture: ['ASCENDANT_V0436_R1D_STARTUP_CAPTURE', 'tests/v0436_r1d_startup_capture.gd'],
  V0436R1GCapture: ['ASCENDANT_V0436_R1G_CAPTURE', 'tests/v0436_r1g_capture.gd'],
  V0436R1HCapture: ['ASCENDANT_V0436_R1H_CAPTURE', 'tests/v0436_r1h_capture.gd'],
  V0436R1JCapture: ['ASCENDANT_V0436_R1J_CAPTURE', 'tests/v0436_r1j_capture.gd'],
  V0436R1KCapture: ['ASCENDANT_V0436_R1K_CAPTURE', 'tests/v0436_r1k_capture.gd'],
};
const constPaths = [
  'production/ascendant-realms-godot/tests/capture_autoload_gate.gd',
  ...Object.values(captureAutoloads).map(([, script]) => `production/ascendant-realms-godot/${script}`),
  'production/ascendant-realms-godot/tests/capture_autoload_isolation_test.gd',
  'tools/godot/validateCanonicalRuntimeIsolation.mjs',
];

const failures = [];
const read = (file) => fs.readFileSync(path.join(repo, file), 'utf8');
const fail = (message) => failures.push(message);
const project = read('production/ascendant-realms-godot/project.godot');
const gate = read('production/ascendant-realms-godot/tests/capture_autoload_gate.gd');

try {
  const head = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: repo, encoding: 'utf8' }).trim();
  if (head !== baseSha) fail(`HEAD ${head} does not equal required base ${baseSha}`);
  const porcelain = execFileSync('git', ['status', '--porcelain'], { cwd: repo, encoding: 'utf8' })
    .split(/\r?\n/).filter(Boolean).map((line) => line.slice(3));
  const changed = [...new Set(porcelain)];
  if (changed.some((file) => !constPaths.includes(file)) || changed.length !== constPaths.length) {
    fail(`changed manifest mismatch: ${JSON.stringify(changed)}`);
  }
  const diffCheck = execFileSync('git', ['diff', '--check'], { cwd: repo, encoding: 'utf8' });
  if (diffCheck.trim()) fail(`git diff --check output: ${diffCheck}`);
} catch (error) {
  fail(`git verification failed: ${error.message}`);
}

for (const [autoload, [env, script]] of Object.entries(captureAutoloads)) {
  const expectedRegistration = `${autoload}="*res://${script}"`;
  if (!project.includes(expectedRegistration)) fail(`project.godot registration missing or changed: ${expectedRegistration}`);
  if (!gate.includes(`"${autoload}": "${env}"`)) fail(`gate mapping missing: ${autoload} -> ${env}`);
  const source = read(`production/ascendant-realms-godot/${script}`);
  const inheritedGate = script.endsWith('v0436_r1f_boundary_physics.gd') || script.endsWith('v0436_r1j_capture.gd') || script.endsWith('v0436_r1k_capture.gd');
  if (!source.includes('preload("res://tests/capture_autoload_gate.gd")') && !inheritedGate) fail(`${script} missing shared gate preload`);
  const ready = source.indexOf('func _ready()');
  if (ready < 0) fail(`${script} has no _ready`);
  else {
    const body = source.slice(ready);
    const guard = body.indexOf(`CaptureGate.guard_autoload(self, "${autoload}")`);
    const firstStatement = body.search(/\n\s*[^\s#\n]/);
    if (guard < 0 || firstStatement < 0 || firstStatement > guard) fail(`${script} gate is not first _ready statement`);
  }
  const preReady = ready < 0 ? source : source.slice(0, ready);
  for (const pattern of ['DirAccess.', 'FileAccess.', 'Match.set_config', 'Engine.time_scale', 'change_scene', 'create_timer', 'connect(']) {
    if (preReady.includes(pattern)) fail(`${script} has pre-ready side effect ${pattern}`);
  }
}

if (!gate.includes('active_variables_for') || !gate.includes('active[0] == String(REGISTRY[autoload_name])')) fail('gate lacks exact-value single-owner decision logic');
for (const forbidden of ['Vector3', 'resources', 'combat', 'navigation', 'save', 'hp', 'stable_id']) {
  if (gate.toLowerCase().includes(forbidden)) fail(`gate contains forbidden semantic field ${forbidden}`);
}
const projectAtBase = execFileSync('git', ['show', `${baseSha}:production/ascendant-realms-godot/project.godot`], { cwd: repo, encoding: 'utf8' });
if (project.replace(/\r\n/g, '\n') !== projectAtBase.replace(/\r\n/g, '\n')) fail('project.godot changed');
const testSource = read('production/ascendant-realms-godot/tests/capture_autoload_isolation_test.gd');
for (const required of ['no capture variables', 'conflict', 'invalid', 'unknown', 'queue itself for deletion', 'matching node']) {
  if (!testSource.toLowerCase().includes(required.toLowerCase())) fail(`focused test missing assertion wording: ${required}`);
}

const result = { schema: 'godot-g1a-canonical-runtime-isolation-validator-v1', baseSha, allowedPaths: constPaths, failures, passed: failures.length === 0 };
console.log(JSON.stringify(result, null, 2));
if (failures.length) process.exitCode = 1;
