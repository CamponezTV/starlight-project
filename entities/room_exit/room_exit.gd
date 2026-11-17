class_name RoomExit
extends RoomEntity
## Saída da fase: um portal de pedra com um véu de luz. Avisa uma vez só. Quem chama
## absorb() vê o Jupiter ser puxado para dentro da luz.

signal reached

const CORE := Vector2(0, -22) ## Do pé do portal ao meio do véu.
const ABSORB_TIME := 1.2
const ABSORBED_SCALE := Vector2(0.1, 0.1)
const ABSORBED_TINT := Color(1.0, 0.97, 0.84, 0.0)
const FLARE_ENERGY := 3.5
const FLARE_POWER := 2.5

var _is_open := true

@onready var _light: PointLight2D = $Light
@onready var _veil: Sprite2D = $Veil
@onready var _inflow: CPUParticles2D = $Inflow
@onready var _reached_sound: AudioStreamPlayer = $ReachedSound
@onready var _absorb_sound: AudioStreamPlayer = $AbsorbSound


## O meio do véu, no mundo.
func core() -> Vector2:
	return global_position + CORE


## Puxa `body` para o meio do véu, encolhendo e virando luz. Com `await`, espera terminar.
func absorb(body: Node2D) -> void:
	_absorb_sound.play()
	_inflow.emitting = true
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(body, "global_position", core(), ABSORB_TIME)
	tween.tween_property(body, "scale", ABSORBED_SCALE, ABSORB_TIME)
	tween.tween_property(body, "modulate", ABSORBED_TINT, ABSORB_TIME)
	tween.tween_property(_light, "energy", FLARE_ENERGY, ABSORB_TIME)
	tween.tween_method(_set_veil_power, 1.0, FLARE_POWER, ABSORB_TIME)
	await tween.finished


func _on_player_entered(_player: Player) -> void:
	if _is_open:
		_is_open = false
		_reached_sound.play()
		reached.emit()


func _set_veil_power(power: float) -> void:
	(_veil.material as ShaderMaterial).set_shader_parameter(&"power", power)
