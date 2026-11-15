class_name Sprout
extends RoomEntity
## Broto-mola: lança o Jupiter para cima (mais alto que um pulo) e devolve o dash.

const FRAME_IDLE := 0
const FRAME_SQUASHED := 1
const FRAME_STRETCHED := 2
const SQUASH_TIME := 0.07
const STRETCH_TIME := 0.2

@export var bounce_speed := 300.0

var _tween: Tween

@onready var _sprite: Sprite2D = $Sprite
@onready var _bounce_sound: AudioStreamPlayer = $BounceSound


func _on_player_entered(player: Player) -> void:
	if player.is_dead():
		return
	player.bounce(bounce_speed)
	_bounce_sound.play()
	if _tween != null:
		_tween.kill()
	_sprite.frame = FRAME_SQUASHED
	_tween = create_tween()
	_tween.tween_interval(SQUASH_TIME)
	_tween.tween_callback(_sprite.set_frame.bind(FRAME_STRETCHED))
	_tween.tween_interval(STRETCH_TIME)
	_tween.tween_callback(_sprite.set_frame.bind(FRAME_IDLE))
