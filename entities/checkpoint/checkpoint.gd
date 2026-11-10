class_name Checkpoint
extends RoomEntity
## Checkpoint: uma estrela adormecida num pedestal. Acende quando Jupiter passa por ela.

signal activated(respawn_point: Vector2)

enum Frame { OFF, LIT }

var _is_lit := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _glow: Sprite2D = $Sprite/Glow
@onready var _sparkles: CPUParticles2D = $Sprite/Sparkles
@onready var _light_up_sound: AudioStreamPlayer = $LightUpSound


func reset() -> void:
	_set_lit(false)


func _on_player_entered(_player: Player) -> void:
	if _is_lit:
		return
	_set_lit(true)
	_light_up_sound.play()
	activated.emit(global_position)


func _set_lit(value: bool) -> void:
	_is_lit = value
	_sprite.frame = Frame.LIT if value else Frame.OFF
	_light.enabled = value
	_glow.visible = value
	_sparkles.emitting = value
