class_name OptionRow
extends Button
## Uma linha de configuração: o nome à esquerda e o valor à direita, entre setas.
## Esquerda e direita trocam o valor; confirmar (ou o clique) avança. Quem usa decide o
## que cada passo faz (sinal `stepped`) e escreve o valor de volta em `value_text` ou,
## numa barra (`pips` > 0), em `filled`.

signal stepped(direction: int)

const VALUE_WIDTH := 84.0
const ARROW_LEFT := "<"
const ARROW_RIGHT := ">"
const PIP_SIZE := Vector2(5, 5)
const PIP_GAP := 2.0
const EMPTY_PIP_ALPHA := 0.25

@export var pips := 0 ## Maior que 0: o valor é uma barra com este tanto de quadradinhos.

var value_text := "":
	set(value):
		value_text = value
		queue_redraw()
var filled := 0:
	set(value):
		filled = value
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left", true):
		stepped.emit(-1)
		accept_event()
	elif event.is_action_pressed(&"ui_right", true):
		stepped.emit(1)
		accept_event()


func _pressed() -> void:
	stepped.emit(1)


func _draw() -> void:
	var font := get_theme_font(&"font")
	var font_size := get_theme_font_size(&"font_size")
	var color := get_theme_color(&"font_focus_color" if has_focus() else &"font_color")
	var outline := get_theme_color(&"font_outline_color")
	var outline_size := get_theme_constant(&"outline_size")
	var area := Rect2(size.x - VALUE_WIDTH, 0.0, VALUE_WIDTH, size.y)
	var baseline := (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	var arrow_width := font.get_string_size(ARROW_RIGHT, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var texts := [[ARROW_LEFT, area.position.x], [ARROW_RIGHT, area.end.x - arrow_width]]
	if pips <= 0:
		texts.append([value_text, area.position.x])
	for entry: Array in texts:
		var is_value: bool = entry[0] == value_text and pips <= 0
		var width := VALUE_WIDTH if is_value else -1.0
		var alignment := HORIZONTAL_ALIGNMENT_CENTER if is_value else HORIZONTAL_ALIGNMENT_LEFT
		var at := Vector2(entry[1], baseline)
		if outline_size > 0:
			draw_string_outline(font, at, entry[0], alignment, width, font_size, outline_size, outline)
		draw_string(font, at, entry[0], alignment, width, font_size, color)
	if pips > 0:
		_draw_pips(area, color)


func _draw_pips(area: Rect2, color: Color) -> void:
	var total := pips * PIP_SIZE.x + (pips - 1) * PIP_GAP
	var x := area.get_center().x - total / 2.0
	var y := area.get_center().y - PIP_SIZE.y / 2.0
	for i in pips:
		var pip_color := color if i < filled else Color(color, EMPTY_PIP_ALPHA)
		draw_rect(Rect2(Vector2(x, y).round(), PIP_SIZE), pip_color)
		x += PIP_SIZE.x + PIP_GAP
