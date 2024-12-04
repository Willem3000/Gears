shader_type canvas_item;

uniform vec4 unshaded_color = vec4(.09, .09, .09, 1.0);
uniform vec3 highlight_color = vec3(.0, .0, .0);

float quantize(float value, float step_value) {
	return min(round(value / step_value) * step_value, 1.0);
}

void fragment() {
	COLOR = vec4(unshaded_color.rgb, COLOR.a);
}

void light() {
	if (LIGHT_ENERGY > 0.2) {
		float size = LIGHT_COLOR.r;
		float layer = quantize((LIGHT_COLOR.a - (1.0 - size)) * ((LIGHT_ENERGY) * 1.0 / size), 0.25);
		if (layer > 0.) {
			LIGHT = texture(TEXTURE, vec2(UV.x, UV.y - 0.25 + layer)) + vec4(highlight_color, LIGHT.a);
			SHADOW_MODULATE = texture(TEXTURE, vec2(UV.x, UV.y - 0.5 + layer));
		}
	}
}