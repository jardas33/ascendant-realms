import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { execSync } from 'node:child_process';
import crypto from 'node:crypto';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0304-visual-archaeology-style-lock-recovery');
const report = join(repo, 'docs', 'V0304_VISUAL_ARCHAEOLOGY_STYLE_LOCK_RECOVERY_RUNTIME_GAP_ANALYSIS_REPORT.md');
const errors = [];

const requiredDocs = [
  'historical-reference-index.md',
  'historical-runtime-index.md',
  'visual-lineage-timeline.md',
  'missing-artifacts-register.md',
  'current-v0303-gap-analysis.md',
  'recommended-target-selection.md',
  'runtime-transition-options.md',
  'contact-sheets/v0304_historical_visual_candidates.png',
  'contact-sheets/v0304_current_v0303_runtime.png',
  'contact-sheets/v0304_current_and_historical_runtime.png',
  'contact-sheets/v0304_side_by_side_gap_analysis.png',
];
for (const file of requiredDocs) if (!existsSync(join(pack, file))) errors.push(`missing pack file: ${file}`);
if (!existsSync(report)) errors.push('missing v0.304 report');

const candidateIds = [
  'v0138-env-a-tactical-clarity',
  'v0138-env-b-barrosan-atmosphere',
  'v0138-env-c-modern-2_5d-balance',
  'v0141-env-r1-gameplay-first-barrosan',
  'v0141-env-r2-barrosan-signature',
  'v0141-env-r3-modern-balanced-ashen-contrast',
];
for (const id of candidateIds) {
  const image = join(pack, 'historical-reference', 'candidates', `${id}.png`);
  const metadataPath = join(pack, 'historical-reference', 'metadata', `${id}.json`);
  if (!existsSync(image)) errors.push(`missing indexed candidate image: ${id}`);
  if (!existsSync(metadataPath)) {
    errors.push(`missing indexed candidate metadata: ${id}`);
    continue;
  }
  try {
    const metadata = JSON.parse(readFileSync(metadataPath, 'utf8'));
    if (metadata.runtimeIntegrationStatus !== 'forbidden') errors.push(`candidate is not runtime-forbidden: ${id}`);
    if (metadata.licencePosture?.runtimeUse !== 'forbidden') errors.push(`candidate licence posture is not runtime-forbidden: ${id}`);
    if (!metadata.protectedIpReview || metadata.protectedIpReview.status !== 'pending') errors.push(`candidate IP review classification incomplete: ${id}`);
    const actualHash = crypto.createHash('sha256').update(readFileSync(image)).digest('hex');
    if (metadata.hash?.value !== actualHash) errors.push(`candidate hash mismatch: ${id}`);
  } catch (error) {
    errors.push(`invalid candidate metadata: ${id} (${error.message})`);
  }
}

const runtimeImages = [
  'historical-runtime/v0232_production_target_spike_overview.png',
  'historical-runtime/v0233_blender_kit_isolated_overview.png',
  'historical-runtime/v0234_composed_battlefield_overview.png',
  'historical-runtime/v0235_architecture_correction_overview.png',
  'historical-runtime/v0236_barrosan_production_slice_overview.png',
  'historical-runtime/v0236_terrain_road_river_integration.png',
  'current-v0303/v0303_player_overview_actual.png',
  'current-v0303/v0303_player_building_actual.png',
  'current-v0303/v0303_player_units_actual.png',
  'current-v0303/v0303_player_hud_actual.png',
  'current-v0303/v0303_player_capture_manifest.json',
];
for (const file of runtimeImages) if (!existsSync(join(pack, file))) errors.push(`missing indexed runtime evidence: ${file}`);

const indexFiles = requiredDocs.filter((file) => file.endsWith('.md')).map((file) => join(pack, file));
const indexText = indexFiles.map((file) => readFileSync(file, 'utf8')).join('\n');
const reportText = readFileSync(report, 'utf8');
for (const token of ['reference-only', 'runtimeIntegrationStatus', 'v0141-env-r1-gameplay-first-barrosan', 'v0.303', 'Select Aster', 'MISSING', 'PLAYER']) {
  if (!indexText.includes(token) && !reportText.includes(token)) errors.push(`report/index agreement token missing: ${token}`);
}

const packFiles = [];
function walk(dir) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) walk(path);
    else packFiles.push(relative(pack, path).replaceAll('\\', '/'));
  }
}
walk(pack);
for (const file of packFiles) {
  if (file.startsWith('desktop-spikes/') || file.startsWith('src/') || file.startsWith('public/assets/')) errors.push(`runtime/production path copied into review pack: ${file}`);
}

const status = execSync('git status --short', { cwd: repo, encoding: 'utf8' });
for (const line of status.split(/\r?\n/).filter(Boolean)) {
  const path = line.slice(3).trim().replaceAll('\\', '/');
  const allowed = path === 'package.json' || path === 'docs/V0304_VISUAL_ARCHAEOLOGY_STYLE_LOCK_RECOVERY_RUNTIME_GAP_ANALYSIS_REPORT.md' || path === 'tools/godot/saltoV0304VisualArchaeologyStyleLockRecoveryTool.mjs' || path.startsWith('artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/');
  if (!allowed) errors.push(`unexpected implementation mutation in working tree: ${path}`);
}

const output = {
  status: errors.length ? 'FAIL_V0304_VISUAL_ARCHAEOLOGY_VALIDATION' : 'PASS_V0304_VISUAL_ARCHAEOLOGY_STYLE_LOCK_RECOVERY_VALIDATION',
  indexedCandidates: candidateIds.length,
  indexedRuntimeEvidence: runtimeImages.length,
  requiredPackFiles: requiredDocs.length,
  runtimeImplementationMutation: errors.some((error) => error.includes('implementation mutation')),
  errors,
};
const outputPath = join(pack, 'v0304-validation-report.json');
if (existsSync(pack)) {
  const { writeFileSync } = await import('node:fs');
  writeFileSync(outputPath, `${JSON.stringify(output, null, 2)}\n`);
}
console.log(output.status);
console.log(`Historical candidates: ${candidateIds.length}`);
console.log(`Runtime evidence files: ${runtimeImages.length}`);
if (errors.length) {
  for (const error of errors) console.error(`- ${error}`);
  process.exitCode = 1;
}
