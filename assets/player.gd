extends KinematicBody2D

const RUN_SPEED = 400

var velocity = Vector2()

func _ready():
	pass


func _physics_process(delta):
	var control = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if control.length() > 0.01:
		velocity = control * RUN_SPEED
	elif velocity.length() > 1:
		velocity *= 0.5
	else:
		velocity = Vector2(0, 0)
	move_and_slide(velocity)
