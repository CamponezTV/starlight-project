extends PlaythroughTest
## Robôs jogam cada desafio da Fase 2 (Ecos) com controles simulados.
## Se algum quebrar depois de mexer na fase ou no "feel", o desafio ficou impossível
## (ou bem mais difícil do que o planejado).

const LEVEL_02 := preload("res://levels/level_02.tscn")
const JUMP_HOLD_FRAMES := 14
const RESPAWN_WAIT := 0.8 ## Mais que Main.RESPAWN_DELAY.
const DELAY_STEP := 6 ## quadros entre uma espera testada e a próxima.
## Nas salas com ritmo, a fração mínima de esperas que precisa dar certo: o desafio é
## apertado, mas não pode depender de um único quadro.
const MIN_WINDOW := 0.1


func test_jumps_across_the_broken_bridge() -> void:
	await start_at(LEVEL_02, Vector2i(10, 41))
	var reached := await run_bot(_hopper([19], func() -> bool: return standing_at_least(29, 42)))
	assert_true(reached, "não atravessou a ponte quebrada")


## As rochas da escada caem rápido: só sobe quem pula de um degrau para o outro sem parar.
func test_climbs_the_crumbling_staircase() -> void:
	await start_at(LEVEL_02, Vector2i(42, 41))
	var reached := await run_bot(_hopper([45, 50, 56, 62, 68, 73], func() -> bool: return standing_at_least(75, 34)), TIME_LIMIT * 2)
	assert_true(reached, "não subiu a escada de rochas frágeis")


func test_voice_breaks_the_first_barrier() -> void:
	await start_at(LEVEL_02, Vector2i(86, 41))
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"dash", player.has_voice and player.global_position.x >= 100 * TILE)
		return standing_at_least(108, 42))
	assert_true(reached, "não quebrou a primeira barreira")


## A orbe flutua sobre o poço: pega no pulo, dash na barreira no ar, pousa na ponte curta
## e pula o último buraco.
func test_grabs_the_voice_midair_and_dashes_through_the_barrier() -> void:
	await start_at(LEVEL_02, Vector2i(122, 41))
	var hop := _hopper([129, 144], func() -> bool: return standing_at_least(148, 42))
	var reached := await run_bot(func(frame: int) -> bool:
		if player.has_voice:
			dash_at_apex()
		return hop.call(frame))
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


## Pontes de duas rochas: o pulo inteiro passa direto; é preciso soltar a direção no ar.
func test_crosses_the_short_bridges() -> void:
	await start_at(LEVEL_02, Vector2i(203, 11))
	var reached := await run_bot(_hopper([210, 217, 223], func() -> bool: return standing_at_least(228, 20), [216, 222]), TIME_LIMIT * 2)
	assert_true(reached, "não atravessou as pontes curtas")


## O Coro: três sussurros sobem e descem em onda no caminho dos pulos. Só passa quem sai
## na hora certa, e com a voz guardada para a barreira do fim.
func test_the_choir_lets_through_who_waits_for_the_wave() -> void:
	await start_at(LEVEL_02, Vector2i(243, 19))
	var window := await _window(Vector2i(243, 19), 2.0, func() -> Callable:
		var hop := _hopper([245, 249, 256, 264, 271], func() -> bool: return standing_at_least(278, 20))
		return func(frame: int) -> bool:
			TestHelpers.set_pressed(&"dash", player.has_voice and player.is_on_floor() and player.global_position.x >= 272 * TILE)
			return hop.call(frame))
	gut.p("O Coro: %d%% das esperas passam" % roundi(window * 100.0))
	assert_gt(window, MIN_WINDOW, "a onda não deixa passar (ou só num quadro)")
	assert_lt(window, 0.9, "a onda não atrapalha ninguém")


## O Silêncio: o broto joga para cima, um dash leva até a plataforma, e dela só um cristal
## no caminho até o portal: dash, cristal, dash.
func test_the_last_room_needs_the_platform_and_the_crystal() -> void:
	await start_at(LEVEL_02, Vector2i(282, 19))
	var exited := [false]
	main.level().exit_reached.connect(func() -> void: exited[0] = true)
	var window := await _window(Vector2i(282, 19), 4.0, func() -> Callable:
		return func(_frame: int) -> bool:
			Input.action_press(&"move_right")
			var on_platform := player.is_on_floor() and player.global_position.x > 288 * TILE
			TestHelpers.set_pressed(&"jump", on_platform)
			var past_crystal := player.global_position.x > 304 * TILE
			var at_apex := player.velocity.y > -20.0
			TestHelpers.set_pressed(&"dash", not player.is_on_floor() and player.can_dash and (past_crystal or at_apex))
			return exited[0] or standing_at_least(314, 20))
	gut.p("O Silêncio: %d%% das esperas passam" % roundi(window * 100.0))
	assert_gt(window, 0.0, "não chegou ao portal")


# --- Apoio --------------------------------------------------------------------------------

## Robô que corre para a direita e pula (segurando) ao chegar em cada borda, uma vez cada,
## até `done` dizer que chegou. Com `landings`, depois do pulo da borda i ele solta a
## direção quando passa da coluna landings[i], para não passar direto de um pouso curto.
func _hopper(edges: Array, done: Callable, landings: Array = []) -> Callable:
	var state := {"next": 0, "hold": 0}
	return func(_frame: int) -> bool:
		var jumped: int = state["next"] - 1
		var braking: bool = not player.is_on_floor() and jumped >= 0 and jumped < landings.size() 			and player.global_position.x >= landings[jumped] * TILE
		TestHelpers.set_pressed(&"move_right", not braking)
		var next: int = state["next"]
		if next < edges.size() and player.is_on_floor() and player.global_position.x >= edges[next] * TILE + 2:
			state["next"] = next + 1
			state["hold"] = JUMP_HOLD_FRAMES
		state["hold"] = maxi(state["hold"] - 1, 0)
		TestHelpers.set_pressed(&"jump", state["hold"] > 0)
		return done.call()


## Tenta a sala várias vezes, esperando cada vez um pouco mais (de 0 a `span` segundos)
## antes de soltar o robô que `make_bot` cria. Devolve a fração de tentativas que chegaram.
func _window(start: Vector2i, span: float, make_bot: Callable) -> float:
	var tries := 0
	var successes := 0
	for wait in range(0, roundi(span * Engine.physics_ticks_per_second), DELAY_STEP):
		TestHelpers.release_all_actions()
		if player.is_dead():
			await wait_seconds(RESPAWN_WAIT)
		player.respawn(TestHelpers.cell_feet(start))
		main.level().reset_entities()
		if wait > 0:
			await wait_physics_frames(wait)
		tries += 1
		if await run_bot(make_bot.call(), TIME_LIMIT):
			successes += 1
	TestHelpers.release_all_actions()
	return float(successes) / tries
