class_name Cutscene
extends Node2D
## Base das cutscenes: um roteiro escrito em _run() com falas, esperas e movimentos.
## A cena monta os planos (filhos de Shots: arte, bustos, efeitos), a DialogueBox e a
## Caption; o script da cutscene só escreve o roteiro e corta de um plano para o outro. Quando ele acaba, a campanha segue (Story.advance()).
## Esc pula a cena inteira.

signal finished

const PAN_DISTANCE := 32.0 ## Sobra de largura dos planos abertos (352 px numa tela de 320).
## Camadas que deslizam em outra velocidade no pan: na frente (mais rápido) e ao fundo.
const LAYER_DEPTH := {&"Fg": 1.9, &"Clouds": 0.45}

@export var music: AudioStream
## Desligue para a cena não trocar sozinha ao terminar (testes, cenas embutidas).
@export var advances_story := true

## Quem fala -> quem mexe a boca: { Speaker: Actor }. Preencha no _ready da cutscene.
var cast := {}

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

## Fala na caixa de diálogo. Se o Speaker estiver no `cast`, o ator mexe a boca enquanto
## o texto aparece.
func say(speaker: Speaker, text: String) -> void:
	var actor := cast.get(speaker) as Actor
	if actor != null:
		actor.talking = true
		dialogue.typing_finished.connect(func() -> void: actor.talking = false, CONNECT_ONE_SHOT)
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


## Corta para o plano `shot`: mostra só ele entre os irmãos (os filhos de Shots).
## Com `fade` > 0, o corte passa pelo preto.
func cut_to(shot: Node2D, fade := 0.0) -> void:
	if fade > 0.0:
		await Transition.fade_out(fade)
	for sibling in shot.get_parent().get_children():
		if sibling is Node2D:
			(sibling as Node2D).visible = sibling == shot
	if fade > 0.0:
		await Transition.fade_in(fade)


## Desliza o plano devagar para o lado (a arte dos planos abertos é mais larga que a tela).
## Os filhos chamados Fg e Clouds deslizam em outra velocidade, o que dá profundidade.
## Não espera terminar.
func pan(shot: Node2D, distance: float, duration: float) -> void:
	shot.position.x = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(shot, "position:x", -distance, duration)
	for child in shot.get_children():
		if LAYER_DEPTH.has(child.name):
			var layer := child as Node2D
			var extra: float = distance * (LAYER_DEPTH[child.name] - 1.0)
			tween.tween_property(layer, "position:x", layer.position.x - extra, duration)


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
