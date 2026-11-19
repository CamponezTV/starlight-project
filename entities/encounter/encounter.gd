class_name Encounter
extends RoomEntity
## Alguém com quem o Jupiter pode conversar. Com ele parado na área, "cima" pede a
## conversa: a cutscene `scene` toca por cima da fase (quem toca é o Main) e, quando
## acaba, o Main chama conclude(). Subclasses decidem se ainda há conversa
## (is_available) e o que muda depois dela (_on_concluded).

signal requested(encounter: Encounter)
signal gifted ## A conversa rendeu uma estrela.

const PROMPT_FADE := 0.25

@export var scene: PackedScene ## A Cutscene da conversa.

var _visitor: Player
var _prompt_tween: Tween

@onready var _prompt: Label = $Prompt


func _ready() -> void:
	super()
	_prompt.modulate.a = 0.0


## Esta conversa rende (ou já rendeu) uma estrela? (Ela entra na contagem da fase.)
func offers_star() -> bool:
	return false


## A estrela já foi dada numa visita passada (a decisão fica salva e a conversa não se
## repete): a fase começa com ela guardada.
func has_given_star() -> bool:
	return false


## Ainda há o que conversar?
func is_available() -> bool:
	return true


## A conversa acabou (ou foi pulada).
func conclude() -> void:
	_on_concluded()
	_refresh_prompt()


func _on_concluded() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_up") and _can_talk():
		get_viewport().set_input_as_handled()
		requested.emit(self)


func _can_talk() -> bool:
	return _visitor != null and is_available() and _visitor.controllable and _visitor.is_on_floor()


func _on_player_entered(player: Player) -> void:
	_visitor = player
	_refresh_prompt()


func _on_player_exited(_player: Player) -> void:
	_visitor = null
	_refresh_prompt()


func _refresh_prompt() -> void:
	if _prompt_tween != null:
		_prompt_tween.kill()
	var alpha := 1.0 if _visitor != null and is_available() else 0.0
	_prompt_tween = create_tween()
	_prompt_tween.tween_property(_prompt, "modulate:a", alpha, PROMPT_FADE)
