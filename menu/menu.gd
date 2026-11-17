class_name Menu
extends Control
## Tela de título: a colina do prólogo (o Jupiter e o avô no telescópio) passando devagar,
## o logo e as opções. Páginas: principal, capítulos, configurações e a confirmação de
## jogo novo (só quando há progresso salvo). Uma estrela-cursor acompanha a opção em foco.
## O pré-alpha só mostra Continuar, Novo jogo, Configurações e Sair. Os capítulos (e os
## extras de desenvolvimento) aparecem com o código secreto (SecretCode) e ficam liberados
## até o jogo fechar.

enum Page { MAIN, CHAPTERS, SETTINGS, CONFIRM }

const VERSION_TEXT := "pré-alpha v%s"
const CONTINUE_TEXT := "Continuar: %s"
const CHAPTER_TEXT := "%d. %s"
const DEV_UNLOCKED_TEXT := "Modo dev: capítulos liberados"
const DEV_MESSAGE_TIME := 2.5
const SELECT_DELAY := 0.3 ## Tempo para o som de confirmar tocar antes de trocar de cena.
const PAN_DISTANCE := 32.0 ## Sobra de largura da arte da colina (352 px numa tela de 320).
const PAN_TIME := 36.0
const CLOUD_DRIFT := 24.0 ## As nuvens andam mais que a colina durante o pan.
const INTRO_TIME := 1.4
const LOGO_DROP := 6.0
const DIM_TIME := 0.3 ## A cena escurece nas subpáginas, para o texto ler bem.
const CURSOR_X := 5.0 ## Da borda esquerda da opção ao centro da estrela.
const CURSOR_SLIDE := 0.12
const CURSOR_FPS := 6.0
const SHOOTING_STAR_WAIT := Vector2(6.0, 12.0) ## Entre uma estrela cadente e outra (s).
const SHOOTING_STAR_TIME := 1.1
const SHOOTING_STAR_FROM := Rect2(170, 4, 140, 20) ## Onde ela nasce...
const SHOOTING_STAR_PATH := Vector2(-110, 46) ## ...e quanto anda.

## Extras que não fazem parte da campanha (sala de teste, finais), junto dos capítulos.
@export var dev_steps: Array[StoryStep] = []
@export var music: AudioStream

## Liberado pelo código secreto. Estático: continua valendo quando o menu volta a abrir.
static var dev_unlocked := false

var _page := Page.MAIN
var _chapters: Array[Dictionary] = [] ## {button, title, number}; extras não têm número (0).
var _cursor_tween: Tween
var _time := 0.0

@onready var _scene: Node2D = $Scene
@onready var _clouds: Sprite2D = $Scene/Clouds
@onready var _content: Control = $Content
@onready var _dim: ColorRect = $Dim
@onready var _logo: Control = $Content/Logo
@onready var _pages := {
	Page.MAIN: $Content/Pages/Main,
	Page.CHAPTERS: $Content/Pages/Chapters,
	Page.SETTINGS: $Content/Pages/Settings,
	Page.CONFIRM: $Content/Pages/Confirm,
}
@onready var _continue_button: Button = %ContinueButton
@onready var _new_game_button: Button = %NewGameButton
@onready var _chapters_button: Button = %ChaptersButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _chapter_list: GridContainer = %ChapterList
@onready var _chapters_back: Button = %ChaptersBack
@onready var _settings: SettingsPanel = $Content/Pages/Settings
@onready var _confirm_button: Button = %ConfirmNewGame
@onready var _cancel_button: Button = %CancelNewGame
@onready var _version: Label = %Version
@onready var _cursor: Sprite2D = $Cursor
@onready var _dev_message: FadingLabel = %DevMessage
@onready var _shooting_star: Node2D = $ShootingStar
@onready var _shooting_timer: Timer = $ShootingStar/Timer
@onready var _move_sound: AudioStreamPlayer = %MoveSound
@onready var _select_sound: AudioStreamPlayer = %SelectSound


func _ready() -> void:
	_build_chapters()
	_refresh_texts()
	var saved_step := Story.saved_step()
	_continue_button.visible = saved_step > 0
	_continue_button.pressed.connect(_select.bind(Story.start.bind(maxi(saved_step, 0))))
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_chapters_button.pressed.connect(_show_page.bind(Page.CHAPTERS))
	_settings_button.pressed.connect(_open_settings)
	_quit_button.pressed.connect(App.quit)
	_chapters_button.visible = dev_unlocked
	$SecretCode.entered.connect(_unlock_dev)
	_chapters_back.pressed.connect(_back_to_main.bind(_chapters_button))
	_settings.closed.connect(_back_to_main.bind(_settings_button))
	_confirm_button.pressed.connect(_select.bind(Story.start.bind(0)))
	_cancel_button.pressed.connect(_back_to_main.bind(_new_game_button))
	# Adiado: numa página que acabou de aparecer, a opção ainda não está no lugar.
	get_viewport().gui_focus_changed.connect(func(control: Control) -> void: _move_cursor.call_deferred(control))
	_show_page(Page.MAIN)
	# Só depois do foco inicial, para o menu não abrir já fazendo barulho.
	for button in _all_buttons():
		button.focus_entered.connect(_move_sound.play)
		button.mouse_entered.connect(button.grab_focus)
	_shooting_timer.timeout.connect(_shoot_star)
	_shooting_timer.start(randf_range(SHOOTING_STAR_WAIT.x, SHOOTING_STAR_WAIT.y))
	_start_ambience()
	_intro()
	Music.play(music)


func _process(delta: float) -> void:
	_time += delta
	_cursor.frame = int(_time * CURSOR_FPS) % _cursor.hframes


