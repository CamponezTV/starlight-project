extends Cutscene
## Depois do chefe 1: na caverna, Jupiter percebe que finalmente falou. A estrela brilha,
## e uma voz distante chama o nome dele. Fim do capítulo 1.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const DISTANT_VOICE := preload("res://dialogue/speakers/distant_voice.tres")

const STAR_GLOW_ENERGY := 2.2
const STAR_GLOW_SCALE := 3.0
const BOB_HEIGHT := 3.0
const BOB_TIME := 1.2
const CLOSE_UP := Vector2(156, 120)

@onready var _jupiter: Actor = $Stage/Jupiter
@onready var _star: Node2D = $Stage/Star
@onready var _star_light: PointLight2D = $Stage/Star/Light
@onready var _star_ahead: Marker2D = $Stage/StarAhead
@onready var _jupiter_ahead: Marker2D = $Stage/JupiterAhead
@onready var _camera: Camera2D = $Camera
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter}


func _run() -> void:
	_bob_star()
	Transition.fade_out(0.0)
	Transition.fade_in(2.5)
	await move_camera(_camera, CLOSE_UP, 2.0, 3.0)
	await say(JUPITER, "Ela nunca me ouviu. Nem uma vez.")
	_jupiter.pose = "stand"
	await say(JUPITER, "Mas hoje eu falei.")
	await say(JUPITER, "Eu finalmente falei.")
	end_conversation()
	await _glow()
	await wait(1.0)
	await say(DISTANT_VOICE, "...Jupiter...")
	_jupiter.pose = "look_up"
	await say(JUPITER, "Vovô...? É você?")
	end_conversation()
	_twinkle_sound.play()
	move_camera(_camera, Vector2(160, 90), 1.0, 3.0)
	await move(_star, _star_ahead.global_position, 3.0)
	_jupiter.pose = "stand"
	await say(JUPITER, "Espera... eu vou atrás de você.")
	end_conversation()
	await walk(_jupiter, _jupiter_ahead.global_position, 3.0)
	await Transition.fade_out(2.0)
	await show_caption("Fim do Capítulo 1", 3.5)


func _bob_star() -> void:
	var sprite := _star.get_node("Sprite") as Node2D
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", -BOB_HEIGHT, BOB_TIME)
	tween.tween_property(sprite, "position:y", BOB_HEIGHT, BOB_TIME)


func _glow() -> void:
	_twinkle_sound.play()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_star_light, "energy", STAR_GLOW_ENERGY, 2.0)
	tween.tween_property(_star_light, "texture_scale", STAR_GLOW_SCALE, 2.0)
	await tween.finished
