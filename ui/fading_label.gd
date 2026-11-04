class_name FadingLabel
extends Label
## Texto que aparece e some sozinho depois de um tempo.

const FADE_TIME := 0.5

@export_range(0.0, 1.0) var max_alpha := 1.0

var _tween: Tween


func _ready() -> void:
	modulate.a = 0.0


func show_text(message: String, duration: float) -> void:
	text = message
	if _tween != null:
		_tween.kill()
	modulate.a = max_alpha
	_tween = create_tween()
	_tween.tween_interval(maxf(duration - FADE_TIME, 0.0))
	_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
