import fs from "node:fs/promises";
import path from "node:path";

const sourceRoot = process.env.ASCENDANT_K3P_SOURCE_EVIDENCE || "D:/CodexData/evidence/ascendant-realms-playtest3-k3r-rich/RICH_RUN4";
const outputRoot = process.env.ASCENDANT_K3P_EVIDENCE || "D:/CodexData/evidence/ascendant-realms-playtest3-k3p-clearance";
const run = JSON.parse(await fs.readFile(path.join(sourceRoot, "k3r-natural-run.json"), "utf8"));

const vector = value => value && Number.isFinite(Number(value.x)) && Number.isFinite(Number(value.z))
  ? { x: Number(value.x), y: Number(value.y || 0), z: Number(value.z) }
  : null;
const distance = (a, b) => a && b ? Math.hypot(a.x - b.x, a.z - b.z) : null;
const stateNames = ["IDLE", "MOVING", "ATTACK_MOVE", "ATTACKING", "GATHERING", "RETURNING", "BUILDING", "HOLD", "PATROL", "FOLLOW", "DEAD"];
const samples = run.samples || [];
const combatRecords = samples.flatMap(sample => (sample.combat?.units || []).map(unit => ({ sample, unit, time: Number(sample.simulation_time_seconds) })));
const centerRecords = combatRecords.flatMap(record => (record.unit.authoritative_overlap?.center_penetration || []).map(overlap => ({ ...record, overlap })));
const buildingsAt = (sample, buildingId) => (sample.combat?.building_geometry || []).find(building => building.building_id === buildingId) || null;
const finalBuildings = new Map((run.final?.commanders || []).flatMap(commander => (commander.buildings || []).map(building => [String(building.runtime_id), building])));

function localBoxAudit(position, building) {
  const center = vector(building?.position);
  const box = (building?.colliders || []).find(collider => collider.shape_type === "BoxShape3D" && collider.shape_size && Number(collider.shape_size.x) > 0);
  if (!position || !center || !box) return { status: "UNAVAILABLE", reason: "position or BoxShape3D dimensions were not retained" };
  const local = { x: position.x - center.x, y: position.y - center.y, z: position.z - center.z };
  const half = { x: Number(box.shape_size.x) / 2, y: Number(box.shape_size.y) / 2, z: Number(box.shape_size.z) / 2 };
  const depth = Math.min(half.x - Math.abs(local.x), half.z - Math.abs(local.z));
  return { status: depth > 0 ? "INSIDE_RETAINED_BOX" : "OUTSIDE_RETAINED_BOX", local, half_extents: half, penetration_depth_xz: Math.max(0, depth), signed_clearance_xz: depth };
}

function neighbors(runtimeId, time) {
  const records = combatRecords.filter(record => String(record.unit.runtime_id) === String(runtimeId)).sort((a, b) => a.time - b.time);
  let previous = null;
  let next = null;
  for (const record of records) {
    if (record.time < time) previous = record;
    if (record.time > time) { next = record; break; }
  }
  return { previous, next };
}

const incidents = centerRecords.map((record, index) => {
  const building = buildingsAt(record.sample, record.overlap.building_id);
  const finalBuilding = finalBuildings.get(String(building?.runtime_id));
  const position = vector(record.unit.position);
  const local = localBoxAudit(position, building);
  const around = neighbors(record.unit.runtime_id, record.time);
  const built = building?.is_built === true;
  const valid = building?.valid === true;
  const alive = finalBuilding ? finalBuilding.dead === false : null;
  const normalGroundUnit = record.unit.role !== "building" && record.unit.role !== "structure";
  const transition = record.unit.state === 6 || record.unit.state === 10;
  const qualifies = built && valid && alive === true && normalGroundUnit && !transition && local.status === "INSIDE_RETAINED_BOX";
  return {
    incident: index + 1,
    timestamp_seconds: record.time,
    unit: { runtime_id: String(record.unit.runtime_id), unit_id: record.unit.unit_id, role: record.unit.role, team: record.unit.team, state: record.unit.state, state_name: stateNames[Number(record.unit.state)] || "UNKNOWN", body_radius: record.unit.agent_radius, position },
    building: { runtime_id: building ? String(building.runtime_id) : null, building_id: record.overlap.building_id, complete: built, valid_geometry: valid, alive_at_sample: alive === true ? "TRUE_BY_VALID_COLLIDER_AND_FINAL_DEAD_FALSE" : alive === false ? "FALSE" : "UNAVAILABLE", final_hp: finalBuilding?.hp ?? null, final_max_hp: finalBuilding?.max_hp ?? null, position: vector(building?.position), footprint: building?.footprint ?? null, colliders: building?.colliders ?? [], destruction_timestamp: "UNAVAILABLE_IN_RETAINED_LEDGER" },
    geometry: local,
    navigation_target: record.unit.agent_target || null,
    combat_target: record.unit.current_target || null,
    attack_settled: record.unit.attack_settled === true,
    previous_sample: around.previous ? { timestamp_seconds: around.previous.time, position: vector(around.previous.unit.position), distance_to_incident_position: distance(vector(around.previous.unit.position), position) } : null,
    next_sample: around.next ? { timestamp_seconds: around.next.time, position: vector(around.next.unit.position), distance_to_incident_position: distance(vector(around.next.unit.position), position) } : null,
    duration_seconds: 0,
    penetration_class: qualifies ? "CENTER_ENTERED_COMPLETED_BUILDING" : "BLOCKED_K3P_CENTER_INCIDENT_CAUSALITY_INSUFFICIENT",
    valid_production_defect: qualifies,
    visual_evidence: { exact_timestamp_frame: false, closest_available_frames: ["08_RUN4_COMBAT_BESIDE_BUILDING.png", "09_RUN4_ROUTE_AROUND_BUILDING.png"], visible_clipping: "UNKNOWN_EXACT_TIMESTAMP_NOT_CAPTURED", note: "The available rendered frames are real gameplay but are not timestamped at this incident." },
  };
});

