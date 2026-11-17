class_name SkillShowcase
extends CanvasLayer
## Holofote de habilidade nova: a tela escurece em volta do Jupiter, raios de luz giram
## atrás dele e o nome da habilidade aparece com a explicação e os botões. Quem chama
## pausa o jogo e espera present() terminar; o jogador confirma para seguir.

signal _confirmed

const FLASH_ALPHA := 0.75
const FADE_IN := 0.45
const FADE_OUT := 0.3
const LINE_FADE := 0.3
const LINE_GAP := 0.25 ## Pausa entre uma linha e a próxima.
const TITLE_DROP := 6.0 ## O título desce estes pixels enquanto aparece.
const READ_TIME := 0.6 ## Depois da última linha, antes de aceitar o botão.
const PROMPT_BLINK := 0.6
const TEXT_TOP_Y := 12.0
const TEXT_BOTTOM_Y := 86.0
const SCREEN_MIDDLE_Y := 90.0
const CONFIRM_ACTIONS: Array[StringName] = [&"jump", &"dash", &"ui_accept"]

var _is_waiting := false
var _prompt_tween: Tween

@onready var _spotlight: ColorRect = $Spotlight
@onready var _flash: ColorRect = $Flash
@onready var _text: Control = $Text
@onready var _kicker: Label = $Text/Kicker
@onready var _title: Label = $Text/Title
@onready var _description: Label = $Text/Description
@onready var _controls: Label = $Text/Controls
@onready var _prompt: Label = $Prompt
@onready var _sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	hide()


func is_open() -> bool:
	return visible


## Apresenta `skill` com o holofote em `focus` (posição na tela). Com `await`, espera o
## jogador confirmar.
func present(skill: Skill, focus: Vector2) -> void:
	_title.text = skill.title
	_description.text = skill.description
	_controls.text = skill.controls
	# O texto fica na metade da tela em que o Jupiter não está.
	_text.position.y = TEXT_TOP_Y if focus.y > SCREEN_MIDDLE_Y else TEXT_BOTTOM_Y
	_set_focus(focus)
	for label: Label in [_kicker, _title, _description, _controls, _prompt]:
		label.modulate.a = 0.0
	show()
	_sound.play()
	await _reveal().finished
	_is_waiting = true
	_blink_prompt()
	await _confirmed
	_is_waiting = false
	_prompt_tween.kill()
	await _dismiss().finished
	hide()


func _input(event: InputEvent) -> void:
	if not _is_waiting:
		return
	for action in CONFIRM_ACTIONS:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			_confirmed.emit()
			return


func _reveal() -> Tween:
	_flash.modulate.a = FLASH_ALPHA
	var tween := create_tween()
	tween.tween_property(_flash, "modulate:a", 0.0, FADE_IN)
	tween.parallel().tween_method(_set_amount, 0.0, 1.0, FADE_IN)
	tween.tween_property(_kicker, "modulate:a", 1.0, LINE_FADE)
	var title_y := _title.position.y
	_title.position.y = title_y - TITLE_DROP
	tween.tween_property(_title, "modulate:a", 1.0, LINE_FADE)
	tween.parallel().tween_property(_title, "position:y", title_y, LINE_FADE).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for label: Label in [_description, _controls]:
		tween.tween_interval(LINE_GAP)
		tween.tween_property(label, "modulate:a", 1.0, LINE_FADE)
	tween.tween_interval(READ_TIME)
	return tween


func _dismiss() -> Tween:
	var tween := create_tween().set_parallel()
	tween.tween_method(_set_amount, 1.0, 0.0, FADE_OUT)
	for label: Label in [_kicker, _title, _description, _controls, _prompt]:
		tween.tween_property(label, "modulate:a", 0.0, FADE_OUT)
	return tween


func _blink_prompt() -> void:
	_prompt_tween = create_tween().set_loops()
	_prompt_tween.tween_property(_prompt, "modulate:a", 1.0, PROMPT_BLINK)
	_prompt_tween.tween_property(_prompt, "modulate:a", 0.3, PROMPT_BLINK)


func _set_focus(focus: Vector2) -> void:
	(_spotlight.material as ShaderMaterial).set_shader_parameter(&"center", focus)


func _set_amount(amount: float) -> void:
	(_spotlight.material as ShaderMaterial).set_shader_parameter(&"amount", amount)
