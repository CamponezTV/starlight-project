extends Cutscene
## Prólogo, o adeus: seis anos depois, o enterro do avô, na chuva. O pai não veio. Sophie
## não sabe o que dizer e vai embora. Jupiter, sozinho, confessa que não chorou. A chuva
## para, e ele olha pra cima mesmo sabendo que "virar estrela" não é verdade.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")

const RAIN_FADE := 3.0

@onready var _wide: Node2D = $Shots/Wide
@onready var _close: Node2D = $Shots/Close
@onready var _alone: Node2D = $Shots/Alone
@onready var _sky: Node2D = $Shots/Sky
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _sophie: Actor = $Shots/Close/Sophie
@onready var _jupiter_alone: Actor = $Shots/Alone/Jupiter
@onready var _jupiter_sky: Actor = $Shots/Sky/Jupiter
@onready var _rain_sound: AudioStreamPlayer = $RainSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, SOPHIE: _sophie}


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Seis anos depois", 3.0)
	await say(null, "\"Ele descansou.\"")
	await say(null, "\"Ele está num lugar melhor.\"")
	await say(null, "\"Era a hora dele.\"")
	await say(null, "(Todo mundo falou dele como se ele tivesse viajado.)")
	end_conversation()
	Transition.fade_in(3.0)
	pan(_wide, PAN_DISTANCE, 30.0)
	await wait(5.0)
	await cut_to(_close, 0.5)
	await say(SOPHIE, "Seu pai ligou. Não conseguiu voo.")
	await say(JUPITER, "Eu sei.")
	await say(SOPHIE, "Ele mandou flores.")
	await say(JUPITER, "Eu vi. Vieram com o nome do vovô escrito errado.")
	_sophie.pose = "away"
	await say(SOPHIE, "...")
	_sophie.pose = "tired"
	await say(SOPHIE, "Eu não sei o que dizer pra você, Jupiter. Nunca soube.")
	await say(JUPITER, "Não precisa dizer nada.")
	_sophie.pose = "cold"
	await say(SOPHIE, "Não fica aí até escurecer. Eu não vou voltar pra te buscar.")
	end_conversation()
	await cut_to(_alone, 0.8)
	cast[JUPITER] = _jupiter_alone
	await wait(1.5)
	await say(JUPITER, "Eu não chorei, vovô.")
	await say(JUPITER, "Fiquei o velório inteiro esperando a vontade vir. Não veio.")
	_jupiter_alone.pose = "sad"
	await say(JUPITER, "Tem alguma coisa quebrada em mim?")
	await say(JUPITER, "Você disse que ia virar uma estrela.")
	_jupiter_alone.pose = "bitter"
	await say(JUPITER, "Eu tenho catorze anos. Eu sei que não é assim que funciona.")
	await say(JUPITER, "Eu sei o que tem dentro daquela caixa.")
	end_conversation()
	create_tween().tween_property(_rain_sound, "volume_db", -50.0, RAIN_FADE)
	await cut_to(_sky, 1.5)
	cast[JUPITER] = _jupiter_sky
	await say(null, "(A chuva parou.)")
	await say(null, "(Você olhou pra cima mesmo assim.)")
	await say(JUPITER, "...Uma delas não tá piscando.")
	_jupiter_sky.pose = "awe"
	await say(JUPITER, "A montanha. De lá dá pra ver melhor.")
	await say(null, "(Você prometeu que não ia ter pressa.)")
	end_conversation()
	await Transition.fade_out(2.5)
