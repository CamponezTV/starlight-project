extends Cutscene
## Cut Scene 1: anos atrás, Jupiter criança e o avô olham as estrelas na colina, ao lado
## do telescópio. O avô conta o que são as estrelas, e os dois fazem uma promessa.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

## Quadros das folhas de personagem (characters/*.png).
const SIT := 2
const SIT_LOOKING_UP := 3

const OPENING_FADE := 2.5
const CLOSING_FADE := 2.5

@onready var _jupiter: Sprite2D = $Jupiter
@onready var _grandpa: Sprite2D = $Grandpa
@onready var _shooting_star: Sprite2D = $ShootingStar
@onready var _shooting_star_end: Marker2D = $ShootingStarEnd
@onready var _twinkle_sound: AudioStreamPlayer = $TwinkleSound


func _run() -> void:
	Transition.fade_out(0.0)
	Transition.fade_in(OPENING_FADE)
	await wait(OPENING_FADE + 0.5)
	await say(JUPITER, "Vovô?")
	_grandpa.flip_h = true
	await say(GRANDPA, "Fale, meu querido!")
	_jupiter.frame = SIT_LOOKING_UP
	await say(JUPITER, "O que são as estrelas?")
	_grandpa.frame = SIT_LOOKING_UP
	await say(GRANDPA, "As estrelas, meu neto, são corpos astrais que vagam e iluminam o vazio do espaço.")
	await say(JUPITER, "Vovô... um dia eu vou poder chegar até elas?")
	_grandpa.frame = SIT
	await say(GRANDPA, "Quem sabe um dia você não vira um astronauta e busca uma delas pra mim?")
	_jupiter.frame = SIT
	await say(JUPITER, "Sim, vovô! Um dia eu vou ser astronauta e vou buscar todas as estrelas pro senhor!")
	await say(GRANDPA, "Vá com calma, meu neto. O céu tem milhares de estrelas...")
	await say(GRANDPA, "Se for buscar todas pra mim, você vai acabar passando uma eternidade no espaço.")
	await say(JUPITER, "Então, quando eu crescer e virar astronauta que nem o senhor, a gente vai junto buscar as estrelas.")
	end_conversation()
	_grandpa.flip_h = false
	_grandpa.frame = SIT_LOOKING_UP
	_jupiter.frame = SIT_LOOKING_UP
	await wait(1.0)
	await _shoot_star()
	await wait(0.6)
	await say(GRANDPA, "Quem sabe um dia, meu neto...")
	await say(GRANDPA, "Quem sabe.")
	end_conversation()
	await wait(1.5)
	await Transition.fade_out(CLOSING_FADE)


## Uma estrela cadente risca o céu.
func _shoot_star() -> void:
	_shooting_star.show()
	_twinkle_sound.play()
	var tween := create_tween().set_parallel()
	tween.tween_property(_shooting_star, "global_position", _shooting_star_end.global_position, 1.1)
	tween.tween_property(_shooting_star, "modulate:a", 0.0, 1.1).set_ease(Tween.EASE_IN)
	await tween.finished
