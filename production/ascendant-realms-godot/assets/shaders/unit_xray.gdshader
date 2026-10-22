shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_back, blend_mix, shadows_disabled, fog_disabled;
// Occluded-unit silhouette, drawn as a material overlay on unit meshes. It
// compares each fragment with the opaque depth buffer and only draws where
// something solid (a tree canopy, a building) stands clearly in front of the
// unit, so units never vanish behind scenery. Self-overlap, other units and grass at the
// feet stay below the threshold and draw nothing.

uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform float min_gap = 2.5; // above unit-to-unit overlap depth (about 1.5 m at play pitch)
instance uniform vec4 xray_color : source_color = vec4(0.35, 0.62, 1.0, 1.0);
// Plan 410: a struck unit glows along its own outline for a moment (hit
// 0..1, set per unit while the hit flash runs). Only the front-most surface
// draws it, so the glow follows the body instead of a blob over the belly.
instance uniform float hit = 0.0;
instance uniform vec4 hit_color : source_color = vec4(1.0, 0.8, 0.52, 1.0);

void fragment() {
	float d = texture(depth_tex, SCREEN_UV).r;
	vec4 view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, d, 1.0);
	float scene_z = -view.z / view.w;
	float frag_z = -VERTEX.z;
	float rim = 1.0 - clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	if (frag_z < scene_z + min_gap) {
		if (hit <= 0.001 || frag_z > scene_z + 0.08) {
			discard;
		}
		ALBEDO = hit_color.rgb;
		ALPHA = hit * (0.04 + 0.6 * rim * rim * rim);
	} else {
		ALBEDO = xray_color.rgb;
		// A faint body with a brighter rim reads as a silhouette, not a paint blob.
		ALPHA = 0.12 + 0.62 * rim * rim;
	}
}