func _unhandled_input(event: InputEvent) -> void:
	if not (event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"quit")):
		return
	get_viewport().set_input_as_handled()
	match _page:
		Page.MAIN:
			_quit_button.grab_focus()
		Page.CHAPTERS:
			_back_to_main(_chapters_button)
		Page.CONFIRM:
			_back_to_main(_new_game_button)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_texts()


## As opções da página principal, na ordem da tela.
func buttons() -> Array[Button]:
	var result: Array[Button] = []
	for child in _pages[Page.MAIN].get_children():
		if child is Button and (child as Button).visible:
			result.append(child)
	return result


func current_page() -> Page:
	return _page


func _all_buttons() -> Array[Button]:
	var result: Array[Button] = []
	for page: Control in _pages.values():
		for button in page.find_children("*", "Button", true, false):
			result.append(button as Button)
	return result


func _build_chapters() -> void:
	for i in Story.steps.size():
		_add_chapter_button(Story.steps[i].title, i + 1, Story.start.bind(i))
	for step in dev_steps:
		_add_chapter_button(step.title, 0, Story.play_outside_campaign.bind(step))


func _add_chapter_button(title: String, number: int, action: Callable) -> void:
	var button := Button.new()
	button.theme_type_variation = &"MenuItem"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(_select.bind(action))
	_chapter_list.add_child(button)
	_chapters.append({"button": button, "title": title, "number": number})


## Textos montados em código (os da cena o próprio Godot traduz).
func _refresh_texts() -> void:
	_version.text = tr(VERSION_TEXT) % ProjectSettings.get_setting("application/config/version")
	var saved_step := Story.saved_step()
	if saved_step > 0:
		_continue_button.text = tr(CONTINUE_TEXT) % tr(Story.steps[saved_step].title)
	for chapter in _chapters:
		var button: Button = chapter["button"]
		var number: int = chapter["number"]
		var title: String = chapter["title"]
		button.text = tr(CHAPTER_TEXT) % [number, tr(title)] if number > 0 else tr(title)


func _show_page(page: Page) -> void:
	_page = page
	for key: Page in _pages:
		(_pages[key] as Control).visible = key == page
	create_tween().tween_property(_dim, "modulate:a", 0.0 if page == Page.MAIN else 1.0, DIM_TIME)
	match page:
		Page.MAIN:
			buttons()[0].grab_focus()
		Page.CHAPTERS:
			(_chapter_list.get_child(0) as Button).grab_focus()
		Page.CONFIRM:
			_cancel_button.grab_focus()


func _unlock_dev() -> void:
	if dev_unlocked:
		return
	dev_unlocked = true
	_select_sound.play()
	_dev_message.show_text(tr(DEV_UNLOCKED_TEXT), DEV_MESSAGE_TIME)
	_chapters_button.show()
	if _page == Page.MAIN:
		_chapters_button.grab_focus()


func _back_to_main(focus: Button) -> void:
	_show_page(Page.MAIN)
	focus.grab_focus()


func _open_settings() -> void:
	_show_page(Page.SETTINGS)
	_settings.open()


## Jogo novo apaga o progresso: com algo salvo, pergunta antes.
func _on_new_game_pressed() -> void:
	if Story.saved_step() > 0:
		_show_page(Page.CONFIRM)
	else:
		_select(Story.start.bind(0))


## A estrela-cursor desliza até a opção em foco (só as opções desta tela).
func _move_cursor(control: Control) -> void:
	if not is_instance_valid(control) or not (control is Button) or not is_ancestor_of(control):
		return
	var rect := control.get_global_rect()
	var target := Vector2(rect.position.x + CURSOR_X, rect.get_center().y).round()
	if _cursor_tween != null:
		_cursor_tween.kill()
	if not _cursor.visible:
		_cursor.position = target
		_cursor.show()
		return
	_cursor_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_cursor_tween.tween_property(_cursor, "position", target, CURSOR_SLIDE)


## A colina vai e volta devagar; as nuvens andam um pouco mais.
func _start_ambience() -> void:
	var pan := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pan.tween_property(_scene, "position:x", -PAN_DISTANCE, PAN_TIME)
	pan.tween_property(_scene, "position:x", 0.0, PAN_TIME)
	var drift := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(_clouds, "position:x", _clouds.position.x - CLOUD_DRIFT, PAN_TIME)
	drift.tween_property(_clouds, "position:x", _clouds.position.x, PAN_TIME)


func _intro() -> void:
	_content.modulate.a = 0.0
	var logo_y := _logo.position.y
	_logo.position.y -= LOGO_DROP
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_content, "modulate:a", 1.0, INTRO_TIME)
	tween.tween_property(_logo, "position:y", logo_y, INTRO_TIME)


func _shoot_star() -> void:
	var from := SHOOTING_STAR_FROM.position + Vector2(randf() * SHOOTING_STAR_FROM.size.x, randf() * SHOOTING_STAR_FROM.size.y)
	_shooting_star.position = from
	_shooting_star.modulate.a = 1.0
	_shooting_star.show()
	var tween := create_tween().set_parallel()
	tween.tween_property(_shooting_star, "position", from + SHOOTING_STAR_PATH, SHOOTING_STAR_TIME).set_ease(Tween.EASE_IN)
	tween.tween_property(_shooting_star, "modulate:a", 0.0, SHOOTING_STAR_TIME).set_ease(Tween.EASE_IN)
	_shooting_timer.start(randf_range(SHOOTING_STAR_WAIT.x, SHOOTING_STAR_WAIT.y))


## Toca o som de confirmar e, depois de um instante, executa a escolha.
func _select(action: Callable) -> void:
	get_viewport().gui_disable_input = true
	_select_sound.play()
	await get_tree().create_timer(SELECT_DELAY).timeout
	get_viewport().gui_disable_input = false
	action.call()
