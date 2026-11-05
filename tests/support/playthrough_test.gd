class_name PlaythroughTest
extends GutTest
## Base dos testes em que um robô joga uma fase com controles simulados.
## Cada teste começa o jogo (main.tscn) numa célula e roda um "passo" por quadro.

const MAIN_SCENE := preload("res://main/main.tscn")
const TILE := TestHelpers.TILE
const TIME_LIMIT := 480 ## quadros (8 s)

var player: Player
var main: Main


func after_each() -> void:
	TestHelpers.release_all_actions()


## Começa `level_scene` com o Jupiter em pé na célula `cell`.
func start_at(level_scene: PackedScene, cell: Vector2i) -> void:
	main = MAIN_SCENE.instantiate()
	main.level_scene = level_scene
	add_child_autofree(main)
	player = main.get_node("Player")
	await wait_physics_frames(2)
	player.respawn(TestHelpers.cell_feet(cell))
	await wait_physics_frames(3)


## Roda `step` a cada quadro até ele devolver true (sucesso), o Jupiter morrer ou o tempo acabar.
func run_bot(step: Callable, limit := TIME_LIMIT) -> bool:
	for frame in limit:
		if step.call(frame):
			return true
		if player.is_dead():
			return false
		await get_tree().physics_frame
	return false


func jump_at_edge(edge_column: int) -> void:
	if player.is_on_floor() and player.global_position.x >= edge_column * TILE + 2:
		Input.action_press(&"jump")


func dash_at_apex() -> void:
	var at_apex := not player.is_on_floor() and player.velocity.y > -20.0
	TestHelpers.set_pressed(&"dash", at_apex and player.can_dash)


## Em pé no chão, com x >= coluna e pés na linha `row` ou acima.
func standing_at_least(column: int, row: int) -> bool:
	var p := player.global_position
	return player.is_on_floor() and p.x >= column * TILE and p.y <= row * TILE + 0.5
