extends Cutscene
## Prólogo, o hospital: seis anos depois da colina. O avô já não sabe quem o Jupiter é e
## fala do neto de oito anos para o próprio neto. Por um instante ele volta, cobra a
## promessa e some de novo. É a última vez que diz o nome dele.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

@onready var _close: Node2D = $Shots/Close
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _grandpa: Actor = $Shots/Close/Grandpa


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Seis anos depois", 3.0)
	Transition.fade_in(3.0)
	await wait(3.5)
	await say(null, "(Quarto 214. Você já sabe o caminho de olhos fechados.)")
	await cut_to(_close, 0.5)
	await say(JUPITER, "Oi, vovô. Trouxe o livro das constelações.")
	_grandpa.pose = "confused"
	await say(GRANDPA, "...Você é o rapaz do soro?")
	_jupiter.pose = "hollow"
	await say(JUPITER, "Sou eu. O Jupiter.")
	_grandpa.pose = "neutral"
	await say(GRANDPA, "Jupiter. Bonito nome. Meu neto tem esse nome.")
	_grandpa.pose = "smile"
	await say(GRANDPA, "Ele tem oito anos. Quer ser astronauta. Você ia gostar dele.")
	_jupiter.pose = "sad"
	await say(JUPITER, "...Ia, sim.")
	await say(null, "(Faz quatro meses que ele não sabe quem você é.)")
	await say(null, "(Você vem todo dia mesmo assim.)")
	_grandpa.pose = "neutral"
	await say(GRANDPA, "Eu prometi levar ele pra ver Saturno. Você avisa que eu não esqueci?")
	await say(JUPITER, "Aviso.")
	_grandpa.pose = "confused"
	await say(GRANDPA, "Tá escuro lá fora. Cadê as estrelas?")
	await say(JUPITER, "Tá nublado. Elas tão atrás.")
	_grandpa.pose = "lucid"
	end_conversation()
	await wait(2.0)
	await say(GRANDPA, "Jupiter.")
	_jupiter.pose = "awe"
	await say(JUPITER, "...Vovô?")
	await say(GRANDPA, "Você cresceu.")
	await say(GRANDPA, "Eu não queria que você me visse assim.")
	_jupiter.pose = "cry"
	await say(JUPITER, "Eu não ligo. Eu não ligo, vovô.")
	await say(GRANDPA, "Lembra do que você me prometeu?")
	await say(JUPITER, "Que eu não ia ter pressa.")
	_grandpa.pose = "smile"
	await say(GRANDPA, "Bom menino.")
	end_conversation()
	await wait(1.5)
	_grandpa.pose = "confused"
	await say(GRANDPA, "...Você é o rapaz do soro?")
	_jupiter.pose = "hollow"
	await say(JUPITER, "...")
	await say(JUPITER, "Sou.")
	end_conversation()
	await Transition.fade_out(2.5)
	await say(null, "(Foi a última vez que ele disse o seu nome.)")
	await say(null, "(Ele morreu numa terça, às 3h12. Ninguém te acordou.)")
	end_conversation()
	await wait(1.0)
