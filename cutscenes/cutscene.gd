class_name Cutscene
extends Node2D
## Base das cutscenes: um roteiro escrito em _run() com falas, esperas e movimentos.
## A cena monta o palco (fundo, personagens, câmera, DialogueBox e Caption); o script
## da cutscene só escreve o roteiro. Quando ele acaba, a campanha segue (Story.advance()).
## Esc pula a cena inteira.

signal finished

const WALK_POSES: Array[String] = ["walk_a", "walk_b"]
const STEP_TIME := 0.2

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


## Leva a câmera até `to` (centro da tela) com `zoom`. Zoom 2 = plano fechado, com os
## pixels do palco do mesmo tamanho dos da jogabilidade.
func move_camera(camera: Camera2D, to: Vector2, zoom: float, duration: float) -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "global_position", to, duration)
	tween.tween_property(camera, "zoom", Vector2.ONE * zoom, duration)
	await tween.finished


## Faz o ator andar até `to` alternando as poses de passo; no fim, fica em `end_pose`.
func walk(actor: Actor, to: Vector2, duration: float, end_pose := "stand") -> void:
	actor.flip_h = to.x < actor.global_position.x
	var tween := create_tween()
	tween.tween_property(actor, "global_position", to, duration)
	var time := 0.0
	while tween.is_running():
		actor.pose = WALK_POSES[int(time / STEP_TIME) % WALK_POSES.size()]
		time += get_process_delta_time()
		await get_tree().process_frame
	actor.pose = end_pose


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
