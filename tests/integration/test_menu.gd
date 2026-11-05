extends GutTest
## Menu principal: continuar, novo jogo, um botão por capítulo (todos liberados) e versão dev.

const MENU_SCENE := preload("res://menu/menu.tscn")

var _menu: Menu


func before_each() -> void:
	_menu = MENU_SCENE.instantiate()
	add_child_autofree(_menu)


func test_lists_every_chapter_and_dev_extra_as_enabled_buttons() -> void:
	var chapters := _menu.get_node("%ChapterList").get_children()
	assert_eq(chapters.size(), Story.steps.size() + _menu.dev_steps.size())
	for i in Story.steps.size():
		var button := chapters[i] as Button
		assert_false(button.disabled, "capítulo %d deveria estar liberado" % (i + 1))
		assert_string_contains(button.text, Story.steps[i].title)


func test_new_game_has_focus() -> void:
	assert_true((_menu.get_node("%NewGameButton") as Button).has_focus())


func test_buttons_fit_the_screen() -> void:
	await wait_process_frames(2)
	var screen := Rect2(Vector2.ZERO, Vector2(320, 180))
	for button in _menu.buttons():
		assert_true(screen.encloses(button.get_global_rect()), "%s fora da tela" % button.text)


func test_shows_dev_version() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version")
	assert_eq((_menu.get_node("%Version") as Label).text, "v%s-dev" % version)


func test_continue_button_resumes_the_saved_step() -> void:
	var previous_path := Story.save_path
	Story.save_path = "user://test_progress.cfg"
	Story.save_progress(2)
	var menu: Menu = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var continue_button := menu.get_node("%ContinueButton") as Button
	assert_true(continue_button.visible)
	assert_string_contains(continue_button.text, Story.steps[2].title)
	assert_eq(menu.buttons()[0], continue_button, "continuar vem primeiro")
	Story.save_progress(-1)
	assert_eq(Story.saved_step(), -1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Story.save_path))
	Story.save_path = previous_path
