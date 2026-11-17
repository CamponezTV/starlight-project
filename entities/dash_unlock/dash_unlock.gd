class_name DashUnlock
extends RoomEntity
## O broche do avô, num altar: quem pega aprende o dash. O broche some de vez depois de
## pego; o altar fica.

signal collected(skill: Skill)

const BOB_SPEED := 3.0
const BOB_HEIGHT := 2.0
const TWINKLE_FPS := 6.0

@export var skill: Skill ## O que o holofote mostra.

var _time := 0.0

@onready var _visual: Node2D = $Visual
@onready var _sprite: Sprite2D = $Visual/Sprite
@onready var _rest_y := _visual.position.y
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound


func _process(delta: float) -> void:
	_time += delta
	_visual.position.y = _rest_y + sin(_time * BOB_SPEED) * BOB_HEIGHT
	_sprite.frame = int(_time * TWINKLE_FPS) % _sprite.hframes


func _on_player_entered(player: Player) -> void:
	if not _visual.visible or player.dash_unlocked:
		return
	player.dash_unlocked = true
	_visual.hide()
	_pickup_sound.play()
	collected.emit(skill)
