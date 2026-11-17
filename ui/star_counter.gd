class_name StarCounter
extends HBoxContainer
## Estrelas perdidas da fase no canto da tela ("2/5"). Some em fases sem estrelas e dá um
## pulinho quando a contagem sobe.

const POP_SCALE := Vector2(1.6, 1.6)
const POP_TIME := 0.35

var _found := 0

@onready var _icon: TextureRect = $Icon
@onready var _label: Label = $Count


func show_count(found: int, total: int) -> void:
	visible = total > 0
	_label.text = "%d/%d" % [found, total]
	if found > _found:
		_icon.scale = POP_SCALE
		create_tween().tween_property(_icon, "scale", Vector2.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_found = found
