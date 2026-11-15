extends PlaythroughTest
## A Diana: a caixa de escolhas, a conversa com os dois desfechos, a memória da Story e
## a cabana da Fase 3 (abre a conversa por cima da fase e muda conforme a decisão).

const TALK := preload("res://cutscenes/diana/diana.tscn")
const CHOICE_BOX := preload("res://dialogue/choice_box.tscn")
const LEVEL_03 := preload("res://levels/level_03.tscn")
const TEST_SAVE := "user://test_diana.cfg"
const BESIDE_HUT := Vector2i(148, 30)
const SPEED := 6.0
const REAL_TIME_LIMIT_MS := 60000
const PRESS_EVERY := 8 ## quadros
const WAIT_LIMIT := 600 ## quadros

var _real_save_path := ""


func before_each() -> void:
	_real_save_path = Story.save_path
	Story.save_path = TEST_SAVE
	DirAccess.remove_absolute(TEST_SAVE)


func after_each() -> void:
	super()
	Engine.time_scale = 1.0
	get_tree().paused = false
	Transition.fade_in(0.0)
	DirAccess.remove_absolute(TEST_SAVE)
	Story.save_path = _real_save_path


# --- Caixa de escolhas ------------------------------------------------------------------

func test_choice_box_returns_the_confirmed_option() -> void:
	var box: ChoiceBox = CHOICE_BOX.instantiate()
	add_child_autofree(box)
	var picked := [-1]
	var ask := func() -> void: picked[0] = await box.choose(["Sim.", "Não.", "Talvez."])
	ask.call()
	assert_true(box.is_open())
	TestHelpers.tap(&"move_down")
	TestHelpers.tap(&"move_down")
	await wait_process_frames(1)
	assert_eq(box.selected(), 2)
	TestHelpers.tap(&"jump")
	await wait_process_frames(1)
	assert_eq(picked[0], 2)
	assert_false(box.is_open())


func test_choice_box_wraps_around() -> void:
	var box: ChoiceBox = CHOICE_BOX.instantiate()
	add_child_autofree(box)
	box.choose(["Sim.", "Não."])
	TestHelpers.tap(&"move_up")
	await wait_process_frames(1)
	assert_eq(box.selected(), 1, "subir da primeira leva à última")
	TestHelpers.tap(&"move_down")
	await wait_process_frames(1)
	assert_eq(box.selected(), 0)


# --- Memória da Story ---------------------------------------------------------------------

func test_story_keeps_choices_next_to_the_progress() -> void:
	assert_eq(Story.recall("diana"), "", "sem escolha, nada guardado")
	Story.remember("diana", DianaTalk.FORGIVEN)
	Story.save_progress(3)
	assert_eq(Story.recall("diana"), DianaTalk.FORGIVEN, "salvar o passo não apaga as escolhas")
	assert_eq(Story.saved_step(), 3)
	Story.forget_choices()
	assert_eq(Story.recall("diana"), "")
	assert_eq(Story.saved_step(), 3, "esquecer as escolhas não apaga o passo")


# --- A conversa ---------------------------------------------------------------------------

func test_first_answers_forgive_diana() -> void:
	assert_true(await _play_talk(false), "a conversa não terminou")
	assert_eq(Story.recall(DianaTalk.CHOICE_KEY), DianaTalk.FORGIVEN)


func test_last_answers_do_not_forgive_diana() -> void:
	assert_true(await _play_talk(true), "a conversa não terminou")
	assert_eq(Story.recall(DianaTalk.CHOICE_KEY), DianaTalk.RESENTFUL)


func test_skipping_the_talk_decides_nothing() -> void:
	var talk: DianaTalk = TALK.instantiate()
	talk.advances_story = false
	add_child_autofree(talk)
	await wait_process_frames(2)
	TestHelpers.tap(&"quit")
	await wait_process_frames(1)
	assert_true(talk.is_finished())
	assert_eq(Story.recall(DianaTalk.CHOICE_KEY), "")


# --- A cabana -----------------------------------------------------------------------------

func test_up_beside_the_hut_plays_the_talk_over_the_paused_level() -> void:
	await start_at(LEVEL_03, BESIDE_HUT)
	var hut := _hut()
	TestHelpers.tap(&"move_up")
	assert_true(await _wait_until(func() -> bool: return _talk() != null), "a conversa não abriu")
	assert_true(get_tree().paused, "a fase para enquanto eles conversam")
	TestHelpers.tap(&"quit")
	assert_true(await _wait_until(func() -> bool: return not get_tree().paused), "o jogo não voltou")
	assert_eq(Music.current(), main.level().music, "a trilha da fase volta")
	assert_true(hut.is_available(), "conversa pulada continua disponível")


func test_forgiving_gives_a_star_and_ends_the_talk() -> void:
	await start_at(LEVEL_03, BESIDE_HUT)
	var hut := _hut()
	watch_signals(main.level())
	Story.remember(DianaTalk.CHOICE_KEY, DianaTalk.FORGIVEN)
	hut.conclude()
	assert_signal_emitted(main.level(), "star_collected")
	assert_false(hut.is_available())
	assert_true((hut.get_node("Lantern") as PointLight2D).enabled, "ela continua ali")


func test_not_forgiving_leaves_the_hut_empty_and_dark() -> void:
	await start_at(LEVEL_03, BESIDE_HUT)
	var hut := _hut()
	watch_signals(main.level())
	Story.remember(DianaTalk.CHOICE_KEY, DianaTalk.RESENTFUL)
	hut.conclude()
	assert_signal_not_emitted(main.level(), "star_collected")
	assert_false(hut.is_available())
	assert_false((hut.get_node("Lantern") as PointLight2D).enabled)
	assert_eq((hut.get_node("Sprite") as Sprite2D).frame, DianaHut.FRAME_EMPTY)


func test_a_decision_already_made_is_remembered_by_the_hut() -> void:
	Story.remember(DianaTalk.CHOICE_KEY, DianaTalk.RESENTFUL)
	await start_at(LEVEL_03, BESIDE_HUT)
	assert_false(_hut().is_available())
	TestHelpers.tap(&"move_up")
	await wait_process_frames(3)
	assert_false(get_tree().paused, "sem conversa, cima não faz nada")


# --- Apoio --------------------------------------------------------------------------------

func _hut() -> DianaHut:
	return main.level().get_node("Entities/DianaHut")


## A conversa tocando por cima da fase, ou null.
func _talk() -> DianaTalk:
	for node in main.find_children("*", "Node2D", true, false):
		if node is DianaTalk:
			return node
	return null


func _wait_until(condition: Callable) -> bool:
	for frame in WAIT_LIMIT:
		if condition.call():
			return true
		await get_tree().process_frame
	return false


## Toca a conversa até o fim apertando "confirmar"; com `pick_last`, sobe da primeira (dá a volta) até a última
## resposta de cada escolha antes de confirmar.
func _play_talk(pick_last: bool) -> bool:
	var talk: DianaTalk = TALK.instantiate()
	talk.advances_story = false
	add_child_autofree(talk)
	Engine.time_scale = SPEED
	var start := Time.get_ticks_msec()
	var frame := 0
	while not talk.is_finished() and Time.get_ticks_msec() - start < REAL_TIME_LIMIT_MS:
		if frame % PRESS_EVERY == 0:
			if pick_last and talk.choices.is_open():
				TestHelpers.tap(&"move_up")
			TestHelpers.tap(&"ui_accept")
		frame += 1
		await get_tree().physics_frame
	Engine.time_scale = 1.0
	return talk.is_finished()
