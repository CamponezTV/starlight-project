class_name Level
extends Node2D
## Uma fase. Terreno e espinhos são pintados nas TileMapLayers, os objetos ficam em
## Entities e as salas (RoomZone) em Rooms. Cada sala define os limites da câmera e os
## pontos de renascimento. A fase conecta os objetos sozinha e repassa os eventos deles.

signal checkpoint_reached(respawn_point: Vector2)
signal star_collected
signal exit_reached ## Saída alcançada ou chefe derrotado: a fase acabou.
signal skill_unlocked(message: String) ## O Jupiter ganhou uma habilidade nesta fase.
signal shake_requested(amount: float) ## Algo na fase pede um tremor de câmera.
signal encounter_requested(encounter: Encounter) ## O Jupiter quer conversar com alguém.

@export var intro_message := "Siga a estrela..." ## Mostrada ao começar a fase (vazia = nada).
@export var end_message := "Fim da fase. Obrigado por jogar!" ## Mostrada ao chegar na saída.
@export var starts_with_dash := true ## Desligue nas fases em que o dash ainda vai ser encontrado.
@export var music: AudioStream ## Trilha da fase (vazia = silêncio).
@export var ambient_color := Color(0.64, 0.62, 0.8) ## Escuridão fora da luz da estrela.

@onready var _terrain: TileMapLayer = $Terrain
@onready var _spawn: Marker2D = $Spawn
@onready var _entities: Node2D = $Entities
@onready var _rooms: Node2D = $Rooms


func _ready() -> void:
	for entity in _room_entities():
		_connect_entity(entity)


## Onde o Jupiter começa a fase.
func spawn_point() -> Vector2:
	return _spawn.global_position


## A sala que contém o ponto, ou null se ele estiver fora de todas.
func room_at(point: Vector2) -> RoomZone:
	for child in _rooms.get_children():
		var room := child as RoomZone
		if room != null and room.contains(point):
			return room
	return null


## Área ocupada pelo terreno, em pixels.
func bounds() -> Rect2:
	var used := Rect2(_terrain.get_used_rect())
	var tile_size := Vector2(_terrain.tile_set.tile_size)
	return Rect2(used.position * tile_size, used.size * tile_size)


## Volta todos os objetos (e plataformas móveis) ao estado inicial.
func reset_entities() -> void:
	for entity in _room_entities():
		entity.reset()
	var platforms := get_node_or_null(^"Platforms")
	if platforms != null:
		for platform in platforms.get_children():
			(platform as MovingPlatform).reset()


## O chefe da fase, ou null se não houver.
func boss() -> SophieBoss:
	for entity in _room_entities():
		if entity is SophieBoss:
			return entity
	return null


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
	elif entity is DashUnlock:
		(entity as DashUnlock).collected.connect(skill_unlocked.emit)
	elif entity is Encounter:
		(entity as Encounter).requested.connect(encounter_requested.emit)
		(entity as Encounter).gifted.connect(star_collected.emit)
	elif entity is SophieBoss:
		(entity as SophieBoss).defeated.connect(exit_reached.emit)
		(entity as SophieBoss).shook.connect(shake_requested.emit)
