shader_type canvas_item;
render_mode blend_add, unshaded;
// Feixe de luz do fundo: respira devagar, cada feixe no seu tempo.

uniform vec4 tint : source_color = vec4(0.55, 0.85, 1.0, 1.0);
uniform float speed = 0.5;
uniform float phase = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float breath = 0.7 + 0.3 * sin(TIME * speed + phase);
	COLOR = vec4(tint.rgb, color.a * tint.a * breath);
}
