extends Cutscene
## Final, parte 2 (GDD "Final Cut Scene 2"): já é de manhã no buraco da montanha. Sirenes,
## a equipe de resgate encontra Jupiter lá embaixo. A estrela ao lado dele se apaga.
## Mostrado com cuidado, sem detalhe: a revelação está no silêncio. Fica fora da campanha
## até o resto do jogo existir (menu dev).

const RESCUER := preload("res://dialogue/speakers/rescuer.tres")

const LIGHT_BLINK := 0.35
const SIREN_FADE := 6.0
const STAR_FADE := 5.0
const SLOW_ZOOM := 9.0
const CLOSE_ON_JUPITER := Vector2(180, 135)

@onready var _outside: Node2D = $Stage/Outside
@onready var _inside: Node2D = $Stage/Inside
@onready var _red_light: Sprite2D = $Stage/Outside/RedLight
@onready var _blue_light: Sprite2D = $Stage/Outside/BlueLight
@onready var _star: Node2D = $Stage/Inside/Star
@onready var _siren: AudioStreamPlayer = $Siren
@onready var _camera: Camera2D = $Camera


func _ready() -> void:
	super()
	_inside.hide()
	_blink_lights()


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(3.0)
	await wait(4.0)
	await say(RESCUER, "Aqui! Tem alguém lá embaixo!")
	await say(RESCUER, "...É só um garoto.")
	end_conversation()
	await wait(1.5)
	await Transition.fade_out(2.0)
	_outside.hide()
	_inside.show()
	create_tween().tween_property(_siren, "volume_db", -40.0, SIREN_FADE)
	await Transition.fade_in(3.0)
	move_camera(_camera, CLOSE_ON_JUPITER, 2.0, SLOW_ZOOM)
	await wait(3.0)
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
	tween.tween_callback(func() -> void:
		_red_light.visible = true
		_blue_light.visible = false)
	tween.tween_interval(LIGHT_BLINK)
	tween.tween_callback(func() -> void:
		_red_light.visible = false
		_blue_light.visible = true)
	tween.tween_interval(LIGHT_BLINK)
