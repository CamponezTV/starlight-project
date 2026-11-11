extends Cutscene
## Cut Scene 1: Jupiter, aos oito anos, e o avô olham as estrelas na colina. O avô conta
## que a luz das estrelas é uma carta de coisas que já morreram, diz que um dia vai virar
## uma delas e arranca uma promessa: não ter pressa. A tragédia inteira nasce aqui.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

const OPENING := 5.0
const PAN_TIME := 40.0

@onready var _wide: Node2D = $Shots/Wide
@onready var _close: Node2D = $Shots/Close
@onready var _hand: Node2D = $Shots/Hand
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _grandpa: Actor = $Shots/Close/Grandpa
@onready var _shooting_star: Node2D = $Shots/Wide/ShootingStar
@onready var _shooting_star_end: Marker2D = $Shots/Wide/ShootingStarEnd
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(3.0)
	pan(_wide, PAN_DISTANCE, PAN_TIME)
	await wait(OPENING)
	await say(JUPITER, "Vovô?")
	await cut_to(_close, 0.4)
	_grandpa.pose = "smile"
	await say(GRANDPA, "Fala, meu querido.")
	_jupiter.pose = "wonder"
	await say(JUPITER, "O que são as estrelas?")
	_grandpa.pose = "look_up"
	await say(GRANDPA, "Fogueiras. Tão longe que a luz leva milhares de anos pra chegar aqui.")
	await say(GRANDPA, "Algumas das que você está vendo já se apagaram. A notícia é que ainda não chegou.")
	_jupiter.pose = "neutral"
	await say(JUPITER, "Então a gente tá olhando pra coisas que já morreram?")
	_grandpa.pose = "smile"
	await say(GRANDPA, "A gente tá lendo a carta que elas deixaram.")
	await say(JUPITER, "...")
	await say(JUPITER, "Você já chegou perto de uma?")
	_grandpa.pose = "look_up"
	await say(GRANDPA, "Uma vez. Subi até onde o céu fica preto no meio do dia.")
	_grandpa.pose = "sad"
	await say(GRANDPA, "Lá de cima, a Terra cabia atrás do meu polegar. Todo mundo que eu amava, atrás de um dedo.")
	await say(GRANDPA, "Depois que eu desci, nunca mais consegui caber aqui embaixo.")
	_jupiter.pose = "smile"
	await say(JUPITER, "Um dia eu vou ser astronauta. Vou lá e busco todas pra você.")
	_grandpa.pose = "smile"
	await say(GRANDPA, "Todas? São milhares. Você ia passar uma eternidade lá em cima.")
	await say(JUPITER, "Então a gente vai junto.")
	_grandpa.pose = "tired"
	await say(GRANDPA, "...")
	await say(GRANDPA, "Jupiter. Se um dia eu não estiver mais aqui...")
	_jupiter.pose = "sad"
	await say(JUPITER, "Onde você vai estar?")
	_grandpa.pose = "look_up"
	end_conversation()
	await wait(1.5)
	await cut_to(_hand, 0.5)
	await say(GRANDPA, "...Lá. Numa daquelas.")
	await say(JUPITER, "Qual?")
	await say(GRANDPA, "A que não piscar. Estrela pisca. Avô, não.")
	await say(JUPITER, "Então eu te busco.")
	await cut_to(_close, 0.5)
	_grandpa.pose = "sad"
	await say(GRANDPA, "Promete uma coisa pra mim.")
	await say(GRANDPA, "Promete que não vai ter pressa.")
	await say(GRANDPA, "Promete que vai demorar muito, muito tempo.")
	_jupiter.pose = "smile"
	await say(JUPITER, "Prometo.")
	end_conversation()
	await cut_to(_wide, 0.6)
	await _shoot_star()
	await say(null, "(Você tinha oito anos.)")
	await say(null, "(Você não sabia o que estava prometendo.)")
	await say(null, "(Ele sabia.)")
	end_conversation()
	await wait(1.0)
	await Transition.fade_out(3.0)


## Uma estrela cadente risca o céu.
func _shoot_star() -> void:
	_shooting_star.show()
	_twinkle_sound.play()
	var tween := create_tween()
	tween.tween_property(_shooting_star, "position", _shooting_star_end.position, 1.2).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_shooting_star, "modulate:a", 0.0, 1.2).set_ease(Tween.EASE_IN)
	await tween.finished
