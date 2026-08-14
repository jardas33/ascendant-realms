import fs from 'node:fs';
import path from 'node:path';

const out = path.resolve('production/ascendant-realms-godot/assets/environment/buildings/barrosan_clanhold_authority.glb');
const positions = [];
const normals = [];
const materials = [
  ['Granite Foundation', [0.28, 0.30, 0.30, 1], 0.96, 0.0],
  ['Weathered Timber', [0.30, 0.13, 0.055, 1], 0.88, 0.0],
  ['Slate Roof', [0.12, 0.14, 0.15, 1], 0.94, 0.0],
  ['Iron Reinforcement', [0.08, 0.09, 0.095, 1], 0.72, 0.18],
  ['Authority Banner', [0.34, 0.10, 0.055, 1], 0.84, 0.0],
];
const indicesByMaterial = materials.map(() => []);

function vecAdd(a, b) { return [a[0] + b[0], a[1] + b[1], a[2] + b[2]]; }
function cross(a, b) { return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]; }
function normalize(v) {
  const d = Math.hypot(v[0], v[1], v[2]) || 1;
  return [v[0] / d, v[1] / d, v[2] / d];
}
function face(a, b, c, d, material) {
  const n = normalize(cross([b[0] - a[0], b[1] - a[1], b[2] - a[2]], [c[0] - a[0], c[1] - a[1], c[2] - a[2]]));
  const base = positions.length / 3;
  for (const p of [a, b, c, d]) { positions.push(...p); normals.push(...n); }
  indicesByMaterial[material].push(base, base + 1, base + 2, base, base + 2, base + 3);
}
function box(cx, cy, cz, sx, sy, sz, material) {
  const x = sx / 2, y = sy / 2, z = sz / 2;
  const p = [
    [cx - x, cy - y, cz - z], [cx + x, cy - y, cz - z], [cx + x, cy + y, cz - z], [cx - x, cy + y, cz - z],
    [cx + x, cy - y, cz + z], [cx - x, cy - y, cz + z], [cx - x, cy + y, cz + z], [cx + x, cy + y, cz + z],
  ];
  face(p[0], p[1], p[2], p[3], material); face(p[4], p[5], p[6], p[7], material);
  face(p[0], p[4], p[7], p[3], material); face(p[1], p[5], p[6], p[2], material);
  face(p[3], p[2], p[6], p[7], material); face(p[0], p[1], p[5], p[4], material);
}
function gable(cx, cy, cz, width, depth, wallTop, ridge, material) {
  const x = width / 2, z = depth / 2;
  const front = [[cx - x, cy + wallTop, cz - z], [cx + x, cy + wallTop, cz - z], [cx, cy + ridge, cz - z]];
  const back = front.map(p => [p[0], p[1], cz + z]);
  const tri = (a, b, c) => {
    const n = normalize(cross([b[0] - a[0], b[1] - a[1], b[2] - a[2]], [c[0] - a[0], c[1] - a[1], c[2] - a[2]]));
    const base = positions.length / 3;
    for (const p of [a, b, c]) { positions.push(...p); normals.push(...n); }
    indicesByMaterial[material].push(base, base + 1, base + 2);
  };
  tri(front[0], front[1], front[2]); tri(back[1], back[0], back[2]);
  face(front[0], back[0], back[2], front[2], material);
  face(front[2], back[2], back[1], front[1], material);
}

// Broad hall mass: intentionally horizontal and authority-scaled, unlike the narrow tower source.
box(0, 0.22, 0, 8.6, 0.44, 6.4, 0);
box(0, 1.65, 0.15, 6.8, 2.9, 5.2, 1);
box(-3.75, 1.35, 0.25, 1.35, 2.25, 5.35, 0);
box(3.75, 1.35, 0.25, 1.35, 2.25, 5.35, 0);
gable(0, 2.8, 0.15, 7.5, 5.7, 3.0, 4.25, 2);
box(-3.75, 2.55, 0.25, 1.7, 0.18, 5.8, 2);
box(3.75, 2.55, 0.25, 1.7, 0.18, 5.8, 2);
// Front gate, timber framing, and an authority banner make the entrance readable at RTS scale.
box(0, 1.30, -2.72, 1.55, 2.05, 0.18, 3);
box(0, 2.45, -2.84, 2.15, 0.18, 0.20, 1);
box(-2.7, 1.65, -2.72, 0.18, 2.35, 0.18, 1);
box(2.7, 1.65, -2.72, 0.18, 2.35, 0.18, 1);
box(0, 3.55, -2.86, 0.95, 0.9, 0.08, 4);
// Small non-colliding side buttresses provide a recognizable fortified-lodge profile.
box(-4.35, 1.05, -1.75, 0.55, 1.65, 0.85, 3);
box(4.35, 1.05, -1.75, 0.55, 1.65, 0.85, 3);

