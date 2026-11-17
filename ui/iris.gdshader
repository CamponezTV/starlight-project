shader_type canvas_item;
// Íris de luz: um círculo que cresce a partir de `center` até tomar a tela, com a borda
// pontilhada no grão da pixel art.

uniform vec4 color : source_color = vec4(1.0, 0.97, 0.84, 1.0);
uniform vec2 center = vec2(160.0, 90.0); // Em pixels da tela.
uniform float radius = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0; // O `modulate` do nó não vale aqui: o shader escreve a cor inteira.
uniform float feather = 18.0;
uniform vec2 grid = vec2(320.0, 180.0); // Resolução do jogo.
uniform float steps = 5.0;

void fragment() {
	vec2 pixel = floor(UV * grid) + 0.5;
	float noise = fract(52.9829189 * fract(dot(pixel, vec2(0.06711056, 0.00583715))));
	float inside = 1.0 - smoothstep(radius - feather, radius, length(pixel - center));
	COLOR = vec4(color.rgb, clamp(floor(inside * steps + noise) / steps, 0.0, 1.0) * opacity);
}
