@tool
class_name Actor
extends Sprite2D
## Personagem de cutscene (busto). A folha tem 3 quadros por expressão, na ordem de
## `poses`: normal, piscando e falando. O ator pisca sozinho, respira, e mexe a boca
## enquanto `talking` estiver ligado (a Cutscene liga durante as falas).
## `tint` e `rim` dão a luz do ambiente: a cor que banha o busto e a luz de contorno.

const SHADER := preload("res://cutscenes/actor_light.gdshader")
const VARIANTS := 3
const VARIANT_BLINK := 1
const VARIANT_TALK := 2
const BLINK_TIME := 0.12
const BLINK_INTERVAL := Vector2(2.0, 5.0)
const TALK_FRAME_TIME := 0.11
const BREATH_SPEED := 1.4

## Nomes das expressões, na ordem da folha.
@export var poses: PackedStringArray = []:
	set(value):
		poses = value
		_refresh()
@export var pose := "":
	set(value):
		pose = value
		_refresh()
@export var tint := Color.WHITE:
	set(value):
		tint = value
		_apply_light()
@export var rim := Color(1, 1, 1, 0):
	set(value):
		rim = value
		_apply_light()

var talking := false

var _blink_left := 0.0
var _next_blink := 0.0
var _talk_time := 0.0
var _time := 0.0
var _rest_offset := Vector2.ZERO


func _ready() -> void:
	_next_blink = randf_range(BLINK_INTERVAL.x, BLINK_INTERVAL.y)
	_time = randf() * TAU
	_rest_offset = offset
	material = ShaderMaterial.new()
	(material as ShaderMaterial).shader = SHADER
	_apply_light()
	_refresh()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_time += delta
	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink_left = BLINK_TIME
		_next_blink = randf_range(BLINK_INTERVAL.x, BLINK_INTERVAL.y)
	_blink_left -= delta
	_talk_time = _talk_time + delta if talking else 0.0
	# Respiração: o busto sobe um pixel de tempos em tempos.
	offset.y = _rest_offset.y - (1.0 if sin(_time * BREATH_SPEED) > 0.3 else 0.0)
	_refresh()


func _refresh() -> void:
	var index := poses.find(pose)
	if index < 0 or texture == null:
		return
	hframes = poses.size() * VARIANTS
	var variant := 0
	if talking and int(_talk_time / TALK_FRAME_TIME) % 2 == 1:
		variant = VARIANT_TALK
	elif _blink_left > 0.0:
		variant = VARIANT_BLINK
	frame = index * VARIANTS + variant


func _apply_light() -> void:
	var shader_material := material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter(&"tint", tint)
		shader_material.set_shader_parameter(&"rim", rim)
