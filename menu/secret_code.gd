class_name SecretCode
extends Node
## Escuta o teclado e avisa (`entered`) quando as últimas teclas apertadas formam
## SEQUENCE. Não consome as teclas: as setas continuam navegando no menu enquanto isso.

signal entered

## Cima, cima, baixo, baixo, esquerda, direita, esquerda, direita, B, A.
const SEQUENCE: Array[Key] = [KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, KEY_B, KEY_A]

var _recent: Array[Key] = []


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	_recent.append(key.keycode)
	if _recent.size() > SEQUENCE.size():
		_recent.pop_front()
	if _recent == SEQUENCE:
		_recent.clear()
		entered.emit()
