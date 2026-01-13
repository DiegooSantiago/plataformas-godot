extends CharacterBody2D

const SPEED = 220.0
const JUMP_FORCE = -480.0
const GRAVITY = 900.0
const EXTRA_GRAVITY = 1400.0

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		if velocity.y < 0 and Input.is_action_pressed("ui_accept"):
			velocity.y += GRAVITY * delta
		else:
			velocity.y += EXTRA_GRAVITY * delta

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Movimiento horizontal
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction -= 1
	if Input.is_action_pressed("ui_right"):
		direction += 1

	velocity.x = direction * SPEED

	move_and_slide()
