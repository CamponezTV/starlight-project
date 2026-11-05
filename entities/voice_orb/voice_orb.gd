class_name VoiceOrb
extends RoomEntity
## Orbe de voz: a voz que o Jupiter nunca usou. Com ela, um dash quebra barreiras de
## palavras e atinge a Sophie. Some ao ser pego e volta quando o RespawnTimer acaba
## (com `respawns` desligado, só volta no reset da fase).

signal collected

@export var respawns := true

var _player_inside: Player

@onready var _visual: Node2D = $Visual
@onready var _respawn_timer: Timer = $RespawnTimer
@onready var _collect_sound: AudioStreamPlayer = $CollectSound


func _ready() -> void:
	super()
	_respawn_timer.timeout.connect(_set_available.bind(true))


func reset() -> void:
	_respawn_timer.stop()
	_set_available(true)


func is_available() -> bool:
	return _visual.visible


func _physics_process(_delta: float) -> void:
	if is_available() and _player_inside != null and _player_inside.gain_voice():
		_collect_sound.play()
		_set_available(false)
		if respawns:
			_respawn_timer.start()
		collected.emit()


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null


func _set_available(available: bool) -> void:
	_visual.visible = available
