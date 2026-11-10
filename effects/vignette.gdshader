shader_type canvas_item;
// Vinheta: escurece os cantos da tela em degraus pontilhados, no grão da pixel art.

uniform vec4 color : source_color = vec4(0.03, 0.02, 0.09, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.38;
uniform float start : hint_range(0.0, 1.5) = 0.8; // Distância do centro em que começa a escurecer.
uniform vec2 grid = vec2(320.0, 180.0); // Resolução do jogo.
uniform float steps = 7.0;

void fragment() {
	vec2 pixel = floor(UV * grid);
	vec2 from_center = (pixel + 0.5) / grid - 0.5;
	from_center.x *= 1.2;
	float amount = smoothstep(start, 1.25, length(from_center) * 1.7);
	float noise = fract(52.9829189 * fract(dot(pixel, vec2(0.06711056, 0.00583715))));
	amount = floor(amount * steps + noise) / steps;
	COLOR = vec4(color.rgb, clamp(amount, 0.0, 1.0) * strength);
}
