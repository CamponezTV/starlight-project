extends GutTest
## Todas as fases (as da campanha e a sala de teste) estão bem montadas: salas, pontos de
## renascimento, objetos e um jeito de terminar (saída ou chefe).

const TEST_ROOM := "res://levels/test_room.tscn"
const PLAYER_CENTER := Vector2(0, -6)
const SCREEN := Vector2(320, 180)


func test_levels_are_well_formed() -> void:
	for level in _levels():
		assert_gt(_rooms(level).size(), 0, "%s sem salas" % level.name)
		assert_not_null(level.room_at(level.spawn_point() + PLAYER_CENTER), "%s: início fora de uma sala" % level.name)
		for node in level.get_node("Entities").get_children():
			assert_true(node is RoomEntity, "%s: %s deveria estender RoomEntity" % [level.name, node.name])


func test_every_level_has_exactly_one_way_to_finish() -> void:
	for level in _levels():
		var finishes := level.get_node("Entities").get_children().filter(
			func(node: Node) -> bool: return node is RoomExit or node is SophieBoss)
		assert_eq(finishes.size(), 1, "%s precisa de uma saída ou um chefe" % level.name)


func test_every_room_fits_the_screen_and_has_a_spawn_inside() -> void:
	for level in _levels():
		for room in _rooms(level):
			var spawn := room.nearest_spawn(room.bounds().get_center())
			assert_true(room.contains(spawn + PLAYER_CENTER), "%s/%s: renascimento fora da sala" % [level.name, room.name])
			assert_true(room.size.x >= SCREEN.x and room.size.y >= SCREEN.y, "%s/%s menor que a tela" % [level.name, room.name])


func test_rooms_do_not_overlap() -> void:
	for level in _levels():
		var rooms := _rooms(level)
		for i in rooms.size():
			for j in range(i + 1, rooms.size()):
				assert_false(rooms[i].bounds().intersects(rooms[j].bounds()),
					"%s: %s e %s se sobrepõem" % [level.name, rooms[i].name, rooms[j].name])


func test_entities_sit_inside_a_room() -> void:
	for level in _levels():
		for node in level.get_node("Entities").get_children():
			var entity := node as Node2D
			assert_not_null(level.room_at(entity.global_position + PLAYER_CENTER), "%s: %s fora das salas" % [level.name, entity.name])


func _levels() -> Array[Level]:
	var scenes: Array[PackedScene] = [load(TEST_ROOM)]
	for step in Story.steps:
		if step.kind == StoryStep.Kind.LEVEL:
			scenes.append(step.scene)
	var result: Array[Level] = []
	for scene in scenes:
		var level: Level = scene.instantiate()
		add_child_autofree(level)
		result.append(level)
	return result


func _rooms(level: Level) -> Array[RoomZone]:
	var result: Array[RoomZone] = []
	for node in level.get_node("Rooms").get_children():
		if node is RoomZone:
			result.append(node)
	return result
