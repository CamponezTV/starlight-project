extends GutTest
## As fases estão bem montadas: salas, pontos de renascimento, objetos e espinhos.

const LEVELS := ["res://levels/level_01.tscn", "res://levels/test_room.tscn"]
const PLAYER_CENTER := Vector2(0, -6)
const SCREEN := Vector2(320, 180)


func test_levels_are_well_formed() -> void:
	for path: String in LEVELS:
		var level: Level = (load(path) as PackedScene).instantiate()
		add_child_autofree(level)
		assert_gt(_rooms(level).size(), 0, "%s sem salas" % path)
		assert_not_null(level.room_at(level.spawn_point() + PLAYER_CENTER), "%s: início fora de uma sala" % path)
		assert_eq(_count(level.get_node("Entities"), func(node: Node) -> bool: return node is RoomExit), 1,
			"%s precisa de exatamente uma saída" % path)
		assert_gt((level.get_node("Hazards") as TileMapLayer).get_used_cells().size(), 0, "%s sem espinhos" % path)
		for node in level.get_node("Entities").get_children():
			assert_true(node is RoomEntity, "%s: %s deveria estender RoomEntity" % [path, node.name])


func test_every_room_fits_the_screen_and_has_a_spawn_inside() -> void:
	for path: String in LEVELS:
		var level: Level = (load(path) as PackedScene).instantiate()
		add_child_autofree(level)
		for room in _rooms(level):
			var spawn := room.nearest_spawn(room.bounds().get_center())
			assert_true(room.contains(spawn + PLAYER_CENTER), "%s/%s: renascimento fora da sala" % [path, room.name])
			assert_true(room.size.x >= SCREEN.x and room.size.y >= SCREEN.y, "%s/%s menor que a tela" % [path, room.name])


func test_rooms_do_not_overlap() -> void:
	for path: String in LEVELS:
		var level: Level = (load(path) as PackedScene).instantiate()
		add_child_autofree(level)
		var rooms := _rooms(level)
		for i in rooms.size():
			for j in range(i + 1, rooms.size()):
				assert_false(rooms[i].bounds().intersects(rooms[j].bounds()),
					"%s: %s e %s se sobrepõem" % [path, rooms[i].name, rooms[j].name])


func _rooms(level: Level) -> Array[RoomZone]:
	var result: Array[RoomZone] = []
	for node in level.get_node("Rooms").get_children():
		if node is RoomZone:
			result.append(node)
	return result


func _count(parent: Node, predicate: Callable) -> int:
	return parent.get_children().filter(predicate).size()
