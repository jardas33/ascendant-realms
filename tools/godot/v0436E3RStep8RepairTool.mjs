import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { E3R_STEP8_REPAIR_REQUIRED_FRAMES, evaluateE3RStep8RepairContract } from './v0436E3RStep8RepairValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const root = process.env.ASCENDANT_E3R_STEP8_REPAIR_ROOT || 'D:\\CodexData\\evidence\\ascendant-realms-core-playability-e\\E3R_STEP8_REPAIR\\FINAL';
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();

function focused() {
  execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436E3RStep8RepairValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' });
}

async function validate() {
  const manifest = await readJson(path.join(root, 'e3r-step8-repair-manifest.json'));
  const telemetry = await readJson(path.join(root, 'e3r-step8-telemetry.json'));
  const files = await fs.readdir(root);
  const result = evaluateE3RStep8RepairContract({ manifest, telemetry, files, sourceSha: git(['rev-parse', 'HEAD']), branch: git(['branch', '--show-current']) });
  result.root = root;
  result.source_sha = git(['rev-parse', 'HEAD']);
  result.branch = git(['branch', '--show-current']);
  result.telemetry_samples = telemetry.samples?.length || 0;
  await fs.writeFile(path.join(root, 'e3r-step8-repair-validation.json'), JSON.stringify(result, null, 2) + '\n');
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

if ((process.argv[2] || 'validate') === 'focused-tests') focused(); else await validate();
