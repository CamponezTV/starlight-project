class_name PauseMenu
extends CanvasLayer
## Pausa (Esc): continuar, voltar ao checkpoint ou ir ao menu principal.
## Pausa a árvore inteira; esta camada continua rodando (process_mode = Always).

signal checkpoint_requested

@onready var _panel: Control = $Panel
@onready var _continue_button: Button = %ContinueButton
@onready var _checkpoint_button: Button = %CheckpointButton
@onready var _menu_button: Button = %MenuButton
@onready var _move_sound: AudioStreamPlayer = $MoveSound


func _ready() -> void:
	_panel.hide()
	_continue_button.pressed.connect(close)
	_checkpoint_button.pressed.connect(_on_checkpoint_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)
	for button: Button in [_continue_button, _checkpoint_button, _menu_button]:
		button.focus_entered.connect(_move_sound.play)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"quit"):
		get_viewport().set_input_as_handled()
		if is_open():
			close()
		else:
			open()


func is_open() -> bool:
	return _panel.visible


func open() -> void:
	get_tree().paused = true
	_panel.show()
	_continue_button.grab_focus.call_deferred()


func close() -> void:
	_panel.hide()
	get_tree().paused = false


func _on_checkpoint_pressed() -> void:
	close()
	checkpoint_requested.emit()


func _on_menu_pressed() -> void:
	close()
	Story.back_to_menu()
