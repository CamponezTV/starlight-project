extends GutTest
## Mede a movimentação do Jupiter com controles simulados.
## Garante que a sala continua possível quando o "feel" é ajustado no Inspetor.

const PLAYER_SCENE := preload("res://player/player.tscn")
const ROOM_SCENE := preload("res://levels/test_room.tscn")
const TILESET := preload("res://levels/tilesets/cave_tileset.tres")
const TILE := TestHelpers.TILE
const ROCK_TILE := Vector2i(0, 0)
const MAX_FRAMES := 600

## Sala plana de 40x11 células com chão no topo da linha 9 (y = 72).
const FLAT_WIDTH := 40
const FLAT_FLOOR_ROW := 9
const FLAT_FLOOR_Y := FLAT_FLOOR_ROW * TILE

## O maior vão da room_01 (seção D) tem 9 blocos.
const WIDEST_GAP := 9.0 * TILE
const SHAFT_BOTTOM := Vector2i(45, 23)
const SHAFT_LEDGE := Vector2(47 * TILE, 9 * TILE)


func after_each() -> void:
	TestHelpers.release_all_actions()


func test_held_jump_rises_three_to_four_tiles() -> void:
	var player := await _spawn_on_flat_floor(20)
	assert_between(await _jump_height(player, MAX_FRAMES), 3.0 * TILE, 4.0 * TILE)


func test_tapped_jump_is_much_lower_than_held_jump() -> void:
	var player := await _spawn_on_flat_floor(20)
	var held := await _jump_height(player, MAX_FRAMES)
	await wait_physics_frames(5)
	var tapped := await _jump_height(player, 1)
	assert_lt(tapped, held * 0.6, "toque: %.1f px, segurado: %.1f px" % [tapped, held])


func test_running_jump_gets_a_forward_boost() -> void:
	var player := await _spawn_on_flat_floor(3)
	Input.action_press(&"move_right")
	await wait_physics_frames(30)
	Input.action_press(&"jump")
	await wait_physics_frames(2)
	assert_gt(player.velocity.x, player.run_speed)


## Pular rente a uma quina do teto (1 px de sobreposição) desliza em vez de bater a cabeça.
func test_jump_slides_around_ceiling_corner() -> void:
	const BLOCK := Vector2i(20, 6)
	var player := await _spawn_on_flat_floor(20, [BLOCK])
	player.respawn(Vector2((BLOCK.x + 1) * TILE + 2, FLAT_FLOOR_Y))
	await wait_physics_frames(3)
	var block_bottom := (BLOCK.y + 1) * TILE
	var start_y := player.global_position.y
	var peak_feet := start_y - await _jump_height(player, MAX_FRAMES)
	assert_lt(peak_feet, float(block_bottom), "a cabeça deveria passar pela quina")


## Regressão: o primeiro fantasma do dash aparecia vindo da origem da fase, porque a
## interpolação de física desenhava o caminho de (0, 0) até a posição dele.
## Efeitos parados não devem ser interpolados.
func test_dash_ghosts_are_not_interpolated() -> void:
	var player := await _spawn_on_flat_floor(20)
	Input.action_press(&"move_right")
	Input.action_press(&"dash")
	await wait_physics_frames(2)
	var ghosts := player.get_parent().get_children().filter(func(node: Node) -> bool: return node is DashGhost)
	assert_gt(ghosts.size(), 0)
	for ghost: DashGhost in ghosts:
		assert_false(ghost.is_physics_interpolated(), "o rastro não pode ser interpolado")
		assert_almost_eq(ghost.global_position.y, player.global_position.y, 1.0)


func test_death_burst_is_not_interpolated() -> void:
	var burst: Node2D = (load("res://effects/death_burst.tscn") as PackedScene).instantiate()
	add_child_autofree(burst)
	assert_false(burst.is_physics_interpolated())


func test_dash_travels_three_to_five_tiles() -> void:
	var player := await _spawn_on_flat_floor(10)
	var start_x := player.global_position.x
	Input.action_press(&"move_right")
	Input.action_press(&"dash")
	await wait_physics_frames(ceili(player.dash_duration * Engine.physics_ticks_per_second))
	assert_between(player.global_position.x - start_x, 3.0 * TILE, 5.0 * TILE)


