extends PlaythroughTest
## Mecânicas da Fase 3 (Fios): broto-mola, Sussurro e plataforma móvel. E os ataques novos
## da Sophie: a mão que esmaga, o anel de palavras e a barra de vida.

const LEVEL_03 := preload("res://levels/level_03.tscn")
const BOSS_LEVEL := preload("res://levels/boss_sophie.tscn")
const BEFORE_SPROUT := Vector2i(11, 41)
const LEDGE_FLOOR_ROW := 37
const WHISPER_CELL := Vector2i(86, 30)
const FIRST_PLATFORM := 0


func test_sprout_launches_the_player_onto_the_high_ledge() -> void:
	await start_at(LEVEL_03, BEFORE_SPROUT)
	var reached := await run_bot(func(_frame: int) -> bool:
		Input.action_press(&"move_right")
		return standing_at_least(19, LEDGE_FLOOR_ROW))
	assert_true(reached, "a mola deveria levar o Jupiter até a borda alta")


func test_sprout_bounces_higher_than_a_jump_and_refills_the_dash() -> void:
	await start_at(LEVEL_03, BEFORE_SPROUT)
	player.can_dash = false
	var start_y := player.global_position.y
	player.bounce(300.0)
	var peak := start_y
	for frame in 60:
		await get_tree().physics_frame
		peak = minf(peak, player.global_position.y)
	assert_gt(start_y - peak, 5.0 * TILE, "mais alto que um pulo (menos de 4 blocos)")
	assert_true(player.can_dash)


func test_touching_a_whisper_costs_a_star() -> void:
	await start_at(LEVEL_03, WHISPER_CELL)
	await wait_physics_frames(3)
	assert_true(player.is_dead())


func test_voice_dash_dissolves_a_whisper_until_the_level_resets() -> void:
	await start_at(LEVEL_03, WHISPER_CELL + Vector2i(-3, 0))
	var whisper := _first(Whisper) as Whisper
	player.gain_voice()
	Input.action_press(&"move_right")
	Input.action_press(&"dash")
	await wait_physics_frames(12)
	assert_false(whisper.is_alive(), "o dash com a voz desfaz o Sussurro")
	assert_false(player.has_voice)
	assert_false(player.is_dead())
	main.level().reset_entities()
	assert_true(whisper.is_alive())


func test_moving_platform_carries_the_player() -> void:
	await start_at(LEVEL_03, Vector2i(42, 36))
	var platform := main.level().get_node("Platforms").get_child(FIRST_PLATFORM) as MovingPlatform
	player.respawn(platform.global_position + Vector2(0, -8))
	await wait_physics_frames(5)
	var start_x := player.global_position.x
	await wait_seconds(1.5)
	assert_true(player.is_on_floor(), "continua em cima da plataforma")
	assert_gt(player.global_position.x - start_x, 2.0 * TILE, "anda junto com ela")


func test_boss_hand_slams_and_sends_shockwaves() -> void:
	await start_at(BOSS_LEVEL, Vector2i(4, 19))
	var boss := main.level().boss()
	watch_signals(boss)
	boss._set_hand_mode(SophieBoss.HandMode.DROPPING)
	await wait_seconds(0.8)
	assert_signal_emitted(boss, "shook")
	var shockwaves := boss.words().filter(func(word: WordProjectile) -> bool: return word.text == SophieBoss.SHOCKWAVE_WORD)
	assert_eq(shockwaves.size(), 2, "uma onda de choque para cada lado")


func test_boss_ring_leaves_a_gap() -> void:
	await start_at(BOSS_LEVEL, Vector2i(4, 19))
	var boss := main.level().boss()
	boss._throw_ring(0.0)
	assert_eq(boss.words().size(), SophieBoss.RING_COUNT[0] - 2)


func test_hud_shows_the_boss_health() -> void:
	await start_at(BOSS_LEVEL, Vector2i(4, 19))
	var bar := main.get_node("HUD/BossBar") as Control
	var pips := main.get_node("HUD/BossBar/Pips")
	assert_true(bar.visible)
	assert_eq(pips.get_child_count(), SophieBoss.MAX_HEALTH)
	main.level().boss().health_changed.emit(1)
	assert_eq((pips.get_child(0) as ColorRect).color, HUD.PIP_FULL)
	assert_eq((pips.get_child(1) as ColorRect).color, HUD.PIP_EMPTY)


func _first(type: Variant) -> Node:
	for node in main.level().get_node("Entities").get_children():
		if is_instance_of(node, type):
			return node
	return null
