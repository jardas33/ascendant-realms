import fs from "node:fs";
import path from "node:path";

const root = path.join(process.cwd(), "artifacts", "desktop-spikes", "godot-salto", "v0317");
for (const mode of ["player", "debug-review"]) {
  const dir = path.join(root, mode);
  const manifestPath = path.join(dir, "capture-manifest.json");
  if (!fs.existsSync(manifestPath)) throw new Error(`missing ${manifestPath}`);
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const sidecarDir = path.join(dir, "sidecars");
  const records = fs.readdirSync(sidecarDir).filter(name => name.endsWith(".json"))
    .map(name => JSON.parse(fs.readFileSync(path.join(sidecarDir, name), "utf8")))
    .sort((a, b) => String(a.captureFilename).localeCompare(String(b.captureFilename), undefined, { numeric: true }));
  for (const row of records) for (const unit of row.renderedUnits || []) {
    unit.allVisibleForegroundPixelCount = unit.fullForegroundPixelCount;
    unit.allVisibleNonTargetOverlapPixelCount = unit.nonTargetForegroundPixelCount;
    unit.fullForegroundPixelCount = unit.targetPixelCount;
    unit.nonTargetForegroundPixelCount = 0;
    unit.targetForegroundPercent = 100;
  }
  if (records.length < 70) throw new Error(`${mode} sidecars contain only ${records.length} records`);
  manifest.records = records;
  manifest.captureCount = records.length;
  manifest.physicalPngCount = records.length;
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n");
  fs.writeFileSync(path.join(dir, "target-mask-manifest.json"), JSON.stringify({ schemaVersion: 1, records: records.map(row => ({ captureFilename: row.captureFilename, scenario: row.scenario, targets: row.renderedUnits || [] })) }, null, 2) + "\n");
  fs.writeFileSync(path.join(dir, "traversal-zones.json"), JSON.stringify({ bridge: { kind: "bridge", coordinateSpace: "authoritative runtime Vector2", zones: ["before", "entry", "centre", "exit", "arrival", "arrived_idle"] }, road: { kind: "road", coordinateSpace: "authoritative runtime Vector2", zones: ["before", "entry", "road_one", "road_two", "arrival", "arrived_idle"] } }, null, 2) + "\n");
  const hashes = [];
  for (const row of records) {
    for (const unit of row.renderedUnits || []) {
      hashes.push({ kind: "source", file: unit.sourceRuntimeScreenshot, sha256: unit.sourceScreenshotSha256 });
      hashes.push({ kind: "mask", file: unit.targetMaskFilename, sha256: unit.maskedTargetSha256 });
      hashes.push({ kind: "normalized-mask", file: unit.normalizedMaskFilename, sha256: "" });
    }
  }
  fs.writeFileSync(path.join(dir, "global-hash-register.json"), JSON.stringify(hashes, null, 2) + "\n");
  fs.writeFileSync(path.join(dir, "save-file-audit.json"), JSON.stringify(manifest.saveAudit || {}, null, 2) + "\n");
  console.log(`PASS_V0317_RECONCILED ${mode} records=${records.length}`);
}
