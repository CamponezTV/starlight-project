class_name Main
extends Node2D
## Orquestra o jogo: carrega a fase escolhida, liga Jupiter, estrela-guia, câmera e HUD,
## acompanha em qual sala o Jupiter está (câmera e renascimento) e cuida da morte e do
## renascimento. Morrer não custa nada além de voltar ao último ponto: a sala recomeça.
## Habilidade nova ganha um holofote (SkillShowcase); na saída da fase, o portal puxa o
## Jupiter, o resumo aparece (LevelComplete) e a campanha segue (Story.advance()).
## Conversas (Encounter) tocam por cima da fase, com o jogo parado.

const RESPAWN_DELAY := 0.7
const DEATH_SHAKE := 4.0
const DASH_SHAKE := 1.0
const STAR_SHAKE := 1.5
const PLAYER_CENTER := Vector2(0, -6) ## Do pé ao centro do Jupiter.
const FALL_DEATH_MARGIN := 16.0 ## Pixels abaixo de uma sala sem saída por baixo em que a queda mata.

const CHECKPOINT_TEXT := "Uma estrela adormecida desperta..."
const INTRO_DURATION := 3.5
const CHECKPOINT_DURATION := 2.0
const ENCOUNTER_LAYER := 50 ## Acima do HUD e da pausa, abaixo da cortina de transição.
const ENCOUNTER_FADE := 0.4

## Fase carregada ao iniciar. O menu troca antes de adicionar a cena.
@export var level_scene: PackedScene

var _level: Level
var _current_room: RoomZone
var _checkpoint := Vector2.ZERO
var _deaths := 0
var _play_time := 0.0 ## Segundos jogados na fase (a pausa não conta).

@onready var _darkness: CanvasModulate = $Darkness
@onready var _level_slot: Node2D = $LevelSlot
@onready var _player: Player = $Player
@onready var _companion: StarCompanion = $StarCompanion
@onready var _camera: FollowCamera = $Camera
@onready var _hud: HUD = $HUD
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _skill_showcase: SkillShowcase = $SkillShowcase
@onready var _level_complete: LevelComplete = $LevelComplete


func _ready() -> void:
	_level = level_scene.instantiate()
	_level_slot.add_child(_level)
	_darkness.color = _level.ambient_color
	Music.play(_level.music)
	_player.dash_unlocked = _level.starts_with_dash
	_camera.target = _player
	_place_player_at_start()
	_companion.follow(_player)
	_connect_signals()
	_refresh_stars()
	_hud.show_controls(_player.dash_unlocked)
	if not _level.intro_message.is_empty():
		_hud.show_message(_level.intro_message, INTRO_DURATION)


func level() -> Level:
	return _level


func deaths() -> int:
	return _deaths


func _process(delta: float) -> void:
	_play_time += delta


func _physics_process(_delta: float) -> void:
	if _player.is_dead():
		return
	var center := _player.global_position + PLAYER_CENTER
	var room := _level.room_at(center)
	if room == null:
		if _current_room != null and center.y > _current_room.bounds().end.y + FALL_DEATH_MARGIN:
			_player.die()
	elif room != _current_room:
		_enter_room(room)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		_return_to_checkpoint()


func _connect_signals() -> void:
	_player.died.connect(_on_player_died)
	_player.dashed.connect(_camera.shake.bind(DASH_SHAKE))
	_level.checkpoint_reached.connect(_on_checkpoint_reached)
	_level.star_collected.connect(_on_star_collected)
	_level.exit_reached.connect(_on_exit_reached)
	_level.shake_requested.connect(_camera.shake)
	_level.skill_unlocked.connect(_on_skill_unlocked)
	_level.encounter_requested.connect(_on_encounter_requested)
	var boss := _level.boss()
	if boss != null:
		_hud.show_boss(SophieBoss.DISPLAY_NAME, SophieBoss.MAX_HEALTH)
		boss.health_changed.connect(_hud.set_boss_health)
	_pause_menu.checkpoint_requested.connect(_return_to_checkpoint)


