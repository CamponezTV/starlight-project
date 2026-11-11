shader_type canvas_item;
// Luz do ambiente nos bustos das cutscenes: `tint` multiplica a cor (o banho de luz da
// cena) e `rim` acende a borda do lado para onde o personagem olha (luz de contorno).

uniform vec4 tint : source_color = vec4(1.0);
uniform vec4 rim : source_color = vec4(0.0);
uniform float rim_width = 2.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb *= tint.rgb;
	// A borda é onde o vizinho na direção da luz (frente e cima) já é transparente.
	float ahead = texture(TEXTURE, UV + vec2(1.0, -0.6) * TEXTURE_PIXEL_SIZE * rim_width).a;
	color.rgb = mix(color.rgb, rim.rgb, color.a * (1.0 - ahead) * rim.a);
	COLOR = color;
}
