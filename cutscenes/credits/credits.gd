extends Cutscene
## Fim do pré-alpha: o céu da colina, o agradecimento e os créditos. Último passo da
## campanha por enquanto; depois dele o jogo volta ao menu.

const LINE_FADE := 1.2
const THANKS_TIME := 4.0
const CREDITS_TIME := 6.0

@onready var _thanks: Control = $Card/Thanks
@onready var _credits: Control = $Card/Credits


func _run() -> void:
	_thanks.modulate.a = 0.0
	_credits.modulate.a = 0.0
	Transition.fade_out(0.0)
	await Transition.fade_in(2.0)
	await _fade(_thanks, 1.0)
	await wait(THANKS_TIME)
	await _fade(_thanks, 0.0)
	await _fade(_credits, 1.0)
	await wait(CREDITS_TIME)
	await Transition.fade_out(2.0)


func _fade(item: Control, alpha: float) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(item, "modulate:a", alpha, LINE_FADE)
	await tween.finished
