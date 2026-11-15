class_name DashUnlock
extends RoomEntity
## O broche do avô: quem pega aprende o dash. Some de vez depois de pego.

signal collected(message: String)

const MESSAGE := "O broche do vovô acende. X: dash"
const BOB_SPEED := 3.0
const BOB_HEIGHT := 2.0

var _time := 0.0

@onready var _visual: Node2D = $Visual
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound


func _process(delta: float) -> void:
	_time += delta
	_visual.position.y = -10.0 + sin(_time * BOB_SPEED) * BOB_HEIGHT


func _on_player_entered(player: Player) -> void:
	if not _visual.visible or player.dash_unlocked:
		return
	player.dash_unlocked = true
	_visual.hide()
	_pickup_sound.play()
	collected.emit(MESSAGE)
