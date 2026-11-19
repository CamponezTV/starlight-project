extends GutTest
## Configurações (autoload Settings): idioma, volumes, texto automático, tamanho da janela, o que fica salvo
## e o painel que o menu e a pausa usam.

const PANEL_SCENE := preload("res://ui/settings_panel.tscn")
const BOX_SCENE := preload("res://dialogue/dialogue_box.tscn")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")
const TRANSLATED_SAMPLE := "Novo jogo"


func before_each() -> void:
	TestHelpers.use_test_settings()


func after_all() -> void:
	TestHelpers.use_test_settings()


func test_portuguese_is_the_default() -> void:
	assert_eq(Settings.language, "pt_BR")
	assert_eq(TranslationServer.get_locale(), "pt_BR")
	assert_eq(tr(TRANSLATED_SAMPLE), TRANSLATED_SAMPLE, "em português o texto fica como foi escrito")


func test_english_translates_the_game_text() -> void:
	Settings.set_language("en")
	assert_eq(tr(TRANSLATED_SAMPLE), "New game")
	Settings.cycle_language(1)
	assert_eq(Settings.language, "pt_BR", "a lista de idiomas dá a volta")


func test_volume_sets_the_bus_and_zero_mutes_it() -> void:
	var music := AudioServer.get_bus_index(&"Music")
	var full_db := AudioServer.get_bus_volume_db(music)
	Settings.set_volume(&"Music", 0.5)
	assert_almost_eq(AudioServer.get_bus_volume_db(music), full_db + linear_to_db(0.5), 0.01)
	Settings.set_volume(&"Music", 0.0)
	assert_true(AudioServer.is_bus_mute(music))
	Settings.set_volume(&"Music", 1.0)
	assert_false(AudioServer.is_bus_mute(music))
	assert_almost_eq(AudioServer.get_bus_volume_db(music), full_db, 0.01)


func test_volume_stays_between_zero_and_one_in_steps() -> void:
	Settings.set_volume(&"SFX", 1.7)
	assert_eq(Settings.volume(&"SFX"), 1.0)
	Settings.set_volume(&"SFX", 0.43)
	assert_almost_eq(Settings.volume(&"SFX"), 0.4, 0.001)


func test_choices_are_saved_and_loaded_back() -> void:
	Settings.set_language("en")
	Settings.set_volume(&"Master", 0.3)
	Settings.set_auto_advance(true)
	Settings.language = "pt_BR"
	Settings.auto_advance = false
	Settings.load_settings()
	assert_eq(Settings.language, "en")
	assert_almost_eq(Settings.volume(&"Master"), 0.3, 0.001)
	assert_true(Settings.auto_advance)


## A tela passa pelas janelas (a resolução do jogo vezes uma escala inteira, até a maior que
## cabe: nos testes, uma tela Full HD de mentira, até 6x) e termina na tela cheia.
func test_display_steps_through_whole_scales_then_fullscreen() -> void:
	assert_eq(Settings.game_resolution(), Vector2i(320, 180))
	assert_eq(Settings.window_size(), Vector2i(1280, 720), "o padrão é 4x")
	Settings.cycle_display(1)
	assert_eq(Settings.window_size(), Vector2i(1600, 900))
	Settings.cycle_display(1)
	assert_eq(Settings.window_size(), Vector2i(1920, 1080))
	assert_false(Settings.fullscreen)
	Settings.cycle_display(1)
	assert_true(Settings.fullscreen, "depois da maior janela, a tela cheia")
	Settings.cycle_display(1)
	assert_false(Settings.fullscreen)
	assert_eq(Settings.window_scale, Settings.WINDOW_SCALE_MIN, "e dá a volta na menor")
	Settings.cycle_display(-1)
	assert_true(Settings.fullscreen)


func test_window_size_is_saved_and_never_bigger_than_the_screen() -> void:
	Settings.set_window_scale(3)
	Settings.window_scale = Settings.WINDOW_SCALE_DEFAULT
	Settings.load_settings()
	assert_eq(Settings.window_scale, 3)
	Settings.set_window_scale(50)
	assert_eq(Settings.window_scale, Settings.max_window_scale())


func test_auto_advance_moves_the_dialogue_on_its_own() -> void:
	var box: DialogueBox = BOX_SCENE.instantiate()
	add_child_autofree(box)
	watch_signals(box)
	box.say(GRANDPA, "Oi.")
	await wait_seconds(1.0)
	assert_signal_not_emitted(box, "line_finished", "sem o texto automático, a fala espera o jogador")
	Settings.set_auto_advance(true)
	box.say(GRANDPA, "Oi.")
	await wait_seconds(DialogueBox.AUTO_ADVANCE_BASE + 0.6)
	assert_signal_emitted(box, "line_finished", "com o texto automático, a fala passa sozinha")


func test_dialogue_shows_the_line_in_the_chosen_language() -> void:
	var box: DialogueBox = BOX_SCENE.instantiate()
	add_child_autofree(box)
	Settings.set_language("en")
	box.say(GRANDPA, "Bom menino.")
	await wait_process_frames(1)
	assert_eq((box.get_node("%Text") as Label).text, "Good boy.")


func test_panel_rows_change_the_settings() -> void:
	var panel: SettingsPanel = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	panel.open()
	var rows := panel.rows()
	rows[0].stepped.emit(1)
	assert_eq(Settings.language, "en", "a linha do idioma troca o idioma")
	var master := panel.get_node("%MasterVolume") as OptionRow
	master.stepped.emit(-1)
	assert_almost_eq(Settings.volume(&"Master"), 0.9, 0.001)
	assert_eq(master.filled, 9, "a barra mostra o volume novo")
	(panel.get_node("%AutoText") as OptionRow).stepped.emit(1)
	assert_true(Settings.auto_advance)
	var display := panel.get_node("%Display") as OptionRow
	assert_eq(display.value_text, "1280x720")
	display.stepped.emit(-1)
	assert_eq(display.value_text, "960x540", "a linha mostra o tamanho novo")
	Settings.set_fullscreen(true)
	assert_eq(display.value_text, "Fullscreen", "em inglês (a primeira linha trocou o idioma)")


func test_panel_closes_with_escape() -> void:
	var panel: SettingsPanel = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	panel.open()
	watch_signals(panel)
	TestHelpers.tap(&"ui_cancel")
	await wait_process_frames(1)
	assert_signal_emitted(panel, "closed")
	assert_false(panel.visible)
