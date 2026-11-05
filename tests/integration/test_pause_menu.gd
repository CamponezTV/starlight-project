extends GutTest
## Pausa: Esc pausa e despausa o jogo; "voltar ao checkpoint" leva o Jupiter de volta.

const MAIN_SCENE := preload("res://main/main.tscn")
const TEST_ROOM := preload("res://levels/test_room.tscn")

var _main: Main
var _pause: PauseMenu


func before_each() -> void:
	_main = MAIN_SCENE.instantiate()
	_main.level_scene = TEST_ROOM
	add_child_autofree(_main)
	_pause = _main.get_node("PauseMenu")
	await wait_physics_frames(2)


func after_each() -> void:
	get_tree().paused = false


func test_escape_pauses_and_unpauses() -> void:
	TestHelpers.tap(&"quit")
	await wait_process_frames(1)
	assert_true(_pause.is_open())
	assert_true(get_tree().paused)
	TestHelpers.tap(&"quit")
	await wait_process_frames(1)
	assert_false(_pause.is_open())
	assert_false(get_tree().paused)


func test_checkpoint_button_returns_the_player() -> void:
	var player := _main.get_node("Player") as Player
	var start := player.global_position
	player.respawn(start + Vector2(40, 0))
	_pause.open()
	(_pause.get_node("%CheckpointButton") as Button).pressed.emit()
	await wait_physics_frames(1)
	assert_false(get_tree().paused)
	assert_almost_eq(player.global_position.x, start.x, 1.0)
