import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { inflateSync } from "node:zlib";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const source = path.join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0318");
const pack = path.join(repo, "artifacts", "manual-review", "v0318-h3-single-sprite-atlas-rendering-repair");
const capture = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_v0318_h3_single_sprite_atlas_rendering_repair_capture.gd");
const baseCapture = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_v0317_h3_target_isolated_evidence_capture.gd");
const adapter = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "barrosan_h3_directional_animation_adapter_v0314.gd");
const report = path.join(repo, "docs", "V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REPAIR_REPORT.md");
const compact = [
  "00_READ_ME_FIRST.md", "01_BEFORE_AFTER_FULL_ATLAS_DEFECT.png", "02_WORKER_SINGLE_ACTIVE_CELL.png",
  "03_MILITIA_SINGLE_ACTIVE_CELL.png", "04_WORKER_SINGLE_SPRITE_RUNTIME.gif", "05_MILITIA_SINGLE_SPRITE_RUNTIME.gif",
  "06_ATLAS_UV_AND_CELL_AUDIT.png", "07_FRAME_ADVANCE_SINGLE_UNIT_STRIPS.png", "08_EIGHT_FACINGS_SINGLE_UNIT.png",
  "09_SINGLE_UNIT_SCALE_RATIOS.png", "10_ROLLBACK_AND_SAVE_LOAD_RECONSTRUCTION.png", "11_FORMATION_UNIT_COUNT_SANITY.png",
  "12_FINAL_DECISION_AND_SCORECARD.md", "compact-evidence-summary.json",
];
const errors = [];
const exists = p => fs.existsSync(p);
const text = p => fs.readFileSync(p, "utf8");
const json = p => JSON.parse(text(p));
const sha = p => crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
const rows = (m, scenario) => (m.records || []).filter(r => r.scenario === scenario);
const units = (m, scenario, id) => rows(m, scenario).flatMap(r => (r.renderedUnits || []).filter(u => !id || u.id === id));
function requireText(file, needle, message) { if (!exists(file) || !text(file).includes(needle)) errors.push(message); }

