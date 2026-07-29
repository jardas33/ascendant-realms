import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { inflateSync } from "node:zlib";
import { execFileSync } from "node:child_process";

const repo = process.cwd();
const source = path.join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0319");
const pack = path.join(repo, "artifacts", "manual-review", "v0319-h3-militia-silhouette-integrity");
const report = path.join(repo, "docs", "V0319_H3_MILITIA_SILHOUETTE_INTEGRITY_REPORT.md");
const capture = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_v0319_h3_militia_silhouette_integrity_capture.gd");
const adapter = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "barrosan_h3_directional_animation_adapter_v0314.gd");
const rootScript = path.join(repo, "desktop-spikes", "godot-salto", "scripts", "salto_spike_root.gd");
const compact = [
  "00_READ_ME_FIRST.md", "01_V0318_MILITIA_BAND_PROBLEM.png", "02_CLEAN_PLAYER_MILITIA_SILHOUETTE.png",
  "03_SOURCE_CELL_VS_LIVE_TARGET.png", "04_VISIBLE_HIDDEN_MASK_RECONSTRUCTION.png", "05_ROLE_SPECIFIC_UV_AUDIT.png",
  "06_MESH_AND_MATERIAL_AUDIT.png", "07_DEPTH_AND_OCCLUSION_CLASSIFICATION.png", "08_MILITIA_CLEAN_RUNTIME.gif",
  "09_WORKER_REGRESSION.png", "10_SAVE_LOAD_AND_REBUILD.png", "11_PIXEL_ROW_COVERAGE_AUDIT.png",
  "12_FINAL_DECISION_AND_SCORECARD.md", "compact-evidence-summary.json",
];
const errors = [];
const exists = file => fs.existsSync(file);
const readText = file => fs.readFileSync(file, "utf8");
const readJson = file => JSON.parse(readText(file));
const sha = file => crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");

function decodePng(buffer) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  if (!buffer.subarray(0, 8).equals(signature)) throw new Error("unsupported PNG signature");
  let offset = 8; let width = 0; let height = 0; let bitDepth = 0; let colorType = 0; const idat = [];
  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset); const type = buffer.subarray(offset + 4, offset + 8).toString("ascii"); const data = buffer.subarray(offset + 8, offset + 8 + length); offset += length + 12;
    if (type === "IHDR") { width = data.readUInt32BE(0); height = data.readUInt32BE(4); bitDepth = data[8]; colorType = data[9]; }
    if (type === "IDAT") idat.push(data); if (type === "IEND") break;
  }
  if (bitDepth !== 8 || ![2, 6].includes(colorType)) throw new Error(`unsupported PNG ${bitDepth}/${colorType}`);
  const bpp = colorType === 6 ? 4 : 3; const stride = width * bpp; const raw = inflateSync(Buffer.concat(idat)); const alpha = new Uint8Array(width * height); let rawOffset = 0; let previous = Buffer.alloc(stride);
  for (let y = 0; y < height; y += 1) {
    const filter = raw[rawOffset++]; const row = Buffer.from(raw.subarray(rawOffset, rawOffset + stride)); rawOffset += stride;
    for (let x = 0; x < stride; x += 1) {
      const left = x >= bpp ? row[x - bpp] : 0; const up = previous[x] ?? 0; const upperLeft = x >= bpp ? previous[x - bpp] : 0;
      if (filter === 1) row[x] = (row[x] + left) & 255;
      else if (filter === 2) row[x] = (row[x] + up) & 255;
      else if (filter === 3) row[x] = (row[x] + Math.floor((left + up) / 2)) & 255;
      else if (filter === 4) { const p = left + up - upperLeft; const pa = Math.abs(p - left); const pb = Math.abs(p - up); const pc = Math.abs(p - upperLeft); row[x] = (row[x] + (pa <= pb && pa <= pc ? left : pb <= pc ? up : upperLeft)) & 255; }
      else if (filter !== 0) throw new Error(`unsupported PNG filter ${filter}`);
    }
    previous = row;
    for (let x = 0; x < width; x += 1) alpha[y * width + x] = colorType === 6 ? row[x * 4 + 3] : 255;
  }
  return { width, height, alpha };
}

function gapMetrics(file) {
  const image = decodePng(fs.readFileSync(file)); const occupied = [];
  for (let y = 0; y < image.height; y += 1) { let row = false; for (let x = 0; x < image.width; x += 1) if (image.alpha[y * image.width + x] > 10) { row = true; break; } occupied.push(row); }
  const first = occupied.indexOf(true); const last = occupied.lastIndexOf(true); let longest = 0; const runs = []; let run = 0;
  if (first >= 0 && last > first) for (let y = first; y <= last; y += 1) { if (!occupied[y]) run += 1; else if (run) { runs.push({ start: y - run, end: y - 1, length: run }); longest = Math.max(longest, run); run = 0; } }
  if (run) { runs.push({ start: last - run + 1, end: last, length: run }); longest = Math.max(longest, run); }
  return { longest, runs, first, last, width: image.width, height: image.height };
}

