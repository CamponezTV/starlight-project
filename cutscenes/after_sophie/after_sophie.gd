extends Cutscene
## Depois do chefe 1: Jupiter gritou tudo o que engoliu, mas foi para uma sombra. A de
## verdade nunca ouviu. Uma voz chama o nome dele, e ele não pergunta como ela sabe o
## caminho. Fim do capítulo 1.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const DISTANT_VOICE := preload("res://dialogue/speakers/distant_voice.tres")

const GLOW := Color(1, 0.9, 0.55, 0.95)
const GLOW_SCALE := 0.7

@onready var _wide: Node2D = $Shots/Wide
@onready var _close: Node2D = $Shots/Close
@onready var _jupiter: Actor = $Shots/Close/Jupiter
@onready var _star_glow: Sprite2D = $Shots/Close/Star/Glow
@onready var _wide_star: Node2D = $Shots/Wide/Star
@onready var _star_ahead: Marker2D = $Shots/Wide/StarAhead
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter}


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(2.5)
	pan(_wide, PAN_DISTANCE, 20.0)
	await wait(4.0)
	await cut_to(_close, 0.5)
	await say(JUPITER, "Eu gritei com ela.")
	await say(JUPITER, "Falei tudo. Cinco anos de coisa engolida. E ela se desfez.")
	_jupiter.pose = "sad"
	await say(JUPITER, "Por que eu não tô feliz?")
	await say(null, "(Porque era só uma sombra.)")
	await say(null, "(A de verdade nunca ouviu uma palavra.)")
	_jupiter.pose = "bitter"
	await say(JUPITER, "...Cala a boca.")
	await say(null, "(Olha só. Você respondeu.)")
	end_conversation()
	await _glow()
	await say(DISTANT_VOICE, "...Jupiter...")
	_jupiter.pose = "look_up"
	await say(JUPITER, "Vovô?")
	await say(DISTANT_VOICE, "...por aqui...")
	_jupiter.pose = "sad"
	await say(JUPITER, "A sua voz tá diferente.")
	await say(null, "(Você não perguntou como ele sabe o caminho.)")
	_jupiter.pose = "look_up"
	await say(JUPITER, "Eu tô indo.")
	end_conversation()
	await cut_to(_wide, 0.5)
	_twinkle_sound.play()
	await move(_wide_star, _star_ahead.global_position, 3.0)
	await Transition.fade_out(2.0)
	await show_caption("Fim do Capítulo 1", 3.5)


func _glow() -> void:
	_twinkle_sound.play()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_star_glow, "modulate", GLOW, 2.0)
	tween.tween_property(_star_glow, "scale", Vector2.ONE * GLOW_SCALE, 2.0)
	await tween.finished
