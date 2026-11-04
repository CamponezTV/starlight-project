class_name DashGhost
extends Sprite2D
## Silhueta que fica para trás durante o dash e some rápido.

const LIFETIME := 0.22


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, LIFETIME)
	tween.finished.connect(queue_free)
