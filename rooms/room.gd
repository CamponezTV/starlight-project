class_name Room
extends Node2D
## Uma sala da caverna. Terreno e espinhos são pintados nas TileMapLayers,
## os objetos ficam dentro de Entities e o início é o Marker2D Spawn.
## A sala conecta os objetos sozinha e repassa os eventos deles para quem a usa.

signal checkpoint_reached(respawn_point: Vector2)
signal star_collected
signal exit_reached

const FALL_DEATH_MARGIN := 24.0 ## Pixels abaixo da sala em que a queda mata.

@onready var _terrain: TileMapLayer = $Terrain
@onready var _spawn: Marker2D = $Spawn
@onready var _entities: Node2D = $Entities


func _ready() -> void:
	for entity in _room_entities():
		_connect_entity(entity)


func spawn_point() -> Vector2:
	return _spawn.global_position


## Área ocupada pelo terreno, em pixels (usada nos limites da câmera).
func bounds() -> Rect2:
	var used := Rect2(_terrain.get_used_rect())
	var tile_size := Vector2(_terrain.tile_set.tile_size)
	return Rect2(used.position * tile_size, used.size * tile_size)


func kill_height() -> float:
	return bounds().end.y + FALL_DEATH_MARGIN


## Volta todos os objetos ao estado inicial.
func reset_entities() -> void:
	for entity in _room_entities():
		entity.reset()


func _room_entities() -> Array[RoomEntity]:
	var result: Array[RoomEntity] = []
	for child in _entities.get_children():
		if child is RoomEntity:
			result.append(child)
	return result


func _connect_entity(entity: RoomEntity) -> void:
	if entity is StarPickup:
		(entity as StarPickup).collected.connect(star_collected.emit)
	elif entity is Checkpoint:
		(entity as Checkpoint).activated.connect(checkpoint_reached.emit)
	elif entity is RoomExit:
		(entity as RoomExit).reached.connect(exit_reached.emit)
