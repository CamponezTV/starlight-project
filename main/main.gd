class_name Main
extends Node2D
## Orquestra o jogo: carrega a fase escolhida, liga Jupiter, estrela-guia, câmera e HUD,
## acompanha em qual sala o Jupiter está (câmera e renascimento) e cuida do ciclo de
## morte, checkpoint, recomeço e volta ao menu.

const MENU_SCENE := "res://menu/menu.tscn"

const RESPAWN_DELAY := 0.7
const DEATH_SHAKE := 4.0
const DASH_SHAKE := 1.0
const PLAYER_CENTER := Vector2(0, -6) ## Do pé ao centro do Jupiter.
const FALL_DEATH_MARGIN := 16.0 ## Pixels abaixo de uma sala sem saída por baixo em que a queda mata.

const MESSAGE_CHECKPOINT := "Uma estrela adormecida desperta..."
const MESSAGE_LIGHT_OUT := "A luz se apagou... tente de novo."
const INTRO_DURATION := 3.5
const CHECKPOINT_DURATION := 2.0
const LIGHT_OUT_DURATION := 3.0
const END_DURATION := 4.0

## Fase carregada ao iniciar. O menu troca antes de adicionar a cena.
@export var level_scene: PackedScene

var _level: Level
var _current_room: RoomZone
var _checkpoint := Vector2.ZERO

@onready var _level_slot: Node2D = $LevelSlot
@onready var _player: Player = $Player
@onready var _companion: StarCompanion = $StarCompanion
@onready var _camera: FollowCamera = $Camera
@onready var _hud: HUD = $HUD
@onready var _light_out_sound: AudioStreamPlayer = $LightOutSound


func _ready() -> void:
	_level = level_scene.instantiate()
	_level_slot.add_child(_level)
	Stars.reset()
	_camera.target = _player
	_place_player_at_start()
	_companion.follow(_player)
	_connect_signals()
	if not _level.intro_message.is_empty():
		_hud.show_message(_level.intro_message, INTRO_DURATION)


func level() -> Level:
	return _level


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
	if event.is_action_pressed(&"restart") and not _player.is_dead():
		_player.respawn(_checkpoint)
	elif event.is_action_pressed(&"quit"):
		_back_to_menu()


func _connect_signals() -> void:
	_player.died.connect(_on_player_died)
	_player.dashed.connect(_camera.shake.bind(DASH_SHAKE))
	_level.checkpoint_reached.connect(_on_checkpoint_reached)
	_level.star_collected.connect(_on_star_collected)
	_level.exit_reached.connect(_on_exit_reached)


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


## Chama `action` depois de `seconds`. O Timer é filho desta cena, então some com ela.
func _after(seconds: float, action: Callable) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	timer.timeout.connect(action)
	timer.timeout.connect(timer.queue_free)
	add_child(timer)
	timer.start()


func _back_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_player_died() -> void:
	Stars.lose()
	_camera.shake(DEATH_SHAKE)
	_companion.flicker()
	_after(RESPAWN_DELAY, _respawn_after_death)


func _respawn_after_death() -> void:
	if Stars.is_empty():
		_restart_level()
	else:
		_player.respawn(_checkpoint)


## Sem estrelas: a fase inteira volta ao começo.
func _restart_level() -> void:
	_hud.show_message(MESSAGE_LIGHT_OUT, LIGHT_OUT_DURATION)
	_light_out_sound.play()
	Stars.reset()
	_level.reset_entities()
	_place_player_at_start()


func _on_checkpoint_reached(respawn_point: Vector2) -> void:
	_checkpoint = respawn_point
	_hud.show_message(MESSAGE_CHECKPOINT, CHECKPOINT_DURATION)


func _on_star_collected() -> void:
	Stars.gain()
	_companion.pulse()


func _on_exit_reached() -> void:
	_hud.show_message(_level.end_message, END_DURATION)
	_after(END_DURATION, _back_to_menu)