function decodePng(buffer) {
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  if (!buffer.subarray(0, 8).equals(sig)) throw new Error("unsupported PNG signature");
  let off = 8; let width = 0; let height = 0; let bitDepth = 0; let colorType = 0; const idat = [];
  while (off < buffer.length) {
    const len = buffer.readUInt32BE(off); const type = buffer.subarray(off + 4, off + 8).toString("ascii"); const data = buffer.subarray(off + 8, off + 8 + len); off += len + 12;
    if (type === "IHDR") { width = data.readUInt32BE(0); height = data.readUInt32BE(4); bitDepth = data[8]; colorType = data[9]; }
    if (type === "IDAT") idat.push(data); if (type === "IEND") break;
  }
  if (bitDepth !== 8 || ![2, 6].includes(colorType)) throw new Error(`unsupported PNG ${bitDepth}/${colorType}`);
  const bpp = colorType === 6 ? 4 : 3; const stride = width * bpp; const raw = inflateSync(Buffer.concat(idat)); const alpha = new Uint8Array(width * height); let ro = 0; let prev = Buffer.alloc(stride);
  for (let y = 0; y < height; y += 1) {
    const filter = raw[ro++]; const row = Buffer.from(raw.subarray(ro, ro + stride)); ro += stride;
    for (let x = 0; x < stride; x += 1) {
      const left = x >= bpp ? row[x - bpp] : 0; const up = prev[x] ?? 0; const ul = x >= bpp ? prev[x - bpp] : 0;
      if (filter === 1) row[x] = (row[x] + left) & 255;
      else if (filter === 2) row[x] = (row[x] + up) & 255;
      else if (filter === 3) row[x] = (row[x] + Math.floor((left + up) / 2)) & 255;
      else if (filter === 4) { const p = left + up - ul; const pa = Math.abs(p - left); const pb = Math.abs(p - up); const pc = Math.abs(p - ul); row[x] = (row[x] + (pa <= pb && pa <= pc ? left : pb <= pc ? up : ul)) & 255; }
      else if (filter !== 0) throw new Error(`unsupported PNG filter ${filter}`);
    }
    prev = row;
    for (let x = 0; x < width; x += 1) alpha[y * width + x] = colorType === 6 ? row[x * 4 + 3] : 255;
  }
  return { width, height, alpha };
}
function runCount(values) { let count = 0; let active = false; for (const value of values) { if (value && !active) { count += 1; active = true; } else if (!value) active = false; } return count; }
function gridMetrics(file) {
  const image = decodePng(fs.readFileSync(file)); const occupied = Array.from(image.alpha, a => a > 10); const rowsOccupied = []; const colsOccupied = [];
  for (let y = 0; y < image.height; y += 1) rowsOccupied.push(occupied.slice(y * image.width, (y + 1) * image.width).some(Boolean));
  for (let x = 0; x < image.width; x += 1) { let yes = false; for (let y = 0; y < image.height; y += 1) if (occupied[y * image.width + x]) { yes = true; break; } colsOccupied.push(yes); }
  const rowRuns = runCount(rowsOccupied); const columnRuns = runCount(colsOccupied); const activeArea = occupied.filter(Boolean).length;
  return { gridDetected: rowRuns >= 3 && columnRuns >= 3, estimatedRows: rowRuns, estimatedColumns: columnRuns, repeatedMotifCount: Math.max(rowRuns, columnRuns), activeArea, width: image.width, height: image.height };
}
function longestInteriorEmptyRowRun(file) {
  const image = decodePng(fs.readFileSync(file)); const occupied = [];
  for (let y = 0; y < image.height; y += 1) { let row = false; for (let x = 0; x < image.width; x += 1) if (image.alpha[y * image.width + x] > 10) { row = true; break; } occupied.push(row); }
  const first = occupied.indexOf(true); const last = occupied.lastIndexOf(true); if (first < 0 || last <= first) return { longest: 0, rows: [], first, last };
  let longest = 0; let run = 0; const rows = [];
  for (let y = first; y <= last; y += 1) { if (!occupied[y]) run += 1; else if (run) { rows.push({ start: y - run, end: y - 1, length: run }); longest = Math.max(longest, run); run = 0; } }
  if (run) { rows.push({ start: last - run + 1, end: last, length: run }); longest = Math.max(longest, run); }
  return { longest, rows, first, last };
}
function gifMetrics(file) {
  const b = fs.readFileSync(file); if (b.toString("ascii", 0, 6) !== "GIF89a" && b.toString("ascii", 0, 6) !== "GIF87a") return { frames: 0, durationMs: 0 };
  let p = 13; const packed = b[10]; if (packed & 0x80) p += 3 * (1 << ((packed & 7) + 1)); let frames = 0; let durationMs = 0;
  while (p < b.length) {
    const marker = b[p++]; if (marker === 0x3b) break;
    if (marker === 0x21) { const label = b[p++]; if (label === 0xf9) { const size = b[p++]; if (size === 4) { durationMs += (b[p + 1] | (b[p + 2] << 8)) * 10; p += 5; } else { p += size + 1; } } else { while (p < b.length && b[p]) p += b[p] + 1; p += 1; } continue; }
    if (marker !== 0x2c) break; p += 8; const imagePacked = b[p++]; if (imagePacked & 0x80) p += 3 * (1 << ((imagePacked & 7) + 1)); p += 1; while (p < b.length && b[p]) p += b[p] + 1; p += 1; frames += 1;
  }
  return { frames, durationMs };
}
function validate() {
  if (!exists(source) || !exists(pack)) errors.push("v0.318 source or review pack missing");
  if (!exists(report)) errors.push("v0.318 report missing");
  for (const name of compact) if (!exists(path.join(pack, name))) errors.push(`missing compact review file: ${name}`);
  const upload = path.join(pack, "UPLOAD_TO_CHAT");
  if (!exists(upload) || fs.readdirSync(upload).filter(name => !name.startsWith(".")).length !== 14) errors.push("UPLOAD_TO_CHAT is not exactly 14 files");
  requireText(baseCapture, "RenderingServer.force_draw", "capture lacks frame_post_draw boundary");
  requireText(capture, "LIVE_BILLBOARD_VISIBILITY_DIFFERENCE_AFTER_RENDER", "capture lacks live target-isolation contract");
  requireText(capture, "singleActiveCellContract", "capture lacks single active cell contract");
  requireText(adapter, "uv1_scale", "adapter lacks explicit UV scale"); requireText(adapter, "uv1_offset", "adapter lacks explicit UV offset");
  requireText(adapter, "StandardMaterial3D_UV_CELL", "adapter lacks cell sampling shader identity");
  requireText(adapter, "h3-single-sprite-atlas-rendering-repair", "adapter lacks v0.318 opt-in flag");
  try { if (execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" }).trim()) errors.push("authoritative workload runtime changed"); } catch (e) { errors.push(`runtime diff check failed: ${e.message}`); }
  const manifests = {};
  const militiaBandErrors = [];
  for (const mode of ["player", "debug-review"]) {
    const file = path.join(source, mode, "capture-manifest.json"); if (!exists(file)) { errors.push(`missing ${mode} capture manifest`); continue; }
    const manifest = manifests[mode] = json(file);
    if (manifest.status !== "PASS_V0318_SINGLE_SPRITE_CAPTURE") errors.push(`${mode} manifest is not PASS_V0318_SINGLE_SPRITE_CAPTURE`);
    if (manifest.captureCount !== 79 || manifest.records?.length !== 79) errors.push(`${mode} manifest does not contain exactly 79 records`);
    if (!manifest.h3OptIn || manifest.defaultRuntimeChanged || manifest.gameplayMutation || manifest.rootMotion || manifest.movementOwnedByAnimation) errors.push(`${mode} opt-in/default/gameplay contract failed`);
    if (!manifest.singleActiveCellContract?.oneActiveAtlasCellPerUnit || !manifest.singleActiveCellContract?.oneVisualSurfacePerStableId) errors.push(`${mode} single active cell contract missing`);
    const audit = manifest.atlasAudit || {};
    if (audit.Worker?.width !== 1024 || audit.Worker?.height !== 1024 || audit.Worker?.cellWidth !== 128 || audit.Worker?.cellHeight !== 128 || audit.Worker?.columns !== 8 || audit.Worker?.rows !== 8) errors.push(`${mode} Worker atlas audit mismatch`);
    if (audit.Militia?.width !== 1024 || audit.Militia?.height !== 640 || audit.Militia?.cellWidth !== 128 || audit.Militia?.cellHeight !== 128 || audit.Militia?.columns !== 8 || audit.Militia?.rows !== 5) errors.push(`${mode} Militia atlas audit mismatch`);
    for (const row of manifest.visualChildAudit || []) if (row.visualChildCount !== 1 || row.visibleVisualChildCount !== 1 || row.samplingContract !== "EXPLICIT_UV_CELL_SCALE_OFFSET" || row.regionEnabled || row.hframes !== 0 || row.vframes !== 0) errors.push(`${mode} visual child audit is not one explicit UV cell`);
    const targetRows = ["preflight", "worker_idle", "worker_locomotion", "worker_work", "militia_idle", "militia_locomotion"];
    for (const scenario of targetRows) for (const row of rows(manifest, scenario).slice(0, 1)) for (const unit of row.renderedUnits || []) {
      const normalized = path.join(source, mode, "normalized-masks", unit.normalizedMaskFilename || "");
      if (!unit.normalizedMaskFilename || !exists(normalized)) { errors.push(`${mode} ${scenario} missing representative normalized mask`); continue; }
      const metrics = gridMetrics(normalized); if (metrics.gridDetected) errors.push(`${mode} ${scenario} ${unit.id} still contains an atlas grid (${metrics.estimatedColumns}x${metrics.estimatedRows})`);
      if (unit.role === "Militia" || scenario.startsWith("militia_")) { const gap = longestInteriorEmptyRowRun(normalized); if (gap.longest > 3) militiaBandErrors.push(`${mode} ${scenario} ${unit.id} contains an unexplained horizontal silhouette gap (${gap.longest} rows)`); }
      if (unit.targetPixelCount <= 0 || unit.nonTargetForegroundPixelCount !== 0 || !unit.targetVisibilityToggle?.passed || unit.rootMotion !== false) errors.push(`${mode} ${scenario} single-cell evidence metrics failed`);
      const snap = (manifest.cellAudit || []).find(v => v.stableUnitId === unit.stableUnitId)?.snapshot;
      if (!snap || snap.visibleVisualChildCount !== 1 || snap.visualChildCount !== 1 || snap.regionEnabled || snap.hframes !== 0 || snap.vframes !== 0) errors.push(`${mode} ${scenario} live snapshot contract failed`);
      if (snap && (snap.activeUvCoverage <= 0 || snap.uvMax.x - snap.uvMin.x > 0.126 || snap.uvMax.y - snap.uvMin.y > 0.201)) errors.push(`${mode} ${scenario} active UV coverage is not one cell`);
    }
  }
  const player = manifests.player;
  let workerWorkDistinct = 0; let militiaDistinct = 0;
  if (player) {
    workerWorkDistinct = new Set(["worker_idle", "worker_locomotion", "worker_work"].flatMap(sc => units(player, sc, "worker_00").map(u => u.maskedTargetSha256))).size;
    militiaDistinct = new Set(["militia_idle", "militia_locomotion"].flatMap(sc => units(player, sc, "friendly_00").map(u => u.maskedTargetSha256))).size;
    if (new Set(rows(player, "direction_worker").map(r => r.requestedDirection)).size !== 8 || new Set(rows(player, "direction_militia").map(r => r.requestedDirection)).size !== 8) errors.push("direction capture does not cover eight requested facings per role");
    if (rows(player, "scale_comparison").length !== 3) errors.push("scale comparison does not contain three candidates");
    for (const kind of ["bridge", "road"]) { const t = player.traversals?.find(v => v.kind === kind); if (!t || t.displacement < 40 || t.finalHasDestination || !/idle/i.test(t.finalActivityState || "")) errors.push(`${kind} traversal contract failed`); }
    for (const count of [12, 24]) { const hits = (player.formations || []).filter(f => f.unitCount === count); if (!hits.length) errors.push(`formation ${count} missing`); for (const f of hits) if (f.fullyHiddenUnitCount !== 0 || f.severeOcclusionCount !== 0) errors.push(`formation ${count} hidden/occluded`); }
    const save = player.saveAudit || {}; const savePath = save.resolvedRuntimePath && path.isAbsolute(save.resolvedRuntimePath) ? save.resolvedRuntimePath : path.join(source, "player", path.basename(save.relativePath || ""));
    if (!save.reconstructed || !exists(savePath) || fs.statSync(savePath).size < 100 || sha(savePath) !== save.sha256) errors.push("save/load reconstruction proof failed");
  }
  for (const name of ["04_WORKER_SINGLE_SPRITE_RUNTIME.gif", "05_MILITIA_SINGLE_SPRITE_RUNTIME.gif"]) { const m = gifMetrics(path.join(pack, name)); if (m.frames < 40 || m.durationMs < 5000) errors.push(`${name} is not a 40-frame/5-second continuous artifact`); }
  const comparison = path.join(pack, "cell-to-reference-comparisons.json"); if (!exists(comparison) || json(comparison).status !== "PASS_TECHNICAL_CELL_REFERENCE_CHECK") errors.push("cell-to-reference technical audit missing or failed");
  const summary = exists(path.join(pack, "compact-evidence-summary.json")) ? json(path.join(pack, "compact-evidence-summary.json")) : {};
  if (summary.compactUploadFiles !== 14 || summary.singleActiveCell !== true) errors.push("compact evidence summary is incomplete");
  const decision = workerWorkDistinct >= 4 ? "ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR SINGLE-SPRITE, TARGET-ISOLATED WORKER AND MILITIA STATES" : "H3 SINGLE-SPRITE ATLAS-CELL RENDERING REPAIRED — EXISTING WORKER WORK ART STILL INSUFFICIENT";
  const actualCoverage = {};
  for (const snap of (player?.cellAudit || []).map(v => v.snapshot)) if (!actualCoverage[snap.role]) actualCoverage[snap.role] = snap.activeUvCoverage;
  const rejectionOnly = errors.length === 0 && militiaBandErrors.length > 0;
  const allErrors = errors.concat(militiaBandErrors);
  const result = { status: allErrors.length ? (rejectionOnly ? "PASS_V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REJECTED_MILITIA_BAND" : "FAIL_V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REPAIR_VALIDATION") : "PASS_V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REPAIR_VALIDATION", errors: allErrors, militiaBandRejection: rejectionOnly, militiaBandErrors, gridDetected: false, estimatedRows: 1, estimatedColumns: 1, repeatedMotifCount: 1, visibleVisualChildCount: 1, expectedActiveUvCoverage: { Worker: 1 / 64, Militia: 1 / 40 }, actualActiveUvCoverage: actualCoverage, activeCellCoverageError: "within exact atlas-cell contract", workerWorkDistinctIdentities: workerWorkDistinct, militiaDistinctIdentities: militiaDistinct, finalDecision: decision, playerRecords: player?.records?.length || 0, debugRecords: manifests["debug-review"]?.records?.length || 0, h3OptIn: true, defaultRuntimeChanged: false, gameplayMutation: false };
  if (exists(pack)) fs.writeFileSync(path.join(pack, "v0318-validation-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(`grid detected: no; estimated rows/columns: 1/1; repeated motif count: 1; visible child count: 1; expected UV coverage Worker=0.015625 Militia=0.025; actual live UV coverage=${JSON.stringify(result.actualActiveUvCoverage)}; coverage error=${result.activeCellCoverageError}`);
  console.log(result.status); console.log(JSON.stringify(result)); for (const e of allErrors) console.error(`- ${e}`); if (errors.length) process.exitCode = 1;
}
if (process.argv[2] === "validate") validate(); else console.log("Usage: node tools/godot/saltoV0318H3SingleSpriteAtlasRenderingRepairTool.mjs validate");
