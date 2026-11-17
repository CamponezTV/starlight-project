extends Cutscene
## Memória antes do chefe 1: aos doze anos, Jupiter é pego à meia-noite olhando Saturno.
## Sophie, a madrasta, vive do dinheiro que o pai manda e desconta nele: humilha, bate
## ("corrigir") e o proíbe de contar. A agressão não aparece: a tela fica preta e só se
## ouve. Na noite seguinte, o avô vê a marca, Jupiter conta uma única vez, e o avô, que
## acha todo mundo bom, diz que ele deve estar confuso. Jupiter nunca mais tenta.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")
const BLOW_GAP := 0.9 ## Entre um golpe e o próximo, no escuro.

@onready var _close: Node2D = $Shots/Close
@onready var _dark: Node2D = $Shots/Dark
@onready var _alone: Node2D = $Shots/Alone
@onready var _next_day: Node2D = $Shots/NextDay
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _sophie: Actor = $Shots/Close/Sophie
@onready var _jupiter_next_day: Actor = $Shots/NextDay/Jupiter
@onready var _grandpa: Actor = $Shots/NextDay/Grandpa
@onready var _door_sound: AudioStreamPlayer = $DoorSound
@onready var _blow_sound: AudioStreamPlayer = $BlowSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, SOPHIE: _sophie, GRANDPA: _grandpa}


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
	await _caught()
	await _corrected()
	await _left_alone()
	await _told_once()
	await Transition.fade_out(2.5)


## Ela entra sorrindo. O sorriso é a parte que dá medo.
func _caught() -> void:
	_sophie.pose = "sweet"
	await say(SOPHIE, "Meia-noite e dez.")
	await say(JUPITER, "Desculpa. Eu já ia dormir.")
	await say(SOPHIE, "Seu pai ligou hoje. Perguntou se você tava dando trabalho.")
	await say(SOPHIE, "Eu disse que não. Eu sempre digo que não.")
	_sophie.pose = "cold"
	await say(SOPHIE, "Enquanto você for um anjo no telefone, o dinheiro dele continua chegando.")
	_jupiter.pose = "sad"
	await say(JUPITER, "É que hoje dá pra ver Saturno, e o vovô disse que...")
	_sophie.pose = "angry"
	await say(SOPHIE, "O seu avô acha que todo mundo é bom. Por isso ele nunca viu nada.")
	_sophie.pose = "cold"
	await say(SOPHIE, "Sua mãe te largou. Seu pai paga pra não ter que te ver.")
	await say(SOPHIE, "E quem ficou com o bastardo fui eu.")
	_jupiter.pose = "silent"
	await say(JUPITER, "...")
	await say(SOPHIE, "Você nem era pra ter nascido. Todo mundo sabe. Só você que não.")
	await say(SOPHIE, "Isso aqui fica comigo.")
	_jupiter.pose = "plead"
	await say(JUPITER, "Não! É do vovô!")
	_sophie.pose = "rage"
	await say(SOPHIE, "Você levantou a voz pra mim?")
	_jupiter.pose = "scared"
	await say(JUPITER, "Não, eu...")
	_sophie.pose = "sweet"
	await say(SOPHIE, "Vem cá. Vou ter que te corrigir.")
	end_conversation()


## No escuro. Só o som, a voz dela e o que ele aprendeu a fazer.
func _corrected() -> void:
	await cut_to(_dark, 0.15)
	for blow in 3:
		_blow_sound.play()
		await wait(BLOW_GAP)
	await say(null, "(Você aprendeu cedo a não fazer barulho.)")
	await say(null, "(Barulho deixava pior.)")
	_blow_sound.play()
	await wait(BLOW_GAP)
	await say(SOPHIE, "LIXO.")
	await say(SOPHIE, "Não conta isso pro seu pai. Senão vai ver.")
	await say(null, "(Ela nunca batia onde o uniforme não cobria.)")
	end_conversation()
	_door_sound.play()
	await wait(1.5)


func _left_alone() -> void:
	await cut_to(_alone, 1.2)
	await wait(1.5)
	await say(null, "(Você tinha uma resposta.)")
	await say(null, "(Você sempre tem. Ela sobe até a garganta e fica lá.)")
	end_conversation()
	await wait(1.0)
	await Transition.fade_out(1.5)


## A única vez que ele contou.
func _told_once() -> void:
	cast[JUPITER] = _jupiter_next_day
	await show_caption("Na noite seguinte", 2.5)
	await cut_to(_next_day)
	await Transition.fade_in(1.5)
	_grandpa.pose = "sad"
	await say(GRANDPA, "Que marca é essa no seu braço, filho?")
	await say(JUPITER, "...")
	await say(JUPITER, "...Foi a Sophie.")
	await say(null, "(Foi a única vez que você disse.)")
	await say(GRANDPA, "A Sophie? Não, não... Ela se mata por você, Jupiter.")
	_grandpa.pose = "smile"
	await say(GRANDPA, "Você deve ter caído e tá confuso. Criança se confunde.")
	_jupiter_next_day.pose = "silent"
	await say(JUPITER, "...")
	await say(null, "(Ele achava que todo mundo era bom. Era a melhor coisa dele.)")
	await say(null, "(Você não mostrou as outras marcas. Não insistiu.)")
	_jupiter_next_day.pose = "sad"
	await say(JUPITER, "...É. Acho que eu caí.")
	await say(null, "(Nunca mais tentou. Com ninguém.)")
	end_conversation()
	await wait(1.5)
