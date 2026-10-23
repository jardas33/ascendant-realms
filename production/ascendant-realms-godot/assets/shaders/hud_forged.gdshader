shader_type canvas_item;
// Plan 425: lit forged metal for the battle HUD. A panel hands over its
// outline as a polygon; the shader turns it into a raised, bevelled bronze
// rim, a dark groove and a hammered iron plate, lit from the upper left,
// with rivets, gem bosses, an optional open window (the minimap) and a soft
// drop shadow. Everything is computed from distances, so it stays crisp at
// any HUD scale.

const int MAX_PTS = 24;
const int MAX_STUDS = 24;

uniform int point_count = 0;
uniform vec2 pts[MAX_PTS];
uniform int stud_count = 0;
uniform vec4 studs[MAX_STUDS];          // x, y, radius, kind (0 rivet, 1 gem, 2 large boss)
const int MAX_LINES = 16;
uniform int line_count = 0;
uniform vec4 lines[MAX_LINES];          // engraved seams: x0, y0, x1, y1
uniform vec4 window_rect = vec4(0.0);   // x, y, w, h; w = 0 means none
uniform float rim = 9.0;
uniform float groove = 2.5;
uniform float inlay = 9.0;              // engraved line this far inside the groove; 0 = none
uniform float shadow_size = 12.0;
uniform float plate_alpha = 0.975;
uniform float top_light = 1.0;          // brightening of the plate's upper part
uniform vec3 iron_hi : source_color = vec3(0.155, 0.145, 0.132);
uniform vec3 iron_lo : source_color = vec3(0.055, 0.058, 0.064);
uniform vec3 bronze : source_color = vec3(0.70, 0.50, 0.26);
uniform vec3 gem_color : source_color = vec3(0.62, 0.10, 0.06);
uniform float plate_top = 0.0;          // local y where the plate's gradient starts
uniform float plate_bottom = 200.0;
// Plan 433: Codex's painted slate as the plate, mirrored so it never seams.
uniform sampler2D plate_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform float plate_tex_mix = 0.0;
uniform float plate_tex_size = 300.0;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + vec2(17.1, 9.3);
		a *= 0.5;
	}
	return v;
}

// Signed distance to the polygon (negative inside) and its outward gradient.
vec3 sd_poly(vec2 p) {
	float d = 1e9;
	vec2 best = vec2(0.0);
	float s = 1.0;
	int n = point_count;
	for (int i = 0; i < MAX_PTS; i++) {
		if (i >= n) { break; }
		int j = (i == 0) ? n - 1 : i - 1;
		vec2 a = pts[i];
		vec2 e = pts[j] - a;
		vec2 w = p - a;
		vec2 b = w - e * clamp(dot(w, e) / max(dot(e, e), 1e-4), 0.0, 1.0);
		float bb = dot(b, b);
		if (bb < d) { d = bb; best = b; }
		bool c1 = p.y >= a.y;
		bool c2 = p.y < pts[j].y;
		bool c3 = e.x * w.y > e.y * w.x;
		if ((c1 && c2 && c3) || (!c1 && !c2 && !c3)) { s = -s; }
	}
	float dist = sqrt(d);
	vec2 g = dist > 1e-4 ? best / dist : vec2(0.0, -1.0);
	return vec3(s * dist, s * g);
}

// A rounded bevel from 0 at the outer edge to a crest and down again.
float rim_profile(float t) {
	t = clamp(t, 0.0, 1.0);
	// A thin outer bead, a small step, then the main rounded bevel.
	float bead = smoothstep(0.0, 0.10, t) * (1.0 - smoothstep(0.16, 0.26, t)) * 0.55;
	float up = smoothstep(0.24, 0.58, t);
	float down = 1.0 - smoothstep(0.70, 1.0, t);
	return max(bead, up * down);
}

