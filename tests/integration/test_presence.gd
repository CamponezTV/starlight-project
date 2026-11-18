extends GutTest
## Status no Discord (autoload Presence): o que ele mostra no menu, em cada passo da
## campanha e fora dela. Sem Discord (como nos testes), o status é montado do mesmo jeito.

const MENU_SCENE := preload("res://menu/menu.tscn")
const TEST_ROOM := preload("res://levels/test_room.tscn")
const CHAPTER := 5 ## "A Queda", uma fase.
const MEMORY := 6 ## "Sophie", uma cutscene.


func after_each() -> void:
	TestHelpers.use_test_settings()
	_show(MENU_SCENE.instantiate())


func test_menu_shows_only_the_menu_and_the_icon() -> void:
	_show(MENU_SCENE.instantiate())
	var activity := Presence.activity()
	assert_eq(activity["details"], Presence.MENU_TEXT)
	assert_false(activity.has("state"))
	assert_eq(activity["assets"]["large_image"], Presence.IMAGE_KEY)


func test_a_level_shows_its_chapter_and_the_icon() -> void:
	var step := Story.steps[CHAPTER - 1]
	_show(Story.instantiate_step(step))
	var activity := Presence.activity()
	assert_eq(activity["details"], "Capítulo %d: %s" % [CHAPTER, step.title])
	assert_eq(activity["state"], Presence.PLAYING_TEXT)
	assert_eq(activity["assets"]["large_image"], Presence.IMAGE_KEY, "uma imagem só, o ícone")


func test_a_cutscene_shows_a_memory() -> void:
	_show(Story.instantiate_step(Story.steps[MEMORY - 1]))
	assert_eq(Presence.activity()["state"], Presence.WATCHING_TEXT)


func test_a_scene_outside_the_campaign_shows_dev_mode() -> void:
	var game: Main = (load("res://main/main.tscn") as PackedScene).instantiate()
	game.level_scene = TEST_ROOM
	_show(game)
	assert_eq(Presence.activity()["details"], Presence.DEV_TEXT)


func test_only_the_main_scene_changes_the_status() -> void:
	_show(MENU_SCENE.instantiate())
	var cutscene: Node = Story.steps[MEMORY - 1].scene.instantiate()
	add_child_autofree(cutscene) # Não é filha da raiz, como uma conversa dentro de uma fase.
	assert_eq(Presence.activity()["details"], Presence.MENU_TEXT)


func test_the_status_follows_the_language() -> void:
	_show(Story.instantiate_step(Story.steps[CHAPTER - 1]))
	Settings.set_language("en")
	assert_eq(Presence.activity()["details"], "Chapter %d: %s" % [CHAPTER, tr(Story.steps[CHAPTER - 1].title)])
	assert_eq(Presence.activity()["state"], "Playing")


## O Discord recusa o status inteiro se um texto vier vazio.
func test_no_text_is_ever_empty() -> void:
	for step in Story.steps:
		_show(Story.instantiate_step(step))
		for key in ["details", "state"]:
			assert_gt((Presence.activity()[key] as String).length(), 1, "texto vazio em %s" % step.title)


## O ícone fica pronto para enviar ao Discord.
func test_the_icon_image_exists() -> void:
	assert_true(FileAccess.file_exists("res://tools/discord/images/%s.png" % Presence.IMAGE_KEY))


func _show(scene: Node) -> void:
	Presence.show_scene(scene)
	scene.free()
