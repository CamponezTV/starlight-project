extends Cutscene
## Final, parte 2 (GDD "Final Cut Scene 2"): a manhã mais bonita do jogo. O resgate
## encontra Jupiter no fundo do buraco. Sophie chega com o telescópio que ele achava que
## ela tinha vendido: ia devolver. Nada é mostrado de perto; o peso está nas falas.
## Fica fora da campanha até o resto do jogo existir (menu dev).

const RESCUER := preload("res://dialogue/speakers/rescuer.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")

const LIGHT_BLINK := 0.35
const SIREN_FADE := 6.0
const STAR_FADE := 6.0

@onready var _wide: Node2D = $Shots/Wide
@onready var _arrival: Node2D = $Shots/Arrival
@onready var _close: Node2D = $Shots/Close
@onready var _inside: Node2D = $Shots/Inside
@onready var _sophie: Actor = $Shots/Close/Sophie
@onready var _red_light: Sprite2D = $Shots/Wide/RedLight
@onready var _blue_light: Sprite2D = $Shots/Wide/BlueLight
@onready var _star: Node2D = $Shots/Inside/Star
@onready var _siren: AudioStreamPlayer = $Siren


func _ready() -> void:
	super()
	cast = {SOPHIE: _sophie}
	_blink_lights()


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(3.0)
	pan(_wide, PAN_DISTANCE, 30.0)
	await wait(5.0)
	await say(RESCUER, "Achei. Tá aqui embaixo.")
	await say(RESCUER, "Quantos anos?")
	await say(RESCUER, "Uns catorze. Tá de terno.")
	await say(RESCUER, "Tem um folheto no bolso. De um velório.")
	await say(RESCUER, "...De ontem.")
	await say(RESCUER, "Ele tá com o rosto pra cima. Parece que tava olhando alguma coisa.")
	end_conversation()
	await cut_to(_arrival, 1.0)
	await wait(1.5)
	await say(RESCUER, "Senhora, não pode passar da fita.")
	await say(SOPHIE, "...")
	await say(RESCUER, "A senhora é a mãe?")
	await cut_to(_close, 0.4)
	await say(SOPHIE, "Não.")
	_sophie.pose = "cry"
	await say(SOPHIE, "Eu ia devolver.")
	await say(SOPHIE, "Eu só queria que ele pedisse.")
	await say(null, "(Ela também tinha uma resposta presa na garganta.)")
	await say(null, "(Faz anos.)")
	end_conversation()
	create_tween().tween_property(_siren, "volume_db", -50.0, SIREN_FADE)
	await cut_to(_inside, 2.0)
	await wait(2.0)
	var tween := create_tween()
	tween.tween_property(_star, "modulate:a", 0.0, STAR_FADE)
	await tween.finished
	await wait(2.0)
	await Transition.fade_out(3.0)
	_siren.stop()
	await show_caption("Fim", 4.0)


## Luzes da ambulância alternando vermelho e azul.
func _blink_lights() -> void:
	var tween := create_tween().set_loops()
	tween.tween_callback(_set_lights.bind(true))
	tween.tween_interval(LIGHT_BLINK)
	tween.tween_callback(_set_lights.bind(false))
	tween.tween_interval(LIGHT_BLINK)


func _set_lights(is_red: bool) -> void:
	_red_light.visible = is_red
	_blue_light.visible = not is_red
