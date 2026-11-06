extends Cutscene
## Cut Scene 1: anos atrás, Jupiter criança e o avô olham as estrelas na colina, ao lado
## do telescópio. O avô conta o que são as estrelas, e os dois fazem uma promessa.
## O palco (Stage) é desenhado em resolução dobrada e mostrado pela metade.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

const OPENING_FADE := 3.0
const OPENING_PAN := 7.0
const CLOSING_FADE := 3.0
const CLOSE_UP := Vector2(224, 122) ## Centro do plano fechado nos dois.
const WIDE := Vector2(226, 90)

@onready var _jupiter: Actor = $Stage/Jupiter
@onready var _grandpa: Actor = $Stage/Grandpa
@onready var _camera: Camera2D = $Camera
@onready var _camera_end: Marker2D = $CameraEnd
@onready var _shooting_star: Node2D = $Stage/ShootingStar
@onready var _shooting_star_end: Marker2D = $Stage/ShootingStarEnd
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(OPENING_FADE)
	await move(_camera, _camera_end.global_position, OPENING_PAN)
	await move_camera(_camera, CLOSE_UP, 2.0, 2.0)
	await say(JUPITER, "Vovô?")
	_grandpa.flip_h = true
	await say(GRANDPA, "Fale, meu querido!")
	_jupiter.pose = "sit_up"
	await say(JUPITER, "O que são as estrelas?")
	_grandpa.flip_h = false
	_grandpa.pose = "sit_up"
	await say(GRANDPA, "As estrelas, meu neto, são corpos astrais que vagam e iluminam o vazio do espaço.")
	await say(JUPITER, "Vovô... um dia eu vou poder chegar até elas?")
	_grandpa.flip_h = true
	_grandpa.pose = "sit"
	await say(GRANDPA, "Quem sabe um dia você não vira um astronauta e busca uma delas pra mim?")
	_jupiter.pose = "sit"
	await say(JUPITER, "Sim, vovô! Um dia eu vou ser astronauta e vou buscar todas as estrelas pro senhor!")
	await say(GRANDPA, "Vá com calma, meu neto. O céu tem milhares de estrelas...")
	await say(GRANDPA, "Se for buscar todas pra mim, você vai acabar passando uma eternidade no espaço.")
	await say(JUPITER, "Então, quando eu crescer e virar astronauta que nem o senhor, a gente vai junto buscar as estrelas.")
	end_conversation()
	_grandpa.flip_h = false
	_grandpa.pose = "sit_up"
	_jupiter.pose = "sit_up"
	await move_camera(_camera, WIDE, 1.0, 2.0)
	await _shoot_star()
	await wait(0.8)
	await move_camera(_camera, CLOSE_UP, 2.0, 1.5)
	await say(GRANDPA, "Quem sabe um dia, meu neto...")
	await say(GRANDPA, "Quem sabe.")
	end_conversation()
	await wait(2.0)
	await Transition.fade_out(CLOSING_FADE)


## Uma estrela cadente risca o céu, deixando um rastro.
func _shoot_star() -> void:
	_shooting_star.show()
	_twinkle_sound.play()
	var tween := create_tween()
	tween.tween_property(_shooting_star, "global_position", _shooting_star_end.global_position, 1.2).set_ease(Tween.EASE_IN)
	tween.tween_property(_shooting_star, "modulate:a", 0.0, 0.4)
	await tween.finished