vec4 shade(vec2 p) {
	vec3 sp = sd_poly(p);
	float sd = sp.x;
	vec2 grad = sp.yz;              // outward
	float depth = -sd;              // distance inside the outline
	float aa = 0.75;

	// Drop shadow, cast downward and a little right.
	if (sd > 0.0) {
		float fall = clamp(0.30 + 0.70 * max(grad.y, 0.0) + 0.2 * max(grad.x, 0.0), 0.0, 1.0);
		float sh = (1.0 - smoothstep(0.0, shadow_size, sd)) * 0.55 * fall;
		return vec4(0.0, 0.0, 0.0, sh);
	}

	// Height field (in pixels) and its gradient along the inward normal.
	float h = 0.0;
	float dh = 0.0;                 // dh / d(depth)
	vec3 albedo;
	float spec_k = 0.0;
	float rough = 18.0;
	float ao = 1.0;
	int region = 0;                 // 0 rim, 1 groove, 2 plate
	float rim_w = rim;
	if (depth < rim_w) {
		float t = depth / rim_w;
		h = 6.0 * rim_profile(t);
		dh = 6.0 * (rim_profile(t + 0.02) - rim_profile(t - 0.02)) / (0.04 * rim_w);
		float brush = vnoise(vec2(p.x * 0.08 + p.y * 0.08, depth * 1.7)) * 0.5 + fbm(p * 0.35) * 0.5;
		float wear = smoothstep(0.35, 0.75, fbm(p * 0.06));
		albedo = bronze * (0.70 + 0.40 * brush);
		albedo = mix(albedo * 0.55, albedo, 0.55 + 0.45 * wear);
		spec_k = 0.85;
		rough = 22.0;
	} else if (depth < rim_w + groove) {
		region = 1;
		h = -0.6;
		albedo = vec3(0.018, 0.014, 0.010);
		spec_k = 0.0;
	} else {
		region = 2;
		float inner = depth - rim_w - groove;
		float ham = fbm(p * 0.11);
		h = 0.4 + ham * 0.9;
		float yt = clamp((p.y - plate_top) / max(plate_bottom - plate_top, 1.0), 0.0, 1.0);
		albedo = mix(iron_hi * (1.0 + 0.25 * top_light), iron_lo, smoothstep(0.0, 1.0, yt));
		float mott = fbm(p * 0.045 + vec2(3.0, 7.0));
		albedo *= 0.80 + 0.42 * mott;
		albedo += vec3(0.020, 0.012, 0.004) * smoothstep(0.55, 0.9, fbm(p * 0.02));
		if (plate_tex_mix > 0.0) {
			vec2 tuv = p / plate_tex_size;
			tuv = 1.0 - abs(mod(tuv, 2.0) - 1.0);
			vec3 slate = texture(plate_tex, tuv).rgb;
			vec3 lit = slate * mix(1.12, 0.72, smoothstep(0.0, 1.0, yt));
			albedo = mix(albedo, lit, plate_tex_mix);
		}
		ao = mix(0.42, 1.0, smoothstep(0.0, 16.0, inner));
		spec_k = 0.16;
		rough = 10.0;
		if (inlay > 0.0) {
			float li = abs(inner - inlay);
			float cut = 1.0 - smoothstep(0.35, 1.25, li);
			h -= cut * 0.9;
			dh = -sign(inner - inlay) * cut * 0.9;
			albedo = mix(albedo, bronze * 0.42, cut * 0.65);
			// A faint gilt catch on the far wall of the engraving.
			float catch = (1.0 - smoothstep(0.0, 0.9, abs(inner - inlay - 1.1)));
			albedo += bronze * 0.30 * catch;
		}
	}

	// Engraved seams cut into the plate.
	if (region == 2) {
		for (int k = 0; k < MAX_LINES; k++) {
			if (k >= line_count) { break; }
			vec4 ln = lines[k];
			vec2 a = ln.xy;
			vec2 e = ln.zw - a;
			vec2 w = p - a;
			float t = clamp(dot(w, e) / max(dot(e, e), 1e-4), 0.0, 1.0);
			vec2 off = w - e * t;
			float dl = length(off);
			float cut = 1.0 - smoothstep(0.5, 1.6, dl);
			if (cut > 0.0) {
				vec2 nrm = dl > 1e-3 ? off / dl : vec2(0.0);
				// Walls of a V cut: the side facing the light catches it.
				dh = 0.0;
				h -= cut;
				albedo = mix(albedo, vec3(0.02, 0.015, 0.01), cut * 0.7);
				float lit = max(dot(nrm, vec2(0.5, 0.7)), 0.0);
				albedo += bronze * 0.45 * lit * cut;
			}
		}
	}

	// The normal: from the outline's slope plus small surface noise.
	vec2 inward = -grad;
	vec2 slope = inward * dh;
	if (region == 2) {
		float e = 1.2;
		float n0 = fbm(p * 0.11);
		float nx = fbm((p + vec2(e, 0.0)) * 0.11);
		float ny = fbm((p + vec2(0.0, e)) * 0.11);
		slope += vec2(nx - n0, ny - n0) / e * 0.9 * 2.2;
	} else if (region == 0) {
		float n0 = vnoise(p * 0.5);
		slope += vec2(vnoise((p + vec2(1.0, 0.0)) * 0.5) - n0, vnoise((p + vec2(0.0, 1.0)) * 0.5) - n0) * 0.15;
	}

	// The minimap opening and its raised sill.
	if (window_rect.z > 0.0) {
		vec2 wc = window_rect.xy + window_rect.zw * 0.5;
		vec2 q = abs(p - wc) - window_rect.zw * 0.5;
		float dw = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
		if (dw < 0.0) {
			// Inner shadow cast by the sill onto the map.
			float s2 = 1.0 - smoothstep(0.0, 9.0, -dw);
			return vec4(0.0, 0.0, 0.0, 0.62 * s2);
		}
		float sill = 7.0;
		if (dw < sill) {
			vec2 wg;
			if (q.x > 0.0 && q.y > 0.0) { wg = normalize(max(q, 0.0)); }
			else if (q.x > q.y) { wg = vec2(sign(p.x - wc.x), 0.0); }
			else { wg = vec2(0.0, sign(p.y - wc.y)); }
			float t = 1.0 - dw / sill;
			h = 5.0 * rim_profile(t);
			float d2 = 5.0 * (rim_profile(t + 0.02) - rim_profile(t - 0.02)) / (0.04 * sill);
			slope = wg * d2;
			float brush = fbm(p * 0.35);
			albedo = bronze * (0.70 + 0.40 * brush);
			spec_k = 0.85;
			rough = 22.0;
			ao = 1.0;
			region = 0;
		} else {
			ao *= mix(0.55, 1.0, smoothstep(sill, sill + 12.0, dw));
		}
	}

	// Studs: rivets and gem bosses sit on top of whatever is under them.
	for (int k = 0; k < MAX_STUDS; k++) {
		if (k >= stud_count) { break; }
		vec4 s = studs[k];
		vec2 dp = p - s.xy;
		float r = s.z;
		float dd = length(dp);
		// Contact shadow around each stud.
		if (dd < r * 1.6 && dd >= r) {
			ao *= mix(0.45, 1.0, smoothstep(r, r * 1.6, dd + 0.0 * s.w));
		}
		if (dd < r) {
			float z = sqrt(max(r * r - dd * dd, 0.0));
			slope = dp / max(z, 0.35);
			if (s.w > 0.5) {
				float bezel = r * 0.68;
				if (dd > bezel) {
					albedo = bronze * 0.95;
					spec_k = 0.9;
					rough = 26.0;
				} else {
					float zg = sqrt(max(bezel * bezel - dd * dd, 0.0));
					slope = dp / max(zg, 0.35) * 0.8;
					albedo = gem_color * (0.65 + 0.6 * (1.0 - dd / bezel));
					spec_k = 1.4;
					rough = 60.0;
				}
			} else {
				albedo = bronze * 0.85;
				spec_k = 0.9;
				rough = 24.0;
			}
			ao = 1.0;
		}
	}

	vec3 N = normalize(vec3(-slope.x, -slope.y, 1.0));
	vec3 L = normalize(vec3(-0.50, -0.70, 0.62));
	vec3 V = vec3(0.0, 0.0, 1.0);
	float diff = max(dot(N, L), 0.0);
	vec3 R = reflect(-L, N);
	float spec = pow(max(dot(R, V), 0.0), rough) * spec_k;
	float fill = max(dot(N, normalize(vec3(0.6, 0.3, 0.5))), 0.0) * 0.12;
	vec3 col = albedo * (0.42 + 0.78 * diff + fill) * ao;
	col += spec * mix(vec3(1.0, 0.86, 0.62), vec3(1.0), 0.2) * (region == 2 ? 0.6 : 1.0);
	// A dark bed line round the very outside so the rim reads on bright ground.
	col *= mix(0.25, 1.0, smoothstep(0.4, 1.6, depth));
	float edge = smoothstep(0.0, 1.1, depth);
	return vec4(col, plate_alpha * edge);
}

void fragment() {
	COLOR = shade(local_pos);
}
