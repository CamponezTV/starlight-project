extends GutTest
## O ciclo de jogo na cena principal inteira: estrelas, espinhos, checkpoints, cristais,
## saída e recomeço quando a vida acaba.

const MAIN_SCENE := preload("res://main/main.tscn")
const TEST_ROOM := preload("res://levels/test_room.tscn")
const RESPAWN_WAIT := 1.0

## Células da room_01.
const STAR_CELL := Vector2i(30, 19)
const CHECKPOINT_CELL := Vector2i(40, 23)
const ABOVE_SPIKES_CELL := Vector2i(25, 25)
const CRYSTAL_CELL := Vector2i(78, 7)
const EXIT_CELL := Vector2i(96, 9)

var _player: Player
var _level: Level


func after_each() -> void:
	TestHelpers.release_all_actions()


func test_game_starts_with_start_count() -> void:
	await _start_game()
	assert_eq(Stars.count, Stars.START_COUNT)


func test_star_pickup_heals() -> void:
	await _start_game()
	await _teleport(STAR_CELL)
	assert_eq(Stars.count, Stars.START_COUNT + 1)


func test_spikes_kill_and_cost_a_star() -> void:
	await _start_game()
	await _teleport(ABOVE_SPIKES_CELL, 30)
	assert_true(_player.is_dead())
	assert_eq(Stars.count, Stars.START_COUNT - 1)


func test_respawns_at_last_checkpoint() -> void:
	await _start_game()
	await _teleport(CHECKPOINT_CELL)
	_player.die()
	await wait_seconds(RESPAWN_WAIT)
	assert_false(_player.is_dead())
	assert_eq(_player.global_position, TestHelpers.cell_feet(CHECKPOINT_CELL))


func test_crystal_refills_dash_midair() -> void:
	await _start_game()
	await _teleport(CRYSTAL_CELL, 0)
	_player.can_dash = false
	await wait_physics_frames(3)
	assert_true(_player.can_dash)


func test_touching_exit_notifies() -> void:
	await _start_game()
	watch_signals(_level)
	await _teleport(EXIT_CELL)
	assert_signal_emitted(_level, "exit_reached")


func test_losing_all_stars_restarts_room() -> void:
	await _start_game()
	await _teleport(STAR_CELL)
	await _teleport(CHECKPOINT_CELL)
	var deaths_until_empty := Stars.count
	for death in deaths_until_empty:
		_player.die()
		await wait_seconds(RESPAWN_WAIT)
	assert_eq(Stars.count, Stars.START_COUNT, "vida volta cheia")
	assert_eq(_player.global_position, _level.spawn_point(), "volta ao início, não ao checkpoint")
	await _teleport(STAR_CELL)
	assert_eq(Stars.count, Stars.START_COUNT + 1, "as estrelas da sala voltam")


# --- Infraestrutura ----------------------------------------------------------------

func _start_game() -> void:
	var main: Main = MAIN_SCENE.instantiate()
	main.level_scene = TEST_ROOM
	add_child_autofree(main)
	_player = main.get_node("Player")
	_level = main.level()
	await wait_physics_frames(3)


func _teleport(cell: Vector2i, settle_frames := 3) -> void:
	_player.respawn(TestHelpers.cell_feet(cell))
	if settle_frames > 0:
		await wait_physics_frames(settle_frames)
