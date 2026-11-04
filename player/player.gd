class_name Player
extends CharacterBody2D
## Jupiter: movimentação de plataforma de precisão. Pulo variável, coyote time,
## buffer de pulo, deslizar/pular na parede e dash em 8 direções.
## A origem do nó fica nos pés. Os valores de "feel" são exportados para ajustar no Inspetor.
## Morre quando a Hurtbox toca a camada de perigos (espinhos pintados no TileMap).
## A Hurtbox precisa de `monitorable = true`: uma Area2D não monitorável não detecta
## corpos estáticos, e os tiles de um TileMapLayer são corpos estáticos.

signal died
signal dashed

enum State { NORMAL, DASHING, DEAD }

const GHOST_INTERVAL := 0.03
const APEX_GRAVITY_FACTOR := 0.5
const DEATH_EFFECT_OFFSET := Vector2(0, -6)
const JUMP_SQUASH := Vector2(0.7, 1.35)
const WALL_JUMP_SQUASH := Vector2(0.75, 1.3)
const LANDING_SQUASH := Vector2(1.35, 0.7)
const RESPAWN_SQUASH := Vector2(0.6, 1.4)
const LANDING_SOUND_MIN_SPEED := 60.0 ## Quedas mais lentas que isto pousam em silêncio.
const PITCH_VARIATION := 0.06 ## Variação de tom para sons repetitivos não cansarem.

@export_group("Corrida")
@export var run_speed := 90.0
@export var run_accel := 1000.0
@export var run_friction := 1200.0
@export var air_control := 0.65
@export var overspeed_decel := 400.0

@export_group("Pulo e gravidade")
@export var gravity := 900.0
@export var rise_gravity := 600.0 ## Gravidade subindo com o botão segurado.
@export var apex_speed_threshold := 30.0 ## Perto do topo do pulo a gravidade cai pela metade.
@export var max_fall_speed := 170.0
@export var fast_fall_speed := 240.0 ## Segurando para baixo.
@export var jump_speed := 180.0
@export var jump_cut_factor := 0.45 ## Soltar o pulo cedo multiplica a subida por isto.
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1

@export_group("Parede")
@export var wall_slide_speed := 45.0
@export var wall_jump_push := 130.0
@export var wall_jump_lock_time := 0.14 ## Tempo em que o empurrão da parede ignora o controle.
@export var wall_check_distance := 2.0

@export_group("Dash")
@export var dash_speed := 240.0
@export var dash_duration := 0.14
@export var dash_exit_speed := 160.0
@export var dash_cooldown := 0.2

@export_group("Efeitos")
@export var death_effect: PackedScene
@export var dash_ghost: PackedScene

var facing := 1
var can_dash := true

var _state := State.NORMAL
var _dash_direction := Vector2.ZERO
var _dash_time_left := 0.0
var _dash_cooldown_left := 0.0
var _coyote_left := 0.0
var _jump_buffer_left := 0.0
var _is_jump_rising := false
var _wall_lock_left := 0.0
var _wall_lock_direction := 0
var _ghost_time_left := 0.0
var _was_on_floor := false

@onready var _visual: JupiterVisual = $Visual
@onready var _jump_sound: AudioStreamPlayer = $JumpSound
@onready var _land_sound: AudioStreamPlayer = $LandSound
@onready var _dash_sound: AudioStreamPlayer = $DashSound
@onready var _death_sound: AudioStreamPlayer = $DeathSound


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return
	_buffer_jump_input(delta)
	_dash_cooldown_left -= delta
	match _state:
		State.NORMAL:
			_update_normal(delta)
		State.DASHING:
			_update_dashing(delta)
	var fall_speed := velocity.y
	move_and_slide()
	_check_landing(fall_speed)
	_update_visual()


# --- API pública -----------------------------------------------------------------

func is_dead() -> bool:
	return _state == State.DEAD


func die() -> void:
	if is_dead():
		return
	_state = State.DEAD
	velocity = Vector2.ZERO
	hide()
	_death_sound.play()
	var effect := _spawn_in_parent(death_effect)
	effect.global_position += DEATH_EFFECT_OFFSET
	died.emit()


func respawn(at: Vector2) -> void:
	global_position = at
	reset_physics_interpolation()
	velocity = Vector2.ZERO
	_state = State.NORMAL
	_is_jump_rising = false
	_wall_lock_left = 0.0
	_coyote_left = 0.0
	_jump_buffer_left = 0.0
	_dash_cooldown_left = 0.0
	can_dash = true
	show()
	_visual.squash(RESPAWN_SQUASH)


## Chamado por cristais. Retorna true se o dash estava gasto e foi recarregado.
func refill_dash() -> bool:
	if is_dead() or (can_dash and _state != State.DASHING):
		return false
	can_dash = true
	_dash_cooldown_left = 0.0
	return true


# --- Estado normal ---------------------------------------------------------------

func _update_normal(delta: float) -> void:
	var input := _read_move_input()
	var on_floor := is_on_floor()
	_update_ground_timers(on_floor, delta)

	if Input.is_action_just_pressed(&"dash") and _can_start_dash():
		_start_dash(input)
		return

	var wall := _touching_wall(on_floor)
	_apply_run(input.x, on_floor, delta)
	_apply_jump_cut()
	_apply_gravity(input, wall, on_floor, delta)
	_try_jump(wall)


func _read_move_input() -> Vector2i:
	return Vector2i(
		int(signf(Input.get_axis(&"move_left", &"move_right"))),
		int(signf(Input.get_axis(&"move_up", &"move_down"))))


func _buffer_jump_input(delta: float) -> void:
	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_left = jump_buffer_time
	else:
		_jump_buffer_left -= delta


