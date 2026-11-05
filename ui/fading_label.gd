class_name FadingLabel
extends Label
## Texto que aparece e some sozinho depois de um tempo.

const FADE_TIME := 0.5

@export_range(0.0, 1.0) var max_alpha := 1.0
@export var fade_in_time := 0.0 ## 0 = aparece de uma vez.

var _tween: Tween


func _ready() -> void:
	modulate.a = 0.0


func show_text(message: String, duration: float) -> void:
	text = message
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	if fade_in_time > 0.0:
		modulate.a = 0.0
		_tween.tween_property(self, "modulate:a", max_alpha, fade_in_time)
	else:
		modulate.a = max_alpha
	_tween.tween_interval(maxf(duration - fade_in_time - FADE_TIME, 0.0))
	_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
