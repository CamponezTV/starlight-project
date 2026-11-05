class_name TestHelpers
## Utilidades compartilhadas pelos testes.

const TILE := 8
const ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down", &"jump", &"dash"]


## Pés de quem está na célula (centro da base), como os objetos são posicionados nas salas.
static func cell_feet(cell: Vector2i) -> Vector2:
	return Vector2((cell.x + 0.5) * TILE, (cell.y + 1) * TILE)


static func release_all_actions() -> void:
	for action in ACTIONS:
		Input.action_release(action)


static func set_pressed(action: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)


## Aperta e solta a ação como um evento (o que a interface e as caixas de diálogo escutam).
static func tap(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
