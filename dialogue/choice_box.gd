class_name ChoiceBox
extends CanvasLayer
## Respostas para o jogador escolher, ao lado da caixa de diálogo. Cima e baixo trocam a
## resposta marcada; pular (ou Enter) confirma.
## Uso: `var picked := await choice_box.choose(["Perdoar.", "Ir embora."])`.

signal chosen(index: int)

const UP_ACTIONS: Array[StringName] = [&"move_up", &"ui_up"]
const DOWN_ACTIONS: Array[StringName] = [&"move_down", &"ui_down"]
const CONFIRM_ACTIONS: Array[StringName] = [&"jump", &"ui_accept"]
const MARKER := ">"
const IDLE_COLOR := Color(0.62, 0.6, 0.78)
const SCREEN_MARGIN := 6.0
const DIALOGUE_HEIGHT := 46.0 ## Altura da DialogueBox: as respostas ficam coladas nela.
const GAP := 3.0

## No alto da tela, logo abaixo de uma DialogueBox que também está no alto.
@export var at_top := false

var _rows: Array[HBoxContainer] = []
var _selected := 0

@onready var _panel: PanelContainer = $Panel
@onready var _list: VBoxContainer = %List
@onready var _move_sound: AudioStreamPlayer = $MoveSound
@onready var _select_sound: AudioStreamPlayer = $SelectSound


func _ready() -> void:
	var edge := SCREEN_MARGIN + DIALOGUE_HEIGHT + GAP
	_panel.anchor_top = 0.0 if at_top else 1.0
	_panel.anchor_bottom = _panel.anchor_top
	_panel.offset_top = edge if at_top else -edge
	_panel.offset_bottom = _panel.offset_top
	_panel.grow_vertical = Control.GROW_DIRECTION_END if at_top else Control.GROW_DIRECTION_BEGIN
	_panel.hide()
	set_process_input(false)


## Mostra as respostas e espera o jogador confirmar uma. Devolve o índice dela.
func choose(options: PackedStringArray) -> int:
	assert(options.size() >= 2, "uma escolha precisa de pelo menos duas respostas")
	_build(options)
	_select(0)
	_shrink_to_fit()
	_panel.show()
	set_process_input(true)
	var index: int = await chosen
	return index


## Some sem escolher (a cena foi pulada).
func close() -> void:
	_panel.hide()
	set_process_input(false)


func is_open() -> bool:
	return _panel.visible


## A resposta marcada agora.
func selected() -> int:
	return _selected


func _build(options: PackedStringArray) -> void:
	for row in _rows:
		row.free()
	_rows.clear()
	for option in options:
		var row := HBoxContainer.new()
		var marker := Label.new()
		marker.text = MARKER
		var text := Label.new()
		text.text = option
		row.add_child(marker)
		row.add_child(text)
		_list.add_child(row)
		_rows.append(row)


## Encolhe o painel até as respostas novas, sem tirar do lugar o canto preso à tela
## (ele cresce para a esquerda e para longe da caixa de diálogo).
func _shrink_to_fit() -> void:
	_panel.offset_left = _panel.offset_right
	if at_top:
		_panel.offset_bottom = _panel.offset_top
	else:
		_panel.offset_top = _panel.offset_bottom


func _select(index: int) -> void:
	_selected = wrapi(index, 0, _rows.size())
	for i in _rows.size():
		var is_selected := i == _selected
		(_rows[i].get_child(0) as Label).modulate.a = 1.0 if is_selected else 0.0
		(_rows[i].get_child(1) as Label).modulate = Color.WHITE if is_selected else IDLE_COLOR


# _input (e não _unhandled_input) para responder antes da DialogueBox, que fica aberta
# com a pergunta e engoliria o botão de confirmar.
func _input(event: InputEvent) -> void:
	if _pressed(event, CONFIRM_ACTIONS):
		get_viewport().set_input_as_handled()
		_select_sound.play()
		close()
		chosen.emit(_selected)
	elif _pressed(event, UP_ACTIONS):
		_move(-1)
	elif _pressed(event, DOWN_ACTIONS):
		_move(1)


func _move(step: int) -> void:
	get_viewport().set_input_as_handled()
	_select(_selected + step)
	_move_sound.play()


func _pressed(event: InputEvent, actions: Array[StringName]) -> bool:
	for action in actions:
		if event.is_action_pressed(action, false):
			return true
	return false
