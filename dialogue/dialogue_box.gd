class_name DialogueBox
extends CanvasLayer
## Caixa de diálogo com texto letra por letra e um "blip" no tom de quem fala.
## Pular (ou Enter) mostra a fala inteira; com a fala completa, passa para a próxima.
## Uso: `await dialogue_box.say(speaker, "Olá")`. Sem speaker, é narração (sem nome).

signal line_finished

const CHARACTERS_PER_SECOND := 40.0
const PAUSE_AFTER := {".": 0.25, "!": 0.25, "?": 0.25, ",": 0.1, "…": 0.3}
const BLIP_EVERY := 2 ## Letras entre um blip e outro.
const PITCH_VARIATION := 0.05
const NARRATION_COLOR := Color(0.75, 0.72, 0.9)
const FADE_TIME := 0.15
const ADVANCE_ACTIONS: Array[StringName] = [&"jump", &"ui_accept"]
const SCREEN_MARGIN := 6.0

## No alto da tela, para não cobrir personagens que estão embaixo.
@export var at_top := false

var _is_typing := false
var _is_waiting := false
var _letters_since_blip := 0
var _pause_left := 0.0
var _progress := 0.0
var _voice_pitch := 1.0
var _fade_tween: Tween

@onready var _panel: Control = $Panel
@onready var _name: Label = %Name
@onready var _text: Label = %Text
@onready var _next_marker: Control = %NextMarker
@onready var _blip: AudioStreamPlayer = $Blip


func _ready() -> void:
	if at_top:
		var height := _panel.size.y
		_panel.anchor_top = 0.0
		_panel.anchor_bottom = 0.0
		_panel.offset_top = SCREEN_MARGIN
		_panel.offset_bottom = SCREEN_MARGIN + height
	_panel.modulate.a = 0.0
	_panel.hide()
	set_process(false)


## Mostra uma fala e espera o jogador passar para a próxima.
func say(speaker: Speaker, text: String) -> void:
	_show_line(speaker, text)
	await line_finished


## Some com a caixa (no fim de uma conversa).
func close() -> void:
	if not _panel.visible:
		return
	_fade_panel(0.0)
	_fade_tween.tween_callback(_panel.hide)


func is_open() -> bool:
	return _panel.visible


func _show_line(speaker: Speaker, text: String) -> void:
	_name.text = speaker.display_name if speaker != null else ""
	_name.modulate = speaker.name_color if speaker != null else Color.WHITE
	_text.modulate = Color.WHITE if speaker != null else NARRATION_COLOR
	_voice_pitch = speaker.voice_pitch if speaker != null else 0.0
	_text.text = text
	_text.visible_characters = 0
	_progress = 0.0
	_pause_left = 0.0
	_letters_since_blip = BLIP_EVERY - 1
	_is_typing = true
	_is_waiting = false
	_next_marker.hide()
	_panel.show()
	_fade_panel(1.0)
	set_process(true)


func _fade_panel(alpha: float) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_panel, "modulate:a", alpha, FADE_TIME)


func _process(delta: float) -> void:
	if not _is_typing:
		return
	if _pause_left > 0.0:
		_pause_left -= delta
		return
	_progress += delta * CHARACTERS_PER_SECOND
	while _is_typing and _progress >= 1.0 and _pause_left <= 0.0:
		_progress -= 1.0
		_reveal_next_letter()


func _reveal_next_letter() -> void:
	_text.visible_characters += 1
	var letter := _text.text[_text.visible_characters - 1]
	if letter != " ":
		_letters_since_blip += 1
		if _letters_since_blip >= BLIP_EVERY and _voice_pitch > 0.0:
			_letters_since_blip = 0
			_blip.pitch_scale = _voice_pitch * randf_range(1.0 - PITCH_VARIATION, 1.0 + PITCH_VARIATION)
			_blip.play()
	_pause_left = PAUSE_AFTER.get(letter, 0.0)
	if _text.visible_characters >= _text.text.length():
		_finish_typing()


func _finish_typing() -> void:
	_text.visible_characters = -1
	_is_typing = false
	_is_waiting = true
	_next_marker.show()
	set_process(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible or not _is_advance(event):
		return
	get_viewport().set_input_as_handled()
	if _is_typing:
		_finish_typing()
	elif _is_waiting:
		_is_waiting = false
		_next_marker.hide()
		line_finished.emit()


func _is_advance(event: InputEvent) -> bool:
	for action in ADVANCE_ACTIONS:
		if event.is_action_pressed(action, false):
			return true
	return false