function gifMetrics(file) {
  const buffer = fs.readFileSync(file); if (!["GIF87a", "GIF89a"].includes(buffer.toString("ascii", 0, 6))) return { frames: 0, durationMs: 0 };
  let position = 13; const packed = buffer[10]; if (packed & 0x80) position += 3 * (1 << ((packed & 7) + 1)); let frames = 0; let durationMs = 0;
  while (position < buffer.length) { const marker = buffer[position++]; if (marker === 0x3b) break; if (marker === 0x21) { const label = buffer[position++]; if (label === 0xf9) { const size = buffer[position++]; if (size === 4) { durationMs += (buffer[position + 1] | (buffer[position + 2] << 8)) * 10; position += 5; } else position += size + 1; } else { while (position < buffer.length && buffer[position]) position += buffer[position] + 1; position += 1; } continue; } if (marker !== 0x2c) break; position += 8; const imagePacked = buffer[position++]; if (imagePacked & 0x80) position += 3 * (1 << ((imagePacked & 7) + 1)); position += 1; while (position < buffer.length && buffer[position]) position += buffer[position] + 1; position += 1; frames += 1; }
  return { frames, durationMs };
}

function unitFor(manifest, scenario) {
  for (const row of manifest.records || []) if (row.scenario === scenario) for (const unit of row.renderedUnits || []) if (unit.id === "friendly_00") return unit;
  return null;
}

