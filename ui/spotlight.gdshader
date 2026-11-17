shader_type canvas_item;
// Holofote: escurece a tela menos um círculo em volta de `center` e gira raios de luz
// a partir dele. Tudo em degraus pontilhados, no grão da pixel art.

uniform vec4 shade : source_color = vec4(0.02, 0.012, 0.07, 1.0);
uniform vec4 ray_color : source_color = vec4(1.0, 0.92, 0.6, 1.0);
uniform vec2 center = vec2(160.0, 90.0); // Em pixels da tela.
uniform float amount : hint_range(0.0, 1.0) = 0.0; // 0 = invisível, 1 = holofote aceso.
uniform float darkness : hint_range(0.0, 1.0) = 0.82;
uniform float radius = 26.0; // Raio do círculo iluminado.
uniform float feather = 30.0; // Largura da borda do círculo.
uniform float ray_reach = 100.0;
uniform float ray_count = 9.0;
uniform float ray_strength : hint_range(0.0, 1.0) = 0.32;
uniform vec2 grid = vec2(320.0, 180.0); // Resolução do jogo.
uniform float steps = 5.0;

void fragment() {
	vec2 pixel = floor(UV * grid) + 0.5;
	vec2 offset = pixel - center;
	float distance_to_center = length(offset);
	float noise = fract(52.9829189 * fract(dot(pixel, vec2(0.06711056, 0.00583715))));
	float dark = smoothstep(radius, radius + feather, distance_to_center);
	dark = floor(dark * steps + noise) / steps * darkness * amount;
	float angle = atan(offset.y, offset.x) + TIME * 0.3;
	float beam = smoothstep(0.72, 1.0, sin(angle * ray_count) * 0.5 + 0.5);
	float reach = clamp(1.0 - distance_to_center / ray_reach, 0.0, 1.0);
	float light = floor(beam * reach * steps + noise) / steps * ray_strength * amount;
	COLOR = vec4(mix(shade.rgb, ray_color.rgb, step(0.001, light)), max(dark * (1.0 - light), light));
}
