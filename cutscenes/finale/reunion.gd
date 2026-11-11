extends Cutscene
## Final, parte 1 (GDD "Final Cut Scene 1"): a estrela leva Jupiter até o avô. Mas o avô
## não lembra da promessa que ele mesmo pediu, e Jupiter entende onde está. Ele vai
## mesmo assim. Fica fora da campanha até o resto do jogo existir (menu dev).

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

@onready var _wide: Node2D = $Shots/Wide
@onready var _close: Node2D = $Shots/Close
@onready var _together: Node2D = $Shots/Together
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _grandpa: Actor = $Shots/Close/Grandpa
@onready var _star: Node2D = $Shots/Wide/Star
@onready var _star_landing: Marker2D = $Shots/Wide/StarLanding
@onready var _flash: ColorRect = $Flash/Rect
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(3.0)
	await wait(2.5)
	_twinkle_sound.play()
	await move(_star, _star_landing.global_position, 4.0)
	await _flash_to(_close)
	await say(JUPITER, "Vovô.")
	await say(GRANDPA, "Meu neto. Eu estava esperando por você.")
	await say(GRANDPA, "Agora a gente pode continuar a nossa jornada. Você pode deixar a vida lá embaixo.")
	_jupiter.pose = "neutral"
	await say(JUPITER, "Espera. Como assim, deixar?")
	_jupiter.pose = "sad"
	await say(JUPITER, "Eu ainda queria ser astronauta. Queria ter uma família.")
	await say(JUPITER, "Queria ver se um dia a Sophie ia pedir desculpa.")
	await say(GRANDPA, "Não se apegue à vida passageira, meu neto. Comigo você vive pra sempre.")
	await say(GRANDPA, "Não era isso que você queria? Buscar as estrelas comigo?")
	_jupiter.pose = "hollow"
	await say(JUPITER, "Você me fez prometer que eu ia demorar.")
	await say(GRANDPA, "Eu fiz?")
	await say(JUPITER, "...")
	_jupiter.pose = "sad"
	await say(JUPITER, "Você não lembra.")
	await say(JUPITER, "No hospital você também não lembrava. Mas lá você pedia desculpa.")
	await say(GRANDPA, "Eu lembro de você. Não basta?")
	_jupiter.pose = "hollow"
	await say(JUPITER, "Vovô. Eu caí de muito alto?")
	await say(GRANDPA, "...")
	await say(JUPITER, "Não doeu. Devia ter doído, né?")
	_grandpa.pose = "smile"
	await say(GRANDPA, "Vem.")
	await say(null, "(Você sabe.)")
	await say(null, "(Você soube desde a queda.)")
	_jupiter.pose = "smile"
	await say(JUPITER, "...Tá bom.")
	await say(null, "(Você vai mesmo assim.)")
	end_conversation()
	await cut_to(_together, 1.0)
	pan(_together, PAN_DISTANCE, 12.0)
	await wait(5.0)
	await Transition.fade_out(4.0)


## Clarão branco que troca de plano (a estrela vira o avô).
func _flash_to(shot: Node2D) -> void:
	var tween := create_tween()
	tween.tween_property(_flash, "color:a", 1.0, 0.5)
	tween.tween_callback(cut_to.bind(shot))
	tween.tween_property(_flash, "color:a", 0.0, 2.0)
	await tween.finished
