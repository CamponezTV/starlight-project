class_name JupiterVisual
extends Node2D
## Visual do Jupiter: vira para o lado certo, deforma no pulo e no pouso
## e troca o quadro do broche de estrela (aceso = dash disponível).

enum Frame { DASH_READY, DASH_SPENT }

const SQUASH_RECOVERY := 14.0

var facing := 1
var dash_ready := true

var _squash := Vector2.ONE

@onready var _sprite: Sprite2D = $Sprite


## Deforma por um instante (pulo, pouso etc.). Volta ao normal sozinho.
func squash(amount: Vector2) -> void:
	_squash = amount


func _process(delta: float) -> void:
	_squash = _squash.lerp(Vector2.ONE, 1.0 - exp(-SQUASH_RECOVERY * delta))
	scale = Vector2(_squash.x * facing, _squash.y)
	_sprite.frame = Frame.DASH_READY if dash_ready else Frame.DASH_SPENT
