extends CanvasLayer
## Autoload "Transition": cortina preta por cima de tudo, para trocar de cena e
## para as cutscenes escurecerem e clarearem a tela.

const DEFAULT_DURATION := 0.6

var _tween: Tween

@onready var _curtain: ColorRect = $Curtain


## Escurece a tela. Com `await`, espera terminar.
func fade_out(duration := DEFAULT_DURATION) -> void:
	await _fade_to(1.0, duration)


## Clareia a tela. Com `await`, espera terminar.
func fade_in(duration := DEFAULT_DURATION) -> void:
	await _fade_to(0.0, duration)


func is_covering() -> bool:
	return _curtain.modulate.a > 0.0


func _fade_to(alpha: float, duration: float) -> void:
	if _tween != null:
		_tween.kill()
	if duration <= 0.0:
		_curtain.modulate.a = alpha
		return
	_tween = create_tween()
	_tween.tween_property(_curtain, "modulate:a", alpha, duration)
	await _tween.finished
