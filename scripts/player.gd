extends CharacterBody2D

enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ROLL_START,
	ROLLING,
	ROLL_STOP
}

@export var speed := 200.0
@export var jump_force := -540.0
@export var gravity := 1200.0
@export var roll_speed := 300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var state: PlayerState = PlayerState.IDLE
var facing_right: bool = true

# Respawn safety
var force_idle_frames: int = 0

# Límite izquierdo
var spawn_x: float
var left_limit: float

func _enter_tree():
	# HARD RESET antes de cualquier frame
	state = PlayerState.IDLE

func _ready():
	spawn_x = global_position.x
	left_limit = spawn_x
	velocity = Vector2.ZERO
	sprite.stop()
	_set_state(PlayerState.IDLE)

func _physics_process(delta: float) -> void:
	# BLOQUEO ABSOLUTO POST-RESPAWN
	if force_idle_frames > 0:
		force_idle_frames -= 1
		velocity = Vector2.ZERO
		_set_state(PlayerState.IDLE)
		move_and_slide()
		return

	_apply_gravity(delta)
	_handle_state(delta)
	move_and_slide()
	_apply_left_limit()
	_update_animation()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

func _handle_state(delta: float) -> void:
	match state:

		PlayerState.IDLE:
			_handle_horizontal_input()
			if Input.is_action_just_pressed("ui_up"):
				_jump()
			elif Input.is_action_just_pressed("ui_down") and is_on_floor():
				_set_state(PlayerState.ROLL_START)
			elif abs(velocity.x) > 0:
				_set_state(PlayerState.RUN)

		PlayerState.RUN:
			_handle_horizontal_input()
			if Input.is_action_just_pressed("ui_up"):
				_jump()
			elif Input.is_action_just_pressed("ui_down") and is_on_floor():
				_set_state(PlayerState.ROLL_START)
			elif velocity.x == 0:
				_set_state(PlayerState.IDLE)

		PlayerState.JUMP:
			_handle_horizontal_input()
			if velocity.y > 0:
				_set_state(PlayerState.FALL)

		PlayerState.FALL:
			_handle_horizontal_input()
			if is_on_floor():
				_set_state(PlayerState.IDLE)

		PlayerState.ROLL_START:
			velocity.y = 0
			velocity.x = roll_speed if facing_right else -roll_speed
			if sprite.frame == sprite.sprite_frames.get_frame_count("roll_start") - 1:
				_set_state(PlayerState.ROLLING)

		PlayerState.ROLLING:
			velocity.y += gravity * delta
			velocity.x = roll_speed if facing_right else -roll_speed
			if Input.is_action_just_pressed("ui_up"):
				_jump()
			elif not Input.is_action_pressed("ui_down"):
				_set_state(PlayerState.ROLL_STOP)

		PlayerState.ROLL_STOP:
			velocity.x = 0
			if sprite.frame == sprite.sprite_frames.get_frame_count("roll_stop") - 1:
				_set_state(PlayerState.IDLE)

func _handle_horizontal_input() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	if direction != 0:
		facing_right = direction > 0
		sprite.flip_h = not facing_right

func _jump() -> void:
	velocity.y = jump_force
	_set_state(PlayerState.JUMP)

func _apply_left_limit() -> void:
	if global_position.x < left_limit:
		global_position.x = left_limit
		velocity.x = 0

func _set_state(new_state: PlayerState) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		PlayerState.IDLE:
			sprite.play("idle")

		PlayerState.RUN:
			sprite.play("run")

		PlayerState.JUMP:
			sprite.play("jump")

		PlayerState.FALL:
			sprite.play("fall")

		PlayerState.ROLL_START:
			sprite.play("roll_start")

		PlayerState.ROLLING:
			sprite.play("rolling")

		PlayerState.ROLL_STOP:
			sprite.play("roll_stop")

func _update_animation() -> void:
	# Mantiene flip correcto en el aire
	sprite.flip_h = not facing_right

func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	sprite.stop()
	force_idle_frames = 2
	_set_state(PlayerState.IDLE)
