class_name Backdrop
extends Node
## Fundo de uma fase: camadas com profundidade (Far) e poeira luminosa no ar (Air).
## Fica em CanvasLayers próprias, então a escuridão e as luzes da fase não o afetam.
## `tint` colore o fundo inteiro (cada fase tem o seu clima).

@export var tint := Color.WHITE:
	set(value):
		tint = value
		if is_node_ready():
			_tint.color = value

@onready var _tint: CanvasModulate = $Far/Tint


func _ready() -> void:
	_tint.color = tint
