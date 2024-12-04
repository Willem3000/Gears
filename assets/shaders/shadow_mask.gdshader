shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
	vec4 mask_color = texture(mask, UV).rgba;
	
	COLOR.a = min(COLOR.a, mask_color.a);
}
