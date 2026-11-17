class_name TestHelpers
## Utilidades compartilhadas pelos testes.

const TILE := 8
const ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down", &"jump", &"dash"]
const TEST_SAVE := "user://test_progress.cfg"
const TEST_SETTINGS := "user://test_settings.cfg"

static var _real_save_path := ""


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


## Troca o arquivo de progresso por um vazio, só dos testes: estrelas guardadas e
## escolhas não tocam no progresso de quem está jogando. Desfaça com restore_save().
static func use_test_save() -> void:
	if _real_save_path.is_empty():
		_real_save_path = Story.save_path
	Story.save_path = TEST_SAVE
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))


static func restore_save() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	if not _real_save_path.is_empty():
		Story.save_path = _real_save_path
		_real_save_path = ""


## Configurações num arquivo só dos testes, no padrão (português, volume cheio, texto
## manual). Os ganchos do GUT já chamam isto; testes que mexem em Settings chamam de novo
## para valer também quando rodam pelo painel do editor.
static func use_test_settings() -> void:
	Settings.save_path = TEST_SETTINGS
	Settings.reset()
