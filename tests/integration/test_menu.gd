extends GutTest
## Tela de título: as opções, os capítulos (todos liberados), as configurações, a
## confirmação antes de apagar o progresso, a versão e os finais guardados fora do menu.

const MENU_SCENE := preload("res://menu/menu.tscn")
const FINALE_DIR := "res://cutscenes/finale/"

var _menu: Menu


func before_each() -> void:
	TestHelpers.use_test_save()
	_menu = MENU_SCENE.instantiate()
	add_child_autofree(_menu)


func after_each() -> void:
	TestHelpers.restore_save()


func after_all() -> void:
	Menu.dev_unlocked = false


func test_lists_every_chapter_as_an_enabled_button() -> void:
	var chapters := _menu.get_node("%ChapterList").get_children()
	assert_eq(chapters.size(), Story.steps.size() + _menu.dev_steps.size())
	for i in Story.steps.size():
		var button := chapters[i] as Button
		assert_false(button.disabled, "capítulo %d deveria estar liberado" % (i + 1))
		assert_string_contains(button.text, Story.steps[i].title)


## Os finais ficam guardados: nem a campanha nem os capítulos chegam neles, mas os passos
## embalados continuam apontando para as cenas, prontos para voltar.
func test_the_finale_stays_packed_away() -> void:
	for step: StoryStep in Story.steps + _menu.dev_steps:
		assert_false(step.scene.resource_path.begins_with(FINALE_DIR), "%s mostra um final" % step.title)
	for file in ["final_1.tres", "final_2.tres"]:
		var step := load(FINALE_DIR + file) as StoryStep
		assert_true(step.scene.resource_path.begins_with(FINALE_DIR), file)


func test_new_game_has_focus_without_a_save() -> void:
	assert_false((_menu.get_node("%ContinueButton") as Button).visible)
	assert_true((_menu.get_node("%NewGameButton") as Button).has_focus())


func test_every_page_fits_above_the_footer() -> void:
	var screen := Rect2(Vector2.ZERO, Vector2(320, 180))
	var footer := (_menu.get_node("Content/Hint") as Control)
	var pages := _menu.get_node("Content/Pages").get_children()
	for page: Control in pages:
		for other: Control in pages:
			other.visible = other == page
		await wait_process_frames(2)
		for button in page.find_children("*", "Button", true, false):
			assert_true(screen.encloses((button as Button).get_global_rect()), "%s/%s fora da tela" % [page.name, (button as Button).text])
		assert_lte(page.get_global_rect().end.y, footer.get_global_rect().position.y, "%s passa por cima do rodapé" % page.name)


func test_shows_the_pre_alpha_version() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version")
	assert_eq((_menu.get_node("%Version") as Label).text, "pré-alpha v%s" % version)


func test_continue_button_resumes_the_saved_step() -> void:
	Story.save_progress(2)
	var menu: Menu = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var continue_button := menu.get_node("%ContinueButton") as Button
	assert_true(continue_button.visible)
	assert_string_contains(continue_button.text, Story.steps[2].title)
	assert_eq(menu.buttons()[0], continue_button, "continuar vem primeiro")
	assert_true(continue_button.has_focus())


func test_new_game_asks_before_erasing_a_save() -> void:
	Story.save_progress(2)
	var menu: Menu = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	(menu.get_node("%NewGameButton") as Button).pressed.emit()
	assert_eq(menu.current_page(), Menu.Page.CONFIRM)
	assert_true((menu.get_node("%CancelNewGame") as Button).has_focus(), "o foco começa no lado seguro")
	(menu.get_node("%CancelNewGame") as Button).pressed.emit()
	assert_eq(menu.current_page(), Menu.Page.MAIN)
	assert_eq(Story.saved_step(), 2, "cancelar não apaga nada")


func test_chapters_stay_hidden_until_the_secret_code() -> void:
	Menu.dev_unlocked = false
	var menu: Menu = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var chapters := menu.get_node("%ChaptersButton") as Button
	assert_false(chapters.visible, "o pré-alpha não mostra os capítulos")
	assert_false(menu.buttons().has(chapters))
	for key: Key in SecretCode.SEQUENCE.slice(0, -1):
		_press(key)
	assert_false(chapters.visible, "o código pela metade não libera")
	_press(SecretCode.SEQUENCE.back())
	assert_true(chapters.visible, "o código inteiro libera os capítulos")
	assert_true(Menu.dev_unlocked)
	var reopened: Menu = MENU_SCENE.instantiate()
	add_child_autofree(reopened)
	assert_true((reopened.get_node("%ChaptersButton") as Button).visible, "continua liberado ao voltar ao menu")


func test_a_wrong_key_restarts_the_code() -> void:
	Menu.dev_unlocked = false
	var menu: Menu = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var sequence := SecretCode.SEQUENCE
	for key: Key in sequence.slice(0, 4) + [KEY_X] + sequence.slice(4):
		_press(key)
	assert_false((menu.get_node("%ChaptersButton") as Button).visible)
	for key: Key in [KEY_UP] + sequence:
		_press(key)
	assert_true((menu.get_node("%ChaptersButton") as Button).visible, "uma tecla a mais antes do código não atrapalha")


func test_chapters_and_settings_open_and_escape_comes_back() -> void:
	Menu.dev_unlocked = true
	_menu = MENU_SCENE.instantiate()
	add_child_autofree(_menu)
	(_menu.get_node("%ChaptersButton") as Button).pressed.emit()
	assert_eq(_menu.current_page(), Menu.Page.CHAPTERS)
	TestHelpers.tap(&"ui_cancel")
	await wait_process_frames(1)
	assert_eq(_menu.current_page(), Menu.Page.MAIN)
	assert_true((_menu.get_node("%ChaptersButton") as Button).has_focus(), "volta para a opção de onde saiu")
	(_menu.get_node("%SettingsButton") as Button).pressed.emit()
	assert_eq(_menu.current_page(), Menu.Page.SETTINGS)
	TestHelpers.tap(&"ui_cancel")
	await wait_process_frames(1)
	assert_eq(_menu.current_page(), Menu.Page.MAIN)


func test_escape_on_the_main_page_only_points_to_quit() -> void:
	TestHelpers.tap(&"ui_cancel")
	await wait_process_frames(1)
	assert_true((_menu.get_node("%QuitButton") as Button).has_focus(), "Esc não fecha o jogo de surpresa")


func test_plays_the_night_theme() -> void:
	assert_eq(_menu.music.resource_path, "res://music/menu_promise.wav")


func test_star_cursor_follows_the_focus() -> void:
	await wait_process_frames(1)
	var cursor := _menu.get_node("Cursor") as Sprite2D
	var settings := _menu.get_node("%SettingsButton") as Button
	settings.grab_focus()
	await wait_seconds(Menu.CURSOR_SLIDE + 0.1)
	assert_true(cursor.visible)
	assert_almost_eq(cursor.position.y, settings.get_global_rect().get_center().y, 1.0)


func _press(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
