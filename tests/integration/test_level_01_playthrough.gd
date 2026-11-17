extends PlaythroughTest
## Robôs jogam cada desafio da Fase 1 com controles simulados.
## Se algum quebrar depois de mexer na fase ou no "feel", o desafio ficou impossível
## (ou bem mais difícil do que o planejado).

const LEVEL_01 := preload("res://levels/level_01.tscn")
## Primeira coluna de cada sala (as células dos testes são contadas a partir dela).
const SANCTUARY := 160
const GAP := 200
const CRYSTALS := 240
const LIGHT := 290
const LEAP := 410
const PORTAL := 450
const JUMP_HOLD := 15 ## quadros


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


func test_sanctuary_ledge_is_out_of_reach_without_the_dash() -> void:
	await start_at(LEVEL_01, Vector2i(SANCTUARY + 24, 18))
	player.dash_unlocked = false
	var reached := await run_bot(func(frame: int) -> bool:
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"jump", frame % 40 < JUMP_HOLD)
		return standing_at_least(SANCTUARY + 27, 14), TIME_LIMIT / 2)
	assert_false(reached, "sem o broche, a borda do Santuário não pode ser alcançada")


func test_up_dash_leaves_the_sanctuary() -> void:
	await start_at(LEVEL_01, Vector2i(SANCTUARY + 24, 18))
	var reached := await run_bot(_up_dash_then_right(SANCTUARY + 27, 14))
	assert_true(reached, "o dash para cima deveria alcançar a borda do Santuário")


func test_jump_and_dash_cross_the_spike_gap() -> void:
	await start_at(LEVEL_01, Vector2i(GAP + 4, 18))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(GAP + 7)
		dash_at_apex()
		return standing_at_least(GAP + 18, 19))
	assert_true(reached, "não atravessou o vão de espinhos")


func test_up_dash_climbs_the_tall_wall() -> void:
	await start_at(LEVEL_01, Vector2i(GAP + 23, 18))
	var reached := await run_bot(_up_dash_then_right(GAP + 26, 12))
	assert_true(reached, "não subiu a parede com o dash")


func test_crystal_chain_crosses_the_spike_sea() -> void:
	await start_at(LEVEL_01, Vector2i(CRYSTALS + 2, 11))
	var reached := await run_bot(_crystal_chain(CRYSTALS + 4, 13, func() -> bool: return standing_at_least(CRYSTALS + 37, 17)))
	assert_true(reached, "não atravessou o mar de espinhos com os cristais")


func test_light_room_is_crossed_with_jumps_and_an_up_dash() -> void:
	await start_at(LEVEL_01, Vector2i(LIGHT + 4, 16))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		var x := player.global_position.x
		TestHelpers.set_pressed(&"jump", (x >= (LIGHT + 6) * TILE and x < (LIGHT + 8) * TILE) or (x >= (LIGHT + 13) * TILE and x < (LIGHT + 16) * TILE))
		var near_wall := x >= (LIGHT + 14) * TILE and x < (LIGHT + 16) * TILE and not player.is_on_floor()
		TestHelpers.set_pressed(&"move_up", near_wall and player.velocity.y > -40.0)
		TestHelpers.set_pressed(&"dash", near_wall and player.velocity.y > -40.0 and player.can_dash)
		return standing_at_least(LIGHT + 34, 17))
	assert_true(reached, "não atravessou a sala da luz")


func test_leap_crosses_three_crystals_and_the_sprout_reaches_the_door() -> void:
	await start_at(LEVEL_01, Vector2i(LEAP + 3, 8))
	var reached := await run_bot(_crystal_chain(LEAP + 5, 10, func() -> bool: return standing_at_least(LEAP + 36, 11)), TIME_LIMIT * 2)
	assert_true(reached, "não atravessou o Salto")


func test_portal_hall_ends_the_level() -> void:
	await start_at(LEVEL_01, Vector2i(PORTAL + 2, 10))
	watch_signals(main.level())
	var exited := [false]
	main.level().exit_reached.connect(func() -> void: exited[0] = true)
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(PORTAL + 21)
		return exited[0])
	assert_true(reached, "não chegou ao portal")


## Pula segurando, dá dash para cima perto do topo do pulo e depois anda para a direita.
func _up_dash_then_right(column: int, row: int) -> Callable:
	return func(frame: int) -> bool:
		TestHelpers.set_pressed(&"jump", frame < JUMP_HOLD)
		var rising_slow := not player.is_on_floor() and player.velocity.y > -40.0
		TestHelpers.set_pressed(&"move_up", rising_slow and player.can_dash)
		TestHelpers.set_pressed(&"dash", rising_slow and player.can_dash)
		TestHelpers.set_pressed(&"move_right", not player.can_dash)
		return standing_at_least(column, row)


## Corre, pula na coluna `edge` e dá dash sempre que tem um no ar (para cima se já caiu
## abaixo da linha `low_row`). Os cristais recarregam o dash pelo caminho.
func _crystal_chain(edge: int, low_row: int, done: Callable) -> Callable:
	return func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(edge)
		var wants_dash := not player.is_on_floor() and player.can_dash and player.velocity.y > -20.0
		TestHelpers.set_pressed(&"move_up", wants_dash and player.global_position.y > low_row * TILE)
		TestHelpers.set_pressed(&"dash", wants_dash)
		return done.call()


# --- Estrelas perdidas: cada desvio é possível e termina em chão firme ---------------------

func test_spike_pit_star_is_kept_after_the_jump() -> void:
	await start_at(LEVEL_01, Vector2i(93, 38))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"jump", player.global_position.x >= 94 * TILE + 4 and not _star("EstrelaEspinhos").is_secured())
		return _star("EstrelaEspinhos").is_secured())
	assert_true(reached, "a estrela sobre os espinhos deveria ser guardada do outro lado")


func test_leap_star_takes_a_diagonal_dash_off_the_last_crystal() -> void:
	await start_at(LEVEL_01, Vector2i(LEAP + 3, 8))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		jump_at_edge(LEAP + 5)
		var past_last_crystal := player.global_position.x > (LEAP + 24) * TILE
		var wants_dash := not player.is_on_floor() and player.can_dash and player.velocity.y > -20.0
		TestHelpers.set_pressed(&"move_up", wants_dash and (past_last_crystal or player.global_position.y > 10 * TILE))
		TestHelpers.set_pressed(&"dash", wants_dash)
		return _star("EstrelaSalto").is_secured(), TIME_LIMIT * 2)
	assert_true(reached, "a estrela do Salto deveria ser alcançável e guardada do outro lado")


func _star(star_name: String) -> StarPickup:
	return main.level().get_node("Entities").get_node(star_name) as StarPickup
