shader_type canvas_item;
// Véu do portal: luz que sobe em ondas, com estrelinhas, só onde a máscara é opaca.
// `power` passa de 1 quando o portal puxa o Jupiter.

uniform vec4 core : source_color = vec4(1.0, 0.97, 0.84, 1.0);
uniform vec4 edge : source_color = vec4(0.52, 0.4, 0.95, 1.0);
uniform float power = 1.0;
uniform vec2 size = vec2(48.0, 56.0); // Tamanho da máscara, em pixels.
uniform float half_width = 12.0; // Do meio do vão até a pedra.
uniform float steps = 4.0;

void fragment() {
	vec2 pixel = floor(UV * size);
	float centered = 1.0 - abs(pixel.x + 0.5 - size.x * 0.5) / half_width;
	float wave = sin(pixel.y * 0.45 - TIME * 3.0 + sin(pixel.x * 0.7 + TIME) * 1.2) * 0.5 + 0.5;
	float glow = clamp((centered * 0.7 + wave * 0.35) * power, 0.0, 1.0);
	glow = floor(glow * steps + 0.5) / steps;
	vec2 cell = vec2(pixel.x, floor(pixel.y + TIME * 14.0));
	float star = step(0.965, fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453));
	vec3 light = mix(mix(edge.rgb, core.rgb, glow), vec3(1.0), star);
	COLOR = vec4(light, texture(TEXTURE, UV).a * clamp(0.5 + glow * 0.5 + star, 0.0, 1.0));
}
