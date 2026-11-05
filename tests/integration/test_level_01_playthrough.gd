extends GutTest
## Robôs jogam cada desafio da Fase 1 com controles simulados.
## Se algum quebrar depois de mexer na fase ou no "feel", o desafio ficou impossível
## (ou bem mais difícil do que o planejado).

const MAIN_SCENE := preload("res://main/main.tscn")
const LEVEL_01 := preload("res://levels/level_01.tscn")
const TILE := TestHelpers.TILE
const TIME_LIMIT := 480 ## quadros (8 s)

var _player: Player


func after_each() -> void:
	TestHelpers.release_all_actions()


func test_held_jump_reaches_the_tall_ledge() -> void:
	await _start_at(Vector2i(61, 41))
	var reached := await _run(func(frame: int) -> bool:
		Input.action_press(&"move_right")
		TestHelpers.set_pressed(&"jump", _player.global_position.x >= 62 * TILE and frame < 40)
		return _standing_at_least(64, 39))
	assert_true(reached, "não subiu a borda de 3 blocos")


func test_wall_jumps_climb_the_shaft() -> void:
	await _start_at(Vector2i(133, 38))
	var jump_hold := [0]
	var climb := func(_frame: int) -> bool:
		var wall := _player._touching_wall(_player.is_on_floor())
		var above_ledge := _player.global_position.y < 19 * TILE - 2
		var direction := 1 if above_ledge or wall == -1 else (-1 if wall == 1 else (-1 if _player.velocity.x < 0 else 1))
		TestHelpers.set_pressed(&"move_right", direction == 1)
		TestHelpers.set_pressed(&"move_left", direction == -1)
		if jump_hold[0] > 0:
			jump_hold[0] = (jump_hold[0] + 1) % 10
			TestHelpers.set_pressed(&"jump", jump_hold[0] > 0)
		elif not above_ledge and (_player.is_on_floor() or wall != 0):
			jump_hold[0] = 1
			Input.action_press(&"jump")
		return _standing_at_least(135, 19)
	var reached := await _run(climb, TIME_LIMIT * 2)
	assert_true(reached, "não subiu o poço")


func test_jump_and_dash_cross_the_spike_gap() -> void:
	await _start_at(Vector2i(164, 18))
	var reached := await _run(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		_jump_at_edge(167)
		_dash_at_apex()
		return _standing_at_least(178, 19))
	assert_true(reached, "não atravessou o vão de espinhos")


func test_up_dash_climbs_the_tall_wall() -> void:
	await _start_at(Vector2i(183, 18))
	var reached := await _run(func(frame: int) -> bool:
		TestHelpers.set_pressed(&"jump", frame < 15)
		var rising_slow := not _player.is_on_floor() and _player.velocity.y > -40.0
		TestHelpers.set_pressed(&"move_up", rising_slow and _player.can_dash)
		TestHelpers.set_pressed(&"dash", rising_slow and _player.can_dash)
		TestHelpers.set_pressed(&"move_right", not _player.can_dash)
		return _standing_at_least(186, 12))
	assert_true(reached, "não subiu a parede com o dash")


func test_crystal_chain_crosses_the_spike_sea() -> void:
	await _start_at(Vector2i(202, 11))
	var reached := await _run(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		_jump_at_edge(204)
		var airborne := not _player.is_on_floor()
		var wants_dash := airborne and _player.can_dash and _player.velocity.y > -20.0
		TestHelpers.set_pressed(&"move_up", wants_dash and _player.global_position.y > 13 * TILE)
		TestHelpers.set_pressed(&"dash", wants_dash)
		return _standing_at_least(237, 17))
	assert_true(reached, "não atravessou o mar de espinhos com os cristais")


func test_final_room_reaches_the_exit() -> void:
	await _start_at(Vector2i(254, 16))
	var level := _player.get_parent().get_node("LevelSlot").get_child(0) as Level
	var exited := [false]
	level.exit_reached.connect(func() -> void: exited[0] = true)
	var reached := await _run(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		var x := _player.global_position.x
		TestHelpers.set_pressed(&"jump", (x >= 256 * TILE and x < 258 * TILE) or (x >= 263 * TILE and x < 266 * TILE))
		var near_wall := x >= 264 * TILE and x < 266 * TILE and not _player.is_on_floor()
		TestHelpers.set_pressed(&"move_up", near_wall and _player.velocity.y > -40.0)
		TestHelpers.set_pressed(&"dash", near_wall and _player.velocity.y > -40.0 and _player.can_dash)
		return exited[0])
	assert_true(reached, "não chegou à saída")


# --- Infraestrutura ----------------------------------------------------------------

func _start_at(cell: Vector2i) -> void:
	var main: Main = MAIN_SCENE.instantiate()
	main.level_scene = LEVEL_01
	add_child_autofree(main)
	_player = main.get_node("Player")
	await wait_physics_frames(2)
	_player.respawn(TestHelpers.cell_feet(cell))
	await wait_physics_frames(3)


## Roda `step` a cada quadro até ele devolver true (sucesso), o Jupiter morrer ou o tempo acabar.
func _run(step: Callable, limit := TIME_LIMIT) -> bool:
	for frame in limit:
		if step.call(frame):
			return true
		if _player.is_dead():
			return false
		await get_tree().physics_frame
	return false


func _jump_at_edge(edge_column: int) -> void:
	var at_edge := _player.is_on_floor() and _player.global_position.x >= edge_column * TILE + 2
	if at_edge:
		Input.action_press(&"jump")


func _dash_at_apex() -> void:
	var at_apex := not _player.is_on_floor() and _player.velocity.y > -20.0
	TestHelpers.set_pressed(&"dash", at_apex and _player.can_dash)


## Em pé no chão, com x >= coluna e pés na linha `row` ou acima.
func _standing_at_least(column: int, row: int) -> bool:
	var p := _player.global_position
	return _player.is_on_floor() and p.x >= column * TILE and p.y <= row * TILE + 0.5
