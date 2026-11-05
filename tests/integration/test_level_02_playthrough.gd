extends PlaythroughTest
## Robôs jogam cada desafio da Fase 2 (Ecos) com controles simulados.
## Se algum quebrar depois de mexer na fase ou no "feel", o desafio ficou impossível
## (ou bem mais difícil do que o planejado).

const LEVEL_02 := preload("res://levels/level_02.tscn")
const JUMP_HOLD_FRAMES := 14


func test_runs_across_the_first_crumbling_bridge() -> void:
	await start_at(LEVEL_02, Vector2i(10, 41))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		return standing_at_least(29, 42))
	assert_true(reached, "não atravessou a ponte frágil")


func test_climbs_the_crumbling_staircase() -> void:
	await start_at(LEVEL_02, Vector2i(42, 41))
	var reached := await run_bot(_jump_at_edges([45, 50, 56, 62, 68, 73]).bind(), TIME_LIMIT * 2)
	assert_true(reached or standing_at_least(75, 34), "não subiu a escada de rochas frágeis")


func test_voice_breaks_the_first_barrier() -> void:
	await start_at(LEVEL_02, Vector2i(86, 41))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"dash", player.has_voice and player.global_position.x >= 100 * TILE)
		return standing_at_least(108, 42))
	assert_true(reached, "não quebrou a primeira barreira")


func test_jump_and_dash_with_voice_over_the_pit() -> void:
	await start_at(LEVEL_02, Vector2i(122, 41))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(131)
		if player.has_voice:
			dash_at_apex()
		return standing_at_least(148, 42))
	assert_true(reached, "não passou a barreira sobre o poço")


## Sobe o poço pulando de parede em parede, pega a voz no caminho e quebra a barreira do topo.
func test_climbs_the_shaft_and_breaks_the_top_barrier() -> void:
	await start_at(LEVEL_02, Vector2i(169, 41))
	var jump_hold := [0]
	var reached := await run_bot(func(_frame: int) -> bool:
		var in_corridor := player.global_position.y <= 12 * TILE
		var wall := player._touching_wall(player.is_on_floor())
		var direction := 1 if in_corridor or wall == -1 else (-1 if wall == 1 else (-1 if player.velocity.x < 0 else 1))
		TestHelpers.set_pressed(&"move_right", direction == 1)
		TestHelpers.set_pressed(&"move_left", direction == -1)
		TestHelpers.set_pressed(&"dash", in_corridor and player.has_voice and player.can_dash)
		if jump_hold[0] > 0:
			jump_hold[0] = (jump_hold[0] + 1) % 10
			TestHelpers.set_pressed(&"jump", jump_hold[0] > 0)
		elif not in_corridor and (player.is_on_floor() or wall != 0):
			jump_hold[0] = 1
			Input.action_press(&"jump")
		return standing_at_least(180, 12), TIME_LIMIT * 3)
	assert_true(reached, "não subiu o poço e quebrou a barreira do topo")


func test_final_bridges_reach_the_exit() -> void:
	await start_at(LEVEL_02, Vector2i(203, 11))
	var exited := [false]
	main.level().exit_reached.connect(func() -> void: exited[0] = true)
	var reached := await run_bot(_jump_at_edges([211, 218, 224]).bind(), TIME_LIMIT * 2)
	assert_true(reached or exited[0], "não chegou à saída")


## Robô que corre para a direita e pula (segurando) ao chegar em cada borda, uma vez cada.
## Termina quando o Jupiter fica em pé depois da última borda, ou quando a fase acaba.
func _jump_at_edges(edges: Array) -> Callable:
	var state := {"next": 0, "hold": 0}
	return func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		var next: int = state["next"]
		if next < edges.size() and player.is_on_floor() and player.global_position.x >= edges[next] * TILE + 2:
			state["next"] = next + 1
			state["hold"] = JUMP_HOLD_FRAMES
		state["hold"] = maxi(state["hold"] - 1, 0)
		TestHelpers.set_pressed(&"jump", state["hold"] > 0)
		var last_edge: int = edges[-1]
		return state["next"] == edges.size() and player.is_on_floor() and player.global_position.x > (last_edge + 2) * TILE
