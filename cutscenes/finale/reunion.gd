extends Cutscene
## Final, parte 1 (GDD "Final Cut Scene 1"): a estrela finalmente leva Jupiter até o avô.
## O avô quer que ele deixe a vida na Terra; Jupiter hesita, mas os dois se abraçam e
## sobem juntos. Fica fora da campanha até o resto do jogo existir (menu dev).

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

const FLOAT_HEIGHT := 420.0
const FLOAT_TIME := 7.0
const CLOSE_UP := Vector2(160, 116)

@onready var _jupiter: Actor = $Stage/Jupiter
@onready var _grandpa: Actor = $Stage/Grandpa
@onready var _star: Node2D = $Stage/Star
@onready var _star_landing: Marker2D = $Stage/StarLanding
@onready var _hug_spot: Marker2D = $Stage/HugSpot
@onready var _flash: ColorRect = $Flash/Rect
@onready var _camera: Camera2D = $Camera
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}
	_grandpa.hide()


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(3.0)
	await wait(2.0)
	_twinkle_sound.play()
	await move(_star, _star_landing.global_position, 4.0)
	await _star_becomes_grandpa()
	await move_camera(_camera, CLOSE_UP, 2.0, 2.0)
	_jupiter.pose = "cry"
	await say(JUPITER, "Vovô! Finalmente te encontrei!")
	_grandpa.pose = "stand"
	await say(GRANDPA, "Meu neto... eu estava esperando por você.")
	await say(GRANDPA, "Agora podemos finalmente continuar a jornada que você tanto queria.")
	await say(GRANDPA, "Você vai poder deixar a sua vida na Terra, e nós vamos alcançar as estrelas juntos.")
	_jupiter.pose = "stand"
	await say(JUPITER, "Espera, vovô... como assim?")
	_jupiter.pose = "sad"
	await say(JUPITER, "Eu não posso deixar a vida na Terra. Ainda tenho muitos sonhos.")
	await say(JUPITER, "Eu quero ser astronauta... quero ter uma família.")
	await say(GRANDPA, "Meu neto, não se apegue à vida passageira.")
	await say(GRANDPA, "Comigo você vai viver pra sempre, fazendo o que a gente mais gosta: olhando e conversando sobre o universo.")
	_grandpa.pose = "arms_open"
	await say(GRANDPA, "Não era isso que você queria? Buscar as estrelas comigo?")
	await say(GRANDPA, "Agora temos todo o tempo do mundo.")
	end_conversation()
	await wait(1.5)
	await walk(_jupiter, _hug_spot.global_position, 2.0, "hug")
	_grandpa.pose = "hug"
	await wait(2.0)
	move_camera(_camera, Vector2(160, 90), 1.0, 3.0)
	await _float_away()
	await Transition.fade_out(3.0)


## Clarão: a estrela vira o avô.
func _star_becomes_grandpa() -> void:
	var tween := create_tween()
	tween.tween_property(_flash, "color:a", 0.9, 0.4)
	tween.tween_callback(func() -> void:
		_star.hide()
		_grandpa.show())
	tween.tween_property(_flash, "color:a", 0.0, 1.5)
	await tween.finished


## Os dois sobem juntos até sumir no alto.
func _float_away() -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	for actor: Actor in [_jupiter, _grandpa]:
		tween.tween_property(actor, "position:y", actor.position.y - FLOAT_HEIGHT, FLOAT_TIME)
	await tween.finished
