class_name StarPickup
extends RoomEntity
## Estrela perdida: um desafio opcional da sala. Tocada, passa a seguir o Jupiter, mas só
## fica guardada quando ele pisa em chão firme por um instante. Se ele morrer antes, ela
## volta para o lugar. Cada visita à fase começa com todas as estrelas no lugar.

signal secured(star: StarPickup)

enum State { WAITING, FOLLOWING, SECURED }

const FOLLOW_OFFSET := Vector2(11, -20) ## Para o Jupiter olhando para a direita (atrás dele).
const FOLLOW_SHARPNESS := 7.0
const SAFE_GROUND_TIME := 0.2 ## Segundos seguidos no chão para a estrela ficar guardada.

var _state := State.WAITING
var _carrier: Player
var _ground_time := 0.0
var _home := Vector2.ZERO

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _animation: AnimationPlayer = $AnimationPlayer
@onready var _touch_sound: AudioStreamPlayer = $TouchSound
@onready var _secured_sound: AudioStreamPlayer = $SecuredSound
@onready var _burst: CPUParticles2D = $Burst


func _ready() -> void:
	super()
	_home = position
	# Cada estrela balança num tempo diferente.
	_animation.seek(fmod(global_position.x, _animation.current_animation_length))
	_refresh_look()


## O Jupiter morreu: uma estrela que ainda o seguia volta para o lugar.
func reset() -> void:
	if _state == State.FOLLOWING:
		_carrier = null
		_state = State.WAITING
		position = _home
		reset_physics_interpolation()


func is_following() -> bool:
	return _state == State.FOLLOWING


func is_secured() -> bool:
	return _state == State.SECURED


func _physics_process(delta: float) -> void:
	if _state != State.FOLLOWING or _carrier.is_dead():
		return
	var target := _carrier.global_position + Vector2(-FOLLOW_OFFSET.x * _carrier.facing, FOLLOW_OFFSET.y)
	global_position = global_position.lerp(target, 1.0 - exp(-FOLLOW_SHARPNESS * delta))
	_ground_time = _ground_time + delta if _carrier.is_on_floor() else 0.0
	if _ground_time >= SAFE_GROUND_TIME:
		_secure()


func _on_player_entered(player: Player) -> void:
	if _state != State.WAITING or player.is_dead():
		return
	_state = State.FOLLOWING
	_carrier = player
	_ground_time = 0.0
	_touch_sound.play()


func _secure() -> void:
	_state = State.SECURED
	_carrier = null
	_secured_sound.play()
	_burst.restart()
	_refresh_look()
	secured.emit(self)


func _refresh_look() -> void:
	_sprite.visible = _state != State.SECURED
	_light.enabled = _state != State.SECURED
