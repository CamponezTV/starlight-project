class_name DianaTalk
extends Cutscene
## Conversa opcional na Fase 3: a Diana, amiga que sumiu da vida do Jupiter há dois anos,
## fuma escondida numa cabana. Ela conta por que parou de falar com ele (os pais a
## obrigaram) e o jogador decide: perdoar ou não. A decisão fica guardada na Story em
## CHOICE_KEY; pular a cena não decide nada, e a conversa continua disponível.

const CHOICE_KEY := "diana"
const FORGIVEN := "forgiven"
const RESENTFUL := "resentful"

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const DIANA := preload("res://dialogue/speakers/diana.tres")

const PAN_TIME := 14.0
const SIT := 0
const TOO_YOUNG := 1
const FORGIVE := 0

@onready var _wide: Node2D = $Shots/Wide
@onready var _close: Node2D = $Shots/Close
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _diana: Actor = $Shots/Close/Diana


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, DIANA: _diana}


func _run() -> void:
	pan(_wide, PAN_DISTANCE, PAN_TIME)
	await wait(1.2)
	await say(null, "(Cheiro de cigarro. Aqui embaixo.)")
	await say(JUPITER, "...Diana?")
	end_conversation()
	await cut_to(_close, 0.4)
	await _arrival()
	await _two_years()
	await _the_reason()
	await _what_it_did()
	if await choose(["Eu te perdoo.", "Eu não consigo."]) == FORGIVE:
		await _forgive()
	else:
		await _hold_on()


func _arrival() -> void:
	await say(DIANA, "Olha só. O menino do telescópio.")
	_diana.pose = "neutral"
	await say(DIANA, "Você cresceu. Ficou com cara de quem não dorme.")
	await say(JUPITER, "O que você tá fazendo aqui?")
	_diana.pose = "smoke"
	await say(DIANA, "Fumando escondida. É o que eu faço de melhor.")
	await say(DIANA, "Acendi um no quintal. Quando olhei em volta, era pedra.")
	await say(DIANA, "Senta. Ou fica aí em pé me odiando. Tanto faz.")
	if await choose(["Sentar do lado dela.", "Ficar em pé."]) == SIT:
		await say(null, "(A madeira range. Ela chega pro lado sem olhar pra você.)")
	else:
		_diana.pose = "smirk"
		await say(DIANA, "Em pé, então. Justo.")


func _two_years() -> void:
	_jupiter.pose = "bitter"
	await say(JUPITER, "Dois anos, Diana.")
	await say(JUPITER, "Você atravessava a rua quando me via.")
	_diana.pose = "away"
	await say(DIANA, "Eu sei.")
	await say(JUPITER, "Eu te mandei parabéns. Nos dois aniversários.")
	await say(DIANA, "Eu li. Os dois. No celular de uma amiga.")


func _the_reason() -> void:
	_diana.pose = "sad"
	await say(DIANA, "Meu pai achou as nossas conversas. Leu em voz alta, na mesa do jantar.")
	await say(DIANA, "Não tinha nada ali. Era você falando de estrela e eu mandando música.")
	_diana.pose = "cold"
	await say(DIANA, "Ele disse que menina de quinze anos não tem amigo. Tem problema.")
	_diana.pose = "away"
	await say(DIANA, "Minha mãe ficou parada na porta do quarto até eu te bloquear.")
	_jupiter.pose = "hollow"
	await say(JUPITER, "Eu tinha doze anos.")
	await say(DIANA, "Eu falei isso. Ele respondeu que menino cresce.")
	if await choose(["Você podia ter me avisado.", "Você tinha quinze anos."]) == TOO_YOUNG:
		_jupiter.pose = "sad"
		await say(JUPITER, "Você tinha quinze anos. Não dava pra você ganhar deles.")
		_diana.pose = "cold"
		await say(DIANA, "Não me entrega a desculpa pronta, Jupiter.")
		await say(DIANA, "Dava pra jogar um bilhete no seu muro. Eu não joguei.")
	else:
		_jupiter.pose = "bitter"
		await say(JUPITER, "Um bilhete. Um olhar na rua. Qualquer coisa.")
		_diana.pose = "sad"
		await say(DIANA, "Podia. Pensei nisso todo dia.")
		await say(DIANA, "E todo dia eu fui covarde. Não vou enfeitar.")


func _what_it_did() -> void:
	_jupiter.pose = "sad"
	await say(JUPITER, "Eu achei que era eu. Que eu tinha feito alguma coisa.")
	await say(JUPITER, "Minha mãe também foi embora sem falar nada.")
	await say(JUPITER, "Eu achei que era um jeito meu. De fazer as pessoas cansarem.")
	_diana.pose = "cry"
	await say(DIANA, "Não era você. Nunca foi você.")
	await say(DIANA, "Você era a única pessoa que não queria nada de mim.")
	_diana.pose = "smoke"
	await say(DIANA, "Hoje eu tenho dezessete e fumo num barraco pra ter uma coisa que eles não escolheram.")
	_diana.pose = "sad"
	await say(DIANA, "Não vim pedir nada. Só não queria que você carregasse isso achando que era seu.")
	await say(null, "(Ela não pede desculpa. Ela espera.)")


func _forgive() -> void:
	Story.remember(CHOICE_KEY, FORGIVEN)
	_jupiter.pose = "sad"
	await say(JUPITER, "Eu te perdoo.")
	await say(JUPITER, "Não porque passou. Não passou.")
	await say(JUPITER, "É que eu tô cansado de perder gente que ainda tá viva.")
	_diana.pose = "smile"
	await say(DIANA, "...Idiota. Você ainda fala desse jeito.")
	await say(DIANA, "Toma. O isqueiro. Lá pra frente é escuro, e eu tô tentando parar.")
	_jupiter.pose = "smile"
	await say(null, "(Pesa pouco. Esquenta a mão.)")
	await say(DIANA, "Quando você sair daqui, me chama no muro. Eu apareço.")
	await say(DIANA, "Eles que se virem.")
	end_conversation()
	await Transition.fade_out(1.2)
	await show_caption("Você perdoou a Diana.", 3.0)


func _hold_on() -> void:
	Story.remember(CHOICE_KEY, RESENTFUL)
	_jupiter.pose = "bitter"
	await say(JUPITER, "Eu não consigo.")
	await say(JUPITER, "Eu entendi. Juro que entendi.")
	await say(JUPITER, "Mas eu fiquei dois anos do outro lado da rua.")
	_diana.pose = "away"
	await say(DIANA, "Tá certo.")
	await say(DIANA, "Não precisa conseguir. Eu só precisava que você soubesse.")
	_diana.pose = "smoke"
	await say(DIANA, "Vai. A sua estrela tá impaciente.")
	end_conversation()
	await cut_to(_wide, 0.6)
	await say(null, "(Você vai. A brasa fica acesa atrás de você por um tempo.)")
	await say(null, "(Depois, não.)")
	end_conversation()
	await Transition.fade_out(1.2)
	await show_caption("Você não perdoou a Diana.", 3.0)
