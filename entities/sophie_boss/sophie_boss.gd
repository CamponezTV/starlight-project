class_name SophieBoss
extends RoomEntity
## Chefe 1: a sombra da Sophie, a madrasta que batia no Jupiter e o mandava ficar quieto.
## Flutua no alto da arena, arremessa o que ela dizia e esmaga com a mão. A arma do
## Jupiter é a voz que ele nunca usou: com um orbe de voz, um dash nela atordoa e tira um
## ponto de vida. Encostar nela sem a voz mata. São quatro pontos de vida; a cada um
## perdido ela fica mais rápida e ganha ataques. A luta é para pesar: ela entra pelos
## olhos, o escuro fecha em volta da tela no ritmo de um coração e cada golpe (a mão no
## chão, o Jupiter caindo) dá um clarão vermelho. A arena é a sala (RoomZone) em `arena`;
## os orbes aparecem nos Marker2D de OrbSpots.

signal hit(health_left: int)
signal health_changed(health: int)
signal shook(amount: float) ## Pede um tremor de câmera.
signal defeated

enum State { WAITING, ATTACKING, STUNNED, DEFEATED }
enum HandMode { IDLE, AIMING, DROPPING, RESTING }

const DISPLAY_NAME := "Sophie"
const MAX_HEALTH := 4
const INTRO_TIME := 2.5
const TELEGRAPH_TIME := 0.7
const STUN_TIME := 2.2
const DEFEAT_TIME := 3.0
const RESPAWN_GRACE := 1.0 ## Depois do Jupiter renascer, espera antes de atacar de novo.
const HOME_OFFSET := Vector2(0, 86) ## Do topo central da arena até os pés dela.
const HOVER_RANGE := Vector2(96, 5)
const HOVER_SPEED := Vector2(0.55, 1.4)
const STUN_DROP := 10.0 ## Atordoada, ela cede este tanto para baixo.
const MOUTH_OFFSET := Vector2(0, -50)
const PLAYER_CENTER := Vector2(0, -6)
const WALL_MARGIN := 12.0
const RAIN_COLUMN_SPACING := 26.0

const IDLE_FPS := 6.0
const IDLE_FRAMES := 4
const FRAME_SHOUT := 4
const FRAME_STUNNED := 6
const HIT_FLASH := Color(3, 3, 3)
const PHASE_LIGHT: Array[Color] = [Color(0.8, 0.16, 0.26), Color(0.9, 0.16, 0.3), Color(1, 0.14, 0.2), Color(1, 0.08, 0.1)]
const LIGHT_ENERGY := 0.9 ## Na primeira fase; cada fase seguinte soma LIGHT_ENERGY_STEP.
const LIGHT_ENERGY_STEP := 0.25
const EYES_ONLY_TIME := 0.9 ## No começo, só os olhos e o sorriso aparecem no escuro.
const REVEAL_TIME := 1.2

## O escuro em volta da tela, pulsando como um coração (valores por fase).
const HEARTBEAT_PERIOD := [1.1, 0.95, 0.8, 0.65]
const DREAD_STRENGTH := [0.34, 0.44, 0.54, 0.64]
const DREAD_PULSE := 0.2
const SECOND_BEAT_DELAY := 0.25 ## Fração do período entre as duas batidas.
const SECOND_BEAT_FORCE := 0.7
const BEAT_SHARPNESS := 90.0
const BLOW_FLASH := 0.5 ## Opacidade do clarão vermelho de um golpe.
const BLOW_FADE := 0.35

const HAND_REST := Vector2(34, -34) ## Onde a mão descansa, em relação aos pés dela.
const HAND_AIM_HEIGHT := 26.0 ## Altura (abaixo do teto) de onde a mão mira.
const HAND_AIM_TIME := 0.9
const HAND_DROP_SPEED := 460.0
const HAND_REST_TIME := 0.5
const HAND_SHARPNESS := 9.0
const HAND_HEIGHT := 14.0
const SLAM_SHAKE := 5.0
const SHOCKWAVE_SPEED := 120.0

