extends PlaythroughTest
## Chefe 1 (Sophie): palavras são perigosas, encostar nela sem voz mata (e a luta recomeça),
## um dash com voz tira vida e três acertos terminam a fase.

const BOSS_LEVEL := preload("res://levels/boss_sophie.tscn")
const START_CELL := Vector2i(4, 19)
const SIDE_OFFSET := Vector2(-26, -32) ## Do pé da Sophie até onde o Jupiter se posiciona para o dash.
const FIGHT_SPEED := 4.0
const DASH_ATTEMPTS := 4
## Palavras mais compridas que estas deixariam a chuva sem brecha e a frase rasteira
## impossível de pular.
const MAX_RAIN_LETTERS := 5
const MAX_SWEEP_LETTERS := 27

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


func test_touching_her_without_voice_kills_without_hurting_her() -> void:
	await _start()
	player.respawn(_boss.global_position + Vector2(0, -30))
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
## Ela se move, então o robô tenta algumas vezes antes de desistir.
func _dash_into_boss() -> bool:
	var health := _boss.health
	for attempt in DASH_ATTEMPTS:
		player.respawn(_boss.global_position + SIDE_OFFSET)
		player.gain_voice()
		Input.action_press(&"move_right")
		Input.action_press(&"dash")
		for frame in 30:
			await get_tree().physics_frame
			if _boss.health < health:
				break
		TestHelpers.release_all_actions()
		if _boss.health < health:
			return true
		await wait_physics_frames(2)
	return false


# --- O peso da luta ---------------------------------------------------------------------------


func test_she_enters_through_her_eyes_before_the_body_shows() -> void:
	await _start()
	var body := _boss.get_node("Sprite") as Sprite2D
	var eyes := _boss.get_node("Sprite/Eyes") as Sprite2D
	assert_eq(body.self_modulate.a, 0.0, "no começo o corpo ainda está no escuro")
	assert_true(eyes.is_visible_in_tree(), "só os olhos e o sorriso aparecem")
	Engine.time_scale = FIGHT_SPEED
	await wait_seconds(SophieBoss.INTRO_TIME)
	assert_eq(body.self_modulate.a, 1.0, "quando a luta começa ela já saiu da sombra")
	assert_eq(eyes.frame, body.frame, "os olhos acompanham o corpo")


func test_a_fallen_jupiter_gets_a_red_flash_and_a_line_from_her() -> void:
	await _start()
	var blow := _boss.get_node("Dread/Blow") as ColorRect
	var taunt := _boss.get_node("%Taunt") as Label
	assert_eq(blow.color.a, 0.0)
	player.die()
	await wait_physics_frames(2)
	assert_gt(blow.color.a, 0.0, "o golpe dá um clarão vermelho")
	assert_true(SophieBoss.KILL_TEXTS.has(taunt.text), "ela fala por cima de quem caiu")


func test_her_words_stay_short_enough_to_dodge() -> void:
	for word: String in SophieBoss.RAIN_TEXTS + [SophieBoss.RING_TEXT, SophieBoss.SHOCKWAVE_TEXT]:
		assert_lte(word.length(), MAX_RAIN_LETTERS, "\"%s\" é larga demais para a chuva e o anel" % word)
	for phrase: String in SophieBoss.SWEEP_TEXTS:
		assert_lte(phrase.length(), MAX_SWEEP_LETTERS, "\"%s\" é comprida demais para pular" % phrase)


func test_every_hit_has_something_jupiter_never_said() -> void:
	assert_eq(SophieBoss.RETORT_TEXTS.size(), SophieBoss.MAX_HEALTH)
