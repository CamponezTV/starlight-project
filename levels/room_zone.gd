@tool
class_name RoomZone
extends Node2D
## Uma sala da fase: o retângulo (a partir da posição do nó) que limita a câmera.
## Os Marker2D filhos são os pontos de renascimento: ao entrar na sala, Jupiter
## passa a renascer no ponto mais perto de onde entrou.
## No editor, a sala aparece como um contorno azul.

const EDITOR_OUTLINE := Color(0.5, 0.8, 1.0, 0.7)

@export var size := Vector2(320, 184):
	set(value):
		size = value
		queue_redraw()


func bounds() -> Rect2:
	return Rect2(global_position, size)


func contains(point: Vector2) -> bool:
	return bounds().has_point(point)


## O ponto de renascimento mais perto de `point`. Sem pontos, devolve o próprio `point`.
func nearest_spawn(point: Vector2) -> Vector2:
	var best := point
	var best_distance := INF
	for child in get_children():
		var marker := child as Marker2D
		if marker == null:
			continue
		var distance := marker.global_position.distance_squared_to(point)
		if distance < best_distance:
			best_distance = distance
			best = marker.global_position
	return best


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, size), EDITOR_OUTLINE, false, 1.0)