## O que ela dizia. As palavras arremessadas têm o tamanho do texto: frases mais compridas
## que estas deixam os ataques mais difíceis de desviar.
const INTRO_TEXT := "Olha pra mim quando eu falo, bastardo."
const TAUNT_TEXTS := ["LIXO!", "Vem cá.", "Vou ter que te corrigir.", "Você nem era pra ter nascido.", "Ninguém vai acreditar em você.", "Conta pro seu pai. Conta pra ver."]
const KILL_TEXTS := ["Engole o choro.", "Levanta.", "Fica quieto.", "De novo."] ## Quando o Jupiter cai.
## O que o Jupiter nunca disse, um por golpe acertado.
const RETORT_TEXTS := ["Eu não sou lixo!", "Você me batia!", "Eu devia ter contado pra alguém!", "Eu não tenho mais medo de você!"]
const AIMED_TEXTS := ["LIXO", "BASTARDO", "INÚTIL", "CALA A BOCA", "ERRO", "FICA QUIETO", "SEU ERRO"]
const RAIN_TEXTS := ["LIXO", "CALA", "CHEGA", "NADA", "ERRO", "SOME"]
const SWEEP_TEXTS := ["NÃO CONTA PRO SEU PAI", "VOU TER QUE TE CORRIGIR", "VOCÊ NEM ERA PRA NASCER"]
const RING_TEXT := "LIXO"
const SHOCKWAVE_TEXT := "CALA"

## Valores por fase (vida 4, 3, 2, 1).
const VOLLEY_COUNT := [3, 4, 5, 6]
const VOLLEY_SPEED := [95.0, 110.0, 125.0, 140.0]
const VOLLEY_INTERVAL := [0.45, 0.4, 0.34, 0.28]
const RAIN_WAVES := [2, 3, 3, 4]
const RAIN_SPEED := [70.0, 82.0, 94.0, 106.0]
const RAIN_GAP := [64.0, 58.0, 52.0, 46.0]
const RAIN_WAVE_INTERVAL := [1.4, 1.25, 1.1, 0.95]
const SWEEP_SPEED := [100.0, 110.0, 120.0, 132.0]
const RING_COUNT := [8, 10, 12, 14]
const RING_SPEED := [70.0, 78.0, 86.0, 94.0]
const REST_TIME := [1.4, 1.15, 0.9, 0.7]

@export var arena: RoomZone
@export var floor_height := 24.0 ## Altura do chão da arena (px acima da borda de baixo).
@export var word_scene: PackedScene
@export var orb_scene: PackedScene
@export var shatter_effect: PackedScene

var health := MAX_HEALTH

var _state := State.WAITING
var _state_time := 0.0
var _schedule: Array[Array] = [] ## [instante, ação], em ordem.
var _clock := 0.0
var _pattern_index := 0
var _hover_time := 0.0
var _words: Array[WordProjectile] = []
var _orb: VoiceOrb
var _last_orb_spot := -1
var _player_inside: Player
var _was_player_dead := false
var _flash_tween: Tween
var _hand_mode := HandMode.IDLE
var _hand_time := 0.0
var _beat_time := 0.0
var _reveal_tween: Tween
var _blow_tween: Tween

@onready var _sprite: Sprite2D = $Sprite
@onready var _eyes: Sprite2D = $Sprite/Eyes
@onready var _dread: ColorRect = $Dread/Pulse
@onready var _blow: ColorRect = $Dread/Blow
@onready var _light: PointLight2D = $Light
## As falas ficam numa camada própria (Voices), fora do escuro da fase, e seguem a câmera.
@onready var _taunt: FadingLabel = %Taunt
@onready var _taunt_anchor: Node2D = $Voices/TauntAnchor
@onready var _retort: FadingLabel = %Retort
@onready var _orb_spots: Node2D = $OrbSpots
@onready var _hand: AnimatableBody2D = $Hand
@onready var _hand_sprite: Sprite2D = $Hand/Sprite
@onready var _hand_collision: CollisionShape2D = $Hand/Collision
@onready var _warning: Node2D = $Warning
@onready var _shout_sound: AudioStreamPlayer = $ShoutSound
@onready var _word_sound: AudioStreamPlayer = $WordSound
@onready var _hit_sound: AudioStreamPlayer = $HitSound
@onready var _slam_sound: AudioStreamPlayer = $SlamSound
@onready var _defeat_sound: AudioStreamPlayer = $DefeatSound


func _ready() -> void:
	super()
	_retort.get_parent().global_position = Vector2(_arena().get_center().x, _floor_y() - 40.0)
	reset()


