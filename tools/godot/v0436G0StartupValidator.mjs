import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const G0_FINAL_FILES = Object.freeze([
  '01_MAIN_MENU.png',
  '02_LOADING_ENTERED.png',
  '03_LOADING_PROGRESS.png',
  '04_GAMEWORLD_ORDINARY_RUN1.png',
  '05_GAMEWORLD_ORDINARY_RUN2.png',
  '06_GAMEWORLD_F2_HARNESS.png',
  '07_FIRST_PLAYABLE_HUD.png',
]);

export function validateG0Manifest(manifest, finalDir, { expectedHead = '07e55140acd737433dce9f14565310320aa0355a' } = {}) {
  const failures = [];
  if (manifest?.schema !== 'v0436-g0-startup-final-v1') failures.push('final startup manifest schema is missing or incorrect');
  if (manifest?.base_sha !== expectedHead) failures.push(`base SHA is ${manifest?.base_sha || 'missing'}, expected ${expectedHead}`);
  if (manifest?.branch !== 'codex/local-runtime-startup-g0') failures.push('G0 branch mismatch');
  if (manifest?.godot?.version !== '4.6.3.stable.official.7d41c59c4') failures.push('certified Godot version missing or incorrect');
  if (manifest?.godot?.sha256 !== 'EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00') failures.push('certified Godot hash missing or incorrect');
  if (manifest?.cold_cache_classification !== 'PASSED_G0_COLD_IMPORT_ENVIRONMENT_ONLY') failures.push('cold-cache classification is not the authorized truthful result');
  if (manifest?.production_code_repaired !== false) failures.push('G0 claims an unapproved production repair');
  if (manifest?.sequence_reentry_observed !== false) failures.push('startup sequence re-entry was not ruled out');

  const runs = manifest?.runs || {};
  for (const name of ['ordinary_run_1', 'ordinary_run_2', 'automated_run', 'f2_harness']) {
    const run = runs[name];
    if (!run) { failures.push(`missing run ${name}`); continue; }
    if (run.status !== 'PASSED_G0_STARTUP_REACHED_GAMEWORLD') failures.push(`${name} did not reach the passing startup status`);
    if (!run.game_root_seen || !run.game_world_seen || !run.hud_seen || !run.first_playable_frame_seen) failures.push(`${name} is missing GameRoot/GameWorld/HUD/first-frame evidence`);
    if (!run.settled) failures.push(`${name} lacks loader-settled evidence`);
    if (run.sequence_invocation_count !== 1) failures.push(`${name} sequence invocation count is ${run.sequence_invocation_count}, expected 1`);
  }

  for (const file of G0_FINAL_FILES) {
    const target = path.join(finalDir, file);
    if (!fs.existsSync(target)) failures.push(`missing final evidence ${file}`);
    else if (fs.statSync(target).size <= 1024) failures.push(`final evidence ${file} is empty or implausibly small`);
  }
  return { schema: 'v0436-g0-startup-validator-v1', passed: failures.length === 0, failures };
}

if (process.argv[1] && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url))) {
  const root = process.env.G0_EVIDENCE_ROOT || 'D:/CodexData/evidence/ascendant-realms-runtime-startup-g0';
  const finalDir = path.join(root, 'FINAL');
  const manifestPath = path.join(finalDir, 'startup-manifest.json');
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const result = validateG0Manifest(manifest, finalDir);
  console.log(JSON.stringify({ ...result, manifest: manifestPath }, null, 2));
  process.exitCode = result.passed ? 0 : 1;
}
