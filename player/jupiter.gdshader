shader_type canvas_item;
// Sprite do Jupiter.
// - O broche é pintado em magenta puro no PNG e trocado por `pin_color` (aceso/apagado).
// - Com `silhouette`, desenha só a forma da pose numa cor (rastro do dash).
// No fragment(), COLOR já vem multiplicado pela textura; por isso a cor do vértice
// (modulate) é guardada no vertex() e aplicada no fim sobre a textura lida à mão.

uniform vec4 pin_color : source_color = vec4(1.0, 0.902, 0.502, 1.0);
uniform bool silhouette = false;
uniform vec4 silhouette_color : source_color = vec4(0.561, 0.722, 1.0, 1.0);

const vec3 PIN_KEY = vec3(1.0, 0.0, 1.0);

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (distance(color.rgb, PIN_KEY) < 0.1) {
		color.rgb = pin_color.rgb;
	}
	if (silhouette) {
		color.rgb = silhouette_color.rgb;
	}
	COLOR = color * vertex_color;
}