## Volta ao começo da luta (quando o Jupiter morre).
func reset() -> void:
	health = MAX_HEALTH
	_clear_attacks()
	_free_orb()
	_pattern_index = 0
	_hover_time = 0.0
	modulate = Color.WHITE
	_light.enabled = true
	global_position = _home()
	reset_physics_interpolation()
	_set_hand_mode(HandMode.IDLE)
	_hand.global_position = global_position + HAND_REST
	_hand.modulate = Color.WHITE
	_set_state(State.WAITING)
	health_changed.emit(health)


func is_defeated() -> bool:
	return _state == State.DEFEATED


func is_stunned() -> bool:
	return _state == State.STUNNED


## Palavras em voo agora.
func words() -> Array[WordProjectile]:
	_words = _words.filter(is_instance_valid)
	return _words


func _physics_process(delta: float) -> void:
	_state_time += delta
	var player := _player()
	if player == null or _state == State.DEFEATED:
		return
	_update_dread(delta)
	if _handle_player_death(player):
		return
	_hover(delta)
	_update_hand(delta, player)
	_check_contact(player)
	match _state:
		State.WAITING:
			if _state_time >= INTRO_TIME:
				_set_state(State.ATTACKING)
		State.ATTACKING:
			_run_schedule(delta)
		State.STUNNED:
			if _state_time >= STUN_TIME:
				_enrage()
	_update_sprite()


# --- Estados ------------------------------------------------------------------------------

func _set_state(state: State) -> void:
	_state = state
	_state_time = 0.0
	match state:
		State.WAITING:
			_taunt.show_text(INTRO_TEXT, INTRO_TIME)
			_reveal()
		State.ATTACKING:
			_schedule.clear()
			_clock = 0.0
			_at(_rest_time(), Callable())


## Com o Jupiter morto, as palavras somem e a luta pausa até ele voltar.
func _handle_player_death(player: Player) -> bool:
	if player.is_dead():
		if not _was_player_dead:
			_was_player_dead = true
			_clear_attacks()
			_flash_blow()
			_taunt.show_text(KILL_TEXTS.pick_random(), RESPAWN_GRACE)
		return true
	if _was_player_dead:
		_was_player_dead = false
		if _state == State.ATTACKING:
			_schedule.clear()
			_at(RESPAWN_GRACE, Callable())
	return false


func _check_contact(player: Player) -> void:
	if _player_inside == null or _state == State.STUNNED:
		return
	if player.is_dashing() and player.has_voice:
		player.spend_voice()
		_take_hit()
	else:
		player.die()


func _take_hit() -> void:
	health -= 1
	_clear_attacks()
	_hit_sound.play()
	_flash()
	_burst()
	shook.emit(SLAM_SHAKE)
	_retort.show_text(RETORT_TEXTS[MAX_HEALTH - health - 1], STUN_TIME + 0.8)
	hit.emit(health)
	health_changed.emit(health)
	if health <= 0:
		_defeat()
	else:
		_set_state(State.STUNNED)


## Passado o atordoamento, ela volta mais furiosa: grito, tremor e a nova fase.
func _enrage() -> void:
	_update_phase_look()
	_shout()
	shook.emit(SLAM_SHAKE * 0.6)
	_set_state(State.ATTACKING)


func _defeat() -> void:
	_set_state(State.DEFEATED)
	_free_orb()
	_sprite.frame = FRAME_STUNNED
	_defeat_sound.play()
	Music.stop(DEFEAT_TIME)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, DEFEAT_TIME)
	tween.parallel().tween_property(_hand, "modulate:a", 0.0, DEFEAT_TIME)
	tween.parallel().tween_property(_light, "energy", 0.0, DEFEAT_TIME)
	tween.parallel().tween_method(_set_dread, DREAD_STRENGTH[MAX_HEALTH - 1], 0.0, DEFEAT_TIME)
	tween.tween_callback(defeated.emit)


# --- Agenda de ataques -----------------------------------------------------------------

## Agenda `action` para daqui a `delay` segundos (Callable vazio = só uma pausa).
func _at(delay: float, action: Callable) -> void:
	_schedule.append([_clock + delay, action])
	_schedule.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])


func _run_schedule(delta: float) -> void:
	_clock += delta
	while not _schedule.is_empty() and _schedule[0][0] <= _clock:
		var action: Callable = _schedule.pop_front()[1]
		if action.is_valid():
			action.call()
	if _schedule.is_empty():
		_plan_next_pattern()


