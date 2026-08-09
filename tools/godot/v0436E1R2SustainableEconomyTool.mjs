import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { E1R2_PACK, evaluateE1R2ValidatorContract } from './v0436E1R2SustainableEconomyValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const pack = path.join(repo, E1R2_PACK, 'session-a');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
async function focused() { execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436E1R2SustainableEconomyValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' }); }
async function validate() {
  const files = await fs.readdir(pack).catch(() => []);
  const config = await readJson(path.join(pack, 'match-configuration.json')).catch(() => null);
  const blocker = await readJson(path.join(pack, 'e1r-blocker.json')).catch(() => null);
  const production = await readJson(path.join(pack, 'production-audit.json')).catch(() => null);
  const source = await fs.readFile(path.join(repo, 'production/ascendant-realms-godot/tests/v0436_r1h_capture.gd'), 'utf8');
  const forbidden = ['set("hp"', 'set("is_dead"', 'set("defeated"', 'spawn_unit(', 'free_units'];
  const result = evaluateE1R2ValidatorContract({ branch: git(['branch', '--show-current']), head: git(['rev-parse', 'HEAD']), config, blocker, files, sourceWritesRejected: !forbidden.some(value => source.includes(value)), resourceTransactions: blocker?.resource_transactions?.length || 0, queueResults: production?.queue_results || [] });
  result.pack = E1R2_PACK;
  result.evidence = { files, configuration: config, last_valid_frame: blocker?.last_valid_frame || null, production_queue_count: production?.queue_results?.length || 0, resource_transaction_count: blocker?.resource_transactions?.length || 0, target_lifecycle_count: blocker?.target_lifecycles?.length || 0 };
  await fs.writeFile(path.join(repo, E1R2_PACK, 'e1r2-validation.json'), JSON.stringify(result, null, 2) + '\n');
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}
if ((process.argv[2] || 'validate') === 'focused-tests') await focused(); else await validate();