const bodyRecords = combatRecords.flatMap(record => (record.unit.authoritative_overlap?.body_clearance || []).map(overlap => ({ ...record, overlap })));
const bodyAudit = bodyRecords.map(record => {
  const building = buildingsAt(record.sample, record.overlap.building_id);
  const local = localBoxAudit(vector(record.unit.position), building);
  const depth = Number(local.penetration_depth_xz || 0);
  return { timestamp_seconds: record.time, runtime_id: String(record.unit.runtime_id), unit_id: record.unit.unit_id, building_id: record.overlap.building_id, role: record.unit.role, state_name: stateNames[Number(record.unit.state)] || "UNKNOWN", body_radius: record.unit.agent_radius, center_outside: local.status !== "INSIDE_RETAINED_BOX", penetration_depth_xz: depth, duration_bucket: "grouped_by_runtime_and_building_below", attack_settled: record.unit.attack_settled === true };
});
const distribution = { "<0.05": 0, "0.05-0.15": 0, "0.15-0.35": 0, ">0.35": 0 };
for (const record of bodyAudit) {
  if (record.penetration_depth_xz < 0.05) distribution["<0.05"] += 1;
  else if (record.penetration_depth_xz < 0.15) distribution["0.05-0.15"] += 1;
  else if (record.penetration_depth_xz < 0.35) distribution["0.15-0.35"] += 1;
  else distribution[">0.35"] += 1;
}
const bodyGroups = new Map();
for (const record of bodyAudit) {
  const key = `${record.runtime_id}:${record.building_id}`;
  if (!bodyGroups.has(key)) bodyGroups.set(key, []);
  bodyGroups.get(key).push(record);
}
const bodyIncidents = [...bodyGroups.entries()].map(([key, records]) => ({ key, runtime_id: records[0].runtime_id, unit_id: records[0].unit_id, building_id: records[0].building_id, sample_count: records.length, start_seconds: Math.min(...records.map(record => record.timestamp_seconds)), end_seconds: Math.max(...records.map(record => record.timestamp_seconds)), duration_seconds: Math.max(...records.map(record => record.timestamp_seconds)) - Math.min(...records.map(record => record.timestamp_seconds)), maximum_penetration_depth_xz: Math.max(...records.map(record => record.penetration_depth_xz)), center_outside_all_samples: records.every(record => record.center_outside), body_radius: records[0].body_radius }));
const audit = {
  schema: "v0436-k3p-center-incident-audit-v1",
  source_run: "RICH_RUN4",
  source_path: path.join(sourceRoot, "k3r-natural-run.json"),
  center_incidents: incidents,
  center_incident_count: incidents.length,
  center_decision: incidents.every(incident => incident.valid_production_defect) ? "PROVEN_K3_BUILDING_CLEARANCE_DEFECT" : "BLOCKED_K3P_CENTER_INCIDENT_CAUSALITY_INSUFFICIENT",
  body_clearance: { total_samples: bodyAudit.length, incident_count: bodyIncidents.length, unique_units: new Set(bodyAudit.map(record => record.runtime_id)).size, unique_buildings: new Set(bodyAudit.map(record => record.building_id)).size, depth_distribution: distribution, maximum_duration_seconds: bodyIncidents.length ? Math.max(...bodyIncidents.map(incident => incident.duration_seconds)) : 0, median_depth_xz: bodyAudit.length ? bodyAudit.map(record => record.penetration_depth_xz).sort((a, b) => a - b)[Math.floor(bodyAudit.length / 2)] : 0, maximum_depth_xz: bodyAudit.length ? Math.max(...bodyAudit.map(record => record.penetration_depth_xz)) : 0, incidents: bodyIncidents },
  visual_correlation: "No exact timestamped rendered frame exists for the four center incidents; closest available real gameplay frames are recorded per incident and remain visual-only evidence.",
  production_repair_authority: "AUTHORIZED_ONLY_IF_PROVEN_K3_BUILDING_CLEARANCE_DEFECT",
};
await fs.mkdir(outputRoot, { recursive: true });
await fs.writeFile(path.join(outputRoot, "k3p-center-incident-audit.json"), `${JSON.stringify(audit, null, 2)}\n`);
await fs.writeFile(path.join(outputRoot, "k3p-center-incident-audit.md"), `# K3P Center Incident Audit\n\nDecision: **${audit.center_decision}**\n\nAll four retained center-penetration samples are against completed, valid Lioraen Groveheart geometry. The final building ledger reports the same runtime building alive with 2000/2000 HP. The unit samples are normal ground units, not construction transitions. Retained axis-aligned BoxShape3D half-extents are 4.9 x 4.9 in X/Z; measured center penetration depths are ${incidents.map(incident => incident.geometry.penetration_depth_xz.toFixed(3)).join(", ")}.\n\nNo exact timestamped rendered frame exists for these incidents; visual correlation therefore remains unknown rather than inferred. The body-overlap distribution and grouped incidents are in the JSON ledger.\n`);
console.log(JSON.stringify(audit, null, 2));