func _update_ground_timers(on_floor: bool, delta: float) -> void:
	if on_floor:
		_coyote_left = coyote_time
		if _dash_cooldown_left <= 0.0:
			can_dash = true
	else:
		_coyote_left -= delta


func _apply_run(input_x: int, on_floor: bool, delta: float) -> void:
	var direction := input_x
	if _wall_lock_left > 0.0:
		_wall_lock_left -= delta
		direction = _wall_lock_direction
	if direction != 0:
		facing = direction

	var control := 1.0 if on_floor else air_control
	var target_speed := run_speed * direction
	var is_overspeeding := absf(velocity.x) > run_speed and signf(velocity.x) == direction
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0.0, run_friction * control * delta)
	elif is_overspeeding:
		velocity.x = move_toward(velocity.x, target_speed, overspeed_decel * control * delta)
	else:
		velocity.x = move_toward(velocity.x, target_speed, run_accel * control * delta)


func _apply_jump_cut() -> void:
	if _is_jump_rising and velocity.y < 0.0 and not Input.is_action_pressed(&"jump"):
		velocity.y *= jump_cut_factor
		_is_jump_rising = false
	elif velocity.y >= 0.0:
		_is_jump_rising = false


func _apply_gravity(input: Vector2i, wall: int, on_floor: bool, delta: float) -> void:
	if on_floor:
		return
	var holding_jump := Input.is_action_pressed(&"jump")
	var current_gravity := gravity
	if holding_jump and velocity.y < 0.0:
		current_gravity = rise_gravity
	if holding_jump and absf(velocity.y) < apex_speed_threshold:
		current_gravity *= APEX_GRAVITY_FACTOR
	velocity.y = move_toward(velocity.y, _max_fall_speed(input, wall), current_gravity * delta)


func _max_fall_speed(input: Vector2i, wall: int) -> float:
	var is_sliding_on_wall := wall != 0 and input.x == wall and velocity.y > 0.0
	if is_sliding_on_wall:
		return wall_slide_speed
	if input.y > 0:
		return fast_fall_speed
	return max_fall_speed


## -1 = parede à esquerda, 1 = à direita, 0 = nenhuma (ou no chão).
func _touching_wall(on_floor: bool) -> int:
	if on_floor:
		return 0
	if test_move(global_transform, Vector2(wall_check_distance, 0)):
		return 1
	if test_move(global_transform, Vector2(-wall_check_distance, 0)):
		return -1
	return 0


func _try_jump(wall: int) -> void:
	if _jump_buffer_left <= 0.0:
		return
	if _coyote_left > 0.0:
		_jump()
	elif wall != 0:
		_wall_jump(-wall)


func _jump() -> void:
	velocity.y = -jump_speed
	_coyote_left = 0.0
	_consume_jump()
	_visual.squash(JUMP_SQUASH)


func _wall_jump(direction: int) -> void:
	velocity = Vector2(direction * wall_jump_push, -jump_speed)
	_wall_lock_left = wall_jump_lock_time
	_wall_lock_direction = direction
	facing = direction
	_consume_jump()
	_visual.squash(WALL_JUMP_SQUASH)


func _consume_jump() -> void:
	_is_jump_rising = true
	_jump_buffer_left = 0.0
	_play_varied(_jump_sound)


# --- Dash ----------------------------------------------------------------------------

func _can_start_dash() -> bool:
	return can_dash and _dash_cooldown_left <= 0.0


func _start_dash(input: Vector2i) -> void:
	var direction := Vector2(input) if input != Vector2i.ZERO else Vector2(facing, 0)
	_dash_direction = direction.normalized()
	if input.x != 0:
		facing = input.x
	_state = State.DASHING
	_dash_time_left = dash_duration
	_dash_cooldown_left = dash_cooldown
	_is_jump_rising = false
	_wall_lock_left = 0.0
	_ghost_time_left = 0.0
	can_dash = false
	velocity = _dash_direction * dash_speed
	_dash_sound.play()
	dashed.emit()


func _update_dashing(delta: float) -> void:
	_dash_time_left -= delta
	velocity = _dash_direction * dash_speed
	_leave_ghosts(delta)
	if _dash_time_left <= 0.0:
		_state = State.NORMAL
		velocity = _dash_direction * dash_exit_speed


func _leave_ghosts(delta: float) -> void:
	_ghost_time_left -= delta
	if _ghost_time_left > 0.0:
		return
	_ghost_time_left = GHOST_INTERVAL
	var ghost := _spawn_in_parent(dash_ghost) as Sprite2D
	ghost.flip_h = facing < 0
	# Logo atrás do Jupiter na árvore: desenhado embaixo dele, mas na frente da sala.
	get_parent().move_child(ghost, get_index())


## Cria uma cena como irmã do Jupiter, na posição dele (sobrevive mesmo se ele sumir).
func _spawn_in_parent(scene: PackedScene) -> Node2D:
	var node := scene.instantiate() as Node2D
	get_parent().add_child(node)
	node.global_position = global_position
	return node


# --- Visual, som e colisões ----------------------------------------------------------

func _check_landing(fall_speed: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_visual.squash(LANDING_SQUASH)
		if fall_speed >= LANDING_SOUND_MIN_SPEED:
			_play_varied(_land_sound)
	_was_on_floor = on_floor


func _update_visual() -> void:
	_visual.facing = facing
	_visual.dash_ready = can_dash


func _play_varied(sound: AudioStreamPlayer) -> void:
	sound.pitch_scale = randf_range(1.0 - PITCH_VARIATION, 1.0 + PITCH_VARIATION)
	sound.play()


func _on_hurtbox_body_entered(_hazard: Node2D) -> void:
	die()
