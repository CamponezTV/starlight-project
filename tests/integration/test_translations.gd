extends GutTest
## Traduções: todo texto que o jogador lê tem inglês, o arquivo não guarda texto que saiu
## do jogo, e o inglês cabe onde o português cabe (falas, lembranças, palavras da Sophie,
## o menu).

const PO_PATH := "res://locale/en.po"
const MAX_DIALOGUE_LINES := 2
const MAX_THOUGHT_LINES := 2
const MAX_RAIN_LETTERS := 5 ## As mesmas medidas de test_boss_sophie.gd.
const MAX_SWEEP_LETTERS := 27
const MENU_SCENE := preload("res://menu/menu.tscn")
const MOUNTAIN := preload("res://cutscenes/mountain/mountain.tscn")

var _english: Translation


func before_all() -> void:
	_english = load(PO_PATH)


func after_each() -> void:
	TestHelpers.use_test_settings()


func test_every_text_has_an_english_translation() -> void:
	var catalog := StringCatalog.collect()
	assert_gt(catalog.size(), 300, "o catálogo deveria achar centenas de textos")
	for text: String in catalog:
		assert_ne(_english.get_message(text), "", "sem tradução: \"%s\" (%s)" % [text, ", ".join(catalog[text])])


func test_no_translation_is_left_over() -> void:
	var catalog := StringCatalog.collect()
	for text in _english.get_message_list():
		assert_true(catalog.has(text), "o texto \"%s\" saiu do jogo; rode tools/i18n/update_po.gd" % text)


func test_formats_keep_their_placeholders() -> void:
	for text in _english.get_message_list():
		for placeholder in ["%s", "%d"]:
			assert_eq(_english.get_message(text).count(placeholder), text.count(placeholder), "\"%s\" perdeu um %s" % [text, placeholder])


func test_every_english_line_fits_the_dialogue_box() -> void:
	var box: DialogueBox = (load("res://dialogue/dialogue_box.tscn") as PackedScene).instantiate()
	add_child_autofree(box)
	var label := box.get_node("%Text") as Label
	for line in StringCatalog.dialogue_lines():
		label.text = _english.get_message(line)
		assert_lte(label.get_line_count(), MAX_DIALOGUE_LINES, "não cabe: %s" % label.text)


func test_every_english_thought_fits_two_lines() -> void:
	var mountain: Node = MOUNTAIN.instantiate()
	mountain.set("advances_story", false)
	add_child_autofree(mountain)
	var thought := mountain.get_node("Thoughts/Label") as Label
	thought.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	for spot: MemorySpot in mountain.get_node("Memories").get_children():
		thought.text = _english.get_message(spot.text)
		assert_lte(thought.get_line_count(), MAX_THOUGHT_LINES, "não cabe: %s" % thought.text)


func test_sophie_english_words_stay_dodgeable() -> void:
	for word: String in SophieBoss.RAIN_TEXTS + [SophieBoss.RING_TEXT, SophieBoss.SHOCKWAVE_TEXT]:
		assert_lte(_english.get_message(word).length(), MAX_RAIN_LETTERS, "\"%s\" é larga demais" % _english.get_message(word))
	for phrase: String in SophieBoss.SWEEP_TEXTS:
		assert_lte(_english.get_message(phrase).length(), MAX_SWEEP_LETTERS, "\"%s\" é comprida demais" % _english.get_message(phrase))


func test_menu_fits_the_screen_in_english() -> void:
	Settings.set_language("en")
	var menu: Menu = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var screen := Rect2(Vector2.ZERO, Vector2(320, 180))
	var pages := menu.get_node("Content/Pages").get_children()
	for page: Control in pages:
		for other: Control in pages:
			other.visible = other == page
		await wait_process_frames(2)
		for button in page.find_children("*", "Button", true, false):
			var rect := (button as Button).get_global_rect()
			assert_true(screen.encloses(rect), "%s/%s fora da tela: %s" % [page.name, (button as Button).text, rect])
		assert_lte(page.get_global_rect().end.y, (menu.get_node("Content/Hint") as Control).get_global_rect().position.y, "%s passa por cima do rodapé" % page.name)
