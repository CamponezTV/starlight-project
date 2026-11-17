class_name LevelComplete
extends CanvasLayer
## Fim de fase: a luz do portal toma a tela, vira céu estrelado e mostra o resumo
## (estrelas guardadas, quedas e tempo). O jogador confirma para seguir.

signal _confirmed

const IRIS_TIME := 0.8
const IRIS_RADIUS := 380.0 ## Cobre a tela a partir de qualquer canto.
const SKY_TIME := 1.1
const LINE_FADE := 0.4
const STAR_GAP := 0.28 ## Entre uma estrela contada e a próxima.
const STAR_POP := Vector2(1.6, 1.6)
const STAR_SIZE := Vector2(20, 20)
const READ_TIME := 0.5
const PROMPT_BLINK := 0.6
const CONFIRM_ACTIONS: Array[StringName] = [&"jump", &"dash", &"ui_accept"]
const STATS_TEXT := "Quedas  %d        Tempo  %s"

@export var full_star: Texture2D
@export var empty_star: Texture2D

var _is_waiting := false

@onready var _iris: ColorRect = $Iris
@onready var _sky: Control = $Sky
@onready var _title: Label = $Card/Title
@onready var _message: Label = $Card/Message
@onready var _stars: HBoxContainer = $Card/Stars
@onready var _stats: Label = $Card/Stats
@onready var _prompt: Label = $Prompt
@onready var _reveal_sound: AudioStreamPlayer = $RevealSound
@onready var _star_sound: AudioStreamPlayer = $StarSound


func _ready() -> void:
	hide()


func is_open() -> bool:
	return visible


## Mostra o resumo, com a luz nascendo em `focus` (posição na tela). Com `await`, espera o
## jogador confirmar.
func present(summary: LevelSummary, focus: Vector2) -> void:
	_title.text = summary.title
	_title.visible = not summary.title.is_empty()
	_message.text = summary.message
	_stats.text = tr(STATS_TEXT) % [summary.deaths, format_time(summary.seconds)]
	var icons := _build_stars(summary.star_total)
	for item: Control in [_sky, _title, _message, _stars, _stats, _prompt]:
		item.modulate.a = 0.0
	(_iris.material as ShaderMaterial).set_shader_parameter(&"center", focus)
	_set_iris_radius(0.0)
	_set_iris_opacity(1.0)
	show()
	var tween := create_tween()
	tween.tween_method(_set_iris_radius, 0.0, IRIS_RADIUS, IRIS_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_reveal_sound.play)
	tween.tween_property(_sky, "modulate:a", 1.0, 0.0)
	tween.tween_method(_set_iris_opacity, 1.0, 0.0, SKY_TIME)
	for item: Control in [_title, _message, _stars]:
		tween.tween_property(item, "modulate:a", 1.0, LINE_FADE)
	for i in mini(summary.stars_found, icons.size()):
		tween.tween_interval(STAR_GAP)
		tween.tween_callback(_light_star.bind(icons[i]))
	tween.tween_property(_stats, "modulate:a", 1.0, LINE_FADE)
	tween.tween_interval(READ_TIME)
	await tween.finished
	_is_waiting = true
	var blink := create_tween().set_loops()
	blink.tween_property(_prompt, "modulate:a", 1.0, PROMPT_BLINK)
	blink.tween_property(_prompt, "modulate:a", 0.3, PROMPT_BLINK)
	await _confirmed
	_is_waiting = false
	blink.kill()


## "3:07" para 187 segundos.
static func format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	return "%d:%02d" % [total / 60, total % 60]


func _input(event: InputEvent) -> void:
	if not _is_waiting:
		return
	for action in CONFIRM_ACTIONS:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			_confirmed.emit()
			return


## Um ícone apagado para cada estrela da fase.
func _build_stars(total: int) -> Array[TextureRect]:
	for old in _stars.get_children():
		old.queue_free()
	var icons: Array[TextureRect] = []
	for i in total:
		var icon := TextureRect.new()
		icon.texture = empty_star
		icon.custom_minimum_size = STAR_SIZE
		icon.pivot_offset = STAR_SIZE / 2.0
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stars.add_child(icon)
		icons.append(icon)
	_stars.visible = total > 0
	return icons


func _light_star(icon: TextureRect) -> void:
	icon.texture = full_star
	icon.scale = STAR_POP
	create_tween().tween_property(icon, "scale", Vector2.ONE, STAR_GAP).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_star_sound.play()


func _set_iris_opacity(opacity: float) -> void:
	(_iris.material as ShaderMaterial).set_shader_parameter(&"opacity", opacity)


func _set_iris_radius(radius: float) -> void:
	(_iris.material as ShaderMaterial).set_shader_parameter(&"radius", radius)