func _place_player_at_start() -> void:
	_player.respawn(_level.spawn_point())
	var room := _level.room_at(_level.spawn_point() + PLAYER_CENTER)
	assert(room != null, "O início da fase precisa estar dentro de uma sala (RoomZone).")
	_enter_room(room)
	_checkpoint = _level.spawn_point()
	_camera.snap_to_target()


## Nova sala: a câmera passa a respeitar os limites dela e o renascimento vai para
## o ponto da sala mais perto de onde o Jupiter entrou.
func _enter_room(room: RoomZone) -> void:
	_current_room = room
	_camera.set_bounds(room.bounds())
	_checkpoint = room.nearest_spawn(_player.global_position)


func _return_to_checkpoint() -> void:
	if _player.controllable and not _player.is_dead():
		_respawn()


## Chama `action` depois de `seconds`. O Timer é filho desta cena, então some com ela.
func _after(seconds: float, action: Callable) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	timer.timeout.connect(action)
	timer.timeout.connect(timer.queue_free)
	add_child(timer)
	timer.start()


## Para o jogo (ou solta) enquanto algo toca por cima da fase. A pausa (Esc) fica travada.
func _hold_game(is_held: bool) -> void:
	get_tree().paused = is_held
	_pause_menu.locked = is_held


## Onde um ponto do mundo aparece na tela.
func _on_screen(point: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * point


func _refresh_stars() -> void:
	var total := _level.star_total()
	var found := _level.stars_found()
	_hud.set_stars(found, total)
	_companion.star_fraction = float(found) / total if total > 0 else 0.0


func _summary() -> LevelSummary:
	var summary := LevelSummary.new()
	summary.title = Story.current_title()
	summary.message = _level.end_message
	summary.stars_found = _level.stars_found()
	summary.star_total = _level.star_total()
	summary.deaths = _deaths
	summary.seconds = _play_time
	return summary


func _on_player_died() -> void:
	_deaths += 1
	_camera.shake(DEATH_SHAKE)
	_companion.flicker()
	_after(RESPAWN_DELAY, _respawn)


## A sala recomeça: os objetos voltam ao lugar e o Jupiter, ao último ponto.
func _respawn() -> void:
	_level.reset_entities()
	_player.respawn(_checkpoint)


func _on_checkpoint_reached(respawn_point: Vector2) -> void:
	_checkpoint = respawn_point
	_hud.show_message(CHECKPOINT_TEXT, CHECKPOINT_DURATION)


func _on_star_collected() -> void:
	_companion.pulse()
	_camera.shake(STAR_SHAKE)
	_refresh_stars()


func _on_skill_unlocked(skill: Skill) -> void:
	_hold_game(true)
	await _skill_showcase.present(skill, _on_screen(_player.global_position + PLAYER_CENTER))
	_hold_game(false)
	_hud.show_controls(_player.dash_unlocked)


## Para o jogo, toca a conversa por cima da fase e devolve o controle quando ela acaba.
func _on_encounter_requested(encounter: Encounter) -> void:
	_hold_game(true)
	await Transition.fade_out(ENCOUNTER_FADE)
	var stage := CanvasLayer.new()
	stage.layer = ENCOUNTER_LAYER
	stage.process_mode = Node.PROCESS_MODE_ALWAYS
	var cutscene: Cutscene = encounter.scene.instantiate()
	cutscene.advances_story = false
	stage.add_child(cutscene)
	add_child(stage)
	Transition.fade_in(ENCOUNTER_FADE)
	await cutscene.finished
	await Transition.fade_out(ENCOUNTER_FADE)
	stage.queue_free()
	Music.play(_level.music)
	_hold_game(false)
	encounter.conclude()
	_refresh_stars() # A decisão pode ter tirado a estrela da conversa do jogo.
	Transition.fade_in(ENCOUNTER_FADE)


## Fim da fase: o portal (se houver) puxa o Jupiter, o resumo aparece e a campanha segue.
func _on_exit_reached() -> void:
	set_process(false)
	_player.controllable = false
	_pause_menu.locked = true
	var focus := _player.global_position + PLAYER_CENTER
	var exit := _level.exit()
	if exit != null:
		_player.process_mode = Node.PROCESS_MODE_DISABLED
		focus = exit.core()
		await exit.absorb(_player)
	await _level_complete.present(_summary(), _on_screen(focus))
	Story.advance()
