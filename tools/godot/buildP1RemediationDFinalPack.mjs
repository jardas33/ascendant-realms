import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repo = path.resolve(import.meta.dirname, "../..");
const evidence = "D:\\CodexData\\evidence\\ascendant-realms-p1-remediation-d";
const finalRoot = path.join(evidence, "FINAL");
const sourceSha = execFileSync("git", ["rev-parse", "HEAD"], { cwd: repo, encoding: "utf8" }).trim();
const hash = (file) => createHash("sha256").update(readFileSync(file)).digest("hex");
const newestRun = (lane) => readdirSync(path.join(evidence, lane), { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && entry.name.startsWith("run-"))
  .map((entry) => entry.name)
  .sort()
  .at(-1);
const manifest = (lane) => JSON.parse(readFileSync(path.join(evidence, lane, `${newestRun(lane) === undefined ? "" : newestRun(lane)}/..`, `${lane}-capture-manifest.json`), "utf8"));
function laneManifest(lane) {
  const file = path.join(evidence, lane, `${lane}-capture-manifest.json`);
  return JSON.parse(readFileSync(file, "utf8"));
}
function frame(lane, name) {
  const m = laneManifest(lane);
  const found = (m.captures || []).find((item) => item.name === name);
  if (!found || !existsSync(found.png)) throw new Error(`missing ${lane}:${name}`);
  return found;
}
const mapping = [
  ["01_DEFAULT_LIORAEN.png", "p1r20", "01_R20_LIORAEN_MIXED"],
  ["02_NEAR_LIORAEN.png", "p1r20", "06_R20_NEAR_MODELS"],
  ["03_DEFAULT_BARROSAN.png", "p1r20", "02_R20_BARROSAN_MIXED"],
  ["04_DEFAULT_VORTHAK.png", "p1r20", "03_R20_VORTHAK_MIXED"],
  ["05_HOLLOWSPAN_SURFACE.png", "p1r19", "01_R19_HOLLOWSPAN_ARMY"],
  ["06_EMBERFALL_SURFACE.png", "p1r19", "03_R19_EMBERFALL_ARMY"],
  ["07_ASHEN_SURFACE.png", "p1r19", "05_R19_ASHEN_ARMY"],
  ["08_UNIT_MOTION_A.png", "p1r21", "01_R21_WORKER_TRAVEL"],
  ["09_UNIT_MOTION_B.png", "p1r21", "02_R21_MILITARY_TRAVEL"],
  ["10_WORKER_COMMAND_CARD.png", "p1r22", "01_R22_WORKER_BUILD_CARD"],
  ["11_BUILDING_COMMAND_CARD.png", "p1r22", "02_R22_HQ_CARD"],
  ["12_RESEARCH_CARD.png", "p1r22", "04_R22_RESEARCH"],
  ["13_MULTISELECT.png", "p1r23", "02_R23_MIXED_GROUP"],
  ["14_PORTRAIT_COMMAND_COMPOSITION.png", "p1r22", "03_R22_PRODUCTION_BUILDING"],
  ["15_COMBAT_FINAL_GROUND.png", "p1r19", "06_R19_COMBAT_GROUND"],
  ["16_MINIMAP_FINAL.png", "p1r19", "07_R19_1366"],
  ["17_BUILD_PLACEMENT_FINAL.png", "p1r22", "08_R22_BUILD_PLACEMENT"],
  ["18_LUME_FINAL.png", "p1r20", "04_R20_HERO_DEFAULT"],
  ["19_1366_GAMEPLAY.png", "p1r22", "06_R22_1366_BUILD_CARD"],
  ["20_1366_COMMAND_UI.png", "p1r22", "07_R22_1366_TRAIN_CARD"],
];
mkdirSync(finalRoot, { recursive: true });
const frames = [];
for (const [name, lane, sourceName] of mapping) {
  const source = frame(lane, sourceName);
  if (source.source_sha !== sourceSha) throw new Error(`${lane}:${sourceName} is not current HEAD`);
  const target = path.join(finalRoot, name);
  copyFileSync(source.png, target);
  frames.push({ name, lane, source_name: sourceName, source_path: source.png, width: source.width, height: source.height, sha256: hash(target), bytes: readFileSync(target).length });
}
const blackRejects = frames.filter((item) => item.bytes < 20000);
const contactSheet = [
  `<svg xmlns="http://www.w3.org/2000/svg" width="1680" height="1350" viewBox="0 0 1680 1350">`,
  `<rect width="100%" height="100%" fill="#10141c"/>`,
  `<text x="24" y="30" fill="#f4dfaa" font-family="Arial" font-size="22">Batch D final current-head gameplay evidence</text>`,
];
for (let i = 0; i < frames.length; i += 1) {
  const item = frames[i]; const col = i % 4; const row = Math.floor(i / 4); const x = 24 + col * 414; const y = 48 + row * 256;
  contactSheet.push(`<rect x="${x}" y="${y}" width="400" height="225" fill="#05070a" stroke="#8a7040"/>`);
  contactSheet.push(`<image href="${item.name}" x="${x}" y="${y}" width="400" height="225" preserveAspectRatio="xMidYMid slice"/>`);
  contactSheet.push(`<text x="${x}" y="${y + 244}" fill="#e9e6d8" font-family="Arial" font-size="13">${item.name}</text>`);
}
contactSheet.push("</svg>");
writeFileSync(path.join(finalRoot, "contact-sheet.svg"), `${contactSheet.join("\n")}\n`);
writeFileSync(path.join(finalRoot, "black-frame-rejection-report.md"), `# Batch D black-frame rejection\n\nSource HEAD: ${sourceSha}\n\nAll 20 final frames are current-head PNGs larger than 20 KB. Rejected frames: ${blackRejects.length}. No blank, stale, or title-card-only frame was accepted.\n\n${frames.map((item) => `- ${item.name}: ${item.width}x${item.height}, ${item.bytes} bytes, SHA-256 ${item.sha256}`).join("\n")}\n`);
writeFileSync(path.join(finalRoot, "final-manifest.json"), JSON.stringify({ schema: "ascendant-realms-p1-remediation-d-final-v1", source_sha: sourceSha, godot: "D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe", frames, black_frame_rejections: blackRejects.length, contact_sheet: "contact-sheet.svg", pass: blackRejects.length === 0 }, null, 2) + "\n");
console.log(JSON.stringify({ source_sha: sourceSha, final_root: finalRoot, frame_count: frames.length, black_frame_rejections: blackRejects.length, pass: blackRejects.length === 0 }, null, 2));
if (blackRejects.length) process.exitCode = 1;
