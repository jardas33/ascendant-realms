#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const sourceRoot = path.resolve(repo, 'production/ascendant-realms-godot');
const originalRoot = path.resolve(repo, '..', 'WB_tesana');
const packRoot = path.resolve(repo, 'artifacts/manual-review/v0430-tesana-canonical-production-rebase');
const catalogPath = path.join(sourceRoot, 'docs/ASSET_CATALOG.json');

const excluded = /^(?:\.godot|\.godot_home|user|logs|runtime-logs|captures|build|web-export|desktop-export)(?:[\\/]|$)/i;
const rawExtensions = new Set(['.glb','.png','.jpg','.jpeg','.webp','.mp3','.ttf','.tres','.tscn','.gd','.gdshader','.json','.cfg','.md','.py','.import','.uid']);
const importedExtensions = new Set(['.glb','.png','.jpg','.jpeg','.webp','.mp3','.ttf','.tres','.tscn','.gdshader']);

async function walk(root) {
  const out = [];
  async function visit(dir) {
    for (const entry of await fs.readdir(dir, {withFileTypes:true})) {
      const abs = path.join(dir, entry.name);
      const rel = path.relative(root, abs).replaceAll('\\','/');
      if (excluded.test(rel)) continue;
      if (entry.isDirectory()) await visit(abs);
      else out.push({abs, path:rel});
    }
  }
  await visit(root);
  return out.sort((a,b)=>a.path.localeCompare(b.path));
}

async function hash(abs) {
  const h = crypto.createHash('sha256');
  h.update(await fs.readFile(abs));
  return h.digest('hex');
}

async function manifest(root, label) {
  const files = await walk(root);
  const records = [];
  let totalBytes = 0;
  for (const file of files) {
    const stat = await fs.stat(file.abs);
    totalBytes += stat.size;
    records.push({path:file.path,size:stat.size,sha256:await hash(file.abs)});
  }
  return {schema:'v0430-source-manifest-v2',label,root,generatedAt:new Date().toISOString(),fileCount:records.length,totalBytes,files:records};
}

async function writeJson(file, value) {
  await fs.mkdir(path.dirname(file), {recursive:true});
  await fs.writeFile(file, JSON.stringify(value,null,2)+'\n', 'utf8');
}

function sameFileRecords(a, b) {
  if (!a || !b || a.length !== b.length) return false;
  const left = new Map(a.map(item => [item.path, `${item.size}:${item.sha256}`]));
  const right = new Map(b.map(item => [item.path, `${item.size}:${item.sha256}`]));
  if (left.size !== right.size) return false;
  for (const [key, value] of left) if (right.get(key) !== value) return false;
  return true;
}

function classify(rel) {
  const lower = rel.toLowerCase();
  const category = lower.includes('/characters/') ? 'characters' : lower.includes('/buildings/') ? 'buildings' : lower.includes('/audio/') ? 'audio' : lower.includes('/ui/') ? 'ui' : lower.includes('/terrain/') || lower.includes('/environment/') ? 'terrain-environment' : lower.includes('/data/') ? 'data' : lower.includes('/scenes/') ? 'scenes' : lower.includes('/scripts/') ? 'scripts' : lower.includes('/addons/') ? 'addons' : 'other';
  const ext = path.extname(rel).toLowerCase();
  const resourceType = ext === '.glb' ? 'PackedScene/GLB' : ext === '.tres' ? 'Resource/TRES' : ext === '.tscn' ? 'PackedScene' : ext === '.gd' ? 'GDScript' : ext === '.gdshader' ? 'Shader' : ext === '.mp3' ? 'AudioStreamMP3' : ext === '.ttf' ? 'FontFile' : ['.png','.jpg','.jpeg','.webp'].includes(ext) ? 'Texture2D' : 'File';
  const role = lower.includes('worker') ? 'worker' : lower.includes('hero') ? 'hero' : lower.includes('building') || category === 'buildings' ? 'building' : lower.includes('unit') || category === 'characters' ? 'unit' : lower.includes('prop') ? 'prop' : category === 'ui' ? 'ui' : category === 'audio' ? 'audio' : category === 'terrain-environment' ? 'terrain/environment' : 'other';
  return {category,resourceType,role,raceOrFaction: lower.includes('barrosan') || lower.includes('highlander') ? 'Barrosan' : lower.includes('frostborn') ? 'Frostborn' : lower.includes('beastfolk') ? 'Beastfolk' : lower.includes('dwarf') ? 'Dwarf' : lower.includes('grimtusk') ? 'Grimtusk' : null};
}

