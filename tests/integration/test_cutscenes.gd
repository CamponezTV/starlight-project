extends GutTest
## Cada cutscene roda até o fim com alguém apertando "pular" (e subindo a montanha no
## prólogo jogável). O tempo do jogo é acelerado para o teste não demorar.

const SPEED := 6.0
const REAL_TIME_LIMIT_MS := 60000
const MAX_DIALOGUE_LINES := 2
const STATIC_CUTSCENES := [
	"res://cutscenes/stargazing/stargazing.tscn",
	"res://cutscenes/hospital/hospital.tscn",
	"res://cutscenes/funeral/funeral.tscn",
	"res://cutscenes/sophie_memory/sophie_memory.tscn",
	"res://cutscenes/after_sophie/after_sophie.tscn",
	"res://cutscenes/spider_memory/spider_memory.tscn",
	"res://cutscenes/finale/reunion.tscn",
	"res://cutscenes/finale/morning.tscn",
]
const MOUNTAIN := "res://cutscenes/mountain/mountain.tscn"
const PRESS_EVERY := 8 ## quadros
const JUMP_HOLD := 12 ## quadros segurando o pulo, a cada PRESS_EVERY * 4


func after_each() -> void:
	Engine.time_scale = 1.0
	TestHelpers.release_all_actions()
	Transition.fade_in(0.0)


func test_static_cutscenes_play_to_the_end() -> void:
	for path: String in STATIC_CUTSCENES:
		assert_true(await _play(path, false), "%s não terminou" % path)


func test_mountain_prologue_ends_with_the_fall_into_the_hole() -> void:
	assert_true(await _play(MOUNTAIN, true), "o Jupiter não chegou ao buraco")


func test_escape_skips_a_cutscene() -> void:
	var cutscene: Cutscene = (load(STATIC_CUTSCENES[0]) as PackedScene).instantiate()
	cutscene.advances_story = false
	add_child_autofree(cutscene)
	await wait_process_frames(2)
	TestHelpers.tap(&"quit")
	await wait_process_frames(1)
	assert_true(cutscene.is_finished())


## Toda fala escrita nos roteiros cabe na caixa de diálogo (duas linhas).
func test_every_line_fits_the_dialogue_box() -> void:
	var box: DialogueBox = (load("res://dialogue/dialogue_box.tscn") as PackedScene).instantiate()
	add_child_autofree(box)
	var label := box.get_node("%Text") as Label
	var pattern := RegEx.create_from_string("say\\(\\w+, \"((?:[^\"\\\\]|\\\\.)*)\"\\)")
	var checked := 0
	for path: String in STATIC_CUTSCENES + [MOUNTAIN]:
		var source := FileAccess.get_file_as_string(path.replace(".tscn", ".gd"))
		for found in pattern.search_all(source):
			label.text = found.get_string(1).c_unescape()
			checked += 1
			assert_lte(label.get_line_count(), MAX_DIALOGUE_LINES, "não cabe: %s" % label.text)
	assert_gt(checked, 100, "deveria ter achado as falas dos roteiros")


func _play(path: String, walk_right: bool) -> bool:
	var cutscene: Cutscene = (load(path) as PackedScene).instantiate()
	cutscene.advances_story = false
	add_child_autofree(cutscene)
	Engine.time_scale = SPEED
	var start := Time.get_ticks_msec()
	var frame := 0
	while not cutscene.is_finished() and Time.get_ticks_msec() - start < REAL_TIME_LIMIT_MS:
		if frame % PRESS_EVERY == 0:
			TestHelpers.tap(&"ui_accept")
		if walk_right:
			Input.action_press(&"move_right")
			TestHelpers.set_pressed(&"jump", frame % (PRESS_EVERY * 4) < JUMP_HOLD)
		frame += 1
		await get_tree().physics_frame
	Engine.time_scale = 1.0
	return cutscene.is_finished()
