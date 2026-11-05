class_name Player
extends CharacterBody2D
## Jupiter: movimentação de plataforma de precisão. Pulo sustentado, coyote time,
## buffer de pulo, deslizar/pular na parede, dash em 8 direções e correção de quinas.
## A origem do nó fica nos pés. Os valores de "feel" são exportados para ajustar no Inspetor.
## Morre quando a Hurtbox toca a camada de perigos (espinhos pintados no TileMap).
## A Hurtbox precisa de `monitorable = true`: uma Area2D não monitorável não detecta
## corpos estáticos, e os tiles de um TileMapLayer são corpos estáticos.

signal died
signal dashed

enum State { NORMAL, DASHING, DEAD }

const GHOST_INTERVAL := 0.03
const APEX_GRAVITY_FACTOR := 0.5
const DEATH_EFFECT_OFFSET := Vector2(0, -8)
const JUMP_SQUASH := Vector2(0.8, 1.2)
const WALL_JUMP_SQUASH := Vector2(0.85, 1.15)
const LANDING_SQUASH := Vector2(1.2, 0.8)
const RESPAWN_SQUASH := Vector2(0.7, 1.3)
const RUNNING_SPEED := 10.0 ## Acima disto no chão, anima correndo.
const RUN_DUST_SPEED := 70.0 ## Acima disto no chão, levanta poeira dos passos.
const RUN_DUST_INTERVAL := 0.22
const WALL_DUST_OFFSET := Vector2(3, -4) ## Da origem até onde a mão encosta na parede.
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
@export var jump_speed := 145.0
@export var jump_sustain_time := 0.11 ## Segurando o pulo, a subida mantém a velocidade por este tempo.
@export var jump_run_boost := 30.0 ## Pular correndo dá um empurrão extra para frente.
@export var apex_speed_threshold := 40.0 ## Perto do topo do pulo (segurando) a gravidade cai pela metade.
@export var max_fall_speed := 160.0
@export var fast_fall_speed := 240.0 ## Segurando para baixo.
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.12
@export var corner_correction := 3 ## Pixels que o pulo/dash desliza para contornar quinas.

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
@export var dust_puff: PackedScene

var facing := 1
var can_dash := true

var _state := State.NORMAL
var _dash_direction := Vector2.ZERO
var _dash_time_left := 0.0
var _dash_cooldown_left := 0.0
var _coyote_left := 0.0
var _jump_buffer_left := 0.0
var _jump_sustain_left := 0.0
var _wall_lock_left := 0.0
var _wall_lock_direction := 0
var _is_wall_sliding := false
var _ghost_time_left := 0.0
var _run_dust_left := 0.0
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
	_correct_corners(delta)
	var fall_speed := velocity.y
	move_and_slide()
	if is_on_ceiling():
		_jump_sustain_left = 0.0
	_check_landing(fall_speed)
	_kick_up_run_dust(delta)
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
	effect.reset_physics_interpolation()
	died.emit()


func respawn(at: Vector2) -> void:
	global_position = at
	reset_physics_interpolation()
	velocity = Vector2.ZERO
	_state = State.NORMAL
	_jump_sustain_left = 0.0
	_wall_lock_left = 0.0
	_coyote_left = 0.0
	_jump_buffer_left = 0.0
	_dash_cooldown_left = 0.0
	_is_wall_sliding = false
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
	_is_wall_sliding = wall != 0 and input.x == wall and velocity.y > 0.0
	_apply_run(input.x, on_floor, delta)
	_apply_gravity(input, on_floor, delta)
	_apply_jump_sustain(delta)
	_try_jump(input.x, wall)


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


func _apply_gravity(input: Vector2i, on_floor: bool, delta: float) -> void:
	if on_floor:
		return
	var current_gravity := gravity
	if Input.is_action_pressed(&"jump") and absf(velocity.y) < apex_speed_threshold:
		current_gravity *= APEX_GRAVITY_FACTOR
	velocity.y = move_toward(velocity.y, _max_fall_speed(input), current_gravity * delta)


## Enquanto o botão de pulo está segurado, a subida não perde velocidade (por pouco tempo).
## Soltar cedo encerra a sustentação: toque = pulo baixo, segurar = pulo alto.
func _apply_jump_sustain(delta: float) -> void:
	if _jump_sustain_left <= 0.0:
		return
	if Input.is_action_pressed(&"jump"):
		velocity.y = minf(velocity.y, -jump_speed)
		_jump_sustain_left -= delta
	else:
		_jump_sustain_left = 0.0


func _max_fall_speed(input: Vector2i) -> float:
	if _is_wall_sliding:
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


func _try_jump(input_x: int, wall: int) -> void:
	if _jump_buffer_left <= 0.0:
		return
	if _coyote_left > 0.0:
		_jump(input_x)
	elif wall != 0:
		_wall_jump(-wall)


