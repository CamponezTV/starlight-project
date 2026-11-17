class_name MemorySpot
extends Area2D
## Um ponto da trilha que faz o Jupiter lembrar de alguma coisa: na primeira vez que ele
## passa, `text` aparece como pensamento na tela (quem mostra é a cena da montanha).

signal recalled(text: String)

@export_multiline var text := ""

var _was_recalled := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not _was_recalled:
		_was_recalled = true
		recalled.emit(text)
