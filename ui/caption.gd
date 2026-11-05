class_name Caption
extends CanvasLayer
## Texto grande no meio da tela, que aparece e some sozinho (títulos de cutscene).
## Fica acima da cortina do Transition, então aparece até com a tela preta.

@onready var _label: FadingLabel = $Label


func show_text(text: String, duration: float) -> void:
	_label.show_text(text, duration)
