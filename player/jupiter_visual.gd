class_name JupiterVisual
extends Node2D
## Visual do Jupiter: escolhe a animação pela pose, vira para o lado certo,
## deforma no pulo e no pouso e acende/apaga o broche (dash disponível).

enum Pose { IDLE, RUN, JUMP, APEX, FALL, WALL_SLIDE, DASH }

const ANIMATIONS := {
	Pose.IDLE: &"idle",
	Pose.RUN: &"run",
	Pose.JUMP: &"jump",
	Pose.APEX: &"apex",
	Pose.FALL: &"fall",
	Pose.WALL_SLIDE: &"wall_slide",
	Pose.DASH: &"dash",
}
const LAND_ANIMATION := &"land"
const LAND_TIME := 0.08 ## Quanto tempo o Jupiter fica agachado ao pousar.
const SQUASH_RECOVERY := 14.0
const MIN_RUN_ANIMATION_SPEED := 0.5
const PIN_READY := Color("ffe680")
const PIN_SPENT := Color("5a5a70")

var facing := 1
var dash_ready := true:
	set(value):
		if value != dash_ready:
			dash_ready = value
			_update_pin()

var _squash := Vector2.ONE
var _land_time_left := 0.0

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_update_pin()


## Toca a animação da pose. Na corrida, `speed_ratio` (velocidade / velocidade máxima)
## acelera ou desacelera as passadas. Logo após um pouso, mantém o quadro agachado
## (a não ser que o Jupiter já esteja no ar de novo).
func set_pose(pose: Pose, speed_ratio := 1.0) -> void:
	var on_ground := pose == Pose.IDLE or pose == Pose.RUN
	var animation: StringName = LAND_ANIMATION if _land_time_left > 0.0 and on_ground else ANIMATIONS[pose]
	if _sprite.animation != animation:
		_sprite.play(animation)
	_sprite.speed_scale = maxf(speed_ratio, MIN_RUN_ANIMATION_SPEED) if pose == Pose.RUN else 1.0


func land() -> void:
	_land_time_left = LAND_TIME


## Deforma por um instante (pulo, pouso etc.). Volta ao normal sozinho.
func squash(amount: Vector2) -> void:
	_squash = amount


## Quadro atual da animação (usado pelo rastro do dash para copiar a pose).
func current_frame() -> Texture2D:
	return _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame)


func _process(delta: float) -> void:
	_land_time_left -= delta
	_squash = _squash.lerp(Vector2.ONE, 1.0 - exp(-SQUASH_RECOVERY * delta))
	scale = Vector2(_squash.x * facing, _squash.y)


func _update_pin() -> void:
	if is_node_ready():
		(_sprite.material as ShaderMaterial).set_shader_parameter(&"pin_color", PIN_READY if dash_ready else PIN_SPENT)
