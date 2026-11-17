class_name HUD
extends CanvasLayer
## Interface: estrelas perdidas da fase, mensagens, barra do chefe e a dica de controles.

const HINT_DURATION := 10.0
const DEFAULT_MESSAGE_DURATION := 2.5
const CONTROLS_BASE := "Setas: mover   Espaço: pular"
const CONTROLS_DASH := "   X: dash"
const CONTROLS_MENU := "   R: checkpoint   Esc: pausa"
const PIP_SIZE := Vector2(14, 4)
const PIP_FULL := Color(1, 0.35, 0.42)
const PIP_EMPTY := Color(0.24, 0.14, 0.26)

@onready var _stars: StarCounter = $Stars
@onready var _message: FadingLabel = $Message
@onready var _hint: FadingLabel = $Hint
@onready var _boss_bar: Control = $BossBar
@onready var _boss_name: Label = $BossBar/Name
@onready var _boss_pips: HBoxContainer = $BossBar/Pips


## Mostra por um tempo os controles que o Jupiter tem agora (o dash só depois do broche).
func show_controls(has_dash: bool) -> void:
	_hint.show_text(CONTROLS_BASE + (CONTROLS_DASH if has_dash else "") + CONTROLS_MENU, HINT_DURATION)


## Estrelas perdidas guardadas / que a fase tem.
func set_stars(found: int, total: int) -> void:
	_stars.show_count(found, total)


## Mostra a barra de vida do chefe, cheia, com um traço por ponto de vida.
func show_boss(boss_name: String, max_health: int) -> void:
	_boss_name.text = boss_name
	for pip in _boss_pips.get_children():
		pip.queue_free()
	for i in max_health:
		var pip := ColorRect.new()
		pip.custom_minimum_size = PIP_SIZE
		pip.color = PIP_FULL
		_boss_pips.add_child(pip)
	_boss_bar.show()


func set_boss_health(health: int) -> void:
	var pips := _boss_pips.get_children().filter(func(pip: Node) -> bool: return not pip.is_queued_for_deletion())
	for i in pips.size():
		(pips[i] as ColorRect).color = PIP_FULL if i < health else PIP_EMPTY


func show_message(text: String, duration := DEFAULT_MESSAGE_DURATION) -> void:
	_message.show_text(text, duration)