func _jump(input_x: int) -> void:
	velocity.y = -jump_speed
	velocity.x += jump_run_boost * input_x
	_coyote_left = 0.0
	_start_jump()
	_visual.squash(JUMP_SQUASH)
	_spawn_in_parent(dust_puff)


func _wall_jump(direction: int) -> void:
	velocity = Vector2(direction * wall_jump_push, -jump_speed)
	_wall_lock_left = wall_jump_lock_time
	_wall_lock_direction = direction
	facing = direction
	_start_jump()
	_visual.squash(WALL_JUMP_SQUASH)
	var dust := _spawn_in_parent(dust_puff)
	dust.global_position += Vector2(-direction * WALL_DUST_OFFSET.x, WALL_DUST_OFFSET.y)


func _start_jump() -> void:
	_jump_sustain_left = jump_sustain_time
	_jump_buffer_left = 0.0
	_play_varied(_jump_sound)


# --- Correção de quinas -----------------------------------------------------------------

## Se o movimento deste quadro bate numa quina por poucos pixels, desliza para contorná-la:
## subindo, desvia da quina do teto; no dash horizontal, sobe por cima de degraus baixos.
func _correct_corners(delta: float) -> void:
	if velocity.y < 0.0:
		_nudge_around(Vector2(0, velocity.y * delta), Vector2.RIGHT, _preferred_side())
	if _state == State.DASHING and velocity.x != 0.0:
		_nudge_around(Vector2(velocity.x * delta, 0), Vector2.UP, 1)


func _nudge_around(motion: Vector2, axis: Vector2, first_side: int) -> void:
	if not test_move(global_transform, motion):
		return
	for distance in range(1, corner_correction + 1):
		for side in [first_side, -first_side]:
			var nudge: Vector2 = axis * side * distance
			if not test_move(global_transform, nudge) and not test_move(global_transform.translated(nudge), motion):
				global_position += nudge
				return


func _preferred_side() -> int:
	if velocity.x != 0.0:
		return int(signf(velocity.x))
	return facing


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
	_jump_sustain_left = 0.0
	_wall_lock_left = 0.0
	_is_wall_sliding = false
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
	var ghost := _spawn_in_parent(dash_ghost) as DashGhost
	ghost.copy_pose(_visual.current_frame(), facing < 0)
	# Logo atrás do Jupiter na árvore: desenhado embaixo dele, mas na frente da sala.
	get_parent().move_child(ghost, get_index())


## Cria uma cena como irmã do Jupiter, na posição dele (sobrevive mesmo se ele sumir).
## Zera a interpolação: sem isso o nó "viaja" da origem até aqui no primeiro quadro.
func _spawn_in_parent(scene: PackedScene) -> Node2D:
	var node := scene.instantiate() as Node2D
	get_parent().add_child(node)
	node.global_position = global_position
	node.reset_physics_interpolation()
	return node


# --- Visual, som e colisões ----------------------------------------------------------

func _check_landing(fall_speed: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_visual.squash(LANDING_SQUASH)
		_visual.land()
		if fall_speed >= LANDING_SOUND_MIN_SPEED:
			_play_varied(_land_sound)
			_spawn_in_parent(dust_puff)
	_was_on_floor = on_floor


## Poeira dos passos enquanto corre no chão.
func _kick_up_run_dust(delta: float) -> void:
	_run_dust_left -= delta
	if is_on_floor() and absf(velocity.x) > RUN_DUST_SPEED and _run_dust_left <= 0.0:
		_run_dust_left = RUN_DUST_INTERVAL
		_spawn_in_parent(dust_puff)


func _update_visual() -> void:
	_visual.facing = facing
	_visual.dash_ready = can_dash
	_visual.set_pose(_current_pose(), absf(velocity.x) / run_speed)


func _current_pose() -> JupiterVisual.Pose:
	if _state == State.DASHING:
		return JupiterVisual.Pose.DASH
	if is_on_floor():
		return JupiterVisual.Pose.RUN if absf(velocity.x) > RUNNING_SPEED else JupiterVisual.Pose.IDLE
	if _is_wall_sliding:
		return JupiterVisual.Pose.WALL_SLIDE
	if absf(velocity.y) < apex_speed_threshold:
		return JupiterVisual.Pose.APEX
	return JupiterVisual.Pose.JUMP if velocity.y < 0.0 else JupiterVisual.Pose.FALL


func _play_varied(sound: AudioStreamPlayer) -> void:
	sound.pitch_scale = randf_range(1.0 - PITCH_VARIATION, 1.0 + PITCH_VARIATION)
	sound.play()


func _on_hurtbox_body_entered(_hazard: Node2D) -> void:
	die()
