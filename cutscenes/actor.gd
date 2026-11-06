@tool
class_name Actor
extends Sprite2D
## Personagem de cutscene. A folha (characters/hd/*.png) tem 3 quadros por pose, na ordem
## de `poses`: normal, piscando e boca aberta. O ator pisca sozinho de tempos em tempos
## e mexe a boca enquanto `talking` estiver ligado (a Cutscene liga durante as falas).

const VARIANTS := 3
const VARIANT_BLINK := 1
const VARIANT_TALK := 2
const BLINK_TIME := 0.12
const BLINK_INTERVAL := Vector2(2.0, 5.0)
const TALK_FRAME_TIME := 0.11

## Nomes das poses, na ordem da folha.
@export var poses: PackedStringArray = []:
	set(value):
		poses = value
		_refresh()
@export var pose := "":
	set(value):
		pose = value
		_refresh()

var talking := false

var _blink_left := 0.0
var _next_blink := 0.0
var _talk_time := 0.0


func _ready() -> void:
	_next_blink = randf_range(BLINK_INTERVAL.x, BLINK_INTERVAL.y)
	_refresh()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink_left = BLINK_TIME
		_next_blink = randf_range(BLINK_INTERVAL.x, BLINK_INTERVAL.y)
	_blink_left -= delta
	_talk_time = _talk_time + delta if talking else 0.0
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
