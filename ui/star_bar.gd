class_name StarBar
extends HBoxContainer
## Vida no canto da tela: um ícone cheio ou vazio para cada estrela possível.

@export var full_texture: Texture2D
@export var empty_texture: Texture2D


func _ready() -> void:
	for i in Stars.MAX_COUNT:
		var icon := TextureRect.new()
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(icon)
	Stars.changed.connect(_on_stars_changed)
	_on_stars_changed(Stars.count)


func _on_stars_changed(count: int) -> void:
	for i in get_child_count():
		var icon := get_child(i) as TextureRect
		icon.texture = full_texture if i < count else empty_texture
