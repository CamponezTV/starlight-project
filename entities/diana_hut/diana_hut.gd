class_name DianaHut
extends Encounter
## A cabana onde a Diana fuma escondida (Fase 3). A conversa acontece uma vez, e o que o
## jogador decide (guardado na Story) muda a cabana: perdoada, ela continua ali e entrega
## o isqueiro (uma estrela); sem perdão, a cabana fica vazia e a lanterna apagada.

const FRAME_SITTING := 0
const FRAME_DRAG := 1
const FRAME_EMPTY := 2
const DRAG_EVERY := 4.2 ## Segundos entre uma tragada e outra.
const DRAG_TIME := 0.9
const FLICKER_SPEED := 7.0
const FLICKER_AMOUNT := 0.08
const LANTERN_ENERGY := 0.6

var _outcome := "" ## O que o jogador decidiu ("" = ainda não conversaram).
var _time := 0.0

@onready var _sprite: Sprite2D = $Sprite
@onready var _lantern: PointLight2D = $Lantern
@onready var _smoke: CPUParticles2D = $Smoke
@onready var _ember: Sprite2D = $Ember


func _ready() -> void:
	super()
	_outcome = Story.recall(DianaTalk.CHOICE_KEY)
	_apply_outcome()


func offers_star() -> bool:
	return true


func is_available() -> bool:
	return _outcome.is_empty()


func _process(delta: float) -> void:
	_time += delta
	var is_dragging := fmod(_time, DRAG_EVERY) > DRAG_EVERY - DRAG_TIME
	_sprite.frame = FRAME_DRAG if is_dragging else FRAME_SITTING
	_ember.visible = is_dragging
	_lantern.energy = LANTERN_ENERGY + sin(_time * FLICKER_SPEED) * FLICKER_AMOUNT


func _on_concluded() -> void:
	_outcome = Story.recall(DianaTalk.CHOICE_KEY)
	_apply_outcome()
	if _outcome == DianaTalk.FORGIVEN:
		gifted.emit()


func _apply_outcome() -> void:
	var is_gone := _outcome == DianaTalk.RESENTFUL
	_lantern.enabled = not is_gone
	_smoke.emitting = not is_gone
	set_process(not is_gone)
	if is_gone:
		_sprite.frame = FRAME_EMPTY
		_ember.hide()