func _plan_next_pattern() -> void:
	var by_phase: Array[Array] = [
		[_volley, _slam, _rain],
		[_ring, _sweep, _slam, _volley],
		[_storm, _slam, _ring, _sweep],
		[_storm, _double_slam, _double_ring, _cross_sweep],
	]
	var patterns: Array = by_phase[_phase()]
	var pattern: Callable = patterns[_pattern_index % patterns.size()]
	_pattern_index += 1
	_shout()
	var end: float = pattern.call(TELEGRAPH_TIME)
	_at(TELEGRAPH_TIME, _offer_orb)
	_at(end + _rest_time(), Callable())


func _clear_attacks() -> void:
	_schedule.clear()
	for word in words():
		word.queue_free()
	_words.clear()
	if is_node_ready():
		_set_hand_mode(HandMode.IDLE)


func _phase() -> int:
	return clampi(MAX_HEALTH - health, 0, MAX_HEALTH - 1)


func _rest_time() -> float:
	return REST_TIME[_phase()]


# --- Ataques: cada um agenda as ações a partir de `start` e devolve quando termina -------

## Palavras em sequência, cada uma mirando onde o Jupiter está.
func _volley(start: float) -> float:
	var phase := _phase()
	var count: int = VOLLEY_COUNT[phase]
	for i in count:
		_at(start + i * VOLLEY_INTERVAL[phase], _throw_at_player.bind(VOLLEY_SPEED[phase]))
	return start + count * VOLLEY_INTERVAL[phase]


## Chuva de palavras caindo em colunas, com uma brecha em lugar aleatório.
func _rain(start: float) -> float:
	var phase := _phase()
	var waves: int = RAIN_WAVES[phase]
	for i in waves:
		_at(start + i * RAIN_WAVE_INTERVAL[phase], _rain_wave)
	return start + waves * RAIN_WAVE_INTERVAL[phase]


## Uma frase comprida rente ao chão, de um lado ao outro: pule por cima.
func _sweep(start: float) -> float:
	_at(start, _throw_sweep.bind(randf() < 0.5))
	return start + _arena().size.x / SWEEP_SPEED[_phase()] * 0.6


## Duas frases rasteiras, uma de cada lado, que se cruzam no meio.
func _cross_sweep(start: float) -> float:
	_at(start, _throw_sweep.bind(true))
	_at(start + 0.5, _throw_sweep.bind(false))
	return start + 0.5 + _arena().size.x / SWEEP_SPEED[_phase()] * 0.6


## Chuva e rajada ao mesmo tempo.
func _storm(start: float) -> float:
	return maxf(_rain(start), _volley(start + 0.6))


## A mão mira no Jupiter, avisa e despenca. O impacto solta ondas de choque pelo chão.
func _slam(start: float) -> float:
	_at(start, _set_hand_mode.bind(HandMode.AIMING))
	_at(start + HAND_AIM_TIME, _set_hand_mode.bind(HandMode.DROPPING))
	return start + HAND_AIM_TIME + 1.0


func _double_slam(start: float) -> float:
	return _slam(_slam(start))


## Um anel de palavras em todas as direções, com uma brecha.
func _ring(start: float) -> float:
	_at(start, _throw_ring.bind(0.0))
	return start + 1.2


func _double_ring(start: float) -> float:
	_at(start, _throw_ring.bind(0.0))
	_at(start + 0.7, _throw_ring.bind(0.5))
	return start + 1.9


func _throw_at_player(speed: float) -> void:
	var from := global_position + MOUTH_OFFSET
	var direction := from.direction_to(_player().global_position + PLAYER_CENTER)
	_spawn_word(AIMED_TEXTS.pick_random(), from, direction * speed)


func _rain_wave() -> void:
	var area := _arena()
	var gap: float = RAIN_GAP[_phase()]
	var gap_center := randf_range(area.position.x + WALL_MARGIN + gap / 2.0, area.end.x - WALL_MARGIN - gap / 2.0)
	var x := area.position.x + WALL_MARGIN
	while x < area.end.x - WALL_MARGIN:
		if absf(x - gap_center) > gap / 2.0:
			_spawn_word(RAIN_TEXTS.pick_random(), Vector2(x, area.position.y + 4.0), Vector2(0, RAIN_SPEED[_phase()]))
		x += RAIN_COLUMN_SPACING


