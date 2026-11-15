class_name MovingPlatform
extends AnimatableBody2D
## Plataforma que vai e volta, suave, entre onde foi colocada e `travel`.
## Fica em Platforms (não em Entities): é um corpo sólido, não um objeto de toque.

@export var travel := Vector2(64, 0)
@export var period := 4.0 ## Segundos para ir e voltar.

var _origin := Vector2.ZERO
var _time := 0.0


func _ready() -> void:
	_origin = position


func reset() -> void:
	_time = 0.0


func _physics_process(delta: float) -> void:
	_time += delta
	position = _origin + travel * (0.5 - 0.5 * cos(TAU * _time / period))