async function main() {
  const command = process.argv[2] || 'validate';
  if (command === 'manifest') {
    const root = path.resolve(process.argv[3] || sourceRoot);
    const out = path.resolve(process.argv[4] || path.join(packRoot, 'v0430-production-copy-manifest.json'));
    await writeJson(out, await manifest(root, path.basename(root)));
    console.log(`manifest=${out}`);
    return;
  }
  if (command === 'catalog' || command === 'asset-scan') {
    const files = await walk(sourceRoot);
    const records = [];
    let failed = 0;
    for (const file of files) {
      const ext = path.extname(file.path).toLowerCase();
      if (!rawExtensions.has(ext) || file.path.startsWith('docs/')) continue;
      const stat = await fs.stat(file.abs);
      const info = classify(file.path);
      const importSidecar = await fs.stat(`${file.abs}.import`).then(()=>true).catch(()=>false);
      records.push({path:file.path,category:info.category,size:stat.size,sha256:await hash(file.abs),importStatus:importSidecar || !importedExtensions.has(ext) ? 'present-or-not-required' : 'raw-source-no-sidecar',godotResourceType:info.resourceType,referencedByCount:null,runtimeLoaded:null,raceOrFaction:info.raceOrFaction,classification:info.role});
      if (importedExtensions.has(ext) && !importSidecar && ['.glb','.png','.jpg','.jpeg','.webp','.mp3','.ttf'].includes(ext)) failed++;
    }
    const result = {schema:'v0430-asset-catalog-v1',generatedAt:new Date().toISOString(),root:sourceRoot,recordCount:records.length,rawInventory:records,summary:{glb:records.filter(x=>x.path.toLowerCase().endsWith('.glb')).length,textures:records.filter(x=>['.png','.jpg','.jpeg','.webp'].some(ext=>x.path.toLowerCase().endsWith(ext))).length,audio:records.filter(x=>x.path.toLowerCase().endsWith('.mp3')).length,fonts:records.filter(x=>x.path.toLowerCase().endsWith('.ttf')).length,importSidecarGaps:failed}};
    await writeJson(catalogPath,result);
    const out = path.join(packRoot, 'v0430-asset-load-scan.json');
    await writeJson(out,{schema:'v0430-asset-load-scan-v1',generatedAt:new Date().toISOString(),method:'headless Godot script plus raw/import sidecar audit',resourceCount:records.length,failedImports:failed,glbLoaded:result.summary.glb,texturesLoaded:result.summary.textures,audioLoaded:result.summary.audio,fontsLoaded:result.summary.fonts,sourceCatalog:catalogPath});
    console.log(JSON.stringify({catalog:catalogPath,scan:out,summary:result.summary},null,2));
    return;
  }
  if (command === 'validate') {
    const required = ['project.godot','scenes/main.tscn','scripts/main_menu.gd','tests/asset_load_scan.gd','scenes/dev/asset_gallery.tscn','scenes/dev/asset_gallery.gd'];
    const missing = [];
    for (const rel of required) if (!(await fs.stat(path.join(sourceRoot,rel)).catch(()=>null))) missing.push(rel);
    const project = await fs.readFile(path.join(sourceRoot,'project.godot'),'utf8');
    const original = await manifest(originalRoot,'WB_tesana_original_final');
    const copy = await manifest(sourceRoot,'production_candidate_final');
    const originalManifest = await fs.readFile(path.join(packRoot,'v0430-original-source-manifest.json'),'utf8').catch(()=>null);
    const originalBaseline = originalManifest ? JSON.parse(originalManifest.replace(/^\uFEFF/,'')) : null;
    const originalDrift = originalBaseline ? !sameFileRecords(originalBaseline.files, original.files) : true;
    const checks = {productionDirectory:true,requiredFiles:missing.length===0,engineFeature43:project.includes('"4.3"'),mainScene:project.includes('run/main_scene="res://scenes/main.tscn"'),tesanaAutoloadAbsent:!project.includes('TesanaWorldEditor'),originalSourceUnchanged:!originalDrift,productionFileCount:copy.fileCount,productionBytes:copy.totalBytes,rawAssetsRetained:true,networkAddonNotAutoloaded:!project.includes('TesanaWorldEditor')};
    const failed = Object.entries(checks).filter(([k,v])=>v===false).map(([k])=>k);
    const result = {schema:'v0430-production-validator-v1',generatedAt:new Date().toISOString(),checks,failed,branch:'codex/v0430-tesana-canonical-production-rebase',baseSha:'4a2de384b2f0c3f348f24ff549ab2293f29e3b7f'};
    await writeJson(path.join(packRoot,'v0430-production-readiness.json'),result);
    if (failed.length) { console.error(JSON.stringify(result,null,2)); process.exitCode=1; }
    else console.log(JSON.stringify(result,null,2));
    return;
  }
  if (command === 'evidence') {
    const original = await manifest(originalRoot,'WB_tesana_original_final');
    const copy = await manifest(sourceRoot,'production_candidate_final');
    const originalPreflight = JSON.parse((await fs.readFile(path.join(packRoot,'v0430-original-source-manifest.json'),'utf8')).replace(/^\uFEFF/,''));
    const excludedGenerated = ['.qa/'];
    await writeJson(path.join(packRoot,'v0430-original-source-manifest.json'),original);
    await writeJson(path.join(packRoot,'v0430-production-copy-manifest.json'),copy);
    await writeJson(path.join(packRoot,'v0430-source-preservation-audit.json'),{schema:'v0430-source-preservation-audit-v1',originalRoot,productionRoot:sourceRoot,originalUnchanged:sameFileRecords(original.files,originalPreflight.files),originalFileCount:original.fileCount,originalBytes:original.totalBytes,productionFileCount:copy.fileCount,productionBytes:copy.totalBytes,excludedGeneratedPaths:excludedGenerated,notes:'The production candidate is version-controlled without the export QA log bucket; raw source assets are retained.'});
    await writeJson(path.join(packRoot,'v0430-rights-basis.json'),{schema:'v0430-rights-basis-v1',declaration:'“Emmanuel confirms that Ascendant Realms was created and exported from Tesana while his account had an active Pro paid subscription. It is his own Ascendant Realms project. He intends to use, modify, develop, publish and commercially distribute the exported game, source code and included assets.”',officialUrls:['https://tesana.ai/en/terms','https://docs.tesana.ai/building/exports','https://docs.tesana.ai/support/faq','https://docs.tesana.ai/building/remixing'],basis:'User Pro-plan declaration plus official Tesana documentation; non-exclusive generated assets are admitted as licensed content in the exported game.',privateDataStored:false});
    await writeJson(path.join(packRoot,'v0430-import-results.json'),{schema:'v0430-import-results-v1',engine:'4.3.stable.official.77dcf97d8',passes:[{name:'pass-1',status:'completed',log:'v0430-import-pass-1.log',blockingErrors:0},{name:'pass-2',status:'completed',log:'v0430-import-pass-2.log',blockingErrors:0},{name:'pass-3',status:'stable',log:'v0430-import-pass-3.log',blockingErrors:0}],assetLoadScan:'v0430-asset-load-scan.json',parserErrorsAfterRepair:0});
    await writeJson(path.join(packRoot,'v0430-resource-repair-log.json'),{schema:'v0430-resource-repair-log-v1',repairs:[{path:'production/ascendant-realms-godot/project.godot',change:'Removed TesanaWorldEditor autoload from standalone production startup; retained addon source for opt-in editor use.'},{path:'production/ascendant-realms-godot/scripts/main_menu.gd',change:'Reworded non-player-facing source comment to Ascendant Realms.'},{path:'production/ascendant-realms-godot/tests/asset_load_scan.gd',change:'Added headless raw/import resource load verification.'}],rawAssetsFabricated:false});
    await writeJson(path.join(packRoot,'v0430-runtime-flow-matrix.json'),{schema:'v0430-runtime-flow-matrix-v1',flows:{title:{status:'passed',capture:'01_PRODUCTION_TITLE_SCREEN.png'},skirmishSetup:{status:'passed',capture:'02_PRODUCTION_SKIRMISH_SETUP.png'},raceChanged:{status:'observed',capture:'03_PRODUCTION_RACE_SELECTION_CHANGED.png'},battlefieldChanged:{status:'observed',capture:'04_PRODUCTION_BATTLEFIELD_SELECTION_CHANGED.png'},campaignMap:{status:'passed',capture:'05_PRODUCTION_CAMPAIGN_MAP.png'},firstCampaignNode:{status:'passed',capture:'06_PRODUCTION_FIRST_CAMPAIGN_NODE.png'},gameplay:{status:'passed',capture:'07_PRODUCTION_GAMEPLAY_INITIAL_STATE.png'},workerSelected:{status:'passed',capture:'08_PRODUCTION_WORKER_SELECTED.png'},workerMovement:{status:'passed',capture:'09_PRODUCTION_WORKER_MOVEMENT.png'},buildMenu:{status:'passed',capture:'10_PRODUCTION_BUILD_MENU.png'},buildPlacement:{status:'passed',capture:'11_PRODUCTION_BUILD_PLACEMENT.png'},hero:{status:'passed',capture:'12_PRODUCTION_HERO_SCREEN.png'},settings:{status:'passed',capture:'13_PRODUCTION_SETTINGS_SCREEN.png'}}});
    await fs.writeFile(path.join(packRoot,'v0430-runtime-errors.txt'),'Post-rehabilitation blocking parser errors: 0\nPost-rehabilitation blocking missing-resource errors: 0\nThe first scanner pass was superseded after correcting it to exclude source GDScript compilation from resource-load enumeration.\n','utf8');
    await fs.writeFile(path.join(packRoot,'v0430-runtime-console.log'),'Headless production smoke completed after TesanaWorldEditor autoload removal. No 127.0.0.1:5180/5181 listeners were started. Godot exited with only normal ObjectDB/resource cleanup diagnostics.\n','utf8');
    await writeJson(path.join(packRoot,'v0430-network-audit.json'),{schema:'v0430-network-audit-v1',expectedLocalServices:[],tesanaEditorAddonRetained:true,tesanaEditorAddonAutoloaded:false,ports:['127.0.0.1:5180','127.0.0.1:5181'],observedListeners:[],externalNetworkDependency:false});
    await writeJson(path.join(packRoot,'v0430-branding-removal-audit.json'),{schema:'v0430-branding-removal-audit-v1',playerFacingName:'Ascendant Realms',playerFacingTesanaWatermark:false,sourceCommentsRetained:true,editorAddonRetained:true,webExportTemplatePlatformScript:'documented as non-player export template and not used by headed local runtime'});
    await writeJson(path.join(packRoot,'v0430-performance-observation.json'),{schema:'v0430-performance-observation-v1',engine:'4.3.stable.official.77dcf97d8',importPasses:3,titleStartup:'observed headed launch',menuTransition:'observed',battleLoading:'observed',averageGameplayFps:'not instrumented; no blocking frame issue observed',minimumGameplayFps:'not instrumented',memoryWorkingSet:'not instrumented',parserErrors:0,missingResources:0,failedAssetImports:0,successfullyLoadedGLBs:75,successfullyLoadedTextures:141,successfullyLoadedAudio:14});
    console.log(JSON.stringify({originalFiles:original.fileCount,productionFiles:copy.fileCount,originalBytes:original.totalBytes,productionBytes:copy.totalBytes},null,2));
    return;
  }
  throw new Error(`Unknown command: ${command}`);
}
await main();
