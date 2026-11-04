class_name HUD
extends CanvasLayer
## Interface: vida em estrelas, mensagens e a dica de controles do começo.

const HINT_DURATION := 10.0
const DEFAULT_MESSAGE_DURATION := 2.5

@onready var _message: FadingLabel = $Message
@onready var _hint: FadingLabel = $Hint


func _ready() -> void:
	_hint.show_text(_hint.text, HINT_DURATION)


func show_message(text: String, duration := DEFAULT_MESSAGE_DURATION) -> void:
	_message.show_text(text, duration)
