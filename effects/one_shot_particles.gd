class_name OneShotParticles
extends CPUParticles2D
## Partículas de uma vez só (explosão da morte, poeira). Somem sozinhas ao terminar.


func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
