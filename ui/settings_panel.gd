class_name SettingsPanel
extends VBoxContainer
## Configurações: idioma, volumes, texto automático e tela (o tamanho da janela ou tela cheia). Aparece no menu
## principal e na pausa. Mexe direto no autoload Settings (que aplica e salva na hora);
## `closed` avisa quando o jogador volta (Voltar ou Esc).

signal closed

const ON_TEXT := "Ligado"
const OFF_TEXT := "Desligado"
const FULLSCREEN_TEXT := "Tela cheia"

var _volume_rows := {} ## OptionRow -> bus.

@onready var _language: OptionRow = %Language
@onready var _auto_text: OptionRow = %AutoText
@onready var _display: OptionRow = %Display
@onready var _back: Button = %Back
@onready var _step_sound: AudioStreamPlayer = $StepSound


func _ready() -> void:
	_volume_rows = {%MasterVolume: &"Master", %MusicVolume: &"Music", %SfxVolume: &"SFX"}
	_language.stepped.connect(Settings.cycle_language)
	for row: OptionRow in _volume_rows:
		row.stepped.connect(_step_volume.bind(_volume_rows[row]))
	_auto_text.stepped.connect(func(_direction: int) -> void: Settings.set_auto_advance(not Settings.auto_advance))
	_display.stepped.connect(Settings.cycle_display)
	for row in rows():
		row.stepped.connect(func(_direction: int) -> void: _step_sound.play())
	_back.pressed.connect(close)
	Settings.changed.connect(_refresh)
	_refresh()


## As linhas de configuração, na ordem da tela.
func rows() -> Array[OptionRow]:
	var result: Array[OptionRow] = []
	for child in get_children():
		if child is OptionRow:
			result.append(child)
	return result


func open() -> void:
	show()
	_refresh()
	_language.grab_focus()


func close() -> void:
	hide()
	closed.emit()


func _input(event: InputEvent) -> void:
	if is_visible_in_tree() and (event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"quit")):
		get_viewport().set_input_as_handled()
		close()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _step_volume(direction: int, bus: StringName) -> void:
	Settings.set_volume(bus, Settings.volume(bus) + direction * Settings.VOLUME_STEP)


func _refresh() -> void:
	_language.value_text = Settings.LANGUAGE_NAMES[Settings.language]
	for row: OptionRow in _volume_rows:
		row.filled = roundi(Settings.volume(_volume_rows[row]) * row.pips)
	_auto_text.value_text = tr(ON_TEXT if Settings.auto_advance else OFF_TEXT)
	var window := Settings.window_size()
	_display.value_text = tr(FULLSCREEN_TEXT) if Settings.fullscreen else "%dx%d" % [window.x, window.y]
