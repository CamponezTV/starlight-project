class_name RoomEntity
extends Area2D
## Base dos objetos de sala que reagem ao toque do Jupiter.
## A cena de cada objeto define colisão, sprite e luz; o script define só o comportamento.
## Subclasses sobrescrevem reset(), _on_player_entered() e _on_player_exited().


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Volta ao estado inicial (usado quando as estrelas acabam e a sala recomeça).
func reset() -> void:
	pass


func _on_player_entered(_player: Player) -> void:
	pass


func _on_player_exited(_player: Player) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_on_player_entered(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_on_player_exited(body as Player)