func test_jump_plus_dash_clears_widest_gap_with_margin() -> void:
	var player := await _spawn_on_flat_floor(3)
	Input.action_press(&"move_right")
	await wait_physics_frames(30)
	var start_x := player.global_position.x
	Input.action_press(&"jump")
	await wait_physics_frames(2)
	while player.velocity.y < 0.0:
		await get_tree().physics_frame
	Input.action_press(&"dash")
	await get_tree().physics_frame
	Input.action_release(&"dash")
	while not player.is_on_floor():
		await get_tree().physics_frame
	assert_gt(player.global_position.x - start_x, WIDEST_GAP * 1.2)


## Um robô sobe o poço da seção C pulando de parede em parede.
func test_room_01_shaft_is_climbable_with_wall_jumps() -> void:
	add_child_autofree(ROOM_SCENE.instantiate())
	var player := await _spawn_player(TestHelpers.cell_feet(SHAFT_BOTTOM))
	var jump_hold_frames := 0
	var climbed := false
	for frame in MAX_FRAMES:
		var position := player.global_position
		var wall := player._touching_wall(player.is_on_floor())
		var above_ledge := position.y < SHAFT_LEDGE.y - 2.0
		var direction := _climb_direction(above_ledge, wall, player.velocity.x)
		TestHelpers.set_pressed(&"move_right", direction == 1)
		TestHelpers.set_pressed(&"move_left", direction == -1)
		if jump_hold_frames > 0:
			jump_hold_frames = (jump_hold_frames + 1) % 10
			TestHelpers.set_pressed(&"jump", jump_hold_frames > 0)
		elif not above_ledge and (player.is_on_floor() or wall != 0):
			jump_hold_frames = 1
			Input.action_press(&"jump")
		await get_tree().physics_frame
		if player.is_on_floor() and position.x >= SHAFT_LEDGE.x and position.y <= SHAFT_LEDGE.y + 0.5:
			climbed = true
			break
	assert_true(climbed, "o robô deveria chegar ao topo do poço")


# --- Infraestrutura ----------------------------------------------------------------

func _spawn_on_flat_floor(column: int, extra_blocks: Array[Vector2i] = []) -> Player:
	var terrain := TileMapLayer.new()
	terrain.tile_set = TILESET
	for x in FLAT_WIDTH:
		terrain.set_cell(Vector2i(x, FLAT_FLOOR_ROW), 0, ROCK_TILE)
		terrain.set_cell(Vector2i(x, 0), 0, ROCK_TILE)
	for y in FLAT_FLOOR_ROW:
		terrain.set_cell(Vector2i(0, y), 0, ROCK_TILE)
		terrain.set_cell(Vector2i(FLAT_WIDTH - 1, y), 0, ROCK_TILE)
	for block in extra_blocks:
		terrain.set_cell(block, 0, ROCK_TILE)
	add_child_autofree(terrain)
	return await _spawn_player(Vector2((column + 0.5) * TILE, FLAT_FLOOR_Y))


## Pula segurando o botão por `hold_frames` e devolve a altura máxima atingida (px).
func _jump_height(player: Player, hold_frames: int) -> float:
	var start_y := player.global_position.y
	var peak_y := start_y
	Input.action_press(&"jump")
	for frame in MAX_FRAMES:
		await get_tree().physics_frame
		if frame == hold_frames:
			Input.action_release(&"jump")
		peak_y = minf(peak_y, player.global_position.y)
		if frame > 5 and player.is_on_floor():
			break
	Input.action_release(&"jump")
	return start_y - peak_y


## O Jupiter fica dentro de um nó "mundo" liberado no fim do teste: os efeitos que ele
## cria como irmãos (poeira, rastro) somem junto.
func _spawn_player(at: Vector2) -> Player:
	var world := Node2D.new()
	add_child_autofree(world)
	var player: Player = PLAYER_SCENE.instantiate()
	world.add_child(player)
	player.respawn(at)
	await wait_physics_frames(3)
	return player


## Segue para a parede oposta; parado conta como direita; acima da borda, vai para a direita.
func _climb_direction(above_ledge: bool, wall: int, speed_x: float) -> int:
	if above_ledge or wall == -1:
		return 1
	if wall == 1:
		return -1
	return -1 if speed_x < 0.0 else 1
