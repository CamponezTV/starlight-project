extends GutTest
## O fim de fase: o portal puxa o Jupiter e o resumo (LevelComplete) espera o jogador
## confirmar. E o holofote de habilidade (SkillShowcase) sozinho.

const MAIN_SCENE := preload("res://main/main.tscn")
const TEST_ROOM := preload("res://levels/test_room.tscn")
const LEVEL_COMPLETE := preload("res://ui/level_complete.tscn")
const SKILL_SHOWCASE := preload("res://ui/skill_showcase.tscn")
const SPEED := 8.0
const PRESS_EVERY := 8 ## quadros
const WAIT_LIMIT := 900 ## quadros


func before_each() -> void:
	TestHelpers.use_test_save()
	Engine.time_scale = SPEED


func after_each() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	TestHelpers.release_all_actions()
	TestHelpers.restore_save()


func test_time_is_shown_as_minutes_and_seconds() -> void:
	assert_eq(LevelComplete.format_time(0.0), "0:00")
	assert_eq(LevelComplete.format_time(59.9), "0:59")
	assert_eq(LevelComplete.format_time(187.0), "3:07")


func test_summary_shows_the_run_and_waits_for_the_player() -> void:
	var screen: LevelComplete = LEVEL_COMPLETE.instantiate()
	add_child_autofree(screen)
	var summary := LevelSummary.new()
	summary.title = "A Queda"
	summary.message = "Para uma lembrança."
	summary.stars_found = 2
	summary.star_total = 6
	summary.deaths = 12
	summary.seconds = 187.0
	var state := {"done": false}
	var show := func() -> void:
		await screen.present(summary, Vector2(160, 90))
		state["done"] = true
	show.call()
	assert_true(screen.is_open())
	assert_eq((screen.get_node("Card/Title") as Label).text, "A Queda")
	assert_string_contains((screen.get_node("Card/Stats") as Label).text, "12")
	assert_string_contains((screen.get_node("Card/Stats") as Label).text, "3:07")
	await wait_physics_frames(2)
	assert_eq(screen.get_node("Card/Stars").get_child_count(), 6, "um ícone por estrela da fase")
	TestHelpers.tap(&"jump")
	await wait_physics_frames(2)
	assert_false(state["done"], "antes de o resumo aparecer inteiro, o botão não vale")
	await _press_until(func() -> bool: return state["done"])
	assert_true(state["done"], "confirmar fecha o resumo")
	var lit := screen.get_node("Card/Stars").get_children().filter(
		func(icon: TextureRect) -> bool: return icon.texture == screen.full_star)
	assert_eq(lit.size(), 2, "só as estrelas guardadas acendem")


func test_showcase_names_the_skill_and_waits_for_the_player() -> void:
	var showcase: SkillShowcase = SKILL_SHOWCASE.instantiate()
	add_child_autofree(showcase)
	assert_false(showcase.is_open())
	var skill := Skill.new()
	skill.title = "DASH"
	skill.description = "O broche do vovô acende."
	skill.controls = "X + uma direção"
	var state := {"done": false}
	var show := func() -> void:
		await showcase.present(skill, Vector2(160, 120))
		state["done"] = true
	show.call()
	assert_true(showcase.is_open())
	assert_eq((showcase.get_node("Text/Title") as Label).text, "DASH")
	assert_eq((showcase.get_node("Text/Controls") as Label).text, "X + uma direção")
	await _press_until(func() -> bool: return state["done"])
	assert_true(state["done"])
	assert_false(showcase.is_open())


func test_the_portal_pulls_jupiter_in_and_the_summary_opens() -> void:
	var main: Main = MAIN_SCENE.instantiate()
	main.level_scene = TEST_ROOM
	add_child_autofree(main)
	var player := main.get_node("Player") as Player
	var screen := main.get_node("LevelComplete") as LevelComplete
	await wait_physics_frames(3)
	var exit := main.level().exit()
	player.respawn(exit.global_position)
	await _wait_until(screen.is_open)
	assert_true(screen.is_open(), "o resumo aparece depois que o portal puxa o Jupiter")
	assert_almost_eq(player.global_position, exit.core(), Vector2(1, 1), "o Jupiter termina no meio do véu")
	assert_lt(player.scale.x, 0.5, "e encolhe para dentro da luz")
	assert_false(player.controllable)


func _press_until(done: Callable) -> void:
	for frame in WAIT_LIMIT:
		if done.call():
			return
		if frame % PRESS_EVERY == 0:
			TestHelpers.tap(&"jump")
		await get_tree().process_frame


func _wait_until(done: Callable) -> void:
	for frame in WAIT_LIMIT:
		if done.call():
			return
		await get_tree().process_frame
