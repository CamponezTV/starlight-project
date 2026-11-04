class_name DeathBurst
extends CPUParticles2D
## Explosão de partículas de uma vez só. Some sozinha ao terminar.


func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
