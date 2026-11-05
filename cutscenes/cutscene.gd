class_name Cutscene
extends Node2D
## Base das cutscenes: um roteiro escrito em _run() com falas, esperas e movimentos.
## A cena monta o palco (fundo, personagens, câmera, DialogueBox e Caption); o script
## da cutscene só escreve o roteiro. Quando ele acaba, a campanha segue (Story.advance()).
## Esc pula a cena inteira.

signal finished

@export var music: AudioStream
## Desligue para a cena não trocar sozinha ao terminar (testes, cenas embutidas).
@export var advances_story := true

var _is_finished := false

@onready var dialogue: DialogueBox = $DialogueBox
@onready var caption: Caption = $Caption


func _ready() -> void:
	Music.play(music)
	_play.call_deferred()


func is_finished() -> bool:
	return _is_finished


## O roteiro. Cada subclasse escreve o seu.
func _run() -> void:
	pass


# --- Passos do roteiro (use com await) ---------------------------------------------

func say(speaker: Speaker, text: String) -> void:
	await dialogue.say(speaker, text)


## Fecha a caixa de diálogo entre uma conversa e outra.
func end_conversation() -> void:
	dialogue.close()


## Espera `seconds`. O Timer é filho da cena: se ela sair antes, o roteiro para junto.
func wait(seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()


## Texto grande no meio da tela ("6 anos depois...").
func show_caption(text: String, duration: float) -> void:
	caption.show_text(text, duration)
	await wait(duration)


## Leva `node` até `to` (posição global) em `duration` segundos.
func move(node: Node2D, to: Vector2, duration: float, ease_type := Tween.EASE_IN_OUT) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(ease_type)
	tween.tween_property(node, "global_position", to, duration)
	await tween.finished


## Espera o Jupiter entrar na área (ou segue direto, se ele já estiver dentro).
func wait_for_player(area: Area2D) -> void:
	for body in area.get_overlapping_bodies():
		if body is Player:
			return
	while not (await area.body_entered) is Player:
		pass


# --- Fim ------------------------------------------------------------------------------

func _play() -> void:
	await _run()
	_finish()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"quit"):
		get_viewport().set_input_as_handled()
		_finish()


func _finish() -> void:
	if _is_finished:
		return
	_is_finished = true
	dialogue.close()
	finished.emit()
	if advances_story:
		Story.advance()
