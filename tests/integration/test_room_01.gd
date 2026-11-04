extends GutTest
## A sala de teste está montada corretamente.

const ROOM_SCENE := preload("res://rooms/room_01.tscn")
const SIZE_IN_TILES := Vector2(100, 30)
const TILE := 8.0

var _room: Room


func before_each() -> void:
	_room = ROOM_SCENE.instantiate()
	add_child_autofree(_room)


func test_bounds_cover_the_whole_room() -> void:
	assert_eq(_room.bounds(), Rect2(Vector2.ZERO, SIZE_IN_TILES * TILE))


func test_spawn_is_inside_the_room() -> void:
	assert_true(_room.bounds().has_point(_room.spawn_point()))


func test_has_exactly_one_exit() -> void:
	var exits := _room.get_node("Entities").get_children().filter(func(node: Node) -> bool: return node is RoomExit)
	assert_eq(exits.size(), 1)


func test_every_entity_is_a_room_entity() -> void:
	for node in _room.get_node("Entities").get_children():
		assert_true(node is RoomEntity, "%s deveria estender RoomEntity" % node.name)


func test_spikes_are_painted_on_the_hazard_layer() -> void:
	var hazards: TileMapLayer = _room.get_node("Hazards")
	assert_gt(hazards.get_used_cells().size(), 0)
