class_name TerrainDecor
extends Node2D
## Enfeita o terreno sozinho. Filho de uma TileMapLayer: olha cada bloco de rocha e
## sorteia (sempre igual para a mesma célula) tufos de musgo em cima, raízes e
## estalactites embaixo e brotos nas paredes. Cristais e cogumelos ganham um brilho.
## O atlas tem células de 8×8: linha 0 = tufos, cogumelo e flor; linha 1 = cristais e
## pedras; linha 2 = pendurados; linha 3 = laterais (desenhados para parede à esquerda).

const CELL := 8
const HASH_X := 73856093
const HASH_Y := 19349663
const HASH_SALT := 83492791
const HASH_MIX := 1274126177

const TUFTS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]
const MUSHROOM := Vector2i(6, 0)
const FLOWER := Vector2i(7, 0)
const CRYSTALS: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(5, 1)]
const PEBBLES: Array[Vector2i] = [Vector2i(3, 1), Vector2i(4, 1)]
const HANGING: Array[Vector2i] = [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(7, 2)]
const HANGING_CRYSTAL := Vector2i(6, 2)
const SIDES: Array[Vector2i] = [Vector2i(0, 3), Vector2i(1, 3), Vector2i(3, 3)]
const SIDE_CRYSTAL := Vector2i(2, 3)

## Sorteio do que nasce em cima de um bloco (de 0 a 99, limites superiores).
const TOP_TUFT := 74
const TOP_MUSHROOM := 80
const TOP_FLOWER := 86
const TOP_CRYSTAL := 93
const HANGING_CRYSTAL_CHANCE := 8
const SIDE_CRYSTAL_CHANCE := 12

const GLOW_SIZE := Vector2(22, 22)

@export var texture: Texture2D ## Atlas de decoração.
@export var glow_texture: Texture2D ## Mancha de luz suave dos cristais e cogumelos.
@export var hazards_path := ^"../../Hazards" ## Onde há espinhos, nada cresce.
@export_range(0, 100) var top_chance := 62 ## % dos blocos com algo em cima.
@export_range(0, 100) var hanging_chance := 38
@export_range(0, 100) var side_chance := 16
@export var crystal_glow := Color(1.0, 0.55, 0.9, 0.42)
@export var mushroom_glow := Color(1.0, 0.82, 0.45, 0.42)

var _pieces: Array[Dictionary] = [] ## {cell, atlas, flipped}
var _glows: Array[Dictionary] = [] ## {position, color}

@onready var _glow: Node2D = $Glow


func _ready() -> void:
	var terrain := get_parent() as TileMapLayer
	assert(terrain != null, "TerrainDecor precisa ser filho de uma TileMapLayer.")
	var hazards := get_node_or_null(hazards_path) as TileMapLayer
	for cell in terrain.get_used_cells():
		_decorate(cell, terrain, hazards)
	_glow.draw.connect(_draw_glows)
	queue_redraw()
	_glow.queue_redraw()


## Quantos enfeites foram sorteados.
func piece_count() -> int:
	return _pieces.size()


## Células onde há um enfeite.
func decorated_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for piece in _pieces:
		result.append(piece["cell"])
	return result


func _decorate(cell: Vector2i, terrain: TileMapLayer, hazards: TileMapLayer) -> void:
	var pick := _roll(cell, 1)
	var mirrored := pick % 2 == 0
	var above := cell + Vector2i.UP
	if _is_free(above, terrain, hazards) and _roll(cell, 0) < top_chance:
		var kind := _roll(cell, 2)
		if kind < TOP_TUFT:
			_add(above, TUFTS[pick % TUFTS.size()], mirrored)
		elif kind < TOP_MUSHROOM:
			_add(above, MUSHROOM, mirrored, mushroom_glow, Vector2(4, 4))
		elif kind < TOP_FLOWER:
			_add(above, FLOWER, mirrored)
		elif kind < TOP_CRYSTAL:
			_add(above, CRYSTALS[pick % CRYSTALS.size()], mirrored, crystal_glow, Vector2(4, 5))
		else:
			_add(above, PEBBLES[pick % PEBBLES.size()], mirrored)
	var below := cell + Vector2i.DOWN
	if _is_free(below, terrain, hazards) and _roll(cell, 3) < hanging_chance:
		if _roll(cell, 4) < HANGING_CRYSTAL_CHANCE:
			_add(below, HANGING_CRYSTAL, false, crystal_glow, Vector2(4, 2))
		else:
			_add(below, HANGING[pick % HANGING.size()], mirrored)
	for side: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT]:
		var beside := cell + side
		if _is_free(beside, terrain, hazards) and _roll(cell, 6 + side.x) < side_chance:
			var flipped := side == Vector2i.LEFT
			if _roll(cell, 8) < SIDE_CRYSTAL_CHANCE:
				_add(beside, SIDE_CRYSTAL, flipped, crystal_glow, Vector2(6 if flipped else 2, 3))
			else:
				_add(beside, SIDES[pick % SIDES.size()], flipped)


func _is_free(cell: Vector2i, terrain: TileMapLayer, hazards: TileMapLayer) -> bool:
	if terrain.get_cell_source_id(cell) != -1:
		return false
	return hazards == null or hazards.get_cell_source_id(cell) == -1


## Número de 0 a 99, sempre o mesmo para a mesma célula e o mesmo `salt`.
func _roll(cell: Vector2i, salt: int) -> int:
	var mixed := (cell.x * HASH_X) ^ (cell.y * HASH_Y) ^ (salt * HASH_SALT)
	mixed = (mixed ^ (mixed >> 13)) * HASH_MIX
	return absi((mixed ^ (mixed >> 16)) % 100)


func _add(cell: Vector2i, atlas: Vector2i, flipped: bool, glow := Color.TRANSPARENT, glow_offset := Vector2.ZERO) -> void:
	_pieces.append({"cell": cell, "atlas": atlas, "flipped": flipped})
	if glow.a > 0.0:
		_glows.append({"position": Vector2(cell * CELL) + glow_offset, "color": glow})


func _draw() -> void:
	if texture == null:
		return
	for piece in _pieces:
		var cell: Vector2i = piece["cell"]
		var atlas: Vector2i = piece["atlas"]
		var target := Rect2(Vector2(cell * CELL), Vector2(CELL, CELL))
		if piece["flipped"]:
			target = Rect2(target.position + Vector2(CELL, 0), Vector2(-CELL, CELL))
		draw_texture_rect_region(texture, target, Rect2(Vector2(atlas * CELL), Vector2(CELL, CELL)))


func _draw_glows() -> void:
	if glow_texture == null:
		return
	for glow in _glows:
		var center: Vector2 = glow["position"]
		_glow.draw_texture_rect(glow_texture, Rect2(center - GLOW_SIZE / 2.0, GLOW_SIZE), false, glow["color"])
