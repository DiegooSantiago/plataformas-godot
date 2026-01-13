extends StaticBody2D

@export var distance := 200.0
@export var speed := 100.0

var start_position: Vector2
var direction := 1

func _ready():
	start_position = global_position

func _physics_process(delta):
	global_position.x += speed * direction * delta

	if abs(global_position.x - start_position.x) > distance:
		direction *= -1
