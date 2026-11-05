extends PlaythroughTest
## Mecânicas da Fase 2 (Ecos): rocha frágil, orbe de voz e barreira de palavras.

const LEVEL_02 := preload("res://levels/level_02.tscn")
const BRIDGE_CELL := Vector2i(16, 42) ## Primeira rocha frágil da ponte da sala 1.
const ORB_CELL := Vector2i(90, 41)
const BEFORE_BARRIER := Vector2i(100, 41)
const BARRIER_COLUMN := 104


func test_crumble_block_falls_after_being_stepped_on_and_comes_back() -> void:
	await start_at(LEVEL_02, BRIDGE_CELL + Vector2i.UP)
	var block := _entity_at(CrumbleBlock, BRIDGE_CELL) as CrumbleBlock
	assert_true(block.is_solid())
	await wait_seconds(block.crack_time + 0.1)
	assert_false(block.is_solid(), "deveria ter caído")
	await wait_seconds(block.return_time + 0.3)
	assert_true(block.is_solid(), "deveria ter voltado")


func test_voice_orb_gives_voice_and_comes_back() -> void:
	await start_at(LEVEL_02, ORB_CELL)
	var orb := _entity_at(VoiceOrb, ORB_CELL) as VoiceOrb
	assert_true(player.has_voice)
	assert_false(orb.is_available())
	player.respawn(TestHelpers.cell_feet(ORB_CELL + Vector2i.LEFT * 6))
	assert_false(player.has_voice, "renascer perde a voz")
	await wait_seconds(3.2)
	assert_true(orb.is_available())


func test_barrier_blocks_a_dash_without_voice() -> void:
	await start_at(LEVEL_02, BEFORE_BARRIER)
	await _dash_right()
	assert_false(_barrier().is_broken())
	assert_lt(player.global_position.x, float(BARRIER_COLUMN * TILE))


func test_dash_with_voice_breaks_the_barrier_and_spends_the_voice() -> void:
	await start_at(LEVEL_02, BEFORE_BARRIER)
	player.gain_voice()
	await _dash_right()
	assert_true(_barrier().is_broken())
	assert_false(player.has_voice)
	assert_gt(player.global_position.x, float((BARRIER_COLUMN + 1) * TILE))


func test_level_reset_rebuilds_the_barrier() -> void:
	await start_at(LEVEL_02, BEFORE_BARRIER)
	player.gain_voice()
	await _dash_right()
	main.level().reset_entities()
	await wait_physics_frames(2)
	assert_false(_barrier().is_broken())


func _dash_right() -> void:
	Input.action_press(&"move_right")
	Input.action_press(&"dash")
	await wait_physics_frames(2)
	Input.action_release(&"dash")
	await wait_physics_frames(20)
	Input.action_release(&"move_right")


func _barrier() -> WordBarrier:
	return _entity_at(WordBarrier, Vector2i(BARRIER_COLUMN, 41)) as WordBarrier


## O objeto do tipo `type` cuja base está na célula `cell`.
func _entity_at(type: Variant, cell: Vector2i) -> Node:
	for node in main.level().get_node("Entities").get_children():
		if is_instance_of(node, type) and (node as Node2D).position.is_equal_approx(TestHelpers.cell_feet(cell)):
			return node
	return null
