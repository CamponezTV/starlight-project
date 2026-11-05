class_name WordProjectile
extends AnimatableBody2D
## Palavra arremessada pela Sophie: um corpo na camada de perigos que voa em linha reta.
## A colisão acompanha o tamanho do texto (um pouco menor, para ser justa).

const LIFETIME := 9.0
const HITBOX_MARGIN := Vector2(4, 4)

var text := ""
var velocity := Vector2.ZERO

var _age := 0.0

@onready var _label: Label = $Label
@onready var _collision: CollisionShape2D = $Collision


func _ready() -> void:
	_label.text = text
	var size := _label.get_minimum_size()
	_label.size = size
	_label.position = -size / 2.0
	(_collision.shape as RectangleShape2D).size = (size - HITBOX_MARGIN).max(Vector2.ONE)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()


## Tamanho da caixa de colisão (para testes e para a Sophie posicionar as palavras).
func hitbox_size() -> Vector2:
	return (_collision.shape as RectangleShape2D).size