function validate() {
  if (!exists(source) || !exists(pack) || !exists(report)) errors.push("v0.319 source, review pack, or report missing");
  if (!exists(capture) || !exists(adapter) || !exists(rootScript)) errors.push("v0.319 capture or runtime integration files missing");
  for (const file of compact) if (!exists(path.join(pack, file))) errors.push(`missing compact evidence: ${file}`);
  const upload = path.join(pack, "UPLOAD_TO_CHAT"); if (!exists(upload) || fs.readdirSync(upload).filter(name => !name.startsWith(".")).length !== 14) errors.push("UPLOAD_TO_CHAT is not exactly 14 files");
  if (exists(capture)) for (const needle of ["NEUTRAL_SINGLE_MILITIA_PRESENTATION_AUDIT", "militia-source-cell", "diagnosticMatrix", "continuousMilitia", "militiaUvScaleV", "noUnexplainedTorsoBandInCleanProof"]) if (!readText(capture).includes(needle)) errors.push(`capture lacks ${needle}`);
  if (exists(adapter)) for (const needle of ["uv1_scale", "uv1_offset", "StandardMaterial3D_UV_CELL", "h3-single-sprite-atlas-rendering-repair"]) if (!readText(adapter).includes(needle)) errors.push(`adapter lacks ${needle}`);
  if (exists(rootScript) && !readText(rootScript).includes("h3-militia-silhouette-integrity")) errors.push("root dispatch lacks v0.319 opt-in flag");
  try { if (execFileSync("git", ["diff", "HEAD", "--", "desktop-spikes/godot-salto/scripts/salto_spike_workload_runtime.gd"], { cwd: repo, encoding: "utf8" }).trim()) errors.push("authoritative workload runtime changed"); } catch (error) { errors.push(`runtime diff check failed: ${error.message}`); }

  const manifests = {};
  for (const mode of ["player", "debug-review"]) {
    const file = path.join(source, mode, "capture-manifest.json"); if (!exists(file)) { errors.push(`missing ${mode} manifest`); continue; }
    const manifest = manifests[mode] = readJson(file);
    if (manifest.status !== "PASS_V0319_MILITIA_SILHOUETTE_CAPTURE") errors.push(`${mode} manifest is not a passing v0.319 capture`);
    if (manifest.captureCount < 40 || (manifest.records || []).length < 40) errors.push(`${mode} has fewer than 40 rendered records`);
    if (!manifest.h3OptIn || manifest.defaultRuntimeChanged || manifest.gameplayMutation || manifest.rootMotion) errors.push(`${mode} default/gameplay contract failed`);
    if (!manifest.cleanNeutralProof?.oneMilitiaStableId || Object.entries(manifest.cleanNeutralProof).some(([key, value]) => key !== "background" && value !== true)) errors.push(`${mode} clean neutral isolation contract failed`);
    if (manifest.continuousMilitia?.frames !== 40 || !manifest.continuousMilitia?.singleUninterruptedSession || !manifest.continuousMilitia?.stateRestoredAfterCapture) errors.push(`${mode} continuous 40-frame state contract failed`);
    if ((manifest.diagnosticMatrix || []).length !== 6) errors.push(`${mode} diagnostic matrix does not contain six variants`);
    if ((manifest.depthContexts || []).length !== 6) errors.push(`${mode} depth context ledger does not contain six contexts`);
    const clean = unitFor(manifest, "clean_neutral"); if (!clean) errors.push(`${mode} clean neutral Militia target missing`);
    else {
      const maskFile = path.join(source, mode, "normalized-masks", clean.normalizedMaskFilename || ""); if (!exists(maskFile)) errors.push(`${mode} clean normalized mask missing`); else { const gap = gapMetrics(maskFile); if (gap.longest > 3) errors.push(`${mode} clean Militia still has a ${gap.longest}-row interior band`); }
      if (clean.id !== "friendly_00" || clean.role !== "Militia" || clean.targetPixelCount <= 0 || clean.nonTargetForegroundPixelCount !== 0 || !clean.targetVisibilityToggle?.passed) errors.push(`${mode} clean Militia target truth failed`);
    }
    const uvMilitia = (manifest.atlasUvAudit || []).find(row => row.role === "Militia"); const uvWorker = (manifest.atlasUvAudit || []).find(row => row.role === "Worker");
    if (!uvMilitia || Math.abs(uvMilitia.uvScale.u - 0.125) > 0.001 || Math.abs(uvMilitia.uvScale.v - 0.2) > 0.001) errors.push(`${mode} Militia UV scale is not 0.125 x 0.200`);
    if (!uvWorker || Math.abs(uvWorker.uvScale.u - 0.125) > 0.001 || Math.abs(uvWorker.uvScale.v - 0.125) > 0.001) errors.push(`${mode} Worker UV scale is not 0.125 x 0.125`);
    const mesh = (manifest.meshMaterialAudit || []).find(row => row.role === "Militia" && row.visibleChildCount === 1); if (!mesh || mesh.meshType !== "QuadMesh" || mesh.surfaceCount !== 1 || mesh.vertexCount !== 4 || mesh.indexCount !== 6 || mesh.triangleCount !== 2 || mesh.materialInstanceId === 0) errors.push(`${mode} live Militia QuadMesh/material audit failed`);
    const save = manifest.saveLoadAudit || {}; if (!save.reconstructed || !save.realSave && !save.fileSizeBytes) errors.push(`${mode} save/load/rebuild proof failed`);
  }
  const player = manifests.player;
  if (player?.workerWorkIdentitiesUnchanged !== 3) errors.push("Worker regression identity count changed");
  if (player?.authoritativeStateRestored !== true || player?.defaultRuntimeChanged !== false || player?.gameplayMutation !== false) errors.push("authoritative/default state restoration contract failed");
  const summaryPath = path.join(pack, "compact-evidence-summary.json"); const summary = exists(summaryPath) ? readJson(summaryPath) : {};
  if (summary.outcome !== "MILITIA MASK-EVIDENCE DEFECT REPAIRED — PLAYER RUNTIME WAS CLEAN") errors.push("exact v0.319 outcome 1 is missing");
  if (summary.compactUploadFiles !== 14 || summary.cleanTargetMask?.maxHorizontalGap !== 0 || summary.cleanTargetMask?.silhouetteIoU < 0.97 || summary.cleanTargetMask?.targetRecall < 0.97 || summary.cleanTargetMask?.targetPrecision < 0.97) errors.push("mask truth thresholds or compact summary failed");
  const gif = gifMetrics(path.join(pack, "08_MILITIA_CLEAN_RUNTIME.gif")); if (gif.frames < 40 || gif.durationMs < 5000) errors.push(`Militia GIF is not 40 frames/5 seconds (${gif.frames}/${gif.durationMs}ms)`);
  try { const old = execFileSync("node", [path.join(repo, "tools/godot/saltoV0318H3SingleSpriteAtlasRenderingRepairTool.mjs"), "validate"], { cwd: repo, encoding: "utf8" }); if (!old.includes("PASS_V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REJECTED_MILITIA_BAND")) errors.push("corrected v0.318 validator did not reject the historical Militia band"); } catch (error) { errors.push(`corrected v0.318 rejection validator failed: ${error.stdout || error.message}`); }
  const changed = execFileSync("git", ["diff", "HEAD", "--name-only"], { cwd: repo, encoding: "utf8" }).split(/\r?\n/).filter(Boolean); for (const file of changed) if (/desktop-spikes[\\/]godot-salto[\\/]assets[\\/]v0314[\\/]h3[\\/].*\.(png|glb|gltf|obj|fbx)$/i.test(file)) errors.push(`unapproved production art import/change: ${file}`);
  const result = { status: errors.length ? "FAIL_V0319_H3_MILITIA_SILHOUETTE_INTEGRITY_VALIDATION" : "PASS_V0319_H3_MILITIA_SILHOUETTE_INTEGRITY_VALIDATION", outcome: summary.outcome, errors, playerRecords: player?.records?.length || 0, debugRecords: manifests["debug-review"]?.records?.length || 0, cleanMaskGap: summary.cleanTargetMask?.maxHorizontalGap ?? null, militiaUvScale: summary.militiaUvScale, workerUvScale: summary.workerUvScale, workerWorkIdentities: player?.workerWorkIdentitiesUnchanged ?? null, gif, defaultRuntimeChanged: false, gameplayMutation: false };
  if (exists(pack)) fs.writeFileSync(path.join(pack, "v0319-validation-report.json"), JSON.stringify(result, null, 2) + "\n");
  console.log(result.status); console.log(JSON.stringify(result)); for (const error of errors) console.error(`- ${error}`); if (errors.length) process.exitCode = 1;
}

if (process.argv[2] === "validate") validate(); else console.log("Usage: node tools/godot/saltoV0319H3MilitiaSilhouetteIntegrityTool.mjs validate");
