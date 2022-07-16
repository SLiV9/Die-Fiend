extends KinematicBody2D

var held_down_movement = Vector2(0, 0)

func _ready():
	pass


func _process(delta):
	var movement = Vector2(0, 0)
	if Input.is_action_just_pressed("move_left") or held_down_movement.x < -1:
		movement.x = -16
	elif Input.is_action_just_pressed("move_right") or held_down_movement.x > 1:
		movement.x = 16
	elif Input.is_action_just_pressed("move_up") or held_down_movement.y < -1:
		movement.y = -16
	elif Input.is_action_just_pressed("move_down") or held_down_movement.y > 1:
		movement.y = 16
	else:
		var charge = 20.0 * delta
		if Input.is_action_pressed("move_left"):
			held_down_movement.x -= charge
			if held_down_movement.x < 0:
				held_down_movement.y = 0
		elif Input.is_action_pressed("move_right"):
			held_down_movement.x += charge
			if held_down_movement.x > 0:
				held_down_movement.y = 0
		elif Input.is_action_pressed("move_up"):
			held_down_movement.y -= charge
			if held_down_movement.y < 0:
				held_down_movement.x = 0
		elif Input.is_action_pressed("move_down"):
			held_down_movement.y += charge
			if held_down_movement.y > 0:
				held_down_movement.x = 0
	if movement.length() > 0:
		held_down_movement = Vector2(0, 0)
		var space = get_world_2d().get_direct_space_state()
		if not space.intersect_point(self.position + movement, 1, [], 1):
			self.position += movement
