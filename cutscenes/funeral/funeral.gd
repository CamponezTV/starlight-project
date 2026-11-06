extends Cutscene
## Prólogo, o adeus: seis anos depois, no enterro do avô. Chove; todos vão embora e
## Jupiter fica sozinho no túmulo. A chuva para, as nuvens abrem e as estrelas aparecem.
## Ele decide subir a montanha onde os dois olhavam o céu.

const JUPITER := preload("res://dialogue/speakers/jupiter.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")

const CLEARING_TIME := 5.0
const CLOSE_UP := Vector2(186, 128)

@onready var _jupiter: Actor = $Stage/Jupiter
@onready var _sophie: Actor = $Stage/Sophie
@onready var _clouds: Sprite2D = $Stage/Clouds
@onready var _stars: Sprite2D = $Stage/Stars
@onready var _rain: CPUParticles2D = $Stage/Rain
@onready var _rain_sound: AudioStreamPlayer = $RainSound
@onready var _camera: Camera2D = $Camera
@onready var _sophie_exit: Marker2D = $Stage/SophieExit
@onready var _jupiter_exit: Marker2D = $Stage/JupiterExit


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, SOPHIE: _sophie}


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Seis anos depois", 3.0)
	Transition.fade_in(3.0)
	await move_camera(_camera, CLOSE_UP, 2.0, 5.0)
	await say(SOPHIE, "Jupiter. Vamos. Todo mundo já foi.")
	await say(JUPITER, "Só mais um pouco.")
	await say(SOPHIE, "...")
	await say(SOPHIE, "Não demora. Vai acabar pegando um resfriado.")
	end_conversation()
	await walk(_sophie, _sophie_exit.global_position, 4.0, "umbrella")
	_sophie.hide()
	await wait(1.0)
	_jupiter.pose = "kneel"
	await wait(1.5)
	await say(JUPITER, "Você prometeu que a gente ia junto, vovô.")
	_jupiter.pose = "cry"
	await say(JUPITER, "Quem vai me mostrar as estrelas agora?")
	end_conversation()
	await wait(1.5)
	await _clear_the_sky()
	_jupiter.pose = "look_up"
	await wait(1.5)
	await say(JUPITER, "...")
	await say(JUPITER, "A montanha. Dá pra ver tudo de lá.")
	end_conversation()
	move_camera(_camera, Vector2(230, 90), 1.0, 3.0)
	await walk(_jupiter, _jupiter_exit.global_position, 5.0)
	await Transition.fade_out(2.0)


## A chuva para, as nuvens somem e o céu estrelado aparece por trás.
func _clear_the_sky() -> void:
	_rain.emitting = false
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_rain_sound, "volume_db", -40.0, CLEARING_TIME)
	tween.tween_property(_clouds, "modulate:a", 0.0, CLEARING_TIME)
	tween.tween_property(_stars, "modulate:a", 1.0, CLEARING_TIME)
	tween.tween_property(_camera, "zoom", Vector2.ONE, CLEARING_TIME)
	tween.tween_property(_camera, "global_position", Vector2(200, 90), CLEARING_TIME)
	await tween.finished
	_rain_sound.stop()
