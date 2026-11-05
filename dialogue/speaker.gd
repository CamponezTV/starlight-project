class_name Speaker
extends Resource
## Quem fala numa caixa de diálogo: nome, cor do nome e tom da voz (o "blip" das letras).

@export var display_name := ""
@export var name_color := Color.WHITE
@export_range(0.5, 2.0) var voice_pitch := 1.0
