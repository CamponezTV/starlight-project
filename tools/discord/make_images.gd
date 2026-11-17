extends SceneTree
## Gera as imagens do status no Discord em tools/discord/images/: uma por capítulo (um
## recorte quadrado da arte do jogo, com o nome do arquivo da cena) e o logo. Envie todas
## no Developer Portal, em Rich Presence > Art Assets: o nome do arquivo vira a chave, que
## é a que o autoload Presence usa. Rode depois de mudar a campanha ou a arte:
##   godot --headless -s res://tools/discord/make_images.gd

const OUT_DIR := "res://tools/discord/images"
const CROP := 176 ## Lado do recorte, em pixels do jogo.
const SCALE := 6 ## Ampliação sem borrar: 176 × 6 = 1056 px (o Discord pede ao menos 1024).
const LOGO := "res://menu/art/logo.png"
const SOPHIE := "res://entities/sophie_boss/sophie_shadow.png"
const SOPHIE_EYES := "res://entities/sophie_boss/sophie_eyes.png"
const SOPHIE_FRAME := Vector2i(96, 112)
const SOPHIE_SKY := [Color("12060f"), Color("3a0a1c")] ## Do alto para baixo.

## Imagem -> [arte de fundo, centro do recorte no eixo x].
const CROPS := {
	"stargazing": ["res://cutscenes/art/hill_wide.png", 236],
	"hospital": ["res://cutscenes/art/hospital_wide.png", 176],
	"funeral": ["res://cutscenes/art/funeral_wide.png", 176],
	"mountain": ["res://cutscenes/art/summit_wide.png", 252],
	"level_01": ["res://cutscenes/art/cave_wide.png", 176],
	"sophie_memory": ["res://cutscenes/art/bedroom_wide.png", 176],
	"level_02": ["res://cutscenes/art/cave_wide.png", 264],
	"level_03": ["res://cutscenes/art/hut_wide.png", 176],
	"after_sophie": ["res://cutscenes/art/void_wide.png", 176],
	"spider_memory": ["res://cutscenes/art/shed_wide.png", 176],
	"credits": ["res://cutscenes/art/hill_wide.png", 120],
	"logo": ["res://levels/backgrounds/night_sky.png", 160],
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for key: String in CROPS:
		var image := _crop(CROPS[key][0], CROPS[key][1])
		if key == "logo":
			_stamp_centered(image, _load(LOGO), CROP / 2)
		_save(image, key)
	_save(_sophie(), "boss_sophie")
	print("imagens do Discord em %s" % OUT_DIR)
	quit()


func _load(path: String) -> Image:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	image.convert(Image.FORMAT_RGBA8)
	return image


## Quadrado de CROP × CROP da arte, centrado em `center_x` (preso às bordas da arte).
func _crop(path: String, center_x: int) -> Image:
	var art := _load(path)
	var x := clampi(center_x - CROP / 2, 0, art.get_width() - CROP)
	var y := maxi(art.get_height() - CROP, 0) / 2
	return art.get_region(Rect2i(x, y, CROP, mini(CROP, art.get_height())))


## A sombra da Sophie, com os olhos acesos, sobre um escuro avermelhado.
func _sophie() -> Image:
	var image := Image.create_empty(CROP, CROP, false, Image.FORMAT_RGBA8)
	for y in CROP:
		var color: Color = SOPHIE_SKY[0].lerp(SOPHIE_SKY[1], float(y) / CROP)
		for x in CROP:
			image.set_pixel(x, y, color)
	var frame := Rect2i(Vector2i.ZERO, SOPHIE_FRAME)
	var at := Vector2i((CROP - SOPHIE_FRAME.x) / 2, CROP - SOPHIE_FRAME.y)
	image.blend_rect(_load(SOPHIE), frame, at)
	image.blend_rect(_load(SOPHIE_EYES), frame, at)
	return image


func _stamp_centered(image: Image, stamp: Image, center_y: int) -> void:
	var at := Vector2i((image.get_width() - stamp.get_width()) / 2, center_y - stamp.get_height() / 2)
	image.blend_rect(stamp, Rect2i(Vector2i.ZERO, stamp.get_size()), at)


func _save(image: Image, key: String) -> void:
	image.resize(image.get_width() * SCALE, image.get_height() * SCALE, Image.INTERPOLATE_NEAREST)
	var path := ProjectSettings.globalize_path("%s/%s.png" % [OUT_DIR, key])
	assert(image.save_png(path) == OK, path)
