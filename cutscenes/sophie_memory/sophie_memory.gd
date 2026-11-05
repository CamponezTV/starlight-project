extends Cutscene
## Memória antes do chefe 1: dois anos atrás, no quarto, Sophie pega Jupiter olhando
## Saturno pelo telescópio do avô. Ele não responde. É aqui que nasce o medo.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")

## Quadros das folhas de personagem (characters/*.png).
const JUPITER_STAND := 0
const JUPITER_SAD := 1
const SOPHIE_STAND := 0
const SOPHIE_CROSSED := 1
const SOPHIE_POINTING := 2
const SOPHIE_HOLDING := 3

const WALK_TIME := 1.4

@onready var _jupiter: Sprite2D = $Jupiter
@onready var _sophie: Sprite2D = $Sophie
@onready var _telescope: Sprite2D = $Telescope
@onready var _door: Marker2D = $Door
@onready var _sophie_stop: Marker2D = $SophieStop


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Dois anos atrás", 2.8)
	Transition.fade_in(2.0)
	await wait(2.2)
	await say(JUPITER, "Dá pra ver os anéis de Saturno hoje... o vovô ia adorar.")
	end_conversation()
	_sophie.global_position = _door.global_position
	_sophie.show()
	await move(_sophie, _sophie_stop.global_position, WALK_TIME)
	await say(SOPHIE, "Jupiter. Já passou da meia-noite.")
	_jupiter.flip_h = true
	await say(JUPITER, "Desculpa... é que Saturno tá bem alto hoje.")
	_sophie.frame = SOPHIE_CROSSED
	await say(SOPHIE, "Saturno.")
	await say(SOPHIE, "Você tem prova amanhã e tá aqui olhando pro céu de novo.")
	await say(JUPITER, "O vovô disse que um dia eu posso ser astronauta.")
	_sophie.frame = SOPHIE_POINTING
	await say(SOPHIE, "Astronauta? Você não consegue nem acordar na hora da escola.")
	await say(SOPHIE, "Seu avô subiu uma vez e passou o resto da vida olhando pra cima. Não vou deixar você fazer o mesmo.")
	await say(JUPITER, "Mas...")
	_sophie.frame = SOPHIE_STAND
	await say(SOPHIE, "Isso aqui fica comigo.")
	end_conversation()
	await move(_sophie, _telescope.global_position + Vector2(10, 0), WALK_TIME * 0.5)
	_telescope.hide()
	_sophie.frame = SOPHIE_HOLDING
	await wait(0.5)
	await say(JUPITER, "Não! É do vovô!")
	_sophie.flip_h = false
	await say(SOPHIE, "Então ele que venha buscar.")
	end_conversation()
	await move(_sophie, _door.global_position, WALK_TIME)
	_sophie.hide()
	await wait(1.0)
	_jupiter.flip_h = false
	_jupiter.frame = JUPITER_SAD
	await wait(1.5)
	await say(null, "Eu não respondi.")
	await say(null, "Nunca respondi. Nenhuma vez.")
	end_conversation()
	await wait(1.0)
	await Transition.fade_out(2.5)
