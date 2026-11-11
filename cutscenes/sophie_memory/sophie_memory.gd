extends Cutscene
## Memória antes do chefe 1: aos doze anos, Jupiter é pego à meia-noite olhando Saturno.
## Sophie não é só cruel: está exausta, criando o filho de outra, e vê nele a mãe que foi
## embora. Ela leva o telescópio. Ele tem uma resposta e não consegue dizer.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")

@onready var _close: Node2D = $Shots/Close
@onready var _alone: Node2D = $Shots/Alone
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _sophie: Actor = $Shots/Close/Sophie
@onready var _door_sound: AudioStreamPlayer = $DoorSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, SOPHIE: _sophie}


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Dois anos antes", 2.8)
	Transition.fade_in(2.5)
	await wait(3.0)
	await say(JUPITER, "Saturno tá com os anéis abertos hoje. O vovô ia querer ver.")
	end_conversation()
	_door_sound.play()
	await wait(0.8)
	await cut_to(_close, 0.3)
	await say(SOPHIE, "Meia-noite e dez.")
	await say(JUPITER, "Desculpa. Eu já ia dormir.")
	await say(SOPHIE, "Você tem prova amanhã. Eu assinei três advertências este mês. Três.")
	_jupiter.pose = "sad"
	await say(JUPITER, "É que hoje dá pra ver Saturno, e o vovô disse que...")
	_sophie.pose = "angry"
	await say(SOPHIE, "O seu avô.")
	await say(SOPHIE, "O seu avô subiu uma vez num foguete e passou quarenta anos sem conseguir descer.")
	_sophie.pose = "tired"
	await say(SOPHIE, "Sabe quem paga a luz desta casa? Seu pai manda dinheiro e acha que isso é ser pai.")
	await say(SOPHIE, "E quem fica sou eu. Criando o filho de outra.")
	_jupiter.pose = "silent"
	await say(JUPITER, "...")
	_sophie.pose = "away"
	await say(SOPHIE, "Você tem os olhos dela.")
	_sophie.pose = "tired"
	await say(SOPHIE, "Eu odeio isso. E odeio que eu odeio isso.")
	_sophie.pose = "cold"
	await say(SOPHIE, "Isso aqui fica comigo.")
	_jupiter.pose = "plead"
	await say(JUPITER, "Não! É do vovô!")
	await say(SOPHIE, "Então ele que venha buscar.")
	end_conversation()
	await cut_to(_alone, 0.6)
	_door_sound.play()
	await wait(2.0)
	await say(null, "(Você tinha uma resposta.)")
	await say(null, "(Você sempre tem. Ela sobe até a garganta e fica lá.)")
	await say(null, "(Faz três anos que nada passa dali.)")
	end_conversation()
	await wait(1.5)
	await Transition.fade_out(2.5)
