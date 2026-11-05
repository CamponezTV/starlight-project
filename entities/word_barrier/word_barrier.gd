class_name WordBarrier
extends RoomEntity
## Barreira de palavras: uma parede que só quebra com um dash carregando a voz.
## Quebrada, fica assim até o reset da fase.

signal broken

@export var shatter_effect: PackedScene

var _player_inside: Player
var _is_broken := false

@onready var _wall_collision: CollisionShape2D = $Wall/Collision
@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _break_sound: AudioStreamPlayer = $BreakSound


func reset() -> void:
	_set_broken(false)


func is_broken() -> bool:
	return _is_broken


func _physics_process(_delta: float) -> void:
	if not _is_broken and _player_inside != null and _player_inside.is_dashing() and _player_inside.has_voice:
		_player_inside.spend_voice()
		_shatter()


func _shatter() -> void:
	_set_broken(true)
	_break_sound.play()
	var effect := shatter_effect.instantiate() as Node2D
	add_sibling(effect)
	effect.global_position = _sprite.global_position
	effect.reset_physics_interpolation()
	broken.emit()


func _set_broken(value: bool) -> void:
	_is_broken = value
	_wall_collision.set_deferred(&"disabled", value)
	_sprite.visible = not value
	_light.enabled = not value


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null
