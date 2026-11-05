extends Cutscene
## Cut Scene 2 (jogável): seis anos depois, logo após o enterro, Jupiter sobe a montanha
## onde olhava as estrelas com o avô. No topo, fala com o céu. Uma estrela parada começa
## a viajar; ele a segue olhando para cima e cai num buraco. A estrela vai atrás dele.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")

const STAR_LEAD := Vector2(56, -44) ## Onde a estrela fica, em relação ao Jupiter, enquanto guia.
const STAR_SHARPNESS := 1.6
const STAR_FIRST_MOVE := Vector2(32, 12)

@export var bounds := Rect2(0, 0, 880, 184) ## Limites da câmera.

var _star_is_leading := false

@onready var _player: Player = $Player
@onready var _camera: FollowCamera = $Camera
@onready var _star: Node2D = $SkyStar
@onready var _star_stop: Marker2D = $StarStop
@onready var _hole_bottom: Marker2D = $HoleBottom
@onready var _summit: Area2D = $Summit
@onready var _hole_edge: Area2D = $HoleEdge
@onready var _hole: Area2D = $Hole
@onready var _star_sound: AudioStreamPlayer = $StarSound
@onready var _fall_sound: AudioStreamPlayer = $FallSound


func _ready() -> void:
	super()
	_player.controllable = false
	_camera.target = _player
	_camera.set_bounds(bounds)
	_camera.snap_to_target()


func _physics_process(delta: float) -> void:
	if not _star_is_leading:
		return
	var target := _player.global_position + STAR_LEAD
	target.x = minf(target.x, _star_stop.global_position.x)
	_star.global_position = _star.global_position.lerp(target, 1.0 - exp(-STAR_SHARPNESS * delta))


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Seis anos depois", 3.0)
	Transition.fade_in(2.0)
	await wait(1.0)
	_player.controllable = true
	await wait_for_player(_summit)
	_player.controllable = false
	await wait(1.2)
	await say(JUPITER, "Vovô...")
	await say(JUPITER, "Eu não sei se você está aí em cima me observando...")
	await say(JUPITER, "...mas quero que saiba que um dia eu vou te buscar.")
	await say(JUPITER, "E quando eu te encontrar, a gente volta pra todos aqueles nossos planos de ir atrás de todas as estrelas do espaço.")
	end_conversation()
	await wait(2.0)
	_star_sound.play()
	await move(_star, _star.global_position + STAR_FIRST_MOVE, 1.8)
	await say(JUPITER, "...vovô?")
	end_conversation()
	_star_is_leading = true
	_player.controllable = true
	await wait_for_player(_hole_edge)
	# Olhando para a estrela, ele não vê o buraco.
	_player.controllable = false
	_player.scripted_move_x = 1
	await wait_for_player(_hole)
	_player.scripted_move_x = 0
	_fall_sound.play()
	_camera.target = null
	_star_is_leading = false
	await wait(0.8)
	_star_sound.play()
	await move(_star, _hole_bottom.global_position, 1.2, Tween.EASE_IN)
	await Transition.fade_out(1.0)
