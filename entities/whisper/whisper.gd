class_name Whisper
extends RoomEntity
## Sussurro: uma sombra que patrulha entre onde foi colocada e `travel`. Encostar nela
## apaga uma estrela. Um dash com a voz a desfaz (e gasta a voz). Volta no reset da fase.

const ANIMATION_FPS := 8.0
const BOB_SPEED := 5.0
const BOB_HEIGHT := 1.5
const SPRITE_REST_Y := -8.0

@export var travel := Vector2(48, 0)
@export var speed := 28.0
## Em que ponto do vai-e-volta ela começa (0 = na origem, 0.5 = no fim de `travel`).
## Vários sussurros com fases diferentes formam uma onda.
@export_range(0.0, 1.0) var phase := 0.0
@export var shatter_effect: PackedScene

var _origin := Vector2.ZERO
var _time := 0.0
var _is_alive := true
var _player_inside: Player

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _dissolve_sound: AudioStreamPlayer = $DissolveSound


func _ready() -> void:
	super()
	_origin = position


func reset() -> void:
	_time = 0.0
	position = _origin
	reset_physics_interpolation()
	_set_alive(true)


func is_alive() -> bool:
	return _is_alive


func _physics_process(delta: float) -> void:
	if not _is_alive:
		return
	_time += delta
	var lap := _time * speed / maxf(travel.length(), 1.0) + phase * 2.0
	position = _origin + travel * pingpong(lap, 1.0)
	_sprite.flip_h = int(lap) % 2 == 1
	_sprite.frame = int(_time * ANIMATION_FPS) % _sprite.hframes
	_sprite.position.y = SPRITE_REST_Y + sin(_time * BOB_SPEED) * BOB_HEIGHT
	if _player_inside == null:
		return
	if _player_inside.is_dashing() and _player_inside.has_voice:
		_player_inside.spend_voice()
		_dissolve()
	else:
		_player_inside.die()


func _dissolve() -> void:
	_set_alive(false)
	_dissolve_sound.play()
	var effect := shatter_effect.instantiate() as Node2D
	add_sibling(effect)
	effect.global_position = _sprite.global_position
	effect.reset_physics_interpolation()


func _set_alive(alive: bool) -> void:
	_is_alive = alive
	_sprite.visible = alive
	_light.enabled = alive


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null
