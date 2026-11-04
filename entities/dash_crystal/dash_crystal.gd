class_name DashCrystal
extends RoomEntity
## Cristal: recarrega o dash no ar. Some ao ser usado e volta quando o RespawnTimer acaba.
## Só é gasto se o Jupiter realmente precisava do dash.

enum Frame { AVAILABLE, USED }

var _player_inside: Player

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _respawn_timer: Timer = $RespawnTimer
@onready var _refill_sound: AudioStreamPlayer = $RefillSound


func _ready() -> void:
	super()
	_respawn_timer.timeout.connect(_refresh)


func reset() -> void:
	_respawn_timer.stop()
	_refresh()


func _physics_process(_delta: float) -> void:
	if _is_available() and _player_inside != null and _player_inside.refill_dash():
		_respawn_timer.start()
		_refill_sound.play()
		_refresh()


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null


func _is_available() -> bool:
	return _respawn_timer.is_stopped()


func _refresh() -> void:
	_sprite.frame = Frame.AVAILABLE if _is_available() else Frame.USED
	_light.enabled = _is_available()
