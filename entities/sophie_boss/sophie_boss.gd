class_name SophieBoss
extends RoomEntity
## Chefe 1: a sombra da Sophie, o medo das discussões.
## Flutua no alto da arena e arremessa palavras. A arma do Jupiter é a voz: com um
## orbe de voz, um dash nela atordoa e tira um ponto de vida. Encostar nela sem a voz
## apaga uma estrela. A cada ponto perdido os ataques ficam mais rápidos e densos.
## A arena é a sala (RoomZone) em `arena`; os orbes aparecem nos Marker2D de OrbSpots.

signal hit(health_left: int)
signal defeated

enum State { WAITING, ATTACKING, STUNNED, DEFEATED }

const MAX_HEALTH := 3
const INTRO_TIME := 2.5
const TELEGRAPH_TIME := 0.7
const STUN_TIME := 2.2
const DEFEAT_TIME := 3.0
const RESPAWN_GRACE := 1.0 ## Depois do Jupiter renascer, espera antes de atacar de novo.
const HOME_OFFSET := Vector2(0, 52) ## Do topo central da arena até os pés dela.
const HOVER_RANGE := Vector2(96, 6)
const HOVER_SPEED := Vector2(0.55, 1.4)
const IDLE_FRAME_TIME := 0.4
const FRAME_SHOUT := 2
const FRAME_STUNNED := 3
const HIT_FLASH := Color(3, 3, 3)
const RAIN_COLUMN_SPACING := 26.0
const WALL_MARGIN := 12.0
const MOUTH_OFFSET := Vector2(0, -20)
const PLAYER_CENTER := Vector2(0, -6)

const INTRO_LINE := "Jupiter. Já passou da meia-noite."
const TAUNTS := ["Jupiter!", "Já pra cama!", "Olha o que você fez.", "Você não aprende.", "Ninguém vai te ouvir."]
const RETORTS := ["Não é besteira!", "O vovô acreditava em mim!", "Eu vou chegar nas estrelas!"]
const AIMED_WORDS := ["INÚTIL", "PREGUIÇOSO", "CALA A BOCA", "QUE VERGONHA", "CRESCE", "DE NOVO?", "BESTEIRA"]
const RAIN_WORDS := ["NÃO", "PARA", "CHEGA", "AGORA", "JÁ", "SAI"]
const SWEEP_WORDS := ["VOCÊ NUNCA ESCUTA", "OLHA PRA MIM QUANDO EU FALO", "SEU AVÔ NÃO VAI VOLTAR"]

## Valores por fase (vida 3, 2, 1).
const VOLLEY_COUNT := [3, 4, 5]
const VOLLEY_SPEED := [95.0, 115.0, 135.0]
const VOLLEY_INTERVAL := [0.45, 0.38, 0.3]
const RAIN_WAVES := [2, 3, 3]
const RAIN_SPEED := [70.0, 85.0, 100.0]
const RAIN_GAP := [64.0, 56.0, 48.0]
const RAIN_WAVE_INTERVAL := [1.4, 1.2, 1.0]
const SWEEP_SPEED := [100.0, 110.0, 125.0]
const REST_TIME := [1.4, 1.1, 0.8]

@export var arena: RoomZone
@export var floor_height := 24.0 ## Altura do chão da arena (px acima da borda de baixo).
@export var word_scene: PackedScene
@export var orb_scene: PackedScene

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

@onready var _sprite: Sprite2D = $Sprite
@onready var _light: PointLight2D = $Light
@onready var _taunt: FadingLabel = $Taunt
@onready var _retort: FadingLabel = %Retort
@onready var _orb_spots: Node2D = $OrbSpots
@onready var _shout_sound: AudioStreamPlayer = $ShoutSound
@onready var _word_sound: AudioStreamPlayer = $WordSound
@onready var _hit_sound: AudioStreamPlayer = $HitSound
@onready var _defeat_sound: AudioStreamPlayer = $DefeatSound


func _ready() -> void:
	super()
	_retort.get_parent().global_position = Vector2(_arena().get_center().x, _arena().end.y - floor_height - 40.0)
	reset()


## Volta ao começo da luta (quando as estrelas acabam).
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
	_set_state(State.WAITING)


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
	if _handle_player_death(player):
		return
	_hover(delta)
	_check_contact(player)
	match _state:
		State.WAITING:
			if _state_time >= INTRO_TIME:
				_set_state(State.ATTACKING)
		State.ATTACKING:
			_run_schedule(delta)
		State.STUNNED:
			if _state_time >= STUN_TIME:
				_set_state(State.ATTACKING)
	_update_sprite()


