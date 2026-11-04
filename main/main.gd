class_name Main
extends Node2D
## Orquestra o jogo: carrega a sala escolhida, liga Jupiter, estrela-guia, câmera e HUD,
## e cuida do ciclo de morte, checkpoint, recomeço e volta ao menu.

const MENU_SCENE := "res://menu/menu.tscn"

const RESPAWN_DELAY := 0.7
const DEATH_SHAKE := 4.0
const DASH_SHAKE := 1.0

const MESSAGE_INTRO := "Siga a estrela..."
const MESSAGE_CHECKPOINT := "O telescópio do vovô..."
const MESSAGE_LIGHT_OUT := "A luz se apagou... tente de novo."
const MESSAGE_PROTOTYPE_END := "Fim do protótipo. Obrigado por jogar!"
const INTRO_DURATION := 3.0
const CHECKPOINT_DURATION := 2.0
const LIGHT_OUT_DURATION := 3.0
const PROTOTYPE_END_DURATION := 4.0

## Sala carregada ao iniciar. O menu troca antes de adicionar a cena.
@export var room_scene: PackedScene

var _room: Room
var _checkpoint := Vector2.ZERO

@onready var _room_slot: Node2D = $RoomSlot
@onready var _player: Player = $Player
@onready var _companion: StarCompanion = $StarCompanion
@onready var _camera: FollowCamera = $Camera
@onready var _hud: HUD = $HUD
@onready var _light_out_sound: AudioStreamPlayer = $LightOutSound


func _ready() -> void:
	_room = room_scene.instantiate()
	_room_slot.add_child(_room)
	Stars.reset()
	_checkpoint = _room.spawn_point()
	_player.respawn(_checkpoint)
	_companion.follow(_player)
	_camera.target = _player
	_camera.set_bounds(_room.bounds())
	_camera.snap_to_target()
	_connect_signals()
	_hud.show_message(MESSAGE_INTRO, INTRO_DURATION)


func room() -> Room:
	return _room


func _physics_process(_delta: float) -> void:
	if not _player.is_dead() and _player.global_position.y > _room.kill_height():
		_player.die()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart") and not _player.is_dead():
		_player.respawn(_checkpoint)
	elif event.is_action_pressed(&"quit"):
		_back_to_menu()


func _connect_signals() -> void:
	_player.died.connect(_on_player_died)
	_player.dashed.connect(_camera.shake.bind(DASH_SHAKE))
	_room.checkpoint_reached.connect(_on_checkpoint_reached)
	_room.star_collected.connect(_on_star_collected)
	_room.exit_reached.connect(_on_exit_reached)


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
		_restart_room()
	_player.respawn(_checkpoint)


## Sem estrelas: a sala inteira volta ao começo.
func _restart_room() -> void:
	_hud.show_message(MESSAGE_LIGHT_OUT, LIGHT_OUT_DURATION)
	_light_out_sound.play()
	Stars.reset()
	_room.reset_entities()
	_checkpoint = _room.spawn_point()


func _on_checkpoint_reached(respawn_point: Vector2) -> void:
	_checkpoint = respawn_point
	_hud.show_message(MESSAGE_CHECKPOINT, CHECKPOINT_DURATION)


func _on_star_collected() -> void:
	Stars.gain()
	_companion.pulse()


func _on_exit_reached() -> void:
	_hud.show_message(MESSAGE_PROTOTYPE_END, PROTOTYPE_END_DURATION)
	_after(PROTOTYPE_END_DURATION, _back_to_menu)
