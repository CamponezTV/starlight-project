extends PlaythroughTest
## Robôs jogam cada desafio da Fase 1 com controles simulados.
## Se algum quebrar depois de mexer na fase ou no "feel", o desafio ficou impossível
## (ou bem mais difícil do que o planejado).

const LEVEL_01 := preload("res://levels/level_01.tscn")


func test_held_jump_reaches_the_tall_ledge() -> void:
	await start_at(LEVEL_01, Vector2i(61, 41))
	var reached := await run_bot(func(frame: int) -> bool:
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"jump", player.global_position.x >= 62 * TILE and frame < 40)
		return standing_at_least(64, 39))
	assert_true(reached, "não subiu a borda de 3 blocos")


func test_wall_jumps_climb_the_shaft() -> void:
	await start_at(LEVEL_01, Vector2i(133, 38))
	var jump_hold := [0]
	var climb := func(_frame: int) -> bool:
		var wall := player._touching_wall(player.is_on_floor())
		var above_ledge := player.global_position.y < 19 * TILE - 2
		var direction := 1 if above_ledge or wall == -1 else (-1 if wall == 1 else (-1 if player.velocity.x < 0 else 1))
		TestHelpers.set_pressed(&"move_right", direction == 1)
		TestHelpers.set_pressed(&"move_left", direction == -1)
		if jump_hold[0] > 0:
			jump_hold[0] = (jump_hold[0] + 1) % 10
			TestHelpers.set_pressed(&"jump", jump_hold[0] > 0)
		elif not above_ledge and (player.is_on_floor() or wall != 0):
			jump_hold[0] = 1
			Input.action_press(&"jump")
		return standing_at_least(135, 19)
	var reached := await run_bot(climb, TIME_LIMIT * 2)
	assert_true(reached, "não subiu o poço")


func test_jump_and_dash_cross_the_spike_gap() -> void:
	await start_at(LEVEL_01, Vector2i(164, 18))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(167)
		dash_at_apex()
		return standing_at_least(178, 19))
	assert_true(reached, "não atravessou o vão de espinhos")


func test_up_dash_climbs_the_tall_wall() -> void:
	await start_at(LEVEL_01, Vector2i(183, 18))
	var reached := await run_bot(func(frame: int) -> bool:
		TestHelpers.set_pressed(&"jump", frame < 15)
		var rising_slow := not player.is_on_floor() and player.velocity.y > -40.0
		TestHelpers.set_pressed(&"move_up", rising_slow and player.can_dash)
		TestHelpers.set_pressed(&"dash", rising_slow and player.can_dash)
		TestHelpers.set_pressed(&"move_right", not player.can_dash)
		return standing_at_least(186, 12))
	assert_true(reached, "não subiu a parede com o dash")


func test_crystal_chain_crosses_the_spike_sea() -> void:
	await start_at(LEVEL_01, Vector2i(202, 11))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(204)
		var airborne := not player.is_on_floor()
		var wants_dash := airborne and player.can_dash and player.velocity.y > -20.0
		TestHelpers.set_pressed(&"move_up", wants_dash and player.global_position.y > 13 * TILE)
		TestHelpers.set_pressed(&"dash", wants_dash)
		return standing_at_least(237, 17))
	assert_true(reached, "não atravessou o mar de espinhos com os cristais")


func test_final_room_reaches_the_exit() -> void:
	await start_at(LEVEL_01, Vector2i(254, 16))
	var level := main.level()
	var exited := [false]
	level.exit_reached.connect(func() -> void: exited[0] = true)
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		var x := player.global_position.x
		TestHelpers.set_pressed(&"jump", (x >= 256 * TILE and x < 258 * TILE) or (x >= 263 * TILE and x < 266 * TILE))
		var near_wall := x >= 264 * TILE and x < 266 * TILE and not player.is_on_floor()
		TestHelpers.set_pressed(&"move_up", near_wall and player.velocity.y > -40.0)
		TestHelpers.set_pressed(&"dash", near_wall and player.velocity.y > -40.0 and player.can_dash)
		return exited[0])
	assert_true(reached, "não chegou à saída")