const posBytes = Buffer.from(new Float32Array(positions).buffer);
const normBytes = Buffer.from(new Float32Array(normals).buffer);
const chunks = [];
let offset = 0;
function align4() { while (offset % 4) { chunks.push(Buffer.from([0])); offset += 1; } }
function append(buf) { align4(); const start = offset; chunks.push(buf); offset += buf.length; return start; }
const posOffset = append(posBytes), normOffset = append(normBytes);
const indexBytes = indicesByMaterial.map((indices) => Buffer.from(new Uint16Array(indices).buffer));
const indexOffsets = indexBytes.map(append);
const buffer = Buffer.concat(chunks);
const views = [
  { buffer: 0, byteOffset: posOffset, byteLength: posBytes.length, target: 34962 },
  { buffer: 0, byteOffset: normOffset, byteLength: normBytes.length, target: 34962 },
  ...indexBytes.map((bytes, i) => ({ buffer: 0, byteOffset: indexOffsets[i], byteLength: bytes.length, target: 34963 })),
];
const accessors = [
  { bufferView: 0, componentType: 5126, count: positions.length / 3, type: 'VEC3', min: [-4.7, 0, -3.1], max: [4.7, 4.25, 3.2] },
  { bufferView: 1, componentType: 5126, count: normals.length / 3, type: 'VEC3' },
  ...indexBytes.map((bytes, i) => ({ bufferView: 2 + i, componentType: 5123, count: bytes.length / 2, type: 'SCALAR' })),
];
const meshPrimitives = indexBytes.map((bytes, i) => ({ attributes: { POSITION: 0, NORMAL: 1 }, indices: 2 + i, material: i }));
const gltf = {
  asset: { version: '2.0', generator: 'Ascendant Realms BUILDINGS-01C authored source generator', extras: { provenance: 'Project-authored low-poly Barrosan hall derived from the existing timber/stone/iron vocabulary; no external asset.' } },
  scene: 0,
  scenes: [{ nodes: [0] }],
  nodes: [{ name: 'BarrosanClanholdAuthority', mesh: 0 }],
  meshes: [{ name: 'BarrosanClanholdAuthorityMesh', primitives: meshPrimitives }],
  materials: materials.map(([name, color, roughness, metallic]) => ({ name, pbrMetallicRoughness: { baseColorFactor: color, metallicFactor: metallic, roughnessFactor: roughness } })),
  buffers: [{ byteLength: buffer.length }],
  bufferViews: views,
  accessors,
};
const json = Buffer.from(JSON.stringify(gltf));
function pad(buf, byte) { const extra = (4 - (buf.length % 4)) % 4; return extra ? Buffer.concat([buf, Buffer.alloc(extra, byte)]) : buf; }
const jsonPadded = pad(json, 0x20);
const binPadded = pad(buffer, 0);
const header = Buffer.alloc(12); header.writeUInt32LE(0x46546c67, 0); header.writeUInt32LE(2, 4); header.writeUInt32LE(12 + 8 + jsonPadded.length + 8 + binPadded.length, 8);
const jsonHeader = Buffer.alloc(8); jsonHeader.writeUInt32LE(jsonPadded.length, 0); jsonHeader.writeUInt32LE(0x4e4f534a, 4);
const binHeader = Buffer.alloc(8); binHeader.writeUInt32LE(binPadded.length, 0); binHeader.writeUInt32LE(0x004e4942, 4);
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, Buffer.concat([header, jsonHeader, jsonPadded, binHeader, binPadded]));
console.log(`wrote ${out} vertices=${positions.length / 3} triangles=${indexBytes.reduce((sum, bytes) => sum + bytes.length / 2, 0) / 3} bytes=${fs.statSync(out).size}`);