func _throw_sweep(from_left: bool) -> void:
	var area := _arena()
	var direction := 1.0 if from_left else -1.0
	var word := _spawn_word(SWEEP_TEXTS.pick_random(), Vector2.ZERO, Vector2(SWEEP_SPEED[_phase()] * direction, 0))
	var half_width := word.hitbox_size().x / 2.0
	var x := area.position.x - half_width if from_left else area.end.x + half_width
	word.global_position = Vector2(x, _floor_y() - 5.0)
	word.reset_physics_interpolation()


## `turn`: fração de um passo do anel, para o segundo anel sair desencontrado do primeiro.
func _throw_ring(turn: float) -> void:
	var count: int = RING_COUNT[_phase()]
	var gap := randi() % count
	for i in count:
		if i == gap or i == (gap + 1) % count:
			continue
		var direction := Vector2.from_angle(TAU * (i + turn) / count)
		_spawn_word(RING_TEXT, global_position + MOUTH_OFFSET, direction * RING_SPEED[_phase()])


func _spawn_word(text: String, at: Vector2, velocity: Vector2) -> WordProjectile:
	var word := word_scene.instantiate() as WordProjectile
	word.text = text
	word.velocity = velocity
	add_sibling(word)
	word.global_position = at
	word.reset_physics_interpolation()
	_words.append(word)
	_word_sound.play()
	return word


func _shout() -> void:
	_shout_sound.play()
	_taunt.show_text(TAUNT_TEXTS.pick_random(), TELEGRAPH_TIME + 1.0)


# --- A mão ------------------------------------------------------------------------------------

func _set_hand_mode(mode: HandMode) -> void:
	_hand_mode = mode
	_hand_time = 0.0
	_hand_sprite.frame = 1 if mode == HandMode.DROPPING or mode == HandMode.RESTING else 0
	_hand_collision.set_deferred(&"disabled", mode == HandMode.IDLE or mode == HandMode.AIMING)
	_warning.visible = mode == HandMode.AIMING


func _update_hand(delta: float, player: Player) -> void:
	_hand_time += delta
	var follow := 1.0 - exp(-HAND_SHARPNESS * delta)
	match _hand_mode:
		HandMode.IDLE:
			_hand.global_position = _hand.global_position.lerp(global_position + HAND_REST, follow)
		HandMode.AIMING:
			var target := Vector2(player.global_position.x, _arena().position.y + HAND_AIM_HEIGHT)
			_hand.global_position = _hand.global_position.lerp(target, follow)
			_warning.global_position = Vector2(_hand.global_position.x, _floor_y())
			_warning.modulate.a = 1.0 if int(_hand_time * 10.0) % 2 == 0 else 0.3
		HandMode.DROPPING:
			_hand.global_position.y += HAND_DROP_SPEED * delta
			if _hand.global_position.y >= _floor_y() - HAND_HEIGHT:
				_hand.global_position.y = _floor_y() - HAND_HEIGHT
				_on_hand_landed()
		HandMode.RESTING:
			if _hand_time >= HAND_REST_TIME:
				_set_hand_mode(HandMode.IDLE)


func _on_hand_landed() -> void:
	_set_hand_mode(HandMode.RESTING)
	_slam_sound.play()
	shook.emit(SLAM_SHAKE)
	_flash_blow()
	var impact := Vector2(_hand.global_position.x, _floor_y() - 5.0)
	for direction: float in [-1.0, 1.0]:
		_spawn_word(SHOCKWAVE_TEXT, impact + Vector2(direction * 14.0, 0), Vector2(direction * SHOCKWAVE_SPEED, 0))


# --- Orbe de voz ---------------------------------------------------------------------------

## Oferece um orbe num ponto diferente do último, se o Jupiter ainda não tem voz.
func _offer_orb() -> void:
	if _orb != null or _player().has_voice:
		return
	var spots := _orb_spots.get_children()
	var index := randi() % spots.size()
	if index == _last_orb_spot:
		index = (index + 1) % spots.size()
	_last_orb_spot = index
	_orb = orb_scene.instantiate() as VoiceOrb
	_orb.respawns = false
	add_sibling(_orb)
	_orb.global_position = (spots[index] as Node2D).global_position
	_orb.reset_physics_interpolation()
	_orb.collected.connect(_free_orb)


