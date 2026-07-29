import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const pack = path.join(repo, 'artifacts/manual-review/v0366-barrosan-house02-and-barn-forked-clean-mesh-prototype/UPLOAD_TO_CHAT');
const capture = path.join(repo, 'artifacts/runtime/v0366/capture');
const manifestFile = path.join(capture, 'v0366-manifest.json');
const report = path.join(repo, 'docs/V0366_BARROSAN_HOUSE02_AND_BARN_FORKED_CLEAN_MESH_PROTOTYPE_REPORT.md');
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/rework/barrosan/v0366/V0366BarrosanHouse02AndBarnForkedCleanMeshPrototype.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0366_barrosan_house02_barn_forked_clean_mesh_prototype.gd');
const requiredPack = ['00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_SCOPE.png','02_ORIGINAL_VS_CLEAN_PLAYER_SCENE.png','03_HOUSE02_A_GROUND_STONE_REMOVAL.png','04_HOUSE02_B_UPPER_TIMBER_REMOVAL.png','05_HOUSE02_FULL_ARCHITECTURAL_PRESERVATION.png','06_BARN_C_FRONT_TIMBER_REMOVAL.png','07_BARN_FULL_ARCHITECTURAL_PRESERVATION.png','08_DERIVED_MESH_HASH_AND_MUTATION_LEDGER.png','compact-evidence-summary.json'];
const fail = (message) => { throw new Error(`V0366_VALIDATION_FAILED: ${message}`); };
const exists = (file) => fs.existsSync(file);
const json = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));
const sha = (file) => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const pngSize = (file) => { const b = fs.readFileSync(file); if (b.length < 24 || b.readUInt32BE(0) !== 0x89504e47 || b.toString('ascii',1,4) !== 'PNG') return null; return {width:b.readUInt32BE(16),height:b.readUInt32BE(20),bytes:b.length}; };
const assert = (condition, message) => { if (!condition) fail(message); };

function validate() {
  assert(exists(manifestFile), 'runtime manifest missing'); assert(exists(report), 'v0.366 report missing'); assert(exists(scene), 'isolated prototype scene missing'); assert(exists(script), 'derived-mesh implementation missing');
  const m = json(manifestFile); assert(m.status === 'PASS_V0366_DERIVED_MESH_CAPTURE', 'manifest status'); assert(m.checkpoint === 'v0.366', 'checkpoint'); assert(m.baseHead === '82a0dfb1f58bbb1651c29893b9414fa6b73a553a', 'base HEAD');
  for (const [key, value] of Object.entries(m)) { if (/MutationCount$/.test(key)) assert(value === 0, `${key} must remain zero`); }
  assert(m.humanReviewStop === true, 'human review stop missing'); assert(m.derivedRecords?.length === 3, 'expected House02 A/B and Barn C derived records');
  const targets = new Set((m.derivedRecords || []).map((r) => r.target)); assert(targets.has('HOUSE_A') && targets.has('HOUSE_B') && targets.has('BARN_C'), 'target records incomplete');
  for (const r of m.derivedRecords) { assert(r.deltaIsGeometry === true && r.removedTriangleCount > 0, `${r.target} has no true triangle delta`); assert(r.canonicalMeshSignature !== r.derivedMeshSignature, `${r.target} derived signature did not differ`); assert(r.derivedSurfaceCount === r.sourceSurfaceCount, `${r.target} surface/material preservation failed`); }
  assert(m.meshDerivationMethod?.includes('ArrayMesh fork'), 'surface-preserving ArrayMesh method missing');
  const sourceText = fs.readFileSync(script, 'utf8'); assert(sourceText.includes('add_surface_from_arrays'), 'derived ArrayMesh construction missing'); assert(sourceText.includes('triangle_components'), 'connected component analysis missing'); assert(!sourceText.includes('h_a.visible = false') && !sourceText.includes('h_b.visible = false') && !sourceText.includes('b_c.visible = false'), 'target parent hide trick detected'); assert(sourceText.includes('humanReviewStop'), 'review stop wiring missing');
  assert(fs.readdirSync(pack).sort().join('|') === requiredPack.slice().sort().join('|'), 'upload pack must contain exactly the ten required files');
  const readme = fs.readFileSync(path.join(pack,'00_READ_ME_FIRST.md'),'utf8'); assert(readme.startsWith('READY FOR HUMAN V0366 BARROSAN HOUSE02 AND BARN FORKED CLEAN-MESH PROTOTYPE REVIEW.'), 'README first line'); assert(!readme.includes('\uFFFD') && !readme.includes('\0'), 'README malformed text');
  const summary = json(path.join(pack,'compact-evidence-summary.json')); assert(summary.status === 'READY_FOR_HUMAN_V0366_REVIEW' && summary.humanReviewStop === true, 'compact summary truth');
  for (const file of requiredPack.filter((name) => name.endsWith('.png'))) { const size = pngSize(path.join(pack,file)); assert(size && size.width >= 640 && size.height >= 360 && size.bytes > 10000, `${file} is not a real rendered capture`); }
  const manifestCaptures = new Set((m.captures || []).map((c) => c.file)); for (const file of ['01_decision_scope.png','02_original_vs_clean.png','03_house_a.png','04_house_b.png','05_house_preservation.png','06_barn_c.png','07_barn_preservation.png','08_ledger.png']) assert(manifestCaptures.has(file), `capture manifest missing ${file}`);
  const canonicalBarn = path.join(repo,'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn'); const canonicalBarnAsset = path.join(repo,'desktop-spikes/godot-salto/assets/v0350/barn_final_material_harmony.glb'); const canonicalHouse = path.join(repo,'desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb'); assert(sha(canonicalBarn) === 'ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a', 'accepted canonical Barn scene source hash changed'); assert(sha(canonicalBarnAsset) === '0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c', 'accepted canonical Barn asset source hash changed'); assert(sha(canonicalHouse) === 'ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89', 'accepted House02 source hash changed');
  assert(!sourceText.includes('get_tree().change_scene') && !sourceText.includes('move_and_slide') && !sourceText.includes('NavigationAgent'), 'gameplay integration detected');
  console.log('PASS_V0366_BARROSAN_HOUSE02_BARN_FORKED_CLEAN_MESH_PROTOTYPE');
}

if (process.argv[2] === 'validate') validate(); else console.log('Usage: node saltoV0366BarrosanHouse02BarnForkedCleanMeshPrototypeTool.mjs validate');
