class_name StarPickup
extends RoomEntity
## Estrela solta na caverna: recupera uma estrela de vida.

signal collected

var _is_taken := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _animation: AnimationPlayer = $AnimationPlayer
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound


func _ready() -> void:
	super()
	# Cada estrela balança num tempo diferente.
	_animation.seek(fmod(global_position.x, _animation.current_animation_length))


func reset() -> void:
	_set_taken(false)


func _on_player_entered(_player: Player) -> void:
	if _is_taken:
		return
	_set_taken(true)
	_pickup_sound.play()
	collected.emit()


func _set_taken(value: bool) -> void:
	_is_taken = value
	_sprite.visible = not value
	_light.enabled = not value
