extends GutTest
## A subida da montanha (prólogo jogável): Jupiter sem habilidades e as lembranças da trilha.

const MOUNTAIN := preload("res://cutscenes/mountain/mountain.tscn")
const MAX_THOUGHT_LINES := 2

var _mountain: Cutscene
var _player: Player


func before_each() -> void:
	_mountain = MOUNTAIN.instantiate()
	_mountain.advances_story = false
	add_child_autofree(_mountain)
	_player = _mountain.get_node("Player")
	await wait_physics_frames(2)


func after_each() -> void:
	Transition.fade_in(0.0)


func test_jupiter_climbs_without_any_skill() -> void:
	assert_false(_player.dash_unlocked, "sem dash na montanha")
	assert_false(_player.wall_moves_unlocked, "sem deslizar nem pular na parede")


func test_a_memory_shows_its_thought_only_once() -> void:
	var spot := _mountain.get_node("Memories/Memory1") as MemorySpot
	var thought := _mountain.get_node("Thoughts/Label") as Label
	watch_signals(spot)
	spot.body_entered.emit(_player)
	spot.body_entered.emit(_player)
	assert_signal_emit_count(spot, "recalled", 1)
	assert_eq(thought.text, spot.text)


func test_every_thought_fits_two_lines() -> void:
	var thought := _mountain.get_node("Thoughts/Label") as Label
	var spots := _mountain.get_node("Memories").get_children()
	assert_gt(spots.size(), 4, "a trilha deveria ter várias lembranças")
	for spot: MemorySpot in spots:
		assert_false(spot.text.is_empty())
		thought.text = spot.text
		assert_lte(thought.get_line_count(), MAX_THOUGHT_LINES, "não cabe: %s" % spot.text)


func test_the_trail_climbs_well_above_the_start() -> void:
	var summit := _mountain.get_node("Summit") as Area2D
	assert_lt(summit.global_position.y, _player.global_position.y - 300.0, "o topo fica bem acima do pé da montanha")


## Nenhum objeto da trilha flutua nem fica enterrado: logo abaixo do pé há rocha, e no pé não.
func test_every_prop_stands_on_the_ground() -> void:
	var terrain := _mountain.get_node("Terrain") as TileMapLayer
	var checked := 0
	for layer: String in ["Props", "FrontProps"]:
		for prop: Sprite2D in _mountain.get_node(layer).get_children():
			var feet := Vector2i(prop.position / TestHelpers.TILE)
			checked += 1
			assert_ne(terrain.get_cell_source_id(feet), -1, "%s flutua" % prop.name)
			assert_eq(terrain.get_cell_source_id(feet + Vector2i.UP), -1, "%s está enterrado" % prop.name)
	assert_gt(checked, 40, "a trilha deveria ter dezenas de objetos")


func test_the_bridge_is_level_with_both_banks() -> void:
	var terrain := _mountain.get_node("Terrain") as TileMapLayer
	var bridge := _mountain.get_node("Bridge") as Node2D
	var deck := Vector2i(bridge.position / TestHelpers.TILE)
	assert_eq(terrain.get_cell_source_id(deck), -1, "debaixo da ponte é a fenda")
	for side in [-5, 4]:
		assert_ne(terrain.get_cell_source_id(deck + Vector2i(side, 0)), -1, "a margem fica na altura do piso da ponte")
		assert_eq(terrain.get_cell_source_id(deck + Vector2i(side, -1)), -1, "sem degrau na cabeceira")
