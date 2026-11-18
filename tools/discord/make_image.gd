extends SceneTree
## Exporta o ícone do jogo para o Discord: tools/discord/images/icon.png, ampliado sem
## borrar até 1024 px (o Discord pede ao menos 512). Envie no Developer Portal, em Rich
## Presence > Art Assets; o nome do arquivo vira a chave que o autoload Presence usa.
##   godot --headless -s res://tools/discord/make_image.gd

const ICON := "res://icon.png"
const OUT := "res://tools/discord/images/icon.png"
const SIZE := 1024


func _initialize() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(ICON))
	image.resize(SIZE, SIZE, Image.INTERPOLATE_NEAREST)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT.get_base_dir()))
	assert(image.save_png(ProjectSettings.globalize_path(OUT)) == OK)
	print("ícone do Discord em %s" % OUT)
	quit()
