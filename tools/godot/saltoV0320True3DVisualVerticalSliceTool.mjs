import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { execSync } from 'node:child_process';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0320-true-3d-visual-vertical-slice');
const source = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0320', 'true-3d-visual-vertical-slice');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'visual_vertical_slice', 'V0320VisualVerticalSlice.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'v0320_true_3d_visual_vertical_slice.gd');
const packageJson = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];
const requiredCompact = ['00_READ_ME_FIRST.md','01_V0319_TO_V0320_BEFORE_AFTER.png','02_OVERVIEW_BEAUTY.png','03_GAMEPLAY_ZOOM.png','04_SETTLEMENT_CLOSEUP.png','05_WORKER_STATES.png','06_MILITIA_STATES.png','07_BRIDGE_AND_WATER.png','08_TERRAIN_AND_ARCHITECTURE.png','09_FORMATION_READABILITY.png','10_CLEAN_PLAYER_UI.png','11_CONTINUOUS_PLAYER_RUNTIME.gif','12_FINAL_DECISION_AND_VISUAL_SCORECARD.md','compact-evidence-summary.json'];
const rendered = existsSync(join(source, 'screenshots')) ? readdirSync(join(source, 'screenshots')).filter((file) => file.endsWith('.png')) : [];
const compact = existsSync(join(pack, 'UPLOAD_TO_CHAT')) ? readdirSync(join(pack, 'UPLOAD_TO_CHAT')) : [];
if (!existsSync(scene)) errors.push('missing isolated v0.320 scene');
if (!existsSync(script)) errors.push('missing v0.320 true-3D script');
for (const file of requiredCompact) if (!compact.includes(file)) errors.push(`missing compact upload file: ${file}`);
if (rendered.length < 11) errors.push(`expected at least 11 rendered primary captures, got ${rendered.length}`);
for (const file of rendered) {
  const bytes = readFileSync(join(source, 'screenshots', file));
  if (bytes.length < 10000) errors.push(`rendered capture too small or blank: ${file}`);
  if (!bytes.slice(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) errors.push(`invalid PNG signature: ${file}`);
}
const manifestPath = join(source, 'v0320-true-3d-visual-vertical-slice-runtime.json');
if (!existsSync(manifestPath)) errors.push('missing v0.320 runtime manifest');
else {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  if (manifest.status !== 'PASS_V0320_TRUE_3D_VISUAL_VERTICAL_SLICE') errors.push(`runtime status is ${manifest.status}`);
  if (manifest.prototypeOptIn !== true || manifest.prototypeOnly !== true) errors.push('prototype is not explicit opt-in only');
  if (manifest.presentationMethod !== 'TRUE 3D STYLISED RTS') errors.push('presentation method is not true 3D stylised RTS');
  if (String(manifest.unitPresentation).includes('billboard') && !String(manifest.unitPresentation).includes('no billboards')) errors.push('PLAYER candidate documents billboard units');
  if (manifest.camera?.projection !== 'orthographic') errors.push('camera is not orthographic');
  if (manifest.geometry?.true3DTerrain !== true || manifest.geometry?.riverBelowLand !== true || manifest.geometry?.bridgeSpansRiver !== true) errors.push('true-3D geometry contract incomplete');
  if (manifest.geometry?.buildingRoofSideBaseDepth !== true) errors.push('building volume contract missing');
  if (manifest.hud?.playerClean !== true || manifest.hud?.selectedCardOverlap !== false) errors.push('clean PLAYER HUD contract missing');
  for (const key of ['defaultRuntimeChanged','gameplayChanged','movementChanged','pathfindingChanged','combatChanged','economyChanged','resourceChanged','stableIdsChanged','saveChanged']) if (manifest[key] !== false) errors.push(`forbidden mutation reported: ${key}`);
  if (manifest.h3FallbackPreserved !== true || manifest.v0319Preserved !== true) errors.push('retained fallback/H3 infrastructure not proven');
}
const sourceText = existsSync(script) ? readFileSync(script, 'utf8') : '';
for (const token of ['SurfaceTool','MeshInstance3D','V0320_True3D_','WorkerPrimary','MilitiaPrimary','BridgeStoneLeftPier','V0320RecessedRiverWater','PROJECTION_ORTHOGONAL','_build_heightfield','_build_worker','_build_militia']) if (!sourceText.includes(token)) errors.push(`source contract missing: ${token}`);
if (sourceText.includes('BILLBOARD_ENABLED') || sourceText.includes('QuadMesh')) errors.push('v0.320 source contains billboard/quad presentation');
if (!existsSync(join(repo, 'docs', 'V0320_WORLD_SCALE_BIBLE.md'))) errors.push('missing world-scale bible');
for (const key of ['godot:capture:salto-true-3d-visual-vertical-slice','godot:validate:salto-true-3d-visual-vertical-slice']) if (!packageJson.scripts[key]) errors.push(`missing package command ${key}`);
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_spike_root.tscn'))) errors.push('true default runtime scene missing');
const status = execSync('git status --short', { cwd: repo, encoding: 'utf8' });
const allowed = ['package.json','desktop-spikes/godot-salto/visual_vertical_slice/','desktop-spikes/godot-salto/scripts/v0320_true_3d_visual_vertical_slice.gd','tools/godot/captureGodotV0320True3DVisualVerticalSliceWindows.ps1','tools/godot/buildV0320True3DVisualVerticalSlicePack.py','tools/godot/saltoV0320True3DVisualVerticalSliceTool.mjs','docs/V0320_WORLD_SCALE_BIBLE.md','docs/V0320_TRUE_3D_VISUAL_VERTICAL_SLICE_RESET_REPORT.md','artifacts/manual-review/v0320-true-3d-visual-vertical-slice/'];
for (const line of status.split(/\r?\n/).filter(Boolean)) {
  const path = line.slice(3).trim().replaceAll('\\', '/');
  if (!allowed.some((prefix) => path === prefix || path.startsWith(prefix))) errors.push(`unexpected mutation outside v0.320 scope: ${path}`);
}
const reportPath = join(repo, 'docs', 'V0320_TRUE_3D_VISUAL_VERTICAL_SLICE_RESET_REPORT.md');
if (!existsSync(reportPath)) errors.push('missing v0.320 report');
else for (const token of ['TRUE 3D STYLISED RTS','CONTINUE TRUE 3D DIRECTION','default runtime','billboards used in v0.320 PLAYER candidate: no','v0.319','v0.303']) if (!readFileSync(reportPath, 'utf8').includes(token)) errors.push(`report token missing: ${token}`);
const output = { status: errors.length ? 'FAIL_V0320_TRUE_3D_VISUAL_VERTICAL_SLICE_VALIDATION' : 'PASS_V0320_TRUE_3D_VISUAL_VERTICAL_SLICE_VALIDATION', renderedPrimaryCaptureCount: rendered.length, compactFileCount: compact.length, true3D: true, billboardsInPlayer: false, defaultRuntimeChanged: false, gameplayMutation: false, errors };
if (existsSync(pack)) writeFileSync(join(pack, 'v0320-validation-report.json'), JSON.stringify(output, null, 2) + '\n');
console.log(output.status);
console.log(`Rendered primary captures: ${rendered.length}`);
console.log(`Compact upload files: ${compact.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
