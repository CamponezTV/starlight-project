class_name FollowCamera
extends Camera2D
## Câmera que segue um alvo, respeita os limites da sala e treme sob demanda.

const SHAKE_DECAY := 14.0

@export var target_offset := Vector2(0, -16)

var target: Node2D

var _shake := 0.0


func set_bounds(bounds: Rect2) -> void:
	limit_left = int(bounds.position.x)
	limit_top = int(bounds.position.y)
	limit_right = int(bounds.end.x)
	limit_bottom = int(bounds.end.y)


## Pula direto para o alvo, sem suavização (início da fase, teleportes).
func snap_to_target() -> void:
	if target == null:
		return
	global_position = _target_point()
	reset_smoothing()
	reset_physics_interpolation()


## Treme a tela. Tremores menores que o atual são ignorados.
func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _physics_process(delta: float) -> void:
	if target != null:
		global_position = _target_point()
	_shake = move_toward(_shake, 0.0, SHAKE_DECAY * delta)
	offset = Vector2(roundf(randf_range(-_shake, _shake)), roundf(randf_range(-_shake, _shake)))


func _target_point() -> Vector2:
	return target.global_position + target_offset
