extends PlaythroughTest
## Salas novas das fases 2 e 3 (robôs), o dash como habilidade e os enfeites que não
## nascem em cima de objetos.

const MAIN := preload("res://main/main.tscn")
const LEVEL_01 := preload("res://levels/level_01.tscn")
const LEVEL_02 := preload("res://levels/level_02.tscn")
const LEVEL_03 := preload("res://levels/level_03.tscn")
const BROOCH_CELL := Vector2i(163, 18)
const JUMP_HOLD := 14


func test_dash_is_locked_until_the_brooch_is_found() -> void:
	var game: Main = MAIN.instantiate()
	game.level_scene = LEVEL_01
	add_child_autofree(game)
	var jupiter := game.get_node("Player") as Player
	await wait_physics_frames(3)
	assert_false(jupiter.dash_unlocked, "a Fase 1 começa sem dash")
	Input.action_press(&"dash")
	await wait_physics_frames(2)
	assert_false(jupiter.is_dashing())
	Input.action_release(&"dash")
	watch_signals(game.level())
	jupiter.respawn(TestHelpers.cell_feet(BROOCH_CELL))
	await wait_physics_frames(3)
	assert_true(jupiter.dash_unlocked, "o broche ensina o dash")
	assert_signal_emitted(game.level(), "skill_unlocked")


func test_decor_never_grows_on_objects() -> void:
	for scene: PackedScene in [LEVEL_01, LEVEL_02, LEVEL_03]:
		var level: Level = scene.instantiate()
		add_child_autofree(level)
		var decorated := (level.get_node("Terrain/Decor") as TerrainDecor).decorated_cells()
		assert_eq(decorated.size(), _unique(decorated).size(), "%s: dois enfeites na mesma célula" % level.name)
		for entity in level.get_node("Entities").get_children():
			var feet := Vector2i(((entity as Node2D).position + Vector2(0, -1)) / TILE)
			assert_false(decorated.has(feet), "%s: enfeite em cima de %s" % [level.name, entity.name])


func test_level_02_choir_room_hops_and_breaks_the_last_barrier() -> void:
	await start_at(LEVEL_02, Vector2i(242, 19))
	var reached := await run_bot(_runner([245, 249, 256, 264], 273.0, func() -> bool: return standing_at_least(276, 20)), TIME_LIMIT * 2)
	assert_true(reached, "não passou pela sala do coro")


func test_level_03_knot_room_reaches_the_exit() -> void:
	await start_at(LEVEL_03, Vector2i(244, 10))
	var exited := [false]
	main.level().exit_reached.connect(func() -> void: exited[0] = true)
	var reached := await run_bot(_runner([], 269.5, func() -> bool: return exited[0]), TIME_LIMIT * 2)
	assert_true(reached, "não chegou à saída da Fase 3")


func test_every_level_has_a_backdrop() -> void:
	for step in Story.steps:
		if step.kind == StoryStep.Kind.LEVEL:
			var level: Level = step.scene.instantiate()
			add_child_autofree(level)
			assert_true(level.get_node_or_null("Backdrop") is Backdrop, "%s sem fundo" % level.name)


func test_level_01_sprouts_reach_the_high_ledge() -> void:
	await start_at(LEVEL_01, Vector2i(292, 16))
	var reached := await run_bot(_runner([], 999.0, func() -> bool: return standing_at_least(306, 9)), TIME_LIMIT)
	assert_true(reached, "os dois brotos deveriam levar até a borda alta")


func test_level_01_exit_is_at_the_end_of_the_crossing() -> void:
	await start_at(LEVEL_01, Vector2i(363, 8))
	watch_signals(main.level())
	Input.action_press(&"move_right")
	await wait_physics_frames(40)
	assert_signal_emitted(main.level(), "exit_reached")


## Robô que corre para a direita, pula (segurando) em cada borda de `edges` e, com a voz,
## dá dash no chão depois da coluna `dash_from`. Termina quando `done` devolve true.
func _runner(edges: Array, dash_from: float, done: Callable) -> Callable:
	var state := {"next": 0, "hold": 0}
	return func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		var next: int = state["next"]
		if next < edges.size() and player.is_on_floor() and player.global_position.x >= edges[next] * TILE + 2:
			state["next"] = next + 1
			state["hold"] = JUMP_HOLD
		state["hold"] = maxi(state["hold"] - 1, 0)
		TestHelpers.set_pressed(&"jump", state["hold"] > 0)
		TestHelpers.set_pressed(&"dash", player.has_voice and player.is_on_floor() and player.global_position.x >= dash_from * TILE)
		return done.call()


func _unique(cells: Array[Vector2i]) -> Dictionary:
	var result := {}
	for cell in cells:
		result[cell] = true
	return result
