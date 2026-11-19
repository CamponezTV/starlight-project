extends GutTest
## O ciclo de jogo na cena principal inteira: estrelas perdidas, espinhos, checkpoints,
## cristais, morte (a sala recomeça, sem contar vidas) e a saída.

const MAIN_SCENE := preload("res://main/main.tscn")
const TEST_ROOM := preload("res://levels/test_room.tscn")
const RESPAWN_WAIT := 1.0
const SECURE_FRAMES := 30 ## Mais que StarPickup.SAFE_GROUND_TIME no chão.

## Células da sala de teste.
const STAR_CELL := Vector2i(30, 19)
const CHECKPOINT_CELL := Vector2i(40, 23)
const ABOVE_SPIKES_CELL := Vector2i(25, 25)
const CRYSTAL_CELL := Vector2i(78, 7)
const EXIT_CELL := Vector2i(96, 9)

var _main: Main
var _player: Player
var _level: Level


func before_each() -> void:
	TestHelpers.use_test_save()


func after_each() -> void:
	TestHelpers.release_all_actions()
	TestHelpers.restore_save()


func test_a_touched_star_follows_but_is_not_kept_in_the_air() -> void:
	await _start_game()
	var star := _star_at(STAR_CELL)
	_player.respawn(TestHelpers.cell_feet(STAR_CELL))
	await wait_physics_frames(2)
	assert_true(star.is_following(), "a estrela tocada segue o Jupiter")
	assert_eq(_level.stars_found(), 0, "no ar ela ainda não está guardada")


func test_a_star_is_kept_on_firm_ground() -> void:
	await _start_game()
	watch_signals(_level)
	var star := await _carry_star_to_the_ground()
	assert_true(star.is_secured())
	assert_signal_emitted(_level, "star_collected")
	assert_eq(_level.stars_found(), 1)


func test_dying_sends_a_carried_star_back() -> void:
	await _start_game()
	var star := _star_at(STAR_CELL)
	var home := star.global_position
	_player.respawn(TestHelpers.cell_feet(STAR_CELL))
	await wait_physics_frames(2)
	_player.die()
	await wait_seconds(RESPAWN_WAIT)
	assert_false(star.is_following())
	assert_eq(star.global_position, home, "a estrela volta para o lugar")
	assert_eq(_level.stars_found(), 0)


func test_a_kept_star_survives_death_but_not_the_next_visit() -> void:
	await _start_game()
	var star := await _carry_star_to_the_ground()
	_player.die()
	await wait_seconds(RESPAWN_WAIT)
	assert_true(star.is_secured(), "morrer não devolve uma estrela guardada")
	assert_eq(_level.stars_found(), 1)
	_main.queue_free()
	await wait_physics_frames(2)
	await _start_game()
	assert_eq(_level.stars_found(), 0, "cada visita começa do zero")
	var again := _star_at(STAR_CELL)
	assert_false(again.is_secured(), "a estrela está no lugar de novo")
	assert_true(again.visible)


func test_spikes_kill_and_only_send_back_to_the_last_point() -> void:
	await _start_game()
	await _teleport(ABOVE_SPIKES_CELL, 30)
	assert_true(_player.is_dead())
	await wait_seconds(RESPAWN_WAIT)
	assert_false(_player.is_dead())
	assert_eq(_player.global_position, _level.spawn_point(), "sem checkpoint, volta ao começo")
	assert_eq(_main.deaths(), 1)


func test_respawns_at_last_checkpoint_as_many_times_as_needed() -> void:
	await _start_game()
	await _teleport(CHECKPOINT_CELL)
	for death in 5:
		_player.die()
		await wait_seconds(RESPAWN_WAIT)
		assert_false(_player.is_dead())
		assert_eq(_player.global_position, TestHelpers.cell_feet(CHECKPOINT_CELL))
	assert_eq(_main.deaths(), 5, "não há vidas: é só tentar de novo")


func test_crystal_refills_dash_midair() -> void:
	await _start_game()
	await _teleport(CRYSTAL_CELL, 0)
	_player.can_dash = false
	await wait_physics_frames(3)
	assert_true(_player.can_dash)


func test_touching_exit_notifies_and_takes_the_controls() -> void:
	await _start_game()
	watch_signals(_level)
	await _teleport(EXIT_CELL)
	assert_signal_emitted(_level, "exit_reached")
	assert_false(_player.controllable)


# --- Infraestrutura ----------------------------------------------------------------

func _start_game() -> void:
	_main = MAIN_SCENE.instantiate()
	_main.level_scene = TEST_ROOM
	add_child_autofree(_main)
	_player = _main.get_node("Player")
	_level = _main.level()
	await wait_physics_frames(3)


func _teleport(cell: Vector2i, settle_frames := 3) -> void:
	_player.respawn(TestHelpers.cell_feet(cell))
	if settle_frames > 0:
		await wait_physics_frames(settle_frames)


func _star_at(cell: Vector2i) -> StarPickup:
	for node in _level.get_node("Entities").get_children():
		if node is StarPickup and (node as Node2D).global_position == TestHelpers.cell_feet(cell):
			return node
	return null


## Toca a estrela no ar e leva até o chão do checkpoint.
func _carry_star_to_the_ground() -> StarPickup:
	var star := _star_at(STAR_CELL)
	_player.respawn(TestHelpers.cell_feet(STAR_CELL))
	await wait_physics_frames(2)
	_player.global_position = TestHelpers.cell_feet(CHECKPOINT_CELL)
	await wait_physics_frames(SECURE_FRAMES)
	return star
