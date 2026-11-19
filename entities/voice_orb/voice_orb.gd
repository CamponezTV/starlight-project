class_name VoiceOrb
extends RoomEntity
## Orbe de voz: a voz que o Jupiter nunca usou. Com ela, um dash quebra barreiras de
## palavras e atinge a Sophie. Pega, é sugada num estouro de faíscas e volta quando o
## RespawnTimer acaba (com `respawns` desligado, só volta no reset da fase). Com `skill`, a
## primeira vez que ela é pega na visita abre o holofote apresentando a voz.

signal collected
signal skill_learned(skill: Skill) ## Primeira vez que esta orbe é pega na visita (só com `skill`).

const ABSORB_TIME := 0.15 ## A orbe encolhe até sumir, como se o Jupiter a puxasse.
const RETURN_TIME := 0.35

@export var respawns := true
@export var skill: Skill ## O que o holofote mostra na primeira coleta (vazio = sem holofote).
@export var burst_effect: PackedScene

var _player_inside: Player
var _is_available := true
var _taught := false ## O holofote já apareceu nesta visita (o reset da fase não desfaz).
var _tween: Tween

@onready var _visual: Node2D = $Visual
@onready var _respawn_timer: Timer = $RespawnTimer
@onready var _collect_sound: AudioStreamPlayer = $CollectSound


func _ready() -> void:
	super()
	_respawn_timer.timeout.connect(_come_back)


func reset() -> void:
	_respawn_timer.stop()
	_set_available(true)


func is_available() -> bool:
	return _is_available


func _physics_process(_delta: float) -> void:
	if is_available() and _player_inside != null and _player_inside.gain_voice():
		_collect()


func _collect() -> void:
	_collect_sound.play()
	_set_available(false)
	_burst()
	if respawns:
		_respawn_timer.start()
	collected.emit()
	if skill != null and not _taught:
		_taught = true
		skill_learned.emit(skill)


## Faíscas para todo lado e a orbe encolhendo até sumir.
func _burst() -> void:
	var effect := burst_effect.instantiate() as Node2D
	add_sibling(effect)
	effect.global_position = _visual.global_position
	effect.reset_physics_interpolation()
	_visual.show()
	_restart_tween().tween_property(_visual, "scale", Vector2.ZERO, ABSORB_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_visual.hide)


## Volta crescendo do nada.
func _come_back() -> void:
	_set_available(true)
	_visual.scale = Vector2.ZERO
	_restart_tween().tween_property(_visual, "scale", Vector2.ONE, RETURN_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _restart_tween() -> Tween:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	return _tween


func _on_player_entered(player: Player) -> void:
	_player_inside = player


func _on_player_exited(_player: Player) -> void:
	_player_inside = null


func _set_available(available: bool) -> void:
	if _tween != null:
		_tween.kill()
	_is_available = available
	_visual.visible = available
	_visual.scale = Vector2.ONE