# --- Estados ------------------------------------------------------------------------------

func _set_state(state: State) -> void:
	_state = state
	_state_time = 0.0
	match state:
		State.WAITING:
			_taunt.show_text(INTRO_LINE, INTRO_TIME)
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
	_retort.show_text(RETORTS[MAX_HEALTH - health - 1], STUN_TIME + 0.8)
	hit.emit(health)
	if health <= 0:
		_defeat()
	else:
		_set_state(State.STUNNED)


func _defeat() -> void:
	_set_state(State.DEFEATED)
	_free_orb()
	_sprite.frame = FRAME_STUNNED
	_defeat_sound.play()
	Music.stop(DEFEAT_TIME)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, DEFEAT_TIME)
	tween.parallel().tween_property(_light, "energy", 0.0, DEFEAT_TIME)
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
	var patterns: Array[Callable] = [_volley, _rain]
	match _phase():
		1:
			patterns = [_volley, _sweep, _rain]
		2:
			patterns = [_storm, _sweep, _volley]
	var pattern := patterns[_pattern_index % patterns.size()]
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


func _phase() -> int:
	return clampi(MAX_HEALTH - health, 0, MAX_HEALTH - 1)


func _rest_time() -> float:
	return REST_TIME[_phase()]


# --- Ataques: cada um agenda as palavras a partir de `start` e devolve quando termina ----

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


## Chuva e rajada ao mesmo tempo (última fase).
func _storm(start: float) -> float:
	return maxf(_rain(start), _volley(start + 0.6))


func _throw_at_player(speed: float) -> void:
	var from := global_position + MOUTH_OFFSET
	var direction := from.direction_to(_player().global_position + PLAYER_CENTER)
	_spawn_word(AIMED_WORDS.pick_random(), from, direction * speed)


func _rain_wave() -> void:
	var area := _arena()
	var gap: float = RAIN_GAP[_phase()]
	var gap_center := randf_range(area.position.x + WALL_MARGIN + gap / 2.0, area.end.x - WALL_MARGIN - gap / 2.0)
	var x := area.position.x + WALL_MARGIN
	while x < area.end.x - WALL_MARGIN:
		if absf(x - gap_center) > gap / 2.0:
			_spawn_word(RAIN_WORDS.pick_random(), Vector2(x, area.position.y + 4.0), Vector2(0, RAIN_SPEED[_phase()]))
		x += RAIN_COLUMN_SPACING


func _throw_sweep(from_left: bool) -> void:
	var area := _arena()
	var direction := 1.0 if from_left else -1.0
	var word := _spawn_word(SWEEP_WORDS.pick_random(), Vector2.ZERO, Vector2(SWEEP_SPEED[_phase()] * direction, 0))
	var half_width := word.hitbox_size().x / 2.0
	var x := area.position.x - half_width if from_left else area.end.x + half_width
	word.global_position = Vector2(x, area.end.y - floor_height - 5.0)
	word.reset_physics_interpolation()


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
	_taunt.show_text(TAUNTS.pick_random(), TELEGRAPH_TIME + 1.0)


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
	if _state == State.STUNNED:
		return
	_hover_time += delta * (1.0 + _phase() * 0.25)
	var wave := Vector2(sin(_hover_time * HOVER_SPEED.x), sin(_hover_time * HOVER_SPEED.y))
	global_position = _home() + wave * HOVER_RANGE


func _update_sprite() -> void:
	if _state == State.STUNNED:
		_sprite.frame = FRAME_STUNNED
	elif _state == State.ATTACKING and _shout_sound.playing:
		_sprite.frame = FRAME_SHOUT
	else:
		_sprite.frame = int(_state_time / IDLE_FRAME_TIME) % 2


func _flash() -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	_sprite.modulate = HIT_FLASH
	_flash_tween = create_tween()
	_flash_tween.tween_property(_sprite, "modulate", Color.WHITE, 0.4)


# --- Utilidades -------------------------------------------------------------------------------

func _arena() -> Rect2:
	return arena.bounds()


func _player() -> Player:
	return get_tree().get_first_node_in_group(&"player") as Player


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null
