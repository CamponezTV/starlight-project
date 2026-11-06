class_name Menu
extends Control
## Menu principal do protótipo: continuar, novo jogo, capítulos (todos liberados nesta build de
## desenvolvimento) e sair. Os capítulos vêm da campanha (autoload Story).
## Música: toca `music_path` se o arquivo existir. A pasta menu/music/ fica fora do Git
## (música de terceiros não vai para o repositório). Sem ele, toca `fallback_music`.

const VERSION_FORMAT := "v%s-dev"
const SELECT_DELAY := 0.3 ## Tempo para o som de confirmar tocar antes de trocar de cena.
const CHAPTER_BUTTON_WIDTH := 100.0
const CONTINUE_FORMAT := "Continuar: %s"

@export var dev_steps: Array[StoryStep] = [] ## Extras da build dev, fora da campanha.
@export_file("*.ogg", "*.mp3", "*.wav") var music_path := "res://menu/music/menu_theme.mp3"
@export var fallback_music: AudioStream

@onready var _continue_button: Button = %ContinueButton
@onready var _new_game_button: Button = %NewGameButton
@onready var _chapter_list: GridContainer = %ChapterList
@onready var _quit_button: Button = %QuitButton
@onready var _version: Label = %Version
@onready var _move_sound: AudioStreamPlayer = %MoveSound
@onready var _select_sound: AudioStreamPlayer = %SelectSound


func _ready() -> void:
	_version.text = VERSION_FORMAT % ProjectSettings.get_setting("application/config/version")
	var saved_step := Story.saved_step()
	_continue_button.visible = saved_step > 0
	if _continue_button.visible:
		_continue_button.text = CONTINUE_FORMAT % Story.steps[saved_step].title
		_continue_button.pressed.connect(_select.bind(Story.start.bind(saved_step)))
	_new_game_button.pressed.connect(_select.bind(Story.start.bind(0)))
	for i in Story.steps.size():
		_add_chapter_button("%d. %s" % [i + 1, Story.steps[i].title], Story.start.bind(i))
	for step in dev_steps:
		_add_chapter_button(step.title, Story.play_outside_campaign.bind(step))
	_quit_button.pressed.connect(App.quit)
	buttons()[0].grab_focus()
	# Só depois do foco inicial, para o menu não abrir já fazendo barulho.
	for button in buttons():
		button.focus_entered.connect(_move_sound.play)
	Music.play(_music())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"quit"):
		App.quit()


## Todos os botões, na ordem da tela.
func buttons() -> Array[Button]:
	var result: Array[Button] = []
	if _continue_button.visible:
		result.append(_continue_button)
	result.append(_new_game_button)
	for child in _chapter_list.get_children():
		result.append(child as Button)
	result.append(_quit_button)
	return result


func _add_chapter_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.x = CHAPTER_BUTTON_WIDTH
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.pressed.connect(_select.bind(action))
	_chapter_list.add_child(button)


func _music() -> AudioStream:
	if not ResourceLoader.exists(music_path):
		return fallback_music
	var music: AudioStream = load(music_path)
	if "loop" in music:
		music.set("loop", true)
	return music


## Toca o som de confirmar e, depois de um instante, executa a escolha.
func _select(action: Callable) -> void:
	get_viewport().gui_disable_input = true
	_select_sound.play()
	await get_tree().create_timer(SELECT_DELAY).timeout
	get_viewport().gui_disable_input = false
	action.call()
