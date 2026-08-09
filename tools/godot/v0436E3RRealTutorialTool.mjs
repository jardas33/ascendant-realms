import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { E3R_PACK, E3R_REQUIRED_FRAMES, evaluateE3RValidatorContract } from './v0436E3RRealTutorialValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, E3R_PACK);
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const isAncestor = sha => { try { execFileSync('git', ['merge-base', '--is-ancestor', sha, git(['rev-parse', 'HEAD'])], { cwd: repo, stdio: 'ignore' }); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const godot = process.env.ASCENDANT_REALMS_GODOT || 'D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe';

function focused() { execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436E3RRealTutorialValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' }); }
function smoke() { execFileSync(godot, ['--headless', '--path', project, '--script', 'res://scripts/ui/tutorial.gd', '--quit-after', '2'], { cwd: repo, stdio: 'inherit' }); }
async function validate() {
  const failures = [];
  const head = git(['rev-parse', 'HEAD']);
  const branch = git(['branch', '--show-current']);
  const source = await fs.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8').catch(() => '');
  for (const forbidden of ['set("hp"', 'set("is_dead"', 'set("defeated"', 'spawn_unit(', 'free_units']) if (source.includes(forbidden)) failures.push(`forbidden capture source pattern ${forbidden}`);
  const session = path.join(pack, 'session-a');
  const files = await fs.readdir(session).catch(() => []);
  const manifest = await readJson(path.join(session, 'e3r-tutorial-manifest.json')).catch(() => null);
  const blocker = await readJson(path.join(session, 'e3r-blocker.json')).catch(() => null);
  const sizes = [];
  for (const name of files.filter(value => value.endsWith('.png'))) {
    const stat = await fs.stat(path.join(session, name));
    sizes.push({ name, bytes: stat.size, rejected: stat.size < 4096 });
  }
  const evidenceSha = manifest?.provenance?.source_sha;
  const result = evaluateE3RValidatorContract({ branch, validatedHead: head, sourceSha: evidenceSha, sourceShaValid: Boolean(evidenceSha && isAncestor(evidenceSha)), manifest, files, blocker, sourceWritesRejected: failures.length === 0, blackFrameRejected: sizes.every(value => !value.rejected) });
  result.pack = E3R_PACK;
  result.evidence = { files, requiredFrames: E3R_REQUIRED_FRAMES, pngSizes: sizes, source_sha: manifest?.provenance?.source_sha || null };
  result.failures.push(...failures);
  result.passed = result.failures.length === 0;
  if (result.failures.length) result.status = 'BLOCKED_E3R_EVIDENCE_VALIDATION';
  await fs.mkdir(pack, { recursive: true });
  await fs.writeFile(path.join(pack, 'e3r-validation.json'), JSON.stringify(result, null, 2) + '\n');
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}
const command = process.argv[2] || 'validate';
if (command === 'focused-tests') focused(); else if (command === 'smoke') smoke(); else await validate();
