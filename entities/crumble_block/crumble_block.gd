class_name CrumbleBlock
extends RoomEntity
## Rocha frágil (um bloco): racha quando o Jupiter pisa, cai pouco depois e volta
## sozinha, desde que ninguém esteja no lugar dela.
## A área de toque cobre o bloco e uma faixa fina em cima dele (onde ficam os pés).

enum State { SOLID, CRACKING, GONE }

const CRACK_FRAMES := 3
const SHAKE_PIXELS := 1.0

@export var crack_time := 0.45 ## Do primeiro passo até cair.
@export var return_time := 2.2 ## Caída, quanto tempo até voltar.
@export var debris_effect: PackedScene

var _state := State.SOLID
var _time_left := 0.0
var _player_inside: Player

@onready var _rock_collision: CollisionShape2D = $Rock/Collision
@onready var _sprite: Sprite2D = $Sprite
@onready var _crack_sound: AudioStreamPlayer = $CrackSound
@onready var _restore_sound: AudioStreamPlayer = $RestoreSound


func reset() -> void:
	_set_state(State.SOLID)


func is_solid() -> bool:
	return _state != State.GONE


func _physics_process(delta: float) -> void:
	match _state:
		State.CRACKING:
			_time_left -= delta
			var progress := 1.0 - _time_left / crack_time
			_sprite.frame = mini(int(progress * CRACK_FRAMES), CRACK_FRAMES - 1)
			_sprite.position.x = SHAKE_PIXELS * (1 if Engine.get_physics_frames() % 4 < 2 else -1)
			if _time_left <= 0.0:
				_fall()
		State.GONE:
			_time_left -= delta
			if _time_left <= 0.0 and _player_inside == null:
				_set_state(State.SOLID)
				_restore_sound.play()


func _on_player_entered(player: Player) -> void:
	_player_inside = player
	if _state == State.SOLID:
		_set_state(State.CRACKING)
		_crack_sound.play()


func _on_player_exited(_player: Player) -> void:
	_player_inside = null


func _fall() -> void:
	_set_state(State.GONE)
	var debris := debris_effect.instantiate() as Node2D
	add_sibling(debris)
	debris.global_position = _sprite.global_position
	debris.reset_physics_interpolation()


func _set_state(state: State) -> void:
	_state = state
	_time_left = crack_time if state == State.CRACKING else return_time
	_rock_collision.set_deferred(&"disabled", state == State.GONE)
	_sprite.visible = state != State.GONE
	_sprite.position.x = 0.0
	if state == State.SOLID:
		_sprite.frame = 0
