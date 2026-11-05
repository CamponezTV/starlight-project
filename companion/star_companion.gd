class_name StarCompanion
extends Node2D
## A estrela-guia (o avô). Segue Jupiter e é a única luz da caverna.
## O tamanho e o brilho refletem a vida (autoload Stars).

const FOLLOW_OFFSET := Vector2(-12, -22) ## Para Jupiter olhando para a direita.
const FOLLOW_SHARPNESS := 5.0
const BOB_SPEED := 2.5
const BOB_HEIGHT := 2.0
const TWINKLE_FPS := 6.0 ## Quadros por segundo da cintilação dos raios.

const MIN_ENERGY := 0.35
const ENERGY_RANGE := 0.9
const MIN_LIGHT_SCALE := 0.9
const LIGHT_SCALE_RANGE := 1.7
const ENERGY_SHARPNESS := 8.0
const SCALE_SHARPNESS := 4.0

const PULSE_DECAY := 2.0
const PULSE_ENERGY := 0.6
const PULSE_SCALE := 0.5
const DEFAULT_FLICKER_TIME := 0.8

const SPRITE_STAR_RADIUS := 4.5 ## Raio de referência da estrela desenhada no PNG.
const MIN_RADIUS := 3.0
const RADIUS_RANGE := 1.5

var _target: Player
var _time := 0.0
var _flicker_left := 0.0
var _pulse := 0.0

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light


## Começa a seguir o Jupiter, já posicionada ao lado dele.
func follow(player: Player) -> void:
	_target = player
	global_position = _follow_point()
	reset_physics_interpolation()


## Pisca, como quem se assusta (quando Jupiter morre).
func flicker(duration := DEFAULT_FLICKER_TIME) -> void:
	_flicker_left = duration


## Brilha mais forte por um instante (quando ganha uma estrela).
func pulse() -> void:
	_pulse = 1.0


func _physics_process(delta: float) -> void:
	if _target != null and not _target.is_dead():
		global_position = global_position.lerp(_follow_point(), 1.0 - exp(-FOLLOW_SHARPNESS * delta))


func _process(delta: float) -> void:
	_time += delta
	_flicker_left = maxf(_flicker_left - delta, 0.0)
	_pulse = maxf(_pulse - delta * PULSE_DECAY, 0.0)
	_update_light(delta)
	_update_sprite()


func _follow_point() -> Vector2:
	var bob := sin(_time * BOB_SPEED) * BOB_HEIGHT
	return _target.global_position + Vector2(FOLLOW_OFFSET.x * _target.facing, FOLLOW_OFFSET.y + bob)


func _update_light(delta: float) -> void:
	var life := Stars.ratio()
	var energy := MIN_ENERGY + life * ENERGY_RANGE + _pulse * PULSE_ENERGY
	var light_scale := MIN_LIGHT_SCALE + life * LIGHT_SCALE_RANGE + _pulse * PULSE_SCALE
	if _flicker_left > 0.0:
		energy *= randf_range(0.2, 1.0)
	_light.energy = lerpf(_light.energy, energy, 1.0 - exp(-ENERGY_SHARPNESS * delta))
	_light.texture_scale = lerpf(_light.texture_scale, light_scale, 1.0 - exp(-SCALE_SHARPNESS * delta))


func _update_sprite() -> void:
	var radius := MIN_RADIUS + Stars.ratio() * RADIUS_RANGE + _pulse
	_sprite.scale = Vector2.ONE * radius / SPRITE_STAR_RADIUS
	_sprite.frame = int(_time * TWINKLE_FPS) % _sprite.hframes
