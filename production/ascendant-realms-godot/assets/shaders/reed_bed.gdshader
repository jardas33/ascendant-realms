shader_type spatial;
render_mode diffuse_burley, specular_disabled, cull_disabled;
// Tarn reeds: slim blades lit the same from both sides (a flat blade turned
// away from the sun drew near black), light through the leaf when the sun is
// behind it, each clump its own shade of green and straw, and a slow sway
// that leaves the roots planted. Presentation only.

uniform float sway = 0.10;

varying float v_h;
varying float v_tint;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	v_h = clamp(VERTEX.y / 2.3, 0.0, 1.0);
	v_tint = fract(sin(dot(origin.xz, vec2(12.9898, 78.233))) * 43758.5453);
	float gust = sin(TIME * 0.7 - origin.x * 0.05 - origin.z * 0.03) * 0.5 + 0.5;
	float lean = sin(TIME * 1.6 + origin.x * 0.4 + origin.z * 0.3) * (0.35 + 0.65 * gust);
	VERTEX.xz += vec2(0.8, 0.5) * lean * sway * v_h * v_h * 2.3;
}

void fragment() {
	// Vertex colours are authored in sRGB.
	vec3 col = pow(COLOR.rgb, vec3(2.2));
	// Clumps differ: fresher green, or drier straw.
	col *= mix(vec3(0.86, 0.94, 0.86), vec3(1.10, 1.04, 0.90), v_tint);
	ALBEDO = col;
	ROUGHNESS = 0.9;
	// Light the blade as if it faced the sky, tipped a little toward the
	// viewer, so neither side goes black.
	vec3 up = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	NORMAL = normalize(up * 0.8 + VIEW * 0.35);
	BACKLIGHT = col * 0.45 * v_h;
	AO = mix(0.55, 1.0, v_h);
	AO_LIGHT_AFFECT = 0.6;
}
