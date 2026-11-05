extends Cutscene
## Depois do chefe 1: na caverna, Jupiter percebe que finalmente falou. A estrela brilha,
## e uma voz distante chama o nome dele. Fim do capítulo 1.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const DISTANT_VOICE := preload("res://dialogue/speakers/distant_voice.tres")

## Quadros de player/jupiter.png.
const JUPITER_IDLE := 0
const JUPITER_LOOKING_UP := 11

const STAR_GLOW_ENERGY := 1.8
const STAR_GLOW_SCALE := 3.2
const BOB_HEIGHT := 2.0
const BOB_TIME := 1.2

@onready var _jupiter: Sprite2D = $Jupiter
@onready var _star: Node2D = $Star
@onready var _star_light: PointLight2D = $Star/Light
@onready var _star_ahead: Marker2D = $StarAhead
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _run() -> void:
	_bob_star()
	Transition.fade_out(0.0)
	Transition.fade_in(2.0)
	await wait(2.5)
	await say(JUPITER, "Ela nunca me ouviu. Nem uma vez.")
	await say(JUPITER, "Mas hoje eu falei.")
	await say(JUPITER, "Eu finalmente falei.")
	end_conversation()
	await _glow()
	await wait(0.8)
	await say(DISTANT_VOICE, "...Jupiter...")
	_jupiter.frame = JUPITER_LOOKING_UP
	await say(JUPITER, "Vovô...? É você?")
	end_conversation()
	_twinkle_sound.play()
	await move(_star, _star_ahead.global_position, 2.0)
	_jupiter.frame = JUPITER_IDLE
	await say(JUPITER, "Espera... eu vou atrás de você.")
	end_conversation()
	await wait(0.8)
	await Transition.fade_out(2.0)
	await show_caption("Fim do Capítulo 1", 3.5)
	await show_caption("Continua...", 2.5)


func _bob_star() -> void:
	var sprite := _star.get_node("Sprite") as Node2D
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", -BOB_HEIGHT, BOB_TIME)
	tween.tween_property(sprite, "position:y", BOB_HEIGHT, BOB_TIME)


func _glow() -> void:
	_twinkle_sound.play()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_star_light, "energy", STAR_GLOW_ENERGY, 1.5)
	tween.tween_property(_star_light, "texture_scale", STAR_GLOW_SCALE, 1.5)
	await tween.finished
