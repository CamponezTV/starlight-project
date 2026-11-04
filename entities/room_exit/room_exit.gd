class_name RoomExit
extends RoomEntity
## Saída da sala: um feixe de luz vindo de cima. Avisa uma vez só.

signal reached

var _is_open := true

@onready var _reached_sound: AudioStreamPlayer = $ReachedSound


func reset() -> void:
	_is_open = true


func _on_player_entered(_player: Player) -> void:
	if _is_open:
		_is_open = false
		_reached_sound.play()
		reached.emit()
