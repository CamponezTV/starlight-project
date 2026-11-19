extends PlaythroughTest
## Mecânicas da Fase 2 (Ecos): rocha frágil, orbe de voz (com o holofote e a animação) e
## barreira de palavras.

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
	await dismiss_showcase()
	var orb := _entity_at(VoiceOrb, ORB_CELL) as VoiceOrb
	assert_true(player.has_voice)
	assert_false(orb.is_available())
	player.respawn(TestHelpers.cell_feet(ORB_CELL + Vector2i.LEFT * 6))
	assert_false(player.has_voice, "renascer perde a voz")
	await wait_seconds(3.2)
	assert_true(orb.is_available())


## A primeira orbe da fase apresenta a voz no holofote, uma vez por visita.
func test_first_orb_presents_the_voice_once() -> void:
	await start_at(LEVEL_02, ORB_CELL + Vector2i.LEFT * 4)
	watch_signals(main.level())
	var showcase := main.get_node("SkillShowcase") as SkillShowcase
	player.respawn(TestHelpers.cell_feet(ORB_CELL))
	await wait_physics_frames(2)
	assert_signal_emitted(main.level(), "skill_unlocked")
	assert_true(showcase.is_open(), "o holofote abre")
	assert_true(get_tree().paused, "o jogo para enquanto ele está aberto")
	assert_eq((showcase.get_node("Text/Title") as Label).text, "VOZ")
	await dismiss_showcase()
	assert_false(get_tree().paused)
	var orb := _entity_at(VoiceOrb, ORB_CELL) as VoiceOrb
	player.spend_voice()
	orb.reset()
	main.level().reset_entities()
	await wait_physics_frames(2)
	assert_true(player.has_voice, "pegou de novo")
	assert_false(showcase.is_open(), "na mesma visita, o holofote não volta")
	assert_signal_emit_count(main.level(), "skill_unlocked", 1)


## Pegar a voz tem animação: a orbe estoura em faíscas e a aura do Jupiter acende grande.
func test_taking_the_voice_bursts_the_orb_and_flares_the_aura() -> void:
	await start_at(LEVEL_02, BEFORE_BARRIER)
	var orb := _entity_at(VoiceOrb, Vector2i(132, 39)) as VoiceOrb
	player.respawn(orb.global_position)
	await wait_physics_frames(2) # A área só nota o Jupiter no passo seguinte.
	assert_true(player.has_voice)
	var aura := player.get_node("VoiceAura") as Node2D
	assert_gt(aura.scale.x, 1.5, "a aura nasce grande")
	var burst := main.level().get_node("Entities").get_children().filter(func(node: Node) -> bool: return node is OneShotParticles)
	assert_eq(burst.size(), 1, "faíscas no lugar da orbe")
	assert_true((orb.get_node("Visual") as Node2D).visible, "a orbe ainda está sumindo")
	await wait_seconds(0.5)
	assert_false((orb.get_node("Visual") as Node2D).visible)
	assert_almost_eq(aura.scale.x, 1.0, 0.01, "e volta ao tamanho normal")


## O toque num sussurro mata uma vez só, mesmo que ele continue no lugar onde o Jupiter morreu.
func test_a_whisper_kills_only_once() -> void:
	await start_at(LEVEL_02, Vector2i(243, 19))
	var whisper := main.level().get_node("Entities/Whisper") as Whisper
	whisper.set_physics_process(false) # Parado no lugar, o toque antigo continua lá.
	player.respawn(whisper.global_position)
	await wait_physics_frames(3)
	whisper.set_physics_process(true)
	await wait_seconds(Main.RESPAWN_DELAY + 0.5)
	assert_false(player.is_dead())
	assert_eq(main.deaths(), 1)


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
