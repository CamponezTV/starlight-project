extends Cutscene
## Memória antes do chefe 1: dois anos atrás, no quarto, Sophie pega Jupiter olhando
## Saturno pelo telescópio do avô e o confisca. Ele não responde. É aqui que nasce o medo.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")

const WALK_TIME := 2.0
const CLOSE_UP := Vector2(214, 118)
const WIDE := Vector2(160, 90)

@onready var _jupiter: Actor = $Stage/Jupiter
@onready var _sophie: Actor = $Stage/Sophie
@onready var _telescope: Sprite2D = $Stage/Telescope
@onready var _door: Marker2D = $Stage/Door
@onready var _sophie_stop: Marker2D = $Stage/SophieStop
@onready var _camera: Camera2D = $Camera
@onready var _door_sound: AudioStreamPlayer = $DoorSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, SOPHIE: _sophie}


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Dois anos antes", 2.8)
	Transition.fade_in(2.0)
	await wait(2.0)
	await say(JUPITER, "Dá pra ver os anéis de Saturno hoje... o vovô ia adorar.")
	end_conversation()
	_sophie.global_position = _door.global_position
	_sophie.show()
	await walk(_sophie, _sophie_stop.global_position, WALK_TIME)
	await move_camera(_camera, CLOSE_UP, 2.0, 1.5)
	await say(SOPHIE, "Jupiter. Já passou da meia-noite.")
	_jupiter.pose = "stand"
	await say(JUPITER, "Desculpa... é que Saturno tá bem alto hoje.")
	_sophie.pose = "crossed"
	await say(SOPHIE, "Saturno.")
	await say(SOPHIE, "Você tem prova amanhã e tá aqui olhando pro céu de novo.")
	await say(JUPITER, "O vovô disse que um dia eu posso ser astronauta.")
	_sophie.pose = "point"
	await say(SOPHIE, "Astronauta? Você não consegue nem acordar na hora da escola.")
	await say(SOPHIE, "Seu avô subiu uma vez e passou o resto da vida olhando pra cima. Não vou deixar você fazer o mesmo.")
	_jupiter.pose = "sad"
	await say(JUPITER, "Mas...")
	_sophie.pose = "stand"
	await say(SOPHIE, "Isso aqui fica comigo.")
	end_conversation()
	await walk(_sophie, _telescope.global_position + Vector2(16, 0), WALK_TIME * 0.4)
	_telescope.hide()
	_sophie.pose = "hold"
	_sophie.flip_h = false
	await wait(0.6)
	_jupiter.pose = "reach"
	await say(JUPITER, "Não! É do vovô!")
	await say(SOPHIE, "Então ele que venha buscar.")
	end_conversation()
	move_camera(_camera, WIDE, 1.0, 2.0)
	await walk(_sophie, _door.global_position, WALK_TIME, "hold")
	_sophie.hide()
	_door_sound.play()
	await wait(1.2)
	_jupiter.pose = "sad"
	await wait(1.5)
	await say(null, "Eu não respondi.")
	await say(null, "Nunca respondi. Nenhuma vez.")
	end_conversation()
	await wait(1.0)
	await Transition.fade_out(2.5)
