extends Cutscene
## Cut Scene 2 (jogável): logo após o enterro, Jupiter sobe a montanha onde olhava as
## estrelas com o avô. No topo, a cena corta para os planos de cinema (SummitShot): ele
## fala com o céu, e a estrela que não pisca começa a andar. De volta ao jogo, ele a segue
## olhando para cima e cai num buraco. A estrela vai atrás. Não doeu, e devia.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")

const STAR_LEAD := Vector2(56, -44) ## Onde a estrela fica, em relação ao Jupiter, enquanto guia.
const STAR_SHARPNESS := 1.6
const STAR_FIRST_MOVE := Vector2(32, 12)
const CUT_TIME := 0.8 ## Fade de cada corte entre o jogo e os planos do topo.

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
@onready var _summit_shot: CanvasLayer = $SummitShot
@onready var _wide: Node2D = $SummitShot/Shots/Wide
@onready var _close: Node2D = $SummitShot/Shots/Close
@onready var _shot_jupiter: Actor = $SummitShot/Shots/Close/Jupiter
@onready var _shot_star: Node2D = $SummitShot/Shots/Wide/Star
@onready var _shot_star_end: Marker2D = $SummitShot/Shots/Wide/StarEnd


func _ready() -> void:
	super()
	_player.controllable = false
	_summit_shot.hide()
	cast = {JUPITER: _shot_jupiter}
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
	Transition.fade_in(2.0)
	await wait(1.0)
	_player.controllable = true
	await wait_for_player(_summit)
	_player.controllable = false
	await wait(0.8)
	await _talk_to_the_sky()
	_star.global_position += STAR_FIRST_MOVE
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
	await wait(1.5)
	await say(null, "(Você caiu por muito tempo.)")
	await say(null, "(Não doeu.)")
	await say(null, "(Isso devia ter te assustado.)")
	end_conversation()
	await wait(1.0)


## Os planos do topo: o pedido ao céu e a estrela que começa a andar.
func _talk_to_the_sky() -> void:
	await Transition.fade_out(CUT_TIME)
	_summit_shot.show()
	cut_to(_wide)
	pan(_wide, PAN_DISTANCE, 25.0)
	await Transition.fade_in(CUT_TIME)
	await wait(3.0)
	await cut_to(_close, 0.5)
	await say(JUPITER, "Vovô.")
	await say(JUPITER, "Eu não sei se você tá aí em cima me olhando.")
	_shot_jupiter.pose = "sad"
	await say(JUPITER, "Eu ia trazer o telescópio. Ela vendeu.")
	await say(JUPITER, "Aqui embaixo ninguém fala a nossa língua. Ninguém olha pra cima.")
	_shot_jupiter.pose = "hollow"
	await say(JUPITER, "Eu tô cansado de caber atrás do dedo de todo mundo.")
	_shot_jupiter.pose = "look_up"
	await say(JUPITER, "Eu sei que eu prometi demorar.")
	await say(JUPITER, "Mas um dia eu vou te buscar. E a gente volta pros nossos planos. Todas as estrelas do espaço.")
	end_conversation()
	await cut_to(_wide, 0.5)
	await wait(1.5)
	_star_sound.play()
	await move(_shot_star, _shot_star_end.global_position, 3.0)
	await cut_to(_close, 0.3)
	_shot_jupiter.pose = "awe"
	await say(JUPITER, "...vovô?")
	end_conversation()
	await Transition.fade_out(CUT_TIME)
	_summit_shot.hide()
	await Transition.fade_in(CUT_TIME)
