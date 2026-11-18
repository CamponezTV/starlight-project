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
const FERRY := 370 ## A Travessia.
const FERRY_TRAVEL := 8.0 ## Blocos que a plataforma anda.
const FERRY_STAR_AT := 2.6 ## Blocos andados quando o Jupiter, em cima dela, fica embaixo da estrela.
const PLATFORM_HALF_WIDTH := 12.0 ## Metade da largura da plataforma móvel (px).
const FERRY_BOARD_AT := 2.5 ## Pula da borda quando a plataforma volta e está a menos disto.
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


func test_crossing_rides_the_platform_without_any_crystal() -> void:
	await start_at(LEVEL_01, Vector2i(FERRY + 5, 8))
	var reached := await run_bot(_ferry_ride(func() -> void:
		# Do fim da plataforma: corre até a beirada dela, pula segurando e dá dash no alto.
		var edge := (main.level().get_node("Platforms").get_child(0) as Node2D).global_position.x + PLATFORM_HALF_WIDTH - 1.0
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"jump", (player.is_on_floor() and player.global_position.x >= edge) or (not player.is_on_floor() and player.velocity.y < 0.0))
		dash_at_apex()
		, FERRY_TRAVEL - 0.5), TIME_LIMIT * 2)
	assert_true(reached and standing_at_least(FERRY + 31, 9), "não atravessou a Travessia só com a plataforma")


func test_crossing_star_takes_a_jump_and_an_up_dash_from_the_platform() -> void:
	await start_at(LEVEL_01, Vector2i(FERRY + 5, 8))
	var star := _star("EstrelaTravessia")
	var platform := main.level().get_node("Platforms").get_child(0) as Node2D
	var state := {"jumped": false}
	var reached := await run_bot(_ferry_ride(func() -> void:
		# Embaixo da estrela: pulo segurado e dash para cima no alto dele. Na descida,
		# acompanha a plataforma para cair de novo em cima dela.
		# Um pulo só: de volta na plataforma, fica parado até a estrela ser guardada.
		if not player.is_on_floor():
			state["jumped"] = true
		var rising := not player.is_on_floor() and player.velocity.y < 0.0
		TestHelpers.set_pressed(&"jump", (player.is_on_floor() and not state["jumped"]) or rising)
		var rising_slow := not player.is_on_floor() and player.velocity.y > -40.0
		TestHelpers.set_pressed(&"move_up", rising_slow and player.can_dash)
		TestHelpers.set_pressed(&"dash", rising_slow and player.can_dash)
		var falling := not player.is_on_floor() and player.velocity.y > 0.0
		TestHelpers.set_pressed(&"move_right", falling and player.global_position.x < platform.global_position.x)
		TestHelpers.set_pressed(&"move_left", falling and player.global_position.x > platform.global_position.x + PLATFORM_HALF_WIDTH)
		, FERRY_STAR_AT, func() -> bool: return star.is_secured()), TIME_LIMIT * 2)
	assert_true(reached, "a estrela da Travessia deveria ser alcançável da plataforma")


func test_leap_crosses_one_crystal_and_the_sprout_reaches_the_door() -> void:
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


func test_leap_star_takes_the_sprout_and_an_up_dash() -> void:
	await start_at(LEVEL_01, Vector2i(LEAP + 3, 8))
	var chain := _crystal_chain(LEAP + 5, 10, func() -> bool: return false)
	var reached := await run_bot(func(frame: int) -> bool:
		var over_sprout := player.global_position.x > (LEAP + 31) * TILE
		if not over_sprout:
			chain.call(frame)
		else:
			# Lançado pelo broto: dash para cima no alto do impulso, depois a borda da porta.
			var rising_slow := not player.is_on_floor() and player.velocity.y > -60.0
			Input.action_press(&"move_right")
			TestHelpers.set_pressed(&"move_up", rising_slow and player.can_dash)
			TestHelpers.set_pressed(&"dash", rising_slow and player.can_dash)
		return _star("EstrelaSalto").is_secured(), TIME_LIMIT * 2)
	assert_true(reached, "a estrela do Salto deveria ser alcançável e guardada do outro lado")


## Espera a plataforma da Travessia chegar perto da borda, sobe nela e, quando ela já andou
## `ride_to` blocos, chama `act` a cada quadro. Termina quando `done` devolve true (por
## padrão, em pé na borda da direita).
func _ferry_ride(act: Callable, ride_to: float, done := Callable()) -> Callable:
	var platform := main.level().get_node("Platforms").get_child(0) as Node2D
	var origin := platform.position.x
	var state := {"boarded": false, "jumping": false, "airborne": false, "acting": false, "last": 0.0}
	return func(_frame: int) -> bool:
		var travelled := (platform.position.x - origin) / TILE
		var returning := travelled < float(state["last"])
		state["last"] = travelled
		if not state["boarded"]:
			# Pula (segurando) quando a plataforma volta para perto da borda: chega nela a tempo.
			if not state["jumping"] and returning and travelled < FERRY_BOARD_AT and player.is_on_floor():
				state["jumping"] = true
			if state["jumping"] and not player.is_on_floor():
				state["airborne"] = true
			TestHelpers.set_pressed(&"move_right", state["jumping"])
			TestHelpers.set_pressed(&"jump", state["jumping"] and (not state["airborne"] or player.velocity.y < 0.0))
			if state["airborne"] and player.is_on_floor():
				state["boarded"] = true
				TestHelpers.release_all_actions()
		elif state["acting"] or travelled >= ride_to:
			# Em cima da plataforma o "no chão" oscila: só age depois de andar o trecho.
			state["acting"] = true
			act.call()
		if done.is_valid():
			return done.call()
		return standing_at_least(FERRY + 31, 9)


func _star(star_name: String) -> StarPickup:
	return main.level().get_node("Entities").get_node(star_name) as StarPickup
