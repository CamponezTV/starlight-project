extends GutTest
## Menu principal: uma opção por fase, todas liberadas, e versão de desenvolvimento.

const MENU_SCENE := preload("res://menu/menu.tscn")

var _menu: Menu


func before_each() -> void:
	_menu = MENU_SCENE.instantiate()
	add_child_autofree(_menu)


func test_lists_every_level_as_an_enabled_button() -> void:
	var buttons := _menu.get_node("%LevelList").get_children()
	assert_eq(buttons.size(), _menu.levels.size())
	for i in buttons.size():
		var button := buttons[i] as Button
		assert_false(button.disabled, "fase %d deveria estar liberada" % (i + 1))
		assert_string_contains(button.text, _menu.levels[i].title)


func test_every_level_has_a_room_scene() -> void:
	for level in _menu.levels:
		assert_not_null(level.scene, "%s sem cena" % level.title)


func test_shows_dev_version() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version")
	assert_eq((_menu.get_node("%Version") as Label).text, "v%s-dev" % version)