func _free_orb() -> void:
	if _orb != null:
		_orb.queue_free()
		_orb = null


# --- Movimento e visual ---------------------------------------------------------------------

func _home() -> Vector2:
	var area := _arena()
	return Vector2(area.get_center().x, area.position.y) + HOME_OFFSET


func _hover(delta: float) -> void:
	if _state != State.STUNNED:
		_hover_time += delta * (1.0 + _phase() * 0.2)
	var wave := Vector2(sin(_hover_time * HOVER_SPEED.x), sin(_hover_time * HOVER_SPEED.y))
	var drop := Vector2(0, STUN_DROP) if _state == State.STUNNED else Vector2.ZERO
	global_position = global_position.lerp(_home() + wave * HOVER_RANGE + drop, 1.0 - exp(-HAND_SHARPNESS * delta))


func _update_sprite() -> void:
	_sprite.position.x = 0.0
	if _state == State.STUNNED:
		_sprite.frame = FRAME_STUNNED
		_sprite.position.x = 1.0 if int(_state_time * 30.0) % 2 == 0 else -1.0
	elif _shout_sound.playing:
		_sprite.frame = FRAME_SHOUT + int(_state_time * IDLE_FPS * 2.0) % 2
	else:
		_sprite.frame = int(_hover_time * IDLE_FPS) % IDLE_FRAMES
	_eyes.frame = _sprite.frame
	_taunt_anchor.global_position = global_position


func _update_phase_look() -> void:
	_light.color = PHASE_LIGHT[_phase()]
	_light.energy = _light_energy()


func _light_energy() -> float:
	return LIGHT_ENERGY + _phase() * LIGHT_ENERGY_STEP


## A entrada: primeiro só os olhos e o sorriso no escuro, depois o corpo sai da sombra.
func _reveal() -> void:
	if _reveal_tween != null:
		_reveal_tween.kill()
	_light.color = PHASE_LIGHT[_phase()]
	_light.energy = 0.0
	_sprite.self_modulate.a = 0.0
	_reveal_tween = create_tween()
	_reveal_tween.tween_interval(EYES_ONLY_TIME)
	_reveal_tween.tween_property(_sprite, "self_modulate:a", 1.0, REVEAL_TIME)
	_reveal_tween.parallel().tween_property(_light, "energy", _light_energy(), REVEAL_TIME)


## O escuro fecha em volta da tela e bate duas vezes por período, como um coração.
func _update_dread(delta: float) -> void:
	var phase := _phase()
	_beat_time = fmod(_beat_time + delta / HEARTBEAT_PERIOD[phase], 1.0)
	var beat := maxf(_beat(_beat_time), _beat(_beat_time - SECOND_BEAT_DELAY) * SECOND_BEAT_FORCE)
	_set_dread(DREAD_STRENGTH[phase] + DREAD_PULSE * beat)


## Uma batida: forte no instante 0 e sumindo logo depois.
func _beat(since: float) -> float:
	return exp(-since * since * BEAT_SHARPNESS) if since >= 0.0 else 0.0


func _set_dread(strength: float) -> void:
	(_dread.material as ShaderMaterial).set_shader_parameter(&"strength", strength)


## Clarão vermelho de um golpe (a mão dela no chão, o Jupiter caindo).
func _flash_blow() -> void:
	if _blow_tween != null:
		_blow_tween.kill()
	_blow.color.a = BLOW_FLASH
	_blow_tween = create_tween()
	_blow_tween.tween_property(_blow, "color:a", 0.0, BLOW_FADE)


func _flash() -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	_sprite.modulate = HIT_FLASH
	_flash_tween = create_tween()
	_flash_tween.tween_property(_sprite, "modulate", Color.WHITE, 0.4)


## Estilhaços de palavras quando ela é atingida.
func _burst() -> void:
	var effect := shatter_effect.instantiate() as Node2D
	add_sibling(effect)
	effect.global_position = global_position + MOUTH_OFFSET * 0.6
	effect.reset_physics_interpolation()


# --- Utilidades -------------------------------------------------------------------------------

func _arena() -> Rect2:
	return arena.bounds()


func _floor_y() -> float:
	return _arena().end.y - floor_height


func _player() -> Player:
	return get_tree().get_first_node_in_group(&"player") as Player


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null
