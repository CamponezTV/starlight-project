extends GutTest
## Caixa de diálogo: texto letra por letra, nome de quem fala e avanço com "pular".

const BOX_SCENE := preload("res://dialogue/dialogue_box.tscn")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

var _box: DialogueBox


func before_each() -> void:
	_box = BOX_SCENE.instantiate()
	add_child_autofree(_box)


func test_types_letter_by_letter_with_the_speaker_name() -> void:
	_box.say(GRANDPA, "Fale, meu querido!")
	await wait_process_frames(3)
	var text := _text()
	assert_eq(text.text, "Fale, meu querido!")
	assert_between(text.visible_characters, 0, text.text.length() - 1, "ainda escrevendo")
	assert_eq((_box.get_node("%Name") as Label).text, GRANDPA.display_name)


func test_finishes_the_line_on_its_own_and_waits() -> void:
	watch_signals(_box)
	_box.say(GRANDPA, "Quem sabe.")
	await wait_seconds(1.0)
	assert_eq(_text().visible_characters, -1)
	assert_true((_box.get_node("%NextMarker") as Control).visible)
	assert_signal_not_emitted(_box, "line_finished")


func test_first_press_completes_the_line_and_second_press_advances() -> void:
	watch_signals(_box)
	_box.say(GRANDPA, "As estrelas, meu neto, são corpos astrais.")
	await wait_process_frames(2)
	TestHelpers.tap(&"jump")
	await wait_process_frames(1)
	assert_eq(_text().visible_characters, -1, "mostra a fala inteira")
	assert_signal_not_emitted(_box, "line_finished")
	TestHelpers.tap(&"jump")
	await wait_process_frames(1)
	assert_signal_emitted(_box, "line_finished")


func test_narration_has_no_name() -> void:
	_box.say(null, "Eu não respondi.")
	await wait_process_frames(1)
	assert_eq((_box.get_node("%Name") as Label).text, "")


func test_can_sit_at_the_top_of_the_screen() -> void:
	var top_box: DialogueBox = BOX_SCENE.instantiate()
	top_box.at_top = true
	add_child_autofree(top_box)
	await wait_process_frames(1)
	var panel := top_box.get_node("Panel") as Control
	assert_lt(panel.get_global_rect().position.y, 20.0)
	assert_gt((_box.get_node("Panel") as Control).get_global_rect().position.y, 100.0)


func _text() -> Label:
	return _box.get_node("%Text") as Label


## Regressão: fechar e abrir logo em seguida escondia a fala nova no fim do fade.
func test_new_line_right_after_closing_stays_visible() -> void:
	_box.say(GRANDPA, "Oi.")
	await wait_process_frames(1)
	_box.close()
	_box.say(GRANDPA, "De novo.")
	await wait_seconds(DialogueBox.FADE_TIME + 0.1)
	assert_true(_box.is_open())
