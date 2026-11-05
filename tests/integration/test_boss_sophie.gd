extends PlaythroughTest
## Chefe 1 (Sophie): palavras são perigosas, encostar nela sem voz mata, um dash com voz
## tira vida e três acertos terminam a fase.

const BOSS_LEVEL := preload("res://levels/boss_sophie.tscn")
const START_CELL := Vector2i(4, 19)
const SIDE_OFFSET := Vector2(-22, -11) ## Do pé da Sophie até onde o Jupiter se posiciona para o dash.
const FIGHT_SPEED := 4.0

var _boss: SophieBoss


func after_each() -> void:
	super()
	Engine.time_scale = 1.0


func test_throws_words_on_the_hazard_layer_after_the_intro() -> void:
	await _start()
	Engine.time_scale = FIGHT_SPEED
	await wait_seconds(SophieBoss.INTRO_TIME + 2.5)
	var words := _boss.words()
	assert_gt(words.size(), 0, "deveria ter arremessado palavras")
	for word in words:
		assert_eq(word.collision_layer, 4, "palavras ficam na camada de perigos")


func test_touching_her_without_voice_costs_a_star() -> void:
	await _start()
	player.respawn(_boss.global_position)
	await wait_physics_frames(3)
	assert_true(player.is_dead())
	assert_eq(_boss.health, SophieBoss.MAX_HEALTH)


func test_dash_with_voice_hits_and_stuns_her() -> void:
	await _start()
	watch_signals(_boss)
	assert_true(await _dash_into_boss(), "o dash não alcançou a Sophie")
	assert_eq(_boss.health, SophieBoss.MAX_HEALTH - 1)
	assert_true(_boss.is_stunned())
	assert_false(player.has_voice, "a voz foi gasta")
	assert_false(player.is_dead())
	assert_signal_emitted_with_parameters(_boss, "hit", [SophieBoss.MAX_HEALTH - 1])


func test_three_hits_defeat_her_and_finish_the_level() -> void:
	await _start()
	watch_signals(main.level())
	Engine.time_scale = FIGHT_SPEED
	for hit in SophieBoss.MAX_HEALTH:
		assert_true(await _dash_into_boss(), "acerto %d falhou" % (hit + 1))
		if not _boss.is_defeated():
			await wait_seconds(SophieBoss.STUN_TIME + 0.2)
	assert_true(_boss.is_defeated())
	await wait_seconds(SophieBoss.DEFEAT_TIME + 0.5)
	assert_signal_emitted(main.level(), "exit_reached")


func test_player_death_clears_the_words() -> void:
	await _start()
	Engine.time_scale = FIGHT_SPEED
	await wait_seconds(SophieBoss.INTRO_TIME + 2.5)
	assert_gt(_boss.words().size(), 0)
	player.die()
	await wait_physics_frames(2)
	assert_eq(_boss.words().size(), 0)


func test_reset_restores_the_fight() -> void:
	await _start()
	await _dash_into_boss()
	_boss.reset()
	assert_eq(_boss.health, SophieBoss.MAX_HEALTH)
	assert_false(_boss.is_stunned())
	assert_eq(_boss.words().size(), 0)


func _start() -> void:
	await start_at(BOSS_LEVEL, START_CELL)
	_boss = main.level().get_node("Entities/SophieBoss") as SophieBoss


## Põe o Jupiter ao lado dela com a voz e dá dash na direção dela. True se acertou.
func _dash_into_boss() -> bool:
	var health := _boss.health
	player.respawn(_boss.global_position + SIDE_OFFSET)
	player.gain_voice()
	Input.action_press(&"move_right")
	Input.action_press(&"dash")
	for frame in 30:
		await get_tree().physics_frame
		if _boss.health < health:
			break
	TestHelpers.release_all_actions()
	return _boss.health < health
