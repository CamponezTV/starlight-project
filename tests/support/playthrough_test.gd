class_name PlaythroughTest
extends GutTest
## Base dos testes em que um robô joga uma fase com controles simulados.
## Cada teste começa o jogo (main.tscn) numa célula e roda um "passo" por quadro.
## O progresso (as escolhas das conversas) vai para um arquivo só dos testes.

const MAIN_SCENE := preload("res://main/main.tscn")
const TILE := TestHelpers.TILE
const TIME_LIMIT := 480 ## quadros (8 s)
const SHOWCASE_PRESS_EVERY := 10 ## quadros

var player: Player
var main: Main


func before_all() -> void:
	TestHelpers.use_test_save()


func after_all() -> void:
	TestHelpers.restore_save()


func after_each() -> void:
	TestHelpers.release_all_actions()


## Começa `level_scene` com o Jupiter em pé na célula `cell`.
func start_at(level_scene: PackedScene, cell: Vector2i) -> void:
	main = MAIN_SCENE.instantiate()
	main.level_scene = level_scene
	add_child_autofree(main)
	player = main.get_node("Player")
	player.dash_unlocked = true # Os robôs testam as salas como quem já tem o dash.
	await wait_physics_frames(2)
	player.respawn(TestHelpers.cell_feet(cell))
	await wait_physics_frames(3)


## Roda `step` a cada quadro até ele devolver true (sucesso), o Jupiter morrer ou o tempo acabar.
## Um holofote de habilidade no caminho é confirmado e não conta no tempo.
func run_bot(step: Callable, limit := TIME_LIMIT) -> bool:
	var frame := 0
	while frame < limit:
		if await dismiss_showcase():
			continue
		if step.call(frame):
			return true
		if player.is_dead():
			_report_stop("morreu")
			return false
		frame += 1
		await get_tree().physics_frame
	_report_stop("o tempo acabou")
	return false


## Onde o robô parou: ajuda a achar o pulo que ficou impossível.
func _report_stop(reason: String) -> void:
	var p := player.global_position
	gut.p("robô: %s na célula (%d, %d)" % [reason, floori(p.x / TILE), floori(p.y / TILE) - 1])


## Se o holofote de habilidade estiver aberto, confirma e espera ele fechar. Devolve se estava.
func dismiss_showcase() -> bool:
	var showcase := main.get_node("SkillShowcase") as SkillShowcase
	if not showcase.is_open():
		return false
	while showcase.is_open():
		TestHelpers.tap(&"ui_accept")
		await wait_physics_frames(SHOWCASE_PRESS_EVERY)
	return true


func jump_at_edge(edge_column: int) -> void:
	if player.is_on_floor() and player.global_position.x >= edge_column * TILE + 2:
		Input.action_press(&"jump")


func dash_at_apex() -> void:
	var at_apex := not player.is_on_floor() and player.velocity.y > -20.0
	TestHelpers.set_pressed(&"dash", at_apex and player.can_dash)


## Em pé no chão, com x >= coluna, sobre um piso na linha `row` (a da rocha) ou mais alto.
func standing_at_least(column: int, row: int) -> bool:
	var p := player.global_position
	return player.is_on_floor() and p.x >= column * TILE and p.y <= row * TILE + 0.5
