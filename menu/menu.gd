class_name Menu
extends Control
## Menu principal do protótipo: aviso de build de desenvolvimento e seleção de fases.
## Nesta build todas as fases ficam liberadas. Para adicionar uma fase, inclua um
## LevelInfo em `levels` no Inspetor.
## A música é opcional: toca o arquivo em `music_path` se ele existir. A pasta menu/music/
## fica fora do Git (música de terceiros não deve ir para o repositório).

const GAME_SCENE := preload("res://main/main.tscn")
const VERSION_FORMAT := "v%s-dev"
const SELECT_DELAY := 0.3 ## Tempo para o som de confirmar tocar antes de trocar de cena.

@export var levels: Array[LevelInfo] = []
@export_file("*.ogg", "*.mp3", "*.wav") var music_path := "res://menu/music/menu_theme.mp3"

@onready var _level_list: VBoxContainer = %LevelList
@onready var _quit_button: Button = %QuitButton
@onready var _version: Label = %Version
@onready var _music_player: AudioStreamPlayer = %Music
@onready var _move_sound: AudioStreamPlayer = %MoveSound
@onready var _select_sound: AudioStreamPlayer = %SelectSound


func _ready() -> void:
	_version.text = VERSION_FORMAT % ProjectSettings.get_setting("application/config/version")
	for i in levels.size():
		_add_level_button(i + 1, levels[i])
	_quit_button.pressed.connect(App.quit)
	_focus_first_button()
	# Só depois do foco inicial, para o menu não abrir já fazendo barulho.
	for button in _buttons():
		button.focus_entered.connect(_move_sound.play)
	_play_music()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"quit"):
		App.quit()


func _add_level_button(number: int, level: LevelInfo) -> void:
	var button := Button.new()
	button.text = "%d. %s" % [number, level.title]
	button.pressed.connect(_start.bind(level.scene))
	_level_list.add_child(button)


func _buttons() -> Array[Button]:
	var result: Array[Button] = []
	for child in _level_list.get_children():
		result.append(child as Button)
	result.append(_quit_button)
	return result


func _focus_first_button() -> void:
	_buttons()[0].grab_focus()


func _play_music() -> void:
	if not ResourceLoader.exists(music_path):
		return
	var music: AudioStream = load(music_path)
	if "loop" in music:
		music.set("loop", true)
	_music_player.stream = music
	_music_player.play()


## Toca o som de confirmar e troca o menu pelo jogo já com a sala escolhida.
func _start(room_scene: PackedScene) -> void:
	get_viewport().gui_disable_input = true
	_select_sound.play()
	await get_tree().create_timer(SELECT_DELAY).timeout
	get_viewport().gui_disable_input = false
	var game: Main = GAME_SCENE.instantiate()
	game.room_scene = room_scene
	var tree := get_tree()
	tree.root.add_child(game)
	tree.current_scene = game
	queue_free()
