extends GutTest

## Todas as fases (as da campanha e a sala de teste) estão bem montadas: salas, pontos de
## renascimento, objetos e um jeito de terminar (saída ou chefe).

const TEST_ROOM := "res://levels/test_room.tscn"
const PLAYER_CENTER := Vector2(0, -6)
const SCREEN := Vector2(320, 180)


func before_all() -> void:
	TestHelpers.use_test_save()


func after_all() -> void:
	TestHelpers.restore_save()


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


func test_decor_only_grows_on_free_cells() -> void:
	for level in _levels():
		var terrain := level.get_node("Terrain") as TileMapLayer
		var hazards := level.get_node("Hazards") as TileMapLayer
		var decor := terrain.get_node("Decor") as TerrainDecor
		assert_gt(decor.piece_count(), 0, "%s sem enfeites" % level.name)
		for cell in decor.decorated_cells():
			assert_eq(terrain.get_cell_source_id(cell), -1, "%s: enfeite dentro da rocha em %s" % [level.name, cell])
			assert_eq(hazards.get_cell_source_id(cell), -1, "%s: enfeite em cima de espinho em %s" % [level.name, cell])


## Duas dicas acesas ao mesmo tempo se escreveriam uma por cima da outra.
func test_only_one_hint_shows_at_a_time() -> void:
	for level in _levels():
		if not level.has_node("Hints"):
			continue
		var hints := level.get_node("Hints").get_children()
		for i in hints.size():
			for j in range(i + 1, hints.size()):
				assert_false(_hint_area(hints[i]).intersects(_hint_area(hints[j])),
					"%s: as dicas \"%s\" e \"%s\" aparecem juntas" % [level.name, hints[i].get("text"), hints[j].get("text")])


func test_every_star_has_its_own_name() -> void:
	for level in _levels():
		assert_eq(level.stars_found(), 0, "%s: nenhuma estrela guardada num progresso vazio" % level.name)
		for node in level.get_node("Entities").get_children():
			if node is StarPickup:
				assert_false(node.name.begins_with("@"), "%s: a estrela %s precisa de um nome fixo (é como ela é salva)" % [level.name, node.name])


func _hint_area(hint: Node) -> Rect2:
	var shape := hint.get_node("Area/Collision") as CollisionShape2D
	var size := (shape.shape as RectangleShape2D).size
	return Rect2(shape.global_position - size / 2.0, size)


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
