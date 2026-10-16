shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Dressed stone for the great walls and dams. The rock texture gives the
// grain; on top of it the faces are laid in courses of cut blocks (each
// course offset by half a block, each block its own shade) with sunken
// mortar joints, and the tops are paved with flagstones. Everything is in
// world metres along each face, so a long wall never stretches its stones.
// The vertex color still darkens the foot of the wall.

uniform sampler2D rock : source_color, filter_linear_mipmap, repeat_enable;
uniform float rock_scale = 0.16;
uniform vec3 stone_tint : source_color = vec3(0.78, 0.76, 0.72);
uniform float course_height = 0.9;
uniform float block_length = 1.8;
uniform float joint = 0.06;

varying vec3 wpos;

float hash21(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint h = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	h = (h ^ (h >> 16u)) * 2246822519u;
	h ^= h >> 13u;
	h *= 3266489917u;
	h ^= h >> 16u;
	return float(h) * (1.0 / 4294967295.0);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Each face's true flat normal. The mesh's own normals are smoothed
	// across the box corners, and the course direction taken from them
	// turned across a face, so the blocks shrank to slivers in places.
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
	vec3 n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	// Triplanar rock grain.
	vec3 w = pow(abs(n), vec3(4.0));
	w /= (w.x + w.y + w.z);
	vec3 p = wpos * rock_scale;
	vec3 grain = texture(rock, p.zy).rgb * w.x + texture(rock, p.xz).rgb * w.y + texture(rock, p.xy).rgb * w.z;

	vec2 uv;
	vec2 cell_size;
	float offset;
	if (abs(n.y) < 0.6) {
		// A face: along the face horizontally, height up it.
		vec2 t = normalize(vec2(-n.z, n.x));
		float row = floor(wpos.y / course_height);
		offset = (mod(row, 2.0) * 0.5 + hash21(vec2(row, 7.0)) * 0.3) * block_length;
		uv = vec2(dot(wpos.xz, t) + offset, wpos.y);
		cell_size = vec2(block_length, course_height);
	} else {
		// A top: flagstones in staggered rows.
		float row = floor(wpos.z / 1.4);
		offset = mod(row, 2.0) * 0.8;
		uv = vec2(wpos.x + offset, wpos.z);
		cell_size = vec2(1.6, 1.4);
	}
	vec2 cell = floor(uv / cell_size);
	vec2 local = (uv / cell_size - cell) * cell_size;
	float edge = min(min(local.x, cell_size.x - local.x), min(local.y, cell_size.y - local.y));
	float shade = hash21(cell + vec2(31.0, 17.0));
	// Each block a touch lighter or darker, a few warmer.
	vec3 block = stone_tint * mix(0.80, 1.08, shade);
	block *= mix(vec3(1.0), vec3(1.06, 1.0, 0.92), step(0.78, hash21(cell + vec2(5.0, 91.0))));
	// The arrises catch a little light; the joints sit in shadow.
	float bevel = smoothstep(joint, joint + 0.16, edge);
	float mortar = 1.0 - smoothstep(joint * 0.5, joint, edge);
	vec3 color = grain * block * mix(0.82, 1.0, bevel);
	color = mix(color, grain * stone_tint * 0.42, mortar);
	ALBEDO = color * COLOR.rgb;
	ROUGHNESS = mix(0.92, 1.0, mortar);
	AO = mix(0.55, 1.0, bevel);
	AO_LIGHT_AFFECT = 0.4;
}
