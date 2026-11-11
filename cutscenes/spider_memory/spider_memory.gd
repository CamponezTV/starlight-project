extends Cutscene
## Memória antes do chefe 2: aos nove anos, Jupiter responde "você não é minha mãe" e é
## trancado no galpão. Passa a noite com uma aranha olhando pra ele. É aqui que ele
## aprende que ficar quieto funciona. De manhã o avô o encontra, e ele não fala.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

const SPIDER_DESCENT := 5.0
const SHADOW_ALPHA := 0.6
const SHADOW_SCALE := 1.6

@onready var _wide: Node2D = $Shots/Wide
@onready var _close: Node2D = $Shots/Close
@onready var _door: Node2D = $Shots/Door
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _jupiter_found: Actor = $Shots/Door/Jupiter
@onready var _grandpa: Actor = $Shots/Door/Grandpa
@onready var _spider: Sprite2D = $Shots/Wide/Spider
@onready var _thread: Line2D = $Shots/Wide/Thread
@onready var _shadow: Sprite2D = $Shots/Wide/SpiderShadow
@onready var _spider_low: Marker2D = $Shots/Wide/SpiderLow
@onready var _door_sound: AudioStreamPlayer = $DoorSound
@onready var _skitter_sound: AudioStreamPlayer = $SkitterSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}


func _process(_delta: float) -> void:
	_thread.points = PackedVector2Array([Vector2(_spider.position.x, 0), _spider.position])


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Cinco anos antes", 2.8)
	await say(SOPHIE, "Repete.")
	await say(SOPHIE, "Repete o que você disse.")
	await say(JUPITER, "...Você não é minha mãe.")
	await say(SOPHIE, "Não. Não sou.")
	await say(SOPHIE, "A sua mãe pôde ir embora. Eu fiquei.")
	end_conversation()
	_door_sound.play()
	await wait(1.5)
	Transition.fade_in(3.0)
	await wait(4.0)
	await cut_to(_close, 0.5)
	await say(JUPITER, "Um. Dois. Três.")
	await say(JUPITER, "O vovô disse pra contar estrelas quando eu tiver medo.")
	_jupiter.pose = "cry"
	await say(JUPITER, "Não tem estrela aqui.")
	end_conversation()
	await cut_to(_wide, 0.5)
	await _spider_descends()
	await cut_to(_close, 0.3)
	_jupiter.pose = "scared"
	await say(JUPITER, "...")
	await say(null, "(Ela não fez nada.)")
	await say(null, "(Só ficou te olhando. A noite inteira.)")
	await say(null, "(Você também.)")
	end_conversation()
	await Transition.fade_out(2.0)
	await show_caption("De manhã", 2.5)
	await cut_to(_door)
	cast[JUPITER] = _jupiter_found
	_door_sound.play()
	await Transition.fade_in(1.5)
	await say(GRANDPA, "Jupiter. Meu Deus.")
	await say(GRANDPA, "Há quanto tempo você tá aqui?")
	await say(JUPITER, "...")
	await say(GRANDPA, "Fala comigo, filho.")
	await say(JUPITER, "...")
	await say(null, "(Naquela noite você descobriu que ficar quieto funciona.)")
	await say(null, "(Ninguém tranca quem não responde.)")
	_grandpa.pose = "look_up"
	await say(GRANDPA, "Ah. Foi ela que te fez companhia?")
	_grandpa.pose = "smile"
	await say(GRANDPA, "Sabe o que elas fazem? Ligam um ponto no outro com fio. Igual a gente faz com as constelações.")
	await say(GRANDPA, "Ela tava só desenhando o céu dela.")
	_jupiter_found.pose = "sad"
	await say(JUPITER, "...Eu não gosto do céu dela.")
	await say(GRANDPA, "Tudo bem. Não precisa.")
	_grandpa.pose = "sad"
	await say(GRANDPA, "Vamos pra casa. Eu converso com a Sophie.")
	end_conversation()
	await wait(1.0)
	await Transition.fade_out(2.5)
	await show_caption("Ele conversou.", 2.5)
	await show_caption("Ela chorou. Pediu desculpa.", 3.0)
	await show_caption("Durou onze dias.", 3.0)
	await show_caption("Capítulo 2: em breve", 3.5)


## A aranha desce pelo fio e a sombra dela cresce na parede.
func _spider_descends() -> void:
	_skitter_sound.play()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_spider, "position", _spider_low.position, SPIDER_DESCENT)
	tween.tween_property(_shadow, "modulate:a", SHADOW_ALPHA, SPIDER_DESCENT)
	tween.tween_property(_shadow, "scale", Vector2.ONE * SHADOW_SCALE, SPIDER_DESCENT)
	await tween.finished
