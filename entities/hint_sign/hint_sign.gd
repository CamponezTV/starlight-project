@tool
class_name HintSign
extends Node2D
## Dica escrita no cenário (tutorial). Aparece devagar quando o Jupiter entra na área
## de detecção (Area) e some quando ele sai. O texto também aparece no editor.

const FADE_TIME := 0.4

@export_multiline var text := "Dica":
	set(value):
		text = value
		if is_node_ready():
			_label.text = value

var _tween: Tween

@onready var _label: Label = $Label
@onready var _area: Area2D = $Area


func _ready() -> void:
	_label.text = text
	if Engine.is_editor_hint():
		return
	_label.modulate.a = 0.0
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_fade_to(1.0)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_fade_to(0.0)


func _fade_to(alpha: float) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_label, "modulate:a", alpha, FADE_TIME)
